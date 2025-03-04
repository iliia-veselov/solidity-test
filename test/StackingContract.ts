import type { SnapshotRestorer } from "@nomicfoundation/hardhat-network-helpers";
import { takeSnapshot } from "@nomicfoundation/hardhat-network-helpers";

import { expect } from "chai";
import { ethers } from "hardhat";
import type { SignerWithAddress } from "@nomicfoundation/hardhat-ethers/signers";

import type { StakingContract } from "../typechain-types";
import type { MyToken } from "../typechain-types";

describe("StakingContract", function () {
    let snapshotA: SnapshotRestorer;

    // Signers.
    let deployer: SignerWithAddress, owner: SignerWithAddress, user: SignerWithAddress;
    let initSupply = 100_000;

    let stakingContract: StakingContract;
    let stakingToken: MyToken;
    let rewardToken: MyToken;

    before(async () => {
        // Getting of signers.
        [deployer, user] = await ethers.getSigners();

        // Deployment of the factory.
        const MyToken = await ethers.getContractFactory("MyToken", deployer);
        stakingToken = await MyToken.deploy(initSupply);
        await stakingToken.waitForDeployment();
        
        rewardToken = await MyToken.deploy(initSupply);
        await rewardToken.waitForDeployment();


        const StakingContract = await ethers.getContractFactory("StakingContract", deployer);
        stakingContract = await StakingContract.deploy(stakingToken, rewardToken);
        await stakingContract.waitForDeployment();

        owner = deployer;
        await rewardToken.transfer(stakingContract.getAddress(), 50000);

        snapshotA = await takeSnapshot();
    });

    afterEach(async () => await snapshotA.restore());

    describe("# Staking contract tests", function () {
        it("Stake and check stacked amount", async () => {
            let stakeAmount = 1000;
            await stakingToken.transfer(user.address, stakeAmount);

            const userStakingContract = stakingContract.connect(user);

            await stakingToken.connect(user).approve(stakingContract.target, stakeAmount);
            await userStakingContract.stake(1000);


            expect(await stakingContract.balanceOf(user.address)).to.equal(stakeAmount);
        });
        
        it("Stake, unstake all and check stacked amount", async () => {
            let stakeAmount = 1000n;
            await stakingToken.transfer(user.address, stakeAmount);

            const userStakingContract = stakingContract.connect(user);

            await stakingToken.connect(user).approve(stakingContract.target, stakeAmount);
            await userStakingContract.stake(1000);
            
            const balanceAfterStake = await stakingContract.balanceOf(user.address);

            expect(balanceAfterStake).to.equal(stakeAmount);

            await userStakingContract.unstake(1000);

            const balanceAfterUnstake = await stakingContract.balanceOf(user.address);
            expect(balanceAfterUnstake).to.equal(balanceAfterStake - stakeAmount);



        });
    });
});