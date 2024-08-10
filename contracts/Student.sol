// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
    @title Student Struct
    @notice This struct represents the details of a student in the registry.
    @dev The struct is used to store and manage student information.
    @custom:property studentAddr, The Ethereum address associated with the student.
    @custom:property name, The name of the student.
    @custom:property studentId, The unique ID assigned to the student within the registry.
    @custom:property age, The unique ID assigned to the student within the registry.
    @custom:property hasPaid, A boolean indicating whether the student has completed the payment required for registration.
*/
struct Student {
    address studentAddr;
    string name;
    uint256 studentId;
    uint8 age;
    bool hasPaid;
}