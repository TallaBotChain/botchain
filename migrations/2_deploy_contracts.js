/* global artifacts */

const PublicStorage = artifacts.require('./PublicStorage.sol')
const BotCoin = artifacts.require('./BotCoin.sol')
const DeveloperRegistryDelegate = artifacts.require('./DeveloperRegistryDelegate.sol')
const BotProductRegistryDelegate = artifacts.require('./BotProductRegistryDelegate.sol')
const BotServiceRegistryDelegate = artifacts.require('./BotServiceRegistryDelegate.sol')
const BotInstanceRegistryDelegate = artifacts.require('./BotInstanceRegistryDelegate.sol')
const TokenVaultDelegate = artifacts.require('./TokenVaultDelegate.sol')

const BotEntryRegistry = artifacts.require('./BotEntryRegistry.sol')
const DeveloperRegistry = artifacts.require('./DeveloperRegistry.sol')
const TokenVaultProxy = artifacts.require('./TokenVaultProxy.sol')

const tallaWalletAddress = '0xc3f61fca6bd491424bc19e844c6847c9c9ab3d2c'
const entryPrice = 1 * 10 ** 18

const fs = require('fs')
const contractsOutputFile = 'build/contracts.json'
let jsonOutput = {}

module.exports = function (deployer) {
  let storage, botCoin
  let developerRegistry, botProductRegistry, botServiceRegistry, botInstanceRegistry

  deployer.then(() => {
    return PublicStorage.new()
  }).then((_storage) => {
    storage = _storage
    addToJSON("PublicStorage", storage.address)
    return BotCoin.new()
  }).then((_botCoin) => {
    botCoin = _botCoin
    addToJSON("BotCoin", botCoin.address)
    return deployDeveloperRegistry(
      storage.address,
      botCoin.address
    )
  }).then((_developerRegistry) => {
    developerRegistry = _developerRegistry
    return deployRegistry(
      'Bot Product',
      'BotProductRegistry',
      developerRegistry.address,
      storage.address,
      botCoin.address,
      BotEntryRegistry,
      BotProductRegistryDelegate
    )
  }).then((_botProductRegistry) => {
    botProductRegistry = _botProductRegistry
    return deployRegistry(
      'Bot Service',
      'BotServiceRegistry',
      developerRegistry.address,
      storage.address,
      botCoin.address,
      BotEntryRegistry,
      BotServiceRegistryDelegate
    )
  }).then((_botServiceRegistry) => {
    botServiceRegistry = _botServiceRegistry
    return deployRegistry(
      'Bot Instance',
      'BotInstanceRegistry',
      botProductRegistry.address,
      storage.address,
      botCoin.address,
      BotEntryRegistry,
      BotInstanceRegistryDelegate
    )
  }).then((_botInstanceRegistry) => {
    botInstanceRegistry = _botInstanceRegistry
    return configureRegistry('developer', developerRegistry, tallaWalletAddress, entryPrice)
  }).then(() => {
    return deployTokenVault(storage.address, storage.address)
  }).then(() => {
    return configureRegistry('bot product', botProductRegistry, tallaWalletAddress, entryPrice)
  }).then(() => {
    return configureRegistry('bot service', botServiceRegistry, tallaWalletAddress, entryPrice)
  }).then(() => {
    return configureRegistry('bot instance', botInstanceRegistry, tallaWalletAddress, entryPrice)
  })
  .catch((err) => {
    console.error(err)
  })
}

function deployTokenVault (
  storageAddress,
  arbiterAddress
) {
  console.log(`deploying contracts for token vault`)
  console.dir(TokenVaultDelegate)
  return TokenVaultDelegate.new(storageAddress,arbiterAddress).then((tokenVaultDelegate) => {
    console.log(`deployed token vault delegate: ${tokenVaultDelegate.address}`)
    addToJSON("TokenVaultDelegate", tokenVaultDelegate.address)
    return TokenVaultProxy.new(
      storageAddress,
      tokenVaultDelegate.address,
      botCoinAddress
    )
  }).then((tokenVaultProxy) => {
    console.log(`deployed token vault proxy instance: ${tokenVaultProxy.address}`)
    addToJSON("TokenVaultProxy", tokenVaultProxy.address)
    return TokenVaultDelegate.at(tokenVaultProxy.address)
  })
}

function deployDeveloperRegistry (
  storageAddress,
  botCoinAddress
) {
  console.log('')
  console.log(`deploying contracts for developer registry`)
  return DeveloperRegistryDelegate.new(storageAddress).then((developerRegistryDelegate) => {
    console.log(`deployed developer registry delegate: ${developerRegistryDelegate.address}`)
    addToJSON("DeveloperRegistryDelegate", developerRegistryDelegate.address)
    return DeveloperRegistry.new(
      storageAddress,
      developerRegistryDelegate.address,
      botCoinAddress
    )
  }).then((developerRegistry) => {
    console.log(`deployed developer registry instance: ${developerRegistry.address}`)
    addToJSON("DeveloperRegistry", developerRegistry.address)
    return DeveloperRegistryDelegate.at(developerRegistry.address)
  })
}

function deployRegistry (
  name,
  displayName,
  ownerRegistryAddress,
  storageAddress,
  botCoinAddress,
  registryArtifact,
  delegateArtifact
) {
  console.log('')
  console.log(`deploying contracts for ${name} `)
  return delegateArtifact.new(storageAddress).then((registryDelegate) => {
    console.log(`deployed ${name} registry delegate: ${registryDelegate.address}`)
    delegateName = displayName + "Delegate"
    addToJSON(delegateName, registryDelegate.address)
    return registryArtifact.new(
      ownerRegistryAddress,
      storageAddress,
      registryDelegate.address,
      botCoinAddress
    )
  }).then((registry) => {
    console.log(`deployed ${name} registry instance: ${registry.address}`)
    addToJSON(displayName, registry.address)
    return delegateArtifact.at(registry.address)
  })
  
}

function configureRegistry (name, registry, walletAddress, price) {
  console.log('')
  console.log(`configuring ${name} registry`)
  return registry.setTallaWallet(walletAddress).then(() => {
    console.log(` ${name}: tallaWalletAddress = ${walletAddress}`)
    return registry.setEntryPrice(price).then(() => {
      console.log(` ${name}: entryPrice = ${price}`)
    })
  })
}

function addToJSON (displayName, address) {
  console.log(`Adding ${displayName} to JSON with address ${address}`)
  jsonOutput[displayName] = address
  fs.writeFile(contractsOutputFile, JSON.stringify(jsonOutput, null, 2), function (err) {
    if (err) {
      return console.log(err)
    }
  })
}
