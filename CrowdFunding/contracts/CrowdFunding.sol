pragma solidity ^0.4.15;

contract CrowdFunding {
  struct Backer {
    address addr;
    uint amount;
  }

  address public owner;
  uint public numBackers;
  uint public deadlineInSeconds;
  // string public campaignStatus;
  uint public statusCode;
  bool public isClosed;
  uint public goalInWei;
  uint public amountRaised;
  mapping(uint => Backer) backers;

  event Deposit(address _from, uint _amount);
  event Refund(address _to, uint _amount);

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  modifier acceptOnlyBeforeDeadline() {
    require(block.timestamp < deadlineInSeconds);
    _;
  }

  function CrowdFunding(uint _deadlineInSeconds, uint _goalInWei) {
    owner = msg.sender;
    deadlineInSeconds = _deadlineInSeconds;
    goalInWei = _goalInWei;
    // campaignStatus = "Funding";
    statusCode = 0;
    numBackers = 0;
    amountRaised = 0;
    isClosed = false;
  }

  function campaignStatus() returns (string status) {
    string[3] memory statusString = ["Funding", "Campaign Succeeded", "Campaign Failed"];
    return statusString[statusCode];
  }

  function fund() acceptOnlyBeforeDeadline payable {
    Backer storage b = backers[numBackers++];
    b.addr = msg.sender;
    b.amount = msg.value;
    amountRaised += b.amount;
    Deposit(msg.sender, msg.value);
  }

  function closeOutCampaign() onlyOwner {
    require(deadlineHasPassed());
    
    isClosed = true;
    if (goalReached())
      campaignSucceeded();
    else
      campaignFailed();
  }

  function goalReached() returns (bool isGoalReached) {
    return amountRaised >= goalInWei;
  }

  function deadlineHasPassed() returns (bool hasDeadlinePassed) {
    return !isClosed && (block.timestamp) >= deadlineInSeconds;
  }

  function campaignSucceeded() {
    // campaignStatus = "Campaign Succeeded";
    statusCode = 1;
    assert(owner.send(this.balance));
  }

  function campaignFailed() {
    // campaignStatus = "Campaign Failed";
    statusCode = 2;

    for (uint i = 0; i < numBackers; ++i) {
      refundBacker(i);
      Refund(backers[i].addr, backers[i].amount);
    }
  }

  function refundBacker(uint i) {
    uint amountToRefund = backers[i].amount;
    backers[i].amount = 0;
    assert(backers[i].addr.send(amountToRefund));
  }

  function destroy() onlyOwner {
    suicide(owner);
  }

  function() {
    revert();
  }
}