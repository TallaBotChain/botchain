const ArgumentParser = require('argparse').ArgumentParser;

const parser = new ArgumentParser({
  version: '0.0.1',
  addHelp: true,
  description: 'Botchain Management CLI'
});

const cmdLvl1 = parser.addSubparsers({
  title: 'subcommands',
  dest: 'subcommand_name'
})

const deploy = cmdLvl1.addParser('deploy',{
  desciption:'All actions related to deploying a BotChain contract to Ethereum.',
  addHelp: true
});

const get = cmdLvl1.addParser('get',{
  desciption:'All actions related to reading the current state of the contracts.',
  addHelp: true
});

const update = cmdLvl1.addParser('update',{
  desciption:'All actions related to updating state in the currently deployed contracts.',
  addHelp: true
});

const registration = cmdLvl1.addParser('registration',{
  desciption:'All actions related to registering an entity on BotChain.',
  addHelp: true
});

const regCmds = registration.addSubparsers({
  title: 'Registration Commands',
  parents: [registration],
  dest: 'registration'
})

const regApprove = regCmds.addParser('approve',{
  desciption:'Approve a developer that has previously registered.',
  addHelp: true
});

regApprove.addArgument(
  [ '-a', '--address' ],
  {
    help: 'Approve a developer at the provided address.',
    defaultValue: '0x0',
    nargs: 1
  }
);

regApprove.addArgument(
  [ '-p', '--password' ],
  {
    help: 'Password for the Network Management Address.',
    nargs: 1,
    required: true
  }
);

parser.addArgument(
  [ '-i', '--rpc' ],
  {
    help: 'Perform read against Ethereum node on localhost:8454.',
    defaultValue: 'http://localhost',
    nargs: 1
  }
);

parser.addArgument(
  [ '-P', '--port' ],
  {
    help: 'The port to speak to the supplied Ethereum Node\'s RPC.',
    defaultValue: '8454',
    nargs: 1
  }
);

deploy.addArgument(
  [ '-p', '--password' ],
  {
    help: 'Password for the Network Management Address.',
    nargs: 1,
    required: true
  }
);

update.addArgument(
  [ '-p', '--password' ],
  {
    help: 'Password for the Network Management Address.',
    nargs: 1,
    required: true
  }
);

deploy.addArgument(
  [ '-i', '--impl' ],
  {
    help: 'Deploy one of the supported contracts to currently connected network.',
    choices: ['dev','bot','instance','service'],
    nargs: 1
  }
);

module.exports = parser.parseArgs();
