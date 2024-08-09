// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title Student
 * @dev A Struct containing student information.
 */
struct Student {
    /**
     * @dev The address of the student.
     */
    address studentAddress;

    /**
     * @dev The unique ID assigned to the student.
     */
    uint256 studentId;

    /**
     * @dev The name of the student.
     */
    string name;

    /**
     * @dev The age of the student.
     */
    uint8 age;

    /**
     * @dev student authorization status.
     */
    bool hasPaid;
}
