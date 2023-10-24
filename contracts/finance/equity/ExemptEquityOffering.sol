// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;




import "../../common/Version.sol";
import "../../common/Frozen.sol";
import "../../common/Token.sol";
import "../../interfaces/IAccount.sol";
import "../../interfaces/IERC20.sol";
import "../../interfaces/IOfferingContract.sol";
import "../../interfaces/IShares.sol";
import "../../interfaces/IShareholder.sol";
import "../../interfaces/ITransaction.sol";
import "../../interfaces/ITransferAgent.sol";

contract ExemptEquityOffering is Version, Frozen {

    uint256 public tokenPrice; // 1 equity token (min $5 par value) for 0.00180870 ETH, 1808700 Gwei
    uint256 public _initial_supply;

    mapping (address => uint256) public _balances;
    mapping (address => Token) public _tokens;

    event Transfer(address sender, uint256 amount);
    event Minted(address sender, uint256 amount);
    event Bought(uint256 amount);
    event Sold(uint256 amount);



    modifier notDPO(IOfferingContract.OfferingType _type) {
        require(_type != IOfferingContract.OfferingType.S1, "A public offering is NOT permitted for exempt offering!");
        _;
    }

    IAccount Account;
    ITransferAgent TransferAgent;
    IShares Shares;
    // using a shared library containing the shareholders, will permit current shareholders to participate in future offerings
    // that is, accredited investors can participate in future exempt offerings, as well as non-accredited investors can participate
    // in future public offerings and certain exempt offerings?
    IShareholder Shareholder;
    ITransaction Transaction;
    IOfferingContract Offering;

    constructor(IOfferingContract.OfferingType offeringType,
                address account_contract, 
                address transferagent_contract, 
                address shares_contract,
                uint256 initial_supply)
        notDPO(offeringType)
    {
        _initial_supply = initial_supply;
        Account = IAccount(account_contract);
        TransferAgent = ITransferAgent(transferagent_contract);
        Shares = IShares(shares_contract);
    }

    function updateTokenPrice(uint256 updatePrice)
        public
    {
        tokenPrice = updatePrice;
    }

    function startOffering()
        public
        payable
        onlyOwner
    {
        start();
    }

    function stopOffering()
        public
        payable
        onlyOwner
    {
        stop();
    }

    function assignTransferAgent(address transferagent)
        public
        payable
        onlyOwner
    {
        TransferAgent.addTransferAgent(address(this), transferagent);
    }

    function initialize(string memory name, string memory symbol, uint256 maxShares, IOfferingContract.OfferingType offeringType)
        public
        notDPO(offeringType)
    {
        Offering.setOffering(address(this),name,symbol,maxShares,offeringType);
    }

    function mint(address account, uint256 amount, uint256 epoch)
        public
        payable
    {
        require(account != address(0), "cannot mint to the zero address");
        require(msg.sender.balance > amount, "insufficient balance");
        //require(TransferAgent.checkTransferAgent(address(this),nonce,signature),"unauthorized, not a valid transfer agent");

        uint256 shares = amount / Shares.getMaxPPU(address(this));
        require((shares + Shares.getTotalSupply(address(this))) <= Shares.getShares(address(this)),
                "exceeds maximum offering amount");

        payable(address(this)).transfer(amount);

        Shares.addTotalSupply(address(this), shares); // convert amount to debt tokens
        _balances[address(this)] += amount;
        _tokens[address(this)].setTotalSupply(shares);

        Transaction.addTransaction(account,shares,amount,epoch);

        emit Transfer(address(this), amount);
        emit Minted(address(this), amount);
    }

    function buy()
        public
        payable
        isRunning
    {
        uint256 amountTobuy = msg.value;
        uint256 dexBalance = _tokens[address(this)].totalSupply();
        require(amountTobuy > 0, "You need to send some ether");
        require(amountTobuy <= dexBalance, "Not enough tokens in the reserve");
        _tokens[address(this)].transfer(msg.sender, amountTobuy);
        emit Bought(amountTobuy);
    }

    function sell(uint256 amount)
        public
        payable
        isRunning
    {
        require(amount > 0, "You need to sell at least some tokens");
        uint256 allowance = _tokens[address(this)].allowance(msg.sender, address(this));
        require(allowance >= amount, "Check the token allowance");
        _tokens[address(this)].transferFrom(msg.sender, address(this), amount);

        payable(msg.sender).transfer(amount);
        emit Sold(amount);
    }
}