# PINGLEWARE Smart Contracts for Solidity

The following is a collection of smart contracts for solidity that will help accelerate blockchain development and deployment through the tokenization of Real World Assets (RWA). For updates, see [NEWS.md](NEWS.md).

# Installation

    npm install @pingleware/contracts

# Usage

In your truffle project, import the appropriate smart contract in your new contract

    imports "@pingleware/contracts/contracts/finance/debt/ExemptDebtOffering.sol";

    contract MyExemptBond is ExemptDebtOffering {
        constructor() public {
            name = "My Exempt Bond";
            symbol = "MYB";
        }
    }

When using remix.ethereum.org, you can import directly from github.com

    imports "https://raw.githubusercontent.com/pingleware/pingleware-contracts/main/contracts/finance/debt/ExemptDebtOffering.sol";

    contract MyExemptBond is ExemptDebtOfferingBond {
        constructor() public {
            name = "My Exempt Bond";
            symbol = "MYB";
        }
    }

## Creating, Compiling and Testing

Truffle create option,

```
Usage:        truffle create <artifact_type> <ArtifactName> 
  Description:  Helper to create new contracts, migrations and tests
  Options: 
                <artifact_type>
                    Create a new artifact where artifact_type is one of the following: contract, migration,
                    test or all. The new artifact is created along with one (or all) of the following
                    files: `contracts/ArtifactName.sol`, `migrations/####_artifact_name.js` or
                    `tests/artifact_name.js`. (required)
                <ArtifactName>
                    Name of new artifact. (required)
```

Truffle compiler options,

```
Usage:        truffle compile [<source1> <source2>...] [--list <filter>] [--all] [--quiet] [--config <file>] [--quiet]
  Description:  Compile contract source files
  Options: 
                --all
                    Compile all contracts instead of only the contracts changed since last compile.
                --list <filter>
                    List all recent stable releases from solc-bin.  If filter is specified then it will display only that
                    type of release or docker tags. The filter parameter must be one of the following: prereleases,
                    releases, latestRelease or docker.
                --compiler <compiler-name>
                    Specify a single compiler to use (e.g. `--compiler=solc`). Specify `none` to skip compilation.
                --config <file>
                    Specify configuration file to be used. The default is truffle-config.js
                --quiet
                    Suppress excess logging output.
```

See the [README.md](https://github.com/pingleware/pingleware-contracts/tree/main/test) under the test directory on GITHUB.COM

# Ethereum Smart Contract Creator

An application is being developed to help developers and business owenrs fast track smart contract implementation using the pingleware-contracts framework for real blockchain scenarios.

![1698075933917](image/README/1698075933917.png)

The Ethereum Smart Contract Creator will also introduce using a NFT as software license, [https://opensea.io/assets/matic/0x2953399124f0cbb46d2cbacd8a89cf0599974963/36333753202514414869774196218446368102124864803313914227828195910238651647648/](https://opensea.io/assets/matic/0x2953399124f0cbb46d2cbacd8a89cf0599974963/36333753202514414869774196218446368102124864803313914227828195910238651647648/)

## Where to Download?

Watch this repository for the release announcement of the Ethereum Smart Contract Creator. A beta version is located at [https://snapcraft.io/ethereum-contract-creator](https://snapcraft.io/ethereum-contract-creator). The application is in beta ONLY because this framework is currently in beta. When this framework is moved to stable, then the Ethereum Smart Contract Creator will be moved to stable. Only Linux version is provided during beta. A Mac, Windows, Android and iOS version will be released after the application has been marked stable.

## Will a Manual be included?

There will be a comprehensive soft copy (PDF) manual included at no charge since the application requires a paid license. A hard copy will be available for sale on AMAZON.COM

# In the News

## Why Blockchain Could Prevent Another Theranos

From: [https://investorplace.com/2022/01/why-blockchain-could-prevent-another-theranos/](https://investorplace.com/2022/01/why-blockchain-could-prevent-another-theranos/)

Before developing the Equity token smart contracts for exempt offerings, I research existing use cases and to my surprise, there were no existing use case. There were plenty of discussions without the implementation. The smart contract is open source, available for inspection by anyone. Also the smart contract can stay in compliance with the rules of an exempt offering by incorporating those restrictions whether timed or not, into the contract code. The most beneficial feature is the blockchain exempt equity token can offer liquidity of restricted securities when conditions have been satisfied to permit such transfers? The blockchain exempt equity token can also provide a future mechanism for exempt equity token conversion to public shares after an IPO/DPO has become effective. The blockchain exempt offering can be the first choice for unicorn startups, because the smart contract can be coded to restrict verified accredited investors ONLY from buying, selling and transferring the exempt equity tokens. Publishing an exempt equity token contract to the public blockchain does not violate the General Solicitation as long as no reference is made to solicitation of investors? A Defi DAPP is needed in conjunction with the exempt equity token contract to maintain the exemption of the offering through use restriction by accredited and qualified investors only! The Defi DAPP can be a mobile app which validates the investor one time on in a hosted environment and then adds their wallet to the authroized investor queue on the blockchain, further interaction is perform execlusively with the blockchain without any need to revisit the hosted environment unless changes and intervention are required?

# REMIX Webapp

The remix desktop was rebuilt as a webapp because I found the straight-browser version to become slow and non-responsive. The webapp version can be downloaded from https://github.com/pingleware/remix-desktop. You should try installing the official desktop version from the Remix Team at https://github.com/ethereum/remix-desktop. If the application will no launch, then download the webapp version.

### REMIXD

Use the following command to interface with remix,

`	remixd -s ./ --remix-ide https://remix.ethereum.org`

# What's included?

I have search github.com for other smart contract implementations in various industries, and copied to this repository ensuring they compile cleanly without errors and warnings.
There are prebuilt smart contracts

* Agriculture
* Aviation
* Education
* Energy
* Finance -
  * Banking
  * Credit
  * Currency
  * Debt
  * Equity
  * Utility
* Government
  * Federal
  * State
  * County
  * Municipal
* Healthcare
* Hospitality
* Insurance
* Legal
* Membership
* News
* NFT
* Non-Profit
* Real Estate
* Retail
* Supply Chain Management
* Social Network
* Technology
* Transportation

Before launching an exempt equity or debt offering you are required to submit the appropriate form to the Security and Exchange Commission as well as to have a Private Placement Memorandum. Using a DAPP or decentralized application on the IPFS or interplanetary file system, to maintain KYC, AML and accredited investor vetting compliance for your restricted securities.

# Release Schedule

|    Date    | Version |                                                                                                                                                                                                                                                                                                                                           |
| :--------: | :-----: | :---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 10/21/2023 |  1.6.4  | Added government, nft,non-profit, retail; refactor interface names                                                                                                                                                                                                                                                                        |
| 07/17/2022 |  1.6.3  | Added finance/banking/SavingsAccount.sol, libs/DateTime.sol. and useful documents                                                                                                                                                                                                                                                         |
| 04/30/2022 |  1.6.2  | Added RideshareTrade contract under Transportation category                                                                                                                                                                                                                                                                               |
| 04/29/2022 |  1.6.1  | Remove package.json dependencies not needed; added package keywords                                                                                                                                                                                                                                                                       |
| 04/29/2022 |  1.6.0  | Added Government contracts; refactor Frozen to include selfdestruct while extending Owned;                                                                                                                                                                                                                                                |
| 03/09/2022 |  1.5.0  | Added  Aviation, Education, Hospitality and Blockchain arbitration; social network, newfeed, and token deployments;                                                                                                                                                                                                                       |
| 02/27/2022 |  1.4.0  | Added BAToken and Peer-to-Peer lending to finance/token and finance/banking, respectively                                                                                                                                                                                                                                                 |
| 02/23/2022 |  1.3.0  | Add RINS (Renewal Identification Number) contract                                                                                                                                                                                                                                                                                         |
| 02/23/2022 |  1.2.2  | Maintenance fixes and refactoring; added SimpleBond.sol under finance                                                                                                                                                                                                                                                                     |
| 02/23/2022 |  1.2.1  | Maintenance; merge fixes;                                                                                                                                                                                                                                                                                                                 |
| 02/23/2022 |  1.2.0  | Add News contract; example tokens under finance/token; Token Exchange contract; Added CommercialPaper in<br />Debt financing;<br />Deployment of exempt offering token at [https://ropsten.etherscan.io/address/0x39db214c0373eda0eeee10bbf3fdc49a7faec46d](https://ropsten.etherscan.io/address/0x39db214c0373eda0eeee10bbf3fdc49a7faec46d) |
| 02/23/2022 |  1.1.1  | Fixed additional subdirectory files not being included during the packing.                                                                                                                                                                                                                                                                |
| 02/17/2022 |  1.1.0  | Refactor of contracts to permit sharing when deployed; add new contracts for:<br />agriculture, energy, finance.currency, healthcare, insurance, non-profit, real estate, retail, scm and transportation                                                                                                                                 |
| 01/28/2022 |  1.0.7  | Remove third-party dependencies; added placeholder contracts for insurance industry;                                                                                                                                                                                                                                                      |
| 01/27/2022 |  1.0.6  | Refactor equity, debt and membership; added additional industry smart contracts                                                                                                                                                                                                                                                           |
| 12/25/2021 |  1.0.5  | Refactoring credit, social and some equity contractsBETA status indicates that the smart contracts compile cleanly.<br /> Functionality is subject to change and is not completely stable.                                                                                                                                                |
| 12/21/2021 |  1.0.4  | Fixes identified through remix debugging; added followers and friends;NPMJS.COM repository permits the<br />tagging of releases as stable. See the workflow.                                                                                                                                                                              |
| 12/19/2021 |  1.0.3  | General fixes and compiler warnings cleanupThe project is currently in an alpha-beta state,<br />which means that production use is not recommended. Production ready will be tagged as stable.                                                                                                                                           |
| 12/19/2021 |  1.0.2  | Employee Benefit Plan contract implementedState of the Project                                                                                                                                                                                                                                                                            |
| 12/19/2021 |  1.0.1  | The remaining ExemptOffering contracts implemented with the exception of Employee Benefit Plan                                                                                                                                                                                                                                            |
| 12/19/2021 |  1.0.0  | Initial release with only ExemptEquityOffering506C contract implemented                                                                                                                                                                                                                                                                   |

 Auditing

Initial audits are conducted using ChatGPT

## Workflow

Skip to step #5, if deploying on a DEX like polymath.network,

    1. Create the contracts for each exempt offering in accordance with SEC rules; complete the Credit Report contract in compliance with the FCRA;
       complete the Social Network contract that support community driven choice.
    2. Test the contracts on remix.ethereum.org to fix implementation issues? To import a contract from github.com into remix, naivgate to the desired contract and press the view raw button, no copy and paste the URL of the raw file view.
    3. Implement a DAPP using HTML, CSS, and JavaScript (jQuery and vanilla - no other JS frameworks) that connect to each contract deployed on a local truffle-ganache configuration.
    4. Deploy on an ethereum testnet for further testing and public preview.

    5. Create a private placement memorandum with a qualified attorney review,[https://theppmattorney.com/](https://theppmattorney.com/)
    6. Register with the SEC as an EDGAR filer, obtain a CIK number, [https://www.sec.gov/edgar/filer-information/how-do-i](https://www.sec.gov/edgar/filer-information/how-do-i)
    7. File the appropriate exempt offering with the Security and Exchange Commission (SEC) via EDGAR at [https://www.portal.edgarfiling.sec.gov/Welcome/EDGAROnlineFormsLogin.htm](https://www.portal.edgarfiling.sec.gov/Welcome/EDGAROnlineFormsLogin.htm)
    8. Register as a Transfer Agent with the SEC using[https://www.sec.gov/about/forms/formta-1.pdf](https://www.sec.gov/about/forms/formta-1.pdf)
    9. Apply for a CUSIP at [https://www.cusip.com/apply/index.html](https://www.cusip.com/apply/index.html)
    10. Prepare most recent balance sheet, profit and loss and retained earnings statements, equivalent financial information for the two prior fiscal years
            Balance sheet - [https://www.investopedia.com/terms/b/balancesheet.asp](https://www.investopedia.com/terms/b/balancesheet.asp)
            Profit and Loss - [https://corporatefinanceinstitute.com/resources/knowledge/accounting/profit-and-loss-statement-pl/](https://corporatefinanceinstitute.com/resources/knowledge/accounting/profit-and-loss-statement-pl/)
            Retained Earnings Statement - [https://www.accountingformanagement.org/statement-of-retained-earnings](https://www.accountingformanagement.org/statement-of-retained-earnings)
    11. Apply for a Ticker Symbol from FINRA using [https://www.finra.org/sites/default/files/p126234.pdf](https://www.finra.org/sites/default/files/p126234.pdf)
    12. Signup at polymath.network and reserve your symbol at [https://eth-tokenstudio.polymath.network/ticker](https://eth-tokenstudio.polymath.network/ticker), finalized STO process on this network.

    12-A. (alternative). Deploy on ethereum mainnet using the symbol assigned by FINRA, integrate with a custom DAPP.

    13. Contact preselect accredited investors for participation.
    14. Tag this project as stable.

* Initial DEX Offering at [https://coinmarketcap.com/alexandria/glossary/initial-dex-offering](https://coinmarketcap.com/alexandria/glossary/initial-dex-offering)
* CoinMarketCap listing criteria at [https://support.coinmarketcap.com/hc/en-us/articles/360043659351-Listings-Criteria#section_b3](https://support.coinmarketcap.com/hc/en-us/articles/360043659351-Listings-Criteria#section_b3)
* Security Token Offerings (STO) at [https://itsblockchain.com/security-token-offerings-stos/](https://itsblockchain.com/security-token-offerings-stos/)
* STO Market [https://stomarket.com/market](https://stomarket.com/market)

# Liquidity and the Blockchain

While a private placement has restricted liquidity, a public offering token using a S-1 filing does not have restricted liquidity, hence a CUSIP and ISIN numbers are both needed. The ideal method for unrestricted liquidity is to issue your public offering (S-1) on an established DEX, but I am discovering this to be more tedious and sometimes more costly than listing on NYSE, NASDAQ, AMEX, Pinksheets or any other brick and mortar exchange? The other option is create an alternative trading system (ATS) with an orderbook and order matching and register your ATS with the SEC. If your ATS is solely for your own company's securities, than FINRA, CFTC and NFA registration may not be needed? (check with your attorney)

# Crowdfunding

Crowdfunding is an exempt offering and highly regulated meaning, to perform a successful equity crowdfund campaign, you must use a registered SEC funding portal. A funding portal is registered with the SEC and regulated by FINRA. The list of current and expired crowdfunding portals/platforms can be found at [https://www.finra.org/about/firms-we-regulate/funding-portals-we-regulate](https://www.finra.org/about/firms-we-regulate/funding-portals-we-regulate).

One such funding portal, [https://cryptolaunch.us/ ](https://cryptolaunch.us/)offering crowd funding on the blockchain through an Security Token Offering (STO). They also offer a Mini-STO. See the difference between the two at [https://cryptolaunch.us/help/article/44](https://cryptolaunch.us/help/article/44),

```
"It depends on your situation. If a max total raise of $5 million USD is enough for your company to reach a meaningful milestone, or if you do not have up to $100,000 to spend upfront or if you have to move fast with you fundraising campaign, then Mini-STO is better. Otherwise and STO is better solution for your situation. Basically, the difference between the Mini-STO and STO boils down to the difference between Reg CF and Reg A+. Simple like that. ", - cryptolaunch.us
```

CRYPTOLAUNCH.US is the easiest crowwdfunding platform for equity offerings.

See [https://www.sec.gov/divisions/marketreg/tmcompliance/fpregistrationguide.htm](https://www.sec.gov/divisions/marketreg/tmcompliance/fpregistrationguide.htm)

# Online Token Builder

The following service, [https://www.thetokenlauncher.com/buildtoken](https://www.thetokenlauncher.com/buildtoken), a user can build a token, download the source code and launch through the platform (cost 0.1 ETH to launch)

The available tokens include,

    - Asset Backed Currency
    - Equity Token
    - Fan Token
    - Fund
    - Game Token
    - Utility Token
    - Other Security Token

with an option to make any offering into an ICO crowdsale.

## Asset Backed Currency

See [https://medium.com/ico-launch-malta/what-is-an-asset-backed-token-a-complete-guide-to-security-token-assets-f7a0f111d443](https://medium.com/ico-launch-malta/what-is-an-asset-backed-token-a-complete-guide-to-security-token-assets-f7a0f111d443)

An Asset-backed currency would be considered as an Asset-back security (ABS) as defined by the SEC. See [finance/debt/ABS.md](finance/debt/ABS.md)

SEC Asset-backed securities disclosure rules at [https://www.sec.gov/rules/final/2014/33-9638.pdf](https://www.sec.gov/rules/final/2014/33-9638.pdf)

ABS public registration uses form ABS-15G and ABS-EE
ABS private registration uses form D

## Equity Token

A Security Token represents an asset or an entitlement to an earning stream or dividends. In terms of their economic function, the tokens are comparable to equities, bonds or derivatives, and are expected to make a profit.

## Fan Token

Fan tokens are a form of cryptocurrency that gives holders access to a variety of fan-related membership perks like voting on club decisions, rewards, merchandise designs and unique experiences.

See more at [https://coinmarketcap.com/alexandria/article/what-are-fan-tokens](https://coinmarketcap.com/alexandria/article/what-are-fan-tokens)

Fan Tokens are typically an NFT. NFT is like a trading card or collectible, any gains made on the sale of the NFT is taxable. See [https://www.romanolaw.com/2021/12/13/nfts-collectibles-or-securities/](https://www.romanolaw.com/2021/12/13/nfts-collectibles-or-securities/)

## Fund

A fund token would be a donation for a tax exempt non-profit organization, and a security for all others.

## Game Token

An old incentive for the blockchain. User purchases a game token to be used in a game. As long as the game token is used for game play and redemption inside the game with no perceived financial gains, the game token would not be a security. See [https://www.romanolaw.com/2021/12/13/nfts-collectibles-or-securities/](https://www.romanolaw.com/2021/12/13/nfts-collectibles-or-securities/)

## Utility Token

A Utility Token provides access to the goods and services that a project launched or will launch in the future, and can be used as a type of discount or premium access to the services. A lot of tokens tend to be used specifically as a funding mechanism for companies.

A Utility token would not be a security as long as trading/swapping with third parties is not provided. Utility token would be like a discount coupon book where you prepaid to get a future discount. See [https://www.romanolaw.com/2021/12/13/nfts-collectibles-or-securities/](https://www.romanolaw.com/2021/12/13/nfts-collectibles-or-securities/)

# What is different between pingleware-contracts and other contract frameworks?

While the other contract frameworks provide templates to help you build contracts, they fall short from real world model (aka Real World Assets [RWA]) implementation. pingleware-contracts provide a template for real world (RWA) use of smart contracts across many industries, saving you development time and expense?

# Getting Test Ether

The following network faucet(s) give the most and permit one request per twenty four hours,

    [https://faucet.egorfine.com/](https://faucet.egorfine.com/)

# Private Ethereum Network

See [https://geth.ethereum.org/docs/interface/private-network](https://geth.ethereum.org/docs/interface/private-network) for more information.

    1. Create a unique chainID and symbol, see https://chainid.network to check for uniqueness. You chainID and networkID will be the same.
    2. (optional) If you want credibility for your private network, then consider taking your cryptocurrency public through an S-1, where the asset class is cryptocurrency.
        Then get a symbol assigned from FINRA ([https://www.securitieslawyer101.com/2015/market-maker](https://www.securitieslawyer101.com/2015/market-maker)). Since you have a private network (private meaning separate from mainnet)
        you will need to register the network as an ATS (alternative trading system), as well as the issuer of the cryptocurrency, register as a transfer agent. You will
        also need to get a license as a Money Transmitter the jurisdictions that you conduct business. When you perform an S-1 the quantity is the maximum number of tokens that
        will be issued. The fee for filing an S-1 is $92.70 per $1,000,000 ([https://www.sec.gov/ofm/Article/feeamt.html](https://www.sec.gov/ofm/Article/feeamt.html)), or

    total offering = token initial price * number of tokens (if you have a par value, then the minimum price is the par value)

    total_offering = $5 * 200,000 = $1,000,000
            filing_fee = (total_offering / 1000000) * 92.70

    You can have multiple offerings of S-1, the first S-1 makes your company a public company.

    When you apply for a trading symbol from FINRA, requires a market maker ([https://www.finra.org/about/firms-we-regulate/broker-dealer-firms-we-regulate](https://www.finra.org/about/firms-we-regulate/broker-dealer-firms-we-regulate)), because they will handle the KYC and AML for your clients, buying your token at a discount or par value.

Command line option,

    > geth --networkid`<chainID>`

## List Private Network on chainid.network

    1. Clone the project[https://github.com/ethereum-lists/chains](https://github.com/ethereum-lists/chains)
    2. Create a new file in ./_data/chains directory using the file convention of eip115-`<chainID>`.json
    3. Create a logo for your private network
    4. Copyright the logo.
    5. Publish your logo to a publicly accessible IPFS network
    6. Create a new file in ./_data/icons directory using the file convetion of `<symbol>`.json
    7. Check in changes to your github.com account
    8. Create a pull request.
    9. Wait for your changes to be merged.

# End-of-Life Doctrine

When a piece of software is useful, there should never be an EOL doctrine. The intention for this application is to achieve immoratlity ;).
At some point of time in the future, this project may appear to be dead and abandon. The opposite will be true!
When this project reaches that stage, this project has matured to a level where maintenance is minimal and hopefully automated (mostly updating to latest version of Node).

    Patrick O. Ingle
    December 19, 2021
