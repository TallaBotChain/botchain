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
const nonOwnerAddr = accounts[1]

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
    bc = await newDeveloperRegistry(botCoin.address, tallaWalletAddress, entryPrice)
    await botCoin.transfer(accounts[1], entryPrice)
    await botCoin.approve(bc.address, entryPrice, { from: accounts[1] })
    await botCoin.transfer(accounts[2], entryPrice)
    await botCoin.approve(bc.address, entryPrice, { from: accounts[2] })
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

  // TODO: fix bot transfer tests
  /* describe('transfer()', () => {
    let senderAddr, recipientAddr

    beforeEach(async () => {
      senderAddr = accounts[7]
      recipientAddr = devAddr
      await bc.addDeveloper(recipientAddr, dataHash, devUrl)
      await bc.addDeveloper(senderAddr, dataHash, devUrl)
      await bom.createBotProduct(senderAddr, botAddr1, dataHash)
    })

    describe('when transfer is valid', () => {
      let tx
      beforeEach(async () => {
        tx = await bom.transfer(recipientAddr, 1, { from: senderAddr })
      })

      it('should change bot owner to the new owner', async () => {
        const botProductOwnerAddr = await bom.ownerOf(1)
        expect(botProductOwnerAddr).to.equal(recipientAddr)
      })

      it('should decrement ownership count for sender', async () => {
        expect((await bom.balanceOf(senderAddr)).toNumber()).to.equal(0)
      })

      it('should increment ownership count for recipient', async () => {
        expect((await bom.balanceOf(recipientAddr)).toNumber()).to.equal(1)
      })

      it('should log Transfer event', () => {
        expect(hasEvent(tx, 'Transfer')).to.equal(true)
      })
    })

    describe('when given a zero address', () => {
      it('should revert', async () => {
        await expectRevert(bom.transfer(zero, 1, { from: senderAddr }))
      })
    })

    describe('when given a botProductId that the sender does not own', () => {
      it('should revert', async () => {
        await expectRevert(bom.transfer(recipientAddr, 1, { from: accounts[5] }))
      })
    })

    // describe('when given an address that is not an approved developer', () => {
    //   it('should revert', async () => {
    //     await expectRevert(bom.transfer(devAddr2, 1, { from: senderAddr }))
    //   })
    // })

    // describe('when bot is disabled', () => {
    //   it('should revert', async () => {
    //     await bom.disableBotProduct(1)
    //     await expectRevert(bom.transfer(recipientAddr, 1, { from: senderAddr }))
    //   })
    // })
  })

  describe('approve()', () => {
    let approverAddr, senderAddr

    beforeEach(async () => {
      approverAddr = accounts[6]
      senderAddr = accounts[7]
      await bc.addDeveloper(approverAddr, dataHash, devUrl)
      await bom.createBotProduct(approverAddr, botAddr1, dataHash)
    })

    describe('when transaction is valid', () => {
      let tx
      beforeEach(async () => {
        tx = await bom.approve(senderAddr, 1, { from: approverAddr })
      })

      it('should log Approval event', () => {
        expect(hasEvent(tx, 'Approval')).to.equal(true)
      })
    })

    describe('when transaction is executed by an address other than the bot owner', () => {
      it('should revert', async () => {
        await expectRevert(bom.approve(senderAddr, 1, { from: nonOwnerAddr }))
      })
    })
  }) */

  describe('disableBotProduct()', () => {
    beforeEach(async () => {
      await bc.addDeveloper(dataHash, devUrl, { from: accounts[1] })
      await bc.grantApproval(1)
      await bom.createBotProduct(botAddr1, dataHash, { from: accounts[1] })
    })

    describe('when transaction is valid', () => {
      let tx
      beforeEach(async () => {
        tx = await bom.disableBotProduct(1)
      })

      it('should set bot to disabled', async () => {
        expect(await bom.botProductIsEnabled(1)).to.equal(false)
      })

      it('should log BotProductDisabled event', () => {
        expect(hasEvent(tx, 'BotProductDisabled'))
      })
    })

    describe('when send by an address that is not the contract owner', () => {
      it('should revert', async () => {
        await expectRevert(bom.disableBotProduct(1, { from: nonOwnerAddr }))
      })
    })

    describe('when botProductId is 0', () => {
      it('should revert', async () => {
        await expectRevert(bom.disableBotProduct(0))
      })
    })

    describe('when bot does not exist', () => {
      it('should revert', async () => {
        await expectRevert(bom.disableBotProduct(3))
      })
    })

    describe('when bot is already disabled', () => {
      it('should revert', async () => {
        await bom.disableBotProduct(1)
        await expectRevert(bom.disableBotProduct(1))
      })
    })
  })

  describe('enableBotProduct()', () => {
    beforeEach(async () => {
      await bc.addDeveloper(dataHash, devUrl, { from: accounts[1] })
      await bc.grantApproval(1)
      await bom.createBotProduct(botAddr1, dataHash, { from: accounts[1] })
      await bom.disableBotProduct(1)
    })

    describe('when transaction is valid', () => {
      let tx
      beforeEach(async () => {
        tx = await bom.enableBotProduct(1)
      })

      it('should set bot to enabled', async () => {
        expect(await bom.botProductIsEnabled(1)).to.equal(true)
      })

      it('should log BotProductEnabled event', () => {
        expect(hasEvent(tx, 'BotProductEnabled'))
      })
    })

    describe('when send by an address that is not the contract owner', () => {
      it('should revert', async () => {
        await expectRevert(bom.enableBotProduct(1, { from: nonOwnerAddr }))
      })
    })

    describe('when botProductId is 0', () => {
      it('should revert', async () => {
        await expectRevert(bom.enableBotProduct(0))
      })
    })

    describe('when bot does not exist', () => {
      it('should revert', async () => {
        await expectRevert(bom.enableBotProduct(3))
      })
    })

    describe('when bot is already enabled', () => {
      it('should revert', async () => {
        await bom.enableBotProduct(1)
        await expectRevert(bom.enableBotProduct(1))
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
