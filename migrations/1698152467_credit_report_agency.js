const Contract = artifacts.require("CreditReportAgency")
const Consumer = artifacts.require("Consumer")
const CreditDispute = artifacts.require("CreditDispute")
const CreditInquiry = artifacts.require("CreditInquiry")
const CreditReport = artifacts.require("CreditReport")
const Subscriber= artifacts.require("Subscriber")

module.exports = function(_deployer) {
  // Use deployer to state migration tasks.
  _deployer.deploy(Consumer)
  _deployer.deploy(CreditDispute)
  _deployer.deploy(CreditInquiry)
  _deployer.deploy(CreditReport)
  _deployer.deploy(Subscriber)
  _deployer.link(Consumer,Contract)
  _deployer.link(CreditDispute,Contract)
  _deployer.link(CreditInquiry,Contract)
  _deployer.link(CreditReport,Contract)
  _deployer.link(Subscriber,Contract)
  _deployer.deploy(Contract)
};
