/* global describe it beforeEach artifacts contract */

import { expect } from 'chai'
import { web3 } from './helpers/w3'
import tryAsync from './helpers/tryAsync'
import expectRevert from './helpers/expectRevert'
import { hasEvent } from './helpers/event'
import isNonZeroAddress from './helpers/isNonZeroAddress'

const cost = 100
// TODO set duration and maxSubscription to appropriate time
const duration = 100
const maxSubscription = 100

const TokenSubscription = artifacts.require('./TokenSubscription.sol')

contract('TokenSubscription', () => {
  let tokenSubscription

  beforeEach(async () => {
    tokenSubscription = await newTokenSubscription();
  })

  describe('setParameters()', () => {
    describe('when given valid parameters', () => {
      let txResult

      beforeEach(async () => {
        txResult = await tokenSubscription.setParameters(cost, duration, maxSubscription)
      })

      it('should set the cost', async () => {
        expect((await tokenSubscription.cost.call()).toNumber()).to.equal(cost)
      })

      it('should set the duration', async () => {
        expect((await tokenSubscription.duration.call()).toNumber()).to.equal(cost)
      })

      it('should set the maxSubscription', async () => {
        expect((await tokenSubscription.maxSubscription.call()).toNumber()).to.equal(cost)
      })
    })
  })




})

async function newTokenSubscription () {
  const tokenSubscription = await tryAsync(TokenSubscription.new())
  return tokenSubscription
}
