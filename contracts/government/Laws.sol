// SPDX-License-Identifier: BSL-1.1
pragma solidity >=0.4.22 <0.9.0;

import "../abstract/AAccessControl.sol";

abstract contract Laws is AAccessControl {
    struct Law {
        string title;
        string description;
        uint256 enactmentDate;
    }
    
    mapping(uint256 => Law) public laws;
    uint256[] public lawIds;

    event LawEnacted(uint256 lawId, string title, string description, uint256 enactmentDate);
    event LawAmended(uint256 lawId, string description, uint256 enactmentDate);
    event LawRepealed(uint256 lawId);

    function enactLaw(string memory title, string memory description, uint256 enactmentDate) public isOwner {
        uint256 lawId = lawIds.length + 1;
        laws[lawId] = Law(title, description, enactmentDate);
        lawIds.push(lawId);
        emit LawEnacted(lawId, title, description, enactmentDate);
    }
    
    function amendLaw(uint256 lawId, string memory newDescription, uint256 newEnactmentDate) public isOwner {
        require(laws[lawId].enactmentDate != 0, "Law does not exist.");
        laws[lawId].description = newDescription;
        laws[lawId].enactmentDate = newEnactmentDate;
        emit LawAmended(lawId, newDescription, newEnactmentDate);
    }
    
    function repealLaw(uint256 lawId) public isOwner {
        require(laws[lawId].enactmentDate != 0, "Law does not exist.");
        delete laws[lawId];
        for (uint256 i = 0; i < lawIds.length; i++) {
            if (lawIds[i] == lawId) {
                lawIds[i] = lawIds[lawIds.length - 1];
                lawIds.pop();
                break;
            }
        }
        emit LawRepealed(lawId);
    }    
}