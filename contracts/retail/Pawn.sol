// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

contract PawnShop {
    address public owner; // The owner of the pawn shop
    uint256 public itemCount; // Total number of pawned items

    struct PawnedItem {
        string name;
        uint256 value;
        uint256 pawnedAmount;
        uint256 redemptionDate;
        address pawnedBy;
        bool redeemed;
    }

    mapping(uint256 => PawnedItem) public pawnedItems;

    event ItemPawned(uint256 itemId, string name, uint256 value, uint256 pawnedAmount, uint256 redemptionDate, address pawnedBy);
    event ItemRedeemed(uint256 itemId, address redeemedBy);
    event ItemDefaulted(uint256 itemId);

    constructor() {
        owner = msg.sender;
        itemCount = 0;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    function pawnItem(string memory _name, uint256 _value, uint256 _pawnedAmount, uint256 _redemptionDate) public payable {
        require(bytes(_name).length > 0, "Item name must not be empty");
        require(_value > 0, "Item value must be greater than zero");
        require(_pawnedAmount > 0, "Pawned amount must be greater than zero");
        require(_redemptionDate > block.timestamp, "Redemption date must be in the future");
        require(msg.value >= _pawnedAmount, "Insufficient pawned amount");

        itemCount++;
        pawnedItems[itemCount] = PawnedItem({
            name: _name,
            value: _value,
            pawnedAmount: _pawnedAmount,
            redemptionDate: _redemptionDate,
            pawnedBy: msg.sender,
            redeemed: false
        });

        emit ItemPawned(itemCount, _name, _value, _pawnedAmount, _redemptionDate, msg.sender);
    }

    function redeemItem(uint256 _itemId) public payable {
        require(_itemId > 0 && _itemId <= itemCount, "Invalid item ID");

        PawnedItem storage item = pawnedItems[_itemId];
        require(!item.redeemed, "Item is already redeemed");
        require(item.redemptionDate <= block.timestamp, "Item can be redeemed after the redemption date");
        require(msg.sender == item.pawnedBy, "Only the pawned can redeem the item");
        require(msg.value >= item.pawnedAmount, "Insufficient redemption amount");

        item.redeemed = true;

        // Transfer the pawned amount to the owner
        payable(owner).transfer(item.pawnedAmount);

        emit ItemRedeemed(_itemId, msg.sender);
    }

    function defaultItem(uint256 _itemId) public onlyOwner {
        require(_itemId > 0 && _itemId <= itemCount, "Invalid item ID");

        PawnedItem storage item = pawnedItems[_itemId];
        require(!item.redeemed, "Item is already redeemed");
        require(item.redemptionDate < block.timestamp, "Item can be defaulted only after the redemption date");

        item.redeemed = true;

        emit ItemDefaulted(_itemId);
    }

    function getItem(uint256 _itemId) public view returns (string memory, uint256, uint256, uint256, address, bool) {
        require(_itemId > 0 && _itemId <= itemCount, "Invalid item ID");
        PawnedItem memory item = pawnedItems[_itemId];
        return (item.name, item.value, item.pawnedAmount, item.redemptionDate, item.pawnedBy, item.redeemed);
    }
}
