// SPDX-License-Identifier: MIT
pragma solidity ^0.8.35;

library Roles {
    bytes32 public constant HSM_MULTISIG_ROLE = keccak256("HSM_MULTISIG_ROLE");
    bytes32 public constant MPC_SIGNER_ROLE = keccak256("MPC_SIGNER_ROLE");
    bytes32 public constant COMPLIANCE_OFFICER_ROLE = keccak256("COMPLIANCE_OFFICER_ROLE");
    bytes32 public constant REGULATOR_ROLE = keccak256("REGULATOR_ROLE");
    bytes32 public constant KYC_OPERATOR_ROLE = keccak256("KYC_OPERATOR_ROLE");
    bytes32 public constant CUSTODY_ADMIN_ROLE = keccak256("CUSTODY_ADMIN_ROLE");
}
