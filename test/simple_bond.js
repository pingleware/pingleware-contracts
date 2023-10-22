const SimpleBond = artifacts.require("SimpleBond");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("SimpleBond", function (/* accounts */) {
  it("should assert true", async function () {
    await SimpleBond.deployed();
    return assert.isTrue(true);
  });
});
