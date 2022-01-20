# PINGLEWARE Smart Contracts for Solidity
The following is a collection od smart contracts for solidity that will help accelerate blockchain development and deployment.

# Installation

    npm install @pingleware/contracts

# Usage
In your truffle project, import the appropriate smart contract in your new contract

    imports "@pingleware/contracts/contracts/debt/ExemptDebtOfferingBond.sol";

    contract MyExemptBond is ExemptDebtOfferingBond {
        constructor() public {
            name = "My Exempt Bond";
            symbol = "MYB";
        }
    }

When using remix.ethereum.org, you can import directly from github.com

    imports "https://raw.githubusercontent.com/pingleware/pingleware-contracts/main/contracts/debt/ExemptDebtOffering.sol";

    contract MyExemptBond is ExemptDebtOfferingBond {
        constructor() public {
            name = "My Exempt Bond";
            symbol = "MYB";
        }
    }

# In the News
## Why Blockchain Could Prevent Another Theranos
From: https://investorplace.com/2022/01/why-blockchain-could-prevent-another-theranos/

Before developing the Equity token smart contracts for exempt offerings, I research existing use cases and to my suprise, there were no existing use case. There were plenty of discussions without the implementation. The smart contract is open source, available for inspection by anyone. Also the smart contract can stay in compliance with the rules of an exempt offering by incorporating those restrictions whether timed or not, into the contract code. The most beneficial feature is the blockchain exempt equity token can offer liquidity of restricted securities when conditions have been satisfied to permit such transfers? The blockchain exempt equity token can also provide a future mechanism for exempt equity token conversion to public shares after an IPO/DPO has become effective. The blockchain exempt offering can be the first choice for unicorn startups, because the smart contract can be coded to restrict verified accredited investors ONLY from buying, selling and transferring the exempt equity tokens. Publishing an exempt equity token contract to the public blockchain does not violate the General Solicitation as long as no reference is made to solicitation of investors? A Defi DAPP is needed in conjunction with the exempt equity token contract to maintain the exemption of the offering through use restriction by accredited and qualified investors only! The Defi DAPP can be a mobile app which validates the investor one time on in a hosted environment and then adds their wallet to the authroized investor queue on the blockchain, further interaction is perform execlusively with the blockchain without any need to revisit the hosted environment unless changes and intervention are required?

# REMIX Webapp
The remix desktop was rebuilt as a webapp because I found the straight-browser version to become slow and non-responsive. The webapp version can be downloaded from https://github.com/pingleware/remix-desktop. You should try installing the official desktop version from the Remix Team at https://github.com/ethereum/remix-desktop. If the application will no launch, then download the webapp version.

# What's included?
There are prebuilt smart contracts 

    Exempt Equity and Debt Offerings
    Credit Report
    Social network
    Membership
    Pharma
    Real Estate
    Supply Chain
    
Before launching an exempt equity or debt offering you are required to submit the appropriate form to the Security and Exchange Commission as well as to have a Private Placement Memorandum. Using a DAPP or decentralized application on the IPFS or interplanetary file system, to maintain KYC, AML and accredited investor vetting compliance for your restricted securities.

# Release Schedule

        Date        Version                 Notes
    ??/??/????       1.0.6         Refactor equity, debt and membership; added supply chain, real estate and pharma
    12/25/2021       1.0.5         Refactoring credit, social and some equity contracts
    12/21/2021       1.0.4         Fixes identified through remix debugging; added followers and friends;
    12/19/2021       1.0.3         General fixes and compiler warnings cleanup
    12/19/2021       1.0.2         Employee Benefit Plan contract implemented
    12/19/2021       1.0.1         The remaining ExemptOffering contracts implemented with the exception of Employee Benefit Plan
    12/19/2021       1.0.0         Initial release with only ExemptEquityOffering506C contract implemented

# State of the Project
The project is currently in an alpha-beta state, which means that production use is not recommended. Production ready will be tagged as stable.
NPMJS.COM repository permits the tagging of releases as stable. See the workflow.

## Workflow
Skip to step #5, if deploying on a DEX like polymath.network,

    1. Create the contracts for each exempt offering in accordance with SEC rules; 
       complete the Credit Report contract in compliance with the FCRA; 
       complete the Social Network contract that support community driven choice.
    2. Test the contracts on remix.ethereum.org to fix implementation issues? 
       To import a contract from github.com into remix, naivgate to the desired contract and
       press the view raw button, no copy and paste the URL of the raw file view.
    3. Implement a DAPP using HTML, CSS, and JavaScript (jQuery and vanilla - no other JS frameworks)
       that connect to each contract deployed on a local truffle-ganache configuration.
    4. Deploy on an ethereum testnet for further testing and public preview.

    5. Create a private placement memorandum with a qualified attorney review, 
            https://theppmattorney.com/
    6. Register with the SEC as an EDGAR filer, obtain a CIK number, 
            https://www.sec.gov/edgar/filer-information/how-do-i
    7. File the appropriate exempt offering with the Security and Exchange Commission (SEC) via EDGAR, 
            https://www.portal.edgarfiling.sec.gov/Welcome/EDGAROnlineFormsLogin.htm
    8. Register as a Transfer Agent with the SEC using 
            https://www.sec.gov/about/forms/formta-1.pdf
    9. Apply for a CUSIP at http://cusip.com/apply
    10. Prepare most recent balance sheet, profit and loss and retained earnings statements, 
        equivalent financial information for the two prior fiscal years
            Balance sheet - https://www.investopedia.com/terms/b/balancesheet.asp
            Profit and Loss - https://corporatefinanceinstitute.com/resources/knowledge/accounting/profit-and-loss-statement-pl/
            Retained Earnings Statement - https://www.accountingformanagement.org/statement-of-retained-earnings
    11. Apply for a Ticker Symbol from FINRA using https://www.finra.org/sites/default/files/p126234.pdf
    12. Signup at polymath.network and reserve your symbol at https://eth-tokenstudio.polymath.network/ticker, 
        finalized STO process on this network.

    12-A. (alternative). Deploy on ethereum mainnet using the symbol assigned by FINRA,
          integrate with a custom DAPP.

    13. Contact preselect accredited investors for participation.
    14. Tag this project as stable.

Initial DEX Offering at https://coinmarketcap.com/alexandria/glossary/initial-dex-offering

CoinMarketCap listing criteria at https://support.coinmarketcap.com/hc/en-us/articles/360043659351-Listings-Criteria#section_b3

Security Token Offerings (STO) at https://itsblockchain.com/security-token-offerings-stos/

STO Market https://stomarket.com/market

# What is different between pingleware-contracts and other contract frameworks?
While the other contract frameworks provide templates to help you build contracts, they fall short from real world model implementation. pingleware-contracts provide a template for real world use of smart contracts across many industries, saving you development time and expense?

# End-of-Life Doctrine
When a piece of software is useful, there should never be an EOL doctrine. The intention for this application is to achieve immoratlity ;).
At some point of time in the future, this project may appear to be dead and abandon. The opposite will be true!
When this project reaches that stage, this project has matured to a level where maintenance is minimal (mostly updating to latest version of Node).

    Patrick O. Ingle
    December 19, 2021
