// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import './modifiers/AccessControlModifiers.sol';
import './modifiers/InputValidation.sol';

/// @title Student Registry Contract
/// @notice This contract allows the management of students' information
/// @dev This contract uses access control and input validation modifiers
contract StudentRegistry is AccessControlModifiers, InputValidation {

   
    /// @dev Custom data type representing a student
    struct Student {
        address studentAddr;
        string name;
        uint256 studentId;
        uint8 age;
    }

    /// @dev Dynamic array of students
    Student[] private students;

    /// @dev Mapping from address to Student struct
    mapping(address => Student) private studentsMapping;

    /// @dev Event emitted when a new student is added
    /// @param studentsMapping[_studentAddr] or students[_studentId - 1]  The student that was added
    event addNewStudentEvent(Student students, Student studentsMapping);

    /// @dev Event emitted when a student is deleted from the array
    /// @param students[_studentId - 1] The student that was deleted
    event deleteStudentEvent(Student students);

    /// @dev Event emitted when a student is deleted from the mapping
    /// @param studentsMapping[_studentAddr] The student that was deleted
    event deleteStudentFromMappingEvent(Student studentsMapping);


    /// @notice Adds a new student to the registry
    /// @dev Only the owner can add a new student
    /// @param _studentAddr The address of the student
    /// @param _name The name of the student
    /// @param _age The age of the student
    function addStudent(
        address _studentAddr,
        string memory _name,
        uint8 _age
    ) public onlyOwner validateStudentAge(_age) validateStudentName(_name) validateStudentAddress(_studentAddr) {
        uint256 _studentId = students.length + 1;
        Student memory student = Student({
            studentAddr: _studentAddr,
            name: _name,
            age: _age,
            studentId: _studentId
        });

        students.push(student);
        //@dev add student to studentsMapping
        studentsMapping[_studentAddr] = student;
        emit addNewStudentEvent(students[_studentId - 1], studentsMapping[_studentAddr]);
    }

    /// @notice Gets a student by their ID
    /// @param _studentId The ID of the student
    /// @return The student with the specified ID
    function getStudent(uint8 _studentId) public validateStudentId(_studentId)  view returns (Student memory) {
         require(_studentId < students.length, "student Id does not exist");
        return students[_studentId - 1];
    }

    /// @notice Gets a student by their address from the mapping
    /// @param _studentAddr The address of the student
    /// @return The student with the specified address
    function getStudentFromMapping(address _studentAddr)
        public validateStudentAddress(_studentAddr)
        view
        returns (Student memory)
    {
        return studentsMapping[_studentAddr];
    }

    /// @notice Deletes a student by their ID from the array
    /// @dev Only the owner can delete a student
    /// @param _studentId The ID of the student to delete
    function deleteStudent(uint8 _studentId) public onlyOwner {
        require(_studentId < students.length, "student Id does not exist");
        for (uint256 i = 0; i < students.length; i++) {
            if (students[i].studentId == _studentId) {
                //@dev Maintaining Order in the array
                students[i] = students[i + 1];
                ///@dev Not Maintaining Order in the array
                // students[i] = students[students.length - 1];
                // students.pop();
                // emit deleteStudentEvent(students[_studentId - 1]);
                // break;
            }
        }
        students.pop();
        emit deleteStudentEvent(students[_studentId - 1]);
    }

    /// @notice Deletes a student by their address from the mapping
    /// @dev Only the owner can delete a student
    /// @param _studentAddr The address of the student to delete
    function deleteStudentFromMapping(address _studentAddr) public onlyOwner {
        require(studentsMapping[_studentAddr].studentAddr != address(0), "Student does not exist");
        delete studentsMapping[_studentAddr];

    }

    /// @notice Updates a student in the mapping
    /// @dev Only the owner can update a student
    /// @param _studentAddr The address of the student to update
    /// @param _name The new name of the student
    /// @param _age The new age of the student
    function updateStudentFromMapping(
        address _studentAddr,
        string memory _name,
        uint8 _age
    ) public onlyOwner {
        require(studentsMapping[_studentAddr].studentAddr != address(0), "Student does not exist");

        Student storage student = studentsMapping[_studentAddr];
        student.name = _name;
        student.age = _age;
    }

    /// @notice Updates a student in the array
    /// @dev Only the owner can update a student
    /// @param _studentId The ID of the student to update
    /// @param _studentAddr The new address of the student
    /// @param _name The new name of the student
    /// @param _age The new age of the student
    function updateStudent(
        uint8 _studentId,
        address _studentAddr,
        string memory _name,
        uint8 _age
    ) public onlyOwner validateStudentId(_studentId) {
        require(_studentId <= students.length, "student Id does not exist");

        Student storage student = students[_studentId - 1];
        student.studentAddr = _studentAddr;
        student.name = _name;
        student.age = _age;

        //@dev Also update the student in studentsMapping
        studentsMapping[_studentAddr] = student;
    }
}
