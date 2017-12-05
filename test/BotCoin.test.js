/* globals contract beforeEach it artifacts expect */

import { expect } from 'chai'

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
  const shrmp = await tryAsync(BotCoin.new())
  return shrmp
}

async function tryAsync (asyncFn) {
  try {
    return await asyncFn
  } catch (err) {
    console.error(err)
  }
}
