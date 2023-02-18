// SPDX-License-Identifier: MIT
// Creator: Kevin Hertwig <kevin.hertwig@gmail.com>

pragma solidity ^0.8.17;

// @author Kevin Hertwig <kevin.hertwig@gmail.com>
// @title IERC721Template

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface IERC721Template is IERC721 {
  enum Kind {
    dataset,
    algorithm
  }

  event MetadataUpdated(
    address indexed updatedBy,
    string metadataURI,
    uint256 timestamp,
    uint256 blockNumber
  );

  function initialize(
    address admin,
    string calldata name,
    string calldata symbol,
    string calldata baseURI,
    Kind _kind
  ) external returns (bool);

  function addManager(address _manager) external;

  function removeManager(address _manager) external;

  function setPrice(uint256 _price) external;

  function updateMetadata(string memory _metadataURI) external;

  function pause() external;

  function unpause() external;

  function withdraw() external;
}
