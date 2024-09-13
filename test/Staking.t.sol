// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/console.sol";
import {Test, console} from "forge-std/Test.sol";
import {StakingContract} from "../src/Staking.sol";
import {ERC20} from "../src/ERC20.sol";

contract StakingContractTest is Test {
    StakingContract public stakingContract;

    ERC20 public bwcErc20TokenContract;
    ERC20 public receiptTokenContract;
    ERC20 public rewardTokenContract;

    address bwcTokenAddress;
    address receiptTokenAddress;
    address rewardTokenAddress;

    address ownerAddr = address(0x1111);
    address addr1 = address(0x8997);
    address addr2 = address(0x2622);

    event TokenStaked(address indexed staker, uint256 amount, uint256 time);
    event TokenWithdraw(address indexed staker, uint256 amount, uint256 time);

    function setUp() public {
        vm.startPrank(ownerAddr);
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
        vm.stopPrank();
    }

    function test_StakingContractDeployment() public view {
        assertEq(stakingContract.bwcErc20TokenAddress(), bwcTokenAddress);
        assertEq(stakingContract.receiptTokenAddress(), receiptTokenAddress);
        assertEq(stakingContract.rewardTokenAddress(), rewardTokenAddress);
        assertEq(stakingContract.totalStaked(), 0);

        // Making sure timeStaked, amount and status are at default values
        assertEq(stakingContract.getStakers(addr1).timeStaked, 0);
        assertEq(stakingContract.getStakers(addr1).amount, 0);
        assertEq(stakingContract.getStakers(addr1).status, false);
    }

    function test_Stake() public {
        uint amount = 1000;
        uint stakeAmount = 200;
        uint allowance = 500;
        uint time = block.timestamp;
        
        // Staker cannot be address zer0
        vm.startPrank(address(0));
        vm.expectRevert("STAKE: Address zero not allowed");
        stakingContract.stake(stakeAmount);
        vm.stopPrank();

        // Cannot stake zero amount 
        vm.startPrank(addr1);
        vm.expectRevert("STAKE: Zero amount not allowed");
        stakingContract.stake(0);
        // Staker does not have enough bwc tokens to stake
        vm.expectRevert("STAKE: Insufficient funds");
        stakingContract.stake(stakeAmount);
        vm.stopPrank();

        // mint bwc Tokens to addr1
        vm.startPrank(ownerAddr);
        bwcErc20TokenContract.mint(addr1, amount);
        vm.stopPrank();

        // Staker does not have enough receipt tokens
        vm.startPrank(addr1);
        // check balances of addr1 and receipt token contract
        assertEq(receiptTokenContract.balanceOf(receiptTokenAddress), 0);
        assertEq(bwcErc20TokenContract.balanceOf(addr1), amount);
        vm.expectRevert("STAKE: Low contract receipt token balance");
        stakingContract.stake(stakeAmount);
        vm.stopPrank();

        // mint receipt token to staking contract
        vm.startPrank(ownerAddr);
        receiptTokenContract.mint(address(stakingContract), amount);
        vm.stopPrank();

        // Staker has not approved enough bwc tokens
        vm.startPrank(addr1);
        // Balance Checks
        assertEq(receiptTokenContract.balanceOf(address(stakingContract)), amount);
        assertEq(bwcErc20TokenContract.balanceOf(addr1), amount);
        // Approving allowance tokens
        bwcErc20TokenContract.approve(address(stakingContract), allowance);
        vm.expectRevert("STAKE: Amount not allowed");
        // Staking 700
        stakingContract.stake(700);
        vm.stopPrank();
        
        // Properly update StakeDetail struct
        vm.startPrank(addr1);
        // Approving tokens
        bwcErc20TokenContract.approve(address(stakingContract), allowance);
        stakingContract.stake(stakeAmount);

        assertEq(stakingContract.getStakers(addr1).amount, stakeAmount);
        assertEq(stakingContract.getStakers(addr1).timeStaked, time);
        assertEq(stakingContract.getStakers(addr1).status, true);

        // check if bwc tokens have been sent to staking contract
        assertEq(bwcErc20TokenContract.balanceOf(address(stakingContract)), stakeAmount);

        // check that totalStaked is incremented by amount
        assertEq(stakingContract.totalStaked(), stakeAmount);

        // check the allowance remaining
        uint remainingAllowance = bwcErc20TokenContract.allowance(addr1, address(stakingContract));
        assertEq(remainingAllowance, allowance - stakeAmount);

        // check that receipt tokens are sent to staker
        assertEq(receiptTokenContract.balanceOf(addr1), stakeAmount);

        // Events
        vm.expectEmit(true, false, true, false);
        emit TokenStaked(addr1, stakeAmount, block.timestamp);
        stakingContract.stake(100);
        // To check that the stake function returns 'true'
        assertEq(stakingContract.stake(100), true);
        vm.stopPrank();
    }

    function test_Withdraw() public {
        uint amount = 1000;
        uint stakeAmount = 300;
        uint allowance = 700;

        // Zero address cannot withdraw
        vm.startPrank(address(0));
        vm.expectRevert("WITHDRAW: Address zero not allowed");
        stakingContract.withdraw(200);
        vm.stopPrank();

        vm.startPrank(addr1);
        vm.expectRevert("WITHDRAW: Zero amount not allowed");
        stakingContract.withdraw(0);
        vm.stopPrank();

        // mint bwc Tokens to addr1
        vm.startPrank(ownerAddr);
        bwcErc20TokenContract.mint(addr1, amount);
        vm.stopPrank();

        // mint receipt token to staking contract
        vm.startPrank(ownerAddr);
        receiptTokenContract.mint(address(stakingContract), 400);
        rewardTokenContract.mint(address(stakingContract), 150);
        vm.stopPrank();

        // Staker must not withdraw more than stakeAmount
        vm.startPrank(addr1);
        console.log(receiptTokenContract.balanceOf(address(stakingContract)));
        bwcErc20TokenContract.approve(address(stakingContract), allowance);
        stakingContract.stake(stakeAmount); 
        vm.expectRevert("WITHDRAW: Withdraw amount not allowed");
        stakingContract.withdraw(360);
        console.log(receiptTokenContract.balanceOf(address(stakingContract)));
        vm.stopPrank();
        
        // Check for proper withdrawal time
        vm.startPrank(addr1);
        vm.expectRevert("WITHDRAW: Not yet time to withdraw");
        stakingContract.withdraw(10);
        vm.stopPrank();

        // Check balance of reward tokens
        vm.startPrank(addr1);
        receiptTokenContract.approve(address(stakingContract), 270);
        skip(240);
        vm.expectRevert("WITHDRAW: Insufficient reward token balance");
        stakingContract.withdraw(100);
        vm.stopPrank();

        vm.startPrank(ownerAddr);
        rewardTokenContract.mint(address(stakingContract), 400);
        vm.stopPrank();

        vm.startPrank(addr1);
        vm.expectRevert("WITHDRAW: Receipt token allowance too low");
        stakingContract.withdraw(275);
        vm.stopPrank();

        vm.startPrank(addr1);
        uint balanceBeforeWithdraw = receiptTokenContract.balanceOf(address(stakingContract));

        uint bwcBalanceBeforeWithdraw = bwcErc20TokenContract.balanceOf(addr1);

        uint totalStakedBeforeWithdraw = stakingContract.totalStaked();
        stakingContract.withdraw(200);

        // Check for proper balance reduction
        assertEq(stakingContract.getStakers(addr1).amount, stakeAmount - 200);

        uint balanceAfterWithdraw = receiptTokenContract.balanceOf(address(stakingContract));

        uint bwcBalanceAfterWithdraw = bwcErc20TokenContract.balanceOf(addr1);

        uint totalStakedAfterWithdraw = stakingContract.totalStaked();
        // Check successful transfer of receipt tokens From addr1 to stakingContract
        assertEq(balanceBeforeWithdraw + 200, balanceAfterWithdraw);

        // Check successful transfer of reward tokens to addr1
        assertEq(rewardTokenContract.balanceOf(addr1), 400);
        // Check successful transfer of bwc tokens to addr1
        assertEq(bwcBalanceBeforeWithdraw + 200, bwcBalanceAfterWithdraw);
        // Check that totalStaked is properly deducted
        assertEq(totalStakedBeforeWithdraw - 200, totalStakedAfterWithdraw);

        console.log(bwcErc20TokenContract.balanceOf(addr1));
        vm.stopPrank();

        // Withdraw Events
        vm.startPrank(addr1);
        vm.expectEmit(true, false, true, false);
        emit TokenWithdraw(addr1, 50, block.timestamp);
        stakingContract.withdraw(50);

        // Check that Withdraw function returns true
        assertEq(stakingContract.withdraw(10), true);
        vm.stopPrank();
    }

}
