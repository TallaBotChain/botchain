const fs = require('fs')
const toml = require('toml');
const _config = toml.parse(fs.readFileSync('./config.toml', 'utf-8'));

if (   !_config.devProxyAddr
    || !_config.botProxyAddr
    || !_config.serviceProxyAddr
    || !_config.instanceProxyAddr
    || !_config.publicStorageAddr
    || !_config.mgmtAddr
    || !_config.botcoinAddr
    || !_config.vaultProxyAddr
    || !_config.curationProxyAddr) {
  console.log('Config is missing fields.')
  exports.error = true
}
else {
  console.log(
    '=============='
    + '\nLoaded Config:'
    + '\n=============='
    + '\nDeveloper Proxy Address: ' + _config.devProxyAddr
    + '\nBot Proxy Address:       ' + _config.botProxyAddr
    + '\nInstance Proxy Address:  ' + _config.instanceProxyAddr
    + '\nService Proxy Address:   ' + _config.serviceProxyAddr
    + '\nPublic Storage Address:  ' + _config.publicStorageAddr
    + '\nManagement Address:      ' + _config.mgmtAddr
    + '\nBotcoin Address:         ' + _config.botcoinAddr
    + '\nVault Proxy Address:     ' + _config.vaultProxyAddr
    + '\nCuration Proxy Address:  ' + _config.curationProxyAddr
    + '\n'
  )

  exports.devProxyAddr = _config.devProxyAddr
  exports.botProxyAddr = _config.botProxyAddr
  exports.instanceProxyAddr = _config.instanceProxyAddr
  exports.serviceProxyAddr = _config.serviceProxyAddr
  exports.publicStorageAddr = _config.publicStorageAddr
  exports.mgmtAddr = _config.mgmtAddr
  exports.botcoinAddr = _config.botcoinAddr
  exports.vaultProxyAddr = _config.vaultProxyAddr
  exports.curationProxyAddr = _config.curationProxyAddr
}
