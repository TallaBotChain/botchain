let shell = require('shelljs');
var version = require('../package.json').version;
let fs = require('file-system');
let fm = require('file-match');
shell.config.fatal = true

let srcFolder = '../src/';
let m4 = '../src/constants.m4';

var filter = fm([
  '*.{sol}'
]);

let cwd

fs.recurse('../src/', [
  '**/',
  '**/*.sol'
], function(filepath, relative, filename) {  
  if (filename) {
    console.log('File: ', filename.slice(0,-4));
  } else {
    console.log('Dir: ',filepath)
  // it's folder
  }
});

async function applyM4(err, files) {
  files.forEach(file => {
    fs.stat(srcFolder + file, (err,info) => { console.log(info); })
  });
}

// Find m4 macro file and apply expansion on all src files.
//fs.readdir(srcFolder, applyM4);

//shell.rm('-rf', 'dist')
//shell.mkdir('-p', 'dist')
//
//shell.exec('npx browserify src/botchain.js --s botchain', { silent: true })
//  .to('dist/botchain-' + version + '.js').to('cli/modules/botchain-'+version+'.js')
//shell.echo('Generated file: dist/botchain-' + version + '.js.')


/**
 *  Minification using uglify-js currently chokes on ES6+ async and arrow functions
 *  so we skip this step for now. Once better support exists we should provide the
 *  minfied version using the commands commented out below:

shell.cp('LICENSE.js', 'dist/botchain-' + version + '.min.js')
shell.exec('cat dist/botchain-' + version + '.js | npx uglifyjs -c', { silent: true })
  .toEnd('dist/botchain-' + version + '.min.js')
shell.echo('Generated file: dist/botchain-' + version + '.min.js.')
 */

