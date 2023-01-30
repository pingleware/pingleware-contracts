// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

// See https://github.com/soniaRbii/Agri-Trade and
// https://github.com/VivekSJ292018/Atmanirbharinnovation/tree/master/App/app for DAPP

import "../common/Version.sol";
import "../common/Frozen.sol";

contract AgriTrade is Version, Owned {

    uint256 public s = 1;
    uint256 public c;
    uint256 public t=1;
    mapping (address => uint) balances;

    function fundaddr(address addr) public{
        balances[addr] = 2000;
    }

    function sendCoin(address receiver, uint amount, address sender)
        public
        returns(bool sufficient)
    {
        if (balances[sender] < amount) {
            return false;
        }

        balances[sender] -= amount;
        balances[receiver] += amount;

        return true;
    }

    function getBalance(address addr)
        public
        view
        returns(uint)
    {
        return balances[addr];
    }

    struct farmer {
        bytes fid;
        bytes32 fname;
        bytes32 loc;
        bytes32 crop;
        uint256 contact;
        uint quantity;
        uint exprice;
    }

    struct lot {
        bytes lotno;
        bytes grade;
        uint mrp;
        bytes32 testdate;
        bytes32 expdate;
    }

    mapping (bytes => farmer) f1;
    farmer[] public fm;

    mapping (bytes => lot) l1;
    lot[] public l;



    function produce(bytes memory id, bytes32 name, bytes32 loc, bytes32 cr, uint256 con, uint q, uint pr)
        public
    {
        AgriTrade.farmer memory fnew = farmer(id,name,loc,cr,con,q,pr);
        f1[id] = fnew;
        fm.push(fnew);
        s++;
    }

    function getproduce(bytes memory j)
        public
        view
        returns(bytes memory,bytes32,bytes32,bytes32,uint256,uint,uint)
    {
        return (f1[j].fid,f1[j].fname,f1[j].loc,f1[j].crop,f1[j].contact,f1[j].quantity,f1[j].exprice);
    }

    function quality(bytes memory ll, bytes memory g, uint256 p, bytes32 tt, bytes32 e)
        public
    {
        AgriTrade.lot memory lnew = lot(ll,g,p,tt,e);
        l1[ll] = lnew;
        l.push(lnew);
        t++;
    }

    function getquality(bytes memory k)
        public
        view
        returns(bytes memory,bytes memory,uint,bytes32,bytes32)
    {
        return(l1[k].lotno,l1[k].grade,l1[k].mrp,l1[k].testdate,l1[k].expdate);
    }
}