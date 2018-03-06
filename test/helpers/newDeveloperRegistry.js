/* globals artifacts */

import _ from 'lodash'

const PublicStorage = artifacts.require('./PublicStorage.sol')
const DeveloperRegistry = artifacts.require('./DeveloperRegistry.sol')
const DeveloperRegistryDelegate = artifacts.require('./DeveloperRegistryDelegate.sol')
const BotCoin = artifacts.require('./BotCoin.sol');

export default async function newDeveloperRegistry () {
  const publicStorage = await PublicStorage.new()
  const developerRegistryDelegate = await DeveloperRegistryDelegate.new()
  const botCoinAddress = await BotCoin.new()

  let developerRegistry = await DeveloperRegistry.new(
    publicStorage.address,
    developerRegistryDelegate.address, 
    botCoinAddress.address
  )
  developerRegistry = _.extend(
    developerRegistry,
    await DeveloperRegistryDelegate.at(developerRegistry.address)
  )
  return developerRegistry
}

