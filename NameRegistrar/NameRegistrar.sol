pragma solidity ^0.4.14;

contract NameRegistrar {
  struct RegistryEntry {
    address owner;
    address addr;
    bytes32 content;
  }

  mapping (bytes32 => RegistryEntry) public records;
  uint public numRecords;

  event Registered(bytes32 name, address account);
  event Deregistered(bytes32 name, address account);

  function NameRegistrar() {
    numRecords = 0;
  }

  function register(bytes32 name) returns (bool success) {
    if (records[name].owner == 0) {
      RegistryEntry storage r = records[name];
      r.owner = msg.sender;
      numRecords++;
      Registered(name, msg.sender);
      success = true;
    } else { success = false; }
  }

  function unregister(bytes32 name) returns (bool success) {
    if (records[name].owner == msg.sender) {
      records[name].owner = 0;
      success = true;
      numRecords--;
      Deregistered(name, msg.sender);
    } else { success = false; }
  }

  function transferOwnership(bytes32 name, address newOwner) {
    require(records[name].owner == msg.sender);
    records[name].owner = newOwner;
  }

  function getOwner(bytes32 name) returns (address addr) {
    return records[name].owner;
  }

  function setAddr(bytes32 name, address addr) {
    require(records[name].owner == msg.sender);
    records[name].addr = addr;
  }

  function getAddr(bytes32 name) returns (address addr) {
    return records[name].addr;
  }

  function setContent(bytes32 name, bytes32 content) {
    require(records[name].owner == msg.sender);
    records[name].content = content;
  }

  function getContent(bytes32 name) returns (bytes32 content) {
    return records[name].content;
  }
}