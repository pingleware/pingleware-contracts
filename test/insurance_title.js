const TitleInsurance = artifacts.require("TitleInsurance");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("insurance/InsuranceTitle", function (/* accounts */) {
  it("should assert true", async function () {
    await TitleInsurance.deployed();
    return assert.isTrue(true);
  });
});
