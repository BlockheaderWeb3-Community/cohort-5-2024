// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

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
    }

    function test_StakingContractDeployment() public view {
        assertEq(stakingContract.bwcErc20TokenAddress(), bwcTokenAddress);
    }
}
