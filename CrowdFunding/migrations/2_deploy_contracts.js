var CrowdFunding = artifacts.require("./CrowdFunding.sol");

module.exports = function(deployer) {

  var now = new Date().getTime();
  deployer.deploy(CrowdFunding, (now/1000)+20, web3.toWei(1));
};
