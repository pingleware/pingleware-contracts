const ExchangeFee = artifacts.require("ExchangeFee");
const Reg3A11Equity = artifacts.require("Reg3A11Equity");
const BestBooks = artifacts.require("BestBooks");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("finance/elmx/ExchangeFee", function (accounts) {
  it("should assert true", async function () {
    await ExchangeFee.deployed();
    return assert.isTrue(true);
  }); 
  it("add fee",async function(){
    const exchangeFeeInstance = await ExchangeFee.deployed();
    const bestbooksInstance = await BestBooks.deployed();
    await bestbooksInstance.createAccount("CASH","Cash");
    await bestbooksInstance.createAccount("FEES","Income");
    const tokenInstance = await Reg3A11Equity.new(accounts[1],"FL","Florida Section 3(a)(11) Offering","PRESS.FL.3A11",4000000,5);
    const tx = await exchangeFeeInstance.addFee(tokenInstance.address,5);
    console.log(tx);
    if (tx.logs[0].args) {
      const fee = tx.logs[0].args[1].toNumber();
      console.log(fee);
      return assert.equal(fee,5,"expected fee to be adjusted to 5%");
    } else {
      return assert.isTrue(true)
    }
  })
  it("subtract fee",async function(){
    const exchangeFeeInstance = await ExchangeFee.deployed();
    const tokenInstance = await Reg3A11Equity.new(accounts[1],"FL","Florida Section 3(a)(11) Offering","PRESS.FL.3A11",4000000,5);
    const txAdd = await exchangeFeeInstance.addFee(tokenInstance.address,5);
    const txSub = await exchangeFeeInstance.subFee(tokenInstance.address,3);
    console.log(txSub);
    if (txSub.logs[0].args) {
      const fee = txSub.logs[0].args[1].toNumber();
      console.log(fee);
      return assert.equal(fee,3,"expected fee to be adjusted to 3%");
    } else {
      return assert.isTrue(true)
    }
  })
  it("get total fee",async function(){
    const exchangeFeeInstance = await ExchangeFee.deployed();
    const tokenInstance = await Reg3A11Equity.new(accounts[1],"FL","Florida Section 3(a)(11) Offering","PRESS.FL.3A11",4000000,5);
    const txAdd = await exchangeFeeInstance.addFee(tokenInstance.address,5);
    const txSub = await exchangeFeeInstance.subFee(tokenInstance.address,3);
    const fee = await exchangeFeeInstance.getTotal(tokenInstance.address);
    console.log(fee.toNumber())
    return assert.equal(fee.toNumber(),2,"expected fee adjusted to 2%");
  })
  it("cleanuo",async function(){
    const bestbooksInstance = await BestBooks.deployed();
    await bestbooksInstance.deleteAccount("CASH");
    await bestbooksInstance.deleteAccount("FEES");
    return assert.isTrue(true)
  })
}); 
