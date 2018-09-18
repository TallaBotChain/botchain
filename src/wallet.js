'use strict';
// The Wallet Module
//
// This module contains wallet related helper functions and structures to
// facilitate interacting with Botchain contracts.  This is provided by
// interacting with a provided web3 instantiation.
const botcoinJSON   = require('../build/contracts/BotCoin.json')
const contractAddrs = require('../build/contracts.json')

// Static variables are provided mostly as conveniences
Wallet.instanceRegistryAddr  = '0x0';

/* 
*  The module object should contain all functions or variables we
*  would like exported. To export a new function you should define it
*  following this template:
*     module.<exported name> = function myFancyFunc(args){ ... }
*/
  function Wallet(_web3, _keystore, _password) {
  
    // Botcoin Interface
    this.token = new _web3.eth.Contract(botcoinJSON.abi, contractAddrs.Botcoin);
    this.web3 = _web3;
  
    if (_keystore !== undefined) {
      this.encrypted_keystore = _web3.eth.accounts.create();
    }
    else {
      this.encrypted_keystore = _keystore
    }

    if (_password !== undefined) {
      this.account = _keystore.decrypt(_password) 
    }
    else {
      this.account = undefined
    }
  }

  Wallet.prototype.decrypt = async function(_password) {
    if (this.encrypted_keystore !== undefined) {
      this.account = this.encrypted_keystore.decrypt(_password)
    }
  }

  function isFloat(n){
    return Number(n) === n && n % 1 !== 0;
  }

  Wallet.prototype.sendEth = async function(toAddr, amount) {
    let nonce = await this.web3.eth.getTransactionCount(this.account.address)

    if (!isFloat(amount)) return

    let rawEthTx = {
      'from': this.account.address,
      'to': toAddr,
      'nonce': nonce,
      'gasPrice': this.web3.utils.toHex(3 * 1e9),
      'gasLimit': this.web3.utils.toHex(3000000),
      'value': amount.toString()
    }

    return decryptedAcct.signTransaction(rawTokenTx)
      .then((signedTx) => {
        console.log('[Addr:',decryptedAcct.address,'] Signed ETH transfer.')
        // should be VERBOSE level
        console.log(signedTx)
        return this.web3.eth.sendSignedTransaction(signedTx.rawTransaction)
      })
      .then((txReceipt) => {
        console.log('[Addr:',decryptedAcct.address,'] ETH transfer tx complete.')
        // should be VERBOSE level
        console.log(txReceipt)
        return { 'success': true, 'receipt': txReceipt }
      })
      .catch((error) => {
        // should be ERROR level
        console.log('[Addr:',decryptedAcct.address,'] ETH Send',error)
        return { 'success': false, 'error': error }
      })
  }
  
  Wallet.prototype.approveTokenTransfer = async function(to, amount) {
    let nonce = await this.web3.eth.getTransactionCount(decryptedAcct.address)

    // Transaction to approve token transfer
    let rawTokenTx = {
      'from': decryptedAcct.address,
      'to': cfg.botcoinAddr,
      'nonce': nonce,
      'gasPrice': this.web3.utils.toHex(3 * 1e9),
      'gasLimit': this.web3.utils.toHex(3000000),
      'value': '0x0',
      'data': token.methods.approve(to, amount).encodeABI()
    }

    return decryptedAcct.signTransaction(rawTokenTx)
      .then((signedTx) => {
        // should be DEBUG level
        console.log('[Addr:',decryptedAcct.address,'] Signed token transfer approval.')
        // should be VERBOSE level
        console.log(signedTx)
        return this.web3.eth.sendSignedTransaction(signedTx.rawTransaction)
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

  /**
   * Approve the ID of a Developer present in the registry.
   *
   * @param {string} Address of the developer to approve (should be a hex value: 0x0...)
   * @param {Object} The decrypted account of the wallet being used locally. Refer to web3.eth.accounts.decrypt.
   * @return {Object} Details about the state of the approval operation.
   */
  Registry.prototype.approveDeveloper = async function(address, decryptedAcct) {
    console.log('[Addr:',address,'] Initiating Approval Process ...')
    let idx 

    // Transaction for approving the developer on the registry
    idx = await this.abi.get('dev').methods.owns(address).call()
    console.log('[Addr:',address,'] Developer owns ID',idx.toString())

    let rawApproveTx = {
      'from': decryptedAcct.address,
      'contractAddress': cfg.devProxyAddr,
      'nonce': 0, // Just a placeholder, needs to be update before sending.
      'gasPrice': this.web3.utils.toHex(3 * 1e9),
      'gasLimit': this.web3.utils.toHex(3000000),
      'value': '0x0',
      'data': this.abi.get('dev').methods.grantApproval(idx).encodeABI()
    }

    return this.approveTokenTransfer(cfg.devProxyAddr, decryptedAcct, approve_cost)
      .then((tokenTxInfo) => {
        if (tokenTxInfo.success) {
          return this.web3.eth.getTransactionCount(decryptedAcct.address)
        }
        else throw tokenTxInfo.error
      })
      .then((nonce) => {
          rawApproveTx.nonce = nonce
          return decryptedAcct.signTransaction(rawApproveTx)
      })
      .then((approvalTx) => {
        console.log('[Addr:',address,'] Signed approval transaction.')
        return this.web3.eth.sendSignedTransaction(approvalTx.rawTransaction)
      })
      .then((approvalReceipt) => {
        console.log('[Addr:',address,'] Developer',idx,'Approved.')
        console.log(approvalReceipt)
        return { 'success': true, 'receipt': approvalReceipt }
      })
      .catch((error) => {
        console.log('[Addr:',address,'] approveDeveloper',error)
        return { 'success': false, 'error': error }
      })
  }

  /**
   * Revoke approval of the ID for the Developer if present in the registry.
   *
   * @param {string} Address of the developer to approve (should be a hex value: 0x0...)
   * @param {Object} The decrypted account of the wallet being used locally. Refer to web3.eth.accounts.decrypt.
   * @return {Object} Details about the state of the revocation operation.
   */
  Registry.prototype.revokeApproval = async function(address, decryptedAcct) {
    console.log('[Addr:',address,'] Initiating Revocation Process ...')
    let idx 

    // Transaction for approving the developer on the registry
    idx = await this.abi.get('dev').methods.owns(address).call()
    console.log('[Addr:',address,'] Developer owns ID',idx.toString())

    let rawRevokeTx = {
      'from': decryptedAcct.address,
      'contractAddress': cfg.devProxyAddr,
      'nonce': 0, // Just a placeholder, needs to be update before sending.
      'gasPrice': this.web3.utils.toHex(3 * 1e9),
      'gasLimit': this.web3.utils.toHex(3000000),
      'value': '0x0',
      'data': this.abi.get('dev').methods.revokeApproval(idx).encodeABI()
    }

    return this.approveTokenTransfer(cfg.devProxyAddr, decryptedAcct, approve_cost)
      .then((tokenTxInfo) => {
        if (tokenTxInfo.success) {
          return this.web3.eth.getTransactionCount(decryptedAcct.address)
        }
        else throw tokenTxInfo.error
      })
      .then((nonce) => {
          rawRevokeTx.nonce = nonce
          return decryptedAcct.signTransaction(rawRevokeTx)
      })
      .then((revokeTx) => {
        console.log('[Addr:',address,'] Signed revoke transaction.')
        return this.web3.eth.sendSignedTransaction(revokeTx.rawTransaction)
      })
      .then((revokeReceipt) => {
        console.log('[Addr:',address,'] Developer',idx,'approval revoked.')
        console.log(revokeReceipt)
        return { 'success': true, 'receipt': revokeReceipt }
      })
      .catch((error) => {
        console.log('[Addr:',address,'] revokeApproval',error)
        return { 'success': false, 'error': error }
      })
  }

  Registry.prototype.checkDevApprovalById = async function(idx) {
    if (!Number.isInteger(Number(idx))) throw Error('checkDevApprovalById - idx: '+idx+' - should be an integer.')

    let address = await this.ownerOfEntry(idx)
    return this.abi.get('dev').methods.approvalStatus(idx)
      .call()
      .then((result) => {
        console.log('[Addr: ',address,'ID:',idx+'] Approval status:',result)
        return result
      })
      .catch((error) => {
        console.log('Entry:', idx, 'Get Owner',error)
      })
  }

  Registry.prototype.checkDevApprovalByAddr = async function(address) {
    await this.web3.utils.isAddress(address)

    return this.abi.get('dev').methods.owns(address)
      .call()
      .then((idx) => {
        console.log('[Addr: ',address,'] ID Found:',idx)
        return this.abi.get('dev').methods.approvalStatus(idx).call()
      })
      .then((result) => {
        console.log('[Addr: ',address,'] Status:',result)
        return result
      })
  }

  Registry.prototype.ownerOfEntry = async function(idx) {
    if (!Number.isInteger(Number(idx))) throw Error('ownerOfEntry - idx: '+idx+' - should be an integer.')

    return this.abi.get('dev').methods.ownerOfEntry(idx)
      .call()
      .then((addr) => {
        console.log('[ID:',idx+'] Owner:',addr)
        return addr
      })
      .catch((error) => {
        console.log('ownerOfEntry',error)
      })
  }

  Registry.prototype.getDeveloperUrl = function(idx) {

    if (Number.isInteger(idx)) {
      console.log('[Idx:',idx+'] getDeveloperUrl expects idx to be an integer.')
      return 0
    }

    this.abi.get('dev').methods.developerDataHash(idx)
      .call()
      .then((url) => {
        console.log('[ID:',idx+']','URL:',url)
        return url
      })
      .catch((error) => {
        console.log('[ID:',idx+'] getDeveloperUrl', error)
        return 0
      })
  }

  module.exports = Registry;
