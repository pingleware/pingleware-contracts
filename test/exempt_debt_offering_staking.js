const ExemptDebtOfferingStaking = artifacts.require("ExemptDebtOfferingStaking");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("finance/debt/ExemptDebtOfferingStaking", function (/* accounts */) {
  it("should assert true", async function () {
    await ExemptDebtOfferingStaking.deployed();
    return assert.isTrue(true);
  });
});
