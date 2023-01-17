// SPDX-License-Identifier: MIT
// Creator: Kevin Hertwig <kevin.hertwig@gmail.com>

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract EIP712 is Ownable {
  using ECDSA for bytes32;

  /**
   * @dev The key used to sign whitelist signatures.
   * Note This key will be recoverd from signature to do signature verification
   */
  address private signerAddress;

  /**
   * @dev Domain Separator is the EIP-712 defined structure that defines what contract
   * and chain these signatures can be used for. This ensures people can't take
   * a signature used to mint on one contract and use it for another, or a signature
   * from testnet to replay on mainnet.
   * It has to be created in the constructor so we can dynamically grab the chainId.
   * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-712.md#definition-of-domainseparator
   */
  bytes32 private domainSeparator;

  /**
   * @dev The typehash for the data type specified in the structured data
   * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-712.md#rationale-for-typehash
   * This should match whats in the client side whitelist signing code
   * https://github.com/msfeldstein/EIP712-whitelisting/blob/main/test/signWhitelist.ts#L22
   */
  bytes32 private constant MINTER_TYPEHASH =
    keccak256("Minter(address wallet)");

  constructor(address _signerAddress, string memory _tokenName) {
    signerAddress = _signerAddress;
    // This should match whats in the client side whitelist signing code
    // https://github.com/msfeldstein/EIP712-whitelisting/blob/main/test/signWhitelist.ts#L12
    domainSeparator = keccak256(
      abi.encode(
        keccak256(
          "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        ),
        // This should match the domain you set in your client side signing.
        keccak256(bytes(_tokenName)),
        keccak256(bytes("1")),
        block.chainid,
        address(this)
      )
    );
  }

  /**
   * @dev Possibility to set a new signer address for whitelist sale.
   *
   * @param _signerAddress address new signer address
   */
  function setSignerAddress(address _signerAddress) external onlyOwner {
    signerAddress = _signerAddress;
  }

  /**
   * @dev Modifier to check for whitelist sale eligibility by verifying the signature
   *
   * @param _signature the received voucher (signature)
   */
  modifier requiresWhitelist(bytes calldata _signature) {
    // Verify EIP-712 signature by recreating the data structure
    // that we signed on the client side, and then using that to recover
    // the address that signed the signature for this data.
    bytes32 digest = keccak256(
      abi.encodePacked(
        "\x19\x01",
        domainSeparator,
        keccak256(abi.encode(MINTER_TYPEHASH, msg.sender))
      )
    );
    // Use the recover method to see what address was used to create
    // the signature on this data.
    // Note that if the digest doesn't exactly match what was signed we'll
    // get a random recovered address.
    address recoveredAddress = digest.recover(_signature);
    require(recoveredAddress == signerAddress, "Not whitelisted");
    _;
  }
}
