// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import "./Student.sol";

/**
    @title IStudentRegistry Interface
    @author Abeeujah <abeeujah@gmail.com>, Zintarh, David Nnamdi.
    @notice BlockHeader BootCamp, Cohort-5.
    @notice This interface defines the standard functions for interacting with a Student Registry contract.
    @dev Contracts implementing this interface must provide implementations for all functions.
*/
interface IStudentRegistry {
    /**
        @notice Adds a new student to the registry.
        @dev This function should be called to register a new student with their address, name, and age.
        @param _studentAddr The unique address of the student.
        @param _name The name of the student.
        @param _age The age of the student.
    */
    function addStudent(
        address _studentAddr,
        string memory _name,
        uint8 _age
    ) external;

    /**
        @notice Retrieves a student's details using their student ID.
        @dev This function returns the Student struct associated with the given student ID.
        @param _studentID The unique ID of the student.
        @return student The `Student` struct containing the student's details.
    */
    function getStudent(
        uint8 _studentID
    ) external view returns (Student memory);

    /**
        @notice Retrieves a student's details using their address.
        @dev This function returns the Student struct associated with the given student address.
        @param _studentAddr The address of the student.
        @return student The Student struct containing the student's details.
    */
    function getStudentFromMapping(
        address _studentAddr
    ) external view returns (Student memory);

    /**
        @notice Registers a student with their details and requires a payment.
        @dev This function should handle the registration process including payment verification.
        @param _studentAddr The address of the student.
        @param _age The age of the student.
        @param _name The name of the student.
        @return success A boolean indicating whether the registration was successful.
    */
    function registerStudent(
        address _studentAddr,
        uint8 _age,
        string memory _name
    ) external payable returns (bool);

    /**
        @notice Authorizes a student's registration, adding them to the registry.
        @dev This function should be called after successful registration to officially add the student to the registry.
        @param _studentAddr The address of the student to be authorized.
        @return success A boolean indicating whether the authorization was successful.
    */
    function authorizeStudentRegistration(
        address _studentAddr
    ) external returns (bool);

    /**
        @notice Updates a student's details in the registry.
        @dev This function should be used to modify the student's age and/or name.
        @param _studentAddr The address of the student to update.
        @param _age The new age of the student.
        @param _name The new name of the student.
        @return updatedStudent The updated Student struct containing the new details.
    */
    function updateStudent(
        address _studentAddr,
        uint8 _age,
        string memory _name
    ) external returns (Student memory);

    /**
        @notice Withdraws the contract's balance to the owner.
        @dev This function should handle the transfer of funds from the contract to the owner.
        @return success A boolean indicating whether the withdrawal was successful.
    */
    function withdraw() external returns (bool);

    /**
        @notice Retrieves the current balance of the contract.
        @dev This function returns the balance in the contract, usually in Ether.
        @return balance The current balance of the contract.
    */
    function getBalance() external view returns (uint256);

    /**
        @notice Deletes a student from the registry.
        @dev This function should be used to remove a student's record from the registry.
        @param _studentAddr The address of the student to be deleted.
    */
    function deleteStudent(address _studentAddr) external;
}
