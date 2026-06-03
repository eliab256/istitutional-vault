// SPDX-License-Identifier: MIT
pragma solidity ^0.8.35;
import {Proposal, Signer} from "./Types.sol";
import {Roles as R} from "./Roles.sol";

contract InstitutionalMultiSig {

    //mapping (uint256 => mapping (Proposal => bool)) public s_proposalSignatures;

    constructor() {

    }
    
    // @audit-issue capire come implementare access control
    function propose(address _target, bytes memory _data, uint256 _value) external  {
        // Create a new proposal and store it
    }

    function signProposal(uint256 _proposalId) external {
        // Sign the proposal with the sender's signature
    }
}
