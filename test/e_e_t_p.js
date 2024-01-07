const EETP = artifacts.require("EETP");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("energy/EETP", function (/* accounts */) {
  it("should assert true", async function () {
    await EETP.deployed();
    return assert.isTrue(true);
  });
});
