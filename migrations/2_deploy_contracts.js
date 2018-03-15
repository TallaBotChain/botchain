/* global artifacts */

/*
* If using parity, run with the --geth flag to run in geth compatible mode,
* otherwise truffle migrate will throw an error even if the contract deployment
* is successful
*
* this is a known issue with truffle:
* https://github.com/trufflesuite/truffle-migrate/issues/15
*
* parity --chain kovan --geth --force-ui
*
*/

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

After deployment, script needs to set talla wallet and entry price for each registry. 
This can be done by executing transactions to each registry instance contract.
*/

const PublicStorage = artifacts.require('./PublicStorage.sol')
const BotCoin = artifacts.require('./BotCoin.sol')
const DeveloperRegistryDelegate = artifacts.require('./DeveloperRegistryDelegate.sol')
const BotProductRegistryDelegate = artifacts.require('./BotProductRegistryDelegate.sol')
const BotServiceRegistryDelegate = artifacts.require('./BotServiceRegistryDelegate.sol')
const BotInstanceRegistryDelegate = artifacts.require('./BotInstanceRegistryDelegate.sol')

const BotEntryRegistry = artifacts.require('./BotEntryRegistry.sol')
const DeveloperRegistry = artifacts.require('./DeveloperRegistry.sol')

module.exports = function (deployer) {
  let storage, tokenAddress, developerRegistryDelegateAddress, botProductRegistryDelegateAddress
  let botServiceRegistryDelegateAddress, botInstanceRegistryDelegateAddress

	deployer.then(() => {
    return PublicStorage.new()
  }).then((_storage) => {
    storage = _storage
    return BotCoin.new()
  }).then((_token) => {
  	tokenAddress = _token.address
  	return DeveloperRegistryDelegate.new()
  }).then((developerRegistryDelegate) => {
  	return DeveloperRegistryDelegate.at(developerRegistryDelegate.address)
  }).then((developerRegistry) => {
  	developerRegistryDelegateAddress = developerRegistry.address
  	return BotProductRegistryDelegate.new()
  }).then((botProductRegistryDelegate) => {
  	botProductRegistryDelegateAddress = botProductRegistryDelegate.address
  	return BotProductRegistryDelegate.at(botProductRegistryDelegateAddress)
  }).then(() => {
  	return BotServiceRegistryDelegate.new()
  }).then((botServiceRegistryDelegate) => {
  	botServiceRegistryDelegateAddress = botServiceRegistryDelegate.address
  	return BotServiceRegistryDelegate.at(botServiceRegistryDelegateAddress)
  }).then(() => {
  	return BotInstanceRegistryDelegate.new()
  }).then((botInstanceRegistryDelegate) => {
  	botInstanceRegistryDelegateAddress = botInstanceRegistryDelegate.address
  	return BotInstanceRegistryDelegate.at(botInstanceRegistryDelegateAddress)
  }).catch((err) =>{
  	console.error(err)
  });
} 