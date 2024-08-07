// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;
import "./IStudentRegistry.sol";
import "./Student.sol";
import "./Ownable.sol";

contract MyStudentRegistry is Ownable {

    address private StudentRegistryContractAddress;

    constructor(address _studentRgistry){
        StudentRegistryContractAddress = _studentRgistry;
    }

    function authorizeRegisteredStudent(
        address _studentAddr,
        string memory _name,
        uint8 _age
    ) public payable  {

        IStudentRegistry(StudentRegistryContractAddress).authorizeStudentRegistration(address _studentAddr)  public onlyOwner;
    }


    function getStudent2(
        uint8 _studentId
    ) public view returns (Student memory) {

        return IStudentRegistry(StudentRegistryContractAddress).getStudent(_studentId);
    }
}


