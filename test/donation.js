const Donation = artifacts.require("Donation");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("Donation", function (/* accounts */) {
  it("should assert true", async function () {
    await Donation.deployed();
    return assert.isTrue(true);
  });
});
