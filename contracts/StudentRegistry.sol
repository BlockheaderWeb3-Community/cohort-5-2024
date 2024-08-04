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

    address public owner;
    uint256 public fee; // Fee for the getStudent function

    //dynamic array of students
    Student[] private students;

    mapping(address => Student) public studentsMapping;
    event FeeUpdated(uint256 newFee);
    event Balance(uint256 balance);


    modifier onlyOwner () {
        require( owner == msg.sender, "You fraud!!!");
        _;
    }

    modifier isNotAddressZero () {
        require(msg.sender != address(0), "Invalid Address");
        _;
    }

    constructor(uint256 _fee) {
        owner = msg.sender;
        fee = _fee;
        // fee = 10 ether;
    }
 
    receive() external payable {}

    // Owner can chahge fee
    function setFee(uint256 _newFee) public onlyOwner {
        fee = _newFee;
        emit FeeUpdated(_newFee);
    }

    function addStudent(
        address _studentAddr,
        string memory _name,
        uint8 _age
     ) public onlyOwner isNotAddressZero {

        require( bytes(_name).length > 0, "Name cannot be blank");
        require( _age >= 18, "This student is under age");

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

    // Take ether on getStudent request
    function getStudent(uint8 _studentId) public payable isNotAddressZero returns (Student memory) {
         require(msg.value >= fee, "Insufficient fee sent");
        // The fee will be stored in the contract
        return students[_studentId - 1];
    }


    function getStudentFromMapping(address _studentAddr)
        public
        isNotAddressZero
        view
        returns (Student memory)
    {
       
        return studentsMapping[_studentAddr];
    }



    function deleteStudent(address _studentAddr) public onlyOwner  isNotAddressZero{

        require(studentsMapping[_studentAddr].studentAddr != address(0), "Student does not exist");

        // delete studentsMapping[_studentAddr];

        Student memory student = Student({
            studentAddr: address(0),
            name: "",
            age: 0,
            studentId: 0
        });

        studentsMapping[_studentAddr] = student;

    }

    // View Contract balance
     function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    // Owner can transfer ether to their address
     function withdraw() public payable onlyOwner {
        // Get stored ether
        uint256 amount = address(this).balance;
        require(amount > 0, "No funds to withdraw");

        // Send ether to owner
        (bool sent,) = payable(owner).call{value: amount}("");
        require(sent, "Failed to send Ether"); 
    }
}
