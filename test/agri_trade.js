const AgriTrade = artifacts.require("AgriTrade");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("AgriTrade", function (accounts) {
  it("should assert true", async function () {
    const contractInstance = await AgriTrade.deployed();
    return assert.isTrue(true);
  });
  it("fund account[1] with 2000 coins", async () =>{
    const contractInstance = await AgriTrade.deployed();
    await contractInstance.fundaddr(accounts[1])
    const balance = await contractInstance.getBalance(accounts[1])
    assert.equal(balance,2000,"expected to be 2000")
  })
});
