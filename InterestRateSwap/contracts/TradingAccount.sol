pragma solidity ^0.4.15;

import "./Mortal.sol";

contract TradingAccount is Mortal {
  struct AuthPeriod {
    uint durationInMinutes;
    uint startTime;
  }

  mapping(address => AuthPeriod) public authorized;
  address[] public addresses;
  address public owner;

  function TradingAccount() {
    owner = msg.sender;
  }

  function deposit() payable {
    require(isOwner(msg.sender) || isAuthorized(msg.sender));
  }

  function withdraw(uint amount) {
    require(amount <= this.balance);
    require(isOwner(msg.sender) || isAuthorized(msg.sender));

    assert(msg.sender.send(amount));
  }

  function authorize(address accountAddr, uint duration) {
    require(duration > 0);

    AuthPeriod storage period = authorized[accountAddr];
    authorized[accountAddr] = AuthPeriod(duration, block.timestamp);
    if (period.durationInMinutes == 0) {
      authorized[accountAddr] = AuthPeriod(duration, block.timestamp);
      addresses.push(accountAddr);
    } else if (timeRemaining(accountAddr) < duration)
      authorized[accountAddr] = AuthPeriod(duration, block.timestamp);
  }

  function isAuthorized(address accountAddr) returns (bool) {
    return (authorized[accountAddr].durationInMinutes > 0 && timeRemaining(accountAddr) >= 0);
  }

  function isOwner(address accountAddr) returns (bool) {
    return accountAddr == owner;
  }

  function timeRemaining(address accountAddr) private returns (uint) {
    uint timeElapsed = (block.timestamp - authorized[accountAddr].startTime) / 60;
    return authorized[accountAddr].durationInMinutes - timeElapsed;
  }
}