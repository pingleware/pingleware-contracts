const Pawn = artifacts.require("Pawn");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("retail/Pawn", function (/* accounts */) {
  it("should assert true", async function () {
    await Pawn.deployed();
    return assert.isTrue(true);
  });
});
