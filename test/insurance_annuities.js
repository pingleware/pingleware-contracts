const InsuranceAnnuities = artifacts.require("InsuranceAnnuities");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("InsuranceAnnuities", function (/* accounts */) {
  it("should assert true", async function () {
    await InsuranceAnnuities.deployed();
    return assert.isTrue(true);
  });
});