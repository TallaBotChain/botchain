/* global describe it artifacts beforeEach */

import { expect } from 'chai'
import { web3 } from './helpers/w3'
import expectRevert from './helpers/expectRevert'

const BaseStorage = artifacts.require('BaseStorage')
const OwnableKeyed = artifacts.require('OwnableKeyed')

describe('OwnableKeyed', () => {
  let ownable, accounts

  beforeEach(async function () {
    accounts = await web3.eth.getAccounts()
    const storage = await BaseStorage.new()
    ownable = await OwnableKeyed.new(storage.address)
  })

  it('should have an owner', async () => {
    let owner = await ownable.getOwner()
    console.log('owner:',owner)
    expect(owner !== 0).to.equal(true)
  })

  describe('transferOwnership', () => {
    it('changes owner after transfer', async () => {
      let other = accounts[1]
      let owner = await ownable.getOwner()
      console.log('owner:',owner,'other:',other)
      await ownable.transferOwnership(other, {from: owner})
      expect(await ownable.getOwner()).to.equal(other.toLowerCase()) 
    })

    it('should prevent non-owners from transfering', async () => {
      const other = accounts[2]
      const owner = await ownable.getOwner()
      expect(owner !== other.toLowerCase()).to.equal(true)
      await expectRevert(ownable.transferOwnership(other, { from: other }))
    })
  })

  it('should guard ownership against stuck state', async () => {
    let originalOwner = await ownable.getOwner()
    await expectRevert(ownable.transferOwnership(null, { from: originalOwner }))
  })

})
