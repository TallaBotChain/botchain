/* global describe it beforeEach artifacts contract */

import _ from 'lodash'
import { expect } from 'chai'
import { web3 } from './helpers/w3'
import expectRevert from './helpers/expectRevert'
import { hasEvent } from './helpers/event'
import isNonZeroAddress from './helpers/isNonZeroAddress'
import newDeveloperRegistry from './helpers/newDeveloperRegistry'

const { accounts } = web3.eth
const zeroAddr = '0x0000000000000000000000000000000000000000'
const zeroHash = '0x0000000000000000000000000000000000000000000000000000000000000000'
const addr = '0x72c2ba659460151cdfbb3cd8005ae7fbe68191b1'
const addr2 = '0x85626d4d9a5603a049f600d9cfef23d28ecb7b8b'
const addr3 = accounts[1]
const addr4 = accounts[2]
const nonOwnerAddr = accounts[3]
const botAddr = accounts[4]
const dataHash = web3.sha3('some data to hash')
const url = web3.fromAscii('www.google.com')
const updatedUrl = web3.fromAscii('www.notgoogle.com')
const updatedDataHash = web3.sha3('some modified data to hash')

const BotProductRegistryDelegate = artifacts.require('./BotProductRegistryDelegate.sol')

contract('DeveloperRegistry', () => {
  let bc

  beforeEach(async () => {
    bc = await newDeveloperRegistry()
  })

  describe.only('when deployed', () => {
    it('should create a new BotManagerOwernship contract', async () => {
      const addr = await bc.getBotProductProductRegistry()
      expect(isNonZeroAddress(addr)).to.equal(true)
    })
  })

  describe('addDeveloper()', () => {
    describe.only('when given a valid address and valid hash', () => {
      let txResult

      beforeEach(async () => {
        txResult = await bc.addDeveloper(addr, dataHash, url)
      })

      it('should add developer to data mapping', async () => {
        const data = await bc.getDeveloperDataHash(0)
        expect(data).to.equal(dataHash)
      })

      it('should add developer to url mapping', async () => {
        const devUrl = await bc.getDeveloperUrl(0)
        expect(devUrl).to.contain(url)
      })

      it('should add developer to approved mapping', async () => {
        const approved = await bc.getDeveloperApprovalStatus(0)
        expect(approved).to.equal(true)
      })

      it('should set the owner address of the new developer', async () => {
        expect(await bc.ownerOf(0)).to.equal(addr)
      })

      it('should log DeveloperAdded event', () => {
        expect(hasEvent(txResult, 'DeveloperAdded')).to.equal(true)
      })
    })

    describe.only('when given a 0x0 hash', () => {
      it('should revert', async () => {
        await expectRevert(bc.addDeveloper(addr, zeroHash, url))
      })
    })

    describe.only('when called by non-owner', () => {
      it('should revert', async () => {
        await expectRevert(bc.addDeveloper(addr, dataHash, url, { from: nonOwnerAddr }))
      })
    })

    describe.only('when given a 0x0 address', () => {
      it('should revert', async () => {
        await expectRevert(bc.addDeveloper(zeroAddr, dataHash, url))
      })
    })
  })

  describe.only('revokeDeveloperApproval()', () => {
    beforeEach(async () => {
      await bc.addDeveloper(addr, dataHash, url)
    })

    describe('when given a valid developer address that is approved', () => {
      let txResult
      beforeEach(async () => {
        txResult = await bc.revokeDeveloperApproval(0)
      })

      it('should set approved to false', async () => {
        expect(await bc.getDeveloperApprovalStatus(0)).to.equal(false)
      })

      it('should log DeveloperApprovalRevoked event', () => {
        expect(hasEvent(txResult, 'DeveloperApprovalRevoked')).to.equal(true)
      })
    })

    describe('when called by non-owner', () => {
      it('should revert', async () => {
        await expectRevert(bc.revokeDeveloperApproval(0, { from: nonOwnerAddr }))
      })
    })

    describe('when given an address that is not an approved developer', () => {
      it('should revert', async () => {
        await expectRevert(bc.revokeDeveloperApproval(3))
      })
    })
  })
})
