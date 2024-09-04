// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import "./Ownable.sol";
import "./Student.sol";

contract StudentRegistryV2 is Ownable {
    //custom erros
    error NameIsEmpty();
    error UnderAge(uint8 age, uint8 expectedAge);

    uint constant public FEE = 1 ether;
    //dynamic array of students
    Student[] public students;


    // Mappings for my Student Registery Contract
    mapping(address => Student) public studentsMapping;
 

    // Events for my student registry Contract
    event registerStudent(
        address _studentAddress,
        string _StName,
        uint8 _stAge
    );
    event AuthorizeStudentReg(address _studentAddress, uint256 time);
    event PaidFee(address indexed payer, uint256 amount);
    event RegisterStudent(address _addr, string name, uint8 age, uint256 time);

    // Function For Paying
    function payFee() public payable {
        require(msg.sender != owner, "Owner is excluded");
        require(msg.value == FEE, "You must pay fee");
        Student storage student =  studentsMapping[msg.sender];
        require(student.hasPaid == false, "You have paid already"); 
        (bool success, ) = address(this).call{value: msg.value}("");
        require(success, "failed to send ETH");
        student.studentAddr = msg.sender;
        student.hasPaid = true;

        emit PaidFee(msg.sender, FEE);
    }

    // Function for Registration
    function register(
        string memory _name,
        uint8 _age
    ) public payable {
        Student storage student = studentsMapping[msg.sender];
        require(student.hasPaid == true, "You need to pay fees");
        require(bytes(_name).length > 0, "No name has been inputed");
        require(_age >= 18, "age should be 18 or more");
        student.name = _name;
        student.age = _age;
        emit RegisterStudent(msg.sender, _name, _age, block.timestamp);
    }

    // Function for authorizing registered Student
    function authorizeStudentRegistration(
        address _studentAddr
    ) public onlyOwner {
        Student storage student =  studentsMapping[_studentAddr];
        require(student.hasPaid == true, "You need to pay fees");
        require(student.isAuthorized == false, "You have already been authorized");
        student.isAuthorized = true;
        addStudent(_studentAddr);
        students.push(student);
        emit AuthorizeStudentReg(_studentAddr, block.timestamp);
    }

    // Function for Adding student, this function is called in the authorizeStudentRegistration() function
    function addStudent(address _studentAddr) private onlyOwner() {
        uint256 _studentId = students.length + 1;
        Student storage student =  studentsMapping[_studentAddr];
        student.studentId = _studentId;
    }

    // Function to get student by call the ID
    function getStudent(
        uint8 _studentId
    ) public view isNotAddressZero onlyOwner returns (Student memory) {
        return students[_studentId - 1];
    }

    //function for getting a student by address
    function getStudentFromMapping(
        address _studentAddr
    ) public view isNotAddressZero onlyOwner returns (Student memory) {
        return studentsMapping[_studentAddr];
    }

    // Function for deleting a student by using the student Address
    function deleteStudent(
        address _studentAddr
    ) public onlyOwner isNotAddressZero {
        require(
            studentsMapping[_studentAddr].studentAddr != address(0),
            "Student does not exist"
        );

        // delete studentsMapping[_studentAddr];

        Student memory student = Student({
            studentAddr: address(0),
            name: "",
            age: 0,
            studentId: 0,
            hasPaid: false,
            isAuthorized: false
        });

        studentsMapping[_studentAddr] = student;
    }

    function modifyOwner(address payable _newOwner) public {
        changeOwner(_newOwner);
    }

    // @notice, function for updating student mapping
    // @params, address, name, and age are the parameter for this function
    function updateStudentMapping(
        address _studentAddr,
        string memory _name,
        uint8 _age
    ) public onlyOwner {
        Student storage currentStudent = studentsMapping[_studentAddr];
        currentStudent.name = _name;
        currentStudent.age = _age;
        currentStudent.studentAddr = _studentAddr;
    }


    function getAllStudents() public view  returns (Student[] memory) {
        return students;
    }

    function getOwner() public view override returns (address) {
        return super.getOwner();
    }


    receive() external payable {}
    

    // fallback() external payable {

    // }

}
