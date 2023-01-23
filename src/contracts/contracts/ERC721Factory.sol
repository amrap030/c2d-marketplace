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
import "./utils/CloneFactory.sol";

contract ERC721Factory is CloneFactory, Ownable, ReentrancyGuard {
  using Strings for uint256;
  using SafeMath for uint256;

  // Number of all created ERC721 contracts with this factory
  uint256 public currentERC721Count = 0;

  // ERC721 Template address
  address public templateAddress;

  event ERC721Created(
    address indexed owner,
    address indexed creator,
    address indexed templateAddress,
    address tokenAddress,
    string tokenName,
    string tokenSymbol,
    string metadataURI
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
    string memory _metadataURI
  ) external returns (address tokenAddress) {
    address template = templateAddress;
    tokenAddress = createClone(template);
    currentERC721Count += 1;

    emit ERC721Created(
      _owner,
      msg.sender,
      templateAddress,
      tokenAddress,
      _name,
      _symbol,
      _metadataURI
    );

    IERC721Template(tokenAddress).initialize(
      _owner,
      _name,
      _symbol,
      _metadataURI
    );
  }
}
