const { time,
    loadFixture,
} = require("@nomicfoundation/hardhat-network-helpers");

const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("StudentRegistry", () => {
    async function deployStudentRegistry() {
        const [owner, addr1, addr2] = await ethers.getSigners();

        const StudentRegistry = await ethers.getContractFactory("StudentRegistry");
        const studentRegistry = await StudentRegistry.deploy();

        return { studentRegistry, owner, addr1, addr2 };
    }

    describe("Deployment", () => {
        it("Should set the right owner", async () => {
            const { studentRegistry, owner } = await loadFixture(deployStudentRegistry);
            expect(await studentRegistry.owner()).to.equal(owner.address);
        });
    });

    describe("Adding Students", () => {
        it("Should add a student successfully", async () => {
            const { studentRegistry, addr1 } = await loadFixture(deployStudentRegistry);
            await studentRegistry.addStudent(addr1.address, "Alice", 20, false);
            const student = await studentRegistry.getStudentFromMapping(addr1.address);
            expect(student.name).to.equal("Alice");
            expect(student.age).to.equal(20);
            expect(student.hasPaid).to.equal(false);
        });

        it("Should revert if name is empty", async () => {
            const { studentRegistry, addr1 } = await loadFixture(deployStudentRegistry);
            await expect(studentRegistry.addStudent(addr1.address, "", 20, false))
                .to.be.revertedWithCustomError(studentRegistry, "NameIsEmpty");
        });

        it("Should revert if age is under 18", async () => {
            const { studentRegistry, addr1 } = await loadFixture(deployStudentRegistry);
            await expect(studentRegistry.addStudent(addr1.address, "Bob", 17, false))
                .to.be.revertedWithCustomError(studentRegistry, "UnderAge");
        });

        it("Should only allow owner to add students", async () => {
            const { studentRegistry, addr1, addr2 } = await loadFixture(deployStudentRegistry);
            await expect(studentRegistry.connect(addr1).addStudent(addr2.address, "Charlie", 25, false))
                .to.be.revertedWith(studentRegistry, "Caller is not the owner");
        });
    });

    describe("Getting Students", () => {
        async function addStudentFixture() {
            const { studentRegistry, owner, addr1, addr2 } = await loadFixture(deployStudentRegistry);
            await studentRegistry.addStudent(addr1.address, "Alice", 20, false);
            return { studentRegistry, owner, addr1, addr2 };
        }

        it("Should get a student by ID", async () => {
            const { studentRegistry } = await loadFixture(addStudentFixture);
            const student = await studentRegistry.getStudent(1);
            expect(student.name).to.equal("Alice");
        });

        it("Should get a student from mapping", async () => {
            const { studentRegistry, addr1 } = await loadFixture(addStudentFixture);
            const student = await studentRegistry.getStudentFromMapping(addr1.address);
            expect(student.name).to.equal("Alice");
        });
    });

    describe("Registering Students", () => {
        it("Should register a student with payment", async () => {
            const { studentRegistry, owner, addr1 } = await loadFixture(deployStudentRegistry);
            const registerTx = await studentRegistry.connect(addr1).register(
                addr1.address,
                owner.address,
                ethers.utils.parseEther("1"),
                "Dave",
                1,
                25,
                { value: ethers.utils.parseEther("1") }
            );

            await expect(registerTx).to.emit(studentRegistry, "paid")
                .withArgs(addr1.address, owner.address, ethers.utils.parseEther("1"));

            const student = await studentRegistry.getStudentFromMapping(addr1.address);
            expect(student.name).to.equal("Dave");
            expect(student.hasPaid).to.equal(true);
        });

        it("Should revert if not enough ether sent", async () => {
            const { studentRegistry, owner, addr1 } = await loadFixture(deployStudentRegistry);
            await expect(studentRegistry.connect(addr1).register(
                addr1.address,
                owner.address,
                ethers.utils.parseEther("0.5"),
                "Eve",
                2,
                22,
                { value: ethers.utils.parseEther("0.5") }
            )).to.be.revertedWith("You have to send 1 ether to register");
        });
    });

    describe("Deleting Students", () => {
        async function addStudentFixture() {
            const { studentRegistry, owner, addr1, addr2 } = await loadFixture(deployStudentRegistry);
            await studentRegistry.addStudent(addr1.address, "Alice", 20, false);
            return { studentRegistry, owner, addr1, addr2 };
        }

        it("Should delete a student", async () => {
            const { studentRegistry, addr1 } = await loadFixture(addStudentFixture);
            await studentRegistry.deleteStudent(addr1.address);
            const student = await studentRegistry.getStudentFromMapping(addr1.address);
            expect(student.studentAddr).to.equal(ethers.constants.AddressZero);
        });

        it("Should only allow owner to delete students", async () => {
            const { studentRegistry, addr1 } = await loadFixture(addStudentFixture);
            await expect(studentRegistry.connect(addr1).deleteStudent(addr1.address))
                .to.be.revertedWith("Caller is not the owner");
        });
    });

    describe("Transferring and Withdrawing", () => {
        async function registerStudentFixture() {
            const { studentRegistry, owner, addr1, addr2 } = await loadFixture(deployStudentRegistry);
            await studentRegistry.connect(addr1).register(
                addr1.address,
                owner.address,
                ethers.utils.parseEther("1"),
                "Alice",
                1,
                20,
                { value: ethers.utils.parseEther("1") }
            );
            return { studentRegistry, owner, addr1, addr2 };
        }

        it("Should transfer ether to a specified address", async () => {
            const { studentRegistry, addr2 } = await loadFixture(registerStudentFixture);
            const initialBalance = await ethers.provider.getBalance(addr2.address);
            await studentRegistry.transfer(addr2.address, ethers.utils.parseEther("0.5"));
            const finalBalance = await ethers.provider.getBalance(addr2.address);
            expect(finalBalance.sub(initialBalance)).to.equal(ethers.utils.parseEther("0.5"));
        });

        it("Should withdraw all ether to the owner", async () => {
            const { studentRegistry, owner } = await loadFixture(registerStudentFixture);
            const initialBalance = await ethers.provider.getBalance(owner.address);
            const tx = await studentRegistry.withdraw();
            const receipt = await tx.wait();
            const gasUsed = receipt.gasUsed.mul(tx.gasPrice);
            const finalBalance = await ethers.provider.getBalance(owner.address);
            expect(finalBalance.add(gasUsed).sub(initialBalance)).to.equal(ethers.utils.parseEther("1"));
        });
    });

    describe("Modifying Owner", () => {
        it("Should allow owner to change ownership", async () => {
            const { studentRegistry, addr1 } = await loadFixture(deployStudentRegistry);
            await studentRegistry.modifyOwner(addr1.address);
            expect(await studentRegistry.owner()).to.equal(addr1.address);
        });

        it("Should not allow non-owner to change ownership", async () => {
            const { studentRegistry, addr1, addr2 } = await loadFixture(deployStudentRegistry);
            await expect(studentRegistry.connect(addr1).modifyOwner(addr2.address))
                .to.be.revertedWith("Caller is not the owner");
        });
    });
});