const InsuranceServiceWarranty = artifacts.require("InsuranceServiceWarranty");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("insurance/InsuranceServiceWarranty", function (/* accounts */) {
  it("should assert true", async function () {
    await InsuranceServiceWarranty.deployed();
    return assert.isTrue(true);
  });
});
