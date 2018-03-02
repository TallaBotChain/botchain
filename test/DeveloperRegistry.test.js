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
        txResult = await bc.addDeveloper(addr, dataHash, url, { from: nonOwnerAddr })
      })

      it('should add developer to data mapping', async () => {
        const data = await bc.developerDataHash(1)
        expect(data).to.equal(dataHash)
      })

      it('should add developer to url mapping', async () => {
        const devUrl = await bc.developerUrl(1)
        expect(devUrl).to.contain(url)
      })

      it('should set developer approval status to false', async () => {
        const approved = await bc.developerApprovalStatus(1)
        expect(approved).to.equal(false)
      })

      it('should set the owner address of the new developer', async () => {
        expect(await bc.ownerOf(1)).to.equal(addr)
      })

      it('should log DeveloperAdded event', () => {
        expect(hasEvent(txResult, 'DeveloperAdded')).to.equal(true)
      })
    })

    describe('when given a 0x0 hash', () => {
      it('should revert', async () => {
        await expectRevert(bc.addDeveloper(addr, zeroHash, url, { from: nonOwnerAddr }))
      })
    })

    describe('when given a 0x0 address', () => {
      it('should revert', async () => {
        await expectRevert(bc.addDeveloper(zeroAddr, dataHash, url, { from: nonOwnerAddr }))
      })
    })
  })

  describe('grantDeveloperApproval()', () => {
    beforeEach(async () => {
      await bc.addDeveloper(addr, dataHash, url, { from: nonOwnerAddr })
      await bc.addDeveloper(addr, dataHash, url, { from: nonOwnerAddr })
      await bc.grantDeveloperApproval(2)
    })

    describe('when given a valid developer ID that is not approved', () => {
      let txResult
      beforeEach(async () => {
        txResult = await bc.grantDeveloperApproval(1)
      })

      it('should set approved to true', async () => {
        expect(await bc.developerApprovalStatus(1)).to.equal(true)
      })

      it('should log DeveloperApprovalGranted event', () => {
        expect(hasEvent(txResult, 'DeveloperApprovalGranted')).to.equal(true)
      })
    })

    describe('when called by non-owner', () => {
      it('should revert', async () => {
        await expectRevert(bc.grantDeveloperApproval(1, { from: nonOwnerAddr }))
      })
    })

    describe('when given an ID of a developer that is already approved', () => {
      it('should revert', async () => {
        await expectRevert(bc.grantDeveloperApproval(2))
      })
    })

    describe('when given an ID of a developer that does not exist', () => {
      it('should revert', async () => {
        await expectRevert(bc.grantDeveloperApproval(3))
      })
    })
  })

  describe('revokeDeveloperApproval()', () => {
    beforeEach(async () => {
      await bc.addDeveloper(addr, dataHash, url, { from: nonOwnerAddr })
      await bc.addDeveloper(addr, dataHash, url, { from: nonOwnerAddr })
      await bc.grantDeveloperApproval(1)
    })

    describe('when given a valid developer ID that is approved', () => {
      let txResult
      beforeEach(async () => {
        txResult = await bc.revokeDeveloperApproval(1)
      })

      it('should set approved to false', async () => {
        expect(await bc.developerApprovalStatus(1)).to.equal(false)
      })

      it('should log DeveloperApprovalRevoked event', () => {
        expect(hasEvent(txResult, 'DeveloperApprovalRevoked')).to.equal(true)
      })
    })

    describe('when called by non-owner', () => {
      it('should revert', async () => {
        await expectRevert(bc.revokeDeveloperApproval(1, { from: nonOwnerAddr }))
      })
    })

    describe('when given an ID that is not an approved developer', () => {
      it('should revert', async () => {
        await expectRevert(bc.revokeDeveloperApproval(2))
      })
    })

    describe('when given an ID of a developer that does not exist', () => {
      it('should revert', async () => {
        await expectRevert(bc.revokeDeveloperApproval(3))
      })
    })
  })
})
