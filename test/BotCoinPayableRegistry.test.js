/* global describe it beforeEach contract */

import { expect } from 'chai'
import { web3 } from './helpers/w3'
import isNonZeroAddress from './helpers/isNonZeroAddress'
import expectRevert from './helpers/expectRevert'
import { hasEvent } from './helpers/event'
import newDeveloperRegistry from './helpers/newDeveloperRegistry'

const PublicStorage = artifacts.require('./PublicStorage.sol')
const BotCoin = artifacts.require('BotCoin')
const MockBotCoinPayableRegistry = artifacts.require('MockBotCoinPayableRegistry')

const zeroAddr = '0x0000000000000000000000000000000000000000'
const tallaWalletAddress = '0x1ae554eea0dcfdd72dcc3fa4034761cf6d041bf3'
const entryPrice = 100

contract('BotCoinPayableRegistry', () => {
  let botCoinPayableRegistry, botCoin
  let accounts

  beforeEach(async () => {
    const publicStorage = await PublicStorage.new()
    botCoin = await BotCoin.new()
    accounts = await web3.eth.getAccounts()
    await botCoin.transfer(accounts[1], entryPrice)
    botCoinPayableRegistry = await MockBotCoinPayableRegistry.new(
      publicStorage.address,
      botCoin.address
    )
  })

  describe('setTallaWallet()', () => {
    describe('when given a valid address', () => {
      it('should set tallaWallet', async () => {
        await botCoinPayableRegistry.setTallaWallet(tallaWalletAddress)
        expect(await botCoinPayableRegistry.tallaWallet()).to.equal(tallaWalletAddress)
      })
    })

    describe('when given a zero address', () => {
      it('should revert', async () => {
        await expectRevert(botCoinPayableRegistry.setTallaWallet(zeroAddr))
      })
    })
  })

  describe('setEntryPrice()', () => {
    describe('when given a valid uint256', () => {
      it('should set entryPrice', async () => {
        await botCoinPayableRegistry.setEntryPrice(entryPrice)
        expect(
          (await botCoinPayableRegistry.entryPrice()).toNumber()
        ).to.equal(entryPrice)
      })
    })
  })

  describe('botCoin()', () => {
    it('should return a valid address', async () => {
      expect(isNonZeroAddress(await botCoinPayableRegistry.botCoin())).to.equal(true)
    })
  })

  describe('transferBotCoin()', () => {
    it('should transfer entry price from the sender to talla wallet', async () => {
      await botCoinPayableRegistry.setTallaWallet(tallaWalletAddress)
      await botCoinPayableRegistry.setEntryPrice(entryPrice)
      await botCoin.approve(botCoinPayableRegistry.address, entryPrice, { from: accounts[1] })
      await botCoinPayableRegistry.makePayment({ from: accounts[1] })
      expect(
        (await botCoin.balanceOf(accounts[1])).toNumber()
      ).to.equal(0)
    })
  })
})
