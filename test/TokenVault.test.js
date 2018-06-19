/* global describe it beforeEach contract */

import { expect } from 'chai'
import { web3 } from './helpers/w3'
import isNonZeroAddress from './helpers/isNonZeroAddress'
import expectRevert from './helpers/expectRevert'
import { hasEvent } from './helpers/event'

const PublicStorage = artifacts.require('PublicStorage')
const BotCoin = artifacts.require('BotCoin')
const TokenVault = artifacts.require('MockTokenVault')
const CurationCouncil = artifacts.require('MockCurationCouncil')

const zeroAddr = '0x0000000000000000000000000000000000000000'

contract('TokenVault', () => {
  let tokenVault, tokenVaultDelegate, botcoin, publicStorage, curationCouncil
  let accounts, arbiter, owner, curator, voter

  before(async () => {
    // We're relying on deterministic addr generation, if you add
    // any new contracts add them to the end of the list.
    accounts = await web3.eth.getAccounts()
    owner = accounts[0]
    arbiter = accounts[1]
    curator = accounts[2]
    voter = accounts[3]
    publicStorage = await PublicStorage.new({from: owner})
    botcoin = await BotCoin.new({from:owner})
    curationCouncil = await CurationCouncil.new(publicStorage.address, botcoin.address, {from:owner})
    tokenVault = await TokenVault.new(
	    publicStorage.address, 
	    curationCouncil.address, 
	    botcoin.address,{from:owner}
    )
  })

  beforeEach(async () => { })
  afterEach(async () => { })

  describe('publicStorage', () => {
    it('address should be 0x3d627fe11843ef6b3d5ec6683d53bd9822696ef6', async () => {
      expect(publicStorage.address).to.equal('0x3d627fe11843ef6b3d5ec6683d53bd9822696ef6')
    })
  })

  describe('curationCouncil', () => {
    it('address should be 0x0237443359ab0b11ecdc41a7af1c90226a88c70f', async () => {
      expect(curationCouncil.address).to.equal('0x0237443359ab0b11ecdc41a7af1c90226a88c70f')
    })
    it('TokenVault should be 0x0000000000000000000000000000000000000000', async () => {
      curationCouncil.tokenVault.call({from: owner}).then((ctv) => {
        expect(ctv).to.equal(zeroAddr)
      })
    })
    it('can add token vault', async () => {
      curationCouncil.changeTokenVault(tokenVault.address, {from: owner})
        .then(() => {
          return curationCouncil.tokenVault.call({from: owner})
        }).then((ctv) => {
          expect(ctv).to.equal(tokenVault.address)
        })
    })
  })

  describe('botcoin', () => {
    it('address should be 0x28b291e74bce603004b52921ec9ad3ddb6f85e44', async () => {
      expect(botcoin.address).to.equal('0x28b291e74bce603004b52921ec9ad3ddb6f85e44')
    })
  })

  describe('tokenVault', () => {

    it('address should be 0xb12d6112d64b213880fa53f815af1f29c91cace9', async () => {
      expect(tokenVault.address).to.equal('0xb12d6112d64b213880fa53f815af1f29c91cace9')
    })

    it('owner can set curator reward rate', async () => {
      let new_rate = 1
      tokenVault.setCuratorRewardRate(new_rate, {from:owner})
        .then(() => {
          return tokenVault.curatorRewardRate.call()
        })
        .then((rate) => {
          expect(rate.toNumber()).to.equal(new_rate)
        })
    })

    it('received 10,000 BOTC', async () => {
      let token_count = 10;
      botcoin.transfer(tokenVault.address, token_count, {from: owner})
      .then(() => {
        return botcoin.balanceOf(tokenVault.address)
      })
      .then((balance) => {
        expect(balance.toNumber()).to.equal(token_count)
      })
    })

    it('curationCouncil can apply reward for curator', async () => {
      let initial_balance
      tokenVault.balance.call({from:voter})
        .then((_initial_balance) => {
          initial_balance = _initial_balance;
          return curationCouncil.vote({from: voter})
        })
        .then(() => {
          return tokenVault.balance({from: voter})
        })
        .then((final_balance) => {
          expect(initial_balance.toNumber()).to.be.lessThan(final_balance.toNumber())
        })
    })
  })
})
