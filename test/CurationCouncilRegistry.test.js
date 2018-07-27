/* global describe it beforeEach contract artifacts */

import { expect } from 'chai'
import { web3 } from './helpers/w3'
import expectRevert from './helpers/expectRevert'
import { hasEvent } from './helpers/event'
import newCurationCouncil from './helpers/newCurationCouncil'
import newDeveloperRegistry from './helpers/newDeveloperRegistry'
const BotCoin = artifacts.require('BotCoin')
const MockTokenVault = artifacts.require('MockTokenVault')
const PublicStorage = artifacts.require('PublicStorage')

contract('CurationCouncilRegistry', () => {
  let cc, botCoin, accounts, tv, publicStorage, developerRegistry

  beforeEach(async () => {
    accounts = await web3.eth.getAccounts()
    botCoin = await BotCoin.new()
    publicStorage = await PublicStorage.new()
    developerRegistry = await newDeveloperRegistry(botCoin.address, accounts[0], 10000)
    cc = await newCurationCouncil(botCoin.address, publicStorage.address)
    await cc.changeDeveloperRegistry(developerRegistry.address)
    await developerRegistry.changeArbiter(cc.address)
    tv = await MockTokenVault.new(publicStorage.address, cc.address, botCoin.address)
    await cc.changeTokenVault(tv.address)
    await tv.setCuratorRewardRate(165)
    await botCoin.transfer(accounts[2], 1000000)
    await botCoin.transfer(accounts[3], 2000000)
    await botCoin.transfer(tv.address, 10000000)
  })

  describe('joinCouncil() with valid botCoin stake amount', () => {
    beforeEach(async () => {
      await botCoin.approve(cc.address, 500, { from: accounts[2]} )
      await cc.joinCouncil(500, { from: accounts[2] })
    })
    it('stake amount should be added', async () => {
      const data = await cc.getStakeAmount(accounts[2])
      expect(data.toNumber()).to.equal(500)
    })

    it('should revert if council member attempts to joinCouncil twice', async () => {
      await botCoin.approve(cc.address, 50, { from: accounts[2]} )
      await expectRevert(cc.joinCouncil(50, { from: accounts[2] }))
      const data = await cc.getStakeAmount(accounts[2])
      expect(data.toNumber()).to.equal(500)
    })
  })

  describe('leaveCouncil() with valid botCoin stake amount', () => {
    it('stake amount should be debited', async () => {
      await cc.leaveCouncil({ from: accounts[2] })
      const data = await cc.getStakeAmount(accounts[2])
      expect(data.toNumber()).to.equal(0)
    })
  })

  describe('registrationVote', () => {
    let createVoteTxResult, id, devAddress, _totalSupply
    beforeEach(async () => {
      await botCoin.approve(developerRegistry.address, 10000, { from: accounts[3]} )
      await developerRegistry.addDeveloper("{data: 'somedata'}", 'https://example.com', { from: accounts[3]} )
      createVoteTxResult = await cc.createRegistrationVote({ from: accounts[3]} )
    })

    describe('createRegistrationVote()', () => {
      it('should log RegistrationVoteCreated event', async () => {
        expect(hasEvent(createVoteTxResult, 'RegistrationVoteCreated')).to.equal(true)
      })

      it('registrationVoteExists() should return true', async() => {
        expect(await cc.registrationVoteExists(accounts[3], {from: accounts[3]})).to.equal(true)
      })
    })

    describe('castRegistrationVote() yay', () => {
      let castVoteTxResult
      beforeEach(async () => {
        await botCoin.approve(cc.address, 500, { from: accounts[2]} )
        await cc.joinCouncil(500, { from: accounts[2] })
        castVoteTxResult = await cc.castRegistrationVote(1, true, { from: accounts[2]} )
      })
      it('should setVotedOnStatus to true', async () => {
        expect(await cc.getVotedOnStatus(1, accounts[2], {from: accounts[2]})).to.equal(true)
      })

      it('should increase yay count by stake amount', async () => {
        const data = await cc.getYayCount(1, {from: accounts[2]})
        expect(data.toNumber()).to.equal(500)
      })

      it('should increase balance by curation reward rate', async () => {
        const newBal = await tv.balance({from: accounts[2]})
        expect(newBal.toNumber()).to.equal(165)
      })

      it('should revert if council member attempts to vote twice', async () => {
        await expectRevert(cc.castRegistrationVote(1, true, { from: accounts[2]} ))
      })
    })

    describe('castRegistrationVote() nay', () => {
      let castVoteTxResult
      beforeEach(async () => {
        await botCoin.approve(cc.address, 500, { from: accounts[2]} )
        await cc.joinCouncil(500, { from: accounts[2] })
        castVoteTxResult = await cc.castRegistrationVote(1, false, { from: accounts[2]} )
      })
      it('should setVotedOnStatus to true', async () => {
        expect(await cc.getVotedOnStatus(1, accounts[2], {from: accounts[2]})).to.equal(true)
      })

      it('should increase nay count by stake amount', async () => {
        const data = await cc.getNayCount(1, {from: accounts[2]})
        expect(data.toNumber()).to.equal(500)
      })

      it('should increase balance by curation reward rate', async () => {
        const newBal = await tv.balance({from: accounts[2]})
        expect(newBal.toNumber()).to.equal(165)
      })

      it('should revert if council member attempts to vote twice', async () => {
        await expectRevert(cc.castRegistrationVote(1, false, { from: accounts[2]} ))
      })
    })
  })
})
