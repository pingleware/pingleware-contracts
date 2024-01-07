const SoftwareLicenseMetadata = artifacts.require("SoftwareLicenseMetadata");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("technology/SoftwareLicenseMetadata", function (/* accounts */) {
  it("should assert true", async function () {
    await SoftwareLicenseMetadata.deployed();
    return assert.isTrue(true);
  });
});
