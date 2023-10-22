const BondCertificate = artifacts.require("BondCertificate");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("BondCertificate", function (/* accounts */) {
  it("should assert true", async function () {
    await BondCertificate.deployed();
    return assert.isTrue(true);
  });
});
