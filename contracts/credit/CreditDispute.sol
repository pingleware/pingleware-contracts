// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

library CreditDispute {
    struct Item {
        string  opendate;
        string  description;
        uint    amount;
        uint    balance;
        uint    limit;
        string  paystatus;
    }

    struct ReportItem {
        address subscriber;
        bytes   item;
    }

    struct DisputeItem {
        address subscriber;
        address consumer;
        string  disputeDate;
        bytes   item;
        string  reason;
        string  status;
    }


    struct CreditDisputeStorage {
        mapping(address => DisputeItem[]) disputes;
    }

    function creditDisputeStorage() internal pure returns (CreditDisputeStorage storage ds)
    {
        bytes32 position = keccak256("dispute.storage");
        assembly { ds.slot := position }
    }

    //
    // because open dispute changes the state of the contract, gas fees applies,
    // hence the consumer must start a dispute offline, and send to the owner to create a dispute and the owner pays the gas fee
    //
    function openDispute(address consumer, address subscriber,bytes memory item,string memory disputeDate,string memory reason)
        internal
    {
        DisputeItem memory dispute = DisputeItem(subscriber, consumer, disputeDate, item, reason, "");
        creditDisputeStorage().disputes[consumer].push(dispute);
    }

    function purgeDispute(address consumer,uint256 index)
        internal
    {
        delete creditDisputeStorage().disputes[consumer][index];
    }

}