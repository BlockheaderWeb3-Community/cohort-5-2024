// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

/**
 * @title StudentCounter
 * @dev This contract is used to manage and track student IDs.
 * It includes functions to get, increase, and decrease the student ID.
 */
contract StudentCounter {
    uint32 internal  studentId = 0;

    /**
     * @dev Retrieve the current student ID.
     * @return The current student ID.
     */
    function getStudentId() internal  view returns (uint32) {
        return studentId;
    }

    /**
     * @dev Increase the student ID by 1.
     */
    function increaseStudentId() internal  {
        studentId++;
    }

     /**
     * @dev Decrease the student ID by 1.
     */
    function decreaseStudentId() internal  {
        studentId--;
    }
}


