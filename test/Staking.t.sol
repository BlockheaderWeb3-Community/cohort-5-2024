// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {StakingContract} from "../src/Staking.sol";
import {ERC20} from "../src/ERC20.sol";

contract StakingContractTest is Test {
    StakingContract public stakingContract;
    struct StakeDetail {
        uint256 timeStaked;
        uint256 amount;
        bool status;
    }

    address ownerAddress = address(0x0101);
    address callingAddress = address(0x333);
    uint256 constant mintConst = 1000; 

    // Events
    event TokenStaked(address indexed staker, uint256 amount, uint256 time);
    event TokenWithdraw(address indexed staker, uint256 amount, uint256 time);

    ERC20 public bwcErc20TokenContract;
    ERC20 public receiptTokenContract;
    ERC20 public rewardTokenContract;

    address bwcTokenAddress;
    address receiptTokenAddress;
    address rewardTokenAddress;
    address stakingContractAddress;

    function setUp() public {
        bwcErc20TokenContract = new ERC20("BlockheaderWeb3 Token", "BWC", 0);
        receiptTokenContract = new ERC20("Receipt Token", "cBWC", 0);
        rewardTokenContract = new ERC20("Reward Token", "wBWC", 0);

        bwcTokenAddress = address(bwcErc20TokenContract);
        receiptTokenAddress = address(receiptTokenContract);
        rewardTokenAddress = address(rewardTokenContract);
        vm.prank(ownerAddress);
        stakingContract = new StakingContract(
            bwcTokenAddress,
            receiptTokenAddress,
            rewardTokenAddress
        );
        stakingContractAddress = address(stakingContract);
    }

    function test_StakingContractDeployment() public view {
        assertEq(stakingContract.bwcErc20TokenAddress(), bwcTokenAddress);
        assertEq(stakingContract.receiptTokenAddress(), receiptTokenAddress);
        assertEq(stakingContract.rewardTokenAddress(), rewardTokenAddress);
        assertEq(stakingContract.totalStaked(), 0);
    }

    function testRevert_StakeWillRevertifZeroAddress () public {
        vm.expectRevert("STAKE: Address zero not allowed");
        vm.startPrank(address(0));
        stakingContract.stake(200);
    }

    function testRevert_StakeWillRevertifAmountLessThanZero () public {
        vm.expectRevert("STAKE: Zero amount not allowed");
        stakingContract.stake(0);
    }

    function test_StakeSuccessful () public {
        uint256 callerStakingAmount = 200;
        // mint all needed toknens
        bwcErc20TokenContract.mint(callingAddress, mintConst);
        receiptTokenContract.mint(stakingContractAddress, mintConst );
        rewardTokenContract.mint(stakingContractAddress, mintConst);

        //check if they were minted succesfully
        assertEq(bwcErc20TokenContract.balanceOf(callingAddress), mintConst, "Balance is supposed to be 1000");
        assertEq(receiptTokenContract.balanceOf(stakingContractAddress), mintConst, "Balance is supposed to be 1000");

        // Verify that the stake detail has been updated
        (uint256 timeStaked, uint256 stakedAmount, bool status) = stakingContract.stakers(callingAddress);
        assertEq(stakedAmount, 0, "Stake amount not updated correctly");
        assertEq(status, false, "Status should be true");

        // start tstake transaction
        vm.warp(block.timestamp);
        vm.startPrank(callingAddress);
        bwcErc20TokenContract.approve(stakingContractAddress, callerStakingAmount);
        vm.expectEmit(true, false, false, false);
        emit TokenStaked(callingAddress, callerStakingAmount, block.timestamp);

        stakingContract.stake(callerStakingAmount);
        vm.stopPrank();

        // check weather all was done correctly
        assertEq(stakingContract.totalStaked(), callerStakingAmount, "Amount supposed to be 200");

        // Verify that the stake detail has been updated
        (timeStaked, stakedAmount, status) = stakingContract.stakers(callingAddress);
        assertEq(stakedAmount, callerStakingAmount, "Stake amount not updated correctly");
        assertEq(status, true, "Status should be true");
        assertGt(timeStaked, 0, "Time staked should be set");
        assertApproxEqRel(timeStaked, block.timestamp, 1, "Time staked is not close enough to block timestamp");
    }

    function testRevert_WithdrawWillRevertifZeroAddress () public {
        vm.expectRevert("WITHDRAW: Address zero not allowed");
        vm.startPrank(address(0));
        stakingContract.withdraw(200);
    }

    function testRevert_WithdrawWillRevertifAmountLessThanZero () public {
        vm.expectRevert("WITHDRAW: Zero amount not allowed");
        stakingContract.withdraw(0);
    }

    function testRevert_WithdrawWillRevertifStakeAmountGreaterThanWithdrawAmount () public {
        test_StakeSuccessful();
        vm.expectRevert("WITHDRAW: Withdraw amount not allowed");
        vm.prank(callingAddress);
        stakingContract.withdraw(700);
    }

    function testRevert_WithdrawWillRevertifStaakeTimeIsLessThanFourMins() public {
        test_StakeSuccessful();
        (uint256 timeStaked, uint256 stakedAmount, bool status) = stakingContract.stakers(callingAddress);
        vm.expectRevert("WITHDRAW: Not yet time to withdraw");
        vm.warp(timeStaked + 5 seconds);
        vm.prank(callingAddress);
        stakingContract.withdraw(200);
    }

    function test_WithdrawSuccesfully() public {
        test_StakeSuccessful();

        (uint256 timeStaked, uint256 stakedAmount, bool status) = stakingContract.stakers(callingAddress);

        vm.startPrank(callingAddress);
        receiptTokenContract.approve(stakingContractAddress, 1000);
        vm.stopPrank();

        vm.expectEmit(true, true, true, false);
        emit TokenWithdraw(callingAddress, 400, timeStaked + 5 days);

        vm.warp(timeStaked + 5 days);
        vm.prank(callingAddress);
        stakingContract.withdraw(200);

        ( timeStaked,  stakedAmount,  status) = stakingContract.stakers(callingAddress);
        assertEq(stakedAmount, 0, "Amount Supposed to be 0");
    }

}
