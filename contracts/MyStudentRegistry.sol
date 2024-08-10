// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.24;
import "./IStudentRegistry.sol";
import "./Student.sol";
import "./Ownable.sol";

/**
    @title MyStudentRegistry Contract
    @author Henry Peters.
    @notice BlockHeader BootCamp, Cohort-5.
    @notice This contract uses the Student Registry contract interface, allowing for student registration, updates, and other management functions.
    @dev This contract interacts with an external Student Registry contract defined by IStudentRegistry.
*/
contract MyStudentRegistry is Ownable {
    /// @notice The address of the external Student Registry contract.
    address private StudentRegistryContractAddress;

    /**
        @notice The constructor sets the address of the Student Registry contract when the contract is deployed.
        @param _studentRegistry The address of the deployed Student Registry contract.
    */
    constructor(address _studentRegistry) {
        StudentRegistryContractAddress = _studentRegistry;
    }

    /**
        @notice Registers a student by calling the addStudent function in the external Student Registry contract.
        @dev This function passes the student's address, name, and age to the external contract for registration.
        @param _studentAddr The unique address of the student.
        @param _name The name of the student.
        @param _age The age of the student.
    */
    function registerStudent(
        address _studentAddr,
        string memory _name,
        uint8 _age
    ) public payable {
        IStudentRegistry(StudentRegistryContractAddress).addStudent(
            _studentAddr,
            _name,
            _age
        );
    }

    /**
        @notice Retrieves a student's details by their student ID.
        @dev This function calls the getStudent function in the external Student Registry contract.
        @param _studentId The ID of the student.
        @return student The Student struct containing the student's details.
    */
    function getStudent2(
        uint8 _studentId
    ) public view returns (Student memory) {
        return
            IStudentRegistry(StudentRegistryContractAddress).getStudent(
                _studentId
            );
    }

    /**
        @notice Registers a student by calling the registerStudent function in the external Student Registry contract.
        @dev This function checks the payment and passes the student's details to the external contract.
        @param _studentAddr The unique address of the student.
        @param _age The age of the student.
        @param _name The name of the student.
        @return success A boolean value indicating whether the registration was successful.
    */
    function studentRegistration(
        address _studentAddr,
        uint8 _age,
        string memory _name
    ) public payable returns (bool) {
        return
            IStudentRegistry(StudentRegistryContractAddress).registerStudent(
                _studentAddr,
                _age,
                _name
            );
    }

    /**
        @notice Enlists a student by authorizing their registration in the external Student Registry contract.
        @dev This function calls the authorizeStudentRegistration function in the external contract.
        @param _studentAddr The address of the student to be enlisted.
        @return success A boolean value indicating whether the enlistment was successful.
    */
    function studentEnlistment(address _studentAddr) public returns (bool) {
        return
            IStudentRegistry(StudentRegistryContractAddress)
                .authorizeStudentRegistration(_studentAddr);
    }

    /**
        @notice Updates the details of a registered student in the external Student Registry contract.
        @dev This function calls the updateStudent function in the external contract.
        @param _studentAddr The address of the student to update.
        @param _age The new age of the student.
        @param _name The new name of the student.
        @return updatedStudent The updated Student struct.
    */
    function studentUpdate(
        address _studentAddr,
        uint8 _age,
        string memory _name
    ) public returns (Student memory) {
        return
            IStudentRegistry(StudentRegistryContractAddress).updateStudent(
                _studentAddr,
                _age,
                _name
            );
    }

    /**
        @notice Withdraws the contract's balance from the external Student Registry contract.
        @dev This function calls the withdraw function in the external contract.
        @return success A boolean value indicating whether the withdrawal was successful.
    */
    function withdrawEarnings() public returns (bool) {
        return IStudentRegistry(StudentRegistryContractAddress).withdraw();
    }

    /**
        @notice Retrieves the balance of the external Student Registry contract.
        @dev This function calls the getBalance function in the external contract.
        @return balance The current balance of the external contract.
    */
    function registryEarnings() public view returns (uint256) {
        return IStudentRegistry(StudentRegistryContractAddress).getBalance();
    }

    /**
        @notice Retrieves a student's details by their address from the external Student Registry contract.
        @dev This function calls the getStudentFromMapping function in the external contract.
        @param _studentAddr The address of the student.
        @return student The Student struct containing the student's details.
    */
    function retrieveStudent(
        address _studentAddr
    ) public view returns (Student memory) {
        return
            IStudentRegistry(StudentRegistryContractAddress)
                .getStudentFromMapping(_studentAddr);
    }

    /**
        @notice Expels a student from the external Student Registry contract.
        @dev This function calls the deleteStudent function from the external contract.
        @param _studentAddr The address of the student to be expelled.
    */
    function studentExpulsion(address _studentAddr) public {
        IStudentRegistry(StudentRegistryContractAddress).deleteStudent(
            _studentAddr
        );
    }
}