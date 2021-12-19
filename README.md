# PINGLEWARE Smart Contracts for Solidity
The following is a collection od smart contracts for solidity that will help accelerate blockchain development and deployment.

# Installation

    npm install @pingleware/contracts

# Usage
In your truffle project, import the appropriate smart contract in your new contract

    imports "@pingleware/contracts/ExemptDebtOfferingBond.sol";

    contract MyExemptBond is ExemptDebtOfferingBond {
        constructor() public {
            name = "My Exempt Bond";
            symbol = "MYB";
        }
    }

# What's included?
There are prebuilt smart contracts for Exempt Equity and Debt Offerings, a Credit Report and a Social network. Before launching an exempt equity or debt offering you are required to submit the appropriate form to the Security and Exchange Commission as well as to have a Private Placement Memorandum. Using a DAPP or decentralized application on the IPFS or interplanetary file system, to maintain KYC, AML and accredied investor vetting compliance for your restricted securities.