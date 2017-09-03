loadScript('ProductSales.json')

var contract = compiledContract.contracts.ProductSales;

var productSalesContract = web3.eth.contract(JSON.parse(contract.abi));
var contractInstance = productSalesContract.new(
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
