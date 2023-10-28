const Historical = artifacts.require("Historical");
const Reg3A11Equity = artifacts.require("Reg3A11Equity");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("finance/elmx/Historical", function (accounts) {
  let tokenAddress;

  it("should assert true", async function () {
    await Historical.deployed();
    return assert.isTrue(true);
  });
  it("add collection of quotes",async function() {
    const historicalInstance = await Historical.deployed();
    const reg3a11equityInstance = await Reg3A11Equity.new(accounts[1],"FL","Section 3(a)(11) Equity","PRESS.3A11.X",4000000,5);
    tokenAddress = reg3a11equityInstance.address;
    const tx1 = await historicalInstance.addQuote(reg3a11equityInstance.address,"PRESS.3A11.X",100,7,5);
    const tx2 = await historicalInstance.addQuote(reg3a11equityInstance.address,"PRESS.3A11.X",100,8,6);
    const tx3 = await historicalInstance.addQuote(reg3a11equityInstance.address,"PRESS.3A11.X",100,8,6);
    const tx4 = await historicalInstance.addQuote(reg3a11equityInstance.address,"PRESS.3A11.X",100,10,8);
    const tx5 = await historicalInstance.addQuote(reg3a11equityInstance.address,"PRESS.3A11.X",100,12,10);
    const tx6 = await historicalInstance.addQuote(reg3a11equityInstance.address,"PRESS.3A11.X",100,8,6);
    const tx7 = await historicalInstance.addQuote(reg3a11equityInstance.address,"PRESS.3A11.X",100,12,10);
    const tx8 = await historicalInstance.addQuote(reg3a11equityInstance.address,"PRESS.3A11.X",100,14,12);
    const tx9 = await historicalInstance.addQuote(reg3a11equityInstance.address,"PRESS.3A11.X",100,20,18);
    const tx10 = await historicalInstance.addQuote(reg3a11equityInstance.address,"PRESS.3A11.X",100,22,20);
    return assert.isTrue(true);
  })
  it("get historical",async function(){
    const historicalInstance = await Historical.deployed();
    const tx = await historicalInstance.getHistorical(tokenAddress);
    console.log(tx);
    return assert.isTrue(true);
  })
  it("get historical by range",async function(){
    const historicalInstance = await Historical.deployed();
    const beginning = new Date("-1 hour").getTime();
    const ending = new Date("+1 hour").getTime();
    const allquotes = await historicalInstance.getHistorical(tokenAddress);
    let quotes = [];
    for(let i=0; i<allquotes.length; i++) {
      if (allquotes[i].timestamp >= beginning && allquotes[i].timestamp < ending) {
        quotes.push(allquotes[i]);
      }
    }
    console.log(quotes);
    return assert.isTrue(true);
  })
});
