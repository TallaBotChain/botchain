const DeveloperRecord = artifacts.require("./DeveloperRecord.sol");

module.exports = function(deployer) {
  deployer.deploy(DeveloperRecord);
};
