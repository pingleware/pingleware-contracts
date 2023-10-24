const AgriChain = artifacts.require("AgriChain");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("agriculture/AgriChain", (accounts) => {
  it("add rhubbard with product id of 0, a product status of active and product location of FL",async () => {
      const agrichainInstance = await AgriChain.deployed();
      await agrichainInstance.addProduct(0,"Rhubbard","active","FL")
      const product = await agrichainInstance.getProductDetail(0);
      assert.equal(product[0], "Rhubbard", "product expected to be Rhubbard") 
  })
  it("get product id's",async () => {
      const agrichainInstance = await AgriChain.deployed();
      await agrichainInstance.addProduct(1,"Lettuce","active","FL")
      const prodIds = await agrichainInstance.getProductIds()
      assert.equal(prodIds.length,16,"prodIds expected to contain 16 id")
  })
  it("get product detail for product id #0",async() => {
    const contractInstance = await AgriChain.deployed();
    const detail = await contractInstance.getProductDetail(0);
    assert.equal(detail[0],"Rhubbard","expected to receive Rhubbard");
  })
})