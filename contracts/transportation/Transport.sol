// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

import "./Payment.sol";

contract Transport is Payment {

    struct Producer {
        address produceraddr;
        string producername;
    }

    struct Distributor {
        address distaddr;
        string distname;
    }

    struct Product {
        uint prodID;
        string prodname;
        uint pricePerUnit;
        address produceraddr;
        uint stock;
    }

    struct TrackingOrder {
        bool flag;
        uint trackingNo;
        string prodname;
        uint prodID;
        address distaddr;
        address produceraddr;
        uint quantity;
        uint amount;
    }

    mapping(address => Producer) public producer;
    mapping(uint => Producer) public prostock;
    mapping(address => Distributor) public distributor;
    mapping(address => Product) public product;
    mapping(uint => TrackingOrder) public trackingorder;
    mapping( uint => Product) public pro;

    //Arrays
    uint[] luminosity;
    uint[] temperature;
    uint[] accelerometer;
    TrackingOrder[] tracking ;
    //Events
    event pop(uint value);
    event TransportMessage(string message);
    event TransportMessage1(string message, string m1);
    event TransportInfo(string _message,uint _trackingNo);
    event add(string s1,string s2,string s3,address s4);
    //addition functions

    function addProducer(address _produceraddr, string memory _name) public {
        producer[_produceraddr].producername = _name;
        emit add("producer with name: ",_name,"and address:", _produceraddr);
    }

    function addDistributor(address _distaddr, string memory _name) public {
        distributor[_distaddr].distname = _name;
        emit add("distributor with name: ",_name,"and address:", _distaddr);
    }

    function addProduct(uint _prodID)
        public
    {

        if(_prodID == 1) {
            pro[1].prodname = "Red Wine";
            pro[1].pricePerUnit = 10;
            pro[1].prodID = 1;
            pro[1].stock = 10;
            emit TransportMessage1("Product added: ",pro[1].prodname);
        } else if(_prodID == 2) {
            pro[2].prodname = "White Wine";
            pro[2].pricePerUnit = 15;
            pro[2].prodID = 2;
            pro[2].stock = 20;
            emit TransportMessage1("Product added: ",pro[2].prodname);
        }
    }

    //setupShipment is supposed to be called by Distributor
    function createOrderByDistributor(address _produceraddr, address _distaddr,uint _quantity, uint _prodID)
        public
        returns(uint)
    {
            Producer storage p = producer [_produceraddr];
            Distributor storage d = distributor[_distaddr];
            p.produceraddr = _produceraddr;
            d.distaddr = _distaddr;

            uint _trackingNo = uint256(keccak256(abi.encodePacked(_prodID)));

            TrackingOrder storage t = trackingorder[_trackingNo];
            t.trackingNo = _trackingNo;
            t.quantity = _quantity;
            emit TransportInfo("Tracking no.:",_trackingNo);
            return _trackingNo;
        }

        function sendOrderByDistributor(address _produceraddr,address _distaddr,uint _trackingNo,uint _quantity)
            public
        {
            emit TransportMessage("Order has been placed by distributor");

            Product memory p;
            // tracking[_trackingNo]= ;
            tracking[_trackingNo].prodname = p.prodname;
            tracking[_trackingNo].trackingNo = _trackingNo;
            tracking[_trackingNo].prodID = p.prodID;
            tracking[_trackingNo].distaddr = _distaddr;
            tracking[_trackingNo].produceraddr = _produceraddr;
            tracking[_trackingNo].quantity = _quantity;

            emit pop(tracking[_trackingNo].trackingNo);

            acceptOrderByProducer(_produceraddr,_trackingNo); //producer accepts order and then sends the order
        }

        //structure object
        TrackingOrder ord;
        //acceptOrder is supposed to be called by producer
        function acceptOrderByProducer(address _produceraddr,uint _trackingNo)
            public
            returns (uint)
        {
            require(msg.sender == _produceraddr,"");
            Product storage prod = product[_produceraddr];
            TrackingOrder storage t = tracking[_trackingNo];
            emit pop(t.trackingNo);
            if((t.trackingNo == _trackingNo) && (prod.stock >= t.quantity)) {
                prod.stock = prod.stock - t.quantity;

                emit TransportInfo("product sent: ",trackingorder[_trackingNo].trackingNo);
                emit TransportInfo("Stock remained: ",prod.stock);
                ord.flag = true;
                uint amount = (t.quantity * prod.pricePerUnit);
                emit TransportInfo("Auto amount: ",amount);
                return amount;
            } else {
                emit TransportMessage("Insufficient quantity or wrong product");
            }
            return 0;
        }

        function randomtemperature(uint no, uint hrs)
            public
            returns (uint[] memory)
        {
            uint _no = no;
            for(uint i = 0 ; i < hrs ; i++) {
                temperature.push((uint256(keccak256(abi.encodePacked(_no))) % 100));
                temperature[i] = (temperature[i] % 10);
                temperature[i] = (temperature[i] * 3);
                _no++;
                emit pop(temperature[i]);
            }
            return temperature;
        }

        function randomaccelerometer(uint no, uint hrs)
            public
            returns (uint[] memory)
        {
            uint _no = no;
            for(uint i = 0 ; i<hrs ; i++) {
                accelerometer.push((uint256(keccak256(abi.encodePacked(_no)))%10));
                //accelerometer[i] =  accelerometer[i]/10;
                _no++;
                emit pop(accelerometer[i]);
            }
            return accelerometer;
         }

        function randomluminosity(uint no, uint hrs)
            public
            returns (uint[] memory)
        {
            uint _no = no;
            for(uint i = 0 ; i<hrs ; i++) {
                luminosity.push((uint256(keccak256(abi.encodePacked(_no)))%1000));
                _no++;
                emit pop(luminosity[i]);
            }
            return luminosity;
        }

        function acceptOrderByDistributor(uint _trackingNo, address _distaddr, address _produceraddr, uint _amount)
            public
        {
            TrackingOrder storage t = trackingorder[_trackingNo];
            require(ord.flag == true, "");

            if(t.trackingNo == _trackingNo){
                emit TransportMessage("Product received");
                uint amt = checkprice(_amount);
                makePayment(_distaddr,_produceraddr, amt);
                emit TransportMessage("Payment sent by distributor");
            }
        }

        function checkprice (uint _amount)
            public
            returns(uint)
        {
            uint amt;

            for (uint i = 0;i < temperature.length; i++) {
                if (temperature[i]>20) {
                    amt = _amount - ((_amount*10) / 100);
                } else {
                    amt = _amount;
                }

                for (uint j = 0; j < luminosity.length; j++) {
                    if (luminosity[i] > 80) {
                        amt = _amount - ((_amount*10) / 100);
                    } else {
                        amt = _amount;
                    }
                    for (uint k = 0; k < accelerometer.length; k++) {
                        if (accelerometer[i] < 1) {
                            amt = _amount - ((_amount*10) / 100);
                        } else {
                            amt = _amount;
                        }
                    }
                }
            }

            emit TransportInfo("The Final Amount is: ",amt);

            if (amt == _amount) {
                emit TransportMessage("Custom's Verified");
            }
             return _amount;
        }
}
