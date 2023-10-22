// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

// See https://github.com/bazinga776/AgriChain-Blockchain

import "../common/Version.sol";
import "../common/Frozen.sol";

contract AgriChain is Version, Frozen {
    uint[16] public productIds;

    struct Data{
        string name;
        string status;
        bytes32 hash_value;
        string curLoc;
    }

    mapping(uint => Data) prod;

    // Adding a product
    function addProduct(uint prodId,string memory pname,string memory pstatus,string memory pcurLoc)
        external
        returns (uint)
    {
        require(prodId >= 0 && prodId <= 15,"go home simon");
        prod[prodId].name = pname;
        prod[prodId].status = pstatus;
        prod[prodId].curLoc = pcurLoc;
        prod[prodId].hash_value = sha256(string_tobytes(strConcat(pname,pstatus,pcurLoc)));
        productIds[prodId] = prodId;
        return prodId;
    }

    // Retrieving the adopters
    function getProductIds()
        external
        view
        returns (uint[16] memory)
    {
        return productIds;
    }

    function getProductDetail(uint prodId)
        external
        view
        returns (string memory,string memory,string memory,bytes32 )
    {
        string memory prod_name = prod[prodId].name;
        string memory prod_status = prod[prodId].status;
        string memory prod_curLoc = prod[prodId].curLoc;
        bytes32  prod_hash = prod[prodId].hash_value;
        return (prod_name,prod_status,prod_curLoc,prod_hash);
    }

    function string_tobytes(string memory s)
        public
        pure
        returns (bytes memory)
    {
        bytes memory b3 = bytes(s);
        return b3;
    }

    function strConcat(string memory _a, string memory _b, string memory _c, string memory _d, string memory  _e)
        internal
        pure
        returns (string memory)
    {
        bytes memory _ba = bytes(_a);
        bytes memory _bb = bytes(_b);
        bytes memory _bc = bytes(_c);
        bytes memory _bd = bytes(_d);
        bytes memory _be = bytes(_e);
        string memory abcde = new string(_ba.length + _bb.length + _bc.length + _bd.length + _be.length);
        bytes memory babcde = bytes(abcde);
        uint k = 0;
        for (uint i = 0; i < _ba.length; i++) babcde[k++] = _ba[i];
        for (uint i = 0; i < _bb.length; i++) babcde[k++] = _bb[i];
        for (uint i = 0; i < _bc.length; i++) babcde[k++] = _bc[i];
        for (uint i = 0; i < _bd.length; i++) babcde[k++] = _bd[i];
        for (uint i = 0; i < _be.length; i++) babcde[k++] = _be[i];
        return string(babcde);
    }

    function strConcat(string memory _a, string memory _b, string memory _c)
        internal
        pure
        returns (string memory)
    {
        return strConcat(_a, _b, _c, "", "");
    }
}