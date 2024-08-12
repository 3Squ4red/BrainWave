// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {BrainWave} from "../src/BrainWave.sol";

contract CounterScript is Script {
    address constant USDT_SEPOLIA = 0xaA8E23Fb1079EA71e0a56F48a2aA51851D8433D0;
    address constant ADMIN = 0xD1B9C015FBA1D7B631791A2201411a378fd562e7;

    function run() external returns (address bwt) {
        vm.startBroadcast();
        bwt = address(new BrainWave(USDT_SEPOLIA, ADMIN));
        vm.stopBroadcast();
    }
}
