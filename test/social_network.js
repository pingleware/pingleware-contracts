const SocialNetwork = artifacts.require("SocialNetwork");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("social/SocialNetwork", function (/* accounts */) {
  it("should assert true", async function () {
    await SocialNetwork.deployed();
    return assert.isTrue(true);
  });
});
