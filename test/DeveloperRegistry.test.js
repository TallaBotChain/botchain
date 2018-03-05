/* global describe it beforeEach contract */

import { expect } from 'chai'
import { web3 } from './helpers/w3'
import expectRevert from './helpers/expectRevert'
import { hasEvent } from './helpers/event'
import newDeveloperRegistry from './helpers/newDeveloperRegistry'

const { accounts } = web3.eth
const zeroAddr = '0x0000000000000000000000000000000000000000'
const zeroHash = '0x0000000000000000000000000000000000000000000000000000000000000000'
const addr = '0x72c2ba659460151cdfbb3cd8005ae7fbe68191b1'
const nonOwnerAddr = accounts[3]
const dataHash = web3.sha3('some data to hash')
const url = web3.fromAscii('www.google.com')

contract('DeveloperRegistry', () => {
  let bc

  beforeEach(async () => {
    bc = await newDeveloperRegistry()
  })

  describe('addDeveloper()', () => {
    describe('when given a valid address and valid hash', () => {
      let txResult

      beforeEach(async () => {
        txResult = await bc.addDeveloper(dataHash, url, { from: accounts[1] })
      })

      it('should add developer to data mapping', async () => {
        const data = await bc.developerDataHash(1)
        expect(data).to.equal(dataHash)
      })

      it('should add developer to url mapping', async () => {
        const devUrl = await bc.developerUrl(1)
        expect(devUrl).to.contain(url)
      })

      it('should set the owner address of the new developer', async () => {
        expect(await bc.ownerOf(1)).to.equal(accounts[1])
      })

      it('should map the new developer ID to the owner address', async () => {
        expect((await bc.owns(accounts[1])).toNumber()).to.equal(1)
      })

      it('should default to unapproved', async () => {
        expect(await bc.approvalStatus(1)).to.equal(false)
      })

      it('should log DeveloperAdded event', () => {
        expect(hasEvent(txResult, 'DeveloperAdded')).to.equal(true)
      })
    })

    describe('when given a 0x0 hash', () => {
      it('should revert', async () => {
        await expectRevert(bc.addDeveloper(zeroHash, url, { from: accounts[1] }))
      })
    })

    describe('when given an owner address that already exists', () => {
      it('should revert', async () => {
        await bc.addDeveloper(dataHash, url, { from: accounts[1] })
        await expectRevert(bc.addDeveloper(dataHash, url, { from: accounts[1] }))
      })
    })
  })

  describe('grantApproval()', () => {
    it('should be executable by owner', async () => {
      expect(await bc.approvalStatus(1)).to.equal(false)
      await bc.addDeveloper(dataHash, url, { from: accounts[1] })
      await bc.grantApproval(1)
      expect(await bc.approvalStatus(1)).to.equal(true)
    })
  })
})
