/* globals artifacts */

import _ from 'lodash'

const PublicStorage = artifacts.require('./PublicStorage.sol')
const DeveloperRegistry = artifacts.require('./DeveloperRegistry.sol')
const DeveloperRegistryDelegate = artifacts.require('./DeveloperRegistryDelegate.sol')
const BotOwnershipManagerDelegate = artifacts.require('./BotOwnershipManagerDelegate.sol')

export default async function newDeveloperRegistry () {
  const publicStorage = await PublicStorage.new()
  const developerRegistryDelegate = await DeveloperRegistryDelegate.new()
  const botOwnershipManagerDelegate = await BotOwnershipManagerDelegate.new()
  let developerRegistry = await DeveloperRegistry.new(
    publicStorage.address,
    developerRegistryDelegate.address,
    botOwnershipManagerDelegate.address
  )
  developerRegistry = _.extend(
    developerRegistry,
    await DeveloperRegistryDelegate.at(developerRegistry.address)
  )
  return developerRegistry
}
