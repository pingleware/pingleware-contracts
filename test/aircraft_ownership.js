const AircraftOwnership = artifacts.require("AircraftOwnership");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("aviation/AircraftOwnership", function (accounts) {
  it("should assert true", async function () {
    await AircraftOwnership.deployed();
    return assert.isTrue(true);
  });
  it("get owner share",async function(){
    const contractInstance = await AircraftOwnership.deployed();
    const owners = await contractInstance.getOwners()
    return assert.equal(owners.length,1,"expected to have 1 owner")
  })
  it("transfer 10% to account[1]", async function(){
    const contractInstance = await AircraftOwnership.deployed();
    await contractInstance.transfer(accounts[1],10)
    const share = await contractInstance.getOwnership(accounts[1]);
    const owners = await contractInstance.getOwners()
    console.log(share)
    return assert.equal(owners.length,1,"expected to have 2 owners")  
  })
  it("transfer 5% from accounts[1] to accounts[2]",async function(){
    const contractInstance = await AircraftOwnership.deployed();
    await contractInstance.transferFrom(accounts[1],accounts[2],5)
    const share = await contractInstance.getOwnership(accounts[2]);
    const owners = await contractInstance.getOwners()
    console.log(share)
    return assert.equal(owners.length,3,"expected to have 3 owners")  
  })
}); 
