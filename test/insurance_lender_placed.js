const InsuranceLenderPlaced = artifacts.require("InsuranceLenderPlaced");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("InsuranceLenderPlaced", function (/* accounts */) {
  it("should assert true", async function () {
    await InsuranceLenderPlaced.deployed();
    return assert.isTrue(true);
  });
});