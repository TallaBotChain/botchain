// The Curation Module
//
// This module contains all functions used to directly interact with
// the Botchain Curation Council Contract.
module.exports = function (web3, cfg) {

  /* 
  *  The module object should contain all functions or variables we
  *  would like exported. To export a new function you should define it
  *  following this template:
  *     module.<exported name> = function myFancyFunc(args){ ... }
  */
  let module = {}

  // Load all relevent compiled contracts
  const curationRegistryDelegateJSON = require('../../build/contracts/CurationCouncilRegistryDelegate.json')
  const tokenVaultDelegateJSON       = require('../../build/contracts/TokenVaultDelegate.json')
  const botCoinJSON                  = require('../../build/contracts/BotCoin.json')
  
  // Botcoin Interface
  const token = new web3.eth.Contract(botCoinJSON.abi, cfg.botcoinAddr)

  // Expansion of the fee for botchain transactions
  const approve_cost_base = 1;
  const approve_cost_exponent = 10 ** 18;
  const approve_cost = approve_cost_base * approve_cost_exponent;

  // Registry Interfaces -- ABIs of the delegates pointed at the Proxy Addresses
  const contracts = new Map()
  .set('curation',  new web3.eth.Contract(curationRegistryDelegateJSON.abi, cfg.curationProxyAddr))
  .set('vault',     new web3.eth.Contract(tokenVaultDelegateJSON.abi, cfg.vaultProxyAddr));
  
  module.approveTokenTransfer = async function approveTokenTransfer(to, decryptedAcct, amount) {
    let nonce = await web3.eth.getTransactionCount(decryptedAcct.address)

    // Transaction to approve token transfer
    let rawTokenTx = {
      'from': decryptedAcct.address,
      'to': cfg.botcoinAddr,
      'nonce': nonce,
      'gasPrice': web3.utils.toHex(3 * 1e9),
      'gasLimit': web3.utils.toHex(3000000),
      'value': '0x0',
      'data': token.methods.approve(to, amount).encodeABI()
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

  module.getStakeAmount = async function getStakeAmount(addr) {

    return contracts.get('curation').methods.getStakeAmount(addr)
      .call()
      .then((result) => {
        console.log('[Addr: ',addr+'] Stake Amount:',result)
        return result
      })
      .catch((error) => {
        console.log('Address:', addr, 'Get Stake Amount',error)
      })
  }

  module.joinCouncil = async function joinCouncil(decryptedAcct, amount) {
    let nonce = await web3.eth.getTransactionCount(decryptedAcct.address)

    // Transaction to approve token transfer
    let rawTokenTx = {
      'from': decryptedAcct.address,
      'to': cfg.curationProxyAddr,
      'nonce': nonce,
      'gasPrice': web3.utils.toHex(4 * 1e8),
      'gasLimit': web3.utils.toHex(7900000),
      'value': '0x0',
      'data': contracts.get('curation').methods.joinCouncil(amount).encodeABI()
    }

    return module.approveTokenTransfer(cfg.curationProxyAddr, decryptedAcct, amount)
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

  return module
} // End Module
