const { time, loadFixture } = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");
const { ethers } = require("hardhat");

const convertEther = (amount) => {
  return ethers.parseEther(amount);
};

// Get balance util function
const getBalance = async (account) => {
  const balance = await ethers.provider.getBalance(account);
  return balance;
};

describe("StudentRegistryV2 Test Suite", () => {
  // deploy util function
  const deployUtil = async () => {
    const StudentRegistryV2 = await ethers.getContractFactory("StudentRegistryV2"); // instance of StudentRegistryV2 contract in Contracts folder
    const deployedStudentRegistryV2 = await StudentRegistryV2.deploy(); // the deployed version of the StudentRegistryV2 contract in the network
    const [owner, addr1, addr2] = await ethers.getSigners();
    const ZERO_ADDRESS = "0x0000000000000000000000000000000000000000";
    return {
      deployedStudentRegistryV2,
      owner,
      addr1,
      addr2,
      ZERO_ADDRESS,
      deployedStudentRegistryV2Address: deployedStudentRegistryV2.target,
    };
  };

  describe("Deployment", () => {
    it("should deploy succesfuly and return default values of count", async () => {
      const { deployedStudentRegistryV2, owner, ZERO_ADDRESS, addr1 } = await loadFixture(deployUtil);
      // check the owner of the StudentRegistry contract which auto inherits from Ownable
      let studentRegistryV2Owner = await deployedStudentRegistryV2.getOwner();
      console.log(studentRegistryV2Owner);

      expect(studentRegistryV2Owner).to.eq(owner);

      // check that students array of Student struct is empty
      let allStudents = await deployedStudentRegistryV2.getAllStudents();
      expect(allStudents.length).to.eq(0);

      // check that studentsMapping has default values
      // meaning no values pushed to studentsMapping upon successful deployment
      let studentsMapping = await deployedStudentRegistryV2.studentsMapping(ZERO_ADDRESS);
      let addr1Mapping = await deployedStudentRegistryV2.studentsMapping(addr1);
      const emptyStudentStruct = ["0x0000000000000000000000000000000000000000", "", "0", "0", false, false];
      expect(...addr1Mapping).to.eq(...emptyStudentStruct);
      expect(...studentsMapping).to.eq(...emptyStudentStruct);

      // check that tempstudentsMapping  has default values
      const tempStudentsMapping = await deployedStudentRegistryV2.tempstudentsMapping(addr1);
      expect(...tempStudentsMapping).to.eq(...emptyStudentStruct);

      // check if  hasPaidMapping has default value of false
      const hasPaidMapping = await deployedStudentRegistryV2.hasPaidMapping(addr1);
      expect(hasPaidMapping).to.eq(false);
    });
  });

  describe("Transactions", () => {
    describe("PayFee Transaction", () => {
      describe("Validations", () => {
        it("should revert owner attempt to paying 1ETH as fee", async () => {
          const { deployedStudentRegistryV2, owner } = await loadFixture(deployUtil);
          await expect(
            deployedStudentRegistryV2.connect(owner).payFee({ value: convertEther("1") })
          ).to.be.revertedWith("Owner is excluded");
        });

        it("should revert attempt to proceed without paying 1ETH as fee", async () => {
          const { deployedStudentRegistryV2, addr1 } = await loadFixture(deployUtil);
          await expect(
            deployedStudentRegistryV2.connect(addr1).payFee({ value: convertEther("0") })
          ).to.be.revertedWith("You must pay fee");
        });
      });

      describe("Success", () => {
        it("should successfully process payment of 1 ETH fee", async () => {
          const { deployedStudentRegistryV2, addr1, deployedStudentRegistryV2Address, owner } = await loadFixture(
            deployUtil
          );

          // Fetch contract balance before payFee txn
          const initialContractBalance = await getBalance(deployedStudentRegistryV2Address);

          // Fetch addr1  balance of  before payFee txn
          const initialPayerBalance = await getBalance(addr1.address);

          // Perform the payment
          const tx = await deployedStudentRegistryV2.connect(addr1).payFee({ value: ethers.parseEther("1") });
          await tx.wait(); // Wait for the transaction to be mined

          // Fetch updated balances
          const finalPayerBalance = await getBalance(addr1.address);
          const finalContractBalance = await getBalance(deployedStudentRegistryV2Address);

          // Assert the balance changes
          const initialPayerBalanceNum = parseFloat(ethers.formatEther(initialPayerBalance));
          const finalPayerBalanceNum = parseFloat(ethers.formatEther(finalPayerBalance));
          const initialContractBalanceNum = parseFloat(ethers.formatEther(initialContractBalance));
          const finalContractBalanceNum = parseFloat(ethers.formatEther(finalContractBalance));

          // Check that the payer's balance decreased by 1 ETH
          expect(finalPayerBalanceNum).to.be.closeTo(initialPayerBalanceNum - 1, 0.01); // Use a tolerance for floating point comparison

          // Check that the contract's balance increased by 1 ETH
          expect(finalContractBalanceNum).to.be.closeTo(initialContractBalanceNum + 1, 0.01); // Use a tolerance for floating point comparison
        });
      });
      describe("Event", () => {
        it("should emit PaidFee", async () => {
          const { deployedStudentRegistryV2, addr1 } = await loadFixture(deployUtil);

          await expect(deployedStudentRegistryV2.connect(addr1).payFee({ value: ethers.parseEther("1") }))
            .to.emit(deployedStudentRegistryV2, "PaidFee")
            .withArgs(addr1.address, ethers.parseEther("1"));
        });
      });
    });
    describe("Registration", function () {
      describe("Validation", function () {
        it("should revert if the address is already registered", async () => {
          const { deployedStudentRegistryV2, owner, addr1 } = await loadFixture(deployUtil);

          // Make a payment first from addr1
          await deployedStudentRegistryV2.connect(addr1).payFee({ value: ethers.parseEther("1") });

          // Register addr1
          await deployedStudentRegistryV2.connect(owner).register(addr1.address, "Alice", 20);

          // Attempt to register the same address again and expect it to revert
          await expect(
            deployedStudentRegistryV2.connect(owner).register(addr1.address, "Alice", 20)
          ).to.be.revertedWith("You're already registered");
        });

        it("should revert if the student has not paid the fee", async () => {
          const { deployedStudentRegistryV2, owner, addr1 } = await loadFixture(deployUtil);

          await expect(
            deployedStudentRegistryV2.connect(owner).register(addr1.address, "Alice", 20)
          ).to.be.revertedWith("You must pay first");
        });

        it("should revert if the name is empty", async () => {
          const { deployedStudentRegistryV2, owner, addr1 } = await loadFixture(deployUtil);

          await deployedStudentRegistryV2.connect(addr1).payFee({ value: ethers.parseEther("1") });

          await expect(deployedStudentRegistryV2.connect(owner).register(addr1.address, "", 20)).to.be.revertedWith(
            "No name has been inputted"
          );
        });

        it("should revert if the age is below 18", async () => {
          const { deployedStudentRegistryV2, owner, addr1 } = await loadFixture(deployUtil);

          await deployedStudentRegistryV2.connect(addr1).payFee({ value: ethers.parseEther("1") });

          await expect(
            deployedStudentRegistryV2.connect(owner).register(addr1.address, "Alice", 17)
          ).to.be.revertedWith("Age should be 18 or more");
        });
      });
      describe("Registration Transcation", function () {
        it("should allow the owner to successfully register a student", async () => {
          const { deployedStudentRegistryV2, owner, addr1 } = await loadFixture(deployUtil);

          // Ensure the contract owner is correct
          let studentRegistryV2Owner = await deployedStudentRegistryV2.getOwner();
          expect(studentRegistryV2Owner).to.eq(owner.address);

          // Make a payment first from addr1
          const payFeeTx = await deployedStudentRegistryV2.connect(addr1).payFee({ value: ethers.parseEther("1") });
          await payFeeTx.wait(); // Ensure the transaction is mined before proceeding

          // Verify the payment status
          const hasPaid = await deployedStudentRegistryV2.hasPaidMapping(addr1.address);
          expect(hasPaid).to.be.true;

          // Perform registration as the owner
          const registerTx = await deployedStudentRegistryV2.connect(owner).register(addr1.address, "Alice", 20);
          await registerTx.wait();

          // Verify the student was added
          const student = await deployedStudentRegistryV2.tempstudentsMapping(addr1.address);
          expect(student.studentAddr).to.equal(addr1.address);
          expect(student.name).to.equal("Alice");
          expect(student.age).to.equal(20);
          expect(student.hasPaid).to.be.true;
          expect(student.isAuthorized).to.be.false;

          // Check that the event was emitted
          await expect(registerTx)
            .to.emit(deployedStudentRegistryV2, "registerStudent")
            .withArgs(addr1.address, "Alice", 20);
        });
      });
      describe("Event", () => {
        it("should emit registerStudent when registeration is successfull", async () => {
          const { deployedStudentRegistryV2, addr1, owner } = await loadFixture(deployUtil);

          // Make a payment first from addr1
          const payFeeTx = await deployedStudentRegistryV2.connect(addr1).payFee({ value: ethers.parseEther("1") });
          await payFeeTx.wait(); // Ensure the transaction is mined before proceeding

          const registerTx = await deployedStudentRegistryV2.connect(owner).register(addr1.address, "Alice", 20);
          await registerTx.wait();

          await expect(registerTx)
            .to.emit(deployedStudentRegistryV2, "registerStudent")
            .withArgs(addr1.address, "Alice", 20);
        });
      });
    });
    describe("Authorization", function () {
      describe("Validation", function () {
        it("should revert if the address is already authorized", async () => {
          const { deployedStudentRegistryV2, owner, addr1 } = await loadFixture(deployUtil);

          // Make a payment first from addr1
          await deployedStudentRegistryV2.connect(addr1).payFee({ value: ethers.parseEther("1") });

          // Register addr1 as a temporary student
          await deployedStudentRegistryV2.connect(owner).register(addr1.address, "Alice", 20);

          // Authorize the registered student
          await deployedStudentRegistryV2.connect(owner).authorizeStudentRegistration(addr1.address);

          // Attempt to authorize the same address again and expect it to revert
          await expect(
            deployedStudentRegistryV2.connect(owner).authorizeStudentRegistration(addr1.address)
          ).to.be.revertedWith("You're already authorized");
        });
        it("should allow the owner to authorize a registered student", async () => {
          const { deployedStudentRegistryV2, owner, addr1 } = await loadFixture(deployUtil);

          // Make a payment first from addr1
          await deployedStudentRegistryV2.connect(addr1).payFee({ value: ethers.parseEther("1") });

          // Register addr1 as a temporary student
          await deployedStudentRegistryV2.connect(owner).register(addr1.address, "Alice", 20);

          // Authorize the registered student
          const authorizeTx = await deployedStudentRegistryV2
            .connect(owner)
            .authorizeStudentRegistration(addr1.address);
          await authorizeTx.wait();

          it("should allow the owner to authorize a registered student", async () => {
            const { deployedStudentRegistryV2, owner, addr1, addr2 } = await loadFixture(deployUtil);

            // Make a payment first from addr1
            await deployedStudentRegistryV2.connect(addr1).payFee({ value: ethers.parseEther("1") });

            // Register addr1 as a temporary student
            await deployedStudentRegistryV2.connect(owner).register(addr1.address, "Alice", 20);

            // Authorize the registered student
            const authorizeTx = await deployedStudentRegistryV2
              .connect(owner)
              .authorizeStudentRegistration(addr1.address);
            await authorizeTx.wait();

            await expect(
              deployedStudentRegistryV2.connect(owner).authorizeStudentRegistration(addr2.address)
            ).to.be.revertedWith("Invalid Address");
          });
        });
      });
      describe("Only owner Authorization", function () {
        it("should authorize registered student", async () => {
          const { deployedStudentRegistryV2, owner, addr1 } = await loadFixture(deployUtil);

          await deployedStudentRegistryV2.connect(addr1).payFee({ value: ethers.parseEther("1") });
          await deployedStudentRegistryV2.connect(owner).register(addr1.address, "Alice", 20);

          expect(deployedStudentRegistryV2.connect(owner).authorizeStudentRegistration(addr1.address));
        });
      });
      describe("Event", function () {
        it("should emit authorizeStudentReg", async () => {
          const { deployedStudentRegistryV2, owner, addr1 } = await loadFixture(deployUtil);

          // Make a payment first from addr1
          await deployedStudentRegistryV2.connect(addr1).payFee({ value: ethers.parseEther("1") });

          // Register addr1 as a temporary student
          await deployedStudentRegistryV2.connect(owner).register(addr1.address, "Alice", 20);

          // Perform the authorization and expect the event
          await expect(deployedStudentRegistryV2.connect(owner).authorizeStudentRegistration(addr1.address))
            .to.emit(deployedStudentRegistryV2, "AuthorizeStudentReg")
            .withArgs(addr1.address);
        });
      });
    });
    describe("Add Student Functionality", function () {
      describe("Add student to the struct", function () {
        it("should add a student", async () => {
          const { deployedStudentRegistryV2, owner, addr1 } = await loadFixture(deployUtil);

          await deployedStudentRegistryV2.connect(addr1).payFee({ value: ethers.parseEther("1") });

          // Register addr1 as a temporary student
          await deployedStudentRegistryV2.connect(owner).register(addr1.address, "Alice", 20);

          // Authorize addr1 and add them as a student
          await deployedStudentRegistryV2.connect(owner).authorizeStudentRegistration(addr1.address);

          // Verify the student was added
          const student = await deployedStudentRegistryV2.studentsMapping(addr1.address);
          expect(student.studentAddr).to.equal(addr1.address);
          expect(student.name).to.equal("Alice");
          expect(student.age).to.equal(20);
          expect(student.hasPaid).to.be.true;
          expect(student.isAuthorized).to.be.false;
        });
      });
      describe("Event", function () {
        it("should emit", async () => {
          const { deployedStudentRegistryV2, owner, addr1 } = await loadFixture(deployUtil);

          await deployedStudentRegistryV2.connect(addr1).payFee({ value: ethers.parseEther("1") });

          // Register addr1 as a temporary student
          await deployedStudentRegistryV2.connect(owner).register(addr1.address, "Alice", 20);

          await expect(deployedStudentRegistryV2.connect(owner).authorizeStudentRegistration(addr1.address))
            .to.emit(deployedStudentRegistryV2, "AddStudent")
            .withArgs(addr1.address);
        });
      });
      // Check that the event was emitted
    });
  });
});
