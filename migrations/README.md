# Migrations

The migration files are required by truffle to deploy the compiled contract to the blockchain EVM. A migration file is created for each Contract and not for abstract contracts, interfaces nor libraries as these cannot be instantiated, by using the command,

```
truffle create migration <CONTRACT NAME>
```

then each file must be modified to add the CONTRACT to the _deployer,

```
const Contract = artifacts.require("CONTRACT NAME")

module.exports = function(_deployer) {
  // Use deployer to state migration tasks.
  _deployer.deploy(Contract)
};

```

## Deploy a Single Contract (or Migration)

You do not need to change into the migrations directory to deploy a single migration file.

```
Usage:        truffle migrate [--reset] [--f <number>] [--to <number>]
                                [--compile-all] [--compile-none] [--verbose-rpc] [--interactive]
                                [--skip-dry-run] [--describe-json] [--dry-run] [--network <name>] [--config <file>] [--quiet]
  Description:  Run migrations to deploy contracts
  Options: 
  		--reset
      		    Run all migrations from the beginning, instead of running from the last completed migration.
  		--f <number>
      		    Run contracts from a specific migration. The number refers to the prefix of the migration file.
                --to <number>
                    Run contracts to a specific migration. The number refers to the prefix of the migration file.
                --compile-all
                    Compile all contracts instead of intelligently choosing which contracts need to be compiled.
                --compile-none
                    Do not compile any contracts before migrating.
                --verbose-rpc
                    Log communication between Truffle and the Ethereum client.
                --interactive
                    Prompt to confirm that the user wants to proceed after the dry run.
                --dry-run
                    Only perform a test or 'dry run' migration.
                --skip-dry-run
                    Do not run a test or 'dry run' migration.
                --describe-json
                    Adds extra verbosity to the status of an ongoing migration
                --network <name>
                    Specify the network to use. Network name must exist in the configuration.
                --config <file>
                    Specify configuration file to be used. The default is truffle-config.js
                --quiet
                    Suppress excess logging output.
```

```
truffle migrate --compile-none --f 1697948405 --to 1697948405
```

where the number is the migration file prefix. Using compile-none, if your contract has alread been compiled using

```
truffle compile
```

a shell script is provided called single_migration.sh
