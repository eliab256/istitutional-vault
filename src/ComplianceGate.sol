// SPDX-License-Identifier: MIT
pragma solidity ^0.8.35;
import { Roles as R} from "./Roles.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {KYCRecord} from "./Types.sol";

contract ComplianceGate is AccessControl {
    event AddressFrozen(address indexed addr, bytes reason);
    event AddressUnfrozen(address indexed addr);
    event FundsFrozen(address indexed owner, address indexed token, uint256 amount, bytes reason);
    event FundsUnfrozen(address indexed owner, address indexed token, uint256 amount);
    event AddressApproved(address indexed addr, uint8 level, uint40 expiryTime);
    event AddressRevoked(address indexed addr);

    error ComplianceGate__WalletAlreadyFrozen(address addr);
    error ComplianceGate__WalletNotFrozen(address addr);
    error ComplianceGate__AddressNotApproved(address addr);
    error ComplianceGate__AddressExpired(address addr);

    address internal immutable i_custodyCore;

    /// @dev Wallet freeze status
    mapping(address => bool) internal s_frozenAddresses;

    /// @dev TokenAmount freeze status mapping: owner => token => frozen value
    mapping(address => mapping(address => uint256)) internal s_frozenValues;

    /// @dev KYC records mapping
    mapping(address => KYCRecord) internal s_kycRecords;

    modifier onlyCompliant(address _address){
        _onlyCompliant(_address);
        _;
    }

    constructor(address _custodyCore) {
        i_custodyCore = _custodyCore;
    }

    // @audit-info check gestione level
    function approvedAddress(
        address _address, 
        uint8 _level, 
        uint40 _expiryTime
        ) external view onlyRole(R.KYC_OPERATOR_ROLE, R.MPC_SIGNER_ROLE) returns (bool) {
        s_kycRecords[_address] = KYCRecord({
            approved: true,
            level: _level,
            expiryTime: _expiryTime
        });

        emit AddressApproved(_address, _level, _expiryTime);
    }

    function revokeAddress(address _address) external onlyRole(R.COMPLIANCE_OFFICER_ROLE) {
        delete s_kycRecords[_address];

        emit AddressRevoked(_address);
    }

    function freezeAddress(address _addr, bytes memory _reason) external onlyRole(R.REGULATOR_ROLE) {
        if(s_frozenAddresses[_addr]) {
            revert ComplianceGate__WalletAlreadyFrozen(_addr);
        }
        s_frozenAddresses[_addr] = true;

        emit AddressFrozen(_addr, _reason);
    }

    function unfreezeAddress(address _addr) external onlyRole(R.HSM_MULTISIG_ROLE) {
        if(!s_frozenAddresses[_addr]) {
            revert ComplianceGate__WalletNotFrozen(_addr);
        }
        s_frozenAddresses[_addr] = false;

        emit AddressUnfrozen(_addr);
    }

    function freezeFunds(address _owner, address _token, uint256 _amount, bytes memory _reason) external onlyRole(R.REGULATOR_ROLE) {
        if(_token == address(0)) {
            // Freeze native currency
        } else {
            IERC20 token = IERC20(_token);

            // Check amount <= unfreezeable balance
            // Freeze ERC20 tokens
        }
    }

    function unfreezeFunds(address _owner, address _token, uint256 _amount) external onlyRole(R.REGULATOR_ROLE) {
        if(_token == address(0)) {
            // Unfreeze native currency
        } else {
            // Check amount <= frozen balance
            // Unfreeze ERC20 tokens
        }
    }

    function _onlyCompliant(address _address) internal view {
        // Check if the address is compliant based on KYC records
    }

    function isCompliant(address _address) external view returns (bool) {
        // Return true if the address is compliant, false otherwise
    }
}
