const Course = artifacts.require("Course");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("education/Course", function (/* accounts */) {
  it("should assert true", async function () {
    await Course.deployed();
    return assert.isTrue(true);
  });
});
