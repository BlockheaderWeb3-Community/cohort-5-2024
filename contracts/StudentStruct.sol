// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

/**
 * @title Student
 * @dev Struct for storing student information.
 */
struct Student {
    /**
     * @dev The address of the student.
     */
    address studentAddr;

    /**
     * @dev The unique ID assigned to the student.
     */
    uint32 studentId;

    /**
     * @dev The name of the student.
     */
    string name;

    /**
     * @dev The age of the student.
     */
    uint8 age;

    /**
     * @dev The authorization status of the student.
     * True if the student is authorized, false otherwise.
     */
    bool isAuthorized;
}
