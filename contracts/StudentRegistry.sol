// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "contracts/modifiers/Ownable.sol";
import "./IStudentRegistry.sol";
/**
 * @title MyStudentRegistry
 * @dev This contract acts as a proxy to interact with another StudentRegistry contract.
 * It forwards calls to the `StudentRegistry` contract for student management functions.
 */
contract StudentRegistry is Ownable {
    address public studentsContractAddress;

    /**
     * @dev Set the address of the Students contract.
     * @param _studentsContractAddr The address of the Student contract.
     */
    constructor(address _studentsContractAddr) {
        studentsContractAddress = _studentsContractAddr;
    }

    /**
     * @dev Register a student.
     * @param _studentAddress The address of the student to register.
     * @param _name The name of the student.
     * @param _age The age of the student.
     */
    function addStudents(address _studentAddress, string memory _name, uint8 _age) public  {
        IStudentRegistry(studentsContractAddress).addStudent(_studentAddress, _name, _age);
    }

    /**
     * @dev Retrieve a student record.
     * @param _studentAddr The address of the student to retrieve.
     */
    function getStudents(address _studentAddr) public view returns (Student memory) {
        return IStudentRegistry(studentsContractAddress).getStudent(_studentAddr);
    }

    /**
     * @dev Update a student record.
     * @param _studentAddr The new address of the student.
     * @param _name The new name of the student.
     * @param _age The new age of the student.
     */
    function updateStudents(
        address _studentAddr, 
        string memory _name, 
        uint8 _age
    ) public {
        IStudentRegistry(studentsContractAddress).updateStudent(_studentAddr, _name, _age);
    }


     /**
     * @dev Delete a student record.
     * @param _studentAddr The address of the student to delete.
     * @notice  only owner can delete a student
     */
    function removeStudent(address _studentAddr) public {
        IStudentRegistry(studentsContractAddress).deleteStudent(_studentAddr);
    }


    /**
        @notice Pay Fees.
        @dev This function calls the payFees function in the external contract..
    */
    function payFees() public payable  {
        return IStudentRegistry(studentsContractAddress).payFees{value: msg.value}();
    }

        /**
        @notice Withdraws the contract's balance from the external Student Registry contract.
        @dev This function calls the withdraw function in the external contract.
        @return success A boolean value indicating whether the withdrawal was successful.
    */
    function withdrawEarnings() public returns (bool) {
        return IStudentRegistry(studentsContractAddress).withdrawEarnings();
    }

    /**
     * @dev Allow the contract to receive Ether.
     */
    receive() external payable { }
}