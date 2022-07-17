// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

library SafeMath32 {

    function mul(uint32 _a, uint32 _b) internal pure returns (uint32) {
        if (_a == 0) {
            return 0;
        }

        uint32 c = _a * _b;
        require(c / _a == _b);

        return c;
    }

    function div(uint32 _a, uint32 _b) internal pure returns (uint32) {
        require(_b > 0); // Solidity only automatically asserts when dividing by 0
        uint32 c = _a / _b;
        // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold

        return c;
    }

    function sub(uint32 _a, uint32 _b) internal pure returns (uint32) {
        require(_b <= _a);
        uint32 c = _a - _b;

        return c;
    }

    function add(uint32 _a, uint32 _b) internal pure returns (uint32) {
        uint32 c = _a + _b;
        require(c >= _a);

        return c;
    }

}