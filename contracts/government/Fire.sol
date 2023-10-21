// SPDX-License-Identifier: BSL-1.1
pragma solidity >=0.4.22 <0.9.0;

import "../abstract/AAccessControl.sol";

abstract contract Fire is AAccessControl {
    uint256 public emergencyFunds;
    
    struct Firefighter {
        string name;
        uint256 experience;
    }
    
    mapping(address => Firefighter) public firefighters;
    address[] public activeFirefighters;

    event FirefighterHired(address firefighterAddress, string name, uint256 experience);
    event FirefighterResigned(address firefighterAddress);
    event FundsDonated(address donor, uint256 amount);
    event EmergencyFundsWithdrawn(address recipient, uint256 amount);

    // This function can receive Ether
    receive() external payable {
        // Do something with the received Ether
        emergencyFunds += msg.value;
    }

    function hireFirefighter(address firefighterAddress, string memory name, uint256 experience) public isOwner {
        require(firefighters[firefighterAddress].experience == 0, "Firefighter already exists.");
        firefighters[firefighterAddress] = Firefighter(name, experience);
        activeFirefighters.push(firefighterAddress);
        emit FirefighterHired(firefighterAddress, name, experience);
    }
    
    function resignFirefighter(address firefighterAddress) public isOwner {
        require(firefighters[firefighterAddress].experience > 0, "Firefighter does not exist.");
        delete firefighters[firefighterAddress];
        for (uint i = 0; i < activeFirefighters.length; i++) {
            if (activeFirefighters[i] == firefighterAddress) {
                activeFirefighters[i] = activeFirefighters[activeFirefighters.length - 1];
                activeFirefighters.pop();
                break;
            }
        }
        emit FirefighterResigned(firefighterAddress);
    }
    
    function donateFunds() public payable {
        require(msg.value > 0, "You must send some Ether to donate funds.");
        emergencyFunds += msg.value;
        emit FundsDonated(msg.sender, msg.value);
    }
    
    function withdrawEmergencyFunds(address recipient, uint256 amount) public isOwner {
        require(amount <= emergencyFunds, "Insufficient emergency funds.");
        emergencyFunds -= amount;
        payable(recipient).transfer(amount);
        emit EmergencyFundsWithdrawn(recipient, amount);
    }
}