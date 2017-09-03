contract RevenueShare {
  address public creator;
  mapping(uint => address) public shareholders;
  uint public numShareholders;

  event Disburse(uint _amount, uint _numShareholders);

  function RevenueShare(address[] addresses) {
    creator = msg.sender;
    numShareholders = addresses.length;

    for (uint i = 0; i < addresses.length; ++i) {
      shareholders[i] = addresses[i];
    }
  }

  function shareRevenue() public payable returns (bool success) {
    uint amount = msg.value / numShareholders;

    for (uint i = 0; i < numShareholders; ++i) {
      assert(shareholders[i].send(amount));
    }

    Disburse(msg.value, numShareholders);

    return true;
  }

  function kill() {
    if (msg.sender == creator) suicide(creator);
  }
}
