contract CrowdFunding {
require(msg.sender == owner);
    _;
  }

  function CrowdFunding(uint _deadline, uint _goal) {
    owner = msg.sender;
    deadline = _deadline;
    goal = _goal;
    campaignStatus = "Funding";
    numBackers = 0;
    amountRaised = 0;
    ended = false;
  }

  function fund() payable returns (bool success) {
    Backer b = backers[numBackers++];
    b.addr = msg.sender;
    b.amount = msg.value;
    amountRaised += b.amount;
    Deposit(msg.sender, msg.value);

    return true;
  }

  function checkGoalReached() onlyOwner returns (bool hasEnded) {
    
    require(!ended);
    require(block.timestamp > deadline);    

    if (amountRaised >= goal) {
      campaignStatus = "Campaign Succeeded";
      assert(owner.send(this.balance));
    } else {
      campaignStatus = "Campaign Failed";
      for (uint i = 0; i <= numBackers; ++i) {
        assert(backers[i].addr.send(backers[i].amount));
        Refund(backers[i].addr, backers[i].amount);
        backers[i].amount = 0;
      }
    }
    ended = true;
    return ended;
  }

  function destroy() {
    if (msg.sender == owner)
      suicide(owner);
  }
}
