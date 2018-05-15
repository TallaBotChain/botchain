const ArgumentParser = require('argparse').ArgumentParser;

/*
 *
 *
 *
 */

const topLevelParser = new ArgumentParser({
  version: '0.0.1',
  addHelp: true,
  description: 'Botchain Management CLI'
});

const commands = topLevelParser.addSubparsers({
  title: 'subcommands',
  dest: 'subcommand_name'
})

const deploy = commands.addParser('deploy',{
  desciption:'All actions related to deploying a BotChain contract to Ethereum.',
  addHelp: true
});

const deployCommands = deploy.addSubparsers({
  title: 'Contract Deployment Commands',
  parents: [deploy],
  dest: 'deploy'
})

deployCommands.addParser('registry',{
  description:'Deploy a registry contract.',
  addHelp: true
});

const get = commands.addParser('get',{
  desciption:'All actions related to reading the current state of the contracts.',
  addHelp: true
});

const update = commands.addParser('update',{
  desciption:'All actions related to updating state in the currently deployed contracts.',
  addHelp: true
});

const registration = commands.addParser('registration',{
  desciption:'All actions related to registering an entity on BotChain.',
  addHelp: true
});

const regCommands = registration.addSubparsers({
  title: 'Registration Commands',
  parents: [registration],
  dest: 'registration'
})

regCommands.addParser('approve',{
  description:'Approve a developer that has previously registered.',
  addHelp: true
});

regCommands.addParser('get-owner',{
  description:'Get the address stored at the provided index.',
  addHelp: true
});

regCommands.addParser('get-id',{
  description:'Get the address stored at the provided index.',
  addHelp: true
});

regCommands.addParser('get-url',{
  description:'Get the address stored at the provided index.',
  addHelp: true
});

regCommands.addParser('revoke-approval',{
  description:'Revoke approval for the developer at the provided address.',
  addHelp: true
});

regCommands.addParser('check-approval',{
  description:'Get the address stored at the provided index.',
  addHelp: true
});

regCommands.choices['approve'].addArgument(
  [ '-a', '--address' ],
  {
    help: 'Approve a developer at the provided address.',
    defaultValue: '0x0',
    nargs: 1
  }
);

regCommands.choices['approve'].addArgument(
  [ '-p', '--password' ],
  {
    help: 'Password for the Network Management Address.',
    nargs: 1,
    required: true
  }
);

regCommands.choices['get-id'].addArgument(
  [ '-a', '--address' ],
  {
    help: 'Address of the desired developer.',
    nargs: 1,
    required: true
  }
);

regCommands.choices['get-url'].addArgument(
  [ '-i', '--index' ],
  {
    help: 'Index of the desired address.',
    nargs: 1,
    required: true
  }
);

regCommands.choices['get-owner'].addArgument(
  [ '-i', '--index' ],
  {
    help: 'Index of the desired address.',
    nargs: 1,
    required: true
  }
);

regCommands.choices['revoke-approval'].addArgument(
  [ '-a', '--address' ],
  {
    help: 'Address of the entry to check.',
    nargs: 1,
    required: true
  }
);

regCommands.choices['revoke-approval'].addArgument(
  [ '-p', '--password' ],
  {
    help: 'Password for the Network Management Address.',
    nargs: 1,
    required: true
  }
);

regCommands.choices['check-approval'].addArgument(
  [ '-a', '--address' ],
  {
    help: 'Address of the entry to check.',
    nargs: 1
  }
);

regCommands.choices['check-approval'].addArgument(
  [ '-i', '--index' ],
  {
    help: 'Index of the entry to check.',
    nargs: 1
  }
);

deployCommands.choices['registry'].addArgument(
  [ '-t', '--type' ],
  {
    help: 'Type of registry to deploy (dev|bot|instance|service).',
    nargs: 1
  }
);

topLevelParser.addArgument(
  [ '-t', '--timeout' ],
  {
    help: 'The URI for an Ethereum Node hosting an open RPC (defaults to localhost).',
    defaultValue: '1000',
    nargs: 1
  }
);

topLevelParser.addArgument(
  [ '-r', '--rpc' ],
  {
    help: 'The URI for an Ethereum Node hosting an open RPC (defaults to Kovan on INFURA).',
    defaultValue: 'https://kovan.infura.io/B9pg6oqTiZgkeibkCKjV',
    nargs: 1
  }
);

topLevelParser.addArgument(
  [ '-P', '--port' ],
  {
    help: 'The port on which to speak to the supplied Ethereum Node\'s RPC (defaults to 8545).',
    defaultValue: '',
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

module.exports = topLevelParser.parseArgs();
