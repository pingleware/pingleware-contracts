// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

import "../common/Version.sol";
import "../common/Owned.sol";

contract Inventory is Version,Owned {
    address public owner; // The owner of the contract
    uint256 public productCount; // Total number of products in the inventory

    struct Product {
        string name;
        uint256 price;
        uint256 quantity;
        bool available;
    }

    mapping(uint256 => Product) public products;

    event ProductAdded(uint256 productId, string name, uint256 price, uint256 quantity);
    event ProductUpdated(uint256 productId, string name, uint256 price, uint256 quantity, bool available);

    constructor() {
        owner = msg.sender;
        productCount = 0;
    }


    function addProduct(string memory _name, uint256 _price, uint256 _quantity) public okOwner {
        require(bytes(_name).length > 0, "Product name must not be empty");
        require(_price > 0, "Product price must be greater than zero");
        require(_quantity > 0, "Product quantity must be greater than zero");

        productCount++;
        products[productCount] = Product({
            name: _name,
            price: _price,
            quantity: _quantity,
            available: true
        });

        emit ProductAdded(productCount, _name, _price, _quantity);
    }

    function updateProduct(uint256 _productId, string memory _name, uint256 _price, uint256 _quantity, bool _available) public okOwner {
        require(_productId > 0 && _productId <= productCount, "Invalid product ID");

        Product storage product = products[_productId];
        product.name = _name;
        product.price = _price;
        product.quantity = _quantity;
        product.available = _available;

        emit ProductUpdated(_productId, _name, _price, _quantity, _available);
    }

    function getProduct(uint256 _productId) public view returns (string memory, uint256, uint256, bool) {
        require(_productId > 0 && _productId <= productCount, "Invalid product ID");
        Product memory product = products[_productId];
        return (product.name, product.price, product.quantity, product.available);
    }
}
