// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

import "../Version.sol";
import "../Owned.sol";

contract Membership is Version, Owned {
    string public name;
    string public symbol;
    uint256 public fee;

    mapping (address => uint) private membership_requests;
    mapping (address => uint) private membership_tokens;

    address[] private members;

    event Forfeited(address sender);
    event Revoked(address sender);
    event Request(address sender);
    event ApprovedMembership(address member,uint value);

    constructor(string memory _name, string memory _symbol, uint256 _fee)
    {
        name = _name;
        symbol = _symbol;
        fee = _fee;
    }

    modifier isValidAddress() {
        require (msg.sender != address(0), "Address is not valid");
        require (msg.sender != getOwner(), "Address cannot be owner");
        _;
    }

    modifier noPendingRequest() {
        require (membership_requests[msg.sender] == 0, "Request has already been made");
        _;
    }

    modifier isPendingRequest(address user) {
        require (membership_requests[user] != 0, "No pending request for membership");
        _;
    }

    modifier notMember() {
        require (membership_tokens[msg.sender] == 0, "already a member");
        _;
    }

    modifier hasToken() {
        require (membership_tokens[msg.sender] == 1, "no membership token exists");
        _;
    }

    function revokeFrom(address _from)
        public
    {
        delete membership_tokens[_from];
        emit Revoked(_from);
    }
    function isCurrentMember(address _to)
        public
        view
        returns (bool)
    {
        return (membership_tokens[_to] == 1);
    }

    function requestMembership()
        public
        payable
        isValidAddress()
        noPendingRequest()
        notMember()
    {
        require(msg.sender.balance > 0.001 ether,"insufficient balance");
        payable(msg.sender).transfer(0.001 ether);
        membership_requests[msg.sender] = 1;
        emit Request(msg.sender);
    }

    function forfeitMembership()
        public
        payable
        hasToken()
    {
        delete membership_tokens[msg.sender];
        emit Forfeited(msg.sender);
        emit Revoked(msg.sender);
    }

    function approveRequest(address _user, bytes32 encrypted, bytes memory signature)
        public
        isOwner(_user,encrypted,signature)
        isPendingRequest(_user)
    {
        delete membership_requests[_user];
        membership_tokens[_user] = block.number;
        members.push(_user);
        emit ApprovedMembership(_user, 0);
    }

    function discardRequest(address _user)
        public
    {
        delete membership_requests[_user];
    }

    function getAllMembers()
        public
        view
        returns (address[] memory)
    {
        return members;
    }

    function getCurrentMemberCount()
        public
        view
        returns (uint)
    {
        return members.length;
    }
}