const POTUS = artifacts.require("POTUS");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("government/federal/POTUS", function (/* accounts */) {
  it("should assert true", async function () {
    await POTUS.deployed();
    return assert.isTrue(true);
  });
});
