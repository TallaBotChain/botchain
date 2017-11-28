const BotChain = artifacts.require("./BotChain.sol");

module.exports = function(deployer) {
  deployer.deploy(BotChain);
};
