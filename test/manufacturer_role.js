const ManufacturerRole = artifacts.require("ManufacturerRole");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("scm/ManufacturerRole", function (/* accounts */) {
  it("should assert true", async function () {
    await ManufacturerRole.deployed();
    return assert.isTrue(true);
  });
});
