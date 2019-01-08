require('babel-register')
require('babel-polyfill')

module.exports = {
  networks: {
    mainnet: {
      // * run parity on mainnet: `parity`
      // * update host/port to point at parity RPC
      host: process.env.RPC_HOST || 'localhost',
      port: process.env.RPC_PORT || 8545,
      network_id: process.env.NETWORK_ID || 1,
      gas: process.env.GAS || 4600000,
      // `gasPrice: 5` is relatively low price and could result in long transaction times (> 30 minutes)
      // If network activity is spiking and gas prices are very high, a transaction at `gasPrice: 5`
      // may not be mined at all until prices drop, which in some cases could take days. Increase this
      // to incentivize miners to mine the tx!
      gasPrice: process.env.GAS_PRICE || 5
    },
    kovan: {
      // * run parity on kovan testnet: `parity --chain kovan`
      // * update host/port to point at parity RPC
      host: process.env.RPC_HOST || 'localhost',
      port: process.env.RPC_PORT || 8545,
      network_id: process.env.NETWORK_ID || 42,
      gas: process.env.GAS || 4600000
    },
    development: {
      host: process.env.RPC_HOST || 'localhost',
      port: process.env.RPC_PORT || 8545,
      network_id: process.env.NETWORK_ID || '*',
      gas: process.env.GAS || 6500000,
      gasPrice: 5
    },
    coverage: {
      host: 'localhost',
      network_id: '*',
      port: 8545,
      gas: 0xfffffffffff,
      gasPrice: 0x01
    },
    rinkeby_infura: getInfuraConfig('rinkeby', 4),
    kovan_infura: getInfuraConfig('kovan', 42),
    mainnet_infura: getInfuraConfig('mainnet', 1)
  }
}

function getInfuraConfig (networkName, networkId) {
  var HDWalletProvider = require('truffle-hdwallet-provider')
  var secrets = {}
  try {
    secrets = require('./secrets.json')
  } catch (err) {
    console.log('could not find ./secrets.json')
  }

  return {
    network_id: networkId,
    provider: () => {
      return new HDWalletProvider(secrets.mnemonic, `https://${networkName}.infura.io/` + secrets.infura_apikey)
    }
  }
}
