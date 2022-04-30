// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

/**
 * Migrated from https://github.com/brave-intl/basic-attention-token-crowdsale/blob/master/contracts/BAToken.sol
 * The original code was built using older solidity syntax that will fail today, @pingleware/contracts refactors
 * the code to have a successful build using the current solidity syntax
 */

import "../../common/Version.sol";
import "../../common/Frozen.sol";
import "../../common/Token.sol";
import "../../libs/SafeMath.sol";

contract BAToken is Version, Frozen, Token {
    uint256 public constant DECIMALS = 18;
    // contracts
    address public ethFundDeposit;      // deposit address for ETH
    address public batFundDeposit;      // deposit address for BAT User Fund

    // crowdsale parameters
    bool public isFinalized;              // switched to true in operational state
    uint256 public fundingStartBlock;
    uint256 public fundingEndBlock;
    uint256 public constant batFund = 500 * (10**6) * 10**DECIMALS;   // 500m BAT reserved
    uint256 public constant tokenExchangeRate = 6400; // 6400 BAT tokens per 1 ETH
    uint256 public constant tokenCreationCap =  1500 * (10**6) * 10**DECIMALS;
    uint256 public constant tokenCreationMin =  675 * (10**6) * 10**DECIMALS;


    // events
    event LogRefund(address indexed _to, uint256 _value);
    event CreateBAT(address indexed _to, uint256 _value);

    constructor(string memory _name,string memory _symbol)
        Token(_name,_symbol)
    {
        isFinalized = false;                   //controls pre through crowdsale state
    }

    function setETHFundsDepositWallet(address wallet)
        public
        okOwner
    {
        ethFundDeposit = wallet;
    }

    function setBATFundDepositWallet(address wallet)
        public
        okOwner
    {
        batFundDeposit = wallet;
    }

    function setFundingStartingBlock(uint256 blocknumber)
        public
        okOwner
    {
        fundingStartBlock = blocknumber;
    }


    function setFundingEndingBlock(uint256 blocknumber)
        public
        okOwner
    {
        fundingEndBlock = blocknumber;
    }

    function createBATFund()
        public
        payable
        okOwner
    {
        setTotalSupply(SafeMath.safeAdd(totalSupply(), batFund));
        payable(batFundDeposit).transfer(batFund);    // Deposit to fund
        emit CreateBAT(batFundDeposit, batFund);  // logs fund
    }

/// @dev Accepts ether and creates new BAT tokens.
    function createTokens() payable external {
      if (isFinalized) revert("not active");
      if (block.number < fundingStartBlock) revert("Block number manipulation attempt");
      if (block.number > fundingEndBlock) revert("Block number manipulation attempt");
      if (msg.value == 0) revert("empty request value");

      uint256 tokens = SafeMath.safeMul(msg.value, tokenExchangeRate); // check that we're not over totals
      uint256 checkedSupply = SafeMath.safeAdd(totalSupply(), tokens);

      // return money if something goes wrong
      if (tokenCreationCap < checkedSupply) revert("exceeding supply");  // odd fractions won't be found

      setTotalSupply(checkedSupply);
      payable(msg.sender).transfer(tokens);  // safeAdd not needed; bad semantics to use here
      emit CreateBAT(msg.sender, tokens);  // logs token creation
    }

    /// @dev Ends the funding period and sends the ETH home
    function finalize() external {
      if (isFinalized) revert("not active");
      if (msg.sender != ethFundDeposit) revert("cannot be the same account"); // locks finalize to the ultimate ETH owner
      if(totalSupply() < tokenCreationMin) revert("exceeds supply");      // have to sell minimum to move to operational
      if(block.number <= fundingEndBlock) revert("lock number manipulation attempt");
      if(totalSupply() != tokenCreationCap) revert("insufficient supply");
      // move to operational
      isFinalized = true;
      payable(ethFundDeposit).transfer(address(this).balance);
    }

    /// @dev Allows contributors to recover their ether in the case of a failed funding campaign.
    function refund() external {
      if(isFinalized) revert("not active");                       // prevents refund if operational
      if (block.number <= fundingEndBlock) revert("lock number manipulation attempt"); // prevents refund until sale period is over
      if(totalSupply() >= tokenCreationMin) revert("lock number manipulation attempt");  // no refunds if we sold enough
      if(msg.sender == batFundDeposit) revert("insufficient funds");
      uint256 batVal = balanceOf(msg.sender);
      if (batVal == 0) revert("insufficient funds");
      payable(address(this)).transfer(batVal);
      setTotalSupply(SafeMath.safeSub(totalSupply(), batVal)); // extra safe
      uint256 ethVal = batVal / tokenExchangeRate;     // should be safe; previous throws covers edges
      emit LogRefund(msg.sender, ethVal);               // log it

      payable(msg.sender).transfer(ethVal);
    }
}