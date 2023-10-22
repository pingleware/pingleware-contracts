const RINS = artifacts.require("RINS");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("RINS", function (/* accounts */) {
  it("should assert true", async function () {
    await RINS.deployed();
    return assert.isTrue(true);
  });
});
