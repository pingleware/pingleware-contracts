// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

library CreditInquiry {
    struct InquiryItem {
        address subscriber;
        uint256 reqdate; // epoch timestamp
    }

    struct CreditInquiryStorage {
        mapping(address => InquiryItem[]) inquiries;
    }

    function creditInquiryStorage() internal pure returns (CreditInquiryStorage storage ds)
    {
        bytes32 position = keccak256("inquiry.storage");
        assembly { ds.slot := position }
    }

    function add(address _consumer, address subscriber, uint256 reqtime)
        external
    {
        creditInquiryStorage().inquiries[_consumer].push(InquiryItem(subscriber, reqtime));
    }

    function getAll(address _consumer)
        internal
        view
        returns (string memory)
    {
      string memory output = "";
      for (uint i = 0; i < creditInquiryStorage().inquiries[_consumer].length; i++) {
        output = string(
          abi.encodePacked(
            output,
            creditInquiryStorage().inquiries[_consumer][i].subscriber,
            creditInquiryStorage().inquiries[_consumer][i].reqdate
          )
        );
      }
      return output;
    }
}