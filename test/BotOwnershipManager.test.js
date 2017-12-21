/* global describe it beforeEach artifacts contract */

import { expect } from 'chai'
import { web3 } from './helpers/w3'
import tryAsync from './helpers/tryAsync'
import expectRevert from './helpers/expectRevert'
import { hasEvent } from './helpers/event'
import isNonZeroAddress from './helpers/isNonZeroAddress'

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
const updatedDataHash = web3.sha3('some modified data to hash')

const BotChain = artifacts.require('./BotChain.sol')
const BotOwnershipManager = artifacts.require('./BotOwnershipManager.sol')

contract('BotOwnershipManager', () => {
  let bc, bom

  beforeEach(async () => {
    bc = await newBotChain()
    bom = await newBotOwnershipManager(bc.address)
  })

  describe('createBot()', () => {
    describe('when given valid params', () => {
      let txResult

      beforeEach(async () => {
        txResult = await bom.createBot(devAddr, botAddr1, dataHash)
      })

      it('should add bot with the given owner, bot address, and data hash', async () => {
        let bot = await bom.getBot.call(1)
        expect(bot[0]).to.equal(devAddr)
        expect(bot[1]).to.equal(botAddr1)
        expect(bot[2]).to.equal(dataHash)
      })

      it('should add bot address to bot ID mapping', async () => {
        expect(await bom.botExists.call(botAddr1)).to.equal(true)
      })

      it('should log BotCreated event', () => {
        expect(hasEvent(txResult, 'BotCreated')).to.equal(true)
      })
    })

    describe('when executed by non-owner', () => {
      it('should throw', async () => {
        await expectRevert(bom.createBot(devAddr, botAddr1, dataHash, { from: nonOwnerAddr }))
      })
    })

    describe('when given invalid owner address', () => {
      it('should throw', async () => {
        await expectRevert(bom.createBot(zero, botAddr1, dataHash))
      })
    })

    describe('when given invalid bot address', () => {
      it('should throw', async () => {
        await expectRevert(bom.createBot(devAddr, zero, dataHash))
      })
    })

    describe('when given invalid data', () => {
      it('should throw', async () => {
        await expectRevert(bom.createBot(devAddr, botAddr1, zero))
      })
    })

    describe('when bot address already exists', () => {
      it('should throw', async () => {
        await bom.createBot(devAddr, botAddr1, dataHash)
        await expectRevert(bom.createBot(devAddr, botAddr1, dataHash))
      })
    })
  })

  describe('getBot()', () => {
    describe('when given the ID of an existing bot', () => {
      let bot

      beforeEach(async () => {
        await bom.createBot(devAddr, botAddr1, dataHash)
        await bom.createBot(devAddr2, botAddr2, dataHash2)
        bot = await bom.getBot(2)
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

  describe('updateBot()', () => {
    let bot

    beforeEach(async () => {
      bot = await bom.createBot(devAddr, botAddr1, dataHash)
    })

    describe('when given a valid bot ID and valid data', () => {
      let txResult

      beforeEach(async () => {
        txResult = await bom.updateBot(1, botAddr2, dataHash2)
        bot = await bom.getBot(1)
      })

      it('should update the address of the bot', () => {
        expect(bot[1]).to.equal(botAddr2)
      })

      it('should update the dataHash of the bot', () => {
        expect(bot[2]).to.equal(dataHash2)
      })

      it('should remove mapping to previous bot address', async () => {
        expect(await bom.botExists.call(botAddr1)).to.equal(false)
      })

      it('should add mapping to new bot address', async () => {
        expect(await bom.botExists.call(botAddr2)).to.equal(true)
      })

      it('should log BotUpdated event', () => {
        expect(hasEvent(txResult, 'BotUpdated')).to.equal(true)
      })
    })

    describe('when executed by non-owner', () => {
      it('should throw', async () => {
        await expectRevert(bom.updateBot(1, botAddr2, dataHash2, { from: nonOwnerAddr }))
      })
    })

    describe('when given a bot ID that does not exist', () => {
      it('should throw', async () => {
        await expectRevert(bom.updateBot(123, botAddr2, dataHash2))
      })
    })

    describe('when given bot ID of `0`, which is an invalid empty bot', () => {
      it('should throw', async () => {
        await expectRevert(bom.updateBot(0, botAddr2, dataHash2))
      })
    })

    describe('when given an invalid bot address', () => {
      it('should throw', async () => {
        await expectRevert(bom.updateBot(1, zero, dataHash2))
      })
    })

    describe('when given an invalid data hash', () => {
      it('should throw', async () => {
        await expectRevert(bom.updateBot(1, botAddr2, zero))
      })
    })
  })

  describe('balanceOf()', () => {
    it('should return number of bots owned by an address', async () => {
      await bom.createBot(devAddr, botAddr1, dataHash)
      await bom.createBot(devAddr, botAddr2, dataHash)
      await bom.createBot(devAddr, botAddr3, dataHash)
      let numBots = (await bom.balanceOf(devAddr)).toNumber()
      expect(numBots).to.equal(3)
    })
  })

  describe('transfer()', () => {
    let senderAddr, recipientAddr

    beforeEach(async () => {
      senderAddr = accounts[7]
      recipientAddr = devAddr
      await bc.addDeveloper(recipientAddr, dataHash)
      await bc.addDeveloper(senderAddr, dataHash)
      await bom.createBot(senderAddr, botAddr1, dataHash)
    })

    describe('when transfer is valid', () => {
      let tx
      beforeEach(async () => {
        tx = await bom.transfer(recipientAddr, 1, { from: senderAddr })
      })

      it('should update bot owner in mapping', async () => {
        const botOwnerAddr = await bom.ownerOf(1)
        expect(botOwnerAddr).to.equal(recipientAddr)
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
      it('should throw', async () => {
        await expectRevert(bom.transfer(zero, 1, { from: senderAddr }))
      })
    })

    describe('when given the address of the BotOwnershipManager contract', () => {
      it('should throw', async () => {
        await bc.addDeveloper(bom.address, dataHash)
        await expectRevert(bom.transfer(bom.address, 1, { from: senderAddr }))
      })
    })

    describe('when given a botId that the sender does not own', () => {
      it('should throw', async () => {
        await expectRevert(bom.transfer(recipientAddr, 1, { from: accounts[5] }))
      })
    })

    describe('when given an address that is not an approved developer', () => {
      it('should throw', async () => {
        await expectRevert(bom.transfer(devAddr2, 1, { from: senderAddr }))
      })
    })
  })
})

async function newBotChain () {
  const bc = await tryAsync(BotChain.new())
  return bc
}

async function newBotOwnershipManager (botChainAddress) {
  const bom = await tryAsync(BotOwnershipManager.new(botChainAddress))
  return bom
}
