// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./IERC20.sol";

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

    // Sum of (reward rate * duration * 1e18 / total supply)
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
    function stake(uint _amount) external {
        require(_amount > 0, "amount must be greater than zero");
        stakingToken.transferFrom(msg.sender, address(this), _amount);
        balanceOf[msg.sender] += _amount;
        totalSupply += _amount;
    }

    function withdraw(uint _amount) external {
        require(_amount > 0, "amount must be greater than zero");
        balanceOf[msg.sender] -= _amount;
        totalSupply -= _amount;
        stakingToken.transfer(msg.sender,_amount)
    }

    function lastTimeRewardApplicable() public view returns (uint) {
        return _min(block.timestamp,finishAt);
    }
    function rewardPerToken() public view returns (uint) {
        if(totalSupply == 0){
            return rewardPerTokenStored;
        }
        return rewardPerTokenStored + (rewardRate *
            (lastTimeRewardApplicable() - updatedAt) * 1e18
        ) / totalSupply;
    }
    function earned(address _account) public view returns (uint) {
        return balanceOf[_account] * (
            (rewardPerToken() - userRewardPerTokenPaid[_account]) / 1e18
        ) + rewards[_account];
    }

    function getReward() external {
        // Code
    }

    function setRewardsDuration(uint _duration) external onlyOwner {
        // Only the owner can call
        // Previous reward period must be expired (block.timestamp > finishAt).
        require(finishAt < block.timestamp, "reward duration not finished");
        duration = _duration;
    }

    function notifyRewardAmount(uint _amount) external onlyOwner {
        //    This function sets the rewardRate and time when the rewards end finishAt.
        // Only the owner can call
        // If previous reward period is expired (block.timestamp >= finishAt) then rewardRate is set to _amount / duration.
        if (block.timestamp >= finishAt) {
            rewardRate = _amount / duration;
        } else {
            // Otherwise, the current reward period is not expired so
            // the new reward rate must be set to (_amount + remaining rewards) / duration.
            uint remainingRewards = rewardRate * (finishAt - block.timestamp);
            rewardRate = (_amount + remainingRewards) / duration;
        }
        // Check rewardRate is greater than 0
        require(rewardRate > 0, "reward rate must be greater than zero");
        // Check balance of rewards locked in this contract is greater than or equal to the total reward to be given out.
        require(
            rewardRate * duration <= rewardsToken.balanceOf(address(this)),
            "reward amount > balance"
        );
        // Set updatedAt to the current timestamp
        finishAt = block.timestamp + duration;
        // Set finishAt to current timestamp + duration
        updatedAt = block.timestamp;
    }

    function _min(uint x, uint y) private pure returns (uint) {
        return x <= y ? x : y;
    }
}
