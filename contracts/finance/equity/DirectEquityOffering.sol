// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

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

import "../../libs/SafeMath.sol";
import "../../common/Version.sol";
import "../../common/Frozen.sol";
import "../../common/Token.sol";
import "../../interfaces/IERC20.sol";
import "../../interfaces/IOfferingContract.sol";
import "../../interfaces/ITransferAgent.sol";


contract DirectEquityOffering is Version, Frozen {

    // Price feeds from https://blog.chain.link/fetch-current-crypto-price-data-solidity/
    // Quote ETH to USD at https://min-api.cryptocompare.com/data/price?fsym=ETH&tsyms=USD, returns amount of USD for 1 ETH
    // https://api.kraken.com/0/public/Ticker?pair=ETHUSD
    /**
     * 2771.5 USD/ETH , 0.0003609 ETH/USD
     * USD -> ETH = $5 USD * 0.0003609 ETH/USD = 0.0018045 ETH, using https://min-api.cryptocompare.com/data/price?fsym=USD&tsyms=ETH
     */

    // 1 equity token (min $5 par value) for 0.00180870 ETH, 1808700 Gwei
    uint256 private tokenPrice;
    uint256 private upperLimit_7;
    uint256 private upperLimit_13;
    uint256 private upperLimit_20;
    uint256 public _initial_supply;


    mapping (address => uint256) public _balances;
    mapping (address => Token) public _tokens;

    event Bought(address sender, uint256 amount);
    event Sold(address sender, uint256 amount);
    event Swapping(address token,address sender, address receiver, uint256 amount);
    event Destroyed(address token, string reason);


    modifier onlyDPO(IOfferingContract.OfferingType _type) {
        require(_type == IOfferingContract.OfferingType.S1, "Exempt offerings are not permitted!");
        _;
    }

    ITransferAgent TransferAgent;
    IOfferingContract Offering;

    constructor(IOfferingContract.OfferingType _type,
                address offering_contract,
                address transferagent_contract,
                uint256 initial_supply,
                uint256 price,
                uint256 parValue)
        onlyDPO(_type)
    {
        require(price >= parValue,"Initial price cannot be less than par value?");
        _initial_supply = initial_supply;
        Offering = IOfferingContract(offering_contract);
        TransferAgent = ITransferAgent(transferagent_contract);

        tokenPrice = price;
        //upperLimit_7 =  price * (7 / 100);
        //upperLimit_13 = price * (13 / 100);
        //upperLimit_20 = price * (20 / 100);
    }

    function updateTokenPrice(uint256 updatePrice)
        public
        okOwner
    {
        tokenPrice = updatePrice;
    }

    function getTokenPrice()
        public
        view
        returns (uint256)
    {
        return tokenPrice;
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
        onlyDPO(offeringType)
    {
        //if (_tokens[address(this)] == 0) {
        //    _tokens[address(this)] = new Token();
        //}
        _tokens[address(this)].setTotalSupply(maxShares);
        Offering.setOffering(address(this),name,symbol,maxShares,offeringType);
    }

    // The transfer agent is responsible for minting the token for the investor
    function mint(address account, uint256 amount, uint256 epoch)
        public
        payable
        isRunning
    {
        require(account != address(0), "mint to the zero address");
        require(TransferAgent.checkTransferAgent(address(this)),"unauthroized, transfer agent is not valid");
        TransferAgent.mint(address(this), account, amount, epoch, _initial_supply);
    }

    function buy()
        public
        payable
        isRunning
    {
        uint256 amountTobuy = msg.value;
        require(amountTobuy > 0, "You need to send some ether");
        require(amountTobuy <= _tokens[address(this)].totalSupply(), "Not enough tokens in the reserve");
        //if (_tokens[msg.sender] != 0) {
        //    _tokens[msg.sender] = new Token();
        //}
        _tokens[address(this)].transfer(msg.sender, amountTobuy);
        emit Bought(msg.sender,amountTobuy);
    }

    function sell(uint256 amount)
        public
        payable
        isRunning
    {
        require(amount > 0, "You need to sell at least some tokens");
        uint256 allowance = _tokens[address(this)].allowance(msg.sender, address(this));
        require(allowance >= amount, "Check the token allowance");
        //if (_tokens[msg.sender] != 0) {
        //    _tokens[msg.sender] = new Token();
        //}
        _tokens[address(this)].transferFrom(msg.sender, address(this), amount);
        payable(msg.sender).transfer(amount);
        emit Sold(msg.sender,amount);
    }



    // Once an investor holds a token, they can freely swap it with another investor on the open market
    // The receiving investor will need to be added to the stockholder list and when the sending investor
    // no longer holds any tokens, they are not removed from the shareholder list
    //
    //this function will allow 2 people to trade 2 tokens as the same time (atomic) and swap them between accounts
    //Bob holds token 1 and needs to send to alice
    //Alice holds token 2 and needs to send to Bob
    //this allows them to swap an amount of both tokens at the same time
    //
    //*** Important ***
    //this contract needs an allowance to send tokens at token 1 and token 2 that is owned by owner 1 and owner 2
    //
    // See https://ethereum.org/en/developers/tutorials/transfers-and-approval-of-erc-20-tokens-from-a-solidity-smart-contract/
    function swap(address investor2, IERC20 token1, uint _amount1, IERC20 token2, uint _amount2)
        public
        payable
        isRunning
    {

            address investor1 = msg.sender;
            // TODO: check is investor1 and investor2 are shareholders?
            //require(msg.sender == investor1 || msg.sender == TransferAgent.getTransferAgent(address(this)), "Not authorized");
            require(token1.allowance(investor1, address(this)) >= _amount1, "Token 1 allowance too low");
            require(token2.allowance(investor2, address(this)) >= _amount2, "Token 2 allowance too low");

            //transfer TokenSwap
            //token1, owner1, amount 1 -> owner2.  needs to be in same order as function
            _safeTransferFrom(token1, investor1, investor2, _amount1);
            //token2, owner2, amount 2 -> owner1.  needs to be in same order as function
            _safeTransferFrom(token2, investor2, investor1, _amount2);
            emit Swapping(address(token1),investor1,investor2,_amount1);
    }

    //This is a private function that the function above is going to call
    //the result of this transaction(bool) is assigned in a variable called sent
    //then we require the transfer to be successful
    function _safeTransferFrom(IERC20 token, address sender, address recipient, uint amount)
        private
    {
        bool sent = token.transferFrom(sender, recipient, amount);
        require(sent, "Token transfer failed");
    }
}