// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import "./Ownable.sol";
import "./Student.sol";


contract StudentRegistry is Ownable {
    //custom erros
    error NameIsEmpty();
    error UnderAge(uint8 age, uint8 expectedAge);

    //custom data type
   
  
    //dynamic array of students
    Student[] private students;

    mapping (address => Student) public studentMapping;


    modifier isNotAddressZero() {
        require(msg.sender != address(0), "Invalid Address");
        _;
    }

    function addStudent(
        address _studentAddr,
        string memory _name,
        uint8 _age
    ) public  isNotAddressZero {
        if (bytes(_name).length == 0) {
            revert NameIsEmpty();
        }

        if (_age < 18) {
            revert UnderAge({age: _age, expectedAge: 18});
        }

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

        studentsMapping[_studentAddr] = student;
    }


    function modifyOwner(address _newOwner) public {
        changeOwner(_newOwner);
    }
}
