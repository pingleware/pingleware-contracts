# Testing

Each test case is created for each Contract and not for abstract contracts, interfaces nor libraries as these cannot be instantiated, by using the command,

```
truffle create test <CONTRACT NAME>
```

the test file contains the basic deploy test, and additional tests are related to the contract under test,

```
const Contract = artifacts.require("CONTRACT NAME");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("CONTRACT NAME", function (/* accounts */) {
  it("should assert true", async function () {
    await Contract.deployed();
    return assert.isTrue(true);
  });
});

```

You can use the Ethereum Contract Creator, and from the settings dialog obtain the RPC host and port

![1697948745720](image/README/1697948745720.png)

Then edit truffle-config.js,

```
development: {
      host: "localhost",     // Localhost (default: none)
      port: 7535,            // Standard Ethereum port (default: none)
      network_id: "*",       // Any network (default: none)
    },

// IMPORTANT: change the following path to the contracts you want to test
  contracts_directory: './contracts/government/county/',

  // Set default mocha options here, use special reporters, etc.
  mocha: {
    // timeout: 100000
  },

  // Configure your compilers
  compilers: {
    solc: {
      version: "0.8.18",      // Fetch exact version from solc-bin (default: truffle's version)
      // docker: true,        // Use "0.5.1" you've installed locally with docker (default: false)
      settings: {          // See the solidity docs for advice about optimization and evmVersion
        optimizer: {
          enabled: true,
          runs: 1
        },
        evmVersion: "byzantium"
      }
    }
  },
```

To start test, change to the root directory, edit the contracts_directory value on truffle-config.js to the contract directory under test,

```
truffle compile
```

then issue the migrate and test command, the migrate and test commands are not dependent on the contracts_directory setting in truffle-config.js,

```
truffle migrate --reset
truffle test
```

## Contract Test Status

The following table created for tracking status when each contract has completed and passed testing. When a contract has passed the testing, that contract is considered to be stable. When all contracts are considered stable, this package will be released as stable.

| Group                   | Sub-Group | Name                          | Complete | Pass |
| :---------------------- | --------- | ----------------------------- | :------: | :--: |
| Agriculture             |           |                               |          |      |
|                         |           | AgriChain                     |    N    |  N  |
|                         |           | AgriTrade                     |    N    |  N  |
| Aviation                |           |                               |          |      |
|                         |           | AircraftOwnership             |    N    |  N  |
| Education               |           |                               |          |      |
|                         |           | Course                        |    N    |  N  |
|                         |           | EducationRoles                |    N    |  N  |
|                         |           | Lesson                        |    N    |  N  |
|                         |           | Transcripts                   |    N    |  N  |
| Energy                  |           |                               |          |      |
|                         |           | EETP                          |    N    |  N  |
|                         |           | EnergyStore                   |    N    |  N  |
|                         |           | RINS                          |    N    |  N  |
| Finance                 |           |                               |          |      |
|                         | Banking   |                               |          |      |
|                         |           | PeerToPeerLending             |    N    |  N  |
|                         |           | SavingsAccount                |    N    |  N  |
|                         | Credit    |                               |          |      |
|                         |           | CreditReportAgency            |    N    |  N  |
|                         | Currency  |                               |          |      |
|                         |           | Asian                         |    N    |  N  |
|                         |           | Forward                       |    N    |  N  |
|                         |           | Future                        |    N    |  N  |
|                         |           | Option                        |    N    |  N  |
|                         |           | Swap                          |    N    |  N  |
|                         |           | Touch                         |    N    |  N  |
|                         | DAO       |                               |          |      |
|                         |           | WyomingDAO                    |    N    |  N  |
|                         | Debt      |                               |          |      |
|                         |           | CommercialPaper               |    N    |  N  |
|                         |           | ExemptDebtOffering            |    N    |  N  |
|                         |           | ExemptDebtOfferingStaking     |    N    |  N  |
|                         |           | SimpleBond                    |    N    |  N  |
|                         |           |                               |          |      |
|                         | ELMX      |                               |          |      |
|                         |           | BestBooks                     |    N    |  N  |
|                         |           | BondCertificate               |    N    |  N  |
|                         |           | ConsolidatedAuditTrail        |    N    |  N  |
|                         |           | EncryptionUtils               |    N    |  N  |
|                         |           | ExchangeFee                   |    N    |  N  |
|                         |           | ExemptLiquidityMarketExchange |    N    |  N  |
|                         |           | InvestorManager               |    N    |  N  |
|                         |           | MunicipalBond                 |    N    |  N  |
|                         |           | OrderBook                     |    N    |  N  |
|                         |           | PaymentWallet                 |    N    |  N  |
|                         |           | Reg3A11Debt                   |    N    |  N  |
|                         |           | Reg3A11Equity                 |    N    |  N  |
|                         |           | Reg147ADebt                   |    N    |  N  |
|                         |           | Reg147AEquity                 |    N    |  N  |
|                         |           | Reg147Debt                    |    N    |  N  |
|                         |           | Reg147Equity                  |    N    |  N  |
|                         |           | Reg701Equity                  |    N    |  N  |
|                         |           | RegAT1Debt                    |    N    |  N  |
|                         |           | RegAT1Equity                  |    N    |  N  |
|                         |           | RegD506CDebt                  |    N    |  N  |
|                         |           | RegD506CEquity                |    N    |  N  |
|                         |           | SecurityMeta                  |    N    |  N  |
|                         |           | StockCertificate              |    N    |  N  |
|                         |           | TokenManager                  |    N    |  N  |
|                         | Equity    |                               |          |      |
|                         |           | ATS                           |    N    |  N  |
|                         |           | CPAMM                         |    N    |  N  |
|                         |           | DelawareStockToken            |    N    |  N  |
|                         |           | DirectEquityOffering          |    N    |  N  |
|                         |           | ExemptEquityOffering          |    N    |  N  |
|                         |           | ICO                           |    N    |  N  |
|                         | Utility   |                               |          |      |
|                         |           | BAToken                       |    N    |  N  |
| Government              |           |                               |          |      |
|                         | Federal   |                               |          |      |
|                         |           | Congress                      |    N    |  N  |
|                         |           | HouseOfRepresentatives        |    N    |  N  |
|                         |           | Immigration                   |    N    |  N  |
|                         |           | IRS                           |    N    |  N  |
|                         |           | POTUS                         |    N    |  N  |
|                         |           | SCOTUS                        |    N    |  N  |
|                         |           | USSenate                      |    N    |  N  |
|                         | State     |                               |          |      |
|                         |           | StateGovernment               |    N    |  N  |
|                         | County    |                               |          |      |
|                         |           | CountyBusStops                |    N    |  N  |
|                         |           | CountyGovernment              |    N    |  N  |
|                         |           | CountyJail                    |    N    |  N  |
|                         | Municipal |                               |          |      |
|                         |           | CityCouncil                   |    N    |  N  |
|                         |           | CityJail                      |    N    |  N  |
|                         |           | MunicipalBond                 |    N    |  N  |
|                         |           | MunicipalBusStops             |    N    |  N  |
| Healthcare              |           |                               |          |      |
|                         |           | Healthcare                    |    N    |  N  |
|                         |           | PersonalInfo                  |    N    |  N  |
|                         | Pharma    |                               |          |      |
|                         |           | SampleGuardian                |    N    |  N  |
| Hospitality             |           |                               |          |      |
|                         |           | BlockchainBNB                 |    N    |  N  |
| Insurance               |           |                               |          |      |
|                         |           | AccidentHealth                |    N    |  N  |
|                         |           | Annuities                     |    N    |  N  |
|                         |           | Automobile                    |    N    |  N  |
|                         |           | Captive                       |    N    |  N  |
|                         |           | FloodInsurance                |    N    |  N  |
|                         |           | HomeServiceWarranty           |    N    |  N  |
|                         |           | Homeowners                    |    N    |  N  |
|                         |           | LenderPlaced                  |    N    |  N  |
|                         |           | Life                          |    N    |  N  |
|                         |           | LongTermCare                  |    N    |  N  |
|                         |           | MediGap                       |    N    |  N  |
|                         |           | MotoreVehicleServiceAgreement |    N    |  N  |
|                         |           | ProfessionalLiability         |    N    |  N  |
|                         |           | Quote                         |    N    |  N  |
|                         |           | ServiceWarranty               |    N    |  N  |
|                         |           | SurplusLines                  |    N    |  N  |
|                         |           | Title                         |    N    |  N  |
|                         |           | WorkersCompensation           |    N    |  N  |
| Legal                   |           |                               |          |      |
|                         |           | Arbitration                   |    N    |  N  |
|                         |           | DisputeResolution             |    N    |  N  |
| Membership              |           |                               |          |      |
|                         |           | Membership                    |    N    |  N  |
| News                    |           |                               |          |      |
|                         |           | NewsFeed                      |    N    |  N  |
| NFT                     |           |                               |          |      |
|                         |           | NFT                           |    N    |  N  |
|                         |           | NFTCollection                 |    N    |  N  |
| Non-Profit              |           |                               |          |      |
|                         |           | Donation                      |    N    |  N  |
|                         |           | TaxExemptBond                 |    N    |  N  |
| Real Estate             |           |                               |          |      |
|                         |           | RealEstate                    |    N    |  N  |
|                         |           | Records                       |    N    |  N  |
| Retail                  |           |                               |          |      |
|                         |           | Classifieds                   |    N    |  N  |
|                         |           | Inventory                     |    N    |  N  |
|                         |           | Pawn                          |    N    |  N  |
|                         |           | RetailInstalmentSales         |    N    |  N  |
|                         |           | Store                         |    N    |  N  |
|                         |           | TicketSales                   |    N    |  N  |
| Supply Chain Management |           |                               |          |      |
|                         |           | DistributorRole               |    N    |  N  |
|                         |           | EndUserRole                   |    N    |  N  |
|                         |           | ManufacturerRole              |    N    |  N  |
|                         |           | ResellerRole                  |    N    |  N  |
|                         |           | SupplierRole                  |    N    |  N  |
|                         |           | SupplyChain                   |    N    |  N  |
| Social                  |           |                               |          |      |
|                         |           | SocialNetwork                 |    N    |  N  |
| Technology              |           |                               |          |      |
|                         |           | SoftwareLicense               |    N    |  N  |
|                         |           | SoftwareLicenseMetadata       |    N    |  N  |
| Transportation          |           |                               |          |      |
|                         |           | Driver                        |    N    |  N  |
|                         |           | Payment                       |    N    |  N  |
|                         |           | RentalCar                     |    N    |  N  |
|                         |           | RideshareTrade                |    N    |  N  |
|                         |           | Transport                     |    N    |  N  |

Complete refers when the contract test script is fully implemented, while Pass refers to the contract passing the test.
