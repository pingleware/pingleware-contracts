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

# What's included?
There are prebuilt smart contracts for Exempt Equity and Debt Offerings, a Credit Report and a Social network. Before launching an exempt equity or debt offering you are required to submit the appropriate form to the Security and Exchange Commission as well as to have a Private Placement Memorandum. Using a DAPP or decentralized application on the IPFS or interplanetary file system, to maintain KYC, AML and accredied investor vetting compliance for your restricted securities.

# Release Schedule

        Date        Version                 Notes
    12/19/2021     1.0.3         General fixes and compiler warnings cleanup
    12/19/2021     1.0.2         Employee Benefit Plan contract implemented
    12/19/2021     1.0.1         The remaining ExemptOffering contracts implemented with the exception of Employee Benefit Plan
    12/19/2021     1.0.0         Initial release with only ExemptEquityOffering506C contract implemented

# State of the Project
The project is currently in an alpha-beta state, which means that production use is not recommended. Production ready will be tagged as stable.
NPMJS.COM repository permits the tagging of releases as stable. See the workflow.

## Workflow

    1. Create the contracts for each exempt offering in accordance with SEC rules; complete the Credit Report contract in compliance with the FCRA; complete the Social Network contract that support community driven choice.
    2. Test the contracts on remix.ethereum.org to fix implementation issues? To import a contract from github.com into remix, naivgate to the desired contract and press the view raw button, no copy and paste the URL of the raw file view.
    3. Implement a DAPP using HTML, CSS, and JavaScript (jQuery and vanilla - no other JS frameworks) that connect to each contract deployed on a local truffle-ganache configuration.
    4. Deploy on an ethereum testnet for further testing and public preview.
    5. Create a private placement memorandum with a qualified attorney review.
    6. File the appropriate exempt offering with the Security and Exchange Commission (SEC) via EDGAR.
    7. Deploy the contract on an ethereum mainnet.
    8. Contact preselect accredited investors for participation.
    9. Tag this project as stable.

# End-of-Life Doctrine
When a piece of software is useful, there should never be an EOL doctrine. The intention for this application is to achieve immoratlity ;).
At some point of time in the future, this project may appear to be dead and abandon. The opposite will be true!
When this project reaches that stage, this project has matured to a level where maintenance is minimal (mostly updating to latest version of Node).

    Patrick O. Ingle
    December 19, 2021
