loadScript('CrowdFunding.json')

var timeframe_in_milli = 1 * 1000
var deadline = Date.now() + timeframe_in_milli;
var goal = 5000000000000000

var contract = compiledContract.contracts.CrowdFunding;

var crowdFundingContract = web3.eth.contract(JSON.parse(contract.abi));
var contractInstance = crowdFundingContract.new(
  deadline,
  goal,
  {
    from: web3.eth.accounts[1],
    data: "0x" + contract.bin,
    gas: 1000000
  }, function(e, contract) {
    if (!e) {
      if(!contract.address) {
        console.log("Contraction transaction send:\n\tTransaction: " +
          contract.transactionHash + " waiting to be mined...");
      } else {
        console.log("Contarct mined!\n\tAddress: " + contract.address);
      }
    } else {
      console.log(e);
    }
  });

console.log(Object.keys(contractInstance.abi));
//var ev = contractInstance.Deposit().watch({}, '', function(error, result) {
//  if(!error) {
//    console.log(JSON.stringify(result));
//  }
//});
