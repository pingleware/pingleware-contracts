// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

import "./Transport.sol";

contract Driver is Transport {

    struct Tracking {
        uint    trackingNo;
        uint256 latitude;
        uint256 longitude;
        uint256 epoch;
        string  memo; // driver notes, rest status, or other updates?
    }

    mapping (address => Tracking[]) logs;

    function drive(address _produceraddr, address _distaddr, uint _quantity, uint _prodID, uint no,uint hrs)
        public
        returns (uint)
    {
        //this should return tracking no.
        uint _trackingNo = createOrderByDistributor(_produceraddr,_distaddr,_quantity, _prodID);

        sendOrderByDistributor(_produceraddr,_distaddr,_trackingNo,_quantity);

        //this return calculated amount
        uint _amount = acceptOrderByProducer(_produceraddr,_trackingNo);
        emit TransportMessage("Order is being sent");
        randomtemperature(no,  hrs);
        randomaccelerometer(no,hrs);
        randomluminosity(no,hrs);
        acceptOrderByDistributor(_trackingNo,_distaddr,_produceraddr,_amount);
        return _trackingNo;
    }

    function updateTrackingPosition(uint trackingNo, uint256 latitude, uint256 longitude, uint256 epoch, string memory memo)
        public
    {
        Tracking memory location = Tracking(trackingNo, latitude, longitude, epoch, memo);
        logs[msg.sender].push(location);
    }

    function getLogs()
        public
        view
        returns (Tracking[] memory)
    {
        return logs[msg.sender];
    }

    function getDriverLogs(address driver)
        public
        view
        returns (Tracking[] memory)
    {
        return logs[driver];
    }
}
