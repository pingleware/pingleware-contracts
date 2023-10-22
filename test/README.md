# Testing

Each test case is created for each Contract and not for abstract contracts, interfaces nor libraries as these cannot be instantiated, by using the command,

```
truffle create test <CONTRACT NAME>
```

the test file contains the basic deploy test, and additional tests are related to the contract under test,

```
const Contract = artifacts.require("CONTRACT NAME");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("CONTRACT NAME", function (/* accounts */) {
  it("should assert true", async function () {
    await Contract.deployed();
    return assert.isTrue(true);
  });
});

```

You can use the Ethereum Contract Creator, and from the settings dialog obtain the RPC host and port

![1697948745720](image/README/1697948745720.png)

Then edit truffle-config.js,

```
development: {
      host: "localhost",     // Localhost (default: none)
      port: 7535,            // Standard Ethereum port (default: none)
      network_id: "*",       // Any network (default: none)
    },

// IMPORTANT: change the following path to the contracts you want to test
  contracts_directory: './contracts/government/county/',

  // Set default mocha options here, use special reporters, etc.
  mocha: {
    // timeout: 100000
  },

  // Configure your compilers
  compilers: {
    solc: {
      version: "0.8.18",      // Fetch exact version from solc-bin (default: truffle's version)
      // docker: true,        // Use "0.5.1" you've installed locally with docker (default: false)
      settings: {          // See the solidity docs for advice about optimization and evmVersion
        optimizer: {
          enabled: true,
          runs: 1
        },
        evmVersion: "byzantium"
      }
    }
  },
```

To start test, change to the root directory, edit the contracts_directory value on truffle-config.js to the contract directory under test,

```
truffle compile
```

then issue the migrate and test command, the migrate and test commands are not dependent on the contracts_directory setting in truffle-config.js,

```
truffle migrate --reset
truffle test
```
