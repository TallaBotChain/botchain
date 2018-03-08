/* globals artifacts */

import _ from 'lodash'
import newBotCoinPaymentRegistry from './newBotCoinPaymentRegistry'

const PublicStorage = artifacts.require('./PublicStorage.sol')
const DeveloperRegistry = artifacts.require('./DeveloperRegistry.sol')
const DeveloperRegistryDelegate = artifacts.require('./DeveloperRegistryDelegate.sol')
const botCoinPaymentReg = artifacts.require('./BotCoinPaymentRegistry.sol')

export default async function newDeveloperRegistry (botCoinAddress, tallaWalletAddress, entryPrice) {
  const publicStorage = await PublicStorage.new()
  const developerRegistryDelegate = await DeveloperRegistryDelegate.new()

  let developerRegistry = await DeveloperRegistry.new(
    publicStorage.address,
    developerRegistryDelegate.address,
    botCoinAddress
  )
  developerRegistry = _.extend(
    developerRegistry,
    await DeveloperRegistryDelegate.at(developerRegistry.address)
  )

  await developerRegistry.setTallaWallet(tallaWalletAddress)
  await developerRegistry.setEntryPrice(entryPrice)

  return developerRegistry
}

