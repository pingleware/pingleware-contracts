// SPDX-License-Identifier: BSL-1.1
pragma solidity >=0.4.22 <0.9.0;

interface IOrderBook {
    struct Order {
        uint256 orderId;
        address wallet;
        uint256 quantity;
        uint256 price;
        uint256 paid;
    }

    struct Trade {
        address buyer;
        address seller;
        address token;
        uint amount;
        bool isCompleted;
    }

    function setThreshold(uint256 value) external;
    function setPriceThreshold(uint256 value) external;
    function setFeeRecipient(address wallet) external;
    function setOfferingContractAddress(string calldata symbol,address offeringContractAddress) external;
    function getOrders(string calldata symbol) external view returns(Order[] memory,Order[] memory);
    function quote(string calldata symbol) external view returns (uint256, uint256);
    function buy(address wallet,string calldata symbol,uint256 quantity,uint256 price,uint256 amount) external;
    function cancelBuy(address wallet, string calldata symbol,uint256 orderId) external;
    function sell(address wallet,string calldata symbol,uint256 quantity,uint256 price) external;
    function cancelSell(address wallet,string calldata symbol,uint256 orderId) external;
    function detectMarketAbuse(string memory symbol) external view returns (bool);
    function detectManipulativeBehaviorDetected(string memory symbol,uint256 orderId) external view returns (bool);
}