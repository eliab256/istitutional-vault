// SPDX-License-Identifier: MIT
pragma solidity ^0.8.35;
import {UUPSUpgradeable} from "@openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol";
import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import {Roles as R} from "./Roles.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract CustodyCore is AccessControlUpgradeable, UUPSUpgradeable {

    function initialize() public initializer {
        __AccessControl_init();
        __UUPSUpgradeable_init();

        _grantRole(R.CUSTODY_ADMIN_ROLE, msg.sender);
    }

    function createAccount(address _clientAddress) external onlyRole(R.CUSTODY_ADMIN_ROLE) {
        // check if clientAddress is compliant

    }

    function deposit(uint256 _accountId, address _token, uint256 _amount) external {

    }

    function withdraw(uint256 _accountId, address _token, uint256 _amount, address _to) external {

    }

}
