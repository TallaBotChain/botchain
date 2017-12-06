/* globals contract beforeEach it artifacts */

import { expect } from 'chai'
import tryAsync from './helpers/tryAsync'

const BotCoin = artifacts.require('./BotCoin.sol')

contract('BotCoin', function (accounts) {
  let botCoin

  beforeEach(async () => {
    botCoin = await newBotCoin()
  })

  it('should have the symbol `BOT`', async function () {
    expect(await botCoin.symbol.call()).to.equal('BOT')
  })
})

async function newBotCoin () {
  const bc = await tryAsync(BotCoin.new())
  return bc
}
