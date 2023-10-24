const AgriTrade = artifacts.require("AgriTrade");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("agriculture/AgriTrade", function (accounts) {
  it("should assert true", async function () {
    await AgriTrade.deployed();
    return assert.isTrue(true);
  });
  it("fund account[1] with 2000 coins", async () =>{
    const contractInstance = await AgriTrade.deployed();
    await contractInstance.fundaddr(accounts[1])
    const balance = await contractInstance.getBalance(accounts[1])
    assert.equal(balance,2000,"expected to be 2000")
  })
  it("farmer produce", async function(){
    const contractInstance = await AgriTrade.deployed();
    //contractInstance.produce(0,"John","FL","Rhubbard",100,1000,5)
    //const product = contractInstance.getproduce(0)
    //console.log(produce)
  })
}); 
