/* global describe it beforeEach artifacts contract */

import _ from 'lodash'
import { expect } from 'chai'
import { web3 } from './helpers/w3'
import botCoinTransferApproveSetup from './helpers/botCoinTransferApproveSetup'

const { accounts } = web3.eth
const botAddr1 = '0x63e230f3b57ec9d180b9403c0d8783ddc135f664'
const tallaWalletAddress = '0x1ae554eea0dcfdd72dcc3fa4034761cf6d041bf3'
const entryPrice = 100
const dataHash = web3.sha3('some data to hash')
const url = 'www.google.com'
const initialBotCoinBalance = 100000000000

const PublicStorage = artifacts.require('./PublicStorage.sol')
const MockOwnerRegistry = artifacts.require('./MockOwnerRegistry.sol')
const MockOwnedRegistry = artifacts.require('./MockOwnedRegistry.sol')
const BotProductRegistry = artifacts.require('./MockBotProductRegistry.sol')
const BotCoin = artifacts.require('BotCoin')

contract('BotProductRegistry', () => {
  let botProductRegistry, mockInstanceRegistry, botCoin, ownerRegistry

  beforeEach(async () => {
    botCoin = await BotCoin.new()
    ownerRegistry = await MockOwnerRegistry.new()
    botProductRegistry = await newMockRegistry(
      BotProductRegistry,
      ownerRegistry.address,
      botCoin.address,
      tallaWalletAddress,
      entryPrice
    )
    mockInstanceRegistry = await MockOwnedRegistry.new(botProductRegistry.address)
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
        botProductRegistry.address,
        botCoinSeededAccounts[i],
        entryPrice
      )
    }
  })

  describe('name()', () => {
    it('should return BotProductRegistry', async () => {
      expect(await botProductRegistry.name()).to.equal('BotProductRegistry')
    })
  })

  describe('mintingAllowed()', () => {
    describe('when conditions are valid', () => {
      it('should return true', async () => {
        await ownerRegistry.setMockOwner(1, accounts[1])
        await botProductRegistry.createBotEntry(1, botAddr1, dataHash, url, { from: accounts[1] })
        expect(
          await mockInstanceRegistry.mintingAllowedOnOwner(accounts[1], 1)
        ).to.equal(true)
      })
    })

    describe('when minting is not allowed by owner registry', () => {
      it('should return false', async () => {
        await ownerRegistry.setMockOwner(1, accounts[1])
        await botProductRegistry.createBotEntry(1, botAddr1, dataHash, url, { from: accounts[1] })
        await ownerRegistry.disableMinting()
        expect(
          await mockInstanceRegistry.mintingAllowedOnOwner(accounts[1], 1)
        ).to.equal(false)
      })
    })

    describe('when sender is not the owner of the bot product', () => {
      it('should return false', async () => {
        await botProductRegistry.createBotEntry(1, botAddr1, dataHash, url, { from: accounts[1] })
        expect(
          await mockInstanceRegistry.mintingAllowedOnOwner(accounts[1], 1)
        ).to.equal(false)
      })
    })

    describe('when bot product is disabled', () => {
      it('should return false', async () => {
        await ownerRegistry.setMockOwner(1, accounts[1])
        await botProductRegistry.createBotEntry(1, botAddr1, dataHash, url, { from: accounts[1] })
        await botProductRegistry.revokeApproval(1)
        expect(
          await mockInstanceRegistry.mintingAllowedOnOwner(accounts[1], 1)
        ).to.equal(false)
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
