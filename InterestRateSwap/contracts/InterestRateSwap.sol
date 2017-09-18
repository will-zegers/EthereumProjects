pragma solidity ^0.4.15;

import "./TradingAccount.sol";
import "./Mortal.sol";
import "./Owned.sol";
import "./RateProvider.sol";

// contract Owned {
//   address public owner;

//   modifier onlyOwner() {
//     require(msg.sender == owner);
//     _;
//   } 
// }

// contract Mortal is Owned {
//   function kill() onlyOwner {
//     suicide(owner);
//   }
// }

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

// contract TradingAccount is Mortal {
//   struct AuthPeriod {
//     uint durationInMinutes;
//     uint startTime;
//   }

//   mapping(address => AuthPeriod) public authorized;
//   address[] public addresses;
//   address public owner;

//   function TradingAccount() {
//     owner = msg.sender;
//   }

//   function deposit() payable {
//     require(isOwner(msg.sender) || isAuthorized(msg.sender));
//   }

//   function withdraw(uint amount) {
//     require(amount <= this.balance);
//     require(isOwner(msg.sender) || isAuthorized(msg.sender));

//     assert(msg.sender.send(amount));
//   }

//   function authorize(address accountAddr, uint duration) {
//     require(duration > 0);

//     AuthPeriod storage period = authorized[accountAddr];
//     authorized[accountAddr] = AuthPeriod(duration, block.timestamp);
//     if (period.durationInMinutes == 0) {
//       authorized[accountAddr] = AuthPeriod(duration, block.timestamp);
//       addresses.push(accountAddr);
//     } else if (timeRemaining(accountAddr) < duration)
//       authorized[accountAddr] = AuthPeriod(duration, block.timestamp);
//   }

//   function isAuthorized(address accountAddr) returns (bool) {
//     return (authorized[accountAddr].durationInMinutes > 0 && timeRemaining(accountAddr) >= 0);
//   }

//   function isOwner(address accountAddr) returns (bool) {
//     return accountAddr == owner;
//   }

//   function timeRemaining(address accountAddr) private returns (uint) {
//     uint timeElapsed = (block.timestamp - authorized[accountAddr].startTime) / 60;
//     return authorized[accountAddr].durationInMinutes - timeElapsed;
//   }
// }

// contract RateProvider {
//   mapping(bytes32 => uint) public rates;
//   mapping(bytes32 => uint) public timestamps;

//   function RateProvider() {
//     rates['XIBOR'] = 50;
//     rates['VIBOR'] = 80;

//     timestamps['XIBOR'] = block.timestamp;
//     timestamps['YIBOR'] = block.timestamp; 
//   }

//   function getPrice(string symbol) constant returns (uint) {
//     return rates[stringToBytes(symbol)];
//   }

//   function getTimestamp(string symbol) constant returns (uint) {
//     return timestamps[stringToBytes(symbol)];
//   }

//   function updateRate(string _symbol, uint _rate) {
//     bytes32 symbol = stringToBytes(_symbol);

//     rates[symbol] = _rate;
//     timestamps[symbol] = block.timestamp;
//   }

//   function stringToBytes(string s) returns (bytes32) {
//     bytes memory b = bytes(s);
//     uint r = 0;
//     for (uint i = 0; i < 32; ++i) {
//       r = (i < b.length) ? r | uint(b[i]) : r;
//       r = (i < 31) ? r * 256 : r;
//     }
//     return bytes32(r);
//   }
// }