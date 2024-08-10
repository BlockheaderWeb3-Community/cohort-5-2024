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

     function registerStudent(
        address _studentAddr,
        uint8 _age,
        string memory _name
    ) external payable returns (bool);

     function authorizeStudentRegistration(
        address _studentAddr
    ) external returns (bool);

     function updateStudent(
        address _studentAddr,
        uint8 _age,
        string memory _name
    ) external returns (Student memory);

     function withdraw() external returns (bool);

    function getBalance() external view returns (uint256);

    function deleteStudent(address _studentAddr) external;

}
