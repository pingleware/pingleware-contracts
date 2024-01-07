// SPDX-License-Identifier: BSL-1.1
pragma solidity >=0.4.22 <0.9.0;

interface IRCEXInvestorManager {
    event InvestorAdded(address wallet,uint investor_type,string jurisdiction);
    event TransferAgentAdded(address wallet);

    function isWhitelisted(address wallet)  external view returns (bool);

    function addInvestor(address investor, uint investor_type,string memory jurisdiction) external;
    function getInvestor(address wallet) external view returns (address,bool,string memory,uint);
    function getInvestors() external view returns (address[] memory,address[] memory,address[] memory,address[] memory);
    function getIssuers()  external view returns (address[] memory,address[] memory,address[] memory,address[] memory,address[] memory,address[] memory,address[] memory,address[] memory);
    function getInvestorStatus(address wallet) external view returns (bool);
    function getInvestorJurisdiction(address wallet) external view returns (string memory);
    function getInvestorLevel(address wallet) external view returns (uint);

    function isBrokerDealer(address wallet)  external view returns (bool);
    function isTransferAgent(address wallet)  external view returns (bool);
    function isInstitution(address wallet)  external view returns (bool);
    function isBank(address wallet)  external view returns (bool);
    function isInvestmentCompany(address wallet)  external view returns (bool);
    function isNonProfitEntity(address wallet)  external view returns (bool);
    function isChurch(address wallet)  external view returns (bool);
    function isLender(address wallet)  external view returns (bool);
    function isVotingTrust(address wallet)  external view returns (bool);
    function isIssuer(address wallet)  external view returns (bool);
    function isMunicipalAdvisor(address wallet)  external view returns (bool);
    function isCFPortal(address wallet)  external view returns (bool);
}