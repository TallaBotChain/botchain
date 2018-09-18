# Botchain CLI

Command line tools for interacting with and managing https://www.botchain.network

## Setup

Clone the CLI locally by running:
```
git clone git@github.com:TallaBotChain/botchain.git ~/
```
Install nodejs dependencies:
```
cd ~/botchain/ && npm install
```

The CLI currently comes packaged with configuration to point it at the Testnet
instance of BotChain, which is hosted on the Kovan Network.

### Test

Run `npm run compile` before first test run, and after any changes to the `.sol` files

```
$ npm test
```

Run `npm run test:coverage` to run with coverage reporting

For an overview of how the contracts involved in the process and how they operate
please refer to the [Botchain Overview](https://github.com/TallaBotChain/botchain#botchain-overview).
