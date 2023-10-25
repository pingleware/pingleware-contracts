const InvestorManager = artifacts.require("InvestorManager");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("finance/elmx/InvestorManager", function (accounts) {
  it("should assert true", async function () {
    await InvestorManager.deployed();
    return assert.isTrue(true);
  });
  it("add investor as non-accredited",async function(){
    const investorManagerInstance = await InvestorManager.deployed();
    await investorManagerInstance.addInvestor(accounts[0]);
    const investor = await investorManagerInstance.getInvestor(accounts[0]);
    return assert.equal(investor[0],accounts[0],`expected ${accounts[0]}`);
  })
  it("is investor whitelisted",async function(){
    const investorManagerInstance = await InvestorManager.deployed();
    const status = await investorManagerInstance.isWhitelisted(accounts[0]);
    return assert.isTrue(status);
  })
  it("assign investor to symbol",async function(){
    const investorManagerInstance = await InvestorManager.deployed();
    await investorManagerInstance.addInvestor("PRESSPAGE.REGA311",accounts[0]);
    const investors = await investorManagerInstance.getInvestorsBySymbol("PRESSPAGE.REGA311");
    return assert.equal(investors[0],accounts[0],`expected ${accounts[0]}`);
  })
  it("remove investor",async function(){
    const investorManagerInstance = await InvestorManager.deployed();
    await investorManagerInstance.removeInvestorBySymbol("PRESSPAGE.REGA311",accounts[0]); // removes from symbol, but is still whitelisted
    await investorManagerInstance.removeInvestor(accounts[0]); // removes from whitelisted
    const status = await investorManagerInstance.isWhitelisted(accounts[0]);
    return assert.equal(status,false,"expected to be false");
  })
  it("add non-accredited investor",async function(){
    const investorManagerInstance = await InvestorManager.deployed();
    await investorManagerInstance.addInvestor(accounts[0],0,"FL");
    const investor = await investorManagerInstance.getInvestor(accounts[0]);
    return assert.equal(investor[0],accounts[0],`expected ${accounts[0]}`);
  })
  it("add accredited investor",async function(){
    const investorManagerInstance = await InvestorManager.deployed();
    await investorManagerInstance.addInvestor(accounts[1],1,"FL");
    const investor = await investorManagerInstance.getInvestor(accounts[1]);
    return assert.equal(investor[0],accounts[1],`expected ${accounts[1]}`);
  })
  it("add affilliate investor",async function(){
    const investorManagerInstance = await InvestorManager.deployed();
    await investorManagerInstance.addInvestor(accounts[2],2,"FL");
    const investor = await investorManagerInstance.getInvestor(accounts[2]);
    return assert.equal(investor[0],accounts[2],`expected ${accounts[2]}`);
  })
  it("add broker-dealer member",async function(){
    const investorManagerInstance = await InvestorManager.deployed();
    await investorManagerInstance.addInvestor(accounts[3],3,"FL");
    const investor = await investorManagerInstance.getInvestor(accounts[3]);
    return assert.equal(investor[0],accounts[3],`expected ${accounts[3]}`);
  })
  it("add transfer agent member",async function(){
    const investorManagerInstance = await InvestorManager.deployed();
    await investorManagerInstance.addInvestor(accounts[4],4,"FL");
    const investor = await investorManagerInstance.getInvestor(accounts[4]);
    return assert.equal(investor[0],accounts[4],`expected ${accounts[4]}`);
  })
  it("add issuer member",async function(){
    const investorManagerInstance = await InvestorManager.deployed();
    await investorManagerInstance.addInvestor(accounts[5],5,"FL");
    const investor = await investorManagerInstance.getInvestor(accounts[5]);
    return assert.equal(investor[0],accounts[5],`expected ${accounts[5]}`);
  })
  it("add institution",async function(){
    const investorManagerInstance = await InvestorManager.deployed();
    await investorManagerInstance.addInvestor(accounts[6],6,"FL");
    const investor = await investorManagerInstance.getInvestor(accounts[6]);
    return assert.equal(investor[0],accounts[6],`expected ${accounts[6]}`);
  })
  it("add bank",async function(){
    const investorManagerInstance = await InvestorManager.deployed();
    await investorManagerInstance.addInvestor(accounts[7],7,"FL");
    const investor = await investorManagerInstance.getInvestor(accounts[7]);
    return assert.equal(investor[0],accounts[7],`expected ${accounts[7]}`);
  })
  it("add investment compny",async function(){
    const investorManagerInstance = await InvestorManager.deployed();
    await investorManagerInstance.addInvestor(accounts[8],8,"FL");
    const investor = await investorManagerInstance.getInvestor(accounts[8]);
    return assert.equal(investor[0],accounts[8],`expected ${accounts[8]}`);
  })
  it("add non-profit entity",async function(){
    const investorManagerInstance = await InvestorManager.deployed();
    await investorManagerInstance.addInvestor(accounts[9],9,"FL");
    const investor = await investorManagerInstance.getInvestor(accounts[9]);
    return assert.equal(investor[0],accounts[9],`expected ${accounts[9]}`);
  })
  it("add church",async function(){
    const investorManagerInstance = await InvestorManager.deployed();
    await investorManagerInstance.addInvestor("0x301C980336C88885E9A5F6Ab0f8c497E40389E26",10,"FL");
    const investor = await investorManagerInstance.getInvestor("0x301C980336C88885E9A5F6Ab0f8c497E40389E26");
    return assert.equal(investor[0],"0x301C980336C88885E9A5F6Ab0f8c497E40389E26",`expected "0x301C980336C88885E9A5F6Ab0f8c497E40389E26"`);
  })
  it("add lender",async function(){
    const investorManagerInstance = await InvestorManager.deployed();
    await investorManagerInstance.addInvestor("0xAedE191391D9f5DEc8ADAcEcF88cFA25362D95a9",11,"FL");
    const investor = await investorManagerInstance.getInvestor("0xAedE191391D9f5DEc8ADAcEcF88cFA25362D95a9");
    return assert.equal(investor[0],"0xAedE191391D9f5DEc8ADAcEcF88cFA25362D95a9",`expected "0xAedE191391D9f5DEc8ADAcEcF88cFA25362D95a9"`);
  })
  it("add voting trust",async function(){
    const investorManagerInstance = await InvestorManager.deployed();
    await investorManagerInstance.addInvestor("0xda58bf01a4dCA8B7a25f6dAC0d5DD40f9a3758f8",12,"FL");
    const investor = await investorManagerInstance.getInvestor("0xda58bf01a4dCA8B7a25f6dAC0d5DD40f9a3758f8");
    return assert.equal(investor[0],"0xda58bf01a4dCA8B7a25f6dAC0d5DD40f9a3758f8",`expected "0xda58bf01a4dCA8B7a25f6dAC0d5DD40f9a3758f8"`);
  })
  it("add borrower",async function(){
    const investorManagerInstance = await InvestorManager.deployed();
    await investorManagerInstance.addInvestor("0x50542cF0903152E1761cffF01d2928C6F229D678",13,"FL");
    const investor = await investorManagerInstance.getInvestor("0x50542cF0903152E1761cffF01d2928C6F229D678");
    return assert.equal(investor[0],"0x50542cF0903152E1761cffF01d2928C6F229D678",`expected "0x50542cF0903152E1761cffF01d2928C6F229D678"`);
  })
  it("add municipal advisor",async function(){
    const investorManagerInstance = await InvestorManager.deployed();
    await investorManagerInstance.addInvestor("0xE6483aA75C0194ECbe872214d4F68D85B28F1267",14,"FL");
    const investor = await investorManagerInstance.getInvestor("0xE6483aA75C0194ECbe872214d4F68D85B28F1267");
    return assert.equal(investor[0],"0xE6483aA75C0194ECbe872214d4F68D85B28F1267",`expected "0xE6483aA75C0194ECbe872214d4F68D85B28F1267"`);
  })
  it("get investors",async function(){
    const investorManagerInstance = await InvestorManager.deployed();
    const investors = await investorManagerInstance.getInvestors();
    console.log(investors);
    return assert.isTrue(true);
  })  
  it("get issuers",async function(){
    const investorManagerInstance = await InvestorManager.deployed();
    const issuers = await investorManagerInstance.getIssuers();
    console.log(issuers);
    return assert.isTrue(true);
  })
  it("remove investors and members",async function(){
    const investorManagerInstance = await InvestorManager.deployed();
    await investorManagerInstance.removeInvestor(0,accounts[0]);
    await investorManagerInstance.removeInvestor(1,accounts[1]);
    await investorManagerInstance.removeInvestor(2,accounts[2]);
    await investorManagerInstance.removeInvestor(3,accounts[3]);
    await investorManagerInstance.removeInvestor(4,accounts[4]);
    await investorManagerInstance.removeInvestor(5,accounts[5]);
    await investorManagerInstance.removeInvestor(6,accounts[6]);
    await investorManagerInstance.removeInvestor(7,accounts[7]);
    await investorManagerInstance.removeInvestor(8,accounts[8]);
    await investorManagerInstance.removeInvestor(9,accounts[9]);
    await investorManagerInstance.removeInvestor(10,"0x301C980336C88885E9A5F6Ab0f8c497E40389E26");
    await investorManagerInstance.removeInvestor(11,"0xAedE191391D9f5DEc8ADAcEcF88cFA25362D95a9");
    await investorManagerInstance.removeInvestor(12,"0xda58bf01a4dCA8B7a25f6dAC0d5DD40f9a3758f8");
    await investorManagerInstance.removeInvestor(13,"0x50542cF0903152E1761cffF01d2928C6F229D678");
    await investorManagerInstance.removeInvestor(14,"0xE6483aA75C0194ECbe872214d4F68D85B28F1267");
    await investorManagerInstance.removeInvestor(accounts[0]);
    await investorManagerInstance.removeInvestor(accounts[1]); // remove accredited investor
    await investorManagerInstance.removeInvestor(accounts[2]); // remove affiliate investor
    await investorManagerInstance.removeInvestor(accounts[3]); // remove broker-dealer investor
    await investorManagerInstance.removeInvestor(accounts[4]);
    await investorManagerInstance.removeInvestor(accounts[5]);
    await investorManagerInstance.removeInvestor(accounts[6]);
    await investorManagerInstance.removeInvestor(accounts[7]);
    await investorManagerInstance.removeInvestor(accounts[8]);
    await investorManagerInstance.removeInvestor(accounts[9]);
    await investorManagerInstance.removeInvestor("0x301C980336C88885E9A5F6Ab0f8c497E40389E26");
    await investorManagerInstance.removeInvestor("0xAedE191391D9f5DEc8ADAcEcF88cFA25362D95a9");
    await investorManagerInstance.removeInvestor("0xda58bf01a4dCA8B7a25f6dAC0d5DD40f9a3758f8");
    await investorManagerInstance.removeInvestor("0x50542cF0903152E1761cffF01d2928C6F229D678");
    await investorManagerInstance.removeInvestor("0xE6483aA75C0194ECbe872214d4F68D85B28F1267");
    return assert.isTrue(true);
  })
});
