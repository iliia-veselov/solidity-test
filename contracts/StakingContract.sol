// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract StakingContract is Ownable {
    IERC20 public stakingToken;  // Token that users stake
    IERC20 public rewardToken;   // Token used for rewards

    mapping(address => uint256) public stakers;

    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);
    event AddedRewards(address indexed user, uint256 amount);

    constructor(address _stakingToken, address _rewardToken) Ownable (_stakingToken) {
        stakingToken = IERC20(_stakingToken);
        rewardToken = IERC20(_rewardToken);
    }

    /**
     * @dev Stake tokens into the contract.
     */
    function stake(uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");

        stakingToken.transferFrom(msg.sender, address(this), amount);

        stakers[msg.sender] += amount;

        rewardToken.transfer(msg.sender, amount);

        emit Staked(msg.sender, amount);
    }

    /**
     * @dev Unstake tokens and claim rewards.
     */
    function unstake(uint256 amount) external {
        uint256 balance = stakers[msg.sender];
        require(balance >= amount, "Insufficient balance");

        stakingToken.transfer(msg.sender, amount);

        balance -= amount;
        stakers[msg.sender] = balance;

        rewardToken.transferFrom(msg.sender, address(this), amount);

        emit Unstaked(msg.sender, amount);
    }


    /**
     * @dev Fund the contract with reward tokens.
     */
    function addRewards(address stakerAddress, uint256 amount) external onlyOwner {

        stakers[msg.sender] += amount;

        emit AddedRewards(stakerAddress, amount);
    }

}
