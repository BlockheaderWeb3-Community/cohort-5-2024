// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract StudentRegistry {
    //custom data type
    struct Student {
        address studentAddr;
        string name;
        uint256 studentId;
        uint8 age;
    }

    event StudentAdded(
        address indexed studentAddr,
        uint256 studentId,
        string name,
        uint8 age
    );
    event StudentDeletedArray(address indexed studentAddr, uint256 studentId);
    event StudentDeletedMapping(address indexed studentAddr);

    address public owner;

    constructor() {
        owner = msg.sender;
    }

    //dynamic array of students
    Student[] private students;

    mapping(address => Student) public studentsMapping;

    modifier onlyOwner() {
        require(owner == msg.sender, "You fraud!!!");
        _;
    }

    modifier isNotAddressZero() {
        require(msg.sender != address(0), "Invalid Address");
        _;
    }

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
        // add student to studentsMapping
        studentsMapping[_studentAddr] = student;

        // event emit for add funtion
        emit StudentAdded(_studentAddr, _studentId, _name, _age);
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
        emit StudentDeletedMapping(_studentAddr);
    }

    /// @notice thursday assignment
    /// @dev function to delete a student from the array
    function deleteStudentFromArray(uint256 _studentid) public {
        require(owner == msg.sender, "You are not authorized");

        uint256 index = _studentid - 1;

        // event emit fro deleting student
        emit StudentDeletedArray(students[index].studentAddr, _studentid);

        for (uint256 i = index; i < students.length - 1; i++) {
            students[i] = students[i + 1];
        }

        students.pop();
    }

    /// @notice thursday assignment
    /// @dev function to update a student in the array

    function updateStudent(
        uint256 _studentid,
        address _studentAddr,
        string memory _name,
        uint8 _age
    ) public {
        require(owner == msg.sender, "You are not authorized");
        require(_age >= 18, "Age Should Not Be Less Than 18");
        students[_studentid - 1] = Student({
            studentAddr: _studentAddr,
            name: _name,
            age: _age,
            studentId: _studentid
        });
    }

    ///@notice Function to update a student in the mapping
    function updateStudentInMapping(
        address _studentAddr,
        string memory _name,
        uint8 _age
    ) public onlyOwner isNotAddressZero {
        require(
            studentsMapping[_studentAddr].studentAddr != address(0),
            "Student does not exist"
        );
        require(_age >= 18, "Age Should Not Be Less Than 18");

        uint256 _studentId = studentsMapping[_studentAddr].studentId;
        studentsMapping[_studentAddr] = Student({
            studentAddr: _studentAddr,
            name: _name,
            age: _age,
            studentId: _studentId
        });
    }
}
