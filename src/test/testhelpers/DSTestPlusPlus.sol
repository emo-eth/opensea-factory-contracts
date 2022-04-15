// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

import {DSTestPlus} from "@rari-capital/solmate/src/test/utils/DSTestPlus.sol";
import {Vm} from "forge-std/Test.sol";

contract DSTestPlusPlus is DSTestPlus {
    Vm public constant vm = Vm(HEVM_ADDRESS);
}
