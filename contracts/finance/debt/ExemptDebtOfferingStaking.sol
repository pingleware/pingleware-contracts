// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

import "../../common/Version.sol";
import "../../common/Owned.sol";
import "../../interfaces/TransactionInterface.sol";

/**
 * Mechanics of a Private Placement Debt Offering
 * ----------------------------------------------
 * Using a DAPP to qualify an accredited investor, and accept monetary investment, then mint an equal token amount for the investor.
 * Using the staking algorithm, to create reward tokens equal to interest payments
 */

contract ExemptDebtOfferingStaking is Version, Owned {
    string public constant name = "DEBT TOKEN";
    string public constant symbol = "DEBT.TOKEN";
    string public constant CUSIP = "";
    string public constant ISIN = "";

    uint256 public constant minimumInvestment = 1000;
    uint256 public constant maximumOffering = 5000000;

    uint256 public _availableTokens;
    uint256 public _totalSupply;
    uint    public interest; // 100=1%,300=3%
    uint256 public _totalInvested;

    mapping (address => uint256) public _balances;
    mapping (address => uint256) public _tokens;

    uint256 public constant interest_payment_interval = 30 days; // 30 days = 2592000 seconds

    /**
     * @notice We usually require to know who are all the stakeholders.
     */
    address[] internal stakeholders;

    /**
    * @notice The stakes for each stakeholder.
    */
    mapping(address => uint256) internal stakes;
    /**
    * @notice The accumulated rewards for each stakeholder.
    */
    mapping(address => uint256) internal rewards;

    event Transfer(address receiver,address account,uint256 amount);
    event Minted(address account,uint256 amount);

    TransactionInterface Transaction;

    constructor(address transaction_contract, uint _interest, uint256 _initial_supply)
    {

        _availableTokens = maximumOffering / minimumInvestment;
        interest = _interest;
        _totalSupply = _initial_supply;
        _totalInvested = 0;

        Transaction = TransactionInterface(transaction_contract);
    }

    modifier isMinimumInvestment() {
        require(msg.value >= minimumInvestment,"does not meet the minimum investment");
        _;
    }

    modifier isEnoughAvailable() {
        require((msg.value / minimumInvestment) > _availableTokens,"not enough available tokens, lower your investment");
        _;
    }

    modifier isSufficientBalance() {
        require(msg.value < _totalSupply,"Exceeds total supply");
        require((_totalSupply - msg.value) >= 0, "Exceeds total supply");
        _;
    }

    modifier isValidStakeholder() {
        (bool _isStakeholder, ) = isStakeholder(msg.sender);
        require(_isStakeholder, "not a stakeholder");
        _;
    }

    modifier noStakes() {
        require(stakes[msg.sender] == 0,"has stakes");
        _;
    }

    modifier isStakes() {
        require(stakes[msg.sender] > 0,"no stakes");
        _;
    }
    // ensure the interest payment dureation has lapsed?
    modifier isInterestPaymentInterval(uint256 epoch) {
        require(epoch >= interest_payment_interval,"interest payment is too soon");
        _;
    }

    modifier isExceededMaximumOffering() {
        require((_totalInvested + msg.value) < maximumOffering,"maximum offering has been reached");
        _;
    }

    function getTotalOffering()
        public
        view
        returns (uint256)
    {
        return _totalSupply * minimumInvestment;
    }

    /**
     * Minitng is used to take an investor funds, transfer to the contract address and issue an equivalent in debt tokens
     */
    function _mint(address account, uint256 amount, uint256 epoch)
        internal
    {
        require(account != address(0), "mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount / minimumInvestment; // convert amount to debt tokens
        _balances[account] += amount;

        // add transaction: wallet, debt token qty, ether invested, timestamp
        Transaction.addTransaction(account,(amount / minimumInvestment),amount,epoch);

        emit Transfer(address(this), account, amount);
        emit Minted(account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount,uint256 epoch)
        internal
    {
        require(account != address(0), "burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalInvested += amount;
        _totalSupply -= amount / minimumInvestment; // convert to debt token
        _tokens[account] += amount / minimumInvestment;
        // add transaction: wallet, debt token qty, ether invested, timestamp
        Transaction.addTransaction(account,(amount / minimumInvestment),amount,epoch);

        emit Transfer(account, address(this), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
    * @notice A method to check if an address is a stakeholder.
    * @param _address The address to verify.
    * @return bool, uint256 Whether the address is a stakeholder,
    * and if so its position in the stakeholders array.
    */
   function isStakeholder(address _address)
       public
       view
       returns(bool, uint256)
   {
       for (uint256 s = 0; s < stakeholders.length; s += 1){
           if (_address == stakeholders[s]) return (true, s);
       }
       return (false, 0);
   }
   /**
    * @notice A method to add a stakeholder.
    * @param _stakeholder The stakeholder to add.
    */
   function addStakeholder(address _stakeholder, bytes32 encrypted, bytes memory signature)
       public
       onlyOwner(encrypted,signature)
       noStakes
   {
       (bool _isStakeholder, ) = isStakeholder(_stakeholder);
       if(!_isStakeholder) stakeholders.push(_stakeholder);
   }
   /**
    * @notice A method to remove a stakeholder.
    * @param _stakeholder The stakeholder to remove.
    */
   function removeStakeholder(address _stakeholder, bytes32 encrypted, bytes memory signature)
       public
       onlyOwner(encrypted,signature)
   {
       (bool _isStakeholder, uint256 s) = isStakeholder(_stakeholder);
       if(_isStakeholder){
           stakeholders[s] = stakeholders[stakeholders.length - 1];
           stakeholders.pop();
       }
   }

    function getStakeholders()
        public view
        returns(address[] memory)
    {
        return stakeholders;
    }

    function getStakeholderCount()
        public
        view
        returns(uint256)
    {
        return stakeholders.length;
    }

    /**
    * @notice A method to retrieve the stake for a stakeholder.
    * @param _stakeholder The stakeholder to retrieve the stake for.
    * @return uint256 The amount of wei staked.
    */
   function stakeOf(address _stakeholder)
       public
       view
       returns(uint256)
   {
       return stakes[_stakeholder];
   }
   /**
    * @notice A method to the aggregated stakes from all stakeholders.
    * @return uint256 The aggregated stakes from all stakeholders.
    */
   function totalStakes()
       public
       view
       returns(uint256)
   {
       uint256 _totalStakes = 0;
       for (uint256 s = 0; s < stakeholders.length; s += 1){
           _totalStakes = _totalStakes + stakes[stakeholders[s]];
       }
       return _totalStakes;
   }

    /**
    * @notice A method for a stakeholder to create a stake. This when an investor will invest in the debt offering
    * @param epoch The timestamp
    */
   function createStake(uint256 epoch)
       public
       payable
       isMinimumInvestment
       isExceededMaximumOffering
       isValidStakeholder
       noStakes
   {
       _burn(msg.sender, msg.value, epoch);
       stakes[msg.sender] = stakes[msg.sender] + msg.value;
   }
   /**
    * @notice A method for a stakeholder to remove a stake.
    * @param epoch The timestamp
    */
   function removeStake(uint256 epoch)
       public
       payable
       isValidStakeholder
       isStakes
   {
       stakes[msg.sender] = stakes[msg.sender] - msg.value;
       _mint(msg.sender, msg.value, epoch);
   }

  
   /**
    * @notice A method to allow a stakeholder to check his rewards.
    * @param _stakeholder The stakeholder to check rewards for.
    */
   function rewardOf(address _stakeholder)
       public
       view
       returns(uint256)
   {
       return rewards[_stakeholder];
   }
   /**
    * @notice A method to the aggregated rewards from all stakeholders.
    * @return uint256 The aggregated rewards from all stakeholders.
    */
   function totalRewards()
       public
       view
       returns(uint256)
   {
       uint256 _totalRewards = 0;
       for (uint256 s = 0; s < stakeholders.length; s += 1){
           _totalRewards = _totalRewards + rewards[stakeholders[s]];
       }
       return _totalRewards;
   }

   /**
    * Calculates the interest earned on a debt offering and kept in rewards variable
    * @notice A simple method that calculates the rewards for each stakeholder.
    * @param _stakeholder The stakeholder to calculate rewards for.
    * @param epoch The timestamp of the trasnaction
    * @param encrypted Owner signed package for proper authenrication
    * @param signature Owner signature
    */
   function calculateReward(address _stakeholder, uint256 epoch, bytes32 encrypted, bytes memory signature)
       public
       onlyOwner(encrypted, signature)
       isInterestPaymentInterval(epoch)
       returns(uint256)
   {
       return stakes[_stakeholder] / interest;
   }
   /**
    * Distributes interest in tokens to the stakeholder
    * @notice A method to distribute rewards to all stakeholders.
    * @param epoch The timestamp of the trasnaction
    * @param encrypted Owner signed package for proper authenrication
    * @param signature Owner signature
    */
   function distributeRewards(uint256 epoch, bytes32 encrypted, bytes memory signature)
       public
       onlyOwner(encrypted, signature)
   {
       for (uint256 s = 0; s < stakeholders.length; s += 1){
           address stakeholder = stakeholders[s];
           uint256 reward = calculateReward(stakeholder,epoch,encrypted,signature);
           uint256 earned = rewards[stakeholder] + reward;
           rewards[stakeholder] = earned;
           Transaction.addTransaction(stakeholder,earned,earned,epoch);
       }
   }
   /**
    * @notice A method to allow a stakeholder to withdraw his rewards.
    * @param epoch The timestamp of the trasnaction
    */
   function withdrawReward(uint256 epoch)
       public
       isValidStakeholder
   {
       uint256 reward = rewards[msg.sender];
       rewards[msg.sender] = 0;
       _mint(msg.sender, reward, epoch);
   }

    /**
     * This is the same as withdrawing the investment
     * @param epoch The timestamp of the trasnaction
     * 
     */
    function withdrawTokens(uint256 epoch)
        public
        isValidStakeholder
    {
        // withdraw any reward remaining?
        withdrawReward(epoch);
        // ensure there are still tokens available? 
        require(_tokens[msg.sender] > 0,"no tokens available");
        uint256 tokens = _tokens[msg.sender];
        _tokens[msg.sender] = 0;
        // ensure contract has enough funds to pay out?
        uint256 accountBalance = _balances[msg.sender];
        require(accountBalance < address(this).balance,"insufficient contract balance");
        // ensure the requestor has a balance?
        require(_balances[msg.sender] > 0,"insufficient account balance");
        _balances[msg.sender] = 0;
        // send the account balance to the requestor
        payable(msg.sender).transfer(accountBalance);
        // update total invested
        _totalInvested -= accountBalance;
        // record a transaction
        Transaction.addTransaction(msg.sender,tokens,accountBalance,epoch);
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal {}

}