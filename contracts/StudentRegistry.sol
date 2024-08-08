// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;
pragma solidity ^0.8.14;
import "./Ownable.sol";
import "./Student.sol";


contract StudentRegistry is Ownable {
    //custom erros
    error NameIsEmpty();
    error UnderAge(uint8 age, uint8 expectedAge);

    //custom data type

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
        uint8 _age
    ) public onlyOwner isNotAddressZero {
        require( bytes(_name).length > 0, "Name cannot be blank");
        require( _age >= 18, "This student is under age");
        // ) public  isNotAddressZero {
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
    }

    // get student (in the array method)
    function getStudent(uint8 _studentId) public isNotAddressZero view returns (Student memory) {
        return students[_studentId - 1];
    }

    // get student (in the mapping method)
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
        returns (Student memory) {
        return studentsMapping[_studentAddr];
    }

    // delete student from the register (in the mapping method)
    function deleteStudent(address _studentAddr) public onlyOwner  isNotAddressZero {

        require(studentsMapping[_studentAddr].studentAddr != address(0), "Student does not exist")
        isNotAddressZero
        returns (Student memory);
    
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

        delete studentsMapping[_studentAddr];

        Student memory student = Student({
            studentAddr: address(0),
            name: "",
            age: 0,
            studentId: 0
        });

        studentsMapping[_studentAddr] = student;
    }

     // this function updates the student register (in the array method)
    function updateStudents(uint8 _index) public view returns(uint8, string memory) {
        Student memory updateStudent = students[_index];
        return(updateStudent.age, updateStudent.name);
    }

    // deletes student from the register (in the array type)
    function deleteStudent(uint8 _index) public {
        students[_index] = students[students.length - 1];
        students.pop();
    }
}
