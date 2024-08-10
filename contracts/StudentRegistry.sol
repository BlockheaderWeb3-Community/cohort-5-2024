// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import "./Ownable.sol";
import "./Student.sol";

/**
    @title Student Registry contract.
    @author Henry Peters.
    @notice BlockHeader BootCamp, Cohort-5.
    @custom:assignment Payable Contracts by mentor Zintarh, David Nnamdi.
*/
contract StudentRegistry is Ownable {
    /**
        @notice These are custom errors to improve UX (informing users what they're doing wrong) of the smart contract.
        @dev NameIsEmpty is an error type that indicates an empty name calldata was received.
        @dev NotRegistered is an error type that indicates the associated address has registered.
        @dev UnderAge is an error type that indicates the age calldata received is lower than the registration requirements.
    */
    error NameIsEmpty();
    error NotRegistered();
    error UnderAge(uint8 age, uint8 expectedAge);

    /**
        @notice Events emitted improves the UX (cost effective way to update contract state change) of clients listening to our smart contract.
        @dev The _studentAddress is the address of the student whose state is changing
        @dev The _message contains information of what state change (register, enlistment, update, delete) occured.
    */
    event Registration(address indexed _studentAddress, string _message);

    /**
        @notice These are the state variables of this contract.
        @dev students array is deprecated.
        @dev studentsCount is the overall count of students registered on the contract.
        @dev studentsPool is a mapping that stores students whose payments has been completed.
        @dev studentsMapping is the students registry where students whose registrations are successful are enlisted.
        @custom:visibility The studentsCount is marked with a private visibility modifier to make it accessible only within the contract.
        @custom:visibility The studentsPool is marked with a private visibility modifier to make it accessible only within the contract.
        @custom:visibility The studentsMapping is marked with a public visibility modifier to make it accessible within and outside the contract.
    */
    Student[] private students;
    uint256 private studentsCount;
    mapping(address => Student) private studentsPool;
    mapping(address => Student) public studentsMapping;

    /**
        @notice Function modifiers are used to abstract logic into reusable pieces of code, This enhances code reusability and modularity.
        @dev The isNotAddressZero ensures that the address interacting with the contract is a valid address.
        @dev The isOfAge modifier ensures that the _age calldata received meets the age requirements stated by the contract.
        @dev The isValidName modifier ensures that _name calldata received is not empty.
        @dev The isRegistered modifier confirms that the received student address has completed their registration.
    */
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

    /**
        @notice Adds a new student directly to the registry, DEPRECATED.
        @param _studentAddr The address of the student.
        @param _name The name of the student.
        @param _age The age of the student.
    */
    function addStudent(
        address _studentAddr,
        string memory _name,
        uint8 _age
    ) public isNotAddressZero {
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

    /**
        @notice Retrieves the student details by student ID, DEPRECATED.
        @param _studentId The ID of the student.
        @return student The Student associated with the ID.
    */
    function getStudent(
        uint8 _studentId
    ) public view isNotAddressZero returns (Student memory) {
        return students[_studentId - 1];
    }

    /**
        @notice Registers a student with the provided details and confirms registration fees payment.
        @dev The function prevents duplicate registration, and that the correct registration fee is paid.
        @param _studentAddr The unique address of the student.
        @param _age The age of the student.
        @param _name The name of the student.
        @return success A boolean value indicating whether the registration was successful.
    */
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

    /**
        @notice Authorizes the registration of a student by the contract owner.
        @dev The function moves the student from `studentsPool` to `studentsMapping`.
        @param _studentAddr The address of the student.
        @return success A boolean value indicating whether the authorization was successful.
    */
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

    /**
        @notice Updates the details of a registered student.
        @param _studentAddr The address of the student to update.
        @param _age The new age of the student.
        @param _name The new name of the student.
        @return updatedStudent The updated student.
    */
    function updateStudent(
        address _studentAddr,
        uint8 _age,
        string memory _name
    )
        public
        isNotAddressZero
        onlyOwner
        isRegistered(_studentAddr)
        isOfAge(_age)
        isValidName(_name)
        returns (Student memory)
    {
        Student memory student = studentsMapping[_studentAddr];
        student.age = _age;
        student.name = _name;
        studentsMapping[_studentAddr] = student;

        emit Registration(_studentAddr, "Update Successful");
        return student;
    }

    /**
        @notice Retrieves the student details by student address.
        @param _studentAddr The address of the student.
        @return student The Student associated with the address.
    */
    function getStudentFromMapping(
        address _studentAddr
    ) public view isNotAddressZero returns (Student memory) {
        return studentsMapping[_studentAddr];
    }

    /**
        @notice Deletes a student from the registry.
        @param _studentAddr The address of the student to delete.
    */
    function deleteStudent(
        address _studentAddr
    ) public onlyOwner isNotAddressZero isRegistered(_studentAddr) {
        // delete studentsMapping[_studentAddr];

        Student memory student;
        studentsMapping[_studentAddr] = student;

        emit Registration(_studentAddr, "Expulsion Successful");
    }

    /**
        @notice Transfers ownership of the contract to a new owner.
        @param _newOwner The address of the new owner.
    */
    function modifyOwner(address payable _newOwner) public {
        changeOwner(_newOwner);
    }

    /**
        @notice Withdraws the contract's balance to the owner's address.
        @return success A boolean value indicating whether the withdrawal was successful.
    */
    function withdraw() public isNotAddressZero onlyOwner returns (bool) {
        uint256 balance = address(this).balance;
        require(balance > 0, "Empty Balance");

        (bool withdrawn, ) = payable(getOwner()).call{value: balance}("");
        require(withdrawn, "Withdrawal failed");

        return withdrawn;
    }

    /**
        @notice Returns the balance of the contract.
        @return balance The current balance of the contract.
    */
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}