const Bot = artifacts.require("./Bot.sol");

module.exports = function(deployer) {
  deployer.deploy(Bot);
};
