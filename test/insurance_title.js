const InsuranceTitle = artifacts.require("InsuranceTitle");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("InsuranceTitle", function (/* accounts */) {
  it("should assert true", async function () {
    await InsuranceTitle.deployed();
    return assert.isTrue(true);
  });
});
