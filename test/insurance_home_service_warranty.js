const InsuranceHomeServiceWarranty = artifacts.require("InsuranceHomeServiceWarranty");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("insurance/InsuranceHomeServiceWarranty", function (/* accounts */) {
  it("should assert true", async function () {
    await InsuranceHomeServiceWarranty.deployed();
    return assert.isTrue(true);
  });
});
