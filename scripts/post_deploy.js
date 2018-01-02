const fs = require('fs')

const contractsPath = 'build/contracts'
const contractsOutputFile = 'build/contracts.json'
const contractFiles = [
  'BotChain.json',
  'BotCoin.json',
  'TokenSubscription.json'
]

let contractJSON
let jsonOutput = {}
for (var i = 0; i < contractFiles.length; i++) {
  contractJSON = JSON.parse(fs.readFileSync(`${contractsPath}/${contractFiles[i]}`).toString())
  jsonOutput[contractJSON.contractName] = getContractAddress(contractJSON.networks)
}

fs.writeFile(contractsOutputFile, JSON.stringify(jsonOutput, null, 2), function (err) {
  if (err) {
    return console.log(err)
  }
})

function getContractAddress (networksJSON) {
  for (var p in networksJSON) {
    if (networksJSON[p].address) {
      return networksJSON[p].address
    }
  }
  return '""'
}
