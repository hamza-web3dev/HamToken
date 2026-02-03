// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {HamToken} from "../src/HamToken.sol";
import {Script} from "forge-std/Script.sol";

contract DeployHamToken is Script {
    uint256 constant INITIAL_SUPPLY = 1000000 ether;

    function run() external returns (HamToken) {
        vm.startBroadcast();
        HamToken htk = new HamToken(INITIAL_SUPPLY);
        vm.stopBroadcast();

        return htk;
    }
}
