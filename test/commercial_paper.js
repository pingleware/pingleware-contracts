const CommercialPaper = artifacts.require("CommercialPaper");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("CommercialPaper", function (/* accounts */) {
  it("should assert true", async function () {
    await CommercialPaper.deployed();
    return assert.isTrue(true);
  });
});
