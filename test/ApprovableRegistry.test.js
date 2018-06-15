/* global describe it beforeEach artifacts contract */

import _ from 'lodash'
import { expect } from 'chai'
import { web3 } from './helpers/w3'
import expectRevert from './helpers/expectRevert'
import { hasEvent } from './helpers/event'

const PublicStorage = artifacts.require('./PublicStorage.sol')
const MockProxyInstance = artifacts.require('./MockProxyInstance.sol')
const MockApprovableRegistryDelegate = artifacts.require('./MockApprovableRegistryDelegate.sol')

contract('ApprovableRegistry', () => {
  let approvableRegistry
  let accounts
  let nonOwnerAddr

  beforeEach(async () => {
    approvableRegistry = await newApprovableRegistry()
    accounts = await web3.eth.getAccounts()
    nonOwnerAddr = accounts[3]
  })

  describe('grantApproval()', () => {
    beforeEach(async () => {
      await approvableRegistry.add({ from: nonOwnerAddr })
      await approvableRegistry.add({ from: nonOwnerAddr })
      await approvableRegistry.grantApproval(2)
    })

    describe('when given a valid entry ID that is not approved', () => {
      let txResult
      beforeEach(async () => {
        txResult = await approvableRegistry.grantApproval(1)
      })

      it('should set approved to true', async () => {
        expect(await approvableRegistry.approvalStatus(1)).to.equal(true)
      })

      it('should log ApprovalGranted event', () => {
        expect(hasEvent(txResult, 'ApprovalGranted')).to.equal(true)
      })
    })

    describe('when called by non-owner', () => {
      it('should revert', async () => {
        await expectRevert(approvableRegistry.grantApproval(1, { from: nonOwnerAddr }))
      })
    })

    describe('when given an ID of a entry that is already approved', () => {
      it('should revert', async () => {
        await expectRevert(approvableRegistry.grantApproval(2))
      })
    })

    describe('when given an ID of a entry that does not exist', () => {
      it('should revert', async () => {
        await expectRevert(approvableRegistry.grantApproval(3))
      })
    })
  })

  describe('revokeApproval()', () => {
    beforeEach(async () => {
      await approvableRegistry.add({ from: nonOwnerAddr })
      await approvableRegistry.add({ from: nonOwnerAddr })
      await approvableRegistry.grantApproval(1)
    })

    describe('when given a valid entry ID that is approved', () => {
      let txResult
      beforeEach(async () => {
        txResult = await approvableRegistry.revokeApproval(1)
      })

      it('should set approved to false', async () => {
        expect(await approvableRegistry.approvalStatus(1)).to.equal(false)
      })

      it('should log ApprovalRevoked event', () => {
        expect(hasEvent(txResult, 'ApprovalRevoked')).to.equal(true)
      })
    })

    describe('when called by non-owner', () => {
      it('should revert', async () => {
        await expectRevert(approvableRegistry.revokeApproval(1, { from: nonOwnerAddr }))
      })
    })

    describe('when given an ID that is not an approved entry', () => {
      it('should revert', async () => {
        await expectRevert(approvableRegistry.revokeApproval(2))
      })
    })

    describe('when given an ID of a entry that does not exist', () => {
      it('should revert', async () => {
        await expectRevert(approvableRegistry.revokeApproval(3))
      })
    })
  })
})

async function newApprovableRegistry () {
  const publicStorage = await PublicStorage.new()
  const approvableRegistryDelegate = await MockApprovableRegistryDelegate.new(publicStorage.address)
  const approvableRegistry = await MockProxyInstance.new(
    publicStorage.address,
    approvableRegistryDelegate.address
  )
  return _.extend(approvableRegistry, await MockApprovableRegistryDelegate.at(approvableRegistry.address))
}
