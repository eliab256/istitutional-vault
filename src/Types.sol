//SPDX-License-Identifier: MIT
pragma solidity ^0.8.35;

/** 
 * @dev Struct compact on one single storage slot for KYC record, with the following fields:
 */
struct KYCRecord {
    bool approved;
    uint8 level;
    uint40 expiryTime;
}

struct Signer {
    bytes32 role;
    uint8 weight;
}

enum Role {
    BOARD,
    COMPLIANCE,
    OPERATIONS
}

struct Proposal {
    address target;
    bool executed;
    uint8 totalWeight;
    bytes data;
    uint256 value;
    uint256 nonce;
}