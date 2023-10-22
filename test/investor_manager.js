const InvestorManager = artifacts.require("InvestorManager");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("InvestorManager", function (/* accounts */) {
  it("should assert true", async function () {
    await InvestorManager.deployed();
    return assert.isTrue(true);
  });
});
