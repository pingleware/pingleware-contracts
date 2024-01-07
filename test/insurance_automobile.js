const InsuranceAutomobile = artifacts.require("InsuranceAutomobile");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("insurance/InsuranceAutomobile", function (/* accounts */) {
  it("should assert true", async function () {
    await InsuranceAutomobile.deployed();
    return assert.isTrue(true);
  });
});
