const CountyBusStops = artifacts.require("CountyBusStops");
const {Web3} = require("web3");
/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("CountyBusStops", function (accounts) {
  it("should assert true", async function () {
    await CountyBusStops.deployed();
    return assert.isTrue(true);
  });
});
