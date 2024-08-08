// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import "./Ownable.sol";
import "./Student.sol";

contract StudentRegistry is Ownable {
    //custom errors
    error NameIsEmpty();
    error UnderAge(uint8 age, uint8 expectedAge);
    event StudentEnlisted(address indexed studentAddr, uint256 studentId);
    mapping(address => bool) public authorizedStudents;

    // Payable address can send Ether via transfer or send
    address payable public owner;

    // Payable constructor can receive Ether
    constructor() payable {
        owner = payable(msg.sender);
    }

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

    // student registration and enlistment
    function addStudent(
        address _studentAddr,
        string memory _name,
        uint8 _age
    ) public payable isNotAddressZero {
        require(authorizedStudents[_studentAddr], "Student is not authorized to register");
        require(msg.value == 1 ether, "Registration requires 1 Ether");
        require(
            !studentsMapping[_studentAddr].registered,
            "Student already registered"
        );

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
            registered: true,
            enlisted: false
        });

        studentsMapping[_studentAddr] = student;
        emit StudentAdded(_studentAddr, _studentId, _name, _age);
    }

    function isRegistered(address _studentAddr) public view returns (bool) {
        return studentsMapping[_studentAddr].registered;
    }

    function enlistStudent(address _studentAddr)
        public
        onlyOwner
        isNotAddressZero
    {
        require(
            studentsMapping[_studentAddr].registered,
            "Student is not registered"
        );
        require(
            !studentsMapping[_studentAddr].enlisted,
            "Student is already enlisted"
        );

        uint256 _studentId = studentsMapping[_studentAddr].studentId;
        studentsMapping[_studentAddr].enlisted = true;

        // Add the student to the array only if enlisted
        students.push(studentsMapping[_studentAddr]);

        emit StudentEnlisted(_studentAddr, _studentId);
    }

    function authorizeStudentRegistration(address _studentAddr)
        public
        onlyOwner
    {
        require(_studentAddr != address(0), "Invalid address");
        authorizedStudents[_studentAddr] = true;
    }

    // Function to withdraw all Ether from this contract.
    function withdraw() public onlyOwner {
        // get the amount of Ether stored in this contract
        uint256 amount = address(this).balance;

        // send all Ether to owner
        (bool success, ) = owner.call{value: amount}("");
        require(success, "Failed to send Ether");
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

   function deleteStudent(address _studentAddr) public onlyOwner isNotAddressZero {
    require(
        studentsMapping[_studentAddr].studentAddr != address(0),
        "Student does not exist"
    );

    uint256 studentId = studentsMapping[_studentAddr].studentId;
    uint256 index = studentId - 1;

    for (uint256 i = index; i < students.length - 1; i++) {
        students[i] = students[i + 1];
    }
    students.pop();

    // Delete the student from the mapping
    delete studentsMapping[_studentAddr];

    emit StudentDeletedMapping(_studentAddr);
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
            studentId: _studentId,
            registered: true,
            enlisted: true
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
            studentId: _studentId,
            registered: true,
            enlisted: true
        });
    }

    function modifyOwner(address _newOwner) public {
        changeOwner(_newOwner);
    }
}
