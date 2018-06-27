/* globals artifacts */

import _ from 'lodash'

const CurationCouncil = artifacts.require('./CurationCouncil.sol')
const CurationCouncilRegistryDelegate = artifacts.require('./CurationCouncilRegistryDelegate.sol')

export default async function newCurationCouncil (botCoinAddress, publicStorageAddress, tokenVaultAddress) {
  const curationCouncilRegistryDelegate = await CurationCouncilRegistryDelegate.new(publicStorageAddress, tokenVaultAddress)

  let curationCouncil = await CurationCouncil.new(
    publicStorageAddress,
    curationCouncilRegistryDelegate.address,
    botCoinAddress
  )
  curationCouncil = _.extend(
    curationCouncil,
    await CurationCouncilRegistryDelegate.at(curationCouncil.address)
  )

  return curationCouncil
}
