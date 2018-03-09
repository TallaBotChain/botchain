/* global describe it beforeEach artifacts contract */

import _ from 'lodash'
import { expect } from 'chai'
import { web3 } from './helpers/w3'
import botCoinTransferApproveSetup from './helpers/botCoinTransferApproveSetup'

const { accounts } = web3.eth
const zeroAddr = '0x0000000000000000000000000000000000000000'
const botAddr1 = '0x63e230f3b57ec9d180b9403c0d8783ddc135f664'
const tallaWalletAddress = '0x1ae554eea0dcfdd72dcc3fa4034761cf6d041bf3'
const dataHash = web3.sha3('some data to hash')
const url = 'www.google.com'
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

  describe('createBotInstance()', () => {
    beforeEach(async () => {
      await ownerRegistry.setMockOwner(1, accounts[1])
    })

    describe('when params are valid', async () => {
      it('should succeed', async () => {
        await botInstanceRegistry.createBotInstance(1, botAddr1, dataHash, url, { from: accounts[1] })
      })
    })

    describe('when url is empty', async () => {
      it('should succeed', async () => {
        await botInstanceRegistry.createBotInstance(1, botAddr1, dataHash, zeroAddr, { from: accounts[1] })
      })
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
