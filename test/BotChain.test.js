/* global describe it beforeEach artifacts contract */

import { expect } from 'chai'
import { web3 } from './helpers/w3'
import tryAsync from './helpers/tryAsync'
import isNonZeroAddress from './helpers/isNonZeroAddress'

const BotChain = artifacts.require('./BotChain.sol')
const { accounts } = web3.eth

contract('BotChain', () => {
  describe('when deployed', () => {
    let bc
    beforeEach(async () => {
      bc = await newBotChain()
    })

    it('should create a new BotManagerOwernship contract', async () => {
      const addr = await bc.botOwnershipManager.call()
      expect(isNonZeroAddress(addr)).to.equal(true)
    })
  })

  describe('addDeveloper()', () => {
    describe('when given a valid address and valid hash', () => {
      it('should add developer to mapping', async () => {
        //
      })
    })

    describe('when given an invalid hash', () => {
      it('should throw', async () => {
        //
      })
    })

    describe('when called by non-owner', () => {
      it('should throw', async () => {
        //
      })
    })

    describe('when given a 0x0 address', () => {
      it('should throw', async () => {
        //
      })
    })
  })

  describe('updateDeveloper()', () => {
    describe('when given a valid address and valid hash', () => {
      it('should update hash value in mapping', async () => {
        //
      })
    })

    describe('when given an invalid hash', () => {
      it('should throw', async () => {
        //
      })
    })

    describe('when called by non-owner', () => {
      it('should throw', async () => {
        //
      })
    })

    describe('when given a 0x0 address', () => {
      it('should throw', async () => {
        //
      })
    })
  })

  describe('removeDeveloper()', () => {
    describe('when given a valid address that exists in mapping', () => {
      it('should set mapping value for address to 0x0', async () => {
        //
      })
    })

    describe('when called by non-owner', () => {
      it('should throw', async () => {
        //
      })
    })

    describe('when given a 0x0 address', () => {
      it('should throw', async () => {
        //
      })
    })

    describe('when address does not exist in developer mapping', () => {
      it('should throw', async () => {
        //
      })
    })
  })
})

async function newBotChain () {
  const bc = await tryAsync(BotChain.new())
  return bc
}
