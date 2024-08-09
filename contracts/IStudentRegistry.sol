// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import "contracts/StudentStruct.sol";

/**
 * @title IStudentRegistry
 * @dev Interface for the StudentRegistry contract.
 * Defines the functions available for interacting with the student registry.
 */
interface IStudentRegistry {


    /**
     * @dev pay Fees.
     */
    function payFees() external payable;

    /**
        @notice Withdraws the contract's balance to the owner.
        @dev This function should handle the transfer of funds from the contract to the owner.
        @return success A boolean indicating whether the withdrawal was successful.
    */
    function withdrawEarnings() external returns (bool);

    /**
     * @dev Register a student with the provided address, name, and age.
     * @param _studentAddress The address of the student to register.
     * @param _name The name of the student.
     * @param _age The age of the student.
     */
    function addStudent(address _studentAddress, string memory _name, uint8 _age) external payable;

    /**
     * @dev Authorize a student for registration by setting their status to authorized.
     * @param _studentAddress The address of the student to authorize.
     */
    function authorizeStudent(address _studentAddress) external;

    /**
     * @dev Retrieve a student information.
     * @param _studentAddress The address of the student to retrieve.
     */
    function getStudent(address _studentAddress) external view returns (Student memory);


    /**
     * @dev Update a student record.
     * @param _studentAddress The new address of the student.
     * @param _name The new name of the student.
     * @param _age The new age of the student.
     */
    function updateStudent(address _studentAddress, string memory _name, uint8 _age) external;


    /**
     * @dev Delete a student record.
     * @param _studentAddress The address of the student to delete.
     */
    function deleteStudent(address _studentAddress) external;

}