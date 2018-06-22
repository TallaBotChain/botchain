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
  let vault_balance, reward_rate

  before(async () => {

    // We're relying on deterministic addr generation, if you add
    // any new contracts add them to the end of the list.
    accounts = await web3.eth.getAccounts()
    owner = accounts[0]
    arbiter = accounts[1]
    curator = accounts[2]
    voter = accounts[3]
    reward_rate = 1
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
      return curationCouncil.tokenVault.call({from: owner})
        .then((ctv) => {
          expect(ctv).to.equal(zeroAddr)
        })
    })
    it('can add token vault', async () => {
      return curationCouncil.changeTokenVault(tokenVault.address, {from: owner})
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
      return tokenVault.setCuratorRewardRate(reward_rate, {from:owner})
        .then(() => {
          return tokenVault.curatorRewardRate.call()
        })
        .then((rate) => {
          expect(rate.toNumber()).to.equal(reward_rate)
        })
    })

    it('owner can set developer reward rate', async () => {
      return tokenVault.setDeveloperRewardRate(reward_rate, {from:owner})
        .then(() => {
          return tokenVault.developerRewardRate.call()
        })
        .then((rate) => {
          expect(rate.toNumber()).to.equal(reward_rate)
        })
    })

    it('received 10,000 BOTC', async () => {
      let token_count = 10000;
      return botcoin.transfer(tokenVault.address, token_count, {from: owner})
        .then(() => {
          return botcoin.balanceOf(tokenVault.address)
        })
        .then((balance) => {
          vault_balance = balance.toNumber()
          expect(balance.toNumber()).to.equal(token_count)
        })
    })

    it('curationCouncil can apply reward for curator', async () => {
      let initial_balance
      return tokenVault.balance.call({from:voter})
        .then((_initial_balance) => {
          initial_balance = _initial_balance;
          return curationCouncil.vote({from: voter})
        })
        .then(() => {
          console.log('bullshit')
          return tokenVault.balance.call({from: voter})
        })
        .then((final_balance) => {
          console.log('bullshit2:',final_balance)
          expect(initial_balance.toNumber()).to.be.lessThan(final_balance.toNumber())
        })
    })

    it('voter can collect rewards', async () => {
      let wallet_balance
      return tokenVault.balance.call({from:voter})
        .then((_vault_balance) => {
          expect(_vault_balance.toNumber()).to.equal(reward_rate)
          return botcoin.balanceOf.call(voter)
        })
        .then((_wallet_balance) => {
          wallet_balance = _wallet_balance
          return tokenVault.collectCuratorReward({from:voter})
        })
        .then(() => {
          return tokenVault.balance.call({from:voter})
        })
        .then((_user_vault_balance) => {
          // Rewards have been collected to wallet, the users vault
          // balance should be empty.
          expect(_user_vault_balance.toNumber()).to.equal(0)
          return botcoin.balanceOf.call(voter)
        })
        .then((_wallet_balance) => {
          expect(_wallet_balance.toNumber()).to.be.greaterThan(wallet_balance.toNumber())
        })
    })

    it('vault balance updated correctly', async () => {
      return botcoin.balanceOf(tokenVault.address)
        .then((balance) => {
          expect(balance.toNumber()).to.equal(vault_balance - reward_rate)
        })
    })
  })
})
