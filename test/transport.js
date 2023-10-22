const Transport = artifacts.require("Transport");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("Transport", function (/* accounts */) {
  it("should assert true", async function () {
    await Transport.deployed();
    return assert.isTrue(true);
  });
});
