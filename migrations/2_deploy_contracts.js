/* const DeveloperRegistry = artifacts.require('./DeveloperRegistry.sol')
const BotCoin = artifacts.require('./BotCoin.sol')
const TokenSubscription = artifacts.require('./TokenSubscription.sol') */

module.exports = function (deployer) {

  /*
  The script needs to first deploy the following contracts:

    * An instance of PublicStorage
    * An instance of BotCoin
    * The four contracts in Delegate dir:
      - DeveloperRegistryDelegate
      - BotProductRegistryDelegate
      - BotServiceRegistryDelegate
      - BotInstanceRegistryDelegate
    * Four registry instance contracts. Each instantiated with PublicStorage, delegate, and BotCoin addresses
      - A DeveloperRegistry instance, with proxy implementation set to DeveloperRegistryDelegate address
      - A BotEntryRegistry instance, with proxy implementation set to BotProductRegistryDelegate address
      - A BotEntryRegistry instance, with proxy implementation set to BotServiceRegistryDelegate address
      - A BotEntryRegistry instance, with proxy implementation set to BotInstanceRegistryDelegate address

  After deployment, script needs to set talla wallet and entry price for each registry. This can be done by executing transactions to each registry instance contract.
  */

  /* deployer.deploy(DeveloperRegistry).then(() => {
    return deployer.deploy(BotCoin)
  }).then(() => {
    return deployer.deploy(TokenSubscription)
  }, (err) => {
    console.error(err)
  }) */
}