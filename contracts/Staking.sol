// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./IERC20.sol";

contract StakingRewards {
    IERC20 public immutable stakingToken;
    IERC20 public immutable rewardsToken;

    address public owner;

    // Duration of rewards to be paid out (in seconds)
    uint public duration;
    // Timestamp of when the rewards finish
    uint public finishAt;
    // Minimum of last updated time and reward finish time
    uint public updatedAt;
    // Reward to be paid out per second
    uint public rewardRate;
    // Sum of (reward rate * dt * 1e18 / total supply)
    uint public rewardPerTokenStored;
    // User address => rewardPerTokenStored
    mapping(address => uint) public userRewardPerTokenPaid;
    // User address => rewards to be claimed
    mapping(address => uint) public rewards;

    // Total staked
    uint public totalSupply;
    // User address => staked amount
    mapping(address => uint) public balanceOf;

    constructor(address _stakingToken, address _rewardsToken) {
        owner = msg.sender;
        stakingToken = IERC20(_stakingToken);
        rewardsToken = IERC20(_rewardsToken);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "not authorized");
        _;
    }

    modifier updateReward(address _account) {
        // Code
        _;
    }

    function lastTimeRewardApplicable() public view returns (uint) {
        // Code
    }

    function rewardPerToken() public view returns (uint) {
        // Code
    }

    function stake(uint _amount) external {
        // Code
    }

    function withdraw(uint _amount) external {
        // Code
    }

    function earned(address _account) public view returns (uint) {
        // Code
    }

    function getReward() external {
        // Code
    }

    function setRewardsDuration(uint _duration) external {
        // Code
    }

    function notifyRewardAmount(uint _amount) external {
        // Code
    }

    function _min(uint x, uint y) private pure returns (uint) {
        return x <= y ? x : y;
    }
}

/*
      Algorithm
      On stake and withdraw
      1. Calculate reward per token
      r += R / totalsupply * (current time - last update timestamp)
      2. Calculate reward earned by user
      rewards[user] += balanceOf[user] * (r - userRewardPerTokenPaid[user])
      3. update user reward per token paid
      r - userRewardPerTokenPaid[user] = r
      4. update last update time
      last update timestamp = current time
      5. updat stake amount
      balanceOf[user] +/- = amount (+ on staking, - on withdraw)
      totalSupply +/- = amount (+ on staking, - on withdraw)
 */
