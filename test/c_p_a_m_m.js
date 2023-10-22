const CPAMM = artifacts.require("CPAMM");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("CPAMM", function (/* accounts */) {
  it("should assert true", async function () {
    await CPAMM.deployed();
    return assert.isTrue(true);
  });
});
