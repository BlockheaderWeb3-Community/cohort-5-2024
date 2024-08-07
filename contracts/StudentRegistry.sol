// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import "./Ownable.sol";
import "./Student.sol";

contract StudentRegistry is Ownable {

    // custom error
    error NameIsEmpty();
    error UnderAge(uint8 age, uint8 expectedAge); 

    // Dynamic array of student
    Student[] private studentsThatPaid;

    Student[] private authorizedStudents;

    mapping(address => Student) public studentMapping;

    mapping(address => uint256) public receipt;

    modifier isNotAddressZero () {
        require(msg.sender != address(0), "Invalid Address");
        _;
    }

    // Events
    event StudentAdded(address indexed studentAddress, uint256 studentId, string name);
    event StudentDeleted(address indexed studentAddress, uint256 studentId, string name);

    function registerStudent(
        address _studentAddr, 
        string memory _name, 
        uint8 _age
    ) public payable {
        uint256 registrationFee = msg.value;

        require(receipt[_studentAddr] == 0, "Already Registered");
        require(registrationFee == 1 ether, "Incorrect Registration Fee");

        if(bytes(_name).length == 0){
            revert NameIsEmpty();
        }
        if (_age < 18) {
            revert UnderAge({ age: _age, expectedAge: 18 });
        }

        Student memory student = Student({
            studentAddr: _studentAddr,
            name: _name,
            age: _age,
            studentID: 0,
            hasPaid: true
        });
        
        studentMapping[_studentAddr] = student;

        (bool success, ) = address(this).call{value: registrationFee}("");
        require(success, "Failed to send payment");

        receipt[_studentAddr] = registrationFee;

        studentsThatPaid.push(student);
    }

    function studentPaymentStatus (address _studentAddr) public view returns (bool) {
        return studentMapping[_studentAddr].hasPaid;
    }

    function studentsWhoPaid() public view onlyOwner returns (Student[] memory) {
        return studentsThatPaid;
    }

    function getAuthorizedStudents() public view onlyOwner returns (Student[] memory) {
        return authorizedStudents;
    }

    function authorizeStudentRegistration(address _studentAddr) private onlyOwner isNotAddressZero {
        require(studentMapping[_studentAddr].studentID == 0, "Student has Already been authorized");
        require(studentMapping[_studentAddr].hasPaid == true, "Fees have not been paid");

        uint256 _studentID = authorizedStudents.length + 1;
        Student memory _student = Student({
            studentAddr: studentMapping[_studentAddr].studentAddr,
            name: studentMapping[_studentAddr].name,
            age: studentMapping[_studentAddr].age,
            hasPaid: studentMapping[_studentAddr].hasPaid,
            studentID: _studentID
        });

        authorizedStudents.push(_student);
        //add student to studentMapping
        studentMapping[_studentAddr] = _student;

        //emit
        emit StudentAdded(_studentAddr, _studentID, _student.name);
    }
    

    function withdraw() public {
        uint256 amount = address(this).balance;
        require(amount > 0, "No Funds");
        require(msg.sender == owner, "Only the owner can withdraw");
        (bool success, ) = owner.call{value: amount}("");
        require(success, "Failed to withdraw ETH");
    }

    function modifyOwner(address payable _newOwner) public {
        changeOwner(_newOwner);
    }

    receive() external payable {}
}