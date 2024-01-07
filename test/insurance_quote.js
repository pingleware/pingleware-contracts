const InsuranceQuote = artifacts.require("InsuranceQuote");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("insurance/InsuranceQuote", function (/* accounts */) {
  it("should assert true", async function () {
    await InsuranceQuote.deployed();
    return assert.isTrue(true);
  });
});
