/* global describe it artifacts beforeEach */

import { expect } from 'chai'
import { web3 } from './helpers/w3'
import expectRevert from './helpers/expectRevert'

const BigNumber = web3.BigNumber
const PublicStorage = artifacts.require('PublicStorage.sol')
const OwnableRegistry = artifacts.require('MockOwnableRegistry.sol')

const { accounts } = web3.eth

describe('OwnableRegistry', () => {
  let ownableRegistry = null
  const _firstEntryId = 1
  const _secondEntryId = 2
  const _unknownEntryId = 3
  const _creator = accounts[0]
  const _entryOwnerId = 4
  const ZERO_ID = '0'

  beforeEach(async function () {
    const storage = await PublicStorage.new()
    ownableRegistry = await OwnableRegistry.new(storage.address, { from: _creator })
    await ownableRegistry.mint(_entryOwnerId, _firstEntryId, { from: _creator })
    await ownableRegistry.mint(_entryOwnerId, _secondEntryId, { from: _creator })
  })

  describe('totalSupply', function () {
    it('has a total supply equivalent to the inital supply', async function () {
      const totalSupply = await ownableRegistry.totalSupply()
      totalSupply.should.be.bignumber.equal(2)
    })
  })

  describe('balanceOf', function () {
    describe('when the given id owns some tokens', function () {
      it('returns the amount of tokens owned by the given id', async function () {
        const balance = await ownableRegistry.balanceOf(_entryOwnerId)
        balance.should.be.bignumber.equal(2)
      })
    })

    describe('when the given id does not own any tokens', function () {
      it('returns 0', async function () {
        const balance = await ownableRegistry.balanceOf(5)
        balance.should.be.bignumber.equal(0)
      })
    })
  })

  describe('ownerOf', function () {
    describe('when the given entry ID was tracked by this token', function () {
      const entryId = _firstEntryId

      it('returns the owner of the given entry ID', async function () {
        const ownerId = await ownableRegistry.ownerOf(entryId)
        ownerId.should.be.bignumber.equal(_entryOwnerId)
      })
    })

    describe('when the given entry ID was not tracked by this token', function () {
      const entryId = _unknownEntryId

      it('reverts', async function () {
        await expectRevert(ownableRegistry.ownerOf(entryId))
      })
    })
  })

  describe('mint', function () {
    describe('when the given entry ID was not tracked by this contract', function () {
      const entryId = _unknownEntryId

      describe('when the given id is not the zero id', function () {
        const to = 5

        it('mints the given entry ID to the given id', async function () {
          const previousBalance = await ownableRegistry.balanceOf(to)

          await ownableRegistry.mint(to, entryId)

          const ownerId = await ownableRegistry.ownerOf(entryId)
          ownerId.should.be.bignumber.equal(to)

          const balance = await ownableRegistry.balanceOf(to)
          balance.should.be.bignumber.equal(previousBalance + 1)
        })

        it('adds that id to the token list of the owner', async function () {
          await ownableRegistry.mint(to, entryId)

          const ownableRegistries = await ownableRegistry.tokensOf(to)
          ownableRegistries.length.should.be.equal(1)
          ownableRegistries[0].should.be.bignumber.equal(entryId)
        })

      })

      describe('when the given id is the zero id', function () {
        const to = ZERO_ID

        it('reverts', async function () {
          await expectRevert(ownableRegistry.mint(to, entryId))
        })
      })
    })

    describe('when the given entry ID was already tracked by this contract', function () {
      const entryId = _firstEntryId

      it('reverts', async function () {
        await expectRevert(ownableRegistry.mint(5, entryId))
      })
    })
  })

})