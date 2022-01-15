// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

/**
 * Sec. 203.36 Fulfillment houses, shipping and mailing services, comarketing agreements, and third-party recordkeeping.
 *
 * (a) Responsibility for creating and maintaining forms, reports, and records. Any manufacturer or authorized distributor of record that uses a fulfillment house,
 * shipping or mailing service, or other third party, or engages in a comarketing agreement with another manufacturer or distributor to distribute drug samples or
 * to meet any of the requirements of PDMA, PDA, or this part, remains responsible for creating and maintaining all requests, receipts, forms, reports,
 * and records required under PDMA, PDA, and this part.
 *
 * (b) Responsibility for producing requested forms, reports, or records. A manufacturer or authorized distributor of record that contracts with a third party
 * to maintain some or all of its records shall produce requested forms, reports, records, or other required documents within 2 business days of a request
 * by an authorized representative of FDA or another Federal, State, or local regulatory or law enforcement official.
 */

library SampleGuardian {
    bytes32 constant private ZERO_BYTES = bytes32(0);
    address constant private ZERO_ADDRESS = address(0);

    struct LicensedPractitioner {
        string  dea_number;
        string  state_license;
        string  name;
        string  mailing_address;
        string  title;
    }

    struct DrugItem {
        string  control_number;
        string  manufacturer;
        string  name;
        string  strength;
    }

    struct DrugItemRequest {
        LicensedPractitioner practitioner;
        DrugItem drug;
        uint quantity;
        uint256 epoch; // date of the request
        bytes   signature;
    }

    struct Receipt {
        DrugItemRequest request; // a request block
        string deliveryAddress; // if not at the practitioner address
        uint256 deliveryDate;
        bytes  signaturePractitioner;
    }

    struct SampleGuardianStorage {
        mapping (address => LicensedPractitioner) practitioners;
        mapping (address => DrugItemRequest[]) drug_samples;
        mapping (address => Receipt) receipts;
        address[] _practitioners;
        DrugItem[] _drugs;
    }


    function sampleGuardianStorage() internal pure returns (SampleGuardianStorage storage ds)
    {
        bytes32 position = keccak256("sampleguardian.storage");
        assembly { ds.slot := position }
    }


    function isPractitioner()
        public
        view
        returns (bool)
    {
        bool found = false;
        for(uint i = 0; i < sampleGuardianStorage()._practitioners.length; i++) {
            if (sampleGuardianStorage()._practitioners[i] != ZERO_ADDRESS) {
                found = true;
            }
        }
        return found;
    }

    function notPractitioner()
        public
        view
        returns (bool)
    {
        bool found = false;
        for(uint i = 0; i < sampleGuardianStorage()._practitioners.length; i++) {
            if (sampleGuardianStorage()._practitioners[i] != ZERO_ADDRESS) {
                found = true;
            }
        }
        return found;
    }

    function addPractitioner(string memory dea_number, string memory state_license,string memory name,string memory mailing_address,string memory title)
        public
    {
        LicensedPractitioner memory practitioner = LicensedPractitioner(dea_number,state_license,name,mailing_address,title);
        sampleGuardianStorage().practitioners[msg.sender] = practitioner;
        sampleGuardianStorage()._practitioners.push(msg.sender);
    }

    function newDrug(string memory control_number,string memory manufacturer,string memory name,string memory strength)
        public
    {
        DrugItem memory item = DrugItem(control_number,manufacturer,name,strength);
        sampleGuardianStorage()._drugs.push(item);
    }

    function newSampleRequest(DrugItem calldata drug, address practitioner, uint256 dateOfRequest, uint quantity, bytes memory signature)
        public
    {
        LicensedPractitioner memory _practitioner = sampleGuardianStorage().practitioners[practitioner];
        DrugItemRequest memory sample = DrugItemRequest(_practitioner, drug, quantity, dateOfRequest,signature);
        sampleGuardianStorage().drug_samples[practitioner].push(sample);
    }

    function newReceipt(address practitioner, DrugItemRequest calldata sample, string memory deliveryAddress, uint256 deliveryDate, bytes memory signature)
        public
    {
        Receipt memory receipt = Receipt(sample,deliveryAddress,deliveryDate,signature);
        sampleGuardianStorage().receipts[practitioner] = receipt;
    }

    function getPractitioners()
        public
        view
        returns (address[] memory)
    {
        return sampleGuardianStorage()._practitioners;
    }

    function getDrugItemList()
        public
        view
        returns (DrugItem[] memory)
    {
        return sampleGuardianStorage()._drugs;
    }
}