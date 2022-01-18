const Migrations = artifacts.require("Migrations");
const BtcMiner = artifacts.require("BtcMiner");

module.exports = function (deployer) {
  deployer.deploy(Migrations);
  deployer.deploy(BtcMiner);
};
