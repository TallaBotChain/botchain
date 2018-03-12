/* global describe it artifacts beforeEach */

import { expect } from 'chai'
import { web3 } from './helpers/w3'
import expectRevert from './helpers/expectRevert'


//const PublicStorage = artifacts.require('PublicStorage.sol')
//const ERC721Token = artifacts.require('ERC721TokenKeyedMock.sol')

const { accounts } = web3.eth

const BaseStorage = artifacts.require('BaseStorage.sol')
const OwnableKeyed = artifacts.require('OwnableKeyed')

//contract('OwnableKeyed', function (accounts) {

describe('OwnableKeyed', () => {
  let ownableKeyed

  beforeEach(async () => {
    //ownableKeyed = await OwnableKeyed.new()
    //const storage = await BaseStorage.new()
  })

  it('should have an owner', async () => {
    const owner = await OwnableKeyed.new()
    expect(owner !== 0).to.equal(true)
  })

  describe('transferOwnership', () => {
	it('changes owner after transfer', async () => {

		const _creator = accounts[0]
	    const storage = await BaseStorage.new()
	    let ownable = await OwnableKeyed.new(storage.address, { from: _creator })

	    let other = accounts[1]
	    await ownable.transferOwnership(other)
	    expect(ownable.address).to.equal(other)
	})

	it('should prevent non-owners from transfering', async () => {
	    const other = accounts[2]
	    const owner = await OwnableKeyed.new()
	    await expectRevert(OwnableKeyed.transferOwnership(other, { from: other }))
	})

  })



  it('should guard ownership against stuck state', async () => {
    let originalOwner = await OwnableKeyed.new()
    await expectRevert(originalOwner.transferOwnership(null, { from: originalOwner }))
  })

})