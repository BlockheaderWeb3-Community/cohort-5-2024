// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract StudentCount {
    uint public studentId = 0;

    function getStudentMainId() internal view returns (uint) {
        return studentId;
    }

    function incrementStudentId() internal {
       studentId += 1;
    }
    
    function decrementStudentId() internal {
       studentId -= 1;
    }
}