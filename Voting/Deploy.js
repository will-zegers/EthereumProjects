var parameters = [];

// ****************************************
var projectName = "Voting";
parameters.proposalNames = ["Alpha", "Beta", "Gamma", "Delta"];
parameters.votingTime = 300;
// ****************************************

loadScript(projectName+'.json');

var contractsArray = compiledContract.contracts;
var contractJSON = contractsArray[Object.keys(contractsArray)[0]];
var contract = web3.eth.contract(JSON.parse(contractJSON.abi));

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

var contractInstance = contract.new(
  parameters.proposalNames,
  parameters.votingTime,
  parameters.tx,
  parameters.callback);
