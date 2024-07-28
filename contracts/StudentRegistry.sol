// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract StudentRegistry {

    struct Student {
        address studentAddr;
        string name;
        uint8 age;
        uint studentId;
    }

    address public owner;

    constructor() {
        owner = msg.sender;
    }

    Student[] private students;

    mapping(address => Student) public studentMap;

    modifier onlyOwner() {
        require(owner == msg.sender, "you're not authorized");
        _;
    }

    modifier isNotAddressZero() {
        require(msg.sender != address(0), "Invalid Address");
        _;
    }

    event StudentAdded(address indexed studentAddr, string name, uint8 age, uint studentId);
    event StudentDeleted(address indexed studentAddr);

    /// @dev function to add student to the students array and mapping
    /// @notice adds student
    function addStudent(address _studentAddr, string memory _name, uint8 _age) public onlyOwner isNotAddressZero {
        require(bytes(_name).length > 0, "input cannot be empty");
        require(_age >= 18, "You are not up to age");
        uint _studentId = students.length + 1;
        Student memory student = Student({
            studentAddr: _studentAddr,
            name: _name,
            age: _age,
            studentId: _studentId
        });

        students.push(student);
        studentMap[_studentAddr] = student;

        emit StudentAdded(_studentAddr, _name, _age, _studentId);
    }

    /// @dev function to get student using studentId
    /// @notice gets student ID
    function getStudent(uint256 _studentId) public view onlyOwner isNotAddressZero returns (Student memory) {
        return students[_studentId - 1];
    }

    /// @dev function to get student using studentAddr
    /// @notice gets student Address
    function getStudentAddr(address _ownerAddr) public view onlyOwner isNotAddressZero returns (Student memory) {
        return studentMap[_ownerAddr];
    }

    function updateStudent(address _studentAddr, string memory _name, uint8 _age, uint _studentId) public onlyOwner isNotAddressZero {
        Student storage studentToUpdate = studentMap[_studentAddr];
        studentToUpdate.name = _name;
        studentToUpdate.age = _age;
        studentToUpdate.studentId = _studentId;
    }

    /// @dev function to delete using address
    /// @notice resets it back to the initial state
    function deleteStudent(address _studentAddr) public onlyOwner isNotAddressZero {
        require(studentMap[_studentAddr].studentAddr != address(0), "student not available");

        // delete studentMap[_studentAddr];

        Student memory student = Student({
            studentAddr: address(0),
            name: "",
            age: 0,
            studentId: 0
        });

        studentMap[_studentAddr] = student;

        emit StudentDeleted(_studentAddr);
    }

    /// @dev function to delete using Uint
    /// @notice resets it back to the initial state
    function deleteStudentUint(uint _student) public onlyOwner isNotAddressZero {
        require(_student > 0, "student not available or does not exist");

        delete students[_student - 1];

        emit StudentDeleted(students[_student - 1].studentAddr);
    }
}