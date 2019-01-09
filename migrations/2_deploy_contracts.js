/* global artifacts */

const PublicStorage = artifacts.require('./PublicStorage.sol')
const BotCoin = artifacts.require('./BotCoin.sol')
const DeveloperRegistryDelegate = artifacts.require('./DeveloperRegistryDelegate.sol')
const BotProductRegistryDelegate = artifacts.require('./BotProductRegistryDelegate.sol')
const BotServiceRegistryDelegate = artifacts.require('./BotServiceRegistryDelegate.sol')
const BotInstanceRegistryDelegate = artifacts.require('./BotInstanceRegistryDelegate.sol')
const TokenVaultDelegate = artifacts.require('./TokenVaultDelegate.sol')
const CurationCouncilRegistryDelegate = artifacts.require('./CurationCouncilRegistryDelegate.sol')

const BotEntryRegistry = artifacts.require('./BotEntryRegistry.sol')
const DeveloperRegistry = artifacts.require('./DeveloperRegistry.sol')
const TokenVaultProxy = artifacts.require('./TokenVaultProxy.sol')
const CurationCouncil = artifacts.require('./CurationCouncil.sol')

const tallaWalletAddress = '0xc3f61fca6bd491424bc19e844c6847c9c9ab3d2c'
const entryPrice = 1 * 10 ** 18
const mainnetBotCoinAddress = '0xe3118A166103F109643497DA22fA656cdE28ac73'

const fs = require('fs')
const contractsOutputFile = 'build/contracts.json'
let jsonOutput = {}

module.exports = function (deployer, network) {
  if (network == 'mainnet_infura') {
    let storage
    let developerRegistry, botProductRegistry, botServiceRegistry, botInstanceRegistry

    deployer.then(() => {
      return PublicStorage.new()
    }).then((_storage) => {
      storage = _storage
      addToJSON("PublicStorage", storage.address)
      _curationCouncil = deployCurationCouncil(storage.address, mainnetBotCoinAddress)
      _tokenVault = deployTokenVault(storage.address, _curationCouncil.address, mainnetBotCoinAddress)
      return deployDeveloperRegistry(
        storage.address,
        mainnetBotCoinAddress
      )
    }).then((_developerRegistry) => {
      developerRegistry = _developerRegistry
      return deployRegistry(
        'Bot Product',
        'BotProductRegistry',
        developerRegistry.address,
        storage.address,
        mainnetBotCoinAddress,
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
        mainnetBotCoinAddress,
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
        mainnetBotCoinAddress,
        BotEntryRegistry,
        BotInstanceRegistryDelegate
      )
    }).then((_botInstanceRegistry) => {
      botInstanceRegistry = _botInstanceRegistry
      return configureRegistry('developer', developerRegistry, tallaWalletAddress, entryPrice)
    }).then(() => {
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
  } else {
    let storage, botcoin
    let developerRegistry, botProductRegistry, botServiceRegistry, botInstanceRegistry

    deployer.then(() => {
      return PublicStorage.new()
    }).then((_storage) => {
      storage = _storage
      addToJSON("PublicStorage", storage.address)
      return BotCoin.new()
    }).then((_botcoin) => {
      botcoin = _botcoin
      addToJSON("BotCoin", botcoin.address)
      _curationCouncil = deployCurationCouncil(storage.address, botcoin.address)
      _tokenVault = deployTokenVault(storage.address, _curationCouncil.address, botcoin.address)
      return deployDeveloperRegistry(
        storage.address,
        botcoin.address
      )
    }).then((_developerRegistry) => {
      developerRegistry = _developerRegistry
      return deployRegistry(
        'Bot Product',
        'BotProductRegistry',
        developerRegistry.address,
        storage.address,
        botcoin.address,
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
        botcoin.address,
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
        botcoin.address,
        BotEntryRegistry,
        BotInstanceRegistryDelegate
      )
    }).then((_botInstanceRegistry) => {
      botInstanceRegistry = _botInstanceRegistry
      return configureRegistry('developer', developerRegistry, tallaWalletAddress, entryPrice)
    }).then(() => {
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
  
}

function deployTokenVault (
  storageAddress,
  arbiterAddress,
  botcoinAddress
) {
  console.log(`deploying contracts for token vault`)
  return TokenVaultDelegate.new(storageAddress,arbiterAddress).then((tokenVaultDelegate) => {
    console.log(`deployed token vault delegate: ${tokenVaultDelegate.address}`)
    addToJSON("TokenVaultDelegate", tokenVaultDelegate.address)
    return TokenVaultProxy.new(
      storageAddress,
      tokenVaultDelegate.address,
      botcoinAddress
    )
  })
  .then((tokenVaultProxy) => {
    console.log(`deployed token vault proxy instance: ${tokenVaultProxy.address}`)
    addToJSON("TokenVaultProxy", tokenVaultProxy.address)
    return TokenVaultDelegate.at(tokenVaultProxy.address)
  })
}

function deployCurationCouncil (
  storageAddress,
  botcoinAddress
) {
  console.log(`deploying contracts for curation council`)
  return CurationCouncilRegistryDelegate.new(storageAddress).then((curationCouncilRegistryDelegate) => {
    console.log(`deployed curation council registry delegate: ${curationCouncilRegistryDelegate.address}`)
    addToJSON("CurationCouncilRegistryDelegate", curationCouncilRegistryDelegate.address)
    return CurationCouncil.new(
      storageAddress,
      curationCouncilRegistryDelegate.address,
      botcoinAddress
    )
  })
  .then((curationCouncil) => {
    console.log(`deployed curation council proxy instance: ${curationCouncil.address}`)
    addToJSON("CurationCouncil", curationCouncil.address)
    return CurationCouncilRegistryDelegate.at(curationCouncil.address)
  })
}

function deployDeveloperRegistry (
  storageAddress,
  botcoinAddress
) {
  console.log('')
  console.log(`deploying contracts for developer registry`)
  return DeveloperRegistryDelegate.new(storageAddress).then((developerRegistryDelegate) => {
    console.log(`deployed developer registry delegate: ${developerRegistryDelegate.address}`)
    addToJSON("DeveloperRegistryDelegate", developerRegistryDelegate.address)
    return DeveloperRegistry.new(
      storageAddress,
      developerRegistryDelegate.address,
      botcoinAddress
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
  botcoinAddress,
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
      botcoinAddress
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
