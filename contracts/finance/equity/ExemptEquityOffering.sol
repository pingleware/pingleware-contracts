// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;




import "../../Version.sol";
import "../../Owned.sol";
import "../Offering.sol";
import "../../Frozen.sol";
import "../../Account.sol";
import "../Shareholder.sol";
import "../Transaction.sol";
import "../TransferAgent.sol";

contract ExemptEquityOffering is Version, Owned, Offering, TransferAgent {

    mapping (address => uint256) public _balances;
    mapping (address => uint256) public _tokens;


    modifier notIPO(OfferingType _type) {
        require(_type != OfferingType.S1, "An IPO or public offering is NOT permitted for exempt offering!");
        _;
    }

    constructor(string memory name, string memory symbol, uint256 maxShares, OfferingType offeringType)
        notIPO(offeringType)
    {
        setOffering(address(this),name,symbol,maxShares,offeringType);
    }

    function getContractAddress()
        public
        view
        returns (address)
    {
        return address(this);
    }

    function mint(address account, uint256 amount, uint256 epoch, bytes32 encrypted, bytes memory signature)
        public
        payable
        onlyTransferAgent(encrypted,signature)
    {
        require(account != address(0), "cannot mint to the zero address");
        require(msg.sender.balance > amount, "insufficient balance");

        uint256 shares = amount / Shares.shareStorage().max_ppu[address(this)];
        require((shares + Shares.shareStorage().totalSupply[address(this)]) <= Shares.shareStorage().shares[address(this)],
                "exceeds maximum offering amount");

        payable(address(this)).transfer(amount);

        Shares.shareStorage().totalSupply[address(this)] += shares; // convert amount to debt tokens
        _balances[account] += amount;
        _tokens[account] += shares;

        Transaction.addTransaction(account,shares,amount,epoch);

        emit Transfer(account, amount);
        emit Minted(account, amount);
    }



}