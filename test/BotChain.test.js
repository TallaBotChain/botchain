/* global describe it beforeEach artifacts contract */

import { expect } from 'chai'
import { web3 } from './helpers/w3'
import tryAsync from './helpers/tryAsync'
import expectRevert from './helpers/expectRevert'
import { hasEvent } from './helpers/event'
import isNonZeroAddress from './helpers/isNonZeroAddress'

const { accounts } = web3.eth
const zeroAddr = '0x0000000000000000000000000000000000000000'
const zeroHash = '0x0000000000000000000000000000000000000000000000000000000000000000'
const devAddr = '0x72c2ba659460151cdfbb3cd8005ae7fbe68191b1'
const devAddr2 = '0x85626d4d9a5603a049f600d9cfef23d28ecb7b8b'
const nonOwnerAddr = accounts[1]
const dataHash = web3.sha3('some data to hash')
const updatedDataHash = web3.sha3('some modified data to hash')

const BotChain = artifacts.require('./BotChain.sol')

contract('BotChain', () => {
  let bc

  beforeEach(async () => {
    bc = await newBotChain()
  })

  describe('when deployed', () => {
    it('should create a new BotManagerOwernship contract', async () => {
      const addr = await bc.botOwnershipManager.call()
      expect(isNonZeroAddress(addr)).to.equal(true)
    })

    it('should add 0x0 address as first developer in array', async () => {
      const addr = await bc.developers.call(0)
      expect(addr).to.equal(zeroAddr)
    })
  })

  describe('addDeveloper()', () => {
    describe('when given a valid address and valid hash', () => {
      let txResult
      beforeEach(async () => {
        txResult = await bc.addDeveloper(devAddr, dataHash)
      })

      it('should add developer to data mapping', async () => {
        const data = await bc.developerToData.call(devAddr)
        expect(data).to.equal(dataHash)
      })

      it('should add developer to approved mapping', async () => {
        const approved = await bc.developerToApproved.call(devAddr)
        expect(approved).to.equal(true)
      })

      it('should add developer to array', async () => {
        expect(await bc.developers.call(1)).to.equal(devAddr)
      })

      it('should log DeveloperAdded event', () => {
        expect(hasEvent(txResult, 'DeveloperAdded')).to.equal(true)
      })
    })

    describe('when given a 0x0 hash', () => {
      it('should revert', async () => {
        await expectRevert(bc.addDeveloper(devAddr, zeroHash))
      })
    })

    describe('when called by non-owner', () => {
      it('should revert', async () => {
        await expectRevert(bc.addDeveloper(devAddr, dataHash, { from: nonOwnerAddr }))
      })
    })

    describe('when given a 0x0 address', () => {
      it('should revert', async () => {
        await expectRevert(bc.addDeveloper(zeroAddr, dataHash))
      })
    })
  })

  describe('updateDeveloper()', () => {
    beforeEach(async () => {
      await bc.addDeveloper(devAddr, dataHash)
    })

    describe('when given a valid address and valid hash', () => {
      let txResult
      beforeEach(async () => {
        txResult = await bc.updateDeveloper(devAddr, updatedDataHash)
      })

      it('should update hash value in mapping', async () => {
        expect(await bc.developerToData.call(devAddr)).to.equal(updatedDataHash)
      })

      it('should log DeveloperUpdated event', async () => {
        expect(hasEvent(txResult, 'DeveloperUpdated')).to.equal(true)
      })
    })

    describe('when given a 0x0 hash', () => {
      it('should revert', async () => {
        await expectRevert(bc.updateDeveloper(devAddr, zeroHash))
      })
    })

    describe('when called by non-owner', () => {
      it('should revert', async () => {
        await expectRevert(bc.updateDeveloper(devAddr, updatedDataHash, { from: nonOwnerAddr }))
      })
    })

    describe('when given a 0x0 developer address', () => {
      it('should revert', async () => {
        await expectRevert(bc.updateDeveloper(zeroAddr, updatedDataHash))
      })
    })
  })

  describe('revokeDeveloperApproval()', () => {
    beforeEach(async () => {
      await bc.addDeveloper(devAddr, dataHash)
    })

    describe('when given a valid developer address that is approved', () => {
      let txResult
      beforeEach(async () => {
        txResult = await bc.revokeDeveloperApproval(devAddr)
      })

      it('should set approved to false', async () => {
        expect(await bc.isApprovedDeveloper.call(devAddr)).to.equal(false)
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
})

async function newBotChain () {
  const bc = await tryAsync(BotChain.new())
  return bc
}
