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
  it("create account",async function(){
    const bestbooksInstance = await BestBooks.deployed();
    const tx = await bestbooksInstance.createAccount("Sales","Income");
    console.log(tx);
    if (tx.logs[0].args.length > 0) {
      console.log(`${tx.logs[0].event}: ${tx.logs[0].args}`);
    } else {
    }
    return assert.isTrue(true);
  })
  it("updated account",async function(){
    const bestbooksInstance = await BestBooks.deployed();
    await bestbooksInstance.createAccount("Bad","Good");
    const tx = await bestbooksInstance.updateAccount("Bad","Bad");
    console.log(tx);
    if (tx.logs[0].args.length > 0) {
      console.log(tx.logs[0].args);
    }
    return assert.isTrue(true);
  })
  it("get an account",async function(){
    const bestbooksInstance = await BestBooks.deployed();
    const account = await bestbooksInstance.getAccount("Sales");
    console.log(account);
    return assert.isTrue(true);
  }) 
  it("delete account",async function(){
    const bestbooksInstance = await BestBooks.deployed();
    const tx = await bestbooksInstance.deleteAccount("Bad");
    console.log(tx);
    if (tx.logs[0].args.length > 0) {
      console.log(tx.logs[0].args);
    }
    return assert.isTrue(true);
  })
  it("add entry",async function(){
    const bestbooksInstance = await BestBooks.deployed();
    const txAccountCreatedCash = await bestbooksInstance.createAccount("Cash","Cash");
    const txAccountCreatedGas = await bestbooksInstance.createAccount("Gas","Expense");
    const tx = await bestbooksInstance.addEntry(1698203550,"Cash","Gas","Gas Fuel Purchase",30,30);
    console.log(tx);
    if (tx.logs[0].args.length > 0) {
      console.log(tx.logs[0].args);
      const ledgerIndex = tx.logs[0].args[0].toNumber();
      console.log(`Ledger index: ${ledgerIndex}`);
    }
    return assert.isTrue(true);
  })
  it("delete entry",async function(){
    const bestbooksInstance = await BestBooks.deployed();
    const txEntryAdded = await bestbooksInstance.addEntry(1698203550,"Cash","Gas","Gas Fuel Purchase",30,30);
    if (txEntryAdded.logs[0].args.length > 0) {
      const ledgerIndex = txEntryAdded.logs[0].args[0].toNumber();
      console.log(ledgerIndex);
      const tx = await bestbooksInstance.deleteEntry(ledgerIndex,"testing");
      console.log(tx);
      if (tx.logs[0].args.length > 0) {
        console.log(tx.logs[0].args);
      }  
    }
    return assert.isTrue(true);
  })
  it("get balance",async function(){
    const bestbooksInstance = await BestBooks.deployed();
    const txAdded = await bestbooksInstance.addEntry(1698203550,"Cash","Gas","Gas Fuel Purchase",30,30);
    console.log(txAdded);
    const balance = await bestbooksInstance.getBalance("Cash");
    let ledgerIndex;
    if (txAdded.logs[0].args) {
      ledgerIndex = txAdded.logs[0].args[0].toNumber();
      await bestbooksInstance.deleteEntry(ledgerIndex,"testing");
    }
    return assert.isTrue(balance.toNumber() > 0);
  })
  it("get ledger entry",async function(){
    const bestbooksInstance = await BestBooks.deployed();
    const txAdded = await bestbooksInstance.addEntry(1698203550,"Cash","Gas","Gas Fuel Purchase",30,30);
    if (txAdded.logs[0].args) {
      const ledgerIndex = txAdded.logs[0].args[0].toNumber();
      const entry = await bestbooksInstance.getLedgerEntry(ledgerIndex);
      console.log(entry);
      await bestbooksInstance.deleteEntry(ledgerIndex,"testing");
      return assert.equal(entry[1],"Cash","expected account to be Cash");
    } else {
      return assert.isTrue(true);
    }
  })
  it("get ledger entry by range",async function(){
    const bestbooksInstance = await BestBooks.deployed();
    const ledgerIndex = await bestbooksInstance.getLedgerIndex();
    var entries = [];
    for(let i=0; i<ledgerIndex.toNumber(); i++) {
      let entry =  await bestbooksInstance.getLedgerEntry(i);
      if (entry[0].toNumber() >= 1698203550 && entry[0].toNumber() < 1729825949) {
        entries.push(entry);
      }
    }
    console.log(entries);
    return assert.isTrue(true);
  })
  it("get ledger index or count",async function(){
    const bestbooksInstance = await BestBooks.deployed();
    const ledgerIndex = await bestbooksInstance.getLedgerIndex();
    console.log(ledgerIndex.toNumber());
    return assert.isTrue(true);
  })
  it("cleanup",async function(){
    const bestbooksInstance = await BestBooks.deployed();
    const ledgerIndex = await bestbooksInstance.getLedgerIndex();
    for(let i=0; i<ledgerIndex.toNumber();i++) {
      await bestbooksInstance.deleteEntry(i,"testing");
    }
    await bestbooksInstance.deleteAccount("Cash");
    await bestbooksInstance.deleteAccount("Sales");
    await bestbooksInstance.deleteAccount("Gas");
    return assert.isTrue(true);
  })
});  
