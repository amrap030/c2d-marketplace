// SPDX-License-Identifier: MIT
// Creator: Kevin Hertwig <kevin.hertwig@gmail.com>

pragma solidity ^0.8.17;

// @author Kevin Hertwig <kevin.hertwig@gmail.com>
// @title ERC721Factory

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./interfaces/IERC721Template.sol";
import "./CloneFactory.sol";

contract ERC721Factory is CloneFactory, Ownable, ReentrancyGuard {
  using Strings for uint256;
  using SafeMath for uint256;

  uint256 private currentNFTCount;

  // ERC721 Template address
  address private templateAddress;

  // Mapping to limit amount of NFT's per address during whitelist sale
  mapping(address => uint) public amountNFTsPerWalletWhitelistSale;

  // List of all available tokens
  mapping(address => address) public availableTokens;

  event NFTCreated(
    address indexed admin,
    address indexed creator,
    address indexed templateAddress,
    address tokenAddress,
    string tokenName,
    string tokenSymbol,
    string tokenURI,
    bool transferable
  );

  constructor(address _templateAddress) {
    require(_templateAddress != address(0), "Null address not allowed");
    templateAddress = _templateAddress;
  }

  function setTemplateAddress(address _templateAddress) external onlyOwner {
    require(_templateAddress != address(0), "Null address not allowed");
    templateAddress = _templateAddress;
  }

  function cloneContract(
    address _owner,
    string memory _name,
    string memory _symbol,
    string memory _tokenURI,
    bool _transferable
  ) public returns (address token) {
    address template = templateAddress;
    token = createClone(template);
    availableTokens[token] = token;
    currentNFTCount += 1;

    emit NFTCreated(
      _owner,
      msg.sender,
      templateAddress,
      token,
      _name,
      _symbol,
      _tokenURI,
      _transferable
    );

    IERC721Template(token).initialize(
      _owner,
      _name,
      _symbol,
      _tokenURI,
      _transferable
    );
  }
}
