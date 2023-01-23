// SPDX-License-Identifier: MIT
// Creator: Kevin Hertwig <kevin.hertwig@gmail.com>

pragma solidity ^0.8.13;

// @author Kevin Hertwig <kevin.hertwig@gmail.com>
// @title ERC721Template

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract ERC721Template is
  ERC721("Name", "Symbol"),
  Ownable,
  Pausable,
  ReentrancyGuard,
  AccessControl
{
  using Strings for uint256;
  using SafeMath for uint256;

  // Token base URI
  string private metadataURI;
  string private tokenName;
  string private tokenSymbol;

  // Payment splitter address
  address payable private paymentSplitter;

  // Initial price
  uint256 public price;

  // Tokens transferable
  bool private transferable;

  bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");

  function initialize(
    address _owner,
    string calldata _name,
    string calldata _symbol,
    string calldata _metadataURI
  ) external returns (bool) {
    return _initialize(_owner, _name, _symbol, _metadataURI);
  }

  function _initialize(
    address _owner,
    string memory _name,
    string memory _symbol,
    string memory _metadataURI
  ) internal returns (bool) {
    tokenName = _name;
    tokenSymbol = _symbol;
    metadataURI = _metadataURI;

    _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    _safeMint(_owner, 1);

    return true;
  }

  // Setter

  /**
   * @dev Add a new manager.
   *
   * @param _manager address new manager
   */
  function addManager(address _manager) external onlyRole(MANAGER_ROLE) {
    _grantRole(MANAGER_ROLE, _manager);
  }

  /**
   * @dev Remove a manager.
   *
   * @param _manager address manager
   */
  function removeManager(address _manager) external onlyOwner {
    _revokeRole(MANAGER_ROLE, _manager);
  }

  /**
   * @dev Set a new price.
   *
   * @param _price uint256 new costs
   */
  function setPrice(uint256 _price) external onlyRole(MANAGER_ROLE) {
    price = _price;
  }

  /**
   * @dev Update metadata
   *
   * @param _metadataURI string new base URI
   */
  function updateMetadata(
    string memory _metadataURI
  ) external onlyRole(MANAGER_ROLE) {
    metadataURI = _metadataURI;
  }

  // Overrides

  /**
   * @dev Override internal name() function
   *
   * @return Token name
   */
  function name() public view override returns (string memory) {
    return tokenName;
  }

  /**
   * @dev Override internal symbol() function
   *
   * @return Token symbol
   */
  function symbol() public view override returns (string memory) {
    return tokenSymbol;
  }

  /**
   * @dev Override internal supportsInterface() function
   *
   * @return bool stating if interface is supported
   */
  function supportsInterface(
    bytes4 interfaceId
  ) public view override(AccessControl, ERC721) returns (bool) {
    return super.supportsInterface(interfaceId);
  }

  /**
   * @dev Get the token uri for 1 token by id.
   *
   * @param _tokenId uint256 id of the token
   * @return string concatenated token uri for 1 token
   */
  function tokenURI(
    uint256 _tokenId
  ) public view virtual override returns (string memory) {
    require(_exists(_tokenId), "URI query for nonexistent token");
    return bytes(metadataURI).length > 0 ? metadataURI : "";
  }

  // Pausable

  /**
   * @dev Pauses any transfers for serially-ordered token ids. This includes minting.
   */
  function pause() external onlyOwner {
    _pause();
  }

  /**
   * @dev Unpauses any transfers for serially-ordered token ids. This includes minting.
   */
  function unpause() external onlyOwner {
    _unpause();
  }

  /**
   * @dev Hook that is called before a set of serially-ordered token ids are about to be transferred.
   *      This includes minting.
   *      Function is overriden, because it uses the whenNotPaused modifier from the Pausable contract
   *
   * @param from address representing the previous owner of the given token ID
   * @param to target address that will receive the tokens
   * @param tokenId uint256 the first token id to be transferred
   * @param batchSize uint256 the amount to be transferred
   */
  function _beforeTokenTransfer(
    address from,
    address to,
    uint256 tokenId,
    uint256 batchSize
  ) internal override(ERC721) whenNotPaused {
    super._beforeTokenTransfer(from, to, tokenId, batchSize);
  }

  // Withdraw

  function withdraw() external nonReentrant {
    Address.sendValue(paymentSplitter, address(this).balance);
  }
}
