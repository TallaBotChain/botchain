require('babel-register')
require('babel-polyfill')

const Eth = require('ethjs')
const fs = require("fs");
const Web3 = require('web3');

const botCoinJSON = require('../build/contracts/BotCoin.json')
const developerRegistryDelegateJSON = require('../build/contracts/DeveloperRegistryDelegate.json')
const botProductRegistryDelegateJSON = require('../build/contracts/BotProductRegistryDelegate.json')
const botServiceRegistryDelegateJSON = require('../build/contracts/BotServiceRegistryDelegate.json')
const botInstanceRegistryDelegateJSON = require('../build/contracts/BotInstanceRegistryDelegate.json')
const botInstanceRegistryUpgradeJSON = require('../build/contracts/OwnableProxy.json')

const eth = new Eth(new Eth.HttpProvider('http://localhost:8545'))

const mikecKovanAddress = '0x54d0c0F6C8EEdB71AEc9A7c26e93Ec6C24bb0c1a'
const tallaAddress = '0x547C0A0e61c41d8948251C02241df6FD4e860EcD'
const botCoinAddress = '0x337bA7e4F7e86F429494D7196b7c122918f31f48'
const developerRegistryAddress = '0x877005c049a458294d3c063d2b5e48485c0900a9'
const botProductRegistryAddress = '0x2b044c8a463bc52716d9818b56505c0ea1273f5a'
const botInstanceRegistryAddress = '0x00be80cb8fe2c0df6462d4eaef2ecbf6dc28541a'
const botServiceRegistryAddress = '0x4728e0a668df2aa10fcedf954228b775cdd45c21'

const token = eth.contract(botCoinJSON.abi).at(botCoinAddress)
const developerRegistry = eth.contract(developerRegistryDelegateJSON.abi).at(developerRegistryAddress)
const botProductRegistry = eth.contract(botProductRegistryDelegateJSON.abi).at(botProductRegistryAddress)
const botServiceRegistry = eth.contract(botInstanceRegistryDelegateJSON.abi).at(botServiceRegistryAddress)
const botInstanceRegistry = eth.contract(botServiceRegistryDelegateJSON.abi).at(botInstanceRegistryAddress)
const botInstanceUpgrade = eth.contract(botServiceRegistryDelegateJSON.abi).at(botInstanceRegistryAddress)

const web3 = new Web3();
web3.setProvider(new web3.providers.HttpProvider('http://localhost:8545'));

// ABI description as JSON structure
let abi = JSON.parse(developerRegistryDelegateJSON.abi);

// Create Contract proxy class
let SampleContract = web3.eth.contract(abi);

// Unlock the coinbase account to make transactions out of it
console.log("Unlocking coinbase account");
var password = "Ender919485";
try {
  web3.personal.unlockAccount(web3.eth.coinbase, password);
} catch(e) {
  console.log(e);
  return;
}

console.log("Deploying the contract");
let contract = SampleContract.new({from: web3.eth.coinbase, gas: 1000000, data: code});

// Transaction has entered to geth memory pool
console.log("Your contract is being deployed in transaction at http://testnet.etherscan.io/tx/" + contract.transactionHash);

// http://stackoverflow.com/questions/951021/what-is-the-javascript-version-of-sleep
function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

// We need to wait until any miner has included the transaction
// in a block to get the address of the contract
async function waitBlock() {
  while (true) {
    let receipt = web3.eth.getTransactionReceipt(contract.transactionHash);
    if (receipt && receipt.contractAddress) {
      console.log("Your contract has been deployed at http://testnet.etherscan.io/address/" + receipt.contractAddress);
      console.log("Note that it might take 30 - 90 sceonds for the block to propagate befor it's visible in etherscan.io");
      break;
    }
    console.log("Waiting a mined block to include your contract... currently in block " + web3.eth.blockNumber);
    await sleep(4000);
  }
}

waitBlock();
