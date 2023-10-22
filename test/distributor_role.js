const DistributorRole = artifacts.require("DistributorRole");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("DistributorRole", function (/* accounts */) {
  it("should assert true", async function () {
    await DistributorRole.deployed();
    return assert.isTrue(true);
  });
});
