# BotChain

Platform smart contracts for BotChain.

## Setup

Make sure you have the following installed globally:

node 8

TestRPC 6: `npm install -g ethereumjs-testrpc`

Then run `npm install`

### Compile

Recompile contracts and build artifacts.

```
$ npm run compile
```

### Deploy

Deploy contracts to RPC provider at port `8546`.

```
$ npm run deploy
```

### Test

Run `npm run compile` before first test run, and after any changes to the `.sol` files

```
$ npm test
```

Run `npm run test:coverage` to run with coverage reporting

### Deployment

* `npm run deploy:development` - deploy to local TestRPC
* `npm run deploy:kovan` - deploy to kovan testnet
* `npm run deploy:rinkeby-infura` - deploy to rinkeby testnet via infura service
* `npm run deploy:mainnet` - deploy to mainnet

### Rinkeby-Infura Deployment Setup

Add `secrets.json` to the project root

```
// secrets.json
{
  "mnemonic": "<some mnemonic>",
  "infura_apikey": "<your infura key>"
}
```

Go to https://iancoleman.github.io/bip39/, click "Generate". Add `BIP39 Mnemonic` to `"mnemonic"` value in `secrets.json`

Add address from the BIP39 page to MetaMask. Send it some rinkeby Ether, or get it from the faucet on https://www.rinkeby.io

Go to https://infura.io/register.html to register for Infura. Paste your API key into `"infura_apikey"` value in `secrets.json`

`npm run deploy-rinkeby` to deploy to rinkeby


## BotChain Overview

BotChain smart contracts allow developers of bots and bot related services to register them on-chain. Applicants to the registry can be added in an unapproved state, and can only be approved by Talla. Adding a new record to a BotChain registry has an associated fee, which is paid in BotCoin and sent to a Talla owned wallet address.

### Registries

The BotChain smart contract layer consists of four registries:

#### 1. Developer Registry

Stores entries for developer records. These will correspond to companies or individuals that want to register bots.

Anyone can create a developer entry in an unapproved state. Only the contract owner (Talla address) can grant approval to new entries.

Implements [ERC721](https://github.com/OpenZeppelin/zeppelin-solidity/blob/d1146e8c8b1863da8fd8c938de629d85dbf5e749/contracts/token/ERC721/ERC721.sol) so each developer entry is a non-fungible token that is owned by an address and can be transferred.

#### 2. Bot Product Registry

Stores entries for bot products. These will correspond to the products created by companies or individuals.

Each bot product is linked to a parent developer ID. Only owners of developer entries can create bot products.

#### 3. Bot Instance Registry

Stores entries for bot instances. Each bot instance will correspond to a running instance of bot product.

Each bot instance is linked to a parent bot product ID. Only owners of developer entries can create bot instances for bot products which they own.

#### 4. Bot Service Registry

Stores entries for bot services. These will correspond with bot related services that companies or individuals create and run off-chain.

### Entry Hierarchy

Developer entries are top level. An address that owns a developer entry can create bot products, instances, or services under their developer entry. Each entry is identified by a uint256 ID.

```
Owner (address)
│
└── Developer (ID)
    │
    ├── Bot Product (ID)
    │   └── Bot Instance (ID)
    │
    └── Bot Service (ID)

```

### Approval Grant/Revoke

Talla can grant or revoke approval for any entry at any time. Newly created developer entries default to an unapproved state and need to be granted approval. Newly created bot product, instance, and service entires default to an approved state, but their approval can be revoked by talla.

Approval functionality is provided by `ApprovableRegistry.sol` which all registries extend.

### Activate/Deactivate

Bot products, instances, and services can be activated or deactivated by the owner of their parent developer record. Newly created entries default to an active state.

Activation functionality is provided by `ActivatableRegistry.sol` which bot product, instance, and service registries extend.

### BotCoin Payments

Talla can set a wallet address and a payment amount (in BotCoin) for each of the four registries. These values can be changed at any time.

When an address creates a new registry entry, the registry contract attempts to transfer BotCoin from the creator address to the stored wallet address. The creator address must first approve this transfer on the BotCoin ERC20 token contract.

Payment functionality is provided by `BotCoinPayableRegistry.sol` which all registries extend.

### Upgradability Pattern

BotChain smart contracts use patterns that allow for upgradability of functionality and storage schema. Talla controls the upgrade process, which can only be initiated by a Talla owned address.

Registry contracts use `delegatecall` to execute transactions provided by delegate contracts. Delegate contracts contain all registry functionality. State for each registry is written and read from a single deployed instance of `PublicStorage.sol`, which stores key/value pairs scoped by contract address.

Talla can upgrade BotChain's functionality by deploying a new registry delegate contract and executing `upgradeTo(<new_registry_delegate_contract_address>)` on the deployed registry instance. The `upgradeTo()` function is provided by `OwnableProxy.sol`, which all registry instance contracts extend.

The pattern that BotChain uses closely resembles one proposed by the Open Zeppelin team in [Smart Contract Upgradeability Using Eternal Storage](https://blog.zeppelinos.org/smart-contract-upgradeability-using-eternal-storage/)


## Smart Contract Files

#### BotCoin.sol

Development stand-in for an ERC20 token. THIS CODE WILL NOT BE USED FOR MAINNET DEPLOYMENT.

#### BotEntryRegistry.sol

Instance contract for bot product, instance, and service registries (a separate instance will be deployed for each of the 3 registries).

Extends `OwnableProxy` to set a delegate implementation and allow for upgrades.

#### DeveloperRegistry.sol

Instance contract for the developer registry.

Extends `OwnableProxy` to set a delegate implementation and allow for upgrades.

### Delegates/

#### BotInstanceRegistryDelegate.sol

Provides functionality for the bot instance registry.

Extends `BotEntryStorableRegistry`.

#### BotProductRegistryDelegate.sol

Provides functionality for the bot product registry.

Extends `BotEntryStorableRegistry`.

#### BotServiceRegistryDelegate.sol

Provides functionality for the bot service registry.

Extends `BotEntryStorableRegistry`.

#### DeveloperRegistryDelegate.sol

Provides functionality for the developer registry. Implements ERC721 non-fungible token standard. 

Extends `ApprovableRegistry`, `OwnerRegistry`, `BotCoinPayableRegistry`, and `ERC721TokenKeyed`.


### Registry/

#### ActivatableRegistry.sol

Provides activation and deactivation functionality for a registry. Extends `StorageConsumer` which allows it to interact with a `BaseStorage` contract.

#### ApprovableRegistry.sol

Provides approval grant and revoke functionality for a registry. Extends `OwnableKeyed` which allows it to have an owner and restrict function execution with the `onlyOwner` modifier.

#### BotCoinPayableRegistry.sol

Provides registries with functionality for BotCoin payment configuration and transfer. Extends `OwnableKeyed` which allows it to have an owner and restrict function execution with the `onlyOwner` modifier.

#### BotEntryStorableRegistry.sol

Provides registries with functionality for creation and storage of entries. Extended by `BotInstanceRegistryDelegate`, `BotProductRegistryDelegate`, and `BotServiceRegistryDelegate`. `BotEntryStorableRegistry` provides these 3 registries with a common format for entry data storage (ID, data hash, URL) and a common implementation for creating and reading entries.

Extends `BotCoinPayableRegistry`, `ApprovableRegistry`, `ActivatableRegistry`, and `OwnableRegistry`.

#### OwnableRegistry.sol

Nearly identical implementation to `ERC721TokenKeyed`. Unlike an ERC721 contract, `OwnableRegistry` stores an ownership mapping by uint256 ID rather than by address. This implementation allows entries in ownable registries (bot product, instance, and service) to be "owned" by entries in owner registries (developer, bot product).

Extends `StorageConsumer`.

#### OwnerRegistry.sol

Abstract contract that "owner" registries (registries whos entries own entries from another registry) must implement.

#### Registry.sol

Abstract contract that all registries must implement.


### Upgradability/

#### BaseProxy.sol

Basic proxy `delegatecall` contract. From [Smart Contract Upgradeability Using Eternal Storage](https://blog.zeppelinos.org/smart-contract-upgradeability-using-eternal-storage/)

#### BaseStorage.sol

Provides getters and setters for key value storage.

Extends `KeyValueStorage`

#### ERC721TokenKeyed.sol

Implmentation of the ERC721 token standard. Uses `BaseStorage` to store all state in a separate contract as key/value pairs. Modified version of Open Zeppelin's [ERC721Token](https://github.com/OpenZeppelin/zeppelin-solidity/blob/d1146e8c8b1863da8fd8c938de629d85dbf5e749/contracts/token/ERC721/ERC721Token.sol)

Extends `StorageConsumer`

#### KeyValueStorage.sol

Defines storage for key/value mappings.

#### OwnableKeyed.sol

A key/value storage based implementation of Open Zeppelin's [Ownable](https://github.com/OpenZeppelin/zeppelin-solidity/blob/d1146e8c8b1863da8fd8c938de629d85dbf5e749/contracts/ownership/Ownable.sol).

#### OwnableProxy.sol

Allows `delegatecall` implementation pointer to be set and upgraded by an owner address.

Extends `OwnableKeyed`, `BaseProxy`.

#### PublicStorage.sol

A `BaseStorage` implementation that scopes keys by sender address. Allows multiple contracts to read and write from storage on the same contract.

Extends `BaseStorage`.

#### StorageConsumer.sol

Allows contracts to set the address of a `BaseStorage` contract, to interact with key/value storage getters and setters.

Extends `StorageStateful`

#### StorageStateful.sol

Provides state for storage of a `BaseStorage` address.
