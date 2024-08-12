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

        usdt.mint(BUYER, type(uint256).max / 2);
        usdt.mint(BUYER2, type(uint256).max / 2);

        vm.prank(BUYER);
        usdt.approve(address(bwt), type(uint256).max);

        vm.prank(BUYER2);
        usdt.approve(address(bwt), type(uint256).max);
    }

    function purchaseBWT(address purchaser, uint amt) private {
        vm.prank(purchaser);
        bwt.purchase(amt);
    }

    function testTransfer() public {
        purchaseBWT(BUYER, 300e6);
        assertEq(bwt.totalSupply(), 240 ether); // 20% burns

        assert(bwt.balanceOf(BUYER) == 120 ether);
        assert(bwt.balanceOf(BUYER2) == 0);

        vm.prank(BUYER);
        bwt.transfer(BUYER2, 100 ether);

        assert(bwt.balanceOf(BUYER2) == 80 ether);
        assertEq(bwt.totalSupply(), 220 ether);  // total supply got reduced by 20% of the transfer amount
    }

    function testPurchaseWithHundredUSDT1() public {
        purchaseBWT(BUYER, 100e6);

        assertEq(bwt.balanceOf(BUYER), 40 ether);
        assertEq(usdt.balanceOf(address(bwt)), HUNDRED_USDT);
        assertEq(bwt.totalSupply(), 80 ether);
        assertEq(bwt.price(), 125e4);
    }

    function testPurchaseWithHundredUSDT2() public {
        testPurchaseWithHundredUSDT1();
        purchaseBWT(BUYER2, 100e6);

        assertEq(bwt.balanceOf(BUYER2), 32 ether);
        assertEq(usdt.balanceOf(address(bwt)), 2 * HUNDRED_USDT);
        assertEq(bwt.totalSupply(), 144 ether);
        assertEq(bwt.price(), 138_8888);
    }

    // function testTransfer()
}
