// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;




import "../../Version.sol";
import "../../Owned.sol";
import "../Offering.sol";
import "../../Frozen.sol";
import "../../Account.sol";
import "../Shares.sol";
import "../Shareholder.sol";
import "../Transaction.sol";
import "../TransferAgent.sol";

/**
 * S-1 Offering:
 * Corporate Finance Reporting Manual at https://www.sec.gov/page/corpfin-section-landing
 *
 * Useful for an issuer who wishes to conduct a Direct Public Offering or DPO on the blockchain after their S-1 has been quallified.
 * The filing fee for an S-1 is at https://www.sec.gov/ofm/Article/feeamt.html
 * Currently is $92.70 per $1,000,000
 * If you have a PAR value of $5 per share, then the minimum authorized shares would be 200,000 shares.
 * Liquidity is most important in a public offering!
 */

contract DirectEquityOffering is Version, Owned, Offering, TransferAgent {

    mapping (address => uint256) public _balances;
    mapping (address => uint256) public _tokens;

    modifier onlyIPO(OfferingType _type) {
        require(_type == OfferingType.S1, "Exempt offerings are not permitted!");
        _;
    }

    constructor(string memory name, string memory symbol, uint256 maxShares, OfferingType offeringType)
        onlyIPO(offeringType)
    {
        setOffering(address(this),name,symbol,maxShares,offeringType);
    }

    function mint(address account, uint256 amount, uint256 epoch, bytes32 encrypted, bytes memory signature)
        public
        payable
        onlyTransferAgent(encrypted,signature)
    {
        require(account != address(0), "mint to the zero address");

        uint256 shares = amount / Shares.shareStorage().max_ppu[address(this)];
        require((shares + Shares.shareStorage().totalSupply[address(this)]) <= Shares.shareStorage().shares[address(this)],
                "exceeds maximum offering amount");


        Shares.shareStorage().totalSupply[address(this)] += shares; // convert amount to debt tokens
        _balances[account] += amount;
        _tokens[account] += shares;
        payable(account).transfer(amount);

        Transaction.addTransaction(account,shares,amount,epoch);

        emit Transfer(account, amount);
        emit Minted(account, amount);
    }
}