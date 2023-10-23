// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

/**
 * ERC-884
 */

import "../../libs/SafeMath.sol";
import "../../common/IdentityRegistry.sol";
//import "../../common/Token.sol";
import "../../interfaces/IERC20TOKEN.sol";
import "../../common/Whitelistable.sol";

contract DelawareStockToken is IERC20TOKEN, Whitelistable {
    string public symbol;
    string public name;
    string public byLawsHash;
    uint public decimals;
    bool public isPrivateCompany = true;
    
    uint256  _totalSupply;

    mapping(address => uint) tokenOwnersIndex;
    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    address[] public tokenOwners;
    
    IdentityRegistry public platformWhitelist;

    event ChangedCompanyStatus(address authorizedBy, bool newStatus);

    constructor(string memory _symbol, string memory _name, uint _supply, string memory _hash, address payable _registry)
        Whitelistable()
    {
        symbol = _symbol;
        name = _name;
        _totalSupply = _supply;
        byLawsHash = _hash;
        balances[msg.sender] = _supply;
        platformWhitelist = IdentityRegistry(_registry);
        tokenOwners.push(address(0));
        tokenOwners.push(msg.sender);
        uint index = tokenOwners.length;
        tokenOwnersIndex[msg.sender] = index - 1;

    }

    modifier onlyIfWhitelisted(address _address) { // modifier to restrict access only to whitelisted accounts
        require(platformWhitelist.isWhitelisted(_address));
        if(isPrivateCompany){
            require(isWhitelisted(_address), "Address not in private shareholders whitelist");
        }
        _;
    }

    function balanceOf(address tokenOwner) override public view returns (uint) {
        return balances[tokenOwner];
    }

    function transfer(address _to, uint256 _value) onlyIfWhitelisted(_to) public virtual override returns (bool){
        uint index = 0;
        if(tokenOwnersIndex[_to] == 0) {
            tokenOwners.push(_to);
            index = tokenOwners.length - 1;
            tokenOwnersIndex[_to] = index;
        }
        _transfer(msg.sender, _to, _value);
        if(balanceOf(msg.sender) == 0){
            removeTokenOwner(msg.sender);
        }
        return true;
    }

    function togglePrivateCompany() okOwner() public {
        isPrivateCompany = !isPrivateCompany;
        emit ChangedCompanyStatus(msg.sender, isPrivateCompany);
    }

    // Return the number of shareholders in the company
    function ownersCount() public view returns(uint){
        return tokenOwners.length - 1;
    }
    
    // Return an array with all the token owners
    function getTokenOwners() public view returns(address[] memory){
        return tokenOwners;
    }

    // Removes entry from array at index and resizes the array appropriatly
    function removeFromTokenOwnersArray(uint index) internal {
        address lastElement = tokenOwners[tokenOwners.length - 1];
        tokenOwners[index] = lastElement;
        delete tokenOwners[tokenOwners.length - 1];
    }
    function totalSupply() virtual public override view returns (uint) {
        return _totalSupply;
    }
    function setTotalSupply(uint256 amount) public {
        _totalSupply = amount;
    }

    // Removes a token owner from the list of shareholders
    function removeTokenOwner(address holder) internal {
        uint i = tokenOwnersIndex[holder];
        removeFromTokenOwnersArray(i);
        tokenOwnersIndex[holder] = 0;
    }
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = msg.sender;
        _approve(owner, spender, amount);
        return true;
    }
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = msg.sender;
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = msg.sender;
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = msg.sender;
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            balances[from] = fromBalance - amount;
        }
        balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

}