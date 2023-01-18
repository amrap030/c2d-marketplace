// SPDX-License-Identifier: MIT
// Creator: Kevin Hertwig <kevin.hertwig@gmail.com>

pragma solidity ^0.8.13;

// @author Kevin Hertwig <kevin.hertwig@gmail.com>
// @title ERC721Template

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./token/ERC721A.sol";

contract ERC721Template is
  ERC721A("Template", "TemplateSymbol"),
  Ownable,
  Pausable,
  ReentrancyGuard
{
  using Strings for uint256;
  using SafeMath for uint256;

  // Token base URI
  string private baseURI;
  string private tokenName;
  string private tokenSymbol;

  // Payment splitter address
  address payable private paymentSplitter;

  // Max amount of available tokens
  uint256 public constant MAX_SUPPLY = 1;
  // Initial price
  uint256 public price;
  // Tokens transferable
  bool private transferable;

  function initialize(
    address _owner,
    string calldata _name,
    string calldata _symbol,
    string calldata _baseURI,
    bool _transferable
  ) external returns (bool) {
    bool initResult = _initialize(
      _owner,
      _name,
      _symbol,
      _baseURI,
      _transferable
    );
    return (initResult);
  }

  function _initialize(
    address _owner,
    string memory _name,
    string memory _symbol,
    string memory _baseURI,
    bool _transferable
  ) internal returns (bool) {
    tokenName = _name;
    tokenSymbol = _symbol;
    baseURI = _baseURI;
    transferable = _transferable;
    _safeMint(_owner, 1);
    return true;
  }

  modifier callerIsUser() {
    require(tx.origin == msg.sender, "The caller is another contract");
    _;
  }

  /**
   * @dev Possibility to set a new price.
   *
   * @param _price uint256 new costs
   */
  function setPrice(uint256 _price) external onlyOwner {
    price = _price;
  }

  // Internals

  /**
   * @dev Override the ERC721A _startTokenId() function, so that the first token starts with id 1.
   *
   * @return 1
   */
  function _startTokenId() internal pure virtual override returns (uint256) {
    return 1;
  }

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

  // URI getters

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
    return
      bytes(baseURI).length > 0
        ? string(abi.encodePacked(baseURI, _tokenId.toString(), ".json"))
        : "";
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
   * @param startTokenId uint256 the first token id to be transferred
   * @param quantity uint256 the amount to be transferred
   */
  function _beforeTokenTransfers(
    address from,
    address to,
    uint256 startTokenId,
    uint256 quantity
  ) internal override whenNotPaused {
    super._beforeTokenTransfers(from, to, startTokenId, quantity);
  }

  function withdraw() external nonReentrant {
    Address.sendValue(paymentSplitter, address(this).balance);
  }
}
