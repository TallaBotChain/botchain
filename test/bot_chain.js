const BotChain = artifacts.require("./BotChain.sol");

contract('BotChain', function(accounts) {

  it("should give BotChain an owner", async function () {
    let botChain = await BotChain.deployed();
    let owner = await botChain.owners.call(0);
    assert.notEqual(owner, 0, "does not have an owner");
    assert.equal(owner, accounts[0], "the creator is not the owner");
  });


});
