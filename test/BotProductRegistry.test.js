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
const devAddr = '0x72c2ba659460151cdfbb3cd8005ae7fbe68191b1'
const devAddr2 = '0x85626d4d9a5603a049f600d9cfef23d28ecb7b8b'
const nonOwnerAddr = accounts[1]
const dataHash = web3.sha3('some data to hash')
const dataHash2 = web3.sha3('other data to hash')
const devUrl = web3.fromAscii('some url to hash')

const PublicStorage = artifacts.require('./PublicStorage.sol')
const BotProductRegistry = artifacts.require('./BotProductRegistry.sol')
const BotProductRegistryDelegate = artifacts.require('./BotProductRegistryDelegate.sol')

contract('BotProductRegistry', () => {
  let bc, bom

  beforeEach(async () => {
    bc = await newDeveloperRegistry()
    bom = await newBotProductRegistry(bc.address)
  })

  describe('createBotProduct()', () => {
    describe('when given valid params', () => {
      let txResult

      beforeEach(async () => {
        txResult = await bom.createBotProduct(devAddr, botAddr1, dataHash)
      })

      it('should add bot with the given owner, bot address, and data hash', async () => {
        let bot = await bom.getBotProduct(1)
        expect(bot[0]).to.equal(devAddr)
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

    describe('when executed by non-owner', () => {
      it('should revert', async () => {
        await expectRevert(bom.createBotProduct(devAddr, botAddr1, dataHash, { from: nonOwnerAddr }))
      })
    })

    describe('when given invalid owner address', () => {
      it('should revert', async () => {
        await expectRevert(bom.createBotProduct(zero, botAddr1, dataHash))
      })
    })

    describe('when given invalid bot address', () => {
      it('should revert', async () => {
        await expectRevert(bom.createBotProduct(devAddr, zero, dataHash))
      })
    })

    describe('when given invalid data', () => {
      it('should revert', async () => {
        await expectRevert(bom.createBotProduct(devAddr, botAddr1, zero))
      })
    })

    describe('when bot address already exists', () => {
      it('should revert', async () => {
        await bom.createBotProduct(devAddr, botAddr1, dataHash)
        await expectRevert(bom.createBotProduct(devAddr, botAddr1, dataHash))
      })
    })
  })

  describe('getBotProduct()', () => {
    describe('when given the ID of an existing bot', () => {
      let bot

      beforeEach(async () => {
        await bom.createBotProduct(devAddr, botAddr1, dataHash)
        await bom.createBotProduct(devAddr2, botAddr2, dataHash2)
        bot = await bom.getBotProduct(2)
      })

      it('should return bot owner', () => {
        expect(bot[0]).to.equal(devAddr2)
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
    it('should return number of bots owned by an address', async () => {
      await bom.createBotProduct(devAddr, botAddr1, dataHash)
      await bom.createBotProduct(devAddr, botAddr2, dataHash)
      await bom.createBotProduct(devAddr, botAddr3, dataHash)
      let numBots = (await bom.balanceOf(devAddr)).toNumber()
      expect(numBots).to.equal(3)
    })
  })

  describe('transfer()', () => {
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

    /* describe('when given an address that is not an approved developer', () => {
      it('should revert', async () => {
        await expectRevert(bom.transfer(devAddr2, 1, { from: senderAddr }))
      })
    }) */

    /* describe('when bot is disabled', () => {
      it('should revert', async () => {
        await bom.disableBotProduct(1)
        await expectRevert(bom.transfer(recipientAddr, 1, { from: senderAddr }))
      })
    }) */
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
  })

  describe('disableBotProduct()', () => {
    beforeEach(async () => {
      await bc.addDeveloper(devAddr, dataHash, devUrl)
      await bom.createBotProduct(devAddr, botAddr1, dataHash)
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
      await bc.addDeveloper(devAddr, dataHash, devUrl)
      await bom.createBotProduct(devAddr, botAddr1, dataHash)
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
