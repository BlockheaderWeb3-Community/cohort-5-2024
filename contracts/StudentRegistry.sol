// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title Student Registry
/// @author Fredrick Loveday
/// @notice This contract provides basic functionality to create , get, delete and update a student registry

contract StudentRegistry {
    // Custom data type
    struct Student {
        address studentAddr;
        string name;
        uint256 studentId;
        uint8 age;
    }

    address public owner;

    /// @dev Sets the contract deployer as the owner.
    constructor() {
        owner = msg.sender;
    }

    // Dynamic array of students
    Student[] private students;

    mapping(address => Student) public studentsMapping;

    // Events
    event StudentAdded(address indexed studentAddr, string name, uint256 studentId, uint8 age);
    event StudentDeleted(uint256 indexed studentId);
    event StudentUpdated(uint256 indexed studentId, address studentAddr, string name, uint8 age);

    modifier onlyOwner() {
        require(owner == msg.sender, "You fraud!!!");
        _;
    }

    modifier isNotAddressZero() {
        require(msg.sender != address(0), "Invalid Address");
        _;
    }

    /// @notice Adds a new student to the registry.
    /// @param _studentAddr The address of the student.
    /// @param _name The name of the student.
    /// @param _age The age of the student.
    function addStudent(
        address _studentAddr,
        string memory _name,
        uint8 _age
    ) public onlyOwner isNotAddressZero {
        require(bytes(_name).length > 0, "Name cannot be blank");
        require(_age >= 18, "This student is under age");

        uint256 _studentId = students.length + 1;
        Student memory student = Student({
            studentAddr: _studentAddr,
            name: _name,
            age: _age,
            studentId: _studentId
        });

        students.push(student);
        studentsMapping[_studentAddr] = student;

        emit StudentAdded(_studentAddr, _name, _studentId, _age);
    }

    /// @notice Gets the details of a student by their ID.
    /// @param _studentId The ID of the student.
    /// @return The details of the student.
    function getStudent(uint8 _studentId) public view isNotAddressZero returns (Student memory) {
        return students[_studentId - 1];
    }

    /// @notice Gets the details of a student by their address.
    /// @param _studentAddr The address of the student.
    /// @return The details of the student.
    function getStudentFromMapping(address _studentAddr)
        public
        view
        isNotAddressZero
        returns (Student memory)
    {
        return studentsMapping[_studentAddr];
    }

    /// @notice Deletes a student from the registry by their ID.
    /// @param _studentId The ID of the student.
    function deleteStudent(uint256 _studentId) public onlyOwner {
        require(_studentId > 0 && _studentId <= students.length, "Student ID is out of range");
        delete students[_studentId - 1];
        
        emit StudentDeleted(_studentId);
    }

    /// @notice Deletes a student from the mapping by their address.
    /// @param _studentAddr The address of the student.
    function deleteStudentFromMapping(address _studentAddr) public onlyOwner isNotAddressZero {
        require(studentsMapping[_studentAddr].studentAddr != address(0), "Student does not exist");

        Student memory student = Student({
            studentAddr: address(0),
            name: "",
            age: 0,
            studentId: 0
        });

        studentsMapping[_studentAddr] = student;

        emit StudentDeleted(studentsMapping[_studentAddr].studentId);
    }

    /// @notice Updates the details of a student by their ID.
    /// @param _studentId The ID of the student.
    /// @param _studentAddr The new address of the student.
    /// @param _name The new name of the student.
    /// @param _age The new age of the student.
    function updateStudent(
        uint256 _studentId,
        address _studentAddr,
        string memory _name,
        uint8 _age
    ) public onlyOwner {
        require(_studentId > 0 && _studentId <= students.length, "Student ID is out of range");
        require(_age >= 18, "You are not of age. Come back in the next few years");

        Student storage student = students[_studentId - 1];
        student.studentAddr = _studentAddr;
        student.name = _name;
        student.age = _age;

        emit StudentUpdated(_studentId, _studentAddr, _name, _age);
    }

    /// @notice Updates the details of a student in the mapping by their address.
    /// @param _studentAddr The address of the student.
    /// @param _name The new name of the student.
    /// @param _age The new age of the student.
    function updateStudentToMapping(
        address _studentAddr,
        string memory _name,
        uint8 _age
    ) public onlyOwner isNotAddressZero {
        require(studentsMapping[_studentAddr].studentAddr != address(0), "Student does not exist");

        studentsMapping[_studentAddr].name = _name;
        studentsMapping[_studentAddr].age = _age;

        emit StudentUpdated(studentsMapping[_studentAddr].studentId, _studentAddr, _name, _age);
    }
}
