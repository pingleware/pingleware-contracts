const AgriChain = artifacts.require("AgriChain");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("AgriChain", (accounts) => {
  it("add rhubbard with product id of 0, a product status of active and product location of FL",async () => {
      const agrichainInstance = await AgriChain.deployed();
      const prodid = await agrichainInstance.addProduct(0,"Rhubbard","active","FL")
      //console.log(prodid)
      //assert.equal(prodid, 0, "prodId expected to be 0")
  })
  it("get product id's",async () => {
      const agrichainInstance = await AgriChain.deployed();
      const prodIds = await agrichainInstance.getProductIds()
      assert.equal(prodIds.length,16,"prodIds expected to contain 16 id")
      //console.log(prodIds)
  })
  it("get product detail for product id #0",async() => {
    const contractInstance = await AgriChain.deployed();
    const detail = await contractInstance.getProductDetail(0);
    assert.equal(detail[0],"Rhubbard","expected to receive Rhubbard");
  })
})