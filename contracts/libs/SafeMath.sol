// SPDX-License-Identifier: BSL-1.1
pragma solidity >=0.4.22 <0.9.0;

library SafeMath {

    // SafeMath for int256
    function safeAdd(int256 a, int256 b) internal pure returns (int256) {
        int256 c;
        assembly {
            c := add(a, b)
            if iszero(eq(c, add(a, b))) {
                revert(0, 0)
            }
        }
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    
    function safeSub(int256 a, int256 b) internal pure returns (int256) {
        require(b <= a, "SafeMath: subtraction overflow");
        int256 c;
        assembly {
            c := sub(a, b)
            if iszero(eq(c, add(a, not(b)))) {
                revert(0, 0)
            }
        }        
        return c;
    }
    
    function safeMul(int256 a, int256 b) internal pure returns (int256) {
        if (a == 0) {
            return 0;
        }
        int256 c;
        assembly {
            c := mul(a, b)
            if or(iszero(b), iszero(eq(div(c, b), a))) {
                revert(0, 0)
            }
        }
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    
    function safeDiv(int256 a, int256 b) internal pure returns (int256) {
        require(b > 0, "SafeMath: division by zero");
        int256 c;
        assembly {
            if iszero(b) {
                revert(0, 0)
            }
            c := div(a, b)
        }
        return c;
    }

    function safePow(int256 base, int256 exponent) external pure returns (int256) {
        if (base == 0) {
            return 0;
        }
        if (exponent == 0) {
            return 1;
        }

        int256 result = 1;
        for (int256 i = 0; i < exponent; i++) {
            assembly {
                result := mul(result,base)
            }
        }

        return result;
    }

    // SafeMath for uint256 (unsigned integers)
    function safeAdd(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c;
        assembly {
            c := add(a, b)
            if iszero(eq(c, add(a, b))) {
                revert(0, 0)
            }
        }
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    
    function safeSub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c;
        assembly {
            c := sub(a, b)
            if iszero(eq(c, add(a, not(b)))) {
                revert(0, 0)
            }
        }
        return c;
    }
    
    function safeMul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c;
        assembly {
            c := mul(a, b)
            if or(iszero(b), iszero(eq(div(c, b), a))) {
                revert(0, 0)
            }
        }
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    
    function safeDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c;
        assembly {
            if iszero(b) {
                revert(0, 0)
            }
            c := div(a, b)
        }
        return c;
    }  

    function safePow(uint256 base, uint256 exponent) external pure returns (uint256) {
        if (base == 0) {
            return 0;
        }
        if (exponent == 0) {
            return 1;
        }

        uint256 result = 1;
        for (uint256 i = 0; i < exponent; i++) {
            assembly {
                result := mul(result,base)
            }
        }

        return result;
    }
}
