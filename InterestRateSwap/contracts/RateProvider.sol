pragma solidity ^0.4.15;

contract RateProvider {
  mapping(bytes32 => uint) public rates;
  mapping(bytes32 => uint) public timestamps;

  function RateProvider() {
    rates['XIBOR'] = 50;
    rates['VIBOR'] = 80;

    timestamps['XIBOR'] = block.timestamp;
    timestamps['YIBOR'] = block.timestamp; 
  }

  function getPrice(string symbol) constant returns (uint) {
    return rates[stringToBytes(symbol)];
  }

  function getTimestamp(string symbol) constant returns (uint) {
    return timestamps[stringToBytes(symbol)];
  }

  function updateRate(string _symbol, uint _rate) {
    bytes32 symbol = stringToBytes(_symbol);

    rates[symbol] = _rate;
    timestamps[symbol] = block.timestamp;
  }

  function stringToBytes(string s) returns (bytes32) {
    bytes memory b = bytes(s);
    uint r = 0;
    for (uint i = 0; i < 32; ++i) {
      r = (i < b.length) ? r | uint(b[i]) : r;
      r = (i < 31) ? r * 256 : r;
    }
    return bytes32(r);
  }
}