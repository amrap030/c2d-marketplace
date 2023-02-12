// SPDX-License-Identifier: MIT
// Creator: Kevin Hertwig <kevin.hertwig@gmail.com>

pragma solidity ^0.8.17;

// @author Kevin Hertwig <kevin.hertwig@gmail.com>
// @title Marketplace

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract Marketplace is ReentrancyGuard {
  using Strings for uint256;

  event ItemCreated(
    address indexed nftAddress,
    address indexed algorithm,
    Item item
  );

  event ItemUpdated();
  event ItemRemoved();
  event ItemSold();

  event ComputationVerified(
    address indexed seller,
    address indexed buyer,
    address indexed nftAddress,
    address algorithm
  );

  event OrderCreated(
    address indexed seller,
    address indexed buyer,
    address indexed nftAddress,
    string pkAddress,
    uint256 price
  );

  event OrderUpdated();
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

  struct Item {
    address seller;
    uint256 price;
  }

  struct Order {
    address nftAddress;
    address algorithm;
    address verifier;
    address buyer;
    address seller;
    uint256 price;
    uint256 createdAt;
    uint256 deadline;
    string provingKey;
    bool isFulfilled;
    bool isProven;
  }

  /// @notice nftAddress -> algorithm -> Item
  mapping(address => mapping(address => Item)) private items;
  /// @notice buyerAddress -> Order[]
  mapping(address => Order[]) private orders;

  bytes4 private constant INTERFACE_ID_ERC721 = 0x80ac58cd;

  function createItem(
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
      items[_nftAddress][_algorithms[i]] = Item(msg.sender, _prices[i]);

      emit ItemCreated(
        _nftAddress,
        _algorithms[i],
        items[_nftAddress][_algorithms[i]]
      );
    }
  }

  function createOrder(
    address _nftAddress,
    address _verifier,
    address _algorithm,
    string memory _pkAddress
  ) external payable {
    Item memory item = items[_nftAddress][_algorithm];
    require(msg.value >= item.price, "Not enough funds");

    orders[_nftAddress].push(
      Order(
        _nftAddress,
        _algorithm,
        _verifier,
        msg.sender,
        item.seller,
        item.price,
        block.timestamp,
        block.timestamp + 3 days,
        _pkAddress,
        false,
        false
      )
    );

    emit OrderCreated(
      item.seller,
      msg.sender,
      _nftAddress,
      _pkAddress,
      item.price
    );
  }

  function verifyComputation(
    address _nftAddress,
    uint256 _orderIndex,
    uint256[] calldata _input,
    Proof calldata _proof
  ) external nonReentrant {
    Order memory order = orders[_nftAddress][_orderIndex];
    require(!order.isFulfilled && !order.isProven, "Order already fulfilled");
    require(msg.sender == order.buyer, "Not the buyer");

    bytes memory payload = abi.encodeWithSignature(
      "verifyTx(((uint256,uint256),(uint256[2],uint256[2]),(uint256,uint256)),uint256[])",
      _proof,
      _input
    );
    (bool success, bytes memory data) = address(order.verifier).call(payload); // solhint-disable-line avoid-low-level-calls
    require(success);

    bool isVerified = abi.decode(data, (bool));
    require(isVerified, "Invalid proof");

    transferFunds(order.seller, order.price);
    order.isFulfilled = true;
    order.isProven = true;

    emit ComputationVerified(
      order.seller,
      order.buyer,
      _nftAddress,
      order.algorithm
    );
  }

  function redeem(
    address _nftAddress,
    uint256 _oderIndex
  ) external nonReentrant {
    Order memory order = orders[_nftAddress][_oderIndex];

    if (
      msg.sender == order.seller &&
      order.deadline < block.timestamp &&
      !order.isFulfilled &&
      !order.isProven
    ) {
      transferFunds(msg.sender, order.price);
    }
  }

  function transferFunds(address _receiver, uint256 _amount) internal {
    (bool success, ) = payable(_receiver).call{value: _amount}(""); // solhint-disable-line avoid-low-level-calls
    require(success, "Transfer failed");
  }

  receive() external payable {
    revert("Only if items are sold");
  }
}
