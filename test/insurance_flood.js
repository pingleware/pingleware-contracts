const InsuranceFlood = artifacts.require("InsuranceFlood");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("insurance/InsuranceFlood", function (/* accounts */) {
  it("should assert true", async function () {
    await InsuranceFlood.deployed();
    return assert.isTrue(true);
  });
});
