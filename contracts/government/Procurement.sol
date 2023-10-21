// SPDX-License-Identifier: BSL-1.1
pragma solidity >=0.4.22 <0.9.0;

import "../abstract/AAccessControl.sol";

abstract contract Procurement is AAccessControl {

    enum ContractStatus { Open, Awarded, Completed }
    
    struct Contract {
        uint256 contractId;
        string title;
        string description;
        uint256 bidDeadline;
        address contractor;
        uint256 contractValue;
        ContractStatus status;
    }
    
    mapping(uint256 => Contract) public contracts;
    uint256 public contractCounter;

    event ContractCreated(uint256 contractId, string title, string description, uint256 bidDeadline);
    event ContractAwarded(uint256 contractId, address contractor, uint256 contractValue);
    event ContractCompleted(uint256 contractId);
    
    function createContract(string memory title, string memory description, uint256 bidDeadline) public isOwner {
        contractCounter++;
        contracts[contractCounter] = Contract(contractCounter, title, description, bidDeadline, address(0), 0, ContractStatus.Open);
        emit ContractCreated(contractCounter, title, description, bidDeadline);
    }
    
    function awardContract(uint256 contractId, address contractor, uint256 contractValue) public isOwner {
        require(contracts[contractId].status == ContractStatus.Open, "Contract is not open for bids.");
        contracts[contractId].contractor = contractor;
        contracts[contractId].contractValue = contractValue;
        contracts[contractId].status = ContractStatus.Awarded;
        emit ContractAwarded(contractId, contractor, contractValue);
    }
    
    function completeContract(uint256 contractId) public isOwner {
        require(contracts[contractId].status == ContractStatus.Awarded, "Contract is not awarded.");
        contracts[contractId].status = ContractStatus.Completed;
        emit ContractCompleted(contractId);
    }
}