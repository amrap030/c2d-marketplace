// SPDX-License-Identifier: MIT
// Creator: Kevin Hertwig <kevin.hertwig@gmail.com>

pragma solidity ^0.8.17;

// @author Kevin Hertwig <kevin.hertwig@gmail.com>
// @title IERC721Template

import "./IERC721A.sol";

interface IERC721Template is IERC721A {
  enum RolesType {
    Manager,
    DeployERC20,
    UpdateMetadata,
    Store
  }

  event MetadataCreated(
    address indexed createdBy,
    uint8 state,
    string decryptorUrl,
    bytes flags,
    bytes data,
    string metaDataDecryptorAddress,
    uint256 timestamp,
    uint256 blockNumber
  );

  event MetadataUpdated(
    address indexed updatedBy,
    uint8 state,
    string decryptorUrl,
    bytes flags,
    bytes data,
    string metaDataDecryptorAddress,
    uint256 timestamp,
    uint256 blockNumber
  );

  function initialize(
    address admin,
    string calldata name,
    string calldata symbol,
    string calldata baseURI,
    bool transferable
  ) external returns (bool);

  struct Roles {
    bool manager;
    bool deployERC20;
    bool updateMetadata;
    bool store;
  }

  struct metaDataProof {
    address validatorAddress;
    uint8 v; // v of validator signed message
    bytes32 r; // r of validator signed message
    bytes32 s; // s of validator signed message
  }

  function getPermissions(address user) external view returns (Roles memory);

  function setDataERC20(bytes32 _key, bytes calldata _value) external;

  function setMetaData(
    uint8 _metaDataState,
    string calldata _metaDataDecryptorUrl,
    string calldata _metaDataDecryptorAddress,
    bytes calldata flags,
    bytes calldata data,
    bytes32 _metaDataHash,
    metaDataProof[] memory _metadataProofs
  ) external;

  function getMetaData()
    external
    view
    returns (string memory, string memory, uint8, bool);

  function createERC20(
    uint256 _templateIndex,
    string[] calldata strings,
    address[] calldata addresses,
    uint256[] calldata uints,
    bytes[] calldata bytess
  ) external returns (address);

  function removeFromCreateERC20List(address _allowedAddress) external;

  function addToCreateERC20List(address _allowedAddress) external;

  function addToMetadataList(address _allowedAddress) external;

  function removeFromMetadataList(address _allowedAddress) external;

  function getId() external pure returns (uint8);
}
