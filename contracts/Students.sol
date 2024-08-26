// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./StudentStruct.sol";
import "./modifiers/Ownable.sol";
import "./modifiers/InputValidations.sol";
import "./Payment.sol";



/**
 * @title Students
 * @dev This contract manages student registrations, authorization, and details.
 * It allows for student registration with payment, updating student information, and handling ownership.
 */
contract Students is Payment, InputValidation, Ownable {
   event createEvent(address indexed  studentAddress, string message);
   event updateEvent(address indexed  studentAddress, string message);
    // Mapping of student address to their details
    mapping (address => Student) private students;
    uint256 private  studentCount = 0;
    

    /**
     * @dev Register a student with a given address, name, and age.
     * Requires payment of exactly 1 ether.
     * @param _studentAddress The address of the student.
     * @param _name The name of the student.
     * @param _age The age of the student.
     */
    
    function addStudent(address _studentAddress, string memory _name, uint8 _age) public validateAddress(_studentAddress) validateStudentAge(_age) validateStudentName(_name) onlyOwner {
      
        uint256 hasPaid = PaymentDetails[_studentAddress];

        require(hasPaid > 0 ether, "payment required");

        uint256 _studentId = studentCount + 1;
        Student memory student = Student({
            studentAddress: _studentAddress,
            name: _name,
            age: _age,
            studentId: _studentId,
            hasPaid:true
        });

        // add student to students Mapping
        students[_studentAddress] = student;
        emit createEvent(_studentAddress, "student added");
    }

    /**
     * @dev Retrieve the student by address.
     * @return The student record.
     */
    function getStudent(address _studentaddr)
        public
        view
        validateAddress(_studentaddr)
        returns (Student memory)
    {  
        require(students[_studentaddr].studentAddress != address(0), "student does not exist");
        return students[_studentaddr];
    }



    /**
     * @dev Delete a student record. Only the owner can delete a student.
     * @param _studentAddr The address of the student to delete.
     */
    function deleteStudent(address _studentAddr)
        public
        onlyOwner
        validateAddress(_studentAddr)
    {
        require(
            students[_studentAddr].studentAddress != address(0),
            "Student does not exist"
        );

        delete students[_studentAddr];
    }



    /**
     * @dev Update student record.
     * Can change name, or age of the student. Only the owner can update.
     * @param _studentAddr The new address of the student.
     * @param _name The new name of the student.
     * @param _age The new age of the student.
     */
    function updateStudent(
        address _studentAddr,
        string memory _name,
        uint8 _age
    ) public validateAddress(_studentAddr) {
require(
            students[_studentAddr].studentAddress != address(0),
            "Student does not exist"
        );

        Student memory student = students[_studentAddr];
        student.name = _name;
        student.age = _age;
        students[_studentAddr] = student;
         emit updateEvent(_studentAddr, "update successful");
    }

    /**
     * @dev Allow the contract to receive Ether.
     */
    receive() external payable { }
}