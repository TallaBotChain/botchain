/* global describe it beforeEach artifacts contract */

import { expect } from 'chai'
import { web3 } from './helpers/w3'
import tryAsync from './helpers/tryAsync'
import expectRevert from './helpers/expectRevert'
import { hasEvent } from './helpers/event'
import isNonZeroAddress from './helpers/isNonZeroAddress'

// TODO set duration and maxSubscriptionLength to appropriate time
const cost = 100 // in ether
const duration = 1 // in months
const maxSubscriptionLength = 100
const payment = 100 // in ether
const subscriber = '0x72c2ba659460151cdfbb3cd8005ae7fbe68191b1'
const wallet = '0x319f2c0d4e7583dff11a37ec4f2c907c8e76593a'

const BotCoin = artifacts.require('./BotCoin.sol')
const TokenSubscription = artifacts.require('./TokenSubscription.sol')

contract('TokenSubscription', () => {
  let tokenSubscription
  let botCoin

  beforeEach(async () => {
    // TODO fix passing in token
    // botCoin = await newBotCoin();
    tokenSubscription = await newTokenSubscription();
  })

  describe('updateParameters()', () => {
    describe('when given valid parameters', () => {
      let txResult

      beforeEach(async () => {
        txResult = await tokenSubscription.updateParameters(cost, duration, maxSubscriptionLength)
      })

      it('should set the cost', async () => {
        expect((await tokenSubscription.cost.call()).toNumber()).to.equal(cost)
      })

      it('should set the duration', async () => {
        expect((await tokenSubscription.duration.call()).toNumber()).to.equal(duration)
      })

      it('should set the maxSubscriptionLength', async () => {
        expect((await tokenSubscription.maxSubscriptionLength.call()).toNumber()).to.equal(maxSubscriptionLength)
      })
    })
  })

  describe('extend()', () => {
    describe('when given valid parameters', () => {
      let txResult
      
      beforeEach(async () => {
        await tokenSubscription.updateParameters(cost, duration, maxSubscriptionLength)
        //  Question: How to set who is calling the function?
        txResult = await tokenSubscription.extend(payment)
      })
      
      it('should extend subscriber subscription correctly', async () => {
        let endTime = (await tokenSubscription.subscriptionEndTimes.call(subscriber)).toNumber();
        // TODO figure out how to handle time
        expect(endTime).to.equal((payment/cost) * duration);
      })
      
      it('forwards funds correctly', async () => {
        // expect(await tokenSubscription.wallet.call())
      })
    })
    
  })


})

async function newTokenSubscription () {
  const tokenSubscription = await tryAsync(TokenSubscription.new(wallet, cost, duration, maxSubscriptionLength))
  return tokenSubscription
}

async function newBotCoin () {
  const bc = await tryAsync(BotCoin.new())
  return bc
}
