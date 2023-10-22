const InsuranceMediGap = artifacts.require("InsuranceMediGap");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("InsuranceMediGap", function (/* accounts */) {
  it("should assert true", async function () {
    await InsuranceMediGap.deployed();
    return assert.isTrue(true);
  });
});
