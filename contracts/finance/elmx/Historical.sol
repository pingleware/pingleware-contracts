// SPDX-License-Identifier: BSL-1.1
pragma solidity >=0.4.22 <0.9.0;

/**
 * Maintains record of historical pricing for quoting
 */

contract Historical {
    struct Quote {
        uint256 timestamp;
        string symbol;
        uint256 volume;
        uint256 bid;
        uint256 ask;
    }

    mapping (address => Quote[]) public quotes;

    constructor() {

    }

    function addQuote(address token,string memory symbol,uint256 volume,uint256 bid,uint256 ask) external {
        quotes[token].push(Quote(block.timestamp,symbol,volume,bid,ask));
    }

    function getHistorical(address token) external view returns (Quote[] memory) {
        return quotes[token];
    }

    function getHistoricalByRange(address token,uint256 beginning,uint256 ending) external view returns (Quote[] memory) {
        Quote[] memory _quotes;
        uint256 index=0;
        for (uint256 i=0; i < quotes[token].length; i++) {
            if (quotes[token][i].timestamp >= beginning && quotes[token][i].timestamp < ending) {
                uint256 timestamp = quotes[token][i].timestamp;
                string memory symbol = quotes[token][i].symbol;
                uint256 volume = quotes[token][i].volume;
                uint256 bid = quotes[token][i].bid;
                uint256 ask = quotes[token][i].ask;
                _quotes[index++] = Quote(timestamp,symbol,volume,bid,ask);
            }
        }
        return _quotes;
    }

}