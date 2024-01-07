const SCOTUS = artifacts.require("SCOTUS");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("government/federal/SCOTUS", function (/* accounts */) {
  it("should assert true", async function () {
    await SCOTUS.deployed();
    return assert.isTrue(true);
  });
});
