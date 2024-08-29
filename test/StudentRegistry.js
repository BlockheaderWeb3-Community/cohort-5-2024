const {
    time,
    loadFixture,
  } = require("@nomicfoundation/hardhat-toolbox/network-helpers");
  const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
  const { ethers } = require("hardhat");
  const { expect } = require("chai");

  const ZERO_ADDRESS = "0x0000000000000000000000000000000000000000";

  describe("Student Registry Test Suite", () => {
    // deployUtil function
    const deployUtil = async () => {
        const [owner, newOwner, otherAccount] = await ethers.getSigners();
        const StudentRegistry = await ethers.getContractFactory("StudentRegistry");
        const deployedRegistry = await StudentRegistry.deploy();
        return {deployedRegistry, owner, newOwner, otherAccount};
    }

    describe("Student Mapping", () => {
        it("should return correct details from mapping", async () => {
            const { deployedRegistry, otherAccount } = await loadFixture(deployUtil);

            await expect(
                deployedRegistry.studentsMapping(otherAccount)
            ).to.not.be.reverted;
        })
    })
    
    describe("Add Students", () => {
        it("should add a student successfully", async () => {
            const { deployedRegistry, otherAccount } = await loadFixture(deployUtil);

            await expect(
                deployedRegistry.connect(otherAccount).addStudent(otherAccount.address, "Made", 19)
              ).to.not.be.reverted;
        })

        it("should be reverted when name is empty", async () => {
            const { deployedRegistry, otherAccount } = await loadFixture(deployUtil);

            await expect(
                deployedRegistry.connect(otherAccount).addStudent(otherAccount.address, "", 19)
              ).to.be.revertedWithCustomError(deployedRegistry, "NameIsEmpty");
        })

        it("should be reverted when age is less than 18", async () => {
            const { deployedRegistry, otherAccount } = await loadFixture(deployUtil);

            await expect(
                deployedRegistry.connect(otherAccount).addStudent(otherAccount.address, "John", 12)
              ).to.be.revertedWithCustomError(deployedRegistry, "UnderAge").withArgs(12, 18);
        })
    })

    describe("Delete Students", () => {
        it("should delete a student successfully", async () => {
            const { deployedRegistry, owner, otherAccount } = await loadFixture(deployUtil);

            await deployedRegistry.addStudent(otherAccount.address, "John", 19);

            await expect(
                deployedRegistry.connect(owner).deleteStudent(otherAccount.address))
            .to.not.be.reverted;
        })

        it("should be reverted when another account tries to delete", async () => {
            const { deployedRegistry, otherAccount } = await loadFixture(deployUtil);

            await expect(
                deployedRegistry.connect(otherAccount).deleteStudent(otherAccount.address))
            .to.be.revertedWith("Caller not owner");
        })

        it("should be reverted when trying to delete a student that has not been added", async () => {
            const { deployedRegistry, owner, otherAccount } = await loadFixture(deployUtil);

            await expect(
                deployedRegistry.connect(owner).deleteStudent(otherAccount.address)
            ).to.be.revertedWith("Student does not exist");
        })
    })

    describe("Get Students", () => {
        it("should get student successfully", async() => {
            const { deployedRegistry, otherAccount } = await loadFixture(deployUtil);

            await deployedRegistry.addStudent(otherAccount.address, "John", 19);

            await expect(
                deployedRegistry.getStudent(1)
            ).to.not.be.reverted;
        })

        it("should revert when an invalid ID is used to get student", async() => {
            const { deployedRegistry, otherAccount } = await loadFixture(deployUtil);

            await deployedRegistry.addStudent(otherAccount.address, "John", 19);

            await expect(
                deployedRegistry.getStudent(0)
            ).to.be.reverted;
        })
    })
    
    describe("Get Student From Mapping", () => {
        it("should successfully get student from mapping", async () => {
            const { deployedRegistry, otherAccount } = await loadFixture(deployUtil);

            await deployedRegistry.addStudent(otherAccount.address, "John", 19);

            await expect(
                deployedRegistry.connect(otherAccount).getStudentFromMapping(otherAccount.address)
            ).to.not.be.reverted;
        })

    })

    describe("Modify Owner", () => {
        it("should successfully modify owner", async () => {
            const { deployedRegistry, owner, newOwner } = await loadFixture(deployUtil);
            
            await expect(
                deployedRegistry.connect(owner).modifyOwner(newOwner.address)
            ).to.not.be.reverted;
        })

        it("should be reverted when other account tries to change owner", async () => {
            const { deployedRegistry, otherAccount, newOwner } = await loadFixture(deployUtil);

            await expect(
                deployedRegistry.connect(otherAccount).modifyOwner(newOwner.address)
            ).to.be.revertedWith("Caller not owner");
        })

        it("should revert when trying to set new owner as address zero", async () => {
            const { deployedRegistry, owner } = await loadFixture(deployUtil);

            await expect(
                deployedRegistry.connect(owner).modifyOwner(ZERO_ADDRESS)
            ).to.be.revertedWith("Owner can not be address zero");
        })
    })

  });