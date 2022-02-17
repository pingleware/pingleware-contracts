// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

import "../common/Version.sol";
import "../common/Owned.sol";

contract Inventory is Version, Owned {

    struct InventoryItem {
        uint256     epoch; // timestamp of entry
        uint256     count;
        string      sku;
        string      product_name;
        string      description;
        uint256     price;
        uint256     cost;
        uint256     reorder_threshold;
        address     vendor;
    }

    address[] public vendors;
    InventoryItem[] public items;

}