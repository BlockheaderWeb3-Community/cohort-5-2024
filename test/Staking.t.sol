// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import "forge-std/console.sol";
import {StakingContract} from "../src/Staking.sol";
import {ERC20} from "../src/ERC20.sol";

contract StakingContractTest is Test {
    StakingContract public stakingContract;

    ERC20 public bwcErc20TokenContract;
    ERC20 public receiptTokenContract;
    ERC20 public rewardTokenContract;
    address public user = address(0x1);
    address public user1 = address(0x21);
    uint256 public constant INITIAL_BALANCE = 10000e18;
    uint256 public stakingAmount = 100e18;
    uint256 constant MIN_TIME_BEFORE_WITHDRAW = 240;

    address bwcTokenAddress;
    address receiptTokenAddress;
    address rewardTokenAddress;

    address ownerAddr;
    // address addr1;

    function setUp() public {
        bwcErc20TokenContract = new ERC20("BlockheaderWeb3 Token", "BWC", 0);
        receiptTokenContract = new ERC20("Receipt Token", "cBWC", 0);
        rewardTokenContract = new ERC20("Reward Token", "wBWC", 0);

        bwcTokenAddress = address(bwcErc20TokenContract);
        receiptTokenAddress = address(receiptTokenContract);
        rewardTokenAddress = address(rewardTokenContract);

        stakingContract = new StakingContract(
            bwcTokenAddress,
            receiptTokenAddress,
            rewardTokenAddress
        );

        bwcErc20TokenContract.mint(user, INITIAL_BALANCE);
        bwcErc20TokenContract.mint(user1, INITIAL_BALANCE);

        receiptTokenContract.mint(address(stakingContract), INITIAL_BALANCE);
    }

    function test_StakingContractDeployment() public view {
        assertEq(stakingContract.bwcErc20TokenAddress(), bwcTokenAddress);
        assertEq(stakingContract.receiptTokenAddress(), receiptTokenAddress);
        assertEq(stakingContract.rewardTokenAddress(), rewardTokenAddress);
    }

    function test_StakingNotAddZero() public {
        vm.startPrank(address(0));
        uint256 amount = 100e18;
        bwcErc20TokenContract.approve(address(stakingContract), amount);
        vm.expectRevert("STAKE: Address zero not allowed");
        stakingContract.stake(amount);
        vm.stopPrank();
    }

    function test_StakingWithZeroAmount() public {
        vm.startPrank(user);
        vm.expectRevert("STAKE: Zero amount not allowed");
        stakingContract.stake(0);
        vm.stopPrank();
    }

    function test_StakingWithInsufficientBalance() public {
        uint256 stakeAmount = INITIAL_BALANCE + 1;
        vm.startPrank(user);
        bwcErc20TokenContract.approve(address(stakingContract), stakeAmount);
        vm.expectRevert("STAKE: Insufficient funds");
        stakingContract.stake(stakeAmount);
        vm.stopPrank();
    }

    function test_StakingWithInsufficientAllowance() public {
        uint256 stakeAmount = 100e18;
        vm.startPrank(user);
        bwcErc20TokenContract.approve(address(stakingContract), stakeAmount - 1);
        vm.expectRevert("STAKE: Amount not allowed");
        stakingContract.stake(stakeAmount);
        vm.stopPrank();
    }

    function test_StakingWhenContractHasInsufficientReceiptTokens() public {
        uint256 stakeAmount = INITIAL_BALANCE;
        receiptTokenContract.burn(address(stakingContract), INITIAL_BALANCE);
        
        vm.startPrank(user);
        bwcErc20TokenContract.approve(address(stakingContract), stakeAmount);
        vm.expectRevert("STAKE: Low contract receipt token balance");
        stakingContract.stake(stakeAmount);
        vm.stopPrank();
    }

    function test_StakeTransferFailed() public {
        vm.startPrank(user);
        uint256 stakeAmount = 100e18;

        vm.mockCall(
            address(bwcTokenAddress),
            abi.encodeWithSignature("transferFrom(address,address,uint256)", user, address(stakingContract), stakeAmount),
            abi.encode(false) // Simulate a transfer failure
        );

        vm.expectRevert("STAKE: Transfer failed");
        stakingContract.stake(stakeAmount);
        vm.stopPrank();
    }


    function test_GetTotalStake() public {
        // Initial total stake should be 0
        assertEq(stakingContract.getTotalStake(), 0, "Initial total stake should be 0");

        // Stake some tokens
        uint256 stakingAmount1 = 100e18;
        uint256 stakingAmount2 = 150e18;

        uint256 totalAmount = stakingAmount1 + stakingAmount2;
        
        vm.startPrank(user);
        bwcErc20TokenContract.approve(address(stakingContract), totalAmount);
        stakingContract.stake(stakingAmount1);
        
        // Check total stake after first staking
        assertEq(stakingContract.getTotalStake(), stakingAmount1, "Total stake should equal first staking amount");
        
        // Stake more tokens
        stakingContract.stake(stakingAmount2);
        vm.stopPrank();

        // Check total stake after second staking
        assertEq(stakingContract.getTotalStake(), totalAmount, "Total stake should equal sum of both staking amounts");
    }

    function test_GetBwcTokenAddress() public view{

        assertEq(stakingContract.getBwcTokenAddress(), bwcTokenAddress, "The bwc token address");
    }

    function test_GetRewardTokenAddress() public view {
        assertEq(stakingContract.getRewardTokenAddress(), rewardTokenAddress, "The reward token address");
    }

    function test_GetReceiptTokenAddress() public view {
        assertEq(stakingContract.getReceiptTokenAddress(), receiptTokenAddress, "The receive token address");
    }

    function test_NextWithdrawal() public view {
        uint time = block.timestamp;
        uint256 nextTime = time + MIN_TIME_BEFORE_WITHDRAW - block.timestamp;
        uint256 actualTime = stakingContract.getNextWithdrawTime(user);
        assertApproxEqAbs(actualTime, nextTime, 1, "The time left for the next withdrawal should be within 1 second of the expected time.");
    }

    function test_GetStakeBalances() public {
        address addr1 = address(0x42);
        uint256 stakingAmounts = 100e18;

        // Mint tokens to addr1 before staking
        bwcErc20TokenContract.mint(addr1, stakingAmounts);

        vm.startPrank(addr1);

        // Approve and stake the amount
        bwcErc20TokenContract.approve(address(stakingContract), stakingAmounts);
        stakingContract.stake(stakingAmounts);

        // Check the staked amount
        assertEq(stakingContract.getStakers(addr1).amount, stakingAmounts);
        vm.stopPrank();
    }

    function test_IsTimeToWithdraw() public {
        address addr1 = address(0x42);
        uint256 stakeTime = stakingContract.getStakers(addr1).timeStaked;
        uint256 minTime = MIN_TIME_BEFORE_WITHDRAW;
        vm.warp(stakeTime + minTime);
        uint256 stakedTime = stakeTime + MIN_TIME_BEFORE_WITHDRAW;
        uint time = block.timestamp;
        bool timeToWithdraw = time >= stakedTime;

        assertTrue(timeToWithdraw, "Should be able to withdraw after the minimum time has passed");
    }


    function test_WithdrawIsNotAddressZero() public {
        uint256 amount = 100e18;
        
        vm.startPrank(address(0));

        vm.expectRevert("WITHDRAW: Address zero not allowed");
        stakingContract.withdraw(amount);
        
        vm.stopPrank();
    }

    function test_WithdrawZeroAmount() public {
        uint256 amount = 0;
        vm.startPrank(user);
        vm.expectRevert("WITHDRAW: Zero amount not allowed");
        stakingContract.withdraw(amount);
    }

    function test_WithdrawAmountNotAllowed() public {
        uint256 withdrawAmount = 150e18;

        vm.startPrank(user);
        bwcErc20TokenContract.approve(address(stakingContract), stakingAmount);

        stakingContract.stake(stakingAmount);

        vm.expectRevert("WITHDRAW: Withdraw amount not allowed");
        stakingContract.withdraw(withdrawAmount);
    }

    function test_WithdrawBeforeMinTime() public {
        uint256 stakeAmount = 100e18;
        uint256 withdrawAmount = 50e18;

        vm.startPrank(user);
        bwcErc20TokenContract.approve(address(stakingContract), stakeAmount);
        stakingContract.stake(stakeAmount);

        vm.expectRevert("WITHDRAW: Not yet time to withdraw");
        stakingContract.withdraw(withdrawAmount);
        vm.stopPrank();
    }

    function test_WithdrawInsufficientBalance() public {
        uint256 stakeAmount = 100e18;
        uint256 withdrawAmount = 50e18;

        vm.startPrank(user);
        bwcErc20TokenContract.approve(address(stakingContract), stakeAmount);
        stakingContract.stake(stakeAmount);

        vm.warp(block.timestamp + MIN_TIME_BEFORE_WITHDRAW+ 1);

        rewardTokenContract.approve(address(stakingContract), withdrawAmount);

        vm.expectRevert("WITHDRAW: Insufficient reward token balance");
        stakingContract.withdraw(withdrawAmount);
        vm.stopPrank();
    }

}
