// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

import "../../common/Version.sol";
import "../../common/Owned.sol";
import "./Consumer.sol";
import "./Subscriber.sol";
import "./CreditInquiry.sol";
import "./CreditReport.sol";
import "./CreditDispute.sol";

contract CreditReportAgency is Version, Owned {
    bytes32 constant private ZERO_BYTES = bytes32(0);
    address constant private ZERO_ADDRESS = address(0);

    uint256 constant public YEAR = 52 weeks;
    uint256 constant public THIRTY_DAYS = 30 days;
    uint256 constant public NINETY_DAYS = 90 days;

    uint total_consumers;

    mapping (address => uint256) public balances;
    mapping (address => bytes32[]) message;
    mapping (address => bool) optout;

    event SubscriberAdded(address addr, string message);
    event SubscriberNotified(address addr, string message);
    event ConsumerNotified(address addr, string message, bytes data);

    event Received(address addr, uint value);

    event MessageConsumer(address addr,string message);

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

    fallback() external payable {
        emit Received(msg.sender,msg.value);
    }
    
    receive() external payable {
        emit Received(msg.sender,msg.value);
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

      if (consumer_lastreq == 0 || (consumer_lastreq + YEAR) > reqtime || (subscriber_lastreq + NINETY_DAYS) < reqtime) {
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

    //
    // The disputeDate is in ISO and must be converted to epoch timestamp before checking current time
    // The currentTime is epoch timestamp provided by the caller
    //
    function checkExpiry(uint256 LastTimeStamp, uint256 currentTime)
      public
      pure
      returns(bool)
    {
      if (LastTimeStamp + THIRTY_DAYS >= currentTime) {
        return true;
      } else {
        return false;
      }
    }

    //
    // adds a new subscriber
    //
    function addSubscriber(uint256 _type)
      public
      validSender
      requiresFee(0.001 ether)
    {
      require(_type <= 1,"incorrect subscriber type? 0=creditor,1=collector, DONT MISREPRESENT!");
      payable(address(this)).transfer(0.001 ether);
      balances[address(this)] += 0.001 ether;
      if (Subscriber.addSubscriber(msg.sender, _type)) {
        emit SubscriberAdded(msg.sender, "subscriber added");
      }
    }

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
    function openDispute(address consumer, address subscriber, uint index,
                        string memory disputeDate,string memory reason,
                        bytes32 encrypted, bytes memory signature)
      public
      onlyOwner(encrypted,signature)
    {
      CreditDispute.openDispute(consumer, subscriber,CreditReport.getConsumerReportItem(consumer,index),disputeDate,reason);
      bytes32 dispute = keccak256(
          abi.encodePacked(
            "Dispute Opened:",
            index,
            subscriber,
            consumer,
            disputeDate,
            reason
          )
        );

      message[subscriber].push(dispute);
      emit SubscriberNotified(subscriber, "new dispute opened");
    }

    //
    // adds an item to the consumer report by an existing subscriber, must contain the minimum:
    //    subscriber, open date, amount, description, balance, limit, payment status
    //
    function addConsumerItem(address consumer, bytes memory item)
      public
      requiresFee(0.001 ether)
    {
      require(consumer != ZERO_ADDRESS,"missing address");
      require(Subscriber.onlySubscriber(), "access denied for subscriber");
      // pays half the fee to the contract
      payable(address(this)).transfer(0.0005 ether);
      balances[address(this)] += 0.0005 ether;
      // pays half the fee to the consumer
      payable(consumer).transfer(0.0005 ether);
      balances[consumer] += 0.0005 ether;
      // add consumer, if not exist?
      Consumer.addConsumer(consumer);
      CreditReport.addConsumerItem(consumer, item);
      emit ConsumerNotified(consumer, "new item was added to your report", item);
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
      bytes memory item = CreditDispute.getDisputeItem(consumer,index);
      CreditDispute.purgeDispute(consumer,index);
      emit ConsumerNotified(consumer, "dispute deleted", item);
    }

    //
    // retrieves consumer report by a subscriber, half the fee is paid to the owner, and half paid to the consumer
    //
    function getConsumerReport(address consumer, uint reqtime)
      public
      payable
      requiresFee(0.001 ether)
      returns (bytes32)
    {
      require(Subscriber.onlySubscriber(), "access denied, only for subscribers");
      //to.transfer(0.001 ether);
      // pays half the fee to the contract
      payable(address(this)).transfer(0.0005 ether);
      balances[address(this)] += 0.0005 ether;
      // pays half the fee to the consumer
      payable(consumer).transfer(0.0005 ether);
      balances[consumer] += 0.0005 ether;

      CreditInquiry.add(consumer,msg.sender,reqtime);
      return CreditReport.getConsumerReport(consumer);
    }

    // Consumer previlieges
    //
    // retrieves consumer report for the consumer by the owner so the consumer does not incur gas fees.
    // to abide by law and allow free credit report to the consumer, cannot change the state on the contract,
    // otherwise the method must pay gas fee. By not recording consumer self requests in the contract, keeps
    // this function free.
    //
    //  No gas feesm because when a consumer requests their report, no record is made on the blockchain, hence
    // no gas fees
    function getCreditReport()
      public
      view
      returns (bytes32)
    {
      require(Consumer.onlyConsumer(), "access denied for consumer");
      return CreditReport.getConsumerReport(msg.sender);
    }

    function getInquiries()
      public
      view
      returns (string memory)
    {
      require(Consumer.onlyConsumer(), "access denied for consumer");
      return CreditInquiry.getAll(msg.sender);
    }

    function finalizeDispute(address consumer,uint index,string memory status, bool purge)
      public
      payable
      requiresFee(0.001 ether)
    {
      require(Subscriber.onlySubscriber(), "access denied for subscriber");
      // pays half the fee to the contract
      payable(address(this)).transfer(0.0005 ether);
      balances[address(this)] += 0.0005 ether;
      // pays half the fee to the consumer
      payable(consumer).transfer(0.0005 ether);
      balances[consumer] += 0.0005 ether;
      CreditDispute.finalizeDispute(consumer,index,status,purge);
      bytes memory item = CreditDispute.getDisputeItem(consumer,index);
      emit ConsumerNotified(consumer, "dispute finalized", item);
    }

    //
    // The contract owner will pull a list of disputes,
    // while iterating through each dispute,
    // convert the disputeDate from ISO string to an epoch timestamp and get current time in epoch timestamp,
    // check if the dispute is expired by more than 30 days from current time,
    // if dispute is expired, delete the dispute and notifiy consumer
    //
    function getDisputes()
      public
      view
      returns (bytes32)
    {
      require(Consumer.onlyConsumer(), "access denied for consumer");
      return CreditDispute.getDisputes(msg.sender);
    }

    function consumerOptsOut(address consumer, bool status, bytes32 encrypted, bytes memory signature)
      public
      onlyOwner(encrypted,signature)
    {
      optout[consumer] = status;
    }

    /**
     * Permits third party marketers to send messages to consumers via the connected DAPP for a fee paid to a verified consumer.
     * Consumer has option to opt-out, if they choose to receive communication, they can now get paid for each message received.
     *
     * Since no Personal Identifying Information (PII) is linked to the wallet on the public chain, there is no matching demographics and
     * just plain blind advertising which is most email campaigns.
     */
    function sendConsumerMessage(address consumer, string memory _message)
      public
      payable
      validSender
      requiresFee(0.0001 ether)
    {
      require(optout[consumer] == false,"consumer has opted-out to received any external messages or communication");
      require(consumer != ZERO_ADDRESS,"invalid consumer address");
      payable(consumer).transfer(0.0001 ether);

      bytes32 bmessage = keccak256(abi.encodePacked(_message));
      message[consumer].push(bmessage);      
      emit MessageConsumer(consumer, _message);
    }

    /**
     * A marketer can buy the consumer list of wallet addresses. No PII is attached and no demographics.
     * Though a marketer can query the blockchain for matching transactions and develop their own demographics?
     * The next analytic metric?
     */
    function getConsumerList()
      public
      payable
      validSender
      requiresFee(0.001 ether)
      returns (address[] memory)
    {
      payable(address(this)).transfer(0.001 ether);
      return Consumer.getConsumers();
    }
}