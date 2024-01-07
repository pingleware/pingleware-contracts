const TransportationPayment = artifacts.require("TransportationPayment");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("transportation/TransportationPayment", function (/* accounts */) {
  it("should assert true", async function () {
    await TransportationPayment.deployed();
    return assert.isTrue(true);
  });
});
