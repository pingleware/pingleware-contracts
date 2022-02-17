# Blockchain Credit Report
A blockchain can provide anonymity for credit reports because no personal identifying information is stored within the smart contract.

Consumers as well as subscribers (creditors and collectors) are identified by their wallet address hash.

Credit report items are defined as private contract variables.

Fair Credit Reporting guidelines are followed by allowing the consumer unlimited, free access to their own report, while subscribers are charge a small fee for each inquiry.

Only a subscriber can add a new consumer when a new report item is added.

Only a consumer can create a dispute while a subscriber can finalize and update a dispute. 

The contract owner can poll disputes and delete any disputes that have been opened for longer than thrty days.

# Benefit for Consumers
The consumers can get paid a portion of the inquiry, add item, and finalize dispute fees paid by the subscriber (creditor/collector). Consumers can request their credit report as well as inquiries as much as they wish because no record is made for a consumer request at the blockchain level. This allows a consumer request to avoid fees and expense.

The DAPP should log consumer requests for compliance requests.

A centralized database of authorized users must still be maintained to prevent bad actors from gaining access to a consumer report.

To give an incentive for adaptation by Consumers, is the receipt of a portion of the fee paid by subsribers (creditors/collectors). Using the DAPP, a consumer can register with their ethereum wallet, which will be their consumer credit ID. They can submit a notarized form of identity verification, so a creditor/collector knows the identity has been verified. Additional public records can be added to this blockchain contract and will be useful to validate the true identity of a consumer.

## Important Discoveries
In order to remain in compliance with the FCRA, the consumer cannot be charge a fee for requesting a once per year report nor when submitting a dispute. When a contract method changes the contract instance state, gas fees are assessed and paid. When a query for contract private data is requested, then no gas fee is assessed and it is a free action.

A modifier is added called consumerFreeAnnualCheck passing a local epoch timestamp (Date.toTime() / 1000) and check against the last consumer inquiry date (inquiries[consumer][inquiries[consumer].length - 1].time) if s year has elapsed or no previous request on the free request method (gas fees paid by owner) and new inquiry entry is added and the report return. A consumer credit report inquiry is available, which assesses gas fees from the consumer. The free method for the consumer, the gas fees are paid by the owner.

UPDATE:

The use of diamond storage in libraries avoids gas fees and hence can provide a consumer direct request to their credit report and disputes without incurring gas fees.

# The Future of Blockchain
Blockchain technologies is NOT a new technology, but a twist on an old technology, repackaged in different wrapping. Blockchain uses RPC or remote procedure calls, which is as old as myself. The abilities of blockchain are reminensent of the old CORBA days which refers to common object-oriented request broker architecture. Unlike CORBA, blockchain is expensive to use because of the gas fees. A better blockchain would be to eliminate the gas fees? and the mining?

Blockchain is easier to implement than CORBA.