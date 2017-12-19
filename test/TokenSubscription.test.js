/* global describe it beforeEach artifacts contract */

import { expect } from 'chai'
import { web3 } from './helpers/w3'
import moment from 'moment'
import lkTestHelpers from 'lk-test-helpers'
import tryAsync from './helpers/tryAsync'
import expectRevert from './helpers/expectRevert'
import { hasEvent } from './helpers/event'
import isNonZeroAddress from './helpers/isNonZeroAddress'

// TODO set duration and maxSubscriptionLength to appropriate time
const { increaseTime, latestTime } = lkTestHelpers(web3)
const { accounts } = web3.eth


const cost = 100 // in ether
const currentTime = 2
const duration = 1 // in weeks
const maxSubscriptionLength = 4
const payment = 100 // in ether
// const subscriber = '0x72c2ba659460151cdfbb3cd8005ae7fbe68191b1'
const subscriber = accounts[1]
const nonSubscriber = '0x85626d4d9a5603a049f600d9cfef23d28ecb7b8b'
const wallet = '0x319f2c0d4e7583dff11a37ec4f2c907c8e76593a'

const BotCoin = artifacts.require('./BotCoin.sol')
const TokenSubscription = artifacts.require('./TokenSubscription.sol')

contract('TokenSubscription', () => {
  let tokenSubscription
  let botCoin

  beforeEach(async () => {
    // TODO fix passing in token
    // botCoin = await newBotCoin();
    tokenSubscription = await newTokenSubscription()
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
    describe('when extending an existing subscriber', () => {
      let txResult

      beforeEach(async () => {
        // Setting up the contract to be in the right state
        await tokenSubscription.extend(payment, { from: subscriber })
        txResult = await tokenSubscription.extend(payment, { from: subscriber} )
      })

      it('should extend existing subscriber subscription correctly', async () => {
        let endTime = (await tokenSubscription.subscriptionEndTimes.call(subscriber)).toNumber()
        // TODO figure out how to handle time
        const defaultTime = await defaultEndTime()
        expect(endTime).to.equal(moment(defaultTime.add(24 * 7, 'hours')).unix())
      })

      it('should require timeToExtend plus time remaining in the current subscription to be less than maxSubscriptionLength', async () => {
        const bigPayment = 5 * payment
        await expectRevert(tokenSubscription.extend.call(bigPayment, { from: subscriber}))
      })

      // TODO Implement after figuring out ERC20
      // it('forwards funds correctly', async () => {
      //   // expect balance in wallet to increase by payment
      //   // TODO figure out how to get balance of the wallet; why is below returning an address?
      //   expect(await tokenSubscription.wallet.balance.call()).to.equal(payment)
      // })
    })

    describe('when extending a new subscriber', () => {
     
      it('should set the subscription correctly', async () => {
        await tokenSubscription.extend(payment, { from: subscriber })
        let endTime = (await tokenSubscription.subscriptionEndTimes.call(subscriber)).toNumber()
        const validEndTime = await defaultEndTime()
        expect(endTime).to.equal(moment(validEndTime).unix())
      })

      it('should require timeToExtend to be less than maxSubscriptionLength', async () => {
        // set payment to an amount that would cause the extending of the subscription to be greater than maxSubscriptionLength
        const bigPayment = 5 * payment
        await expectRevert(tokenSubscription.extend.call(bigPayment, { from: subscriber}))
      })

      // TODO Implement after figuring out ERC20
      // it('forwards funds correctly', async () => {
      //   // expect balance in wallet to increase by payment
      //   // TODO figure out how to get balance of the wallet
      //   // expect(await tokenSubscription.wallet.call()).to.equal(payment)
      // })
    })
  })

  describe('checkRegistration()', () => {
    let txResult
    
    beforeEach(async () => {
      await tokenSubscription.extend(payment, { from: subscriber })
    })

    describe('when checking whether a registered subscriber exists', () => {
      it('should return true', async () => {
        txResult = await tokenSubscription.checkRegistration.call(subscriber)
        expect(txResult).to.equal(true)
      })    
    })

    describe('when checking whether an unregistered subscriber exists', () => {
      it('should return false', async () => {
        txResult = await tokenSubscription.checkRegistration.call(nonSubscriber)
        expect(txResult).to.equal(false)
      })    
    })
  })

  describe('checkStatus()', () => {

  })

  describe('checkExpiration()', () => {
    
  })

  describe('forwardFunds()', () => {
    
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

let _latestTime // a moment() object

async function defaultEndTime () {
  if (!_latestTime) {
    _latestTime = await latestTime()
  }
  return moment(_latestTime).add(24 * 7, 'hours')
}

