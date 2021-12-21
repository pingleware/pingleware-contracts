// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

import "../Version.sol";

contract CreditReport is Version {
  bytes32 constant private ZERO_BYTES = bytes32(0);
  address constant private ZERO_ADDRESS = address(0);

  struct Item {
    string opendate;
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

  struct Inquiry {
    address subscriber;
    uint256 reqdate; // epoch timestamp
  }

  struct Dispute {
    uint index;
    address subscriber;
    address consumer;
    string  disputeDate;
    ReportItem item;
    string reason;
    string status;
  }

  mapping(address => ReportItem[]) private reports;
  mapping(address => uint256) private subscribers;

  mapping(address => uint256) private consumers;
  mapping(address => Inquiry[]) private inquiries;
  mapping(address => Dispute[]) private disputes;

  address[] private _subscribers;
  address[] private _consumers;

  uint total_consumers;

  mapping (address => bytes32[]) message;

  mapping (bytes => address) private _owner;

  address private owner;
  bool private initialized;

  event SubscriberAdded(address addr, string message);
  event SubscriberNotified(address addr, string message);
  event ConsumerNotified(address addr, string message);

  constructor()
  {
    owner = msg.sender;
    initialized = true;
    total_consumers = 0;
  }

  // Modifiers
  modifier onlyOwner() {
    require(msg.sender == owner, "access denied for owner");
    _;
  }

  modifier isOwner(address addr) {
    require(addr == owner, "not the owner");
    _;
  }

  modifier validSender() {
    require(msg.sender != ZERO_ADDRESS,"access denied for sender");
    _;
  }

  modifier onlySubscriber() {
    require(subscribers[msg.sender] != 0, "access denied for subscriber");
    _;
  }

  modifier onlyConsumer() {
    require(consumers[msg.sender] != 0, "access denied for consumer");
    _;
  }

  modifier alreadySubscriber(address addr) {
    bool found = false;
    for (uint i = 0; i < _subscribers.length; i++) {
      if (_subscribers[i] == addr) {
        found = true;
      }
    }
    require(found == false, "user is already a subscriber");
    _;
  }

  modifier alreadyConsumer(address addr) {
    bool found = false;
    for (uint i = 0; i < _consumers.length; i++) {
      if (_consumers[i] == addr) {
        found = true;
      }
    }
    require(found == false, "user is already a consumer");
    _;
  }

  /**
   * A consumer is entitled
   */
  modifier freeReportCheck(address consumer, address subscriber, uint256 reqtime) {
    bool found = false;
    uint256 subscriber_lastreq = reqtime;
    for (uint i = inquiries[consumer].length; i > 0; i--) {
      if (!found && subscribers[inquiries[consumer][i].subscriber] != 0) {
          subscriber_lastreq = inquiries[consumer][i].reqdate;
          found = true;
      }
    }

    uint consumer_total = inquiries[consumer].length - 1;
    uint256 consumer_lastreq = inquiries[consumer][consumer_total].reqdate;
    require(
      consumer_lastreq == 0 || (consumer_lastreq + 52 weeks) > reqtime || (subscriber_lastreq + 90 days) < reqtime,
     "not eligible for a free report");
     _;
  }

  modifier requiresFee(uint fee) {
    require(msg.sender.balance > fee, "insufficient balance/amount");
    _;
  }

  // Common privleges
  /**
   * retrieves the owner
   */
  function getOwner()
    public
    view
    returns (address addr)
  {
    return owner;
  }

  function getUserRole()
    public
    view
    validSender
    returns (string memory)
  {
    if (msg.sender == owner) {
      return string("owner");
    } else if (subscribers[msg.sender] != 0) {
      return string("subscriber");
    } else if (consumers[msg.sender] != 0) {
      return string("consumer");
    }
    return string("unknown");
  }

  function getConsumerReportTotal(address consumer)
    public
    view
    returns (uint)
  {
    return _reportItemsTotal(consumer);
  }

  function getConsumerReportItem(address consumer,uint index)
    public
    view
    returns (bytes memory)
  {
    return _reportItem(consumer, index);
  }

  function getBlocktime()
    public
    view
    returns (uint256)
  {
    return block.timestamp;
  }

  /**
   * The disputeDate is in ISO and must be converted to epoch timestamp before checking current time
   * The currentTime is epoch timestamp provided by the caller
   */
  function checkExpiry(uint256 LastTimeStamp, uint256 currentTime)
   public
   pure
   returns(bool success)
  {
    if (LastTimeStamp + 30 days >= currentTime) {
      return true;
    } else {
      return false;
    }
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

  // Owner-Administrator privileges
  function getSubscribers()
  public
  view
  onlyOwner
  returns (address[] memory)
  {
    return _subscribers;
  }

  function getConsumers()
  public
  view
  onlyOwner
  returns (address[] memory)
  {
    return _consumers;
  }

  /**
   * retrieves consumer report for the consumer by the owner so the consumer does not incur gas fees.
   * to abide by law and allow free credit report to the consumer, cannot change the state on the contract,
   * otherwise the method must pay gas fee. By not recording consumer self requests in the contract, keeps
   * this function free.
   */
  function getFreeCreditReport(address consumer, address subscriber, uint256 reqtime)
    public
    payable
    onlyOwner
    freeReportCheck(consumer, subscriber, reqtime)
    returns (bytes32)
  {
    Inquiry memory inquiry = Inquiry(consumer, reqtime);
    inquiries[consumer].push(inquiry);
    return _report(consumer);
  }

  /**
   * because open dispute changes the state of the contract, gas fees applies,
   * hence the consumer must start a dispute offline, and send to the owner to create a dispute and the owner pays the gas fee
   */
  function openDispute(address consumer, uint index, string memory disputeDate,string memory reason)
    public
    onlyOwner
  {
    ReportItem memory report = ReportItem(reports[consumer][index].subscriber,reports[consumer][index].item);
    Dispute memory dispute = Dispute(index, report.subscriber, consumer, disputeDate, report, reason, "");
    disputes[consumer].push(dispute);
    message[report.subscriber].push(
      keccak256(
        abi.encodePacked(
          "Dispute Opened:",
          index,
          report.subscriber,
          consumer,
          disputeDate,
          report.item,
          reason
        )
      )
    );
    emit SubscriberNotified(report.subscriber, "new dispute opened");
  }

  function getReportsByConsumer(address consumer)
    public
    view
    onlyOwner
    returns (bytes32)
  {
    return _report(consumer);
  }

  function purgeDispute(address consumer, uint index)
    public
    onlyOwner
  {
    delete disputes[consumer][index];
    emit ConsumerNotified(consumer, "dispute deleted");
  }

  // Subscriber privileges
  /**
   * adds a new subscriber
   */
  function addSubscriber(address addr, uint256 _type)
  public
  onlyOwner
  alreadySubscriber(addr)
  {
    require(addr != ZERO_ADDRESS,"missing address");
    subscribers[addr] = _type;
    _subscribers.push(addr);
    emit SubscriberAdded(addr, "subscriber added");
  }

  /**
   * adds an item to the consumer report by an existing subscriber, must contain the minimum:
   *    subscriber, open date, amount, description, balance, limit, payment status
   */
  function addConsumerItem(address consumer, bytes memory item)
    public
    onlySubscriber
  {
    require(consumer != ZERO_ADDRESS,"missing address");
    if (consumers[consumer] == 0) {
      consumers[consumer] = 1;
      _consumers.push(consumer);
      total_consumers++;
    }
    ReportItem memory ritem = ReportItem(msg.sender, item);
    reports[consumer].push(ritem);
    emit ConsumerNotified(consumer, "new item was added to your report");
  }

  /**
   * retrieves consumer report by a subscriber, fee is paid to the owner
   */
  function getConsumerReport(address consumer, uint reqtime, address payable to)
    public
    payable
    onlySubscriber
    isOwner(to)
    requiresFee(0.001 ether)
    returns (bytes32)
  {
    //to.transfer(0.001 ether);
    Inquiry memory inquiry = Inquiry(msg.sender, reqtime);
    inquiries[consumer].push(inquiry);
    return _report(consumer);
  }

  function finalizeDispute(address consumer,uint index,string memory status, bool purge)
    public
    onlySubscriber
  {
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
    emit ConsumerNotified(consumer, "dispute finalized");
  }

  // Consumer previlieges
  /**
   * When the consumer is not entitled to a free annual report
   */
  function getCreditReport(uint256 reqtime)
    public
    payable
    onlyConsumer
    returns (bytes32)
  {
    Inquiry memory inquiry = Inquiry(msg.sender, reqtime);
    inquiries[msg.sender].push(inquiry);
    return _report(msg.sender);
  }

  function getInquiries()
    public
    view
    onlyConsumer
    returns (string memory)
  {
    string memory output = "";
    for (uint i = 0; i < inquiries[msg.sender].length; i++) {
      output = string(
        abi.encodePacked(
          output,
          inquiries[msg.sender][i].subscriber,
          inquiries[msg.sender][i].reqdate
        )
      );
    }
    return output;
  }

  /**
   * The contract owner will pull a list of disputes,
   * while iterating through each dispute,
   * convert the disputeDate from ISO string to an epoch timestamp and get current time in epoch timestamp,
   * check if the dispute is expired by more than 30 days from current time,
   * if dispute is expired, delete the dispute and notifiy consumer
   */
  function getDisputes(address consumer)
    public
    view
    onlyOwner
    returns (bytes32)
  {
    bytes32 output = "";
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
    return output;
  }

  // Internal privileges
  function _report(address consumer)
    internal
    view
    returns (bytes32)
  {
    bytes32 output;
    for (uint i = 0; i < reports[consumer].length; i++) {
      output = keccak256(abi.encodePacked(
        output, "[",
          reports[consumer][i].subscriber, ",",
          reports[consumer][i].item, ",",
        "]"
      ));
    }
    return output;
  }

  function _reportItem(address consumer, uint index)
    internal
    view
    returns (bytes memory)
  {
    return reports[consumer][index].item;
  }

  function _reportItemsTotal(address consumer)
    internal
    view
    returns (uint)
  {
    return reports[consumer].length;
  }
}
