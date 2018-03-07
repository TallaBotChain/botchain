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

const PublicStorage = artifacts.require('./PublicStorage.sol')
const BotProductRegistry = artifacts.require('./BotProductRegistry.sol')
const BotProductRegistryDelegate = artifacts.require('./BotProductRegistryDelegate.sol')
const BotCoin = artifacts.require('BotCoin')

contract('BotProductRegistry', () => {
  let bc, bom, botCoin

  beforeEach(async () => {
    botCoin = await BotCoin.new()
    bc = await newDeveloperRegistry(botCoin.address, tallaWalletAddress)
    const botCoinSeededAccounts = [
      accounts[1],
      accounts[2],
      accounts[7],
      accounts[8]
    ]
    for (var i = 0; i < botCoinSeededAccounts.length; i++) {
      await botCoinTransferApproveSetup(
        botCoin,
        bc.address,
        botCoinSeededAccounts[i],
        entryPrice
      )
    }
    bom = await newBotProductRegistry(bc.address)
  })

  describe('createBotProduct()', () => {
    beforeEach(async () => {
      await bc.addDeveloper(dataHash, devUrl, { from: accounts[1] })
      await bc.grantApproval(1)
    })

    describe('when given valid params', () => {
      let txResult

      beforeEach(async () => {
        txResult = await bom.createBotProduct(botAddr1, dataHash, { from: accounts[1] })
      })

      it('should add bot with the given owner, bot address, and data hash', async () => {
        let bot = await bom.getBotProduct(1)
        expect(bot[0]).to.equal(accounts[1])
        expect(bot[1]).to.equal(botAddr1)
        expect(bot[2]).to.equal(dataHash)
      })

      it('should add bot address to bot ID mapping', async () => {
        expect(await bom.botProductAddressExists(botAddr1)).to.equal(true)
      })

      it('should default to approved', async () => {
        expect(await bom.approvalStatus(1)).to.equal(true)
      })

      it('should default to active', async () => {
        expect(await bom.active(1)).to.equal(true)
      })

      it('should log BotProductCreated event', () => {
        expect(hasEvent(txResult, 'BotProductCreated')).to.equal(true)
      })

      it('should log Transfer event', () => {
        expect(hasEvent(txResult, 'Transfer')).to.equal(true)
      })
    })

    describe('when sender is not the owner of an approved developer entry', () => {
      it('should revert', async () => {
        await expectRevert(bom.createBotProduct(botAddr1, dataHash, { from: accounts[2] }))
      })
    })

    describe('when sender is the owner of an unapproved developer entry', () => {
      it('should revert', async () => {
        await bc.addDeveloper(dataHash, devUrl, { from: accounts[2] })
        await expectRevert(bom.createBotProduct(botAddr1, dataHash, { from: accounts[2] }))
      })
    })

    describe('when given invalid bot address', () => {
      it('should revert', async () => {
        await expectRevert(bom.createBotProduct(zero, dataHash, { from: accounts[1] }))
      })
    })

    describe('when given invalid data', () => {
      it('should revert', async () => {
        await expectRevert(bom.createBotProduct(botAddr1, zero, { from: accounts[1] }))
      })
    })

    describe('when bot address already exists', () => {
      it('should revert', async () => {
        await bom.createBotProduct(botAddr1, dataHash, { from: accounts[1] })
        await expectRevert(bom.createBotProduct(botAddr1, dataHash, { from: accounts[1] }))
      })
    })
  })

  describe('getBotProduct()', () => {
    beforeEach(async () => {
      await bc.addDeveloper(dataHash, devUrl, { from: accounts[1] })
      await bc.addDeveloper(dataHash, devUrl, { from: accounts[2] })
      await bc.grantApproval(1)
      await bc.grantApproval(2)
    })

    describe('when given the ID of an existing bot', () => {
      let bot

      beforeEach(async () => {
        await bom.createBotProduct(botAddr1, dataHash, { from: accounts[1] })
        await bom.createBotProduct(botAddr2, dataHash2, { from: accounts[2] })
        bot = await bom.getBotProduct(2)
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
      await bc.addDeveloper(dataHash, devUrl, { from: accounts[1] })
      await bc.grantApproval(1)
    })
    it('should return number of bots owned by an address', async () => {
      await bom.createBotProduct(botAddr1, dataHash, { from: accounts[1] })
      await bom.createBotProduct(botAddr2, dataHash, { from: accounts[1] })
      await bom.createBotProduct(botAddr3, dataHash, { from: accounts[1] })
      let numBots = (await bom.balanceOf(accounts[1])).toNumber()
      expect(numBots).to.equal(3)
    })
  })

  describe('transfer()', () => {
    let senderAddr, recipientAddr

    beforeEach(async () => {
      senderAddr = accounts[7]
      recipientAddr = accounts[8]
      await bc.addDeveloper(dataHash, devUrl, { from: senderAddr })
      await bc.addDeveloper(dataHash, devUrl, { from: recipientAddr })
      await bc.grantApproval(1)
      await bom.createBotProduct(botAddr1, dataHash, { from: senderAddr })
    })

    describe('when given an address that is an approved developer', () => {
      it('should change bot owner to the new owner', async () => {
        await bc.grantApproval(2)
        await bom.transfer(recipientAddr, 1, { from: senderAddr })
        const botProductOwnerAddr = await bom.ownerOf(1)
        expect(botProductOwnerAddr).to.equal(recipientAddr)
      })
    })

    describe('when given an address that is not an approved developer', () => {
      it('should revert', async () => {
        await expectRevert(bom.transfer(recipientAddr, 1, { from: senderAddr }))
      })
    })

    describe('when bot product is not approved', () => {
      it('should revert', async () => {
        await bc.grantApproval(2)
        await bom.revokeApproval(1)
        await expectRevert(bom.transfer(recipientAddr, 1, { from: senderAddr }))
      })
    })
  })
})

async function newBotProductRegistry (developerRegistryAddress) {
  const publicStorage = await PublicStorage.new()
  const botProductRegistryDelegate = await BotProductRegistryDelegate.new()
  const bom = await BotProductRegistry.new(
    developerRegistryAddress,
    publicStorage.address,
    botProductRegistryDelegate.address
  )
  return _.extend(bom, await BotProductRegistryDelegate.at(bom.address))
}

async function botCoinTransferApproveSetup (
  botCoin,
  developerRegistryAddress,
  transferFromAddress,
  amount
) {
  await botCoin.transfer(transferFromAddress, amount)
  await botCoin.approve(developerRegistryAddress, amount, { from: transferFromAddress })
}
