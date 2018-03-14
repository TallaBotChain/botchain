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

const walletAddress = '0xdf08f82de32b8d460adbe8d72043e3a7e25a3b39'
const entryPrice =  1 * 10 ** 18
const devId = '0x6704fbfcd5ef766b287262fa2281c105d57246a6'
const botId = '0x9e1ef1ec212f5dffb41d35d9e5c14054f26c6560'
const dataHash = web3.sha3('some data to hash')
const url = web3.fromAscii('www.google.com')

module.exports = function (deployer) {
  let storage, tokenAddress, developerRegistryAddress, botProductRegistryAddress
  let botServiceRegistryAddress, botInstanceRegistryAddress

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
 	  developerRegistry.addDeveloper(dataHash, url)
  	return BotProductRegistryDelegate.new()
  }).then((botProductRegistryDelegate) => {
  	botProductRegistryAddress = botProductRegistryDelegate.address
  	return BotProductRegistryDelegate.at(botProductRegistryAddress)
  }).then((botProductRegistry) => {
 	  botProductRegistry.createBotProduct(devId, botProductRegistryAddress, dataHash, url)
  	return BotServiceRegistryDelegate.new()
  }).then((botServiceRegistryDelegate) => {
  	botServiceRegistryAddress = botServiceRegistryDelegate.address
  	return BotServiceRegistryDelegate.at(botServiceRegistryAddress)
  }).then((botServiceRegistry) => {
 	  botServiceRegistry.createBotService(devId, botServiceRegistryAddress, dataHash, url)
  	return BotInstanceRegistryDelegate.new()
  }).then((botInstanceRegistryDelegate) => {
  	botInstanceRegistryAddress = botInstanceRegistryDelegate.address
  	return BotInstanceRegistryDelegate.at(botInstanceRegistryAddress)
  }).then((botInstanceRegistry) => {
  	botInstanceRegistry.createBotInstance(botId, botInstanceRegistryAddress, dataHash, url)
  }).then(() => {
  	return DeveloperRegistry.new(
  		storage,
  		developerRegistryAddress, 
  		tokenAddress
  	), (err) => { console.error(err) }
  }).then(() => {
  	return BotEntryRegistry.new(
  		storage,
  		botProductRegistryAddress, 
  		tokenAddress
  	), (err) => { console.error(err) }
  }).then(() => {
  	return BotEntryRegistry.new(
  		storage,
  		botServiceRegistryAddress, 
  		tokenAddress
  	), (err) => { console.error(err) }
  }).then(() => {
  	return BotEntryRegistry.new(
  		storage,
  		botInstanceRegistryAddress, 
  		tokenAddress
  	), (err) => { console.error(err) }
  })
}