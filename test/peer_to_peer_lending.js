const PeerToPeerLending = artifacts.require("PeerToPeerLending");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("PeerToPeerLending", function (/* accounts */) {
  it("should assert true", async function () {
    await PeerToPeerLending.deployed();
    return assert.isTrue(true);
  });
});
