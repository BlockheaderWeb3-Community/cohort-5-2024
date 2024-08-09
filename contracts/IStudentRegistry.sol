// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;
import "contracts/StudentStruct.sol";

/**
 * @title IStudentRegistry
 * @dev Interface for the StudentRegistry contract.
 * Defines the functions available for interacting with the student registry.
 */
interface IStudentRegistry {
    /**
     * @dev Register a student with the provided address, name, and age.
     * @param _studentAddr The address of the student to register.
     * @param _name The name of the student.
     * @param _age The age of the student.
     */
    function registerStudent(address _studentAddr, string memory _name, uint8 _age) external payable;

    /**
     * @dev Authorize a student for registration by setting their status to authorized.
     * @param _studentAddr The address of the student to authorize.
     */
    function authorizeStudent(address _studentAddr) external;

    /**
     * @dev Retrieve a student's information.
     * @param _studentAddr The address of the student to retrieve.
     */
    function getStudent(address _studentAddr) external view returns (Student memory);

    /**
     * @dev Update a student's information, including potentially changing their address.
     * @param _studentAddr The new address of the student.
     * @param _name The new name of the student.
     * @param _age The new age of the student.
     */
    function updateStudent(address _studentAddr, string memory _name, uint8 _age) external;

     /**
     * @dev Delete a student's record.
     * @param _studentAddr The address of the student to delete.
     */
    function deleteStudent(address _studentAddr) external;

}



