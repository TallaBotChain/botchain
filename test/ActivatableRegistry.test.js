/* global describe it beforeEach artifacts contract */

import _ from 'lodash'
import { expect } from 'chai'
import { web3 } from './helpers/w3'
import expectRevert from './helpers/expectRevert'
import { hasEvent } from './helpers/event'

const PublicStorage = artifacts.require('./PublicStorage.sol')
const MockProxyInstance = artifacts.require('./MockProxyInstance.sol')
const MockActivatableRegistryDelegate = artifacts.require('./MockActivatableRegistryDelegate.sol')

contract('ActivatableRegistry', () => {
  let activatable
  let accounts

  beforeEach(async () => {
    activatable = await newActivatableRegistry()
    accounts = await web3.eth.getAccounts()
  })

  describe('activate()', () => {
    describe('when given a valid entry ID that is not activated', () => {
      let txResult
      beforeEach(async () => {
        await activatable.add({ from: accounts[3] })
        txResult = await activatable.activate(1, { from: accounts[3] })
      })

      it('should set active to true', async () => {
        expect(await activatable.active(1)).to.equal(true)
      })

      it('should log Activate event', () => {
        expect(hasEvent(txResult, 'Activate')).to.equal(true)
      })
    })

    describe('when called by address that does not own the entry', () => {
      beforeEach(async () => {
        await activatable.add({ from: accounts[3] })
      })

      it('should revert', async () => {
        await expectRevert(activatable.activate(1, { from: accounts[4] }))
      })
    })

    describe('when given an ID of a entry that is already activated', () => {
      it('should revert', async () => {
        await activatable.add({ from: accounts[3] })
        await activatable.activate(1, { from: accounts[3] })
        await expectRevert(activatable.activate(1, { from: accounts[3] }))
      })
    })

    describe('when given an ID of a entry that does not exist', () => {
      it('should revert', async () => {
        await expectRevert(activatable.activate(5, { from: accounts[3] }))
      })
    })
  })

  describe('deactivate()', () => {
    describe('when given a valid entry ID that is currently activated', () => {
      let txResult
      beforeEach(async () => {
        await activatable.add({ from: accounts[3] })
        await activatable.activate(1, { from: accounts[3] })
        txResult = await activatable.deactivate(1, { from: accounts[3] })
      })

      it('should set active to true', async () => {
        expect(await activatable.active(1)).to.equal(false)
      })

      it('should log Deactivate event', () => {
        expect(hasEvent(txResult, 'Deactivate')).to.equal(true)
      })
    })

    describe('when called by address that does not own the entry', () => {
      beforeEach(async () => {
        await activatable.add({ from: accounts[3] })
        await activatable.activate(1, { from: accounts[3] })
      })

      it('should revert', async () => {
        await expectRevert(activatable.deactivate(1, { from: accounts[4] }))
      })
    })

    describe('when given an ID of a entry that is already deactivated', () => {
      it('should revert', async () => {
        await activatable.add({ from: accounts[3] })
        await expectRevert(activatable.deactivate(1, { from: accounts[3] }))
      })
    })

    describe('when given an ID of a entry that does not exist', () => {
      it('should revert', async () => {
        await expectRevert(activatable.deactivate(5, { from: accounts[3] }))
      })
    })
  })
})

async function newActivatableRegistry () {
  const publicStorage = await PublicStorage.new()
  const activatableRegistry = await MockActivatableRegistryDelegate.new()
  const activatable = await MockProxyInstance.new(
    publicStorage.address,
    activatableRegistry.address
  )
  return _.extend(activatable, await MockActivatableRegistryDelegate.at(activatable.address))
}
