// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;
import "./IStudentRegsr.sol";
import "./Student.sol";
import "./Ownable.sol";

contract MyStudentRegistry is Ownable {

    address private StudentRegistryContractAddress;

    constructor(address _studentRgistry){
        StudentRegistryContractAddress = _studentRgistry;
    }

    function registerStudents(
        address _studentAddr,
        string memory _name,
        uint8 _age
    ) public payable  onlyOwner {

        IStudentRegistry(StudentRegistryContractAddress).registerStudents(_studentAddr, _name, _age);
    }


    function authorizeStudents(
        address _studentId
    ) public {

        return IStudentRegistry(StudentRegistryContractAddress).authorizeStudent(_studentId);
    }

    function StudentUpdates(address _studentAddr, string memory _name, uint8 _age) public returns (Student memory) {
       return IStudentRegistry(StudentRegistryContractAddress).updateStudent(_studentAddr, _name, _age);
    } 

    function getStudentFromMappings(address _studentAddr) public view returns (Student memory) {
        return IStudentRegistry(StudentRegistryContractAddress).getStudentFromMapping(_studentAddr);
    }

    function deleteStudents(address _studentAddr) public {
        IStudentRegistry(StudentRegistryContractAddress).deleteStudent(_studentAddr);
    }

    function modifyOwners(address _newOwner) public {
        IStudentRegistry(StudentRegistryContractAddress).modifyOwner(_newOwner);
    }

    function withdraws() public {
        IStudentRegistry(StudentRegistryContractAddress).withdraw();
    }

    function getsBalance() public  view returns (uint256) {
        return IStudentRegistry(StudentRegistryContractAddress).getBalance();
    }

}