const DirectEquityOffering = artifacts.require("DirectEquityOffering");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("finance/equity/DirectEquityOffering", function (/* accounts */) {
  it("should assert true", async function () {
    await DirectEquityOffering.deployed();
    return assert.isTrue(true);
  });
});
