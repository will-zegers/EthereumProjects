var ConvertLib = artifacts.require("./ConvertLib.sol");
var MetaCoin = artifacts.require("./MetaCoin.sol");
var RevenueShare = artifacts.require("./RevenueShare.sol");

module.exports = function(deployer) {
  deployer.deploy(RevenueShare, ["0x16c96e25684a6065f730514459807cc725b6288a", "0x3e22f8dd3a7ea312d5470b840e4d477944fed039"]);
};
