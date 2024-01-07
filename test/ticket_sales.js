const TicketSales = artifacts.require("TicketSales");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("retail/TicketSales", function (/* accounts */) {
  it("should assert true", async function () {
    await TicketSales.deployed();
    return assert.isTrue(true);
  });
});
