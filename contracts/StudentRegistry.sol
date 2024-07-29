// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;


contract StudentRegistry {
   
    struct Student {
        address studentAddr;
        string name;
        uint256 studentId;
        uint8 age;
    }

    constructor() {
        owner = msg.sender;
    }

   
    Student[] private students;
    address public owner;
    mapping(address => Student) public studentsMapping;

   
    modifier onlyOwner() {
        require(owner == msg.sender, "You fraud!!!");
        _;
    }

    modifier isNotAddressZero() {
        require(msg.sender != address(0), "Invalid Address");
        _;
    }

    modifier isAdult(uint8 _age) {
        require(_age >= 18, "You're under age.");
        _;
    }

    modifier isValidAge(uint8 _age) {
        require(_age <= 255, "Cannot exceed max limit(255)");
        _;
    }

    modifier isRegistered(address _studentAddr) {
        require(
            studentsMapping[_studentAddr].studentAddr != address(0),
            "Student not found."
        );
        _;
    }

    event StudentEvent(string message, Student student);

    function addStudent(
        address _studentAddr,
        string memory _name,
        uint8 _age
    ) public onlyOwner isNotAddressZero isAdult(_age) isValidAge(_age) {
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
        // add student to studentsMapping
        studentsMapping[_studentAddr] = student;
        emit StudentEvent("Student registered successfully.", student);
    }

    
    function getStudent(
        uint8 _studentId
    ) public view isNotAddressZero returns (Student memory) {
        return students[_studentId - 1];
    }

    
    function getStudentFromMapping(
        address _studentAddr
    )
        public
        view
        isNotAddressZero
        isRegistered(_studentAddr)
        returns (Student memory)
    {
        return studentsMapping[_studentAddr];
    }

   
    function deleteStudent(
        address _studentAddr
    ) public onlyOwner isNotAddressZero isRegistered(_studentAddr) {
        // delete studentsMapping[_studentAddr];

        Student memory student = Student({
            studentAddr: address(0),
            name: "",
            age: 0,
            studentId: 0
        });

        studentsMapping[_studentAddr] = student;
    }

   
    function updateStudent(
        address _studentAddr,
        string memory _name,
        uint8 _age
    )
        public
        onlyOwner
        isNotAddressZero
        isRegistered(_studentAddr)
        isAdult(_age)
        isValidAge(_age)
    {
        Student memory student = studentsMapping[_studentAddr];

        if (bytes(_name).length > 0) {
            student.name = _name;
        }
        student.age = _age;
        studentsMapping[_studentAddr] = student;
        emit StudentEvent("Student record updated.", student);
    }
}