// SPDX-License-Identifier: BSL-1.1
pragma solidity >=0.4.22 <0.9.0;

import "../../interfaces/IInvestorManager.sol";
import "../../libs/InvestorManagerLibrary.sol";

contract InvestorManager is IInvestorManager {
    using InvestorManagerLibrary for *;

    mapping(string => address[]) public investors;
    mapping(string => mapping(address => bool)) private investorExists;

    mapping(address => InvestorManagerLibrary.INVESTOR) public whitelisted;

    mapping(address => bool) private accreditedInvestors;
    mapping(address => bool) private accredited_investors;
    mapping(address => bool) private nonaccredited_investors;
    mapping(address => bool) private affiliate_investors;
    mapping(address => bool) private broker_dealers;
    mapping(address => bool) private transfer_agents;
    mapping(address => bool) private institutions;
    mapping(address => bool) private municipalities;
    mapping(address => bool) private banks;
    mapping(address => bool) private investment_companies;
    mapping(address => bool) private nonprofitentities;
    mapping(address => bool) private churches;
    mapping(address => bool) private lenders;
    mapping(address => bool) private trusts;
    mapping(address => bool) private issuers;
    mapping(address => bool) private borrowers;
    mapping(address => bool) private municipalAdvisors;

    address[] private _accreditedInvestors;
    address[] private _accredited_investors;
    address[] private _nonaccredited_investors;
    address[] private _affiliate_investors;
    address[] private _broker_dealers;
    address[] private _transfer_agents;
    address[] private _institutions;
    address[] private _municipalities;
    address[] private _banks;
    address[] private _investment_companies;
    address[] private _nonprofitentities;
    address[] private _churches;
    address[] private _lenders;
    address[] private _trusts;
    address[] private _issuers;
    address[] private _borrowers;
    address[] private _municipalAdvisors;

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

    // Add functions for investor management here
    function isWhitelisted(address wallet) public view  returns (bool) {
        return whitelisted[wallet].active;
    }

    function findInvestor(string calldata symbol,address wallet) public view returns (bool) {
        return investorExists[symbol][wallet];
    }


    function addInvestor(string calldata symbol,address wallet) external nonReentrant {
        require(isWhitelisted(wallet),"not whitelisted");
        require(findInvestor(symbol, wallet) == false,"investor already exists");
        investorExists[symbol][wallet] = true;
        investors[symbol].push(wallet);
        //emit InvestorAdded(wallet, investor_type, jurisdiction);
    }

    function isInvestor(string calldata symbol,address wallet) external view  returns(bool) {
        return findInvestor(symbol, wallet);
    }

    /**
     * NON_ACCREDITED = 0,
     * ACCREDITED = 1, 
     * AFFILIATE = 2, 
     * BROKER_DEALERS =  3, 
     * TRANSFER_AGENTS = 4, 
     * INSTITUTIONS = 5, 
     * BANKS = 6, 
     * MUNICIPALITIES = 7
     * INVESTMENT COMPANY = 8
     * NONPROFIT = 9
     * CHURCH = 10
     * LEDNERS = 11
     * TRUSTS = 12
     * ISSUER = 13
     * MUNICIPALITY ADVISOR = 14
     */
    function addInvestor(address investor, uint investor_type,string memory jurisdiction) external nonReentrant {
        require(whitelisted[investor].active == false,"investor already exists");
        if (investor_type == 1) {
            accredited_investors[investor] = true;
            _accredited_investors.push(investor);
        } else if (investor_type == 2) {
            affiliate_investors[investor] = true;
            _affiliate_investors.push(investor);
        } else if (investor_type == 3) {
            broker_dealers[investor] = true;
            _broker_dealers.push(investor);
        } else if (investor_type == 4) {
            transfer_agents[investor] = true;
            _transfer_agents.push(investor);
            emit TransferAgentAdded(investor);
        } else if (investor_type == 5) {
            institutions[investor] = true;
            _institutions.push(investor);
        } else if (investor_type == 6) {
            banks[investor] = true;
            _banks.push(investor);
        } else if (investor_type == 7) {
            municipalities[investor] = true;
            _municipalities.push(investor);
        } else if (investor_type == 8) {
            investment_companies[investor] = true;
            _investment_companies.push(investor);
        } else if (investor_type == 9) {
            nonprofitentities[investor] = true;
            _nonprofitentities.push(investor);
        } else if (investor_type == 10) {
            churches[investor] = true;
            _churches.push(investor);
        } else if (investor_type == 11) {
            lenders[investor] = true;
            _lenders.push(investor);
        } else if (investor_type == 12) {
            trusts[investor] = true;
            _trusts.push(investor);
        } else if (investor_type == 13) {
            issuers[investor] = true;
            _issuers.push(investor);
        } else if (investor_type == 14) {
            municipalAdvisors[investor] = true;
            _municipalAdvisors.push(investor);
        } else if (investor_type == 99) {
            borrowers[investor] = true;
            _borrowers.push(investor);
        } else {
            nonaccredited_investors[investor] = true;
            _nonaccredited_investors.push(investor);
        }
        whitelisted[investor] = InvestorManagerLibrary.INVESTOR(msg.sender,true,jurisdiction,investor_type);

        emit InvestorAdded(investor, investor_type, jurisdiction);
    }

    function getInvestor(address wallet) external view  returns (address,bool,string memory,uint) {
        return (whitelisted[wallet].wallet,whitelisted[wallet].active,whitelisted[wallet].jurisdiction,whitelisted[wallet].level);
    }

    function getInvestors()  external view  returns (address[] memory,address[] memory,address[] memory,address[] memory,address[] memory,address[] memory,address[] memory) {
        return (_nonaccredited_investors,_accredited_investors,_affiliate_investors,_broker_dealers,_institutions,_investment_companies,_trusts); 
    }
    function getIssuers()  external view  returns (address[] memory,address[] memory,address[] memory,address[] memory,address[] memory,address[] memory) {
        return (_transfer_agents,_banks,_municipalities,_nonprofitentities,_churches,_lenders);
    }
    function getInvestorStatus(address wallet)  external view  returns (bool) {
        return whitelisted[wallet].active;        
    }
    function getInvestorJurisdiction(address wallet)  external view  returns (string memory) {
        return whitelisted[wallet].jurisdiction;
    }
    function getInvestorLevel(address wallet)  external view  returns (uint) {
        return whitelisted[wallet].level;
    }
    function isAccredited(address wallet)  external view  returns (bool) {
        return accredited_investors[wallet];
    }
    function isNonAccredited(address wallet)  external view  returns (bool) {
        return nonaccredited_investors[wallet];
    }
    function isAffiliate(address wallet)  external view  returns (bool) {
        return affiliate_investors[wallet];
    }
    function isBrokerDealer(address wallet)  external view  returns (bool) {
        return broker_dealers[wallet];
    }
    function isTransferAgent(address wallet)  external view  returns (bool) {
        return transfer_agents[wallet];
    }
    function isInstitution(address wallet)  external view  returns (bool) {
        return institutions[wallet];
    }
    function isBank(address wallet)  external view  returns (bool) {
        return banks[wallet];
    }
    function isInvestmentCompany(address wallet)  external view  returns (bool) {
        return investment_companies[wallet];
    }
    function isNonProfitEntity(address wallet)  external view  returns (bool) {
        return nonprofitentities[wallet];
    }
    function isChurch(address wallet)  external view  returns (bool) {
        return churches[wallet];
    }
    function isLender(address wallet)  external view  returns (bool) {
        return lenders[wallet];
    }
    function isVotingTrust(address wallet)  external view  returns (bool) {
        return trusts[wallet];
    }
    function isBorrower(address wallet) external view  returns (bool) {
        return borrowers[wallet];
    }
    function isIssuer(address wallet)  external view  returns (bool) {
        return issuers[wallet];
    }
    function isMunicipalAdvisor(address wallet) external view returns (bool) {
        return municipalAdvisors[wallet];
    }
}
