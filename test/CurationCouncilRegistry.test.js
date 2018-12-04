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
    await botCoin.transfer(accounts[4], 2000000)
    await botCoin.transfer(tv.address, 10000000)
  })

  describe('joinCouncil() with valid botCoin stake amount', () => {
    beforeEach(async () => {
      await cc.setMinStake(500, { from: accounts[0]})
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

    it('totalMembers should return 2 and totalVotes should return 0', async () => {
      await botCoin.approve(cc.address, 10000, { from: accounts[4]} )
      await cc.joinCouncil(10000, { from: accounts[4] })
      const memberTotalSupply = await cc.totalMembers()
      expect(memberTotalSupply.toNumber()).to.equal(2)
      const voteTotalSupply = await cc.totalVotes()
      expect(voteTotalSupply.toNumber()).to.equal(0)
    })

    it('should revert if stake amount is less than minimum', async() => {
      await cc.setMinStake(1000, { from: accounts[0]})
      await botCoin.approve(cc.address, 500, { from: accounts[3]} )
      expectRevert(cc.joinCouncil(500, {from: accounts[3]} ))
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
      await botCoin.approve(cc.address, 500, { from: accounts[2]} )
      await cc.joinCouncil(500, { from: accounts[2] })
      await cc.setAutoApproveThreshold(200, { from: accounts[0] })
      await botCoin.approve(developerRegistry.address, 10000, { from: accounts[3]} )
      await developerRegistry.addDeveloper('0x7d5a99f603f231d53a4f39d1521f98d2e8bb279cf29bebfd0687dc98458e7f89', '12', '20', { from: accounts[3]} )
      await cc.setVoteWindowBlocks(100000, { from: accounts[0]} )
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
      it('should setVotedOnStatus to true', async () => {
        await cc.castRegistrationVote(1, true, { from: accounts[2]} )
        expect(await cc.getVotedOnStatus(1, accounts[2], {from: accounts[2]})).to.equal(true)
      })

      it('totalVotes should return 1', async() => {
        await cc.castRegistrationVote(1, true, { from: accounts[2]} )
        const voteTotalSupply = await cc.totalVotes()
        expect(voteTotalSupply.toNumber()).to.equal(1)
      })

      it('should increase yay count by stake amount', async () => {
        await cc.castRegistrationVote(1, true, { from: accounts[2]} )
        const data = await cc.getYayCount(1, {from: accounts[2]})
        expect(data.toNumber()).to.equal(500)
      })

      it('should increase balance by curation reward rate', async () => {
        await cc.castRegistrationVote(1, true, { from: accounts[2]} )
        const newBal = await tv.balance({from: accounts[2]})
        expect(newBal.toNumber()).to.equal(165)
      })

      it('should revert if council member attempts to vote twice', async () => {
        await cc.castRegistrationVote(1, true, { from: accounts[2]} )
        await expectRevert(cc.castRegistrationVote(1, true, { from: accounts[2]} ))
      })

      it('should approve developer if threshold is met', async () => {
        await cc.castRegistrationVote(1, true, { from: accounts[2]} )
        const developerAddress = await cc.getRegistrationVoteAddressById(1)
        const entryId = await developerRegistry.owns(developerAddress)
        const approvalStatus = await developerRegistry.approvalStatus(entryId)
        expect(approvalStatus).to.equal(true)
      })

      it('should not approve developer if threshold is not met', async() => {
        await cc.setAutoApproveThreshold(700, { from: accounts[0]} )
        await cc.castRegistrationVote(1, true, { from: accounts[2]} )
        const developerAddress = await cc.getRegistrationVoteAddressById(1)
        const entryId = await developerRegistry.owns(developerAddress)
        const approvalStatus = await developerRegistry.approvalStatus(entryId)
        expect(approvalStatus).to.equal(false)
      })
    })

    describe('castRegistrationVote() nay', () => {
      beforeEach(async () => {
        await cc.castRegistrationVote(1, false, { from: accounts[2]} )
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
