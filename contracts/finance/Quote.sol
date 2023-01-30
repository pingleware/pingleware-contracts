// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;


/*
abstract contract OracleExample is usingOraclize {

    string public ETHUSD;

    function updatePrice() public payable {
        if (oraclize_getPrice("URL") > this.balance) {
            //Handle out of funds error
        } else {
            oraclize_query("URL", "json(https://min-api.cryptocompare.com/data/price?fsym=USD&tsyms=ETH).ETH");
        }
    }
    
    function __callback(bytes32 myid, string result) public {
        require(msg.sender == oraclize_cbAddress());
        ETHUSD = result;
    }
}
*/