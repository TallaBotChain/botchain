/* global describe it beforeEach artifacts contract */

import _ from 'lodash'
import { expect } from 'chai'
import { web3 } from './helpers/w3'
import expectRevert from './helpers/expectRevert'
import { hasEvent } from './helpers/event'
import isNonZeroAddress from './helpers/isNonZeroAddress'
import newBotChain from './helpers/newBotChain'

const { accounts } = web3.eth
const zeroAddr = '0x0000000000000000000000000000000000000000'
const zeroHash = '0x0000000000000000000000000000000000000000000000000000000000000000'
const devAddr = '0x72c2ba659460151cdfbb3cd8005ae7fbe68191b1'
const devAddr2 = '0x85626d4d9a5603a049f600d9cfef23d28ecb7b8b'
const devAddr3 = accounts[1]
const devAddr4 = accounts[2]
const nonOwnerAddr = accounts[3]
const botAddr = accounts[4]
const dataHash = web3.sha3('some data to hash')
const url = web3.sha3('www.google.com')
const updatedUrl = web3.sha3('www.notgoogle.com')
const updatedDataHash = web3.sha3('some modified data to hash')

const BotOwnershipManagerDelegate = artifacts.require('./BotOwnershipManagerDelegate.sol')

contract('BotChain', () => {
  let bc

  beforeEach(async () => {
    bc = await newBotChain()
  })

  describe('when deployed', () => {
    it('should create a new BotManagerOwernship contract', async () => {
      const addr = await bc.getBotOwnershipManager()
      expect(isNonZeroAddress(addr)).to.equal(true)
    })
  })

  describe('addDeveloper()', () => {
    describe('when given a valid address and valid hash', () => {
      let txResult
      beforeEach(async () => {
        txResult = await bc.addDeveloper(devAddr, dataHash, url)
      })

      it('should add developer to data mapping', async () => {
        const data = await bc.getDeveloperDataHash(devAddr)
        expect(data).to.equal(dataHash)
      })

      it('should add developer to url mapping', async () => {
        const devUrl = await bc.getDeveloperUrl(devAddr)
        expect(devUrl).to.equal(url)
      })

      it('should add developer to approved mapping', async () => {
        const approved = await bc.getDeveloperApprovalStatus(devAddr)
        expect(approved).to.equal(true)
      })

      it('should add developer to array', async () => {
        expect(await bc.getDeveloper(0)).to.equal(devAddr)
      })

      it('should log DeveloperAdded event', () => {
        expect(hasEvent(txResult, 'DeveloperAdded')).to.equal(true)
      })
    })

    describe('when given a 0x0 hash', () => {
      it('should revert', async () => {
        await expectRevert(bc.addDeveloper(devAddr, zeroHash, url))
      })
    })

    describe('when called by non-owner', () => {
      it('should revert', async () => {
        await expectRevert(bc.addDeveloper(devAddr, dataHash, url, { from: nonOwnerAddr }))
      })
    })

    describe('when given a 0x0 address', () => {
      it('should revert', async () => {
        await expectRevert(bc.addDeveloper(zeroAddr, dataHash, url))
      })
    })
  })

  describe('updateDeveloper()', () => {
    beforeEach(async () => {
      await bc.addDeveloper(devAddr, dataHash, url)
    })

    describe('when given a valid address and valid hash', () => {
      let txResult
      beforeEach(async () => {
        txResult = await bc.updateDeveloper(devAddr, updatedDataHash, updatedUrl)
      })

      it('should update hash value in mapping', async () => {
        expect(await bc.getDeveloperDataHash(devAddr)).to.equal(updatedDataHash)
      })

      it('should update url in mapping', async () => {
        expect(await bc.getDeveloperUrl(devAddr)).to.equal(updatedUrl)
      })

      it('should log DeveloperUpdated event', async () => {
        expect(hasEvent(txResult, 'DeveloperUpdated')).to.equal(true)
      })
    })

    describe('when given a 0x0 hash', () => {
      it('should revert', async () => {
        await expectRevert(bc.updateDeveloper(devAddr, zeroHash, updatedUrl))
      })
    })

    describe('when called by non-owner', () => {
      it('should revert', async () => {
        await expectRevert(bc.updateDeveloper(devAddr, updatedDataHash, updatedUrl, { from: nonOwnerAddr }))
      })
    })

    describe('when given a 0x0 developer address', () => {
      it('should revert', async () => {
        await expectRevert(bc.updateDeveloper(zeroAddr, updatedDataHash, updatedUrl))
      })
    })
  })

  describe('revokeDeveloperApproval()', () => {
    beforeEach(async () => {
      await bc.addDeveloper(devAddr, dataHash, url)
    })

    describe('when given a valid developer address that is approved', () => {
      let txResult
      beforeEach(async () => {
        txResult = await bc.revokeDeveloperApproval(devAddr)
      })

      it('should set approved to false', async () => {
        expect(await bc.getDeveloperApprovalStatus(devAddr)).to.equal(false)
      })

      it('should log DeveloperApprovalRevoked event', () => {
        expect(hasEvent(txResult, 'DeveloperApprovalRevoked')).to.equal(true)
      })
    })

    describe('when called by non-owner', () => {
      it('should revert', async () => {
        await expectRevert(bc.revokeDeveloperApproval(devAddr, { from: nonOwnerAddr }))
      })
    })

    describe('when given an address that is not an approved developer', () => {
      it('should revert', async () => {
        await expectRevert(bc.revokeDeveloperApproval(devAddr2))
      })
    })
  })

  describe('createBot()', () => {
    let bot
    let bomAddress
    let bom

    beforeEach(async () => {
      bomAddress = await bc.getBotOwnershipManager()
      bom = await BotOwnershipManagerDelegate.at(bomAddress)
      await bc.addDeveloper(devAddr3, dataHash, url)
      await bc.createBot(botAddr, dataHash, { from: devAddr3 })
    })

    describe('when an approved developer creates a bot with valid parameters', () => {
      it('should successfully create bot', async () => {
        // Load bot ownership manager and check for presence of bot
        bot = await bom.getBot.call(1)
        expect(bot[0]).to.equal(devAddr3)
        expect(bot[1]).to.equal(botAddr)
        expect(bot[2]).to.equal(dataHash)
      })
    })

    describe('when an unapproved developer attempts to create a bot with valid parameters', () => {
      it('should throw', async () => {
        await expectRevert(bc.createBot(botAddr, dataHash, { from: devAddr4 }))
      })
    })
  })

  describe('updateBot()', () => {
    let bot
    let bomAddress
    let bom
    let botID

    beforeEach(async () => {
      bomAddress = await bc.getBotOwnershipManager()
      bom = await BotOwnershipManagerDelegate.at(bomAddress)
      await bc.addDeveloper(devAddr3, dataHash, url)
      await bc.createBot(botAddr, dataHash, { from: devAddr3 })
      botID = await bom.getBotId(botAddr)
      await bc.updateBot(botID, botAddr, updatedDataHash, { from: devAddr3 })
    })

    describe('when an approved developer updates a bot with valid parameters', () => {
      it('should successfully update bot', async () => {
        // Load bot ownership manager and check for updated information
        bot = await bom.getBot.call(1)
        expect(bot[0]).to.equal(devAddr3)
        expect(bot[1]).to.equal(botAddr)
        expect(bot[2]).to.equal(updatedDataHash)
      })
    })

    describe('when an unapproved developer attempts to update a bot with valid parameters', () => {
      it('should throw', async () => {
        await expectRevert(bc.updateBot(botAddr, dataHash, updatedDataHash, { from: devAddr4 }))
      })
    })
  })
})
