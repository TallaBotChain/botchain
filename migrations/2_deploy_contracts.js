// const BotChain = artifacts.require("./BotChain.sol");
const BotCoin = artifacts.require("./BotCoin.sol");
// const DeveloperRecord = artifacts.require("./DeveloperRecord.sol");

module.exports = function(deployer) {
  // deployer.deploy(BotChain);
  deployer.deploy(BotCoin);
  // deployer.deploy(DeveloperRecord);
};
