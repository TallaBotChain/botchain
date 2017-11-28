const BotCoin = artifacts.require("./BotCoin.sol");

module.exports = function(deployer) {
  deployer.deploy(BotCoin);
};
