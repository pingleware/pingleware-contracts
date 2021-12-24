THERE IS A LOT OF INFORMATION DISCLOSED ON THIS PAGE. PLEASE SEEK THE ADVICE OF A QUALIFIED LICENSED PROFESSIONAL TO ANSWER YOUR QUESTIONS.

# Exempt Offerings
See more at https://www.sec.gov/smallbusiness/exemptofferings

The perpose of creating exempt offerings on the blockchain even though they are restricted securities, is to offer liquidity to accredited investors after certain conditions have met, if any, for the accredited investors to liquidate with other investors, as well as to have a trading platform in-place when a public offering becomes effective and those existing securities become unrestricted.

This readme has been shorten by creating additional markdown files

    AML.md
    ATS.md
    BUILDING.md
    GLOSSARY.md
    SEC.md
    TransferAgent.md

A traditional private placement offering involves filing a FORM D on the SEC.GOV EDGAR filing system, creating a private placement memorandum and then searching for qualified and accredited investors. Prior to cryptocurrency and blockchain, liquidity in the private equity markets was limited until the company initiated an IPO. Under rule 144, creates liquidity in a private equity offering after twelve months from each sale of restricted securities. Using cryptocurrency for the private equity offering on the Ethereum network can create compliance liquidity before an IPO as well as generate a market value.

(THE FOLLOWING STATEMENTS ARE CLASSIFIED AS OPINIONS, SUBJECT TO VERIFICATION, etc. AND NOT LEGAL NOR INVESTMENT ADVICE!)

The introduction to equity trading tokens on the etheruem network make the search for accredited investors easier because liquidity is possible after the first twelve months of the offering under Rule 144. The market rate of the equity is established when the accredited investors have resold their holdings after twelve months have lapsed. Establishing a market rate in a private equity offering can prevent exorbitant valuations when a full IPO/DPO via a S-1 becomes effective.

Issuing preferred stock only during the private equity offering adds protection for the investors by placing them in a protected class similar to creditors, so in the event of court-ordered liquidation, the company assets can be sold to recover preferred equity investors funds.

A private equity offering should limit the maximum preferred shares to 10% of the total authorized shares specified in the company's charter, otherwise additional reporting requirements will be needed when new investors are vested. For example, a company with 1,000,000 authorized shares listed in it's charter, should limit private equity preferred outstanding shares to 100,000. The remaining 900,000 authorized shares can used for other offerings at a later date.

# Why an Exempt Offering on the Blockchain?
Prior to exempt blockchain offering, the accredited investor would have to wait for the company to conduct an unrestricted IPO before they can sell their holdings. Using the blockchain for exempt offerings, liquidity is automatically available based on the exemption?

# A Defi DAPP is required
A Decentralized-finance (Defi) distributed application (DAPP) is required to maintain SEC compliance for exempt offerings including but not limited to KYC, AML, and Transfer Agent responsibilities.

The source code for the Defi DAPP will reside in the src directory

See https://medium.com/ethereum-developers/the-ultimate-end-to-end-tutorial-to-create-and-deploy-a-fully-descentralized-dapp-in-ethereum-18f0cf6d7e0e

# Funding Categories

The former meaning,

    Series A - pre-seed funding private individuals and entities
    Series B - private equity
    Series C - higher funding goals that regulation A+ offers

the former series of funding was sequential, A before B before C?

the new meaning,

    Series A - under the rules for Regulation A
    Series B - under the rules for Regulation B (bank and institutional investors)
    Series C - under the rules for Regulation CF - Crowdfunding
    Series D - under the rules for Regulation D (this repository)
    Series 10 - under the rules of Regulation 10-12/G|B

the new definition permits any order of funding based on the SEC regulation?

# Project Structure
This project is being built for both ethereum and solana blockchains, where the source code resides in the respective directories

# Architecture
Solidity is an object-oriented language with inheritance and encapsulation (like C++ and Java). Proper OOP is to break up complex operations into smaller units, hence a method should ONLY perform a single task. Bugs get introduced when a method becomes a multitasker?

Solidity has contracts (like Classes in C++) and they can be abstract (which means they must be inherited), they have virtual and override functions, and they have library contracts which don't get inherited. If you are unfamaliar with OOP concepts and your parents were programmers, ask for the olde C++ and OOP methodologies as the same principles apply and can be adapted for Solidity smart contract programming.

The hierarchy of these contacts is the exempt offering contract is the top level and has unique properties (methods and data) unique to that offering. There are common entities used in all exempt offerings.

First, indetifying the main entities,

    ExemptEquityOffering506C

Second, identify the common entities all offerings include,

    Transfer Agent = required when applying for a CUSIP number, otherwise not required for an exempt offering
    Shareholder    = there are three distinct types: accredited, non-accredited and affiliate
    Shares         = the equity of the offering
    Transaction    = a record of each transaction (while this is kept on the blockchain, having a separate entity assists with recording keeping compliance)
    Account        = account properties