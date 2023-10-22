const EnergyStore = artifacts.require("EnergyStore");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("EnergyStore", function (/* accounts */) {
  it("should assert true", async function () {
    await EnergyStore.deployed();
    return assert.isTrue(true);
  });
});
