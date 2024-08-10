// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;
import "./IStudentRegistry.sol";
import "./Student.sol";
import "./Ownable.sol";


// Pay 1 Eth to register a student
// Collect student's name, age, address
// Admin should add registered students to the Registry
// Check if the students has paid.(hasPaid => Student)
// 

contract MyStudentRegistry is Ownable {

    address private StudentRegistryContractAddress;

    constructor(address _studentRgistry){
        StudentRegistryContractAddress = _studentRgistry;
    }

    function registerStudent(
        address _studentAddr,
        string memory _name,
        uint8 _age
    ) public onlyOwner {

        IStudentRegistry(StudentRegistryContractAddress).addStudent(_studentAddr, _name, _age);
    }


    function getStudent2(
        uint8 _studentId
    ) public view returns (Student memory) {

        return IStudentRegistry(StudentRegistryContractAddress).getStudent(_studentId);
    }
}