const ATS = artifacts.require("ATS");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("ATS", function (/* accounts */) {
  it("should assert true", async function () {
    await ATS.deployed();
    return assert.isTrue(true);
  });
});
