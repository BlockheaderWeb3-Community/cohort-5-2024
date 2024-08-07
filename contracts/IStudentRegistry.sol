// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import "./Student.sol";
interface IStudentRegistry {
    

    function addStudent(
        address _studentAddr,
        string memory _name,
        uint8 _age,
        uint256 _price
    ) external payable;

    function getStudent(uint8 _studentID) external view returns (Student memory);

    function getStudentFromMapping(address _studentAddr) external view returns (Student memory);

    function confirmAllStudents() external payable;

}

interface IOwnable{
    function getBalance() external view returns (uint256);
}
