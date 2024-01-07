const InsuranceLongTermCare = artifacts.require("InsuranceLongTermCare");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("insurance/InsuranceLongTermCare", function (/* accounts */) {
  it("should assert true", async function () {
    await InsuranceLongTermCare.deployed();
    return assert.isTrue(true);
  });
});
