const InsuranceWorkersCompensation = artifacts.require("InsuranceWorkersCompensation");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("InsuranceWorkersCompensation", function (/* accounts */) {
  it("should assert true", async function () {
    await InsuranceWorkersCompensation.deployed();
    return assert.isTrue(true);
  });
});
