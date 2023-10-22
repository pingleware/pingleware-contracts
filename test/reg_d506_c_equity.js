const RegD506CEquity = artifacts.require("RegD506CEquity");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("RegD506CEquity", function (/* accounts */) {
  it("should assert true", async function () {
    await RegD506CEquity.deployed();
    return assert.isTrue(true);
  });
});
