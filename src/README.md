# botchain.js

This is a collection of ES6 modules that interact with the Botchain Smart Contracts.

## Setup

A distribution of the library can be generated by running:

```
npm install && npm run build
```

This will produce a library that can be included in modern browsers or node.js

## Distribution

When compiled the distribution can be found in `../dist/botchain-<version>.js`

## Dependencies

All of the botchain.js modules are dependent on the `Web3 library`.

All other dependencies are handled internal to simplify development.

## Example Usage

The below example illustrates how to instantiate a botchain.js Registry module
and use it to access some basic information regarding a registered developer.

```
// Include required libs 
let Web3 = require('web3')
let botchain = require('botchain-0.1.0')

// Initialize web3 provider
let web3 = new Web3(new Web3.providers.HttpProvider('https://kovan.infura.io/<infura-api-key>')

// Instantiate a Registry module with the web3 provider
let registry = new botchain.Registry(web3)

// You can now access information from the blockchain directly through the module.
let developerId = '1'
let developerAddr = registry.getId(developerId)
console.log('The developer addr registered at index \'1\' is:', developerAddr)
```




