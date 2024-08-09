// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import "./Ownable.sol";
import "./Student.sol";
import "contracts/StudentCount.sol";

contract StudentRegistry is Ownable, StudentCount {
    event PaymentStatus(bool indexed havePaid, string message);
    event StudentUpdate(bool indexed updated, string message);

    mapping(address => Student) private studentsMapping;

    mapping(address => uint) public studentUId;

    mapping(address => uint) public receipt;

    function registerStudents(
        address _studentAddr,
        string memory _name,
        uint8 _age,
        uint256 _studentId
    ) public payable isNotAddressZero onlyOwner nameIsNotEmpty(_name) upToAge(_age) {
        uint amount = msg.value;
        uint hasUserPaid = receipt[_studentAddr];

        require(hasUserPaid == 0 ether, "You have registered");
        require(amount == 1 ether, "You must pay exactly 1 ether to proceed");

        Student memory student = Student({
            studentAddr: _studentAddr,
            name: _name,
            age: _age,
            studentId: _studentId
        });

        // add student to studentsMapping
        studentsMapping[_studentAddr] = student;
        receipt[_studentAddr] = amount;
        emit PaymentStatus(true, "you have succesfully registered");
    }

    function authorizeStudent(address _studentAddr) public {
       require(receipt[_studentAddr] == 1 ether, "Go and register to proceed");

       Student storage studentsDetails = studentsMapping[_studentAddr];

       studentsDetails.studentAddr = _studentAddr;
       studentsDetails.studentId = getStudentMainId();
       incrementStudentId();

       studentUId[_studentAddr] = studentId;

    }

    function updateStudent(address _studentAddr, string memory _name, uint8 _age) public  isNotAddressZero onlyOwner nameIsNotEmpty(_name) upToAge(_age) returns (Student memory) {
        Student storage studentsUpdate = studentsMapping[_studentAddr];
        studentsUpdate.name = _name;
        studentsUpdate.age = _age;

        studentsMapping[_studentAddr] = studentsUpdate;
        emit StudentUpdate(true, "Successfully Updated");

        return studentsUpdate;

    }

    function getStudentFromMapping(address _studentAddr)
        public
        view
        isNotAddressZero
        returns (Student memory)
    {
        return studentsMapping[_studentAddr];
    }

    function deleteStudent(address _studentAddr)
        public
        onlyOwner
        isNotAddressZero
    {
        require(
            studentsMapping[_studentAddr].studentAddr != address(0),
            "Student does not exist"
        );

        // delete studentsMapping[_studentAddr];

        Student memory student = Student({
            studentAddr: address(0),
            name: "",
            age: 0,
            studentId: 0
        });

        studentsMapping[_studentAddr] = student;
    }


    function modifyOwner(address _newOwner) public {
        changeOwner(_newOwner);
    }

    /**
        @notice Withdraws the contract's balance to the owner's address.
    */
    function withdraw() public isNotAddressZero onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "Empty Balance");

        (bool success, ) = getOwner().call{value: balance}("");
        require(success, "your Withdrawal was unsucessful");
    }


    /**
        @notice Returns the balance of the contract.
        @return balance The current balance of the contract.
    */
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    receive() external payable { }
    
}