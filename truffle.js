require('babel-register')
require('babel-polyfill')

module.exports = {
  networks: {
    mainnet: {
      // * run parity on mainnet: `parity`
      // * update host/port to point at parity RPC
      host: 'localhost',
      port: 8546,
      network_id: 1,
      gas: 4600000,
      // `gasPrice: 5` is relatively low price and could result in long transaction times (> 30 minutes)
      // If network activity is spiking and gas prices are very high, a transaction at `gasPrice: 5`
      // may not be mined at all until prices drop, which in some cases could take days. Increase this
      // to incentivize miners to mine the tx!
      gasPrice: 5
    },
    kovan: {
      // * run parity on kovan testnet: `parity --chain kovan`
      // * update host/port to point at parity RPC
      host: 'localhost',
      port: 8546,
      network_id: 42,
      gas: 4600000
    },
    development: {
      host: 'localhost',
      port: 8546,
      network_id: '*', // Match any network id
      gas: 4600000
    },
    coverage: {
      host: 'localhost',
      network_id: '*',
      port: 8546,
      gas: 0xfffffffffff,
      gasPrice: 0x01
    },
    rinkeby_infura: getInfuraConfig('rinkeby', 4),
    kovan_infura: getInfuraConfig('kovan', 42)
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
