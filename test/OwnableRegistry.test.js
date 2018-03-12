/* global describe it artifacts beforeEach */

import { expect } from 'chai'
import { web3 } from './helpers/w3'
import expectRevert from './helpers/expectRevert'

const BigNumber = web3.BigNumber
const PublicStorage = artifacts.require('PublicStorage.sol')
const ERC721Token = artifacts.require('ERC721TokenKeyedMock.sol')

const { accounts } = web3.eth

const BaseStorage = artifacts.require('BaseStorage')
const OwnableRegistry = artifacts.require('OwnableRegistry')


describe.only('OwnableRegistry', () => {
  let token = null
  const _firstTokenId = 1
  const _secondTokenId = 2
  const _unknownTokenId = 3
  const _creator = accounts[0]
  const ZERO_ADDRESS = '0x0000000000000000000000000000000000000000'

  beforeEach(async function () {
    const storage = await PublicStorage.new()
    token = await ERC721Token.new(storage.address, { from: _creator })
    await token.mint(_creator, _firstTokenId, { from: _creator })
    await token.mint(_creator, _secondTokenId, { from: _creator })
  })

  describe('totalSupply', function () {
    it('has a total supply equivalent to the inital supply', async function () {
      const totalSupply = await token.totalSupply()
      totalSupply.should.be.bignumber.equal(2)
    })
  })

  describe('balanceOf', function () {
    describe('when the given address owns some tokens', function () {
      it('returns the amount of tokens owned by the given address', async function () {
        const balance = await token.balanceOf(_creator)
        balance.should.be.bignumber.equal(2)
      })
    })

    describe('when the given address does not own any tokens', function () {
      it('returns 0', async function () {
        const balance = await token.balanceOf(accounts[1])
        balance.should.be.bignumber.equal(0)
      })
    })
  })

  describe('ownerOf', function () {
    describe('when the given token ID was tracked by this token', function () {
      const tokenId = _firstTokenId

      it('returns the owner of the given token ID', async function () {
        const owner = await token.ownerOf(tokenId)
        owner.should.be.equal(_creator)
      })
    })

    describe('when the given token ID was not tracked by this token', function () {
      const tokenId = _unknownTokenId

      it('reverts', async function () {
        await expectRevert(token.ownerOf(tokenId))
      })
    })
  })

  describe('mint', function () {
    describe('when the given token ID was not tracked by this contract', function () {
      const tokenId = _unknownTokenId

      describe('when the given address is not the zero address', function () {
        const to = accounts[1]

        it('mints the given token ID to the given address', async function () {
          const previousBalance = await token.balanceOf(to)

          await token.mint(to, tokenId)

          const owner = await token.ownerOf(tokenId)
          owner.should.be.equal(to)

          const balance = await token.balanceOf(to)
          balance.should.be.bignumber.equal(previousBalance + 1)
        })

        it('adds that token to the token list of the owner', async function () {
          await token.mint(to, tokenId)

          const tokens = await token.tokensOf(to)
          tokens.length.should.be.equal(1)
          tokens[0].should.be.bignumber.equal(tokenId)
        })

        it('emits a transfer event', async function () {
          const { logs } = await token.mint(to, tokenId)

          logs.length.should.be.equal(1)
          logs[0].event.should.be.eq('Transfer')
          logs[0].args._from.should.be.equal(ZERO_ADDRESS)
          logs[0].args._to.should.be.equal(to)
          logs[0].args._tokenId.should.be.bignumber.equal(tokenId)
        })
      })

      describe('when the given address is the zero address', function () {
        const to = ZERO_ADDRESS

        it('reverts', async function () {
          await expectRevert(token.mint(to, tokenId))
        })
      })
    })

    describe('when the given token ID was already tracked by this contract', function () {
      const tokenId = _firstTokenId

      it('reverts', async function () {
        await expectRevert(token.mint(accounts[1], tokenId))
      })
    })
  })

})