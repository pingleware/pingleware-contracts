// SPDX-License-Identifier: BSL-1.1
pragma solidity >=0.4.22 <0.9.0;

interface IConsolidatedAuditTrail {

    // Struct representing an audit trail entry
    struct AuditEntry {
        address sender;     // Address of the sender
        bytes32 routedOrderID; 
        uint256 timestamp;  // Timestamp of the event
        string symbol;      // Symbol
        string eventType;   // Type of event being recorded
        string eventData;   // Additional data related to the event
    }

    enum CANCELLED_REASON {
        NOTHING_DONE,USER,SYSTEM,LOST_CONNECTION,INSUFFICIENT_QUANTITY,SPECIAL_ADJUSTMENT,QRM_REMOVED,INSUFFICIENT_QUANTITY_BUY_SIDE,
        INSUFFICIENT_QUANTITY_SELL_SIDE,WASH_TRADE_PREVENTION,QUOTE_UPDATE_CONTROL,FAILOVER,QUOTE_IN_TRIGGER,INVALID_SESSION_ID,
        SAL_IN_PROGRESS,CROSS_IN_PROGRESS,INVALID_NBBO,NOT_WITHIN_NBBO,TRADE_THROUGH_CBOE,INSUFFICIENT_CUSTOMER_ORDER_QUANTITY,
        INSUFFICIENT_CROSS_ORDER_SIZE,INSUFFICIENT_CROSS_ORDER_DOLLAR_AMOUNT,SELL_SHORT_RULE_VIOLATION,CANCEL_ON_RSS,
        CALL_BID_EXCEEDS_UNDERLYING_PRICE,PUT_BID_EXCEEDS_STRIKE_PRICE,LIMIT_EXECUTION_PRICE_WOULD_BE_DEBIT,
        LIMIT_EXECUTION_PRICE_EXCEEDS_MAX_VALUE,NO_USER_ACTIVITY,BROKER_OPTION,CANCEL_PENDING,CROWD_TRADE,DUPLICATE_ORDER,
        EXCHANGE_CLOSED,GATE_VIOLATION,INVALID_ACCOUNT,INVALID_AUTOEX_VALUE,INVALID_CMTA,INVALID_FIRM,INVALID_ORIGIN_TYPE,
        INVALID_POSITION_EFFECT,INVALID_PRICE,INVALID_PRODUCT,INVALID_PRODUCT_TYPE,INVALID_QUANTITY,INVALID_SIDE,INVALID_SUBACCOUNT,
        INVALID_TIME_IN_FORCE,INVALID_USER,LATE_PRINT,NOT_FIRM,MISSING_EXEC_INFO,NO_MATCHING_ORDER,NON_BLOCK_TRADE,NOT_NBBO,COMM_DELAYS,
        ORIGINAL_ORDER_REJECTED,OTHERPROCESSING_PROBLEMS,PRODUCT_HALTED,PRODUCT_IN_ROTATION,STALE_EXECUTION,STALE_ORDER,ORDER_TOO_LATE,
        TRADE_BUSTED,TRADE_REJECTED,ORDER_TIMEOUT,REJECTED_LINKAGE_TRADE,SATISFACTION_ORD_REJ_OTHER,UNKNOWN_ORDER,INVALD_EXCHANGE,
        TRANSACTION_FAILED,NOT_ACCEPTED,SUSPENDED,AWAY_EXCHANGE_CANCEL,LINKAGE_CONDITIONAL_FIELD_MISSING,LINKAGE_EXCHANGE_UNAVAILABLE,
        LINKAGE_INVALID_MESSAGE,LINKAGE_INVALID_DESTINATION,LINKAGE_INVALID_PRODUCT,LINKAGE_SESSION_REJECT
    }

    // Event emitted when a new audit entry is added
    event AuditEntryAdded(string symbol, bytes32 indexed uti, address indexed sender, uint256 timestamp, string eventType, string eventData);
    
    function addAuditEntry(string memory symbol, string memory eventDetail, string memory eventType, string memory eventData) external returns (bytes32);
    function getAuditTrail(string memory symbol, bytes32 uti) external view returns (AuditEntry[] memory);
    function getAuditTrailRange(uint256 startingTimestamp,uint256 endingTimestamp,string memory symbol,bytes32 uti) external returns (AuditEntry[] memory);
    function getAuditTrailRange(uint256 startingTimestamp, uint256 endingTimestamp, string memory symbol, bytes32 uti, uint256 page, uint256 pageSize) external view returns (AuditEntry[] memory);
    function getAuditTrailComplete() external view returns (AuditEntry[] memory);

    function setExchangeRate(uint256 newRate) external;
    function getExchangeRate() external view returns (uint256);
    function weiToUSD(uint256 weiAmount) external view returns (uint256);
    function usdToWei(uint256 usdAmount) external view returns (uint256);
    function usdToEth(uint256 usdAmount) external view returns (string memory);

    function timestampToString() external view returns (string memory);
    function uintToString(uint256 value) external pure returns (string memory);
}