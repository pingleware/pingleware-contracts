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
