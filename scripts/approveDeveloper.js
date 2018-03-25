var Web3 = require("web3");

const providerUrl = "https://localhost:8545";
const web3Provider = new Web3.providers.HttpProvider(providerUrl);
const web3 = new Web3(web3Provider);

const accounts = web3.eth.accounts;

const botCoinJSON = require('./build/contracts/BotCoin.json')
const token = new web3.eth.Contract(botcoinJson.abi,'0x337bA7e4F7e86F429494D7196b7c122918f31f48')

async function logBalances() {
   let totalSupply = await token.totalSupply()
   console.log('Botcoin Total Supply: '+ totalSupply.toString())
}

