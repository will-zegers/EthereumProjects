pragma solidity ^0.4.15;

import "./TradingAccount.sol";
import "./Mortal.sol";
import "./Owned.sol";
import "./RateProvider.sol";

contract InterestRateSwap is Owned, Mortal {
  bool public isActive;
  
  address public partyA;
  address public partyB;

  uint public fixedRate;
  uint public floatingRateMargin;
  uint public notional;
  uint public schedule;
  uint public timeToExpiry;
  uint public startTime;
  uint public lastAmountPaid;

  string public feedName;

  RateProvider public rateFeed;

  TradingAccount public partyATradingAcct;
  TradingAccount public partyBTradingAcct;

  function InterestRateSwap() {
    isActive = false;
  }

  function initialize(
    address _partyATradingAcct,
    address _partyBTradingAcct,
    uint _fixedRate,
    uint _floatingRateMargin,
    uint _notional,
    uint _schedule,
    string _feedName,
    address _rateProvider,
    uint _timeToExpiry) {

    partyATradingAcct = TradingAccount(_partyATradingAcct);
    partyA = partyATradingAcct.owner();
    partyBTradingAcct = TradingAccount(_partyBTradingAcct);
    partyB = partyBTradingAcct.owner();

    fixedRate = _fixedRate;
    floatingRateMargin = _floatingRateMargin;
    notional = _notional;
    schedule = _schedule;
    feedName = _feedName;
    rateFeed = RateProvider(_rateProvider);

    timeToExpiry = _timeToExpiry;
    startTime = now;
    lastAmountPaid = 0;

    authorizeTradingAccounts();
  }

  function validate() {
    require(!isActive);
    require(!isExpired());
    require(partyATradingAcct.isAuthorized(this) && partyBTradingAcct.isAuthorized(this));

    authorizeTradingAccounts();

    isActive = true;
  }

  function excercise() {
    require(isActive);
    require(!isExpired());

    uint currentRate = getRate();
    uint floatingRate = currentRate + floatingRateMargin;

    uint amountAOwesToB = (notional * floatingRate)/100;
    uint amountBOwesToA = (notional * fixedRate)/100;

    if (amountAOwesToB > amountBOwesToA) {
      lastAmountPaid = amountAOwesToB - amountBOwesToA;
      partyBTradingAcct.deposit.value(lastAmountPaid)();
      partyATradingAcct.withdraw(lastAmountPaid);
    } else {
      lastAmountPaid = amountBOwesToA - amountAOwesToB;
      partyATradingAcct.deposit.value(lastAmountPaid)();
      partyBTradingAcct.withdraw(lastAmountPaid);
    }
  }

  function authorizeTradingAccounts() {
    if (msg.sender == partyA)
      partyATradingAcct.authorize(this, timeToExpiry);
    else if (msg.sender == partyB)
      partyBTradingAcct.authorize(this, timeToExpiry);
  }

  function isExpired() constant returns (bool) {
    return now > startTime + timeToExpiry;
  }

  function getRate() returns (uint) {
    return rateFeed.getPrice(feedName);
  }
}