// SPDX-License-Identifier: BSL-1.1
pragma solidity >=0.4.22 <0.9.0;

import "./CountyGovernment.sol";
import "../Police.sol";
import "../Case.sol";

interface ICountyGovernment {
    enum ProposalStatus { Proposed, Approved, Rejected }

    function getCountyAddress() external view returns (address);
    function isCommissioner(address account) external view returns (bool);
    function addCommissioner(address newCommissioner) external;
    function submitProposal(string memory description) external;
    function decideProposal(uint256 proposalId, ProposalStatus status) external;
}

contract CountyJail is Police {

    struct Inmate {
        string first_name;
        string last_name;
        uint256 dob;
        bool custody;
        string caseIndex;
    }

    struct Message {
        address other;
        uint256 timestamp;
        bool attorney;
        string text;
    }

    uint256 public balance;
    uint256 public commissary_revenue;

    mapping (address => Inmate) public inmates;
    mapping (address => string[]) private inmate_property;
    mapping (address => Message[]) private inmate_messages;
    mapping (address => uint256) private inmate_balances;

    event InmateAdded(address,address,string,string,uint256,string);
    event InmateReleased(address,address,string,string);
    event InmatePropertyAdded(address,address,string);
    event Deposit(address indexed from,address inmate, uint256 value);
    event Withdrawal(address,uint256);
    event CommissaryPurchase(address,uint256,string);
    event InmateFundsTransfer(address,address,uint256);
    event InmateMessageDeleted(address,address,uint,string);

    string public facilityName;

    ICountyGovernment countyGovernmentContract;

    constructor(address countyGovvernmentAddress) {
        countyGovernmentContract = ICountyGovernment(countyGovvernmentAddress);
    }

    modifier isInmate() {
        require(inmates[msg.sender].custody,"inmate is not in custody or has been released");
        _;
    }

    // This function can receive Ether
    receive() external payable {
        // Do something with the received Ether
    }

    function addInmate(address inmate, string calldata first_name,string calldata last_name,uint256 dob) external isOfficer {
        string memory caseIndex = getCaseIndexByDefendant(inmate);
        inmates[inmate] = Inmate(first_name,last_name,dob,true,caseIndex);
        emit InmateAdded(msg.sender,inmate, first_name, last_name, dob, caseIndex);
    }

    function setFacilityName(string calldata name) external isOwner {
        facilityName = name;
    }

    function addInmateProperty(address inmate,string calldata description) external isOfficer {
        require(inmates[inmate].custody,"inmate already released, not in custody");
        inmate_property[inmate].push(description);
        emit InmatePropertyAdded(msg.sender, inmate, description);
    }

    function releaseInmate(address inmate,string calldata reason) external isOfficer {
        require(inmates[inmate].custody,"inmate already released, not in custody");
        inmates[inmate].custody = false;
        emit InmateReleased(msg.sender,inmate,inmates[inmate].caseIndex,reason);
    }

    function getCaseInfo(address inmate) external view returns (CaseRecord memory){
      return getCaseInfo(inmates[inmate].caseIndex); 
    }

    function getInmateProperty(address inmate) external view returns (string[] memory) {
        return inmate_property[inmate];
    }

    function inmateAssignLegalRepresentative(address _representative) external isInmate {
        assignLegalRepresentative(inmates[msg.sender].caseIndex,_representative);
    }

    function sendInmateMessage(address inmate,string memory _message) external {
        bool attorney = false;
        if (checkAssignedAttorney(inmates[inmate].caseIndex)) {
            attorney = true;
        }
        inmate_messages[inmate].push(Message(msg.sender,block.timestamp,attorney,_message));
    }

    function getInmateMessages() external view isInmate returns (Message[] memory) {
        return inmate_messages[msg.sender];
    }

    function getNonAttorneyInmateMessages(address inmate) external view isOfficer returns (Message[] memory) {
        Message[] memory _messages;
        uint count = 0;

        for (uint i=0; i < inmate_messages[inmate].length; i++) {
            if (inmate_messages[inmate][i].attorney == false) {
                _messages[count++] = inmate_messages[inmate][i];
            }
        }
        return _messages;
    }

    function deleteNonAttorneyInmateMessage(address inmate,uint msgno,string calldata reason) external isOfficer {
        require(inmate_messages[inmate][msgno].attorney == false,"cannot delete attorney privilege messages");
        delete inmate_messages[inmate][msgno];
        emit InmateMessageDeleted(msg.sender,inmate,msgno,reason);
    }

    function deposit(address inmate) external payable {
        require(inmates[inmate].custody,"inmate already released, not in custody");
        require(msg.value > 0, "You must send some monies to deposit.");
        inmate_balances[inmate] += msg.value;
        emit Deposit(msg.sender,inmate,msg.value);
    }

    function getBalance() external view isInmate returns (uint256) {
        return inmate_balances[msg.sender];
    }

    function withdraw(uint256 amount) external isInmate {
        require(amount <= address(this).balance, "Insufficient balance.");
        require(amount <= inmate_balances[msg.sender], "Insufficient balance.");
        inmate_balances[msg.sender] -= amount;
        payable(msg.sender).transfer(amount); // pay out funds to inmate wallet
        emit Withdrawal(msg.sender,amount);
    }    

    function buy(uint256 amount, string memory item) external isInmate {
        require(inmates[msg.sender].custody,"inmate already released, not in custody"); // can onyl buy from commissary while in custody
        require(amount <= inmate_balances[msg.sender], "Insufficient balance.");
        inmate_balances[msg.sender] -= amount;
        commissary_revenue += amount;
        emit CommissaryPurchase(msg.sender,amount,item);
    }

    function transferToAnotherInmate(address inmate,uint256 amount) external isInmate {
        require(inmates[inmate].custody,"receiving inmate already released, not in custody");
        require(amount <= inmate_balances[msg.sender], "Insufficient balance.");
        inmate_balances[msg.sender] -= amount;
        inmate_balances[inmate] += amount;
        emit InmateFundsTransfer(msg.sender,inmate,amount);
    }

}