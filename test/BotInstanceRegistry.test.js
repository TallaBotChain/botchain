/* global describe it beforeEach artifacts contract */

import _ from 'lodash'
import { expect } from 'chai'
import { web3 } from './helpers/w3'
import botCoinTransferApproveSetup from './helpers/botCoinTransferApproveSetup'

const { accounts } = web3.eth
const tallaWalletAddress = '0x1ae554eea0dcfdd72dcc3fa4034761cf6d041bf3'
const entryPrice = 100
const initialBotCoinBalance = 100000000000

const PublicStorage = artifacts.require('./PublicStorage.sol')
const MockOwnerRegistry = artifacts.require('./MockOwnerRegistry.sol')
const BotInstanceRegistry = artifacts.require('./MockBotInstanceRegistry.sol')
const BotCoin = artifacts.require('BotCoin')

contract('BotInstanceRegistry', () => {
  let botInstanceRegistry, botCoin, ownerRegistry

  beforeEach(async () => {
    botCoin = await BotCoin.new()
    ownerRegistry = await MockOwnerRegistry.new()
    botInstanceRegistry = await newMockRegistry(
      BotInstanceRegistry,
      ownerRegistry.address,
      botCoin.address,
      tallaWalletAddress,
      entryPrice
    )
    const botCoinSeededAccounts = [
      accounts[1],
      accounts[2],
      accounts[7],
      accounts[8]
    ]
    for (var i = 0; i < botCoinSeededAccounts.length; i++) {
      await botCoinTransferApproveSetup(
        initialBotCoinBalance,
        botCoin,
        botInstanceRegistry.address,
        botCoinSeededAccounts[i],
        entryPrice
      )
    }
  })

  describe('name()', () => {
    it('should return BotInstanceRegistry', async () => {
      expect(await botInstanceRegistry.name()).to.equal('BotInstanceRegistry')
    })
  })
})

async function newMockRegistry (RegistryContract, ownerRegistryAddress, botCoinAddress, tallaWalletAddress, entryPrice) {
  const publicStorage = await PublicStorage.new()
  let registry = await RegistryContract.new(
    publicStorage.address,
    ownerRegistryAddress,
    botCoinAddress
  )

  registry = _.extend(
    registry,
    await RegistryContract.at(registry.address)
  )

  await registry.setTallaWallet(tallaWalletAddress)
  await registry.setEntryPrice(entryPrice)

  return registry
}
