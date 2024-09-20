// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract StakingContract {
    struct StakeDetail {
        uint256 timeStaked;
        uint256 amount;
        bool status;
    }

    mapping(address => StakeDetail) public stakers;
    address public bwcErc20TokenAddress;
    address public receiptTokenAddress;
    address public rewardTokenAddress;
    uint256 public totalStaked;

    //////////////////
    // CONSTANTS
    //////////////////
    uint256 constant MIN_TIME_BEFORE_WITHDRAW = 240; // Minimum time (in seconds) before tokens can be withdrawn. Equivalent to 4 minutes.
    uint256 constant MULTIPLIER = 2; //

    //////////////////
    // EVENTS
    //////////////////
    event TokenStaked(address indexed staker, uint256 amount, uint256 time);
    event TokenWithdraw(address indexed staker, uint256 amount, uint256 time);

    //////////////////
    // CONSTRUCTOR
    //////////////////
    constructor(address _bwcErc20TokenAddress, address _receiptTokenAddress, address _rewardTokenAddress) {
        bwcErc20TokenAddress = _bwcErc20TokenAddress;
        receiptTokenAddress = _receiptTokenAddress;
        rewardTokenAddress = _rewardTokenAddress;
    }

    //////////////////
    // STAKE FUNCTION
    //////////////////
    function stake(uint256 amount) external returns (bool) {
        require(msg.sender != address(0), "STAKE: Address zero not allowed");
        require(amount > 0, "STAKE: Zero amount not allowed");

        IERC20 bwcToken = IERC20(bwcErc20TokenAddress);
        IERC20 receiptToken = IERC20(receiptTokenAddress);

        // Staker have enough token to stake
        require(bwcToken.balanceOf(msg.sender) >= amount, "STAKE: Insufficient funds");

        // Contract has enough receipt token to send to staker
        require(receiptToken.balanceOf(address(this)) >= amount, "STAKE: Low contract receipt token balance");

        // Staker has approved enough tokens to be staked
        require(bwcToken.allowance(msg.sender, address(this)) >= amount, "STAKE: Amount not allowed");

        StakeDetail storage stakeDetail = stakers[msg.sender];

        stakeDetail.amount += amount;
        stakeDetail.timeStaked = block.timestamp;
        stakeDetail.status = true;

        // Transfer stake token from Staker to contract
        require(bwcToken.transferFrom(msg.sender, address(this), amount), "STAKE: Transfer failed");

        // Increase total stake amount of Staker
        totalStaked += amount;

        // Transfer receipt token from contract to Staker
        require(receiptToken.transfer(msg.sender, amount), "STAKE: Receipt token transfer failed");

        emit TokenStaked(msg.sender, amount, block.timestamp);
        return true;
    }

    //////////////////
    // WITHDRAW FUNCTION
    //////////////////
    function withdraw(uint256 amount) external returns (bool) {
        StakeDetail storage stakeDetail = stakers[msg.sender];

        require(msg.sender != address(0), "WITHDRAW: Address zero not allowed");
        require(amount > 0, "WITHDRAW: Zero amount not allowed");
        require(stakeDetail.amount >= amount, "WITHDRAW: Withdraw amount not allowed");
        require(isTimeToWithdraw(stakeDetail.timeStaked), "WITHDRAW: Not yet time to withdraw");

        IERC20 bwcToken = IERC20(bwcErc20TokenAddress);
        IERC20 receiptToken = IERC20(receiptTokenAddress);
        IERC20 rewardToken = IERC20(rewardTokenAddress);

        uint256 withdrawAmount = amount * MULTIPLIER;

        require(rewardToken.balanceOf(address(this)) >= withdrawAmount, "WITHDRAW: Insufficient reward token balance");
        require(bwcToken.balanceOf(address(this)) >= amount, "WITHDRAW: Insufficient BWC token balance");
        require(
            receiptToken.allowance(msg.sender, address(this)) >= amount, "WITHDRAW: Receipt token allowance too low"
        );

        stakeDetail.amount -= amount;

        require(receiptToken.transferFrom(msg.sender, address(this), amount), "WITHDRAW: Receipt token transfer failed");
        require(rewardToken.transfer(msg.sender, withdrawAmount), "WITHDRAW: Reward token transfer failed");
        require(bwcToken.transfer(msg.sender, amount), "WITHDRAW: BWC token transfer failed");

        totalStaked -= amount;

        emit TokenWithdraw(msg.sender, amount, block.timestamp);
        return true;
    }

    //////////////////
    // VIEW FUNCTIONS
    //////////////////
    function getStakeBalance(address staker) external view returns (uint256) {
        return stakers[staker].amount;
    }

    function getNextWithdrawTime(address staker) external view returns (uint256) {
        return stakers[staker].timeStaked + MIN_TIME_BEFORE_WITHDRAW - block.timestamp;
    }

    function getTotalStake() external view returns (uint256) {
        return totalStaked;
    }

    function getBwcTokenAddress() external view returns (address) {
        return bwcErc20TokenAddress;
    }

    function getRewardTokenAddress() external view returns (address) {
        return rewardTokenAddress;
    }

    function getReceiptTokenAddress() external view returns (address) {
        return receiptTokenAddress;
    }

    //////////////////
    // INTERNAL FUNCTION
    //////////////////
    function isTimeToWithdraw(uint256 stakeTime) internal view returns (bool) {
        return block.timestamp >= stakeTime + MIN_TIME_BEFORE_WITHDRAW;
    }
}
