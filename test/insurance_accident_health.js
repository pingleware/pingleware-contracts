const InsuranceAccidentHealth = artifacts.require("InsuranceAccidentHealth");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("insurance/InsuranceAccidentHealth", function (/* accounts */) {
  it("should assert true", async function () {
    await InsuranceAccidentHealth.deployed();
    return assert.isTrue(true);
  });
});
