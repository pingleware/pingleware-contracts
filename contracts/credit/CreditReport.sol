// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

library CreditReport {
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

    struct CreditReportStorage {
      mapping(address => ReportItem[]) reports;
    }

    function creditReportStorage() internal pure returns (CreditReportStorage storage ds)
    {
        bytes32 position = keccak256("creditreport.storage");
        assembly { ds.slot := position }
    }

    function addConsumerItem(address consumer, bytes memory item)
        internal
    {
        require(consumer != ZERO_ADDRESS,"missing address");
        creditReportStorage().reports[consumer].push(ReportItem(msg.sender, item));
    }

    function getConsumerReportTotal(address consumer)
        external
        view
        returns (uint)
    {
        return creditReportStorage().reports[consumer].length;
    }

    function getConsumerReportItem(address consumer,uint index)
        public
        view
        returns (bytes memory)
    {
        return creditReportStorage().reports[consumer][index].item;
    }

    function getReportItem(address subscriber, bytes memory item)
        internal
        pure
        returns (ReportItem memory)
    {
        return ReportItem(subscriber,item);
    }

    function getConsumerReport(address consumer)
        internal
        view
        returns (bytes32)
    {
        return _report(consumer);
    }

    function _report(address consumer)
        internal
        view
        returns (bytes32)
    {
        bytes32 output;
        for (uint i = 0; i < creditReportStorage().reports[consumer].length; i++) {
            output = keccak256(abi.encodePacked(
                output, "[",
                creditReportStorage().reports[consumer][i].subscriber, ",",
                creditReportStorage().reports[consumer][i].item, ",",
                "]"
            ));
        }
        return output;
    }

}