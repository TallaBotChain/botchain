/* globals artifacts */

import _ from 'lodash'

const PublicStorage = artifacts.require('./PublicStorage.sol')
const DeveloperRegistry = artifacts.require('./DeveloperRegistry.sol')
const DeveloperRegistryDelegate = artifacts.require('./DeveloperRegistryDelegate.sol')
const BotProductRegistryDelegate = artifacts.require('./BotProductRegistryDelegate.sol')

export default async function newDeveloperRegistry () {
  const publicStorage = await PublicStorage.new()
  const developerRegistryDelegate = await DeveloperRegistryDelegate.new()
  const botProductRegistryDelegate = await BotProductRegistryDelegate.new()
  let developerRegistry = await DeveloperRegistry.new(
    publicStorage.address,
    developerRegistryDelegate.address,
    botProductRegistryDelegate.address
  )
  developerRegistry = _.extend(
    developerRegistry,
    await DeveloperRegistryDelegate.at(developerRegistry.address)
  )
  return developerRegistry
}
