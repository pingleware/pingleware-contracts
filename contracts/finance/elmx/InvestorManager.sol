// SPDX-License-Identifier: BSL-1.1
pragma solidity >=0.4.22 <0.9.0;

import "../../interfaces/IInvestorManager.sol";
import "../../libs/InvestorManagerLibrary.sol";

contract InvestorManager is IInvestorManager {
    using InvestorManagerLibrary for *;

    mapping(string => address[]) public investors;
    mapping(string => mapping(address => bool)) private investorExists;
    uint256 private investorCount = 0;

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
    function findInvestor(address[] memory _investors,address wallet) internal pure returns (bool) {
        for(uint256 i=0; i<_investors.length; i++) {
            if (_investors[i] == wallet) {
                return true;
            }
        }
        return false;
    }

    function addInvestor(address wallet) external nonReentrant {
        require(!isWhitelisted(wallet),"already whitelisted");
        whitelisted[wallet].wallet = wallet;
        whitelisted[wallet].active = true;
        whitelisted[wallet].level = 0; // default to non-accredited
    }

    function addInvestor(string calldata symbol,address wallet) external nonReentrant {
        require(isWhitelisted(wallet),"not whitelisted");
        require(findInvestor(symbol, wallet) == false,"investor already exists");
        investorExists[symbol][wallet] = true;
        investors[symbol].push(wallet);
        investorCount++;
        //emit InvestorAdded(wallet, investor_type, jurisdiction);
    }

    function getInvestorsBySymbol(string calldata symbol) external view returns (address[] memory) {
        return investors[symbol];
    }

    function isInvestor(string calldata symbol,address wallet) external view  returns(bool) {
        return findInvestor(symbol, wallet);
    }

    function removeInvestor(address wallet) external nonReentrant {
        //require(isWhitelisted(wallet),"not whitelisted");
        whitelisted[wallet].active = false;
    }

    function removeInvestorBySymbol(string calldata symbol,address wallet) external nonReentrant {
        require(isWhitelisted(wallet),"not whitelisted");
        require(findInvestor(symbol, wallet) == true,"investor does not exists");
        investorExists[symbol][wallet] = false;
        bool found = false;
        for(uint256 i=0; i<investorCount; i++) { 
            if (!found) {
                if (investors[symbol][i] == wallet) {
                    if (i < investors[symbol].length) {
                        delete investors[symbol][i];
                        investors[symbol][i] = investors[symbol][investors[symbol].length - 1];
                        investors[symbol].pop();
                        found = true;
                    }
                }
            }
        }
        require(found,"investor not assigned to symbol");
    }

    function removeInvestor(uint256 investor_type,address wallet) external nonReentrant {
        bool found = false;

        if (investor_type == 0) {
            for (uint256 i=0; i<_nonaccredited_investors.length; i++) {
                if (!found) {
                    if (_nonaccredited_investors[i] == wallet) {
                        if (i < _nonaccredited_investors.length) {
                            delete _nonaccredited_investors[i];
                            _nonaccredited_investors[i] = _nonaccredited_investors[_nonaccredited_investors.length - 1];
                            _nonaccredited_investors.pop();
                            found = true;
                        }
                    }
                }
            }
        } else if (investor_type == 1) {
            for (uint256 i=0; i<_accredited_investors.length; i++) {
                if (!found) {
                    if (_accredited_investors[i] == wallet) {
                        if (i < _accredited_investors.length) {
                            delete _accredited_investors[i];
                            _accredited_investors[i] = _accredited_investors[_accredited_investors.length - 1];
                            _accredited_investors.pop();
                            found = true;
                        }
                    }
                }
            }
        } else if (investor_type == 2) {
            for (uint256 i=0; i<_affiliate_investors.length; i++) {
                if (!found) {
                    if (_affiliate_investors[i] == wallet) {
                        if (i < _affiliate_investors.length) {
                            delete _affiliate_investors[i];
                            _affiliate_investors[i] = _affiliate_investors[_affiliate_investors.length - 1];
                            _affiliate_investors.pop();
                            found = true;
                        }
                    }
                }
            }
        } else if (investor_type == 3) {
            for (uint256 i=0; i<_broker_dealers.length; i++) {
                if (!found) {
                    if (_broker_dealers[i] == wallet) {
                        if (i < _broker_dealers.length) {
                            delete _broker_dealers[i];
                            _broker_dealers[i] = _broker_dealers[_broker_dealers.length - 1];
                            _broker_dealers.pop();
                            found = true;
                        }
                    }
                }
            }
        } else if (investor_type == 4) {
            for (uint256 i=0; i<_transfer_agents.length; i++) {
                if (!found) {
                    if (_transfer_agents[i] == wallet) {
                        if (i < _transfer_agents.length) {
                            delete _transfer_agents[i];
                            _transfer_agents[i] = _transfer_agents[_transfer_agents.length - 1];
                            _transfer_agents.pop();
                            found = true;
                        }
                    }
                }
            }
        } else if (investor_type == 5) {
            for (uint256 i=0; i<_institutions.length; i++) {
                if (!found) {
                    if (_institutions[i] == wallet) {
                        if (i < _institutions.length) {
                            delete _institutions[i];
                            _institutions[i] = _institutions[_institutions.length - 1];
                            _institutions.pop();
                            found = true;
                        }
                    }
                }
            }
        } else if (investor_type == 6) {
            for (uint256 i=0; i<_banks.length; i++) {
                if (!found) {
                    if (_banks[i] == wallet) {
                        if (i < _banks.length) {
                            delete _banks[i];
                            _banks[i] = _banks[_banks.length - 1];
                            _banks.pop();
                            found = true;
                        }
                    }
                }
            }
        } else if (investor_type == 7) {
            for (uint256 i=0; i<_municipalities.length; i++) {
                if (!found) {
                    if (_municipalities[i] == wallet) {
                        if (i < _municipalities.length) {
                            delete _municipalities[i];
                            _municipalities[i] = _municipalities[_municipalities.length - 1];
                            _municipalities.pop();
                            found = true;
                        }
                    }
                }
            }
        } else if (investor_type == 8) {
            for (uint256 i=0; i<_investment_companies.length; i++) {
                if (!found) {
                    if (_investment_companies[i] == wallet) {
                        if (i < _investment_companies.length) {
                            delete _investment_companies[i];
                            _investment_companies[i] = _investment_companies[_investment_companies.length - 1];
                            _investment_companies.pop();
                            found = true;
                        }
                    }
                }
            }
        } else if (investor_type == 9) {
            for (uint256 i=0; i<_nonprofitentities.length; i++) {
                if (!found) {
                    if (_nonprofitentities[i] == wallet) {
                        if (i < _nonprofitentities.length) {
                            delete _nonprofitentities[i];
                            _nonprofitentities[i] = _nonprofitentities[_nonprofitentities.length - 1];
                            _nonprofitentities.pop();
                            found = true;
                        }
                    }
                }
            }
        } else if (investor_type == 10) {
            for (uint256 i=0; i<_churches.length; i++) {
                if (!found) {
                    if (_churches[i] == wallet) {
                        if (i < _churches.length) {
                            delete _churches[i];
                            _churches[i] = _churches[_churches.length - 1];
                            _churches.pop();
                            found = true;
                        }
                    }
                }
            }
        } else if (investor_type == 11) {
            for (uint256 i=0; i<_lenders.length; i++) {
                if (!found) {
                    if (_lenders[i] == wallet) {
                        if (i < _lenders.length) {
                            delete _lenders[i];
                            _lenders[i] = _lenders[_lenders.length - 1];
                            _lenders.pop();
                            found = true;
                        }
                    }
                }
            }
        } else if (investor_type == 12) {
            for (uint256 i=0; i<_trusts.length; i++) {
                if (!found) {
                    if (_trusts[i] == wallet) {
                        if (i < _trusts.length) {
                            delete _trusts[i];
                            _trusts[i] = _trusts[_trusts.length - 1];
                            _trusts.pop();
                            found = true;
                        }
                    }
                }
            }
        } else if (investor_type == 13) {
            for (uint256 i=0; i<_issuers.length; i++) {
                if (!found) {
                    if (_issuers[i] == wallet) {
                        if (i < _issuers.length) {
                            delete _issuers[i];
                            _issuers[i] = _issuers[_issuers.length - 1];
                            _issuers.pop();
                            found = true;
                        }
                    }
                }
            }
        } else if (investor_type == 14) {
            for (uint256 i=0; i<_municipalAdvisors.length; i++) {
                if (!found) {
                    if (_municipalAdvisors[i] == wallet) {
                        if (i < _municipalAdvisors.length) {
                            delete _municipalAdvisors[i];
                            _municipalAdvisors[i] = _municipalAdvisors[_municipalAdvisors.length - 1];
                            _municipalAdvisors.pop();
                            found = true;
                        }
                    }
                }
            }
        } else if (investor_type == 99) {
            for (uint256 i=0; i<_borrowers.length; i++) {
                if (!found) {
                    if (_borrowers[i] == wallet) {
                        if (i < _borrowers.length) {
                            delete _borrowers[i];
                            _borrowers[i] = _borrowers[_borrowers.length - 1];
                            _borrowers.pop();
                            found = true;
                        }
                    }
                }
            }
        }
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
     * LENDERS = 11
     * TRUSTS = 12
     * ISSUER = 13
     * MUNICIPALITY ADVISOR = 14
     */
    function addInvestor(address investor, uint investor_type,string memory jurisdiction) external nonReentrant {
        require(whitelisted[investor].active == false,"investor already exists");
        bool investorAdded = false;

        if (investor_type == 1) {
            if (!findInvestor(_accredited_investors, investor)) {
                _accredited_investors.push(investor);
            }
            accredited_investors[investor] = true;
            investorAdded = true;
        } else if (investor_type == 2) {
            if (!findInvestor(_affiliate_investors, investor)) {
                _affiliate_investors.push(investor);
            }
            affiliate_investors[investor] = true;
            investorAdded = true;
        } else if (investor_type == 3) {
            if (!findInvestor(_broker_dealers, investor)) {
                _broker_dealers.push(investor);
            }
            broker_dealers[investor] = true;
            investorAdded = true;
        } else if (investor_type == 4) {
            if (!findInvestor(_transfer_agents, investor)) {
                _transfer_agents.push(investor);
            }
            transfer_agents[investor] = true;
            investorAdded = true;
            emit TransferAgentAdded(investor);
        } else if (investor_type == 5) {
            if (!findInvestor(_institutions, investor)) {
                _institutions.push(investor);
            }
            institutions[investor] = true;
            investorAdded = true;
        } else if (investor_type == 6) {
            if (!findInvestor(_banks, investor)) {
                _banks.push(investor);
            }
            banks[investor] = true;
            investorAdded = true;
        } else if (investor_type == 7) {
            if (!findInvestor(_municipalities, investor)) {
                _municipalities.push(investor);
            }
            municipalities[investor] = true;
            investorAdded = true;
        } else if (investor_type == 8) {
            if (!findInvestor(_investment_companies, investor)) {
                _investment_companies.push(investor);
            }
            investment_companies[investor] = true;
            investorAdded = true;
        } else if (investor_type == 9) {
            if (!findInvestor(_nonprofitentities, investor)) {
                _nonprofitentities.push(investor);
            }
            nonprofitentities[investor] = true;
            investorAdded = true;
        } else if (investor_type == 10) {
            if (!findInvestor(_churches, investor)) {
                _churches.push(investor);
            }
            churches[investor] = true;
            investorAdded = true;
        } else if (investor_type == 11) {
            if (!findInvestor(_lenders, investor)) {
                _lenders.push(investor);
            }
            lenders[investor] = true;
            investorAdded = true;
        } else if (investor_type == 12) {
            if (findInvestor(_trusts, investor)) {
                _trusts.push(investor);
            }
            trusts[investor] = true;
            investorAdded = true;
        } else if (investor_type == 13) {
            if (!findInvestor(_issuers, investor)) {
                _issuers.push(investor);
            }
            issuers[investor] = true;
            investorAdded = true;
        } else if (investor_type == 14) {
            if (!findInvestor(_municipalAdvisors, investor)) {
                _municipalAdvisors.push(investor);
            }
            municipalAdvisors[investor] = true;
            investorAdded = true;
        } else if (investor_type == 99) {
            if (!findInvestor(_borrowers, investor)) {
                _borrowers.push(investor);
            }
            borrowers[investor] = true;
            investorAdded = true;
        } else {
            if (!findInvestor(_nonaccredited_investors, investor)){
                _nonaccredited_investors.push(investor);
            }
            nonaccredited_investors[investor] = true;
            investorAdded = true;
        }

        if (investorAdded) {
            whitelisted[investor] = InvestorManagerLibrary.INVESTOR(investor,true,jurisdiction,investor_type);
            emit InvestorAdded(investor, investor_type, jurisdiction);
        }
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
