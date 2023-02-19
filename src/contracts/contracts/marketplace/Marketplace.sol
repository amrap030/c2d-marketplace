// SPDX-License-Identifier: MIT
// Creator: Kevin Hertwig <kevin.hertwig@gmail.com>

pragma solidity ^0.8.17;

// @author Kevin Hertwig <kevin.hertwig@gmail.com>
// @title Marketplace

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "../fairswap/FairSwap.sol";

contract Marketplace is ReentrancyGuard, FairSwap {
  using Strings for uint256;

  event OfferCreated(
    address indexed nftAddress,
    address indexed algorithm,
    address indexed sender,
    uint256 price
  );

  event OfferUpdated();
  event OfferRemoved();

  event OrderCreated(
    Stage phase,
    address indexed sender,
    address indexed receiver,
    address indexed nftAddress,
    address algorithm,
    address verifier,
    string pkAddress,
    uint256 timeout,
    uint256 timeoutInterval,
    uint256 price,
    bytes32 sessionId
  );

  event OrderInitialized(
    uint256 depth,
    uint256 length,
    uint256 n,
    bytes32 keyCommit,
    bytes32 ciphertextRoot,
    bytes32 fileRoot,
    bytes32 sessionId
  );

  event OrderAccepted(bytes32 sessionId);

  event OrderRevealed(bytes32 key, bytes32 sessionId);

  event OrderFulfilled(bytes32 sessionId);
  event OrderCancelled(bytes32 sessionId);

  // elliptic curve points for proof verification
  struct G1Point {
    uint X;
    uint Y;
  }

  struct G2Point {
    uint[2] X;
    uint[2] Y;
  }

  struct Proof {
    G1Point a;
    G2Point b;
    G1Point c;
  }

  /// @notice nftAddress -> offers -> price
  mapping(address => mapping(address => uint256)) private offers;
  /// @notice receiverAddress -> fileSaleSession
  mapping(address => bytes32) private orders;

  bytes4 private constant INTERFACE_ID_ERC721 = 0x80ac58cd;

  uint256 constant TIMEOUT_INTERVAL = 1 hours;

  /**
   * @dev Creates a new offer as a sender, i.e. storing a pair of algorithm addresses
   *      and prices with a link to the dataset's nft address.
   *
   * @param _nftAddress address Address of the dataset nft
   * @param _algorithms address[] array of addresses for computation algorithms
   * @param _prices uint256[] array of prices for each computation algorithm
   */
  function createOffer(
    address _nftAddress,
    address[] calldata _algorithms,
    uint256[] calldata _prices
  ) external {
    require(_algorithms.length == _prices.length, "Lengths not equal");
    require(
      IERC165(_nftAddress).supportsInterface(INTERFACE_ID_ERC721),
      "Not a valid ERC721"
    );

    for (uint256 i = 0; i < _algorithms.length; i++) {
      require(_prices[i] > 0, "Price can't be negative");
      offers[_nftAddress][_algorithms[i]] = _prices[i];

      emit OfferCreated(
        _nftAddress,
        _algorithms[i],
        IERC721(_nftAddress).ownerOf(1),
        _prices[i]
      );
    }
  }

  /**
   * @dev Creates a new order as a receiver which creates a new FileSaleSession
   *      that serves as a sales agreement between sender and receiver.
   *
   * [IMPORTANT]
   * ====
   * The receiver doesn't have to pay anything at this point, because he got no
   * data so far. This means, that the sender has to send the result of the computation
   * to the receiver upfront, before receiving any money. However, the result is hashed,
   * so the plain result is invisible to the receiver at this point. This is a countermeasure
   * against the sender not sending data after making the purchase. The only downside of this
   * is, that the sender has to waste unnecessary compute power in case the receiver won't
   * accept the purchase later. However, there could be a punishment mechanism in place, so
   * that receivers, who continously won't pay, will get blocked on the marketplace.
   * ====
   *
   * @param _nftAddress address address of the dataset nft
   * @param _verifier address address of the proof verification smart contract
   * @param _algorithm address address of the chosen computation algorithm
   * @param _pkAddress string url of the proving key
   */
  function createOrder(
    address _nftAddress,
    address _verifier,
    address _algorithm,
    string memory _pkAddress
  ) external {
    uint256 price = offers[_nftAddress][_algorithm];
    address sender = IERC721(_nftAddress).ownerOf(1);

    bytes32 sessionId = _createFileSession(
      payable(sender),
      payable(msg.sender),
      _nftAddress,
      _algorithm,
      _verifier,
      _pkAddress,
      TIMEOUT_INTERVAL,
      price
    );

    FileSaleSession memory session = sessions[sessionId];

    emit OrderCreated(
      session.phase,
      session.sender,
      session.receiver,
      session.nftAddress,
      session.algorithm,
      session.verifier,
      session.pkAddress,
      session.timeout,
      session.timeoutInterval,
      session.price,
      sessionId
    );
  }

  /**
   * @dev Proves the correct execution of the off-chain zero-knowledge program,
   *      so that the receiver can be sure about the result of the computation.
   *      On success, the FileSaleSession will be updated with all the
   *      necessary information for a potential Proof of Misbehavior (PoM) by
   *      the receiver.
   *
   * @param _sessionId bytes32 session id of FileSaleSession
   * @param _depth uint256 depth of the merkletree
   * @param _length uint256 length of the plain data
   * @param _n uint256 amount of slices of the plain data
   * @param _keyCommit bytes32 hashed encryption key
   * @param _ciphertextRoot bytes32 root hash of the encoding
   * @param _fileRoot bytes32 root hash of the plain data
   * @param _input uint256 public inputs of the zero knowledge proof
   * @param _proof Proof zero knowledge proof
   */
  function proofComputation(
    bytes32 _sessionId,
    uint256 _depth,
    uint256 _length,
    uint256 _n,
    bytes32 _keyCommit,
    bytes32 _ciphertextRoot,
    bytes32 _fileRoot,
    uint256[] calldata _input,
    Proof calldata _proof
  ) external nonReentrant {
    FileSaleSession memory session = sessions[_sessionId];
    require(msg.sender == session.sender, "Not the sender");

    bytes memory payload = abi.encodeWithSignature(
      "verifyTx(((uint256,uint256),(uint256[2],uint256[2]),(uint256,uint256)),uint256[])",
      _proof,
      _input
    );
    (bool success, bytes memory data) = address(session.verifier).call(payload); // solhint-disable-line avoid-low-level-calls
    require(success);

    bool isVerified = abi.decode(data, (bool));
    require(isVerified);

    _initFileSession(
      _sessionId,
      _depth,
      _length,
      _n,
      _keyCommit,
      _ciphertextRoot,
      _fileRoot
    );
  }

  function _initFileSession(
    bytes32 _sessionId,
    uint256 _depth,
    uint256 _length,
    uint256 _n,
    bytes32 _keyCommit,
    bytes32 _ciphertextRoot,
    bytes32 _fileRoot
  ) private {
    _initializeFileSession(
      _sessionId,
      _depth,
      _length,
      _n,
      _keyCommit,
      _ciphertextRoot,
      _fileRoot
    );

    FileSaleSession memory session = sessions[_sessionId];

    emit OrderInitialized(
      session.depth,
      session.length,
      session.n,
      session.keyCommit,
      session.ciphertextRoot,
      session.fileRoot,
      _sessionId
    );
  }

  /**
   * @dev Accept the file sale and commit to the received data as a receiver.
   *      The price of the order in turn is locked in the marketplace, before
   *      the exchange is fulfilled.
   *
   * @param _sessionId bytes32 session id of FileSaleSession
   */
  function buy(bytes32 _sessionId) external payable {
    _accept(_sessionId);

    emit OrderAccepted(_sessionId);
  }

  /**
   * @dev Reveals the plain encryption key to the receiver, so that the receiver
   *      can decrypt the encoding to check it's validity. If everything is
   *      valid at this point, the protocol stops and the receiver got untampered
   *      data. If it is invalid, the receiver will compute a PoM and complains, to
   *      get back his funds.
   *
   * @param _sessionId bytes32 session id of FileSaleSession
   * @param _key bytes32 plain encryption key
   */
  function reveal(bytes32 _sessionId, bytes32 _key) external {
    _revealKey(_sessionId, _key);

    emit OrderRevealed(_key, _sessionId);
  }

  /**
   * @dev Receiver complains either about a wrong decryption key or wrongly
   *      encrypted plain data. If the call is successful, the protocol stops
   *      and the receiver gets back his funds. The FileSaleSession will be
   *      deleted subsequently. If the call is not successful, nothing happens.
   *
   * @param _sessionId bytes32 session id of FileSaleSession
   * @param _Zm bytes32
   * @param _proofZm bytes32[]
   */
  function complainAboutRoot(
    bytes32 _sessionId,
    bytes32 _Zm,
    bytes32[] calldata _proofZm
  )
    external
    allowed(_sessionId, sessions[_sessionId].receiver, Stage.keyRevealed)
  {
    bool success = _complainAboutRoot(_sessionId, _Zm, _proofZm);

    if (success) emit OrderCancelled(_sessionId);
  }

  /**
   * @dev Receiver complains about a intentional modification of a hash value in
   *      a non-leaf node. If the call is successful, the protocol stops
   *      and the receiver gets back his funds. The FileSaleSession will be
   *      deleted subsequently. If the call is not successful, nothing happens.
   *
   * @param _sessionId bytes32 session id of FileSaleSession
   * @param _indexOut bytes32
   * @param _indexIn bytes32
   * @param _Zout bytes32
   * @param _Zin1 bytes32
   * @param _Zin2 bytes32
   * @param _proofZout bytes32[]
   * @param _proofZin bytes32[]
   */
  function complainAboutNode(
    bytes32 _sessionId,
    uint _indexOut,
    uint _indexIn,
    bytes32 _Zout,
    bytes32 _Zin1,
    bytes32 _Zin2,
    bytes32[] calldata _proofZout,
    bytes32[] calldata _proofZin
  )
    external
    allowed(_sessionId, sessions[_sessionId].receiver, Stage.keyRevealed)
  {
    bool success = _complainAboutNode(
      _sessionId,
      _indexOut,
      _indexIn,
      _Zout,
      _Zin1,
      _Zin2,
      _proofZout,
      _proofZin
    );

    if (success) emit OrderCancelled(_sessionId);
  }

  /**
   * @dev Receiver complains about a intentional modification of leaf value.
   *      If the call is successful, the protocol stops and the receiver gets back
   *      his funds. The FileSaleSession will be deleted subsequently. If the call
   *      is not successful, nothing happens.
   *
   * @param _sessionId bytes32 session id of FileSaleSession
   * @param _indexOut bytes32
   * @param _indexIn bytes32
   * @param _Zout bytes32
   * @param _Zin1 bytes32[]
   * @param _Zin2 bytes32[]
   * @param _proofZout bytes32[]
   * @param _proofZin bytes32[]
   */
  function complainAboutLeaf(
    bytes32 _sessionId,
    uint _indexOut,
    uint _indexIn,
    bytes32 _Zout,
    bytes32[] calldata _Zin1,
    bytes32[] calldata _Zin2,
    bytes32[] calldata _proofZout,
    bytes32[] calldata _proofZin
  )
    public
    allowed(_sessionId, sessions[_sessionId].receiver, Stage.keyRevealed)
  {
    bool success = _complainAboutLeaf(
      _sessionId,
      _indexOut,
      _indexIn,
      _Zout,
      _Zin1,
      _Zin2,
      _proofZout,
      _proofZin
    );

    if (success) emit OrderCancelled(_sessionId);
  }

  /**
   * fallback function so nobody can send funds to the marketplace without
   * fulfilling a data exchange trade.
   */
  receive() external payable {
    revert("Only if computations are sold");
  }
}
