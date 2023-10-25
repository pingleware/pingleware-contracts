const BestBooks = artifacts.require("BestBooks");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("finance/elmx/BestBooks", function (/* accounts */) {
  it("should assert true", async function () {
    await BestBooks.deployed();
    return assert.isTrue(true);
  });
  it("add entry",async function(){
    const bestbooksInstance = await BestBooks.deployed();
    await bestbooksInstance.addEntry(1698203550,"Cash","Gas","Gas Fuel Purchase",30,30)
    return assert.isTrue(true);
  })
  it("get balance",async function(){
    const bestbooksInstance = await BestBooks.deployed();
    const balance = await bestbooksInstance.getBalance("Cash");
    return assert.equal(balance.words[0],30,"expected balance to be $30");
  })
  it("get ledger entry",async function(){
    const bestbooksInstance = await BestBooks.deployed();
    const entry = await bestbooksInstance.getLedgerEntry(0);
    return assert.equal(entry[1],"Cash","expected account to be Cash");
  })
  it("get ledger entry by range",async function(){
    const bestbooksInstance = await BestBooks.deployed();
    const entry = await bestbooksInstance.getLedgerEntryByRange(1698203550,1729825949);
    console.log(entry);
    return assert.isTrue(true);
  })
  it("create account",async function(){
    const bestbooksInstance = await BestBooks.deployed();
    await bestbooksInstance.createAccount("Sales","Sales");
    return assert.isTrue(true);
  })
  it("updated account",async function(){
    const bestbooksInstance = await BestBooks.deployed();
    await bestbooksInstance.createAccount("Bad","Good");
    await bestbooksInstance.updateAccount("Bad","Bad");
    return assert.isTrue(true);
  })
  it("delete account",async function(){
    const bestbooksInstance = await BestBooks.deployed();
    await bestbooksInstance.deleteAccount("Bad");
    return assert.isTrue(true);
  })
  it("get an account",async function(){
    const bestbooksInstance = await BestBooks.deployed();
    const account = await bestbooksInstance.getAccount("Sales");
    console.log(account);
    return assert.isTrue(true);
  })
}); 
