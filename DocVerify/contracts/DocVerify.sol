pragma solidity ^0.4.15;

contract DocVerify {
  struct Document {
    address owner;
    uint blockTimeStamp;
  }

  address public creator;
  uint public numDocuments;
  mapping(bytes32 => Document) public documentHashMap;

  modifier onlyOwner {
    require(msg.sender == creator);
    _;
  }

  function DocVerify() {
    creator = msg.sender;
    numDocuments = 0;
  }

  function newDocument(bytes32 hash) returns (bool) {
    if (documentExists(hash))
      return false;
    else {
      Document storage d = documentHashMap[hash];
      d.owner = msg.sender;
      d.blockTimeStamp = block.timestamp;
      numDocuments++;
      return true;
    }
  }

  function documentExists(bytes32 hash) constant returns (bool) {
    return documentHashMap[hash].blockTimeStamp > 0;
  }

  function getDocument(bytes32 hash) constant returns (uint blockTimeStamp, address owner) {
    blockTimeStamp = documentHashMap[hash].blockTimeStamp;
    owner = documentHashMap[hash].owner;
  }

  function destroy() onlyOwner{
    suicide(creator);
  }
}