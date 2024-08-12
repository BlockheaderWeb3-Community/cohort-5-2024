// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./Ownable.sol";
import "./Student.sol";


contract StudentRegistry is Ownable {
    //custom erros
    error NameIsEmpty();
    error UnderAge(uint8 age, uint8 expectedAge);

    //custom data type
   
   event paid(address _from, address _to, uint256 _value);
  
    //dynamic array of students
    Student[] private students;

    mapping(address => Student) public studentsMapping;

    modifier isNotAddressZero() {
        require(msg.sender != address(0), "Invalid Address");
        _;
    }

    // student to the students array
    function addStudent(
        address _studentAddr,
        string memory _name,
        uint8 _age,
        bool _hasPaid
    ) public  isNotAddressZero onlyOwner {
        if (bytes(_name).length == 0) {
            revert NameIsEmpty();
        }

        if (_age < 18) {
            revert UnderAge({age: _age, expectedAge: 18});
        }

        uint256 _studentId = students.length + 1;
        Student memory student = Student({
            studentAddr: _studentAddr,
            name: _name,
            age: _age,
            studentId: _studentId,
            hasPaid: _hasPaid 
        });

        students.push(student);

        // add student to studentsMapping
        studentsMapping[_studentAddr] = student;
    }

    function getStudent(uint8 _studentId)
        public
        view
        isNotAddressZero
        returns (Student memory)
    {
        return students[_studentId - 1];
    }

    function getStudentFromMapping(address _studentAddr)
        public
        view
        isNotAddressZero
        returns (Student memory)
    {
        return studentsMapping[_studentAddr];
    }

    // Register student
    function register(address _studentAddr, address _owner, uint256 amount, string memory _name, uint256 _studentId, uint8 _age) public payable isNotAddressZero {
        require(msg.value == 1, "You have to send 1 ether to register");
        Student memory student = Student({
            studentAddr: _studentAddr,
            name: _name,
            age: _age,
            studentId: _studentId,
            hasPaid: true
        });

        students.push(student);

        // add student to studentsMapping
        studentsMapping[_studentAddr] = student;

        emit paid(_studentAddr, _owner, amount);
    }

      // Function to transfer Ether from this contract to address from input
    function transfer(address payable _to, uint256 _amount) public onlyOwner {
        (bool success,) = _to.call{value: _amount}("");
        require(success, "Failed to send Ether");
    }

    function withdraw() public {
        uint256 amount = address(this).balance;
        (bool success,) = owner.call{value: amount}("");
        require(success, "Failed to send Ether");
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
            studentId: 0,
            hasPaid: false
        });

        studentsMapping[_studentAddr] = student;
    }

    function modifyOwner(address _newOwner) public onlyOwner {
        changeOwner(_newOwner);
    }
}
