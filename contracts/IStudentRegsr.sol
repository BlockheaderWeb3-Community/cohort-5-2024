// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import "./Student.sol";
interface IStudentRegistry {


    function registerStudents(
        address _studentAddr,
        string memory _name,
        uint8 _age
    ) external payable ;

    function authorizeStudent(address _studentAddr) external;

    function updateStudent(address _studentAddr, string memory _name, uint8 _age) external returns (Student memory);

    function getStudentFromMapping(address _studentAddr) external view returns (Student memory);

    function deleteStudent(address _studentAddr) external;

    function modifyOwner(address _newOwner) external ;

    function withdraw() external ;

    function getBalance() external view returns (uint256);
    
}