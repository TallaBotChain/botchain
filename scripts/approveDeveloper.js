require('babel-register')
require('babel-polyfill')

const Eth = require('ethjs')
const botCoinJSON = require('../build/contracts/BotCoin.json')
const developerRegistryDelegateJSON = require('../build/contracts/DeveloperRegistryDelegate.json')

const eth = new Eth(new Eth.HttpProvider('http://localhost:8545'))

const metadata = new Buffer('{"some":"thing"}');
const url = new Buffer('https://something.com');

const tallaAddress = '0x547C0A0e61c41d8948251C02241df6FD4e860EcD'
const botCoinAddress = '0x337bA7e4F7e86F429494D7196b7c122918f31f48'
const developerRegistryAddress = '0x877005c049a458294d3c063d2b5e48485c0900a9'

const token = eth.contract(botCoinJSON.abi).at(botCoinAddress)
const developerRegistry = eth.contract(developerRegistryDelegateJSON.abi).at(developerRegistryAddress)
const approve_cost = 1*10**18;

run()

async function run () {
  await token.approve(developerRegistryAddress, approve_cost, {from: tallaAddress})
  await developerRegistry.grantApproval(2, {from: tallaAddress})
}

async function transferOwners () {
  const accounts = await eth.accounts()
  console.log((await token.balanceOf(accounts[0]))[0].toString())
  await token.approve(developerRegistryAddress, 1*10**18,{from: accounts[0]})
  await developerRegistry.addDeveloper(metadata,url,{from: accounts[0]})
}

async function logOwners () {
  let supply = await token.totalSupply()
  console.log('Total Supply: '+supply[0].toString())
}

async function sendBotcoin () {
  const accounts = await eth.accounts()
  console.log(accounts)

  // transfer botcoin
  await logBalances()
  await token.transfer(tallaAddress, new Eth.BN('1000000000000000000000000000'), { from: accounts[2] })
}

async function logBalances () {
  const initBal = await token.balanceOf()
  const tallaBal = await token.balanceOf(tallaAddress)
  console.log('init address balance: ', initBal[0].toString())
  console.log('talla address balance: ', tallaBal[0].toString())
}

/*
{
  "BotCoin": " 0x337bA7e4F7e86F429494D7196b7c122918f31f48",
  "DeveloperRegistry": "0x877005c049a458294d3c063d2b5e48485c0900a9",
  "BotProductRegistry": "0x2b044c8a463bc52716d9818b56505c0ea1273f5a",
  "BotServiceRegistry": "0x00be80cb8fe2c0df6462d4eaef2ecbf6dc28541a",
  "BotInstanceRegistry": "0x4728e0a668df2aa10fcedf954228b775cdd45c21",
  "DeveloperRegistryDelegate": "0xabcb3295bcb6bab93839eb12cb56ab6b2cba7f2e",
  "BotProductRegistryDelegate": "0x18cb05796cdcb886e5c4f6c7223df86e29d7320c",
  "BotServiceRegistryDelegate": "0x894ff5b5ba6508061ed4a22d1c11bfa987ceecc4",
  "BotInstanceRegistryDelegate": "0x4bfd1828a620f3303d358a80bc2eb5f9492e640f"
}
*/
