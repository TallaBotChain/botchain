/* globals artifacts */

import _ from 'lodash'

const PublicStorage = artifacts.require('./PublicStorage.sol')
const CurationCouncil = artifacts.require('./CurationCouncil.sol')
const CurationCouncilRegistryDelegate = artifacts.require('./CurationCouncilRegistryDelegate.sol')

export default async function newCurationCouncil (botCoinAddress) {
  const publicStorage = await PublicStorage.new()
  const curationCouncilRegistryDelegate = await CurationCouncilRegistryDelegate.new(publicStorage.address)

  let curationCouncil = await CurationCouncil.new(
    publicStorage.address,
    curationCouncilRegistryDelegate.address,
    botCoinAddress
  )
  curationCouncil = _.extend(
    curationCouncil,
    await CurationCouncilRegistryDelegate.at(curationCouncil.address)
  )

  return curationCouncil
}
