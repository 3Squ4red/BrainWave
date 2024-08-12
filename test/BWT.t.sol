// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {USDT} from "./mock/TestUSDT.sol";
import "../src/BrainWave.sol";

contract BWTTest is Test {
    uint256 constant HUNDRED_USDT = 100e6;

    USDT usdt;
    BrainWave bwt;
    address ADMIN = makeAddr("ADMIN");
    address BUYER = makeAddr("BUYER");
    address BUYER2 = makeAddr("BUYER2");
    address SELLER = makeAddr("SELLER");

    function setUp() public {
        usdt = new USDT();
        bwt = new BrainWave(address(usdt), ADMIN);

        usdt.mint(BUYER, type(uint256).max/2);
        usdt.mint(BUYER2, type(uint256).max/2);
        
        vm.prank(BUYER);
        usdt.approve(address(bwt), type(uint256).max);
        
        vm.prank(BUYER2);
        usdt.approve(address(bwt), type(uint256).max);
    }

    function testPurchaseWithHundredUSDT1() public {
        vm.startPrank(BUYER);
        bwt.purchase(HUNDRED_USDT);

        assertEq(usdt.balanceOf(address(bwt)), HUNDRED_USDT);
        assertEq(bwt.totalSupply(), 80 ether);
        assertEq(bwt.price(), 125e4);
    }

    function testPurchaseWithHundredUSDT2() public {
        testPurchaseWithHundredUSDT1();
        vm.startPrank(BUYER2);
        bwt.purchase(HUNDRED_USDT);

        assertEq(usdt.balanceOf(address(bwt)), 2*HUNDRED_USDT);
        assertEq(bwt.totalSupply(), 144 ether);
        assertEq(bwt.price(), 138_8888);
    }

    // function testTransfer()
}
