loadScript("test.js");

var myContract = web3.eth.contract(JSON.parse(compiledContract.contracts["RevenueShare.sol:RevenueShare"].abi))

var addresses = [
  "0xfa943a8e67599f9cb392860cc38e788982dbaf25",
  "0xb9e557b4214fe99976e4714a3dac1249d038e757",
  "0x0df60e025cc6bd143d5626b5f8bb56373c55a0b7"]

var myContractInstance = myContract.new(
  addresses,
  {
    from: web3.eth.accounts[0],
    data: "0x" + compiledContract.contracts["RevenueShare.sol:RevenueShare"].bin,
    gas: 1000000
  }, 
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        console.log("Contract transaction send:\n\tTransactionHash: " +
          contract.transactionHash + " waiting to be mined...");
      } else {
        console.log("Contract mined! Address : " + contract.address);
      }
    } else {
      console.log(e)
    }
  }
);
