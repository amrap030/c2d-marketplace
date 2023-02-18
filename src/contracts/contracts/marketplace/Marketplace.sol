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

  event ComputationVerified(
    address indexed sender,
    address indexed receiver,
    address indexed nftAddress,
    address algorithm
  );

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

  event OrderAccepted(
    address indexed sender,
    address indexed receiver,
    address indexed nftAddress,
    address algorithm,
    uint256 price,
    bytes32 sessionId
  );

  event OrderFulfilled();
  event OrderCancelled();

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

  function createOrder(
    address _nftAddress,
    address _verifier,
    address _algorithm,
    string memory _pkAddress
  ) external {
    uint256 price = offers[_nftAddress][_algorithm]; // how to efficiently get offer???
    address sender = IERC721(_nftAddress).ownerOf(1);

    bytes32 sessionId = createFileSession(
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
    require(session.phase == Stage.created, "Already initialized");
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
  ) private nonReentrant {
    initializeFileSession(
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

  function buy(bytes32 _sessionId) external {
    accept(_sessionId);

    FileSaleSession memory session = sessions[_sessionId];

    emit OrderAccepted(
      session.sender,
      session.receiver,
      session.nftAddress,
      session.algorithm,
      session.price,
      _sessionId
    );
  }

  receive() external payable {
    revert("Only if computations are sold");
  }
}
