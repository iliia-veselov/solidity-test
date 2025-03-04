// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";

contract StakingContract is Ownable {
    IERC20 public stakingToken;  // Token that users stake
    IERC20 public rewardToken;   // Token used for rewards

    uint256 public constant DECIMALS = 10**18;

    mapping(address => Staker) public stakers;

    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);
    event AddedRewards(address indexed user, uint256 amount);

    struct Staker {
        uint256 balance;
        uint256 rewarded;
    }   

    constructor(address _stakingToken, address _rewardToken, address owner) Ownable (owner) {
        stakingToken = IERC20(_stakingToken);
        rewardToken = IERC20(_rewardToken);
    }

    /**
     * @dev Balance of address
     */
    function balanceOf(address callerAddress) public view returns (uint256)  {
        return stakers[callerAddress].balance;
    }

    /**
     * @dev Stake tokens into the contract.
     */
    function stake(uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");
        stakers[msg.sender].balance += amount;
        stakers[msg.sender].rewarded += amount;

        console.log("stake - amount: ", amount);
        console.log("stake - transfering stakingToken");
        console.log("stake - contract balance before stakingToken transfer: ", stakingToken.balanceOf(address(this)));
        console.log("stake - user balance before stakingToken transfer: ", stakingToken.balanceOf(msg.sender));
        stakingToken.transferFrom(msg.sender, address(this), amount);
        console.log("stake - contract balance after stakingToken transfer: ", stakingToken.balanceOf(address(this)));
        console.log("stake - user balance after stakingToken transfer: ", stakingToken.balanceOf(msg.sender));

        console.log("stake - transfering rewardToken");
        console.log("stake - contract balance before rewardToken transfer: ", rewardToken.balanceOf(address(this)));
        console.log("stake - user balance before rewardToken transfer: ", rewardToken.balanceOf(msg.sender));
        rewardToken.transfer(msg.sender, amount);
        console.log("stake - contract balance after rewardToken transfer: ", rewardToken.balanceOf(address(this)));
        console.log("stake - user balance after rewardToken transfer: ", rewardToken.balanceOf(msg.sender));

        emit Staked(msg.sender, amount);
    }

    /**
     * @dev Unstake tokens and claim rewards.
     */
    function unstake(uint256 amount) external {
        uint256 balance = stakers[msg.sender].balance;
        uint256 rewarded = stakers[msg.sender].rewarded;
        uint256 balanceToRewardRatio = balance * DECIMALS / rewarded;
        uint256 unstakeAmount = amount * balanceToRewardRatio / DECIMALS;
        console.log("unstake - balance: ", balance);
        console.log("unstake - rewarded: ", rewarded);
        console.log("unstake - amount: ", amount);

        require(rewarded >= amount, "Insufficient rewarded balance");
        require(balance >= unstakeAmount, "Insufficient balance");

        stakers[msg.sender].balance -= unstakeAmount;
        stakers[msg.sender].rewarded -= amount;

        
        console.log("unstake - userAddress: ", msg.sender);
        console.log("unstake - contractAddress: ", address(this));
        console.log("unstake - balanceToRewardRatio: ", balanceToRewardRatio);
        console.log("unstake - unstakeAmount: ", unstakeAmount);

        console.log("unstake - transfering stakingToken");
        console.log("unstake - contract balance before stakingToken transfer: ", stakingToken.balanceOf(address(this)));
        console.log("unstake - user balance before stakingToken transfer: ", stakingToken.balanceOf(msg.sender));
        stakingToken.transfer(msg.sender, unstakeAmount);
        console.log("unstake - contract balance after stakingToken transfer: ", stakingToken.balanceOf(address(this)));
        console.log("unstake - user balance after stakingToken transfer: ", stakingToken.balanceOf(msg.sender));


        console.log("unstake - transfering rewardToken");
        console.log("unstake - contract balance before rewardToken transfer: ", rewardToken.balanceOf(address(this)));
        console.log("unstake - user balance before rewardToken transfer: ", rewardToken.balanceOf(msg.sender));
        rewardToken.transferFrom(msg.sender, address(this), amount);
        console.log("unstake - contract balance after rewardToken transfer: ", rewardToken.balanceOf(address(this)));
        console.log("unstake - user balance after rewardToken transfer: ", rewardToken.balanceOf(msg.sender));

        emit Unstaked(msg.sender, amount);
    }

    /**
     * @dev Fund the contract with reward tokens.
     */
    function addRewards(address stakerAddress, uint256 amount) external onlyOwner {

        stakers[stakerAddress].balance += amount;

        stakingToken.transferFrom(msg.sender, address(this), amount);

        emit AddedRewards(stakerAddress, amount);
    }

}
