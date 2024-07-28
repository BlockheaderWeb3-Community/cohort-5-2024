// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title Input Validation Contract
/// @notice This contract contains modifiers to validate inputs for student registration
contract InputValidation {
   
    /// @notice Modifier to validate the age of the student
    /// @dev Ensures that the student is at least 18 years old
    /// @param _age The age of the student
    modifier validateStudentAge(uint256 _age) {
        require( _age >= 18, "This student is under age");
        _;
    }

    /// @notice Modifier to validate the name of the student
    /// @dev Ensures that the name is not blank
    /// @param _name The name of the student
    modifier validateStudentName(string memory _name) {
       require( bytes(_name).length > 0, "Name cannot be blank");
        _;
    }

    /// @notice Modifier to validate the ID of the student
    /// @dev Ensures that the student ID is greater than zero
    /// @param _studentId The ID of the student
    modifier validateStudentId(uint8 _studentId) {
        require(_studentId > 0, "Invalid Student ID");
        _;
    }

    /// @notice Modifier to validate the address of the student
    /// @dev Ensures that the address is not the zero address
    /// @param _studentAddr The address of the student
     modifier validateStudentAddress(address _studentAddr) {
        require( _studentAddr != address(0), "Invalid Address");
        _;
    }
}