const Inventory = artifacts.require("Inventory");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("retail/Inventory", function (/* accounts */) {
  it("should assert true", async function () {
    await Inventory.deployed();
    return assert.isTrue(true);
  });
});
