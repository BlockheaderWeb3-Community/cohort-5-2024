// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import "./Ownable.sol";
import "./Student.sol";


contract StudentRegistry is Ownable {
    //custom erros
    error NameIsEmpty();
    error UnderAge(uint8 age, uint8 expectedAge);
    event Log(address indexed sender, uint256 amount);
    //custom data type   
  
    //dynamic array of students
    // Student[] private students;

    // Temporary register
    Student[] public tempRegister;
    mapping(address => Student) private tempStudentsMapping;

    // Permanent register
    Student[] public permanentRegister;
    mapping(address => Student) private permanentStudentsMapping;

    receive() external payable {}

    modifier isNotAddressZero() {
        require(msg.sender != address(0), "Invalid Address");
        _;
    }

    // Register Student - Required to pay 1 ether
    function addStudent(
        address _studentAddr,
        string memory _name,
        uint8 _age,
        uint256 _price
    ) public payable isNotAddressZero {
        // Ensure the student exists by checking if the studentAddr is not zero address
        require(tempStudentsMapping[_studentAddr].studentAddr == address(0), "Student already exists.");
        // Check the value sent with the transaction
        require(msg.value == fee, "You need to pay exactly 1 ether");
        require(msg.value == _price, "Amount and Msg.Value doesn't match");

        if (bytes(_name).length == 0) {
            revert NameIsEmpty();
        }

        if (_age < 18) {
            revert UnderAge({age: _age, expectedAge: 18});
        }

        uint256 _studentId = tempRegister.length + 1;
        Student memory student = Student({
            studentAddr: _studentAddr,
            name: _name,
            age: _age,
            studentId: _studentId,
            hasPaid: true
        });

        // (bool sent,) = address(0).call{value: msg.value}("");
        // require(sent, "Failed to send Ether");        

        // Store the student in the temporary register and mapping
        tempRegister.push(student);
        tempStudentsMapping[_studentAddr] = student;
    }


     // Function to move all students from the temporary register to the permanent register
    function confirmAllStudents() public payable onlyOwner {
        // Loop through all students in the tempRegister
        for (uint256 i = 0; i < tempRegister.length; i++) {
            Student memory student = tempRegister[i];

            // Add the student to the permanent register and mapping
            permanentRegister.push(student);
            permanentStudentsMapping[student.studentAddr] = student;

            // Remove the student from the temporary mapping
            delete tempStudentsMapping[student.studentAddr];
        }

        // Clear the temporary register array
        delete tempRegister;

        // Make withdrawal on confirm
        return withdraw();
    }

    function getStudent(uint8 _studentId)
        public
        view
        isNotAddressZero
        returns (Student memory)
    {
        return permanentRegister[_studentId - 1];
     }

    function getStudentFromMapping(address _studentAddr)
        public
        view
        isNotAddressZero
        returns (Student memory)
    {
        return permanentStudentsMapping[_studentAddr];
    }

    function deleteStudent(address _studentAddr)
        public
        onlyOwner
        isNotAddressZero
    {
        require(
            permanentStudentsMapping[_studentAddr].studentAddr != address(0),
            "Student does not exist"
        );

        // delete studentsMapping[_studentAddr];

        Student memory student = Student({
            studentAddr: address(0),
            name: "",
            age: 0,
            studentId: 0,
            hasPaid: false
        });

        permanentStudentsMapping[_studentAddr] = student;
    }


    function modifyOwner(address _newOwner) public {
        changeOwner(_newOwner);
    }

     function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    // Function to get the number of permanent registered students
    function getPermanentTotalStudents() public view returns (uint256) {
        return permanentRegister.length;
    }

    // Function to get the number of temp registered students
    function getTemperaryTotalStudents() public view returns (uint256) {
        return tempRegister.length;
    }

    
}
