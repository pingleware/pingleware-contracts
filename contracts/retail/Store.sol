// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

// See https://github.com/brakmic/BlockchainStore

import "../common/Version.sol";
import "../common/Owned.sol";

/**
    @notice This contract implements a simple store that can interact with registered customers. Every customer has its own shopping cart.
    @title Retail Store Contract
    @author Harris Brakmic
*/
contract Store is Version, Owned {

    /* Store internals */
    bytes32 public store_name; // store name
    uint256 private store_balance;  // store balance

    mapping (address => Customer) customers;
    mapping (uint256 => Product) products;

    /* Store Events */
    event CustomerRegistered(address customer);
    event CustomerRegistrationFailed(address customer);
    event CustomerDeregistered(address customer);
    event CustomerDeregistrationFailed(address customer);

    event ProductRegistered(uint256 productId);
    event ProductDeregistered(uint256 productId);
    event ProductRegistrationFailed(uint256 productId);
    event ProductDeregistrationFaled(uint256 productId);

    event CartProductInserted(address customer, uint256 prodId, uint256 prodPrice, uint256 completeSum);
    event CartProductInsertionFailed(address customer, uint256 prodId);
    event CartProductRemoved(address customer, uint256 prodId);
    event CartCheckoutCompleted(address customer, uint256 paymentSum);
    event CartCheckoutFailed(address customer, uint256 customerBalance, uint256 paymentSum);
    event CartEmptied(address customer);

    /**
        @notice A shopping cart contains an array of product ids: @products
        and a sum of product prices: @completeSum
        The @completeSum gets automatically updated when customer
        adds or removes products.
    */
    struct Cart {
      uint256[] products;
      uint256 completeSum;
    }

    /**
        @notice every customer has an address, name,
        balance and a shopping cart
    */
    struct Customer {
        address adr;
        bytes32 name;
        uint256 balance;
        Cart cart;
    }

    /**
        @notice Represents a product:
        Product id: @id
        Product name: @name
        Decription: @description
        Amount of items in a single product: @default_amount
    */
    struct Product {
        uint256 id;
        bytes32 name;
        bytes32 description;
        uint256 price;
        uint256 default_amount;
    }

    /**
        @notice Represents a receipt [NOT IN USE]
    */
    struct Receipt {
        InvoiceLine[] lines;
        address customer_address;
    }

    /**
        @notice Represents a single entry describing a single product [NOT IN USE]
    */
    struct InvoiceLine {
        bytes product_id;
        uint256 amount;
        uint256 product_price;
        uint256 total_price;
    }

    /**
        @notice Default constructor
    */
    constructor() {
        store_name = 'my-store-name';
        store_balance = 0;
    }

    /**
          @notice Register a single product
          @param id Product ID
          @param name Product Name
          @param description Product Description
          @param price Product Price
          @param default_amount Default amount of items in a single product
          @return success
    */
    function registerProduct(uint256 id, bytes32 name, bytes32 description, uint256 price, uint256 default_amount)
        public
        payable
        onlyOwner
        returns (bool success)
    {
        Product memory product = Product(id, name, description, price, default_amount);
        if (checkProductValidity(product)) {
            products[id] = product;
            emit ProductRegistered(id);
            return true;
        }
        emit ProductRegistrationFailed(id);
        return false;
    }

    /**
          @notice Removes a product from the list
          @param id Product ID
          @return success
    */
    function deregisterProduct(uint256 id)
        public
        payable
        onlyOwner
        returns (bool success)
    {
        Product memory product = products[id];
        if (product.id == id) {
            delete products[id];
            emit ProductDeregistered(id);
            return true;
        }
        emit ProductDeregistrationFaled(id);
        return false;
    }

    /**
          @notice Registers a new customer (only store owners)
          @param _address Customer's address
          @param _name Customer's name
          @param _balance Customer's balance
          @return success
    */
    function registerCustomer(address _address, bytes32 _name, uint256 _balance)
        public
        payable
        onlyOwner
        returns (bool success)
    {
        if (_address != address(0)) {
            Customer memory customer = Customer({
                                                    adr: _address,
                                                    name: _name,
                                                    balance: _balance,
                                                    cart: Cart(new uint256[](0), 0)
                                                });
            customers[_address] = customer;
            emit CustomerRegistered(_address);
            return true;
        }
        emit CustomerRegistrationFailed(_address);
        return false;
    }

    /**
        @notice Removes a customer (only store owners)
        @param _address Customer's address
        @return success
    */
    function deregisterCustomer(address _address)
        public
        payable
        onlyOwner
        returns (bool success)
    {
        Customer memory customer = customers[_address];
        if (customer.adr != address(0)) {
            delete customers[_address];
            emit CustomerDeregistered(_address);
            return true;
        }
        emit CustomerDeregistrationFailed(_address);
        return false;
    }

    function insertProductIntoCart(uint256 id)
        public
        returns (bool success, uint256 pos_in_prod_mapping)
    {
        Customer memory cust = customers[msg.sender];
        Product memory prod = products[id];
        uint256 prods_prev_len = cust.cart.products.length;
        // TODO fix TypeError: Member "push" is not available in uint256[] memory outside of storage.
        // cust.cart.products.push(prod.id);
        uint256 current_sum = cust.cart.completeSum;
        cust.cart.completeSum = current_sum + prod.price;
        if (cust.cart.products.length > prods_prev_len) {
          emit CartProductInserted(msg.sender, id, prod.price, cust.cart.completeSum);
          return (true, cust.cart.products.length - 1);
        }
        emit CartProductInsertionFailed(msg.sender, id);
        return (false, 0);
    }

    function removeProductFromCart(uint256 prod_pos_in_mapping)
        public
        pure
    {
        prod_pos_in_mapping;
        // Uncomment next line when TODO's are completed?
        // uint256[] memory new_product_list = new uint256[](customers[msg.sender].cart.products.length - 1);
        // TODO fix TypeError: Member "push" is not available in uint256[] memory outside of storage.
        // Product memory customerProds = customers[msg.sender].cart.products;
        // TODO fix TypeError: Member "length" not found or not visible after argument-dependent lookup in struct Store.Product memory.
        /*
        for (uint256 i = 0; i < customerProds.length; i++) {
          if (i != prod_pos_in_mapping) {
            new_product_list[i] = customerProds[i];
          } else {
            customers[msg.sender].cart.completeSum -= products[customerProds[i]].price;
            emit CartProductRemoved(msg.sender, customerProds[i]);
          }
        }
        customers[msg.sender].cart.products = new_product_list;
        */
    }

    function checkoutCart()
        public
        returns (bool success)
    {
        Customer memory customer = customers[msg.sender];
        uint256 paymentSum = customer.cart.completeSum;
        if ((customer.balance >= paymentSum) &&
            customer.cart.products.length > 0) {
            customer.balance -= paymentSum;
            customer.cart = Cart(new uint256[](0), 0);
            store_balance += paymentSum;
            emit CartCheckoutCompleted(msg.sender, paymentSum);
            return true;
        }
        emit CartCheckoutFailed(msg.sender, customer.balance, paymentSum);
        return false;
    }

    function emptyCart()
        public
        returns (bool success)
    {
      /*if (msg.sender != owner) {*/
        Customer memory customer = customers[msg.sender];
        customer.cart = Cart(new uint256[](0), 0);
        emit CartEmptied(customer.adr);
        return true;
      /*}*/
      /*return false;*/
    }

    function renameStoreTo(bytes32 new_store_name)
        public
        payable
        onlyOwner
        returns (bool success)
    {
        if (new_store_name.length != 0 &&
            new_store_name.length <= 32) {
            store_name = new_store_name;
            return true;
        }
        return false;
    }

    function getProduct(uint256 id)
        public
        view
        returns (bytes32 name, bytes32 description, uint256 price, uint256 default_amount)
    {
       return (products[id].name,
               products[id].description,
               products[id].price,
               products[id].default_amount);
    }

    function getCart()
        public
        view
        returns (uint256[] memory product_ids, uint256 complete_sum)
    {
      Customer memory customer = customers[msg.sender];
      uint256 len = customer.cart.products.length;
      uint256[] memory ids = new uint256[](len);
      for (uint256 i = 0; i < len; i++) {
        ids[i] = products[i].id;
      }
      return (ids, customer.cart.completeSum);
    }

    function getBalance()
        public
        view
        returns (uint256 _balance)
    {
      return customers[msg.sender].balance;
    }

    function getStoreBalance()
        public
        payable
        onlyOwner
        returns (uint256)
    {
      return store_balance;
    }

    function checkProductValidity(Product memory product)
        private
        pure
        returns (bool valid)
    {
       return (product.price > 0);
    }
}