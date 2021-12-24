// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

import "../Version.sol";
import "../Owned.sol";
import "./Consumer.sol";
import "./Subscriber.sol";
import "./CreditInquiry.sol";
import "./CreditReport.sol";
import "./CreditDispute.sol";

contract CreditReportAgency is Version, Owned {
    bytes32 constant private ZERO_BYTES = bytes32(0);
    address constant private ZERO_ADDRESS = address(0);

    uint total_consumers;

    mapping (address => bytes32[]) message;

    event SubscriberAdded(address addr, string message);
    event SubscriberNotified(address addr, string message);
    event ConsumerNotified(address addr, string message);


    constructor()
    {
      total_consumers = 0;
    }

    modifier validSender() {
      require(msg.sender != ZERO_ADDRESS,"access denied for sender");
      _;
    }

    modifier requiresFee(uint fee) {
      require(msg.sender.balance > fee, "insufficient balance/amount");
      _;
    }

    // A consumer is entitled
    modifier freeReportCheck(address consumer, address subscriber, uint256 reqtime) {
      //bool found = false;
      //uint256 subscriber_lastreq = reqtime;
      //for (uint i = inquiries[consumer].length; i > 0; i--) {
      //  if (!found && subscribers[inquiries[consumer][i].subscriber] != 0) {
      //      subscriber_lastreq = inquiries[consumer][i].reqdate;
      //      found = true;
      //  }
      //}

      //uint consumer_total = inquiries[consumer].length - 1;
      //uint256 consumer_lastreq = inquiries[consumer][consumer_total].reqdate;
      //require(
      //  consumer_lastreq == 0 || (consumer_lastreq + 52 weeks) > reqtime || (subscriber_lastreq + 90 days) < reqtime,
      //"not eligible for a free report");
      _;
    }

    
    function getUserRole()
      public
      payable
      validSender
      returns (string memory)
    {
      if (msg.sender == getOwner()) {
        return string("owner");
      } else if (Subscriber.isSubscriber(msg.sender)) {
        return string("subscriber");
      } else if (Consumer.isConsumer(msg.sender)) {
        return string("consumer");
      }
      return string("unknown");
    }
    

    function getBlocktime()
      public
      view
      returns (uint256)
    {
      return block.timestamp;
    }

    //
    // The disputeDate is in ISO and must be converted to epoch timestamp before checking current time
    // The currentTime is epoch timestamp provided by the caller
    //
    function checkExpiry(uint256 LastTimeStamp, uint256 currentTime)
      public
      pure
      returns(bool)
    {
      if (LastTimeStamp + 30 days >= currentTime) {
        return true;
      } else {
        return false;
      }
    }

    //
    // adds a new subscriber
    //
    function addSubscriber(address addr, uint256 _type,bytes32 encrypted, bytes memory signature)
      public
      onlyOwner(encrypted,signature)
    {
      require(addr != ZERO_ADDRESS,"missing address");
      if (Subscriber.addSubscriber(addr, _type)) {
        emit SubscriberAdded(addr, "subscriber added");
      }
    }

    //
    // retrieves consumer report for the consumer by the owner so the consumer does not incur gas fees.
    // to abide by law and allow free credit report to the consumer, cannot change the state on the contract,
    // otherwise the method must pay gas fee. By not recording consumer self requests in the contract, keeps
    // this function free.
    //
    function getFreeCreditReport(address _consumer, address subscriber, uint256 reqtime,bytes32 encrypted, bytes memory signature)
      public
      payable
      onlyOwner(encrypted,signature)
      freeReportCheck(_consumer, subscriber, reqtime)
      returns (bytes32)
    {
      CreditInquiry.add(_consumer, subscriber, reqtime);
      return CreditReport.getConsumerReport(_consumer);
    }

    function getReportsByConsumer(address consumer,bytes32 encrypted, bytes memory signature)
      public
      payable
      onlyOwner(encrypted,signature)
      returns (bytes32)
    {
      return CreditReport.getConsumerReport(consumer);
    }


    //
    // because open dispute changes the state of the contract, gas fees applies,
    // hence the consumer must start a dispute offline, and send to the owner to create a dispute and the owner pays the gas fee
    //
    function openDispute(address consumer, address subscriber, uint index, string memory disputeDate,string memory reason,bytes32 encrypted, bytes memory signature)
      public
      onlyOwner(encrypted,signature)
    {
      CreditDispute.openDispute(consumer, subscriber,CreditReport.getConsumerReportItem(consumer,index),disputeDate,reason);
      //message[report.subscriber].push(
      //  keccak256(
      //    abi.encodePacked(
      //      "Dispute Opened:",
      //      index,
      //      report.subscriber,
      //      consumer,
      //      disputeDate,
      //      report.item,
      //      reason
      //    )
      //  )
      //);
      emit SubscriberNotified(subscriber, "new dispute opened");
    }

    //
    // adds an item to the consumer report by an existing subscriber, must contain the minimum:
    //    subscriber, open date, amount, description, balance, limit, payment status
    //
    function addConsumerItem(address consumer, bytes memory item)
      public
    {
      require(consumer != ZERO_ADDRESS,"missing address");
      require(Subscriber.onlySubscriber(), "access denied for subscriber");
      //if (consumers[consumer] == 0) {
      //  consumers[consumer] = 1;
      //  _consumers.push(consumer);
      //  total_consumers++;
      //}
      //ReportItem memory ritem = ReportItem(msg.sender, item);
      //reports[consumer].push(ritem);
      emit ConsumerNotified(consumer, "new item was added to your report");
    }

    function sendMessage(address _recipient, bytes32 _message)
      public
    {
      message[_recipient].push(_message);
    }

    function readMessage()
      public
      view
      returns (bytes32[] memory)
    {
      return message[msg.sender];
    }


    function purgeDispute(address consumer, uint index,bytes32 encrypted, bytes memory signature)
      public
      onlyOwner(encrypted,signature)
    {
      CreditDispute.purgeDispute(consumer,index);
      emit ConsumerNotified(consumer, "dispute deleted");
    }

    //
    // retrieves consumer report by a subscriber, fee is paid to the owner
    //
    function getConsumerReport(address consumer, uint reqtime, address payable to,bytes32 encrypted, bytes memory signature)
      public
      payable
      isOwner(to,encrypted,signature)
      requiresFee(0.001 ether)
      returns (bytes32)
    {
      require(Subscriber.onlySubscriber(), "access denied for subscriber");
      //to.transfer(0.001 ether);
      CreditInquiry.add(consumer,msg.sender,reqtime);
      return CreditReport.getConsumerReport(consumer);
    }

    // Consumer previlieges
    //
    // When the consumer is not entitled to a free annual report
    //
    function getCreditReport(uint256 reqtime)
      public
      payable
      returns (bytes32)
    {
      require(Consumer.onlyConsumer(), "access denied for consumer");
      CreditInquiry.add(msg.sender, msg.sender, reqtime);
      return CreditReport.getConsumerReport(msg.sender);
    }

    function getInquiries()
      public
      payable
      returns (string memory)
    {
      require(Consumer.onlyConsumer(), "access denied for consumer");
      return CreditInquiry.getAll(msg.sender);
    }

    function finalizeDispute(address consumer,uint index,string memory status, bool purge)
      public
    {
      require(Subscriber.onlySubscriber(), "access denied for subscriber");
      /*
      Dispute memory dispute = Dispute(
        index,
        disputes[consumer][index].subscriber,
        disputes[consumer][index].consumer,
        disputes[consumer][index].disputeDate,
        disputes[consumer][index].item,
        disputes[consumer][index].reason,
        status
      );

      if (purge) {
        delete disputes[consumer][index];
      } else {
        disputes[consumer][index] = dispute;
      }
      */
      emit ConsumerNotified(consumer, "dispute finalized");
    }

    //
    // The contract owner will pull a list of disputes,
    // while iterating through each dispute,
    // convert the disputeDate from ISO string to an epoch timestamp and get current time in epoch timestamp,
    // check if the dispute is expired by more than 30 days from current time,
    // if dispute is expired, delete the dispute and notifiy consumer
    //
    function getDisputes(address consumer,bytes32 encrypted, bytes memory signature)
      public
      payable
      onlyOwner(encrypted,signature)
      returns (bytes32)
    {
      bytes32 output = "";
      /*
      for (uint i = 0; i < disputes[consumer].length; i++) {
        Dispute memory _dispute = Dispute(
          disputes[consumer][i].index,
          disputes[consumer][i].subscriber,
          disputes[consumer][i].consumer,
          disputes[consumer][i].disputeDate,
          disputes[consumer][i].item,
          disputes[consumer][i].reason,
          disputes[consumer][i].status
        );
        output = keccak256(
          abi.encodePacked(
            output,
            "[",
            _dispute.index,
            _dispute.subscriber,
            _dispute.consumer,
            _dispute.disputeDate,
            _dispute.reason,
            _dispute.status,
            "]"
          )
        );
      }
      */
      return output;
    }
}