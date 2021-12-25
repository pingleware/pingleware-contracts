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

    uint256 private subscriber_lastreq = 0;
    uint256 private consumer_total = 0;
    uint256 private consumer_lastreq = 0;


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
    function freeReportCheck(address consumer, address subscriber, uint256 reqtime)
      internal
      returns(bool)
    {
      bool found = false;
      subscriber_lastreq = reqtime;

      for (uint i = CreditInquiry.getTotalInquiry(consumer); i > 0; i--) {
        if (!found && (CreditInquiry.getInquiryofSubscriber(consumer,i) == subscriber)) {
            subscriber_lastreq = CreditInquiry.getInquiryofReqDate(consumer,i);
            found = true;
        }
      }

      consumer_total = CreditInquiry.getTotalInquiry(consumer) - 1;
      consumer_lastreq = CreditInquiry.getInquiryofReqDate(consumer,consumer_total);

      if (consumer_lastreq == 0 || (consumer_lastreq + 52 weeks) > reqtime || (subscriber_lastreq + 90 days) < reqtime) {
        return true;
      }
      return false;
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
      returns (bytes32)
    {
      require(freeReportCheck(_consumer, subscriber, reqtime), "not eligible for a free consumer report");

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
      message[subscriber].push(
        keccak256(
          abi.encodePacked(
            "Dispute Opened:",
            index,
            subscriber,
            consumer,
            disputeDate,
            reason
          )
        )
      );
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
      // add consumer, if not exist?
      Consumer.addConsumer(consumer);
      CreditReport.addConsumerItem(consumer, item);
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
      CreditDispute.finalizeDispute(consumer,index,status,purge);
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
      return CreditDispute.getDisputes(consumer);
    }
}