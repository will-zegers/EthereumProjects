pragma solidity ^0.4.15;

contract EventRegistration {

  struct Registrant {
    uint amount;
    uint numTickets;
    string email;
  }

  address public owner;
  uint public numTicketsSold;
  uint public quota;
  uint public pricePerTicket;
  uint public numRegistrants;
  mapping (address => Registrant) registrants;

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

  function EventRegistration(uint _quota, uint _pricePerTicket) {
    owner = msg.sender;
    quota = _quota;
    pricePerTicket = _pricePerTicket;
    numTicketsSold = 0;
  }

  function buyTickets(string email, uint numTickets) soldOut payable {
    uint totalAmount = pricePerTicket * numTickets;
    require(msg.value >= totalAmount);

    if (registrants[msg.sender].amount > 0) {
      registrants[msg.sender].amount += totalAmount;
      registrants[msg.sender].email = email;
      registrants[msg.sender].numTickets += numTickets;
    } else {
      Registrant storage r = registrants[msg.sender];
      r.amount = totalAmount;
      r.email = email;
      r.numTickets = numTickets;

      numRegistrants++;
    }

    numTicketsSold += numTickets;

    if (msg.value > totalAmount) {
      uint refundAmount = msg.value - totalAmount;
      assert(msg.sender.send(refundAmount));
    }

    Deposit(msg.sender, msg.value);
  }

  function refundTickets(address buyer) onlyOwner {
    if (registrants[buyer].amount > 0) {
      if (this.balance >= registrants[buyer].amount) {
        uint amountToRefund = registrants[buyer].amount;
        registrants[buyer].amount = 0;
        numTicketsSold -= registrants[buyer].numTickets;

        assert(buyer.send(amountToRefund));

        numRegistrants--;
        Refund(buyer, amountToRefund);
      }
    }
  }

  function withdrawFund() onlyOwner {
    assert(owner.send(this.balance));
  }

  function getRegistrantAmountPaid(address buyer) returns (uint) {
    return (registrants[buyer].amount > 0) ? registrants[buyer].amount : 0;
  }

  function kill() onlyOwner {
    suicide(owner);
  }
}