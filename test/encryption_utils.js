const EncryptionUtils = artifacts.require("EncryptionUtils");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("EncryptionUtils", function (/* accounts */) {
  it("should assert true", async function () {
    await EncryptionUtils.deployed();
    return assert.isTrue(true);
  });
});
