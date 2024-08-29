const {
    time,
    loadFixture,
  } = require("@nomicfoundation/hardhat-toolbox/network-helpers");
  const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
  const { expect } = require("chai");
  // const { ethers } = require("hardhat");
  
  describe("Counter Test Suite", () => {
    // deploy util function
    const deployUtil = async () => {
      const Counter = await ethers.getContractFactory("Counter"); // instance of Counter contract in Contracts folder
      const deployedCounter = await Counter.deploy(); // the deployed version of the Counter contract in the network
      return deployedCounter; // returning the deployed counter instance
    };
  
    describe("Deployment", () => {
      it("should deploy succesfuly and return default values of count", async () => {
        const deployedCounter = await loadFixture(deployUtil);
  
        // check initial value of count
        let initialCountValue = await deployedCounter.count();
        expect(initialCountValue).to.eq(0); // assertion that the value of  count variable upon deployment is 0
      });
    });
  
    describe("Transactions", () => {
      describe("Increase Count Transactions", () => {
        it("should increase count by one", async () => {
          const deployedCounter = await loadFixture(deployUtil);
  
          // check initial value of count before increase count txn
          const count1 = await deployedCounter.count();
          console.log("count 1___", count1);
          expect(count1).to.eq(0);
  
          // check count value after increase count txn
          await deployedCounter.increaseByOne();
  
          const count2 = await deployedCounter.count();
          expect(count2).to.eq(1);
  
          // check count value after 2nd increase count txn
          await deployedCounter.increaseByOne();
  
          const count3 = await deployedCounter.count();
          expect(count3).to.eq(2);
          console.log("count 3", count3);
        });
      });
  
      describe("Decrease Count Transactions", () => {
        describe("Successful Decrease", () => {
          it("should decrease count by one", async () => {
            const deployedCounter = await loadFixture(deployUtil);
  
            // check initial value of count before increase count txn
            const count1 = await deployedCounter.count();
            console.log("count 1___", count1);
            expect(count1).to.eq(0);
  
            // check count value after increase count txn
            await deployedCounter.increaseByOne();
  
            const count2 = await deployedCounter.count();
            expect(count2).to.eq(1); // 1
  
            // check count value after 2nd increase count txn
            await deployedCounter.decreaseByOne();
  
            const count3 = await deployedCounter.count();
            expect(count3).to.eq(0);
            console.log("count 3", count3); // 0
          });
        });
  
        describe("Validations", () => {
          it("should revert attempt to decrease below 0", async () => {
            const deployedCounter = await loadFixture(deployUtil);
  
            // check initial value of count before increase count txn
            const count1 = await deployedCounter.count();
            console.log("count 1___", count1);
            expect(count1).to.eq(0);
  
            // check count value after increase count txn
            await deployedCounter.increaseByOne();
  
            const count2 = await deployedCounter.count();
            expect(count2).to.eq(1); // 1
  
            // check count value after 2nd increase count txn
            await deployedCounter.decreaseByOne();
  
            const count3 = await deployedCounter.count();
            expect(count3).to.eq(0);
            console.log("count 3", count3); // 0
  
           await expect( deployedCounter.decreaseByOne()).to.be.rejectedWith("cannot decrease below 0")
          });
        });
      });
    });

    describe("Events", () => {
      it("should emit an event when count is increased", async () => {
        const deployedCounter = await loadFixture(deployUtil);

        const count1 = await deployedCounter.count();
        console.log("count1 ___", count1);
        expect(count1).to.eq(0);

        await expect(deployedCounter.increaseByOne())
        .to.emit(deployedCounter, "CountIncreased")
        .withArgs(count1 + BigInt(1), anyValue)
      })

      it("should emit an event when count is decreased", async () => {
        const deployedCounter = await loadFixture(deployUtil);

        await deployedCounter.increaseByOne();

        const count1 = await deployedCounter.count();
        console.log("count1 ____", count1);
        expect(count1).to.eq(1);

        await expect(deployedCounter.decreaseByOne())
        .to.emit(deployedCounter, "CountDecreased")
        .withArgs(count1 - BigInt(1), anyValue)
      })
    });
  });
  