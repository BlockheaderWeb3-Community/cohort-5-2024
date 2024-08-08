// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import "./Ownable.sol";
import "./Student.sol";

contract StudentRegistry is Ownable {
    //custom errors
    error NameIsEmpty();
    error UnderAge(uint8 age, uint8 expectedAge);

    event StudentAdded(
        address indexed studentAddr,
        uint256 studentId,
        string name,
        uint8 age
    );
    event StudentDeletedArray(address indexed studentAddr, uint256 studentId);
    event StudentDeletedMapping(address indexed studentAddr);
    //custom data type

    //dynamic array of students
    Student[] private students;

    mapping(address => Student) public studentsMapping;

    modifier isNotAddressZero() {
        require(msg.sender != address(0), "Invalid Address");
        _;
    }

    // modofying this function to receive payment
    function addStudent(
        address _studentAddr,
        string memory _name,
        uint8 _age
    ) public isNotAddressZero {
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
            studentId: _studentId
        });

        students.push(student);
        // add student to studentsMapping
        studentsMapping[_studentAddr] = student;
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
    }

    /// @notice Thursday assignment
    /// @dev Function to delete a student from the array
    function deleteStudentFromArray(uint256 _studentId) public onlyOwner {
        uint256 index = _studentId - 1;

        emit StudentDeletedArray(students[index].studentAddr, _studentId);

        for (uint256 i = index; i < students.length - 1; i++) {
            students[i] = students[i + 1];
        }

        students.pop();
    }

    /// @notice Thursday assignment
    /// @dev Function to update a student in the array
    function updateStudent(
        uint256 _studentId,
        address _studentAddr,
        string memory _name,
        uint8 _age
    ) public onlyOwner {
        require(_age >= 18, "Age should not be less than 18");
        students[_studentId - 1] = Student({
            studentAddr: _studentAddr,
            name: _name,
            age: _age,
            studentId: _studentId
        });
    }

    /// @notice Function to update a student in the mapping
    function updateStudentInMapping(
        address _studentAddr,
        string memory _name,
        uint8 _age
    ) public onlyOwner isNotAddressZero {
        require(
            studentsMapping[_studentAddr].studentAddr != address(0),
            "Student does not exist"
        );
        require(_age >= 18, "Age should not be less than 18");

        uint256 _studentId = studentsMapping[_studentAddr].studentId;
        studentsMapping[_studentAddr] = Student({
            studentAddr: _studentAddr,
            name: _name,
            age: _age,
            studentId: _studentId
        });
    }

    function modifyOwner(address _newOwner) public {
        changeOwner(_newOwner);
    }
}
