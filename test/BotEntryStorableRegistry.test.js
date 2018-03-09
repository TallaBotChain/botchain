/* global describe it beforeEach artifacts contract */

import _ from 'lodash'
import { expect } from 'chai'
import { web3 } from './helpers/w3'
import expectRevert from './helpers/expectRevert'
import { hasEvent } from './helpers/event'
import newDeveloperRegistry from './helpers/newDeveloperRegistry'

const { accounts } = web3.eth
const zero = '0x0000000000000000000000000000000000000000'
const botAddr1 = '0x63e230f3b57ec9d180b9403c0d8783ddc135f664'
const botAddr2 = '0x319f2c0d4e7583dff11a37ec4f2c907c8e76593a'
const botAddr3 = '0x70d9f81dca9102acda0b894e64a7c683924355df'
const tallaWalletAddress = '0x1ae554eea0dcfdd72dcc3fa4034761cf6d041bf3'
const entryPrice = 100
const dataHash = web3.sha3('some data to hash')
const dataHash2 = web3.sha3('other data to hash')
const devUrl = web3.fromAscii('some url to hash')
const url = 'www.google.com'

const PublicStorage = artifacts.require('./PublicStorage.sol')
const BotEntryRegistry = artifacts.require('./BotEntryRegistry.sol')
const BotEntryStorableRegistry = artifacts.require('./BotEntryStorableRegistry.sol')
const BotCoin = artifacts.require('BotCoin')

contract('BotEntryStorableRegistry', () => {
  let developerRegistry, botEntryStorableRegistry, botCoin

  beforeEach(async () => {
    botCoin = await BotCoin.new()
    developerRegistry = await newDeveloperRegistry(
      botCoin.address,
      tallaWalletAddress,
      entryPrice
    )
    botEntryStorableRegistry = await newBotEntryStorableRegistry(
      developerRegistry.address,
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
        botCoin,
        developerRegistry.address,
        botCoinSeededAccounts[i],
        entryPrice
      )
      await botCoinTransferApproveSetup(
        botCoin,
        botEntryStorableRegistry.address,
        botCoinSeededAccounts[i],
        entryPrice
      )
    }
  })

  describe('createBotEntry()', () => {
    beforeEach(async () => {
      await developerRegistry.addDeveloper(dataHash, devUrl, { from: accounts[1] })
      await developerRegistry.grantApproval(1)
    })

    describe('when given valid params', () => {
      let txResult

      beforeEach(async () => {
        txResult = await botEntryStorableRegistry.createBotEntry(1, botAddr1, dataHash, url, { from: accounts[1] })
      })

      it('should add bot with the given owner, bot address, data hash, and url', async () => {
        let bot = await botEntryStorableRegistry.getBotEntry(1)
        expect(bot[0]).to.equal(accounts[1])
        expect(bot[1]).to.equal(botAddr1)
        expect(bot[2]).to.equal(dataHash)
      })

      it('should add bot address to bot ID mapping', async () => {
        expect(await botEntryStorableRegistry.botEntryAddressExists(botAddr1)).to.equal(true)
      })

      it('should default to approved', async () => {
        expect(await botEntryStorableRegistry.approvalStatus(1)).to.equal(true)
      })

      it('should default to active', async () => {
        expect(await botEntryStorableRegistry.active(1)).to.equal(true)
      })

      it('should log BotEntryCreated event', () => {
        expect(hasEvent(txResult, 'BotEntryCreated')).to.equal(true)
      })
    })

    describe('when sender is not the owner of the given developer ID', () => {
      it('should revert', async () => {
        await expectRevert(botEntryStorableRegistry.createBotEntry(1, botAddr1, dataHash, url, { from: accounts[2] }))
      })
    })

    describe('when the given developer ID is not approved', () => {
      it('should revert', async () => {
        await developerRegistry.addDeveloper(dataHash, devUrl, { from: accounts[2] })
        await expectRevert(botEntryStorableRegistry.createBotEntry(2, botAddr1, dataHash, url, { from: accounts[2] }))
      })
    })

    describe('when given invalid bot address', () => {
      it('should revert', async () => {
        await expectRevert(botEntryStorableRegistry.createBotEntry(1, zero, dataHash, url, { from: accounts[1] }))
      })
    })

    describe('when given invalid data', () => {
      it('should revert', async () => {
        await expectRevert(botEntryStorableRegistry.createBotEntry(1, botAddr1, zero, url, { from: accounts[1] }))
      })
    })

    describe('when bot address already exists', () => {
      it('should revert', async () => {
        await botEntryStorableRegistry.createBotEntry(1, botAddr1, dataHash, url, { from: accounts[1] })
        await expectRevert(botEntryStorableRegistry.createBotEntry(1, botAddr1, dataHash, url, { from: accounts[1] }))
      })
    })
  })

  describe('getBotEntry()', () => {
    beforeEach(async () => {
      await developerRegistry.addDeveloper(dataHash, devUrl, { from: accounts[1] })
      await developerRegistry.addDeveloper(dataHash, devUrl, { from: accounts[2] })
      await developerRegistry.grantApproval(1)
      await developerRegistry.grantApproval(2)
    })

    describe('when given the ID of an existing bot', () => {
      let bot

      beforeEach(async () => {
        await botEntryStorableRegistry.createBotEntry(1, botAddr1, dataHash, url, { from: accounts[1] })
        await botEntryStorableRegistry.createBotEntry(2, botAddr2, dataHash2, url, { from: accounts[2] })
        bot = await botEntryStorableRegistry.getBotEntry(2)
      })

      it('should return bot owner', () => {
        expect(bot[0]).to.equal(accounts[2])
      })

      it('should return bot address', () => {
        expect(bot[1]).to.equal(botAddr2)
      })

      it('should return bot data', () => {
        expect(bot[2]).to.equal(dataHash2)
      })

    })
  })

  describe('balanceOf()', () => {
    beforeEach(async () => {
      await developerRegistry.addDeveloper(dataHash, devUrl, { from: accounts[1] })
      await developerRegistry.grantApproval(1)
    })
    it('should return number of bots owned by an address', async () => {
      await botEntryStorableRegistry.createBotEntry(1, botAddr1, dataHash, url, { from: accounts[1] })
      await botEntryStorableRegistry.createBotEntry(1, botAddr2, dataHash, url, { from: accounts[1] })
      await botEntryStorableRegistry.createBotEntry(1, botAddr3, dataHash, url, { from: accounts[1] })
      let numBots = (await botEntryStorableRegistry.balanceOf(1)).toNumber()
      expect(numBots).to.equal(3)
    })
  })
})

async function newBotEntryStorableRegistry (registryAddress, botCoinAddress, tallaWalletAddress, entryPrice) {
  const publicStorage = await PublicStorage.new()
  const botEntryStorableRegistryDelegate = await BotEntryStorableRegistry.new()
  let botEntryStorableRegistry = await BotEntryRegistry.new(
    registryAddress,
    publicStorage.address,
    botEntryStorableRegistryDelegate.address,
    botCoinAddress
  )

  botEntryStorableRegistry = _.extend(
    botEntryStorableRegistry,
    await BotEntryStorableRegistry.at(botEntryStorableRegistry.address)
  )

  await botEntryStorableRegistry.setTallaWallet(tallaWalletAddress)
  await botEntryStorableRegistry.setEntryPrice(entryPrice)

  return botEntryStorableRegistry
}

async function botCoinTransferApproveSetup (
  botCoin,
  registryAddress,
  transferFromAddress,
  amount
) {
  await botCoin.transfer(transferFromAddress, 100000000000)
  await botCoin.approve(registryAddress, amount * 3, { from: transferFromAddress })
}
