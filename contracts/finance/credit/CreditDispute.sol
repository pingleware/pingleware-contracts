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

    function getDisputes(address consumer)
        internal
        view
        returns (bytes32)
    {
      bytes32 output = "";
      for (uint i = 0; i < creditDisputeStorage().disputes[consumer].length; i++) {
        DisputeItem memory _dispute = DisputeItem(
          creditDisputeStorage().disputes[consumer][i].subscriber,
          creditDisputeStorage().disputes[consumer][i].consumer,
          creditDisputeStorage().disputes[consumer][i].disputeDate,
          creditDisputeStorage().disputes[consumer][i].item,
          creditDisputeStorage().disputes[consumer][i].reason,
          creditDisputeStorage().disputes[consumer][i].status
        );
        output = keccak256(
          abi.encodePacked(
            output,
            "[",
            _dispute.subscriber,
            _dispute.consumer,
            _dispute.disputeDate,
            _dispute.reason,
            _dispute.status,
            "]"
          )
        );
      }
      return output;
    }

    function getDisputeItem(address consumer, uint index)
      public
      view
      returns (bytes memory)
    {
      return creditDisputeStorage().disputes[consumer][index].item;
    }

    function finalizeDispute(address consumer,uint index,string memory status, bool purge)
        internal
    {
      DisputeItem memory dispute = DisputeItem(
        creditDisputeStorage().disputes[consumer][index].subscriber,
        creditDisputeStorage().disputes[consumer][index].consumer,
        creditDisputeStorage().disputes[consumer][index].disputeDate,
        creditDisputeStorage().disputes[consumer][index].item,
        creditDisputeStorage().disputes[consumer][index].reason,
        status
      );

      if (purge) {
        delete creditDisputeStorage().disputes[consumer][index];
      } else {
        creditDisputeStorage().disputes[consumer][index] = dispute;
      }
    }

}