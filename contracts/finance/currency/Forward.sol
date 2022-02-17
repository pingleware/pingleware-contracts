// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

/**
 * A currency forward is a binding contract in the foreign exchange market that locks in the exchange rate for the purchase or sale of a currency on a future date.
 * A currency forward is essentially a customizable hedging tool that does not involve an upfront margin payment. The other major benefit of a currency forward is
 * that its terms are not standardized and can be tailored to a particular amount and for any maturity or delivery period, unlike exchange-traded currency futures.
 *
 * https://github.com/alanwhite1203/fxForward
 */

// Forward Currency Rates at https://www.fxempire.com/currencies/eur-usd/forward-rates

/**
 * Calculation of the FX Forward Rate involves querying the related central bank interest rate and the spot rate for the ccy pair
 *
 * Central Bank Interest Rates at https://www.global-rates.com/en/interest-rates/central-banks/central-banks.aspx
 * 
 */


contract Forward {

    uint256 public constant DAY             = 60*60*24;
    uint256 public constant WEEK            = 60*60*24*7;
    uint256 public constant MONTH           = 60*60*24*30;
    uint256 public constant YEAR            = 60*60*24*30*12;

    uint256 public constant NEXT_DAY        = DAY;
    uint256 public constant ONE_WEEK        = WEEK;
    uint256 public constant TWO_WEEKS       = 2 * WEEK;
    uint256 public constant THREE_WEEKS     = 3 * WEEK;
    uint256 public constant ONE_MONTH       = MONTH;
    uint256 public constant TWO_MONTHS      = 2 * MONTH;
    uint256 public constant THREE_MONTHS    = 3 * MONTH;
    uint256 public constant FOUR_MONTHS     = 4 * MONTH;
    uint256 public constant FIVE_MONTHS     = 5 * MONTH;
    uint256 public constant SIX_MONTHS      = 6 * MONTH;
    uint256 public constant SEVEN_MONTHS    = 7 * MONTH;
    uint256 public constant EIGHT_MONTHS    = 8 * MONTH;
    uint256 public constant NINE_MONTHS     = 9 * MONTH;
    uint256 public constant TEN_MONTHS      = 10 * MONTH;
    uint256 public constant ELEVEN_MONTHS   = 11 * MONTH;
    uint256 public constant ONE_YEAR        = YEAR;
    uint256 public constant TWO_YEARS       = 2 * YEAR;
    uint256 public constant THREE_YEARS     = 3 * YEAR;
    uint256 public constant FOUR_YEARS      = 4 * YEAR;
    uint256 public constant FIVE_YEARS      = 5 * YEAR;
    uint256 public constant SIX_YEARS       = 6 * YEAR;
    uint256 public constant SEVEN_YEARS     = 7 * YEAR;
    uint256 public constant TEN_YEARS       = 10 * YEAR;

    struct ForwardToken {
        string   ccypair;
        uint256  lots;
        uint256  maturity;
        uint256  rate;
    }

    struct ForwardRates {
        uint256  Points;     // -0.33,
        uint256  SpotRate;   // 1.357105,
        uint256  Ask;        // 1.357118,
        uint256  Mid;        // 1.357072,
        uint256  Bid;        // 1.357026,
        uint256  Expiration; // "Overnight"        
    }

    struct InterestRate {
         string     name;
         string	    country;
         string     symbol;
         uint256    current_rate;
         uint256    previous_rate;
         string	    change;
    }


    mapping (address => ForwardToken) public tokens;
    ForwardRates[] fwdrates;
    InterestRate[] public interestRates;

    bool private inWithdrawal = false;

    event ForwardTokenMinted(address investor, string ccypair, uint256 lots, uint256 maturity, ForwardToken token);
    event Withdrawal(address investor, uint256 amount);
    event Deposit(address wallet, uint256 amount);
    event FallbackEvent(address sender, uint256 amount);
    event ReceiveEvent(address sender, uint256 amount);
    
    constructor()
    {
        /*
        ForwardRates memory forwardRates = ForwardRates(-0.33, 1.357105, 1.357118, 1.357072, 1.357026, "Overnight");
        fwdrates.append(forwardRates);

        InterestRate memory interestRate = InterestRate("American", "United States", "USD", 0.250, 1.250, "03-15-2020");
        interestRates.append(interestRate);
        interestRate = InterestRate("Australian", "Australia", "AUD", 0.100, 0.250, "11-03-2020");
        interestRates.append(interestRate);
        interestRate = InterestRate("Banco Central", "Chile", "", 5.500, 4.000, "01-26-2022");
        interestRates.append(interestRate);
        interestRate = InterestRate("Bank of Korea", "South Korea", "", 1.250, 1.000, "01-14-2022");
        interestRates.append(interestRate);
        interestRate = InterestRate("Brazilian", "Brazil", "", 10.750, 9.250, "02-02-2022");
        interestRates.append(interestRate);
        interestRate = InterestRate("British", "Great Britain", "GBP", 0.500, 0.250, "02-03-2022");
        interestRates.append(interestRate);
        interestRate = InterestRate("Canadian", "Canada", "CAD", 0.250, 0.750, "03-27-2020");
        interestRates.append(interestRate);
        interestRate = InterestRate("Chinese", "China", "", 3.700, 3.800, "01-20-2022");
        interestRates.append(interestRate);
        interestRate = InterestRate("Czech", "Czech Republic", "", 4.500, 3.750, "02-03-2022");
        interestRates.append(interestRate);
        interestRate = InterestRate("Danish", "Denmark", "", -0.450, -0.350, "10-01-2021");
        interestRates.append(interestRate);
        interestRate = InterestRate("European", "Europe", "EUR", 0.000, 0.050, "03-10-2016");
        interestRates.append(interestRate);
        interestRate = InterestRate("Hungarian", "Hungary", "", 2.900, 2.400, "01-25-2022");
        interestRates.append(interestRate);
        interestRate = InterestRate("Indian", "India", "", 4.000, 4.400, "05-22-2020");
        interestRates.append(interestRate);
        interestRate = InterestRate("Indonesian", "Indonesia", "", 6.500, 6.750, "06-16-2016");
        interestRates.append(interestRate);
        interestRate = InterestRate("Israeli", "Israel", "", 0.100, 0.250, "04-06-2020");
        interestRates.append(interestRate);
        interestRate = InterestRate("Japanese", "Japan", "JPY", -0.100, 0.000, "02-01-2016");
        interestRates.append(interestRate);
        interestRate = InterestRate("Mexican", "Mexico", "", 5.500, 5.000, "12-16-2021");
        interestRates.append(interestRate);
        interestRate = InterestRate("New Zealand", "New Zealand", "NZD", 0.750, 0.500, "11-24-2021");
        interestRates.append(interestRate);
        interestRate = InterestRate("Norwegian", "Norway", "", 0.500, 0.250, "12-16-2021");
        interestRates.append(interestRate);
        interestRate = InterestRate("Polish", "Poland", "", 2.250, 1.750, "01-04-2022");
        interestRates.append(interestRate);
        interestRate = InterestRate("Russian", "Russia", "", 8.500, 7.500, "12-20-2021");
        interestRates.append(interestRate);
        interestRate = InterestRate("Saudi Ariabian", "Saudi Arabia", "", 1.000, 1.750, "03-16-2020");
        interestRates.append(interestRate);
        interestRate = InterestRate("South African", "South Africa", "", 4.000, 3.750, "01-27-2022");
        interestRates.append(interestRate);
        interestRate = InterestRate("Swedish", "Sweden", "", 0.000, -0.250, "12-19-2019");
        interestRates.append(interestRate);
        interestRate = InterestRate("Swiss", "Switzerland", "", -0.750, -0.500, "01-15-2015");
        interestRates.append(interestRate);
        interestRate = InterestRate("Turkish", "Turkey", "", 14.000, 15.000, "12-16-2021");
        interestRates.append(interestRate);
        */
    }


    // @notice Will receive any eth sent to the contract
    // https://ethereum.stackexchange.com/questions/42995/how-to-send-ether-to-a-contract-in-truffle-test
    // https://www.codegrepper.com/code-examples/whatever/Expected+a+state+variable+declaration.+If+you+intended+this+as+a+fallback+function+or+a+function+to+handle+plain+ether+transactions%2C+use+the+%22fallback%22+keyword+or+the+%22receive%22+keyword+instead.
    fallback()
        external
        payable
    {
        require(tx.origin == msg.sender, "phishing attack detected?");
        emit FallbackEvent(msg.sender,msg.value);
    }

    receive()
        external
        payable
    {
        emit ReceiveEvent(msg.sender,msg.value);
    }

    modifier isCorrectMaturity(uint256 epoch) {
        require(epoch == NEXT_DAY ||
                epoch == ONE_WEEK ||
                epoch == TWO_WEEKS ||
                epoch == THREE_WEEKS ||
                epoch == ONE_MONTH ||
                epoch == TWO_MONTHS ||
                epoch == THREE_MONTHS ||
                epoch == FOUR_MONTHS ||
                epoch == FIVE_MONTHS ||
                epoch == SIX_MONTHS ||
                epoch == SEVEN_MONTHS ||
                epoch == EIGHT_MONTHS ||
                epoch == NINE_MONTHS ||
                epoch == TEN_MONTHS ||
                epoch == ELEVEN_MONTHS ||
                epoch == ONE_YEAR ||
                epoch == TWO_YEARS ||
                epoch == THREE_YEARS ||
                epoch == FOUR_YEARS ||
                epoch == FIVE_YEARS ||
                epoch == SIX_YEARS ||
                epoch == SEVEN_YEARS ||
                epoch == TEN_YEARS,
                "incorrect maturity date");
        _;
    }

    modifier correctLotSize(uint256 lots) {
        require(lots >= 1 && lots <= 100,"lots out of bounds");
        _;
    }

    modifier notWithdrawing() {
        require(inWithdrawal == false,"withdrawal in progress");
        _;
    }

    /*
    function quote(string memory ccypair, uint256 maturity)
        public
        view
        returns (uint256)
    {
        // https://api.kraken.com/0/public/Ticker?pair=GBPUSD
        // {"error":[],"result":{"ZGBPZUSD":{"a":["1.35553","1033","1033.000"],"b":["1.35526","132","132.000"],"c":["1.35555","2.74000000"],"v":["646400.53966339","1521216.22766749"],"p":["1.35725","1.35846"],"t":[1226,3036],"l":["1.35448","1.35448"],"h":["1.36080","1.36109"],"o":"1.35966"}}}
        return _quote(maturity);
    }


    function _quote(uint256 maturity)
        internal
        returns (uint256)
    {
        uint256 tquote = 1.35555;
        uint256 base_interest = 0.500;
        uint256 quote_interest = 0.250;
        return tquote * ( ( (1 + base_interest * (maturity / ONE_YEAR)) / (1 + quote_interest * (maturity/ONE_YEAR)) ));
    }

    function mint(string memory ccypair, uint256 lots, uint256 maturity)
        public
        payable
        correctLotSize(lots)
        isCorrectMaturity(maturity)
    {
        require(msg.sender != address(0),"wallet address not valid");
        uint256 rate = _quote(maturity); // current forware rate for ccypair obtain from a similar source as https://www.fxempire.com/currencies/eur-usd/forward-rates
        require(msg.sender.balance > (lots * rate * uint256(10000)),"insufficient balance");
        uint256 _rate = uint256(rate * 10000);
        require(msg.value == (lots * _rate), "not enough funds");
        payable(address(this)).transfer(msg.value); // transfer payment to contract 

        tokens[msg.sender] = ForwardToken(ccypair, lots, maturity, fixed24x5(msg.value));
        emit ForwardTokenMinted(msg.sender,ccypair,lots,maturity,tokens[msg.sender]);
    }

    // current forward rate for tokens[msg.sender].ccypair from a similar source as https://www.fxempire.com/currencies/eur-usd/forward-rates
    function profitLoss(uint256forward_rate)
        public
        view
        returns (uint256)
    {
        require(msg.sender != address(0),"wallet address not valid");
        require(tokens[msg.sender] != address(0),"no forward contract token exists?");

        uint256investor_rate = tokens[msg.sender].rate;
        return (forward_rate - investor_rate);
    }

    function isMatured()
        public
        view
        returns (bool)
    {
        require(msg.sender != address(0),"wallet address not valid");
        require(tokens[msg.sender] != address(0),"no forward contract token exists?");

        uint256 maturity_date = tokens[msg.sender].maturity;
        return (maturity_date > block.timestamp);
    }

    // current forward rate for tokens[msg.sender].ccypair from a similar source as https://www.fxempire.com/currencies/eur-usd/forward-rates
    function withdraw(uint256forward_rate)
        public
        payable
        notWithdrawing
    {
        require(msg.sender != address(0),"wallet address not valid");
        require(tokens[msg.sender] != address(0),"no forward contract token exists?");

        inWithdrawal = true; // prevents re-entrancy

        uint256 maturity_date = tokens[msg.sender].maturity;
        if (maturity_date > block.timestamp) {
            uint256investor_rate = tokens[msg.sender].rate;
            
            if (forward_rate >= investor_rate) {
                uint256 amount = forward_rate * tokens[msg.sender].lots * uint256(10000);
                if (address(this).balance > amount) {
                    payable(msg.sender).transfer(amount);
                    emit Withdrawal(msg.sender,amount);
                    delete tokens[msg.sender];
                    inWithdrawal = false;
                } else {
                    inWithdrawal = false;
                    revert("insufficient contract balance to process withdrawal");
                }
            } else {
                inWithdrawal = false;
                emit Withdrawal(msg.sender,uint256(0));
                delete tokens[msg.sender];
            }
        } else {
            inWithdrawal = false;
            revert("forward contract token has not reached maturity");
        }
    }

    function deposit()
        public
        payable
    {
        require(msg.sender != address(0),"wallet address not valid");
        require(msg.value > 0,"only positive amounts for a deposit");
        payable(address(this)).transfer(msg.value);
        emit Deposit(msg.sender,msg.value);
    }

    function balance()
        public
        view
        returns (uint256)
    {
        return address(this).balance;
    }
    */
}