/* global describe it beforeEach contract artifacts */

import { expect } from 'chai'
import { web3 } from './helpers/w3'
import expectRevert from './helpers/expectRevert'
import { hasEvent } from './helpers/event'
import newCurationCouncil from './helpers/newCurationCouncil'
const BotCoin = artifacts.require('BotCoin')
const TokenVault = artifacts.require('MockTokenVault')
const PublicStorage = artifacts.require('PublicStorage')

contract('CurationCouncilRegistry', () => {
  let cc, botCoin, accounts, tv, publicStorage

  beforeEach(async () => {
    accounts = await web3.eth.getAccounts()
    botCoin = await BotCoin.new()
    publicStorage = await PublicStorage.new()
    tv = await TokenVault.new(publicStorage.address, 0x0, botCoin.address)
    cc = await newCurationCouncil(botCoin.address, publicStorage.address, tv.address)
    await tv.changeArbiter(cc.address)
    await tv.setCuratorRewardRate(165)
    await botCoin.transfer(accounts[2], 10000000000)
    await botCoin.transfer(tv.address, 10000000)
  })

  describe('joinCouncil() with valid botCoin stake amount', () => {
    it('stake amount should be added', async () => {
      await botCoin.approve(cc.address, 500, { from: accounts[2]} )
      await cc.joinCouncil(500, { from: accounts[2] })
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
    let createVoteTxResult
    beforeEach(async () => {
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
        // await tv.applyCuratorReward({from: accounts[2]})
        const newBal = await tv.balance({from: accounts[2]})
        const _curatorReward = await tv.reservedBalance.call()
        console.log(_curatorReward.toNumber())
        console.log(newBal.toNumber())
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

      it('should revert if council member attempts to vote twice', async () => {
        await expectRevert(cc.castRegistrationVote(1, false, { from: accounts[2]} ))
      })
    })
  })
})
