// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

/**
 * An example of an Oracle, where the Owner will create a new contract, and update the contract with pertinent data
 * for other contracts to use
 */

import "../common/Version.sol";
import "../common/Frozen.sol";

contract BusStops is Version, Frozen {
    string public NAME;

    struct BusStop {
        uint id;
        uint256 last_updated;
        string  stop_name;
        string  latitude; // using string to represent negative and decimals
        string  longitude; // using string to represent negative and decimals
        string  street;
        string  crossroad;
        string  position;
        string  direction;
        bool    status;
        string  location;
    }

    BusStop[] public busStops;

    mapping(uint => BusStop) _busStop;

    event BusStopAdded(address,uint,uint256,string,string,string,string,string,string,string,bool,string);
    event BusStopUpdated(address,uint,uint256,string,string,string,string,string,string,string,bool,string);

    constructor(string memory _name) {
        NAME = _name;
    }

    function getBusStop(uint index) public view returns(BusStop memory) {
        return busStops[index];
    }

    function getBusStops() public view returns(BusStop[] memory) {
        return busStops;
    }

    function getActiveBusStops() public view returns(BusStop[] memory) {
        BusStop[] memory active;

        for(uint i = 0; i < busStops.length; i++) {
            if (busStops[i].status) {
                active[active.length] = busStops[i];
            }
        }
        return active;
    }

    function add(uint _id,
                 uint256 epoch,
                 string calldata _name,
                 string calldata _latitude,
                 string calldata _longitude,
                 bool _status)
        public
        okOwner
    {
        BusStop memory busStop = BusStop(_id,epoch,_name,_latitude,_longitude,"","","","",_status,"");
        busStops.push(busStop);
        emit BusStopAdded(msg.sender,_id,epoch,_name,_latitude,_longitude,"","","","",_status,"");
    }
}