pragma solidity ^0.4.14;

contract EventRegistration {
  struct Registrant {
    uint amount;
    uint numTickets;
    string email;
  }

  address public owner;
  uint public numTicketsSold;
  uint public quota;
  uint public price;
  mapping (address => Registrant) registrantsPaid;

  event Deposit(address _from, uint _amount);
  event Refund(address _to, uint _amount);

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  modifier soldOut() {
    require(numTicketsSold < quota);
    _;
  }

  function EventRegistration(uint _quota, uint _price) {
    owner = msg.sender;
    numTicketsSold = 0;
    quota = _quota;
    price = _price;
  }

  function buyTicket(string email, uint numTickets) payable soldOut {
    uint totalAmount = price * numTickets;
    require(msg.value >= totalAmount);

    if (registrantsPaid[msg.sender].amount > 0) {
      registrantsPaid[msg.sender].amount += totalAmount;
      registrantsPaid[msg.sender].email = email;
      registrantsPaid[msg.sender].numTickets += numTickets;
    } else {
      Registrant storage r = registrantsPaid[msg.sender];
      r.amount = totalAmount;
      r.email = email;
      r.numTickets = numTickets;
    }

    numTicketsSold = numTicketsSold + numTickets;

    if (msg.value > totalAmount) {
      uint refundAmount = msg.value - totalAmount;
      assert(msg.sender.send(refundAmount));
    }

    Deposit(msg.sender, msg.value);
  }

  function refundTickets(address buyer) onlyOwner {
    if (registrantsPaid[buyer].amount > 0) {
      if (this.balance >= registrantsPaid[buyer].amount) {
        assert(buyer.send(registrantsPaid[buyer].amount));

        registrantsPaid[buyer].amount = 0;
        numTicketsSold = numTicketsSold - registrantsPaid[buyer].numTickets;
        
        Refund(buyer, registrantsPaid[buyer].amount);
      }
    }
  }

  function withdrawFunds() onlyOwner {
    assert(owner.send(this.balance));
  }

  function getRegistrantAmountPaid(address buyer) returns(uint) {
    return registrantsPaid[buyer].amount;
  }

  function kill() onlyOwner {
    suicide(owner);
  }
}