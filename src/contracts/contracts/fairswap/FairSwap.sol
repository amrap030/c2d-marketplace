// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

contract FairSwap {
  enum Stage {
    created,
    initialized,
    accepted,
    keyRevealed,
    finished
  }

  struct FileSaleSession {
    Stage phase;
    address payable sender;
    address payable receiver;
    address verifier;
    uint depth;
    uint length;
    uint n;
    uint timeout;
    uint timeoutInterval;
    uint price;
    bytes32 keyCommit;
    bytes32 ciphertextRoot;
    bytes32 fileRoot;
    bytes32 key;
  }

  mapping(bytes32 => FileSaleSession) sessions;

  // function modifier to only allow calling the function in the right phase only from the correct party
  modifier allowed(
    bytes32 _sessionId,
    address _p,
    Stage _s
  ) {
    require(sessions[_sessionId].phase == _s);
    require(block.timestamp < sessions[_sessionId].timeout);
    require(msg.sender == _p);
    _;
  }

  // go to next phase
  function nextStage(bytes32 _sessionId) internal {
    sessions[_sessionId].phase = Stage(uint(sessions[_sessionId].phase) + 1);
    sessions[_sessionId].timeout =
      block.timestamp +
      sessions[_sessionId].timeoutInterval;
  }

  function _createFileSession(
    address payable _sender,
    address payable _receiver,
    address _verifier,
    address _algorithm,
    uint _timeoutInterval,
    uint _price
  ) internal returns (bytes32) {
    bytes32 sessionId = sha256(
      abi.encodePacked(_sender, _receiver, _algorithm)
    );

    sessions[sessionId] = FileSaleSession(
      Stage.created,
      payable(_sender),
      payable(_receiver),
      _verifier,
      0,
      0,
      0,
      block.timestamp + _timeoutInterval,
      _timeoutInterval,
      _price,
      0,
      0,
      0,
      0
    );

    return sessionId;
  }

  // constructor is initialize function
  function _initializeFileSession(
    bytes32 _sessionId,
    uint _depth,
    uint _length,
    uint _n,
    bytes32 _keyCommit,
    bytes32 _ciphertextRoot,
    bytes32 _fileRoot
  ) internal allowed(_sessionId, sessions[_sessionId].sender, Stage.created) {
    sessions[_sessionId].depth = _depth;
    sessions[_sessionId].length = _length;
    sessions[_sessionId].n = _n;
    sessions[_sessionId].keyCommit = _keyCommit;
    sessions[_sessionId].ciphertextRoot = _ciphertextRoot;
    sessions[_sessionId].fileRoot = _fileRoot;

    nextStage(_sessionId);
  }

  // function accept
  function _accept(
    bytes32 _sessionId
  )
    internal
    allowed(_sessionId, sessions[_sessionId].receiver, Stage.initialized)
  {
    require(msg.value >= sessions[_sessionId].price);
    nextStage(_sessionId);
  }

  // function revealKey (key)
  function _revealKey(
    bytes32 _sessionId,
    bytes32 _key
  ) internal allowed(_sessionId, sessions[_sessionId].sender, Stage.accepted) {
    require(sessions[_sessionId].keyCommit == sha256(abi.encodePacked(_key)));
    sessions[_sessionId].key = _key;
    nextStage(_sessionId);
  }

  // function complain about wrong hash of file
  function _noComplain(
    bytes32 _sessionId
  )
    internal
    allowed(_sessionId, sessions[_sessionId].receiver, Stage.keyRevealed)
  {
    transferFunds(sessions[_sessionId].sender, sessions[_sessionId].price);
    sessions[_sessionId].phase = Stage.finished;
    delete sessions[_sessionId];
  }

  // function complain about wrong hash of file
  function _complainAboutRoot(
    bytes32 _sessionId,
    bytes32 _Zm,
    bytes32[] calldata _proofZm
  )
    internal
    allowed(_sessionId, sessions[_sessionId].receiver, Stage.keyRevealed)
    returns (bool success)
  {
    require(
      vrfy(_sessionId, 2 * (sessions[_sessionId].n - 1), _Zm, _proofZm),
      "Not in encoding"
    );
    if (
      cryptSmall(_sessionId, 2 * (sessions[_sessionId].n - 1), _Zm) !=
      sessions[_sessionId].fileRoot
    ) {
      transferFunds(sessions[_sessionId].receiver, sessions[_sessionId].price);
      sessions[_sessionId].phase = Stage.finished;
      delete sessions[_sessionId];
      return true;
    }

    return false;
  }

  // function complain about wrong hash of two inputs
  function _complainAboutLeaf(
    bytes32 _sessionId,
    uint _indexOut,
    uint _indexIn,
    bytes32 _Zout,
    bytes32[] calldata _Zin1,
    bytes32[] calldata _Zin2,
    bytes32[] calldata _proofZout,
    bytes32[] calldata _proofZin
  )
    internal
    allowed(_sessionId, sessions[_sessionId].receiver, Stage.keyRevealed)
    returns (bool)
  {
    require(vrfy(_sessionId, _indexOut, _Zout, _proofZout), "Not in encoding");
    bytes32 Xout = cryptSmall(_sessionId, _indexOut, _Zout);

    require(
      vrfy(_sessionId, _indexIn, sha256(abi.encode(_Zin1)), _proofZin),
      "Not in encoding"
    );

    require(
      _proofZin[sessions[_sessionId].depth - 1] ==
        sha256(abi.encodePacked(_Zin2))
    );

    if (
      Xout !=
      sha256(
        abi.encode(
          cryptLarge(_sessionId, _indexIn, _Zin1),
          cryptLarge(_sessionId, _indexIn + 1, _Zin2)
        )
      )
    ) {
      transferFunds(sessions[_sessionId].receiver, sessions[_sessionId].price);
      sessions[_sessionId].phase = Stage.finished;
      delete sessions[_sessionId];
      return true;
    }

    return false;
  }

  // function complain about wrong hash of two inputs
  function _complainAboutNode(
    bytes32 _sessionId,
    uint _indexOut,
    uint _indexIn,
    bytes32 _Zout,
    bytes32 _Zin1,
    bytes32 _Zin2,
    bytes32[] calldata _proofZout,
    bytes32[] calldata _proofZin
  )
    internal
    allowed(_sessionId, sessions[_sessionId].receiver, Stage.keyRevealed)
    returns (bool)
  {
    require(vrfy(_sessionId, _indexOut, _Zout, _proofZout), "Not in encoding");
    bytes32 Xout = cryptSmall(_sessionId, _indexOut, _Zout);

    require(vrfy(_sessionId, _indexIn, _Zin1, _proofZin), "Not in encoding");

    require(_proofZin[sessions[_sessionId].depth - 1] == _Zin2);

    if (
      Xout !=
      sha256(
        abi.encode(
          cryptSmall(_sessionId, _indexIn, _Zin1),
          cryptSmall(_sessionId, _indexIn + 1, _Zin2)
        )
      )
    ) {
      transferFunds(sessions[_sessionId].receiver, sessions[_sessionId].price);
      sessions[_sessionId].phase = Stage.finished;
      delete sessions[_sessionId];
      return true;
    }

    return false;
  }

  // refund function is called in case some party did not contribute in time
  function refund(bytes32 _sessionId) public {
    require(block.timestamp > sessions[_sessionId].timeout);
    if (sessions[_sessionId].phase == Stage.accepted) {
      transferFunds(sessions[_sessionId].receiver, sessions[_sessionId].price);
      sessions[_sessionId].phase = Stage.finished;
      delete sessions[_sessionId];
    } else if (sessions[_sessionId].phase >= Stage.keyRevealed) {
      transferFunds(sessions[_sessionId].sender, sessions[_sessionId].price);
      sessions[_sessionId].phase = Stage.finished;
      delete sessions[_sessionId];
    }
  }

  // function to both encrypt and decrypt text chunks with key k
  function cryptLarge(
    bytes32 _sessionId,
    uint _index,
    bytes32[] memory _ciphertext
  ) private view returns (bytes32[] memory) {
    _index = _index * sessions[_sessionId].length;
    for (uint i = 0; i < sessions[_sessionId].length; i++) {
      _ciphertext[i] =
        sha256(abi.encode(_index, sessions[_sessionId].key)) ^
        _ciphertext[i];
      _index++;
    }
    return _ciphertext;
  }

  // function to decrypt hashes of the merkle tree
  function cryptSmall(
    bytes32 _sessionId,
    uint _index,
    bytes32 _ciphertext
  ) private view returns (bytes32) {
    return
      sha256(
        abi.encode(sessions[_sessionId].n + _index, sessions[_sessionId].key)
      ) ^ _ciphertext;
  }

  // function to verify Merkle Tree proofs
  function vrfy(
    bytes32 _sessionId,
    uint _index,
    bytes32 _value,
    bytes32[] calldata _proof
  ) private view returns (bool) {
    for (uint i = 0; i < sessions[_sessionId].depth; i++) {
      if ((_index & (1 << i)) >> i == 1)
        _value = sha256(
          abi.encodePacked(_proof[sessions[_sessionId].depth - i - 1], _value)
        );
      else
        _value = sha256(
          abi.encodePacked(_value, _proof[sessions[_sessionId].depth - i - 1])
        );
    }
    return (_value == sessions[_sessionId].ciphertextRoot);
  }

  function transferFunds(address _receiver, uint256 _amount) private {
    (bool success, ) = payable(_receiver).call{value: _amount}(""); // solhint-disable-line avoid-low-level-calls
    require(success, "Transfer failed");
  }
}
