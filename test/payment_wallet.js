const PaymentWallet = artifacts.require("PaymentWallet");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("PaymentWallet", function (/* accounts */) {
  it("should assert true", async function () {
    await PaymentWallet.deployed();
    return assert.isTrue(true);
  });
});
