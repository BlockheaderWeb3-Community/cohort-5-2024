const { time, loadFixture } = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");
const { ethers } = require("hardhat");

const convertEther = (amount) => {
  return ethers.parseEther(amount);
};

async function deployUtil() {
  const StudentRegistryV2 = await ethers.getContractFactory("StudentRegistryV2");
  const deployedStudentRegistryV2 = await StudentRegistryV2.deploy(); // Deployment
  await deployedStudentRegistryV2.deployed(); // Wait for deployment to be mined
  return deployedStudentRegistryV2;
}

describe("StudentRegistryV2 Test Suite", function () {
  async function deployUtil() {
    const StudentRegistryV2 = await ethers.getContractFactory("StudentRegistryV2");
    const deployedStudentRegistryV2 = await StudentRegistryV2.deploy();
    await deployedStudentRegistryV2.deployed();
    return deployedStudentRegistryV2;
  }

  let deployedStudentRegistryV2;

  async function () {
    deployedStudentRegistryV2 = await deployUtil();
  }

  it("should deploy successfully and return default values of count", async function () {
    const count = await deployedStudentRegistryV2.count();
    expect(count).to.equal(0); // Replace this with the expected default value
  });

  // Additional test cases...
});
