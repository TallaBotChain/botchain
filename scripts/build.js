
var shell = require('shelljs')
shell.config.fatal = true
var version = require('../package.json').version

shell.rm('-rf', 'dist')
shell.mkdir('-p', 'dist')

shell.exec('npx browserify src/botchain.js --s botchain', { silent: true })
  .to('dist/botchain-' + version + '.js').to('cli/modules/botchain-'+version+'.js')
shell.echo('Generated file: dist/botchain-' + version + '.js.')

/**
 *  Minification using uglify-js currently chokes on ES6+ async and arrow functions
 *  so we skip this step for now. Once better support exists we should provide the
 *  minfied version using the commands commented out below:

shell.cp('LICENSE.js', 'dist/botchain-' + version + '.min.js')
shell.exec('cat dist/botchain-' + version + '.js | npx uglifyjs -c', { silent: true })
  .toEnd('dist/botchain-' + version + '.min.js')
shell.echo('Generated file: dist/botchain-' + version + '.min.js.')
 */

