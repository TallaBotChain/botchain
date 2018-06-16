/* global describe it beforeEach contract artifacts */

import { expect } from 'chai'
import { web3 } from './helpers/w3'
import expectRevert from './helpers/expectRevert'
import { hasEvent } from './helpers/event'
import newCurationCouncil from './helpers/newCurationCouncil'
const BotCoin = artifacts.require('BotCoin')

const zeroHash = '0x0000000000000000000000000000000000000000000000000000000000000000'

contract('CurationCouncilRegistry', () => {
  let cc, botCoin, accounts

  beforeEach(async () => {
    accounts = await web3.eth.getAccounts()
    botCoin = await BotCoin.new()
    cc = await newCurationCouncil(botCoin.address)
    await botCoin.transfer(accounts[2], 10000000000)
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
  
})
