// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract StudentRegistry{

    struct Student {
        address studentAddr;
        uint256 studentID;
        string name;
        uint8 age;
    }

    address public owner;

    constructor () {
        owner = msg.sender; // Address of the person that deploys the contract
    }

    // Dynamic array of student
    Student[] private students;

    mapping (address => Student) public studentMapping;

    modifier onlyOwner() {
        require(owner == msg.sender, "You are not authorized");
        _;
    }

    modifier isNotAddressZero () {
        require(msg.sender != address(0), "Invalid Address");
        _;
    }

    // Events
    event StudentAdded(address indexed studentAddress, uint256 studentId, string name, uint8 age);
    event StudentDeleted(address indexed studentAddress, uint256 studentId, string name, uint8 age);

    function addStudent(address _studentAddr, string memory _name, uint8 _age) public onlyOwner isNotAddressZero {
        
        // require(_studentAddr != address(0), "Invalid Address");
        require(bytes(_name).length > 0, "Name cannot be blank" );
        require(_age >= 18, "Age must be more than 18");

        uint256 _studentID = students.length + 1;
        Student memory student = Student({
            studentAddr: _studentAddr,
            name: _name,
            age: _age,
            studentID: _studentID
        });

        students.push(student);
        // add student to studentMapping
        studentMapping[_studentAddr] = student;
        // emit
        emit StudentAdded(_studentAddr, _studentID, _name, _age);
    }

    function getStudents(uint8 _studentID) public view returns (Student memory) {
        return students[_studentID - 1];
    }

    function getStudentsFromMapping(address _studentAddr) public view returns (Student memory) {
        return studentMapping[_studentAddr];
    }

    function updateStudentFromMapping(
        address _studentAddr,
        uint256 _studentID, 
        string memory _name, 
        uint8 _age
    ) public onlyOwner {
        Student storage student = studentMapping[_studentAddr];
        student.name = _name;
        student.age =_age;
        student.studentID = _studentID;
    }

    function deleteStudentFromMapping(address _studentAddr) public onlyOwner isNotAddressZero {

        require(studentMapping[_studentAddr].studentAddr != address(0), "Student does not exist");

        Student memory student = studentMapping[_studentAddr];

        // emit
        emit StudentDeleted(_studentAddr, student.studentID, student.name, student.age);

        delete studentMapping[_studentAddr];

        // Alternative
        // Student memory student = Student({
        //     studentAddr: address(0x00),
        //     name: "",
        //     age: 0,
        //     studentID: 0
        // });

        //studentMapping[_studentAddr] = student;
    }


    // Assignment
    function updateStudent(uint256 _studentID, address _studentAddr, string memory _name, uint8 _age) public {
        require(_studentID > 0 && _studentID <= students.length, "Invalid student ID");

        uint256 index = _studentID - 1; // Convert studentID to array index

        Student storage student = students[index];
        student.name = _name;
        student.age = _age;
        student.studentAddr = _studentAddr;
    }

    function deleteStudent(uint256 _studentID) public {
        require(_studentID > 0 && _studentID < students.length + 1, "Invalid student ID");

        // To move every element after the deleted element one position to the left
        for (uint256 i = _studentID - 1; i < students.length - 1; i++) {
            students[i] = students[i + 1];
            students[i].studentID = i + 1; // Update the studentID
        }
        // Remove last element
        students.pop();
    }

}