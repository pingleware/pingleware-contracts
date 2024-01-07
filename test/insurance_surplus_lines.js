const InsuranceSurplusLines = artifacts.require("InsuranceSurplusLines");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("insurance/InsuranceSurplusLines", function (/* accounts */) {
  it("should assert true", async function () {
    await InsuranceSurplusLines.deployed();
    return assert.isTrue(true);
  });
});
