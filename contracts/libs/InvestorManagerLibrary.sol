// SPDX-License-Identifier: BSL-1.1
pragma solidity >=0.4.22 <0.9.0;

library InvestorManagerLibrary {

    struct INVESTOR {
        address wallet;
        bool active;
        string jurisdiction;
        uint level;
    }

    event InvestorAdded(address wallet,uint investor_type,string jurisdiction);
    event TransferAgentAdded(address wallet);

    function isWhitelisted(mapping(address => INVESTOR) storage whitelisted, address wallet) internal view returns (bool) {
        return whitelisted[wallet].active;
    }

    function findInvestor(mapping(string => mapping(address => bool)) storage investorExists, string calldata symbol, address wallet) internal view returns (bool) {
        return investorExists[symbol][wallet];
    }

    /**
     * investors
     */
    function addInvestor(mapping(string => address[]) storage investors, mapping(string => mapping(address => bool)) storage investorExists, mapping(address => INVESTOR) storage whitelisted, mapping(address => bool) storage member,string calldata symbol, address wallet, uint investor_type, string calldata jurisdiction) external {
        require(isWhitelisted(whitelisted, wallet), "Not whitelisted");
        require(!findInvestor(investorExists, symbol, wallet), "Investor already exists");

        member[wallet] = true;
        whitelisted[wallet] = INVESTOR(wallet, true, jurisdiction, investor_type);
        investorExists[symbol][wallet] = true;
        investors[symbol].push(wallet);
        emit InvestorAdded(wallet, investor_type, jurisdiction);
    }

    // Implement other functions similarly

    // Modifier for non-reentrancy
    modifier nonReentrant(bool reentrantGuard) {
        require(!reentrantGuard, "Reentrant call detected");
        _;
    }
}
