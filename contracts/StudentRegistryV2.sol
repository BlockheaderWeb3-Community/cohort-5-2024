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
    event authorizeStudentReg(address _studentAddress);
    event addStud(address _studentAddr);
    event PaidFee(address indexed payer, uint256 amount);

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
        require(bytes(_name).length > 0, "No name has been inputed");
        require(_age >= 18, "age should be 18 or more");
                require(
            studentsMapping[msg.sender].studentAddr != address(0),
            "Pls make payment first"
        );
        Student storage student =  studentsMapping[msg.sender];
        student.name = _name;
        student.age = _age;
        emit registerStudent(msg.sender, _name, _age);
    }

    // Function for authorizing registered Student
    function authorizeStudentRegistration(
        address _studentAddr
    ) public onlyOwner {
    require(
        !studentsMapping[_studentAddr].isAuthorized,
        "Student is already authorized"
    );
require(bytes(studentsMapping[_studentAddr].name).length != 0, "Student is not registered");

        // addStudent(_studentAddr);
    Student storage student = studentsMapping[_studentAddr];
    student.isAuthorized = true;
    students.push(student);
    emit authorizeStudentReg(_studentAddr);
    }

    // Function for Adding student, this function is called in the authorizeStudentRegistration() function
    function addStudent(address _studentAddr) private {
        uint256 _studentId = students.length + 1;
     
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


    function getAllStudents() public view  returns (Student[] memory students) {
        return students;
    }

    function getOwner() public view override returns (address) {
        return super.getOwner();
    }

    function getStudentsLength() public view returns (uint) {
    return students.length;
}


    receive() external payable {}
    

    // fallback() external payable {

    // }

}
