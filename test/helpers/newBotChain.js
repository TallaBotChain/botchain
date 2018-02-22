/* globals artifacts */

import _ from 'lodash'

const PublicStorage = artifacts.require('./PublicStorage.sol')
const BotChain = artifacts.require('./BotChain.sol')
const BotChainDelegate = artifacts.require('./BotChainDelegate.sol')

export default async function newBotChain () {
  const publicStorage = await PublicStorage.new()
  const botChainDelegate = await BotChainDelegate.new()
  let botChain = await BotChain.new(
    publicStorage.address,
    botChainDelegate.address
  )
  botChain = _.extend(botChain, await BotChainDelegate.at(botChain.address))
  return botChain
}
