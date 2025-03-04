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
    let myToken: MyToken;

    before(async () => {
        // Getting of signers.
        [deployer, user] = await ethers.getSigners();

        // Deployment of the factory.
        const MyToken = await ethers.getContractFactory("MyToken", deployer);
        myToken = await MyToken.deploy(initSupply);
        await myToken.deployed();


        const StakingContract = await ethers.getContractFactory("StakingContract", deployer);
        stakingContract = await StakingContract.deploy();
        await stakingContract.deployed();

        owner = deployer;

        snapshotA = await takeSnapshot();
    });

    afterEach(async () => await snapshotA.restore());

    describe("# Deployment", function () {
        it("Sets the deployer as the initial owner when initialization", async () => {
            // Deployment.
            const StakingContract = await ethers.getContractFactory("StakingContract", deployer);
            const StakingContract = await StakingContract.deploy();
            await StakingContract.deployed();

            expect(await StakingContract.owner()).to.be.eq(deployer.address);
        });

        it("Sets the positive even number with '2' when initialization", async () => {
            // Deployment.
            const StakingContract = await ethers.getContractFactory("StakingContract", deployer);
            const StakingContract = await StakingContract.deploy();
            await StakingContract.deployed();

            expect(await StakingContract.positiveEven()).to.be.eq(2);
        });
    });

    describe("# Setting of the positive even number", function () {
        it("Sets", async () => {
            // Saving of the previous value.
            const positiveEvenBefore = await stakingContract.positiveEven();

            // Setting.
            const newPositiveEven = 4;
            const tx = await stakingContract.connect(owner).setPositiveEven(newPositiveEven);
            // Check of the event emission.
            await expect(tx)
                .to.emit(stakingContract, "PositiveEvenSet")
                .withArgs(positiveEvenBefore, newPositiveEven);

            // Check of values.
            expect(await stakingContract.positiveEven()).to.be.eq(newPositiveEven);
        });

        it("Reverts when setting if a zero value", async () => {
            await expect(stakingContract.connect(owner).setPositiveEven(0)).to.be.revertedWithCustomError(
                stakingContract,
                "SetPositiveNumberToZero"
            );
        });

        it("Reverts when setting if an odd value", async () => {
            const oddNumber = 1;
            await expect(stakingContract.connect(owner).setPositiveEven(oddNumber))
                .to.be.revertedWithCustomError(stakingContract, "SetEvenToOddNumber")
                .withArgs(oddNumber);
        });

        it("Prevents non-owners from setting", async () => {
            await expect(stakingContract.connect(user).setPositiveEven(4)).to.be.revertedWith(
                "Ownable: caller is not the owner"
            );
        });
    });
});