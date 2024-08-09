// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script} from "forge-std/Script.sol";
import {MinAccount} from "src/ethereum/MinAccount.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";

contract DeployMinAccoung is Script {
    function run() public {}

    function deployMinAccount() public returns (HelperConfig, MinAccount) {
        HelperConfig helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory config = helperConfig.getConfig();

        vm.startBroadcast(config.account);
        MinAccount minAccount = new MinAccount(config.entryPoint);
        minAccount.transferOwnership(msg.sender);
        vm.stopBroadcast();

        return (helperConfig, minAccount);
    }
}
