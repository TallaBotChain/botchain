/* global describe it beforeEach contract */

import { expect } from 'chai'
import { web3 } from './helpers/w3'
import isNonZeroAddress from './helpers/isNonZeroAddress'
import expectRevert from './helpers/expectRevert'
import { hasEvent } from './helpers/event'
import newDeveloperRegistry from './helpers/newDeveloperRegistry'

const PublicStorage = artifacts.require('PublicStorage')
const BotCoin = artifacts.require('BotCoin')
const TokenVault = artifacts.require('TokenVaultDelegate')
const CurationCouncil = artifacts.require('MockCurationCouncil')

const zeroAddr = '0x0000000000000000000000000000000000000000'
const entryPrice = 100

contract('TokenVault', () => {
  let tokenVault, botcoin, publicStorage, curationCouncil
  let accounts, arbiter, owner, curator, voter

  before(async () => {
    // We're relying on deterministic addr generation, if you add
    // any new contracts add them to the end of the list.
    accounts = await web3.eth.getAccounts()
    owner = accounts[0]
    arbiter = accounts[1]
    curator = accounts[2]
    voter = accounts[3]
    publicStorage = await PublicStorage.new()
    botcoin = await BotCoin.new()
    curationCouncil = await CurationCouncil.new(publicStorage.address)
    tokenVault = await TokenVault.new(publicStorage.address, arbiter)
  })

  describe('publicStorage', () => {
    it('address should be 0x3d627fe11843ef6b3d5ec6683d53bd9822696ef6', async () => {
      expect(publicStorage.address).to.equal('0x3d627fe11843ef6b3d5ec6683d53bd9822696ef6')
    })
  })

  describe('curationCouncil', () => {
    it('address should be 0x0237443359ab0b11ecdc41a7af1c90226a88c70f', async () => {
      expect(curationCouncil.address).to.equal('0x0237443359ab0b11ecdc41a7af1c90226a88c70f')
    })
    it('can add token vault', async () => {
      await curationCouncil.changeTokenVault(tokenVault.address, {from:owner})
      let ctv = await curationCouncil.tokenVault()
      expect(ctv).to.equal(tokenVault.address)
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
    it('curationCouncil can apply reward for curator', async () => {
      let init_balance = await tokenVault.balance({from: voter})
      console.log('initial balance:',init_balance)
      await curationCouncil.vote({from: voter})
      let final_balance = await tokenVault.balance({from: voter})
      console.log('final balance:',final_balance)
      expect(init_balance).to.be.lessThan(final_balance)
    })
  })
})
