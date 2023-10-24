// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

/**
 * Refactored from https://github.com/stefanionescu/Smart-Bond
 */

import "../../common/Version.sol";
import "../../common/Frozen.sol";
import "../../libs/SafeMath.sol";
import "../../common/Token.sol";
import "../../interfaces/ISimpleBond.sol";
import "../../interfaces/IToken.sol";

contract SimpleBond is ISimpleBond, Version, Frozen {

   using SafeMath for uint256;
   string name;
   address tokenToRedeem;
   uint256 totalDebt;
   uint256 parDecimals;
   uint256 bondsNumber;
   uint256 cap;
   uint256 parValue;
   uint256 couponRate;
   uint256 term;
   uint256 timesToRedeem;
   uint256 loopLimit;
   uint256 nonce = 0;
   uint256 couponThreshold = 0;

   IToken token;

   mapping(uint256 => address) bonds;
   mapping(uint256 => uint256) maturities;
   mapping(uint256 => uint256) couponsRedeemed;
   mapping(address => uint256) bondsAmount;

   constructor(string memory _name, 
               uint256 _par, 
               uint256 _parDecimals, 
               uint256 _coupon,
               uint256 _term, 
               uint256 _cap, 
               uint256 _timesToRedeem, 
               address _tokenToRedeem,
               uint256 _loopLimit) {
        require(bytes(_name).length > 0,"name for bond cannot be empty");
        require(_coupon > 0,"coupon must be greater than zero");
        require(_par > 0,"par must be greater than zero");
        require(_term > 0,"term must be greater than zero");
        require(_loopLimit > 0,"loop limit must be greater than zero");
        require(_timesToRedeem >= 1,"redemption time  must be greater than one");

        name = _name;
        parValue = _par;
        cap = _cap;
        loopLimit = _loopLimit;
        parDecimals = _parDecimals;
        timesToRedeem = _timesToRedeem;
        couponRate = _coupon;
        term = _term;
        couponThreshold = SafeMath.safeDiv(term,timesToRedeem);

        if (_tokenToRedeem == address(0)) {
            tokenToRedeem = _tokenToRedeem;
        } else {
            // Bond token name and symbol are the same
            token = IToken(_tokenToRedeem);
        }
    }

    /**
    * @notice Change the number of elements you can loop through in this contract
    * @param _loopLimit The new loop limit
    */

    function changeLoopLimit(uint256 _loopLimit) public override okOwner {
        require(_loopLimit > 0,"loop limit must be greater than zero");
        loopLimit = _loopLimit;
    }

    /**
    * @notice Mint bonds to a new buyer
    * @param buyer The buyer of the bonds
    * @param _bondsAmount How many bonds to mint
    */
    function mintBond(address buyer, uint256 _bondsAmount) public override okOwner {
        require(buyer != address(0),"unauthorized buyer");
        require(_bondsAmount >= 1,"bond amount cannot be zero");
        require(_bondsAmount <= loopLimit,"bond amount cannot exceed loop limit");

        if (cap > 0) {
            require(SafeMath.safeAdd(bondsNumber,_bondsAmount) <= cap,"minting will exceed capacity");
        }

        bondsNumber = SafeMath.safeAdd(bondsNumber,_bondsAmount);

        nonce = SafeMath.safeAdd(nonce,_bondsAmount);

        for (uint256 i = 0; i < _bondsAmount; i++) {
            maturities[SafeMath.safeSub(nonce,i)] = SafeMath.safeAdd(block.timestamp,term);
            bonds[SafeMath.safeSub(nonce,i)] = buyer;
            couponsRedeemed[SafeMath.safeSub(nonce,i)] = 0;
            bondsAmount[buyer] = SafeMath.safeAdd(bondsAmount[buyer],_bondsAmount);
        }

        totalDebt = SafeMath.safeAdd(SafeMath.safeMul(SafeMath.safeAdd(totalDebt,parValue),_bondsAmount),(SafeMath.safeMul(SafeMath.safeMul(SafeMath.safeMul(parValue,(SafeMath.safeDiv(couponRate,100))),timesToRedeem),_bondsAmount)));

        emit MintedBond(buyer, _bondsAmount);
    }

    /**
    * @notice Redeem coupons on your bonds
    * @param _bonds An array of bond ids corresponding to the bonds you want to redeem apon
    */
    function redeemCoupons(uint256[] calldata _bonds) public override {
        require(_bonds.length > 0,"");
        require(_bonds.length <= loopLimit,"");
        require(_bonds.length <= getBalance(msg.sender),"");

        uint256 issueDate = 0;
        uint256 lastThresholdRedeemed = 0;
        uint256 toRedeem = 0;

        for (uint256 i = 0; i < _bonds.length; i++) {
            if (bonds[_bonds[i]] != msg.sender
                || couponsRedeemed[_bonds[i]] == timesToRedeem) continue;

            issueDate = SafeMath.safeSub(maturities[_bonds[i]],term);
            lastThresholdRedeemed = SafeMath.safeMul(SafeMath.safeAdd(issueDate,couponsRedeemed[_bonds[i]]),couponThreshold);

            if (SafeMath.safeAdd(lastThresholdRedeemed,couponThreshold) >= maturities[_bonds[i]] ||
                block.timestamp < SafeMath.safeAdd(lastThresholdRedeemed,couponThreshold)) continue;

            toRedeem = SafeMath.safeDiv(SafeMath.safeSub(block.timestamp,lastThresholdRedeemed),couponThreshold);

            if (toRedeem == 0) continue;

            couponsRedeemed[_bonds[i]] = SafeMath.safeAdd(couponsRedeemed[_bonds[i]],toRedeem);

            getMoney(SafeMath.safeMul(toRedeem,(SafeMath.safeDiv(SafeMath.safeMul(parValue,couponRate),(10 ** (SafeMath.safeAdd(parDecimals,2)))))), msg.sender);

            if (couponsRedeemed[_bonds[i]] == timesToRedeem) {
                bonds[_bonds[i]] = address(0);
                maturities[_bonds[i]] = 0;
                bondsAmount[msg.sender]--;

                getMoney(SafeMath.safeDiv(parValue,(10 ** parDecimals)), msg.sender);
            }
        }

        emit RedeemedCoupons(msg.sender, _bonds);
    }

    /**
    * @notice Transfer bonds to another address
    * @param receiver The receiver of the bonds
    * @param _bonds The ids of the bonds that you want to transfer
    */

    function transfer(address receiver, uint256[] calldata _bonds) public override {

        require(_bonds.length > 0,"");
        require(receiver != address(0),"");
        require(_bonds.length <= getBalance(msg.sender),"");

        for (uint256 i = 0; i < _bonds.length; i++) {
            if (bonds[_bonds[i]] != msg.sender
                || couponsRedeemed[_bonds[i]] == timesToRedeem) continue;

            bonds[_bonds[i]] = receiver;
            bondsAmount[msg.sender] = SafeMath.safeSub(bondsAmount[msg.sender],1);
            bondsAmount[receiver] = SafeMath.safeAdd(bondsAmount[receiver],1);

        }

        emit Transferred(msg.sender, receiver, _bonds);
    }

    /**
    * @notice Donate money to this contract
    */

    function donate() public override payable {
        require(address(token) == address(0),"undefined contract address");
    }

    //PRIVATE

    /**
    * @notice Transfer coupon money to an address
    * @param amount The amount of money to be transferred
    * @param receiver The address which will receive the money
    */

    function getMoney(uint256 amount, address receiver) public override {
        if (address(token) == address(0)) {
            payable(receiver).transfer(amount);
        } else {
            token.transfer(msg.sender, amount);
        }

        totalDebt = SafeMath.safeSub(totalDebt,amount);
   }

    //GETTERS

    /**
    * @dev Get the last time coupons for a particular bond were redeemed
    * @param bond The bond id to analyze
    */

    function getLastTimeRedeemed(uint256 bond) public override view returns (uint256) {
        uint256 issueDate = SafeMath.safeSub(maturities[bond],term);
        uint256 lastThresholdRedeemed = SafeMath.safeAdd(issueDate,SafeMath.safeMul(couponsRedeemed[bond],couponThreshold));
        return lastThresholdRedeemed;
    }

    /**
    * @dev Get the owner of a specific bond
    * @param bond The bond id to analyze
    */

    function getBondOwner(uint256 bond) public override view returns (address) {
        return bonds[bond];
    }

    /**
    * @dev Get how many coupons remain to be redeemed for a specific bond
    * @param bond The bond id to analyze
    */

    function getRemainingCoupons(uint256 bond) public override view returns (int256) {
        address owner = getBondOwner(bond);
        if (owner == address(0)) return -1;
        uint256 redeemed = getCouponsRedeemed(bond);
        return int256(timesToRedeem - redeemed);
    }

   /**
   * @dev Get how many coupons were redeemed for a specific bond
   * @param bond The bond id to analyze
   */

   function getCouponsRedeemed(uint256 bond) public override view returns (uint256) {
     return couponsRedeemed[bond];
   }

   /**
   * @dev Get the address of the token that is redeemed for coupons
   */

    function getTokenAddress() public override view returns (address) {
        return (address(token));
    }

    /**
    * @dev Get how many times coupons can be redeemed for bonds
    */

    function getTimesToRedeem() public override view returns (uint256) {
        return timesToRedeem;
    }

    /**
    * @dev Get how much time it takes for a bond to mature
    */

    function getTerm() public override view returns (uint256) {
        return term;
    }

    /**
    * @dev Get the maturity date for a specific bond
    * @param bond The bond id to analyze
    */

    function getMaturity(uint256 bond) public override view returns (uint256) {
        return maturities[bond];
    }

    /**
    * @dev Get how much money is redeemed on a coupon
    */

    function getSimpleInterest() public override view returns (uint256) {
        uint256 rate = getCouponRate();
        uint256 par = getParValue();
        return SafeMath.safeDiv(SafeMath.safeMul(par,rate),100);
    }

    /**
    * @dev Get the yield of a bond
    */

    function getCouponRate() public override view returns (uint256) {
        return couponRate;
    }

    /**
    * @dev Get the par value for these bonds
    */

    function getParValue() public override view returns (uint256) {
        return parValue;
    }

    /**
    * @dev Get the cap amount for these bonds
    */

    function getCap() public override view returns (uint256) {
        return cap;
    }

    /**
    * @dev Get amount of bonds that an address has
    * @param who The address to analyze
    */

    function getBalance(address who) public override view returns (uint256) {
        return bondsAmount[who];
    }

    /**
    * @dev If the par value is a real number, it might have decimals. Get the amount of decimals the par value has
    */

    function getParDecimals() public override view returns (uint256) {
        return parDecimals;
    }

    /**
    * @dev Get the address of the token redeemed for coupons
    */

    function getTokenToRedeem() public override view returns (address) {
        return tokenToRedeem;
    }

    /**
    * @dev Get the name of this smart bond contract
    */

    function getName() public override view returns (string memory) {
        return name;
    }

    /**
    * @dev Get the current unpaid debt
    */

    function getTotalDebt() public override view returns (uint256) {
        return totalDebt;
    }

    /**
    * @dev Get the total amount of bonds issued
    */

    function getTotalBonds() public override view returns (uint256) {
        return bondsNumber;
    }

    /**
    * @dev Get the latest nonce
    */

    function getNonce() public override view returns (uint256) {
        return nonce;
    }

    /**
    * @dev Get the amount of time that needs to pass between the dates when you can redeem coupons
    */

    function getCouponThreshold() public override view returns (uint256) {
        return couponThreshold;
    }
}