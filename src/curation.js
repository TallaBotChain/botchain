'use strict';
// The Curation Module
//
// This module contains all functions used to directly interact with
// the Botchain Curation Council Contract.

/* 
*  The module object should contain all functions or variables we
*  would like exported. To export a new function you should define it
*  following this template:
*     module.<exported name> = function myFancyFunc(args){ ... }
*/

// Load all relevent compiled contracts
const curationRegistryDelegateJSON = require('../build/contracts/CurationCouncilRegistryDelegate.json')
const tokenVaultDelegateJSON       = require('../build/contracts/TokenVaultDelegate.json')
const botCoinJSON                  = require('../build/contracts/BotCoin.json')

// Load addresses for Registry contracts
const contractAddrs                = require('../build/contracts.json')

// Store related Proxy contract addresses.
Curation.prototype.tokenVaultAddr       = contractAddrs.TokenVault;
Curation.prototype.curationCouncilAddr  = contractAddrs.CurationCouncil;

function Curation(_web3, _curationCouncilAddr=0, _tokenVaultAdddr=0) {

  // Interfaces -- ABIs of the delegates pointed at the Proxy Addresses
  this.abi = new Map()
  .set('curation',  new web3.eth.Contract(curationRegistryDelegateJSON.abi, _curationCouncilAddr || this.curationCouncilAddr))
  .set('vault',     new web3.eth.Contract(tokenVaultDelegateJSON.abi, _tokenVaultAdddr || this.tokenVaultAdddr))
  .set('token',     new web3.eth.Contract(botCoinJSON.abi, contractAddrs.BotCoin));
}

Curation.prototype.approveTokenTransfer = async function(to, decryptedAcct, amount) {
  let nonce = await web3.eth.getTransactionCount(decryptedAcct.address)

  // Transaction to approve token transfer
  let rawTokenTx = {
    'from': decryptedAcct.address,
    'to': contractAddrs.BotCoin,
    'nonce': nonce,
    'gasPrice': web3.utils.toHex(3 * 1e9),
    'gasLimit': web3.utils.toHex(3000000),
    'value': '0x0',
    'data': this.abi.get('token').methods.approve(to, amount).encodeABI()
  }

  return decryptedAcct.signTransaction(rawTokenTx)
    .then((signedTx) => {
      // should be DEBUG level
      console.log('[Addr:',decryptedAcct.address,'] Signed token transfer approval.')
      // should be VERBOSE level
      console.log(signedTx)
      return web3.eth.sendSignedTransaction(signedTx.rawTransaction)
    })
    .then((txReceipt) => {
      // should be DEBUG level
      console.log('[Addr:',decryptedAcct.address,'] Token transfer tx complete.')
      // should be VERBOSE level
      console.log(txReceipt)
      return { 'success': true, 'receipt': txReceipt }
    })
    .catch((error) => {
      // should be ERROR level
      console.log('[Addr:',decryptedAcct.address,'] approveTokenTransfer',error)
      return { 'success': false, 'error': error }
    })
}

Curation.prototype.getStakeAmount = async function(addr) {

  return this.abi.get('curation').methods.getStakeAmount(addr)
    .call()
    .then((result) => {
      console.log('[Addr: ',addr+'] Stake Amount:',result)
      return result
    })
    .catch((error) => {
      console.log('Address:', addr, 'Get Stake Amount',error)
    })
}

Curation.prototype.createRegistrationVote = async function(decryptedAcct) {
  let nonce = await web3.eth.getTransactionCount(decryptedAcct.address)

  // Transaction to approve token transfer
  let rawTx = {
    'from': decryptedAcct.address,
    'to': this.curationCouncilAddr,
    'nonce': nonce,
    'gasPrice': web3.utils.toHex(4 * 1e8),
    'gasLimit': web3.utils.toHex(7900000),
    'value': '0x0',
    'data': this.abi.get('curation').methods.createRegistrationVote().encodeABI()
  }

    return decryptedAcct.signTransaction(rawTx)
      .then((signedTx) => {
        // should be DEBUG level
        console.log('[Addr:',decryptedAcct.address,'] Signed vote creation message.')
        // should be VERBOSE level
        console.log(signedTx)
        return web3.eth.sendSignedTransaction(signedTx.rawTransaction)
      })
      .then((txReceipt) => {
        // should be DEBUG level
        console.log('[Addr:',decryptedAcct.address,'] Vote creation complete.')
        // should be VERBOSE level
        console.log(txReceipt)
        return { 'success': true, 'receipt': txReceipt }
      })
      .catch((error) => {
        // should be ERROR level
        console.log('[Addr:',decryptedAcct.address,'] createRegistrationVote',error)
        return { 'success': false, 'error': error }
      })
}

Curation.prototype.joinCouncil = async function(decryptedAcct, amount) {
  let nonce = await web3.eth.getTransactionCount(decryptedAcct.address)

  // Transaction to approve token transfer
  let rawTokenTx = {
    'from': decryptedAcct.address,
    'to': contractAddrs.CurationCouncil,
    'nonce': nonce,
    'gasPrice': web3.utils.toHex(4 * 1e8),
    'gasLimit': web3.utils.toHex(7900000),
    'value': '0x0',
    'data': this.abi.get('curation').methods.joinCouncil(amount).encodeABI()
  }

  return this.approveTokenTransfer(contractAddrs.CurationCouncil, decryptedAcct, amount)
    .then((tokenTxInfo) => {
      if (tokenTxInfo.success) {
        return web3.eth.getTransactionCount(decryptedAcct.address)
      }
      else throw tokenTxInfo.error
    })
    .then((nonce) => {
        rawTokenTx.nonce = nonce
        return decryptedAcct.signTransaction(rawTokenTx)
    })
    .then((signedTx) => {
      // should be DEBUG level
      console.log('[Addr:',decryptedAcct.address,'] Signed token transfer approval.')
      // should be VERBOSE level
      console.log(signedTx)
      return web3.eth.sendSignedTransaction(signedTx.rawTransaction)
    })
    .then((txReceipt) => {
      // should be DEBUG level
      console.log('[Addr:',decryptedAcct.address,'] Token transfer tx complete.')
      // should be VERBOSE level
      console.log(txReceipt)
      return { 'success': true, 'receipt': txReceipt }
    })
    .catch((error) => {
      // should be ERROR level
      console.log('[Addr:',decryptedAcct.address,'] approveTokenTransfer',error)
      return { 'success': false, 'error': error }
    })
}

module.exports = Curation;
