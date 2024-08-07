// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;
import "./IStudentRegistry.sol";
import "./Student.sol";
import "./Ownable.sol";

contract MyStudentRegistry is Ownable {

    address private StudentRegistryContractAddress;

    constructor(address _studentRegistry){
        StudentRegistryContractAddress = _studentRegistry;
    }

    function registerStudent(
        address _studentAddr,
        string memory _name,
        uint8 _age
    ) public payable {

        require(msg.value == 1 ether, "You need to send exactly 1 ether to register");
        IStudentRegistry(StudentRegistryContractAddress).addStudent{value: msg.value}(_studentAddr, _name, _age, msg.value);
    }

    function confirmAllStudents() public payable { 
        IStudentRegistry(StudentRegistryContractAddress).confirmAllStudents();
    } 

    function getStudent2(
        uint8 _studentId
    ) public view returns (Student memory) {

        return IStudentRegistry(StudentRegistryContractAddress).getStudent(_studentId);
    }
}
