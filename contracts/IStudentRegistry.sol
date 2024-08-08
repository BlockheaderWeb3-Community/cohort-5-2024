// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import "./Student.sol";
interface IStudentRegistry {
    

    function addStudent(
        address _studentAddr,
        string memory _name,
        uint8 _age
    ) external;

    function getStudent(uint8 _studentID) external view returns (Student memory);

    function getStudentFromMapping(address _studentAddr) external view returns (Student memory);

}
