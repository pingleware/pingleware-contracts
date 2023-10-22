const SupplyChain = artifacts.require("SupplyChain");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("SupplyChain", function (/* accounts */) {
  it("should assert true", async function () {
    await SupplyChain.deployed();
    return assert.isTrue(true);
  });
});
