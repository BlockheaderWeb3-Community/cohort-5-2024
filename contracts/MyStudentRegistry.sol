// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "contracts/StudentStruct.sol";
import "contracts/IStudentRegistry.sol";
import "contracts/Ownable.sol";
import "contracts/StudentCounter.sol";

/**
 * @title MyStudentRegistry
 * @dev This contract acts as a proxy to interact with another StudentRegistry contract.
 * It forwards calls to the `StudentRegistry` contract for student management functions.
 */
contract MyStudentRegistry is Ownable, StudentCounter {
    address public studentRegistry;
    event StudentAuthorized(address indexed  studentAddr, uint256 studentId);
    event StudentUpdated(address indexed  newAddress, string name, uint8 age);



    /**
     * @dev Sets the address of the StudentRegistry contract.
     * @param _studentRegistryAddr The address of the StudentRegistry contract.
     */
    constructor(address _studentRegistryAddr) {
        studentRegistry = _studentRegistryAddr;
    }

    mapping  (address => uint256) public receipt;
    mapping  (address => uint32) public myStudentId;


    /**
     * @dev Register a student by forwarding the call to the StudentRegistry contract.
     * @param _studentAddr The address of the student to register.
     * @param _name The name of the student.
     * @param _age The age of the student.
     * Requires exactly 1 ether to be sent with the transaction.
     */

    function registerStudents(address _studentAddr, string memory _name, uint8 _age) public payable {
        uint256 amount = msg.value;
        require(amount == 1 ether, "You must pay exactly 1 ether");

        // Collect the payment in ColabRegistry
        // Call the registerStudent function in StudentRegistry
        (bool success,) = studentRegistry.call{value: msg.value}(
            abi.encodeWithSignature("registerStudent(address,string,uint8)", _studentAddr, _name, _age)
        );

        receipt[_studentAddr] = amount;
    }

    /**
     * @dev Authorize a student by forwarding the call to the StudentRegistry contract.
     * @param _studentAddr The address of the student to authorize.
     */

    function authorizeStudents(address _studentAddr) public {
        IStudentRegistry(studentRegistry).authorizeStudent(_studentAddr);
        myStudentId[_studentAddr] = getStudentId();
        increaseStudentId();
        myStudentId[_studentAddr] = studentId;

        emit StudentAuthorized(_studentAddr, studentId);
    }


     /**
     * @dev Retrieve a student's information by forwarding the call to the StudentRegistry contract.
     * @param _studentAddr The address of the student to retrieve.
     */
    function getStudents(address _studentAddr) public view returns (Student memory) {
        return IStudentRegistry(studentRegistry).getStudent(_studentAddr);
    }

    /**
     * @dev Update a student's information by forwarding the call to the StudentRegistry contract.
     * @param _studentAddr The new address of the student.
     * @param _name The new name of the student.
     * @param _age The new age of the student.
     */

    function updateStudents(
        address _studentAddr, 
        string memory _name, 
        uint8 _age
    ) public {
        IStudentRegistry(studentRegistry).updateStudent(_studentAddr, _name, _age);
        myStudentId[_studentAddr] = getStudentId();
        increaseStudentId();
        emit StudentUpdated( _studentAddr, _name, _age);
    }


     /**
     * @dev Delete a student's record by forwarding the call to the StudentRegistry contract.
     * @param _studentAddr The address of the student to delete.
     */
    function deleteStudents(address _studentAddr) public {
        IStudentRegistry(studentRegistry).deleteStudent(_studentAddr);
        myStudentId[_studentAddr] = getStudentId();
        decreaseStudentId();
    }

     /**
     * @dev Allow the contract to receive Ether.
     */
    receive() external payable {}
}





