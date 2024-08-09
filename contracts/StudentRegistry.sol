// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "contracts/StudentStruct.sol";
import "contracts/Ownable.sol";
import "contracts/StudentCounter.sol";

/**
 * @title StudentRegistry
 * @dev This contract manages student registrations, authorization, and details.
 * It allows for student registration with payment, updating student information, and handling ownership.
 */
contract StudentRegistry is Ownable, StudentCounter{
    
    event PaymentStatus(bool indexed  hasPaid, string message);

    // Mapping of student address to their details
    mapping (address => Student) private myStudents;
    // Mapping of student address to their payment receipt amount
    mapping  (address => uint256) public receipt;
    // Mapping of student address to their student ID
    mapping  (address => uint32) public myStudentId;

    /**
     * @dev Modifier to ensure that the address is not the zero address.
     */
    modifier notAddress() {
        require(msg.sender != address(0), "Invalid address");
        _;
    }

     /**
     * @dev Modifier to ensure the age is 18 or older.
     * @param _age The age to check.
     */
     modifier notUpToAge(uint8 _age) {
        require(_age >= 18, "Not up to age");
        _;
    }

    /**
     * @dev Modifier to ensure the name is not empty.
     * @param _name The name to check.
     */
    modifier nameNoEmpty(string memory _name) {
        require(bytes(_name).length != 0, "Name must not be empty");
        _;
    }

    /**
     * @dev Register a student with a given address, name, and age.
     * Requires payment of exactly 1 ether.
     * @param _studentAddr The address of the student.
     * @param _name The name of the student.
     * @param _age The age of the student.
     */
    function registerStudent(address _studentAddr, string memory _name, uint8 _age) public payable notAddress notUpToAge(_age) nameNoEmpty(_name) {
        uint256 amount = msg.value;
        uint256 hasPaid = receipt[_studentAddr];
        
        require(hasPaid == 0 ether, "You have registered");


        require(amount == 1 ether, "You must pay exactly 1 eth");

        Student memory student = Student({
            studentAddr: _studentAddr,
            studentId: 0,
            name: _name,
            age: _age,
            isAuthorized: false
        });

        myStudents[_studentAddr] = student;
        receipt[_studentAddr] = amount;

        emit PaymentStatus(true, "Payment successful!!");
    }

    /**
     * @dev Authorize a student. Only the contract owner can authorize students.
     * @param _studentAddr The address of the student to authorize.
     */
    function authorizeStudent(address _studentAddr) public onlyOwner  {
        require(receipt[_studentAddr] == 1 ether, "Go and register");

        Student storage students = myStudents[_studentAddr];
        students.isAuthorized = true;
        students.studentId = getStudentId();
        increaseStudentId();

        myStudentId[_studentAddr] = studentId;

    }

    /**
     * @dev Retrieve student information.
     * @param _studentAddr The address of the student.
     * @return The student details.
     */
    function getStudent(address _studentAddr) public view returns  (Student memory) {
        return myStudents[_studentAddr];
    }

    /**
     * @dev Update student information.
     * Can change the address, name, or age of the student. Only the owner can update.
     * @param _studentAddr The new address of the student.
     * @param _name The new name of the student.
     * @param _age The new age of the student.
     */
    function updateStudent( address _studentAddr, string memory _name, uint8 _age) public  notAddress notUpToAge(_age) nameNoEmpty(_name) {
        Student storage student = myStudents[_studentAddr];
        student.name = _name;
        student.age = _age;
    }

    /**
     * @dev Delete a student's record. Only the owner can delete a student.
     * @param _studentAddr The address of the student to delete.
     */
    function deleteStudent(address _studentAddr) public onlyOwner {
        require(myStudents[_studentAddr].studentAddr != address(0), "Student does not exist");

        delete myStudents[_studentAddr];
        myStudentId[_studentAddr] = getStudentId();
        decreaseStudentId();

    }
    
    /**
     * @dev Withdraw all Ether from the contract to the owner's address.
     */
    function withdraw() public  {

        uint256 balance = address(this).balance;
        require(balance > 0, "Insufficient funds");

        (bool success,) = owner.call{value: balance}("");
        require(success, "Failed to send Ether");

    }
 
    /**
     * @dev Allow the contract to receive Ether.
     */
    receive() external payable { }

    /**
     * @dev Change the owner of the contract.
     * @param _newOwner The address of the new owner.
     */
    function modifyOwner(address payable  _newOwner) public onlyOwner {
        changeOwner(_newOwner);
    }
}
