// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import "./Ownable.sol";
import "./Student.sol";


contract StudentRegistry is Ownable {
    //custom erros
    error NameIsEmpty();
    error NotRegistered();
    error UnderAge(uint8 age, uint8 expectedAge);

    //Event Registration
    event Registration(address indexed _studentAddress, string _message);

   
  
    //dynamic array of students
    Student[] private students;
    uint256 private studentsCount;
    mapping(address => Student) private studentsPool;
    mapping(address => Student) public studentsMapping;
   

    modifier isNotAddressZero() {
        require(msg.sender != address(0), "Invalid Address");
        _;
    }
      modifier isOfAge(uint8 _age) {
        if (_age < 18) {
            revert UnderAge(_age, 18);
        }
        _;
    }

     modifier isValidName(string memory _name) {
        if (bytes(_name).length <= 0) {
            revert NameIsEmpty();
        }
        _;
    }

    modifier isRegistered(address _studentAddr) {
        if (!studentsPool[_studentAddr].hasPaid) {
            revert NotRegistered();
        }
        _;
    }

    

// RegisterStudent
    function registerStudent(
        address _studentAddr,
        uint8 _age,
        string memory _name
    )
        public
        payable
        isNotAddressZero
        isOfAge(_age)
        isValidName(_name)
        returns (bool)
    {
        require(!studentsPool[_studentAddr].hasPaid, "Duplicate Registration");
        uint256 regFee = msg.value;
        require(regFee == 1 ether, "Registration Fee is 1Eth");

        studentsCount += 1;
        studentsPool[_studentAddr] = Student({
            studentAddr: _studentAddr,
            name: _name,
            age: _age,
            studentId: studentsCount,
            hasPaid: true
        });

        emit Registration(_studentAddr, "Registration Successful");
        return true;
    }

// authorizeStudentRegistration
 function authorizeStudentRegistration(
        address _studentAddr
    )
        public
        isNotAddressZero
        onlyOwner
        isRegistered(_studentAddr)
        returns (bool)
    {
        require(
            !studentsMapping[_studentAddr].hasPaid,
            "Duplicate Registration"
        );
        studentsMapping[_studentAddr] = studentsPool[_studentAddr];

        emit Registration(_studentAddr, "Enlisted Successfully");
        return true;
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

        uint256 _studentId = students.length + 1;
        Student memory student = Student({
            studentAddr: _studentAddr,
            name: _name,
            age: _age,
            studentId: _studentId,
            hasPaid: true
        });

        students.push(student);
        // add student to studentsMapping
        studentsMapping[_studentAddr] = student;
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
            studentId: 0,
            hasPaid: true
        });

        studentsMapping[_studentAddr] = student;
    }


    function modifyOwner(address payable  _newOwner) public {
        changeOwner(_newOwner);
    }

    // Withdraw
     function withdraw() public isNotAddressZero onlyOwner returns (bool) {
        uint256 balance = address(this).balance;
        require(balance > 0, "Empty Balance");

        (bool withdrawn, ) = payable(getOwner()).call{value: balance}("");
        require(withdrawn, "Withdrawal failed");

        return withdrawn;
    }

    // Getting the current balance
     function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
