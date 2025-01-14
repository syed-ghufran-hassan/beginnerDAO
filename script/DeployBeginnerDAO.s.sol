// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {BeginnerDAO} from "../src/BeginnerDAO.sol";

contract DeployBeginnerDAO is Script {
    function run() external {
        uint256 deployerPrivateKey = <0xPrivatekey>;

        vm.startBroadcast(deployerPrivateKey); // Begin transaction broadcast

        BeginnerDAO dao = new BeginnerDAO();

        console.log("BeginnerDAO deployed at:", address(dao));

        vm.stopBroadcast(); // End transaction broadcast
    }
}
