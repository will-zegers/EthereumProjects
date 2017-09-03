pragma solidity ^0.4.14;

contract SmartSwitch {
  
  address public owner;
  mapping (address => uint) public usersPaid;
  uint public numUsers;

  event Deposit(address _from, uint _amount);
  event Refund(address _to, uint _amount);

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  function SmartSwitch() {
    owner = msg.sender;
    numUsers = 0;
  }

  function payToSwitch() payable {
    usersPaid[msg.sender] = msg.value;
    numUsers++;
    Deposit(msg.sender, msg.value);
  }

  function refundUser(address recipient, uint amount) onlyOwner {
    if (usersPaid[recipient] == amount) {
      if (this.balance >= amount) {
        assert(recipient.send(amount));
        Refund(recipient, amount);
        usersPaid[recipient] = 0;
        numUsers--;
      }
    }
  }

  function withdrawFunds() onlyOwner {
    assert(owner.send(this.balance));
  }

  function kill() onlyOwner {
    suicide(owner);
  }
}