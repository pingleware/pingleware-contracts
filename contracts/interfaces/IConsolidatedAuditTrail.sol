// SPDX-License-Identifier: BSL-1.1
pragma solidity >=0.4.22 <0.9.0;

interface IConsolidatedAuditTrail {
    // Enum to represent different reportable events
    enum REPORTABLE_EVENT {
        ORDER_PLACED,
        ORDER_CANCELLED,
        ORDER_EXECUTED,
        ORDER_MODIFIED,
        ORDER_ROUTING
        // Add other reportable events as needed
    }

    // Structure to hold the details of an order execution
    struct OrderExecution {
        string orderId;
        string executionId;
        uint256 timestamp;
        string instrumentId;
        uint256 executionQuantity;
        uint256 executionPrice;
        string buyerId;
        string sellerId;
        string executionVenue;
        string orderType;
        string orderStatus;
        string tradeId;
        string counterpartyId;
        string counterpartyName;
        string executionAlgorithm;
    }

    // Event to log when an order is executed
    event OrderExecuted(
        REPORTABLE_EVENT eventType,
        string orderId,
        string executionId,
        uint256 timestamp,
        string instrumentId,
        uint256 executionQuantity,
        uint256 executionPrice,
        string buyerId,
        string sellerId,
        string executionVenue,
        string orderType,
        string orderStatus,
        string tradeId,
        string counterpartyId,
        string counterpartyName,
        string executionAlgorithm
    );

    function logOrderExecution(
        string memory orderId,
        string memory executionId,
        uint256 timestamp,
        string memory instrumentId,
        uint256 executionQuantity,
        uint256 executionPrice,
        string memory buyerId,
        string memory sellerId,
        string memory executionVenue,
        string memory orderType,
        string memory orderStatus,
        string memory tradeId,
        string memory counterpartyId,
        string memory counterpartyName,
        string memory executionAlgorithm
    ) external;
}