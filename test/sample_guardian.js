const SampleGuardian = artifacts.require("SampleGuardian");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("healthcare/pharma/SampleGuardian", function (/* accounts */) {
  it("should assert true", async function () {
    await SampleGuardian.deployed();
    return assert.isTrue(true);
  });
});
