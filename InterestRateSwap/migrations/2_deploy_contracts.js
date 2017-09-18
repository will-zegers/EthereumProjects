var ConvertLib = artifacts.require("./ConvertLib.sol");
var MetaCoin = artifacts.require("./MetaCoin.sol");
var InterestRateSwap = artifacts.require("./InterestRateSwap.sol");

module.exports = function(deployer) {
  deployer.deploy(InterestRateSwap);
};
