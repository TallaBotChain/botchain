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

const BasicSubscription = artifacts.require('./BasicSubscription.sol')

contract('BasicSubscription', () => {
  let basicSubscription

  beforeEach(async () => {
    basicSubscription = await newBasicSubscription();
  })

  describe('setParameters()', () => {
    describe('when given valid parameters', () => {
      let txResult

      beforeEach(async () => {
        txResult = await basicSubscription.setParameters(cost, duration, maxSubscription)
      })

      it('should set the cost', async () => {
        expect((await basicSubscription.cost.call()).toNumber()).to.equal(cost)
      })

      it('should set the duration', async () => {
        expect((await basicSubscription.duration.call()).toNumber()).to.equal(cost)
      })

      it('should set the maxSubscription', async () => {
        expect((await basicSubscription.maxSubscription.call()).toNumber()).to.equal(cost)
      })
    })
  })

})

async function newBasicSubscription () {
  const basicSubscription = await tryAsync(BasicSubscription.new())
  return basicSubscription
}
