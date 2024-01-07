const Membership = artifacts.require("Membership");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("membership/Membership", function (/* accounts */) {
  it("should assert true", async function () {
    await Membership.deployed();
    return assert.isTrue(true);
  });
});
