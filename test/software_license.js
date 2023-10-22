const SoftwareLicense = artifacts.require("SoftwareLicense");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("SoftwareLicense", function (/* accounts */) {
  it("should assert true", async function () {
    await SoftwareLicense.deployed();
    return assert.isTrue(true);
  });
});
