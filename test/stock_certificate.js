const StockCertificate = artifacts.require("StockCertificate");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("StockCertificate", function (/* accounts */) {
  it("should assert true", async function () {
    await StockCertificate.deployed();
    return assert.isTrue(true);
  });
});
