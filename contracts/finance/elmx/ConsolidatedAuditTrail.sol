// SPDX-License-Identifier: BSL-1.1
pragma solidity >=0.4.22 <0.9.0;

/*
 * In this example, the AuditableContract smart contract has a struct named AuditTrail to store relevant data such as the user address, 
 * action performed, and the timestamp of the action. The auditTrails array is used to store the audit trail logs.
 *
 * The addAuditTrail function allows users to add an audit trail entry by providing the action as a parameter. 
 * It creates a new AuditTrail object with the sender's address, the provided action, and the current timestamp. 
 * The new entry is then added to the auditTrails array, and the AuditTrailAdded event is emitted to signal the addition of a new audit trail.
 *
 * To use this contract, deploy it to an Ethereum network, and then call the addAuditTrail function whenever you want to add an audit trail entry. 
 * The action performed can be passed as an argument to the function.
 &
 * Each time the addAuditTrail function is called, a new entry will be added to the auditTrails array, 
 * and the AuditTrailAdded event will be emitted. You can listen to this event to capture and store the audit trail logs externally.
 *
 * See https://www.sec.gov/divisions/marketreg/rule613-info
*/
// Reengineering the Audit with Blockchain and Smart Contracts - https://publications.aaahq.org/jeta/article-abstract/16/1/21/9276/Reengineering-the-Audit-with-Blockchain-and-Smart?redirectedFrom=fulltext

import "../../interfaces/IConsolidatedAuditTrail.sol";

contract ConsolidatedAuditTrail is IConsolidatedAuditTrail {

    // Mapping of unique trade identifiers (UTIs) to their corresponding audit entries
    mapping(string => mapping(bytes32 => AuditEntry[])) public auditTrail;
    uint256 public auditTrailTotal = 0;
    AuditEntry[] pending;
    
    // Mapping of UTIs to a flag indicating whether it exists
    mapping(string => mapping(bytes32 => bool)) public utiExists;



    uint256 public exchangeRate;

    // Variable to track reentrant calls
    bool private reentrantGuard;

    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier nonReentrant() {
        require(!reentrantGuard, "Reentrant call detected");
        reentrantGuard = true;
        _;
        reentrantGuard = false;
    }


    // Function to add a new audit entry
    /**
     * Trade Execution: When a trade occurs on the decentralized exchange, the financial institution calls the addAuditEntry function of the CAT contract, 
     * passing the necessary trade details, such as the trade ID, transaction details, and involved parties. 
     * For example:
     *
     *      catContract.addAuditEntry("PEIKX-A1", "TRADE123", "Trade Execution", "Buy 10 ETH at $2000 from Address A");
     *
     * eventDetail in the following format:
     *
     *  {
     *      "tradeId": "TRADE123",
     *      "transactionHash": "0x7634baeeae9a8487671906e5a60d2845974b8bfd6285ac7525ed7f5b71f090db",
     *      "assetSymbol": "PEIKX-A1",
     *      "assetContractAddress": "0x429Fd2E795b3C8f51b5ea08255EAB8C31Db955df",
     *      "quantity": 10,
     *      "buyer": "0x490e7f14f80807df3f814331D48103BEC8eD03bf",
     *      "seller": "0x9F30e3755035dcaf201b2b48C85F0a4649E7a9ba",
     *      "timestamp": 1654191900
     *  }
     *
     */
    function addAuditEntry(string memory symbol, string memory eventDetail, string memory eventType, string memory eventData) override external nonReentrant returns (bytes32) {
        
        bytes32 uti = generateUTI(eventDetail);
        
        require(!utiExists[symbol][uti], "UTI already exists");
        
        AuditEntry memory entry = AuditEntry({
            sender: msg.sender,
            routedOrderID: uti,
            timestamp: block.timestamp,
            symbol: symbol,
            eventType: eventType,
            eventData: eventData
        });

        pending.push(entry);
        
        auditTrail[symbol][uti].push(entry);
        utiExists[symbol][uti] = true;
        auditTrailTotal++;
        
        emit AuditEntryAdded(symbol, uti, msg.sender, block.timestamp, eventType, eventData);

        return uti;
    }

        /**
         * CONSOLIDATED AUDIT TRAIL (CAT) entry format:
         * -------------------------------------------
         *
         * assetSymbol: <token symbol>,  
         * assetContractAddress: <contract address of token>,  
         * quantity: <number of tokens>,  
         * buyer: <buyer waller address>,  
         * seller: <seller wallet address>, 
         * timestamp: <timestamp>
         */
    
    // Function to retrieve the audit trail for a specific UTI
    /**
     * Audit Trail Retrieval: To retrieve the audit trail for a specific trade, the financial institution calls the getAuditTrail function of the CAT contract, 
     * providing the corresponding UTI. 
     * For example:
     *
     *      AuditEntry[] memory tradeAuditTrail = catContract.getAuditTrail("PEIKX-A1", generateUTI("TRADE123"));
     *
     */
    function getAuditTrail(string memory symbol, bytes32 uti) override external view returns (AuditEntry[] memory) {
        return auditTrail[symbol][uti];
    }

    function getAuditTrailRange(uint256 startingTimestamp,uint256 endingTimestamp,string memory symbol,bytes32 uti) external  returns (AuditEntry[] memory) {
        AuditEntry[] memory selected;
        selected = auditTrail[symbol][uti];

        for (uint256 i=0; i < selected.length; i++) {
            if (selected[i].timestamp >= startingTimestamp && selected[i].timestamp < endingTimestamp) {
                pending.push(selected[i]);
            }
        }
        return pending;
    }

    function getAuditTrailRange(uint256 startingTimestamp, uint256 endingTimestamp, string memory symbol, bytes32 uti, uint256 page, uint256 pageSize)
        external view
        
        returns (AuditEntry[] memory)
    {
        AuditEntry[] memory selected = auditTrail[symbol][uti];
        uint256 totalCount = selected.length;

        require(page > 0, "Page must be greater than zero");
        require(pageSize > 0, "Page size must be greater than zero");

        uint256 startIndex = (page - 1) * pageSize;
        uint256 endIndex = startIndex + pageSize;

        // Ensure that startIndex is within bounds
        require(startIndex < totalCount, "Start index out of bounds");

        if (endIndex > totalCount) {
            endIndex = totalCount; // Ensure endIndex does not exceed the total count
        }

        uint256 resultSize = endIndex - startIndex;
        AuditEntry[] memory result = new AuditEntry[](resultSize);

        for (uint256 i = startIndex; i < endIndex; i++) {
            if (selected[i].timestamp >= startingTimestamp && selected[i].timestamp < endingTimestamp) {
                result[i - startIndex] = selected[i];
            }
        }

        return result;
    }


    function getAuditTrailComplete() external view  returns (AuditEntry[] memory) {
        return pending;
    }

    /*
     * Exchnage rate is updated nightly at 5:00 pm NY Time
     */
    function setExchangeRate(uint256 newRate) external nonReentrant  {
        uint256 oldRate = exchangeRate;
        exchangeRate = newRate;
        emit ExchangeRateChange(oldRate, exchangeRate);
    }

    function getExchangeRate() external view returns (uint256) {
        return exchangeRate;
    }

    function weiToUSD(uint256 weiAmount) external view returns (uint256) {
        uint256 usdAmount = (weiAmount * exchangeRate) / 1e18; // Assuming 1 ETH = 1e18 Wei
        return usdAmount;
    }

    function usdToWei(uint256 usdAmount) external view returns (uint256) {
        uint256 weiAmount = (usdAmount * 1e18) / exchangeRate; // Assuming 1 ETH = 1e18 Wei
        return weiAmount;
    }

    function usdToEth(uint256 usdAmount) external view returns (string memory) {
        uint256 ethAmount = (usdAmount * 1e18) / exchangeRate; // Assuming 1 ETH = 1e18 Wei
        string memory ethString = int256ToString(ethAmount); 
        return ethString;
    }


    // internal functions
    // Function to generate a UTI using trade-specific details
    function generateUTI(string memory tradeDetails) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(tradeDetails));
    }

    function compareStrings(string memory a, string memory b) internal pure returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }

    function int256ToString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0";
        }
                
        uint256 temp = uint256(value);
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp /= 10;
        }
        
        bytes memory buffer;
        buffer = new bytes(length);
        
        while (value != 0) {
            length--;
            uint256 remainder = value % 10;
            value /= 10;
            buffer[length] = bytes1(uint8(48 + remainder));
        }
        
        return string(abi.encodePacked("0.", string(buffer)));
    }

    function timestampToString() external view returns (string memory) {
        uint256 timestamp = block.timestamp;
        uint256 maxLength = 20; // Maximum length of the string (adjust as needed)
        bytes memory buffer = new bytes(maxLength);
        uint256 i = maxLength - 1;
        
        while (timestamp > 0) {
            buffer[i--] = bytes1(uint8(48 + timestamp % 10)); // Convert digit to ASCII
            timestamp /= 10;
        }
        
        bytes memory result = new bytes(maxLength - i - 1);
        for (uint256 j = i + 1; j < maxLength; j++) {
            result[j - i - 1] = buffer[j];
        }
        
        return string(result);
    }

    // Helper function to convert uint to string
    function uintToString(uint256 value) external pure returns (string memory) {
        if (value == 0) {
            return "0";
        }

        uint256 temp = value;
        uint256 digits;

        while (temp > 0) {
            digits++;
            temp /= 10;
        }

        bytes memory buffer = new bytes(digits);
        temp = value;
        while (temp > 0) {
            buffer[--digits] = bytes1(uint8(48 + temp % 10));
            temp /= 10;
        }

        return string(buffer);
    }
}
