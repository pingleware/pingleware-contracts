const InsuranceHomeowners = artifacts.require("InsuranceHomeowners");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("InsuranceHomeowners", function (/* accounts */) {
  it("should assert true", async function () {
    await InsuranceHomeowners.deployed();
    return assert.isTrue(true);
  });
});
