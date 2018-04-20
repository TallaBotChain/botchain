require('babel-register')
require('babel-polyfill')

var ArgumentParser = require('argparse').ArgumentParser;
var parser = new ArgumentParser({
  version: '0.0.1',
  addHelp: true,
  description: 'Botchain Deployment CLI'
});

parser.addArgument(
  [ '-u', '--update' ],
  {
    help: 'update the proxy contracts with the available delegates',
    nargs: 0
  }
);

parser.addArgument(
  [ '-i', '--impl' ],
  {
    help: 'Deploy a delegate of a particular type',
    choices: ['developer','bot','instance','service'],
    nargs: 1
  }
);

const args = parser.parseArgs();
console.log(args);
process.exit()

const Web3 = require('web3');
const web3 = new Web3(new web3.providers.HttpProvider('http://localhost:8545'));

const botCoinJSON                  = require('../build/contracts/BotCoin.json')
const ownableProxyJSON             = require('../build/contracts/OwnableProxy.json')
const devRegistryDelegateJSON      = require('../build/contracts/DeveloperRegistryDelegate.json')
const botRegistryDelegateJSON      = require('../build/contracts/BotProductRegistryDelegate.json')
const serviceRegistryDelegateJSON  = require('../build/contracts/BotServiceRegistryDelegate.json')
const instanceRegistryDelegateJSON = require('../build/contracts/BotInstanceRegistryDelegate.json')

// Account of the owner of the network i.e. Talla's Address
const mgmtAddr          = '0x547C0A0e61c41d8948251C02241df6FD4e860EcD'

// Token Address
const botcoinAddr       = '0x337bA7e4F7e86F429494D7196b7c122918f31f48'

// Addresses for all current proxies.
// Delegates aren't listed as they will change and are not required.
const devProxyAddr      = '0x877005c049a458294d3c063d2b5e48485c0900a9'
const botProxyAddr      = '0x2b044c8a463bc52716d9818b56505c0ea1273f5a'
const serviceProxyAddr  = '0x00be80cb8fe2c0df6462d4eaef2ecbf6dc28541a'
const instanceProxyAddr = '0x4728e0a668df2aa10fcedf954228b775cdd45c21'
const publicStorageAddr = '0x88d3633a6b6AC6A30C39Fc1A336933dc61f2bDf6'

// Botcoin Interface
const token                = eth.contract(botCoinJSON.abi).at(botCoinAddress)

// Registry Interfaces -- ABIs the delegates pointed at the Proxy Addresses
const curDevRegistry          = eth.contract(developerRegistryDelegateJSON.abi).at(devProxyAddress)
const curBotRegistry          = eth.contract(botProductRegistryDelegateJSON.abi).at(botProxyAddress)
const curServiceRegistry      = eth.contract(botServiceRegistryDelegateJSON.abi).at(serviceProxyAddress)
const curInstanceRegistry     = eth.contract(botInstanceRegistryDelegateJSON.abi).at(instanceProxyAddress)

// Upgrade Interfaces -- The "Ownable Proxies"
const devUpgradeIface      = eth.contract(ownableProxyJSON.abi).at(devProxyAddress)
const botUpgradeIface      = eth.contract(ownableProxyJSON.abi).at(botProxyAddress)
const serviceUpgradeIface  = eth.contract(ownableProxyJSON.abi).at(serviceProxyAddress)
const instanceUpgradeIface = eth.contract(ownableProxyJSON.abi).at(instanceProxyAddress)

// Registry Contract Objects
// Used to create a new contract for deployment
const DevRegistry      = web3.eth.contract(devRegistryDelegateJSON.abi);
const BotRegistry      = web3.eth.contract(botRegistryDelegateJSON.abi);
const ServiceRegistry  = web3.eth.contract(serviceRegistryDelegateJSON.abi);
const InstanceRegistry = web3.eth.contract(instanceRegistryDelegateJSON.abi);

try {
  web3.personal.unlockAccount(mgmtAddress, password);
} catch(e) {
  console.log(e);
  return;
}

console.log("Deploying the contract");
const gasTxLimit = 7900000;
const devRegistry      = DevRegistry.new({from: mgmtAddress, gas: gasTxLimit, data: devRegistryDelegateJSON.bytecode});
const botRegistry      = BotRegistry.new({from: mgmtAddress, gas: gasTxLimit, data: botRegistryDelegateJSON.bytecode});
const serviceRegistry  = ServiceRegistry.new({from: mgmtAddress, gas: gasTxLimit, data: serviceRegistryDelegateJSON.bytecode});
const instanceRegistry = InstanceRegistry.new({from: mgmtAddress, gas: gasTxLimit, data: instanceRegistryDelegateJSON.bytecode});

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
