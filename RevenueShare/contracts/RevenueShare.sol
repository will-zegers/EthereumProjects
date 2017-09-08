pragma solidity ^0.4.14;

contract RevenueShare {
  address public creator;
  mapping(uint => address) public shareholders;
  uint public numShareholders;

  event Disburse(uint _amount, uint _numShareholders);

  modifier onlyCreator() {
    require(msg.sender == creator);
    _;
  }

  function RevenueShare(address[] addresses) {
    creator = msg.sender;

    for (uint i = 0; i < addresses.length; i++) {
      shareholders[i] = addresses[i];
      numShareholders++;
    }
  }

  function addShareholder(address newShareholder) onlyCreator {
    shareholders[numShareholders] = newShareholder;
    numShareholders++;
  }

  function shareRevenue() public payable onlyCreator returns (bool success) {
    uint amount = msg.value / numShareholders;

    for (uint i = 0; i < numShareholders; i++) {
      assert(shareholders[i].send(amount));
    }

    Disburse(msg.value, numShareholders);

    return true;
  }

  function kill() {
    if (msg.sender == creator) suicide(creator);
  }

  function() payable {}
}
