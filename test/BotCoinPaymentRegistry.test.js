/* global describe it beforeEach contract */

import { expect } from 'chai'
import { web3 } from './helpers/w3'
import expectRevert from './helpers/expectRevert'
import { hasEvent } from './helpers/event'
import newDeveloperRegistry from './helpers/newDeveloperRegistry'
const BotCoin = artifacts.require('BotCoin')

const { accounts } = web3.eth
const zeroAddr = '0x0000000000000000000000000000000000000000'
const zeroHash = '0x0000000000000000000000000000000000000000000000000000000000000000'
const addr = '0x72c2ba659460151cdfbb3cd8005ae7fbe68191b1'
const tallaWalletAddress = '0x1ae554eea0dcfdd72dcc3fa4034761cf6d041bf3'

const entryPrice = 100
const nonOwnerAddr = accounts[3]
const dataHash = web3.sha3('some data to hash')
const url = web3.fromAscii('www.google.com')

contract('BotCoinPaymentRegistry', () => {
  let bc, botCoin

  beforeEach(async () => {
    botCoin = await BotCoin.new()
    bc = await newDeveloperRegistry(botCoin.address, tallaWalletAddress, entryPrice)
    await botCoin.transfer(accounts[2], entryPrice)
    await botCoin.approve(bc.address, entryPrice, { from: accounts[2] })
  })

  describe('transferFrom()', () => {
    describe('when given a valid payment', () => {
      let txResult

      beforeEach(async () => {
        txResult = await bc.addDeveloper(dataHash, url, { from: accounts[2] })
      })

      it('should not revert', async () => {
        //const data = await bc.developerDataHash(1)
        //expect(data).to.equal(dataHash)
      })

      
    })
  })  
  
})
