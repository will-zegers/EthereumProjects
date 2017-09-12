var EventRegistration = artifacts.require("./EventRegistration.sol");

module.exports = function(deployer) {
  deployer.deploy(EventRegistration, 100, web3.toWei(1.25, "ether"));
};
