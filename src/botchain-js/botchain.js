'use strict';

var botchain = module.exports;

// module information
botchain.version = 'v' + require('../package.json').version;
botchain.versionGuard = function(version) {
  if (version !== undefined) {
    var message = 'Found an instance of botchainjs already instantiated. ' +
      'Please make sure to require botchainjs and check that submodules do' +
      ' not also include botchainjs as a dependency.';
    throw new Error(message);
  }
};
botchain.versionGuard(global._botchain);
global._botchain = botchain.version;

botchain.Registry = require('./registry')
botchain.Curation = require('./curation')
