var parameters = [];

// ****************************************
var projectName = "EventRegistration";
parameters.quota = 1000;
parameters.price = web3.toWei(10, 'ether');
// ****************************************

parameters.tx = 
  {
    from: eth.accounts[0],
    data: "0x" + contractJSON.bin,
    gas: 1000000
  };

parameters.callback = 
  function(err, contract) {
    if(!err) {
      if(!contract.address) {
        console.log("Contract transaction send:\n\tTransaction Hash:", 
          contract.transactionHash, "waiting to be mined...");
      } else {
        console.log("Contract mined! Address:", contract.address)
      }
    } else {
      console.log(err);
    }
  };

loadScript(projectName+'.json');

var contractsArray = compiledContract.contracts;
var contractJSON = contractsArray[Object.keys(contractsArray)[0]];
var contract = web3.eth.contract(JSON.parse(contractJSON.abi));

var contractInstance = contract.new(
  parameters.quota,
  parameters.price,
  parameters.tx,
  parameters.callback);