pragma solidity ^0.4.15;

contract Owned {
  address public owner;

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  function Owner() {
    owner = msg.sender;
  }
}

contract Mortal is Owned {
  function kill() onlyOwner {
    suicide(owner);
  }
}

contract CallOption is Owned, Mortal {
  bool public isActive;
  bool public isComplete;

  address public buyer;
  address public seller;

  uint public strikePrice;
  uint public premium;
  uint public timeToExpiry;
  uint public startTime;
  uint public underlyingQty;

  string public underlyingName;

  modifier mustBeActive() {
    require(isActive);
    _;
  }

  modifier mustBeInactive() {
    require(!isActive);
    _;
  }

  modifier onlyBuyer() {
    require(msg.sender == buyer);
    _;
  }

  modifier onlySeller() {
    require(msg.sender == seller);
    _;
  }

  function CallOption() {
    isActive = false;
    isComplete = false;
    seller = msg.sender;
  }

  function initialize(
    address _buyer,
    uint _strikePrice,
    uint _premium,
    uint _timeToExpiry,
    uint _underlyingQty,
    string _underlyingName) onlySeller mustBeInactive {

    buyer = _buyer;
    strikePrice = _strikePrice;
    premium = _premium;
    timeToExpiry = _timeToExpiry;
    underlyingQty = _underlyingQty;
    underlyingName = _underlyingName;

    startTime = now;
  }

  function validate() onlyBuyer mustBeInactive payable {
    require(!isExpired());
    require(msg.value >= premium);

    assert(seller.send(premium));
    assert(buyer.send(msg.value - premium));

    isActive = true;
  }

  function exercise() onlyBuyer mustBeActive payable {
    require(!isExpired());

    uint amount = strikePrice * underlyingQty;
    require(msg.value >= amount);

    assert(seller.send(amount));
    assert(buyer.send(msg.value - amount));

    isActive = false;
    isComplete = true;
  }

  function isExpired() constant returns (bool) {
    return now > startTime + timeToExpiry;
  }
}