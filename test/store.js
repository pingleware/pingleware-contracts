const Store = artifacts.require("Store");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("retail/Store", function (/* accounts */) {
  it("should assert true", async function () {
    await Store.deployed();
    return assert.isTrue(true);
  });
});
