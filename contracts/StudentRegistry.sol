// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;


/**
*@title studentRegistry contract to register students.
*@author Iwuese
*/
contract StudentRegistry {

   struct Student {
    address studentAddr;
    string name;
    uint8 age; 
    uint256 studentId;

   } 

address public owner;
/**
*@notice msg.sender is the owner of the contract. 
*/
constructor () {
    owner = msg.sender; 

}

   //dynamic array of students
   Student[] public students;

//A mapping for students that requires the address as the Unique Identifier for each student.
   mapping (address => Student) public studentsMapping;

//
   modifier onlyOwner () {
    require( owner == msg.sender, "You fraud!!!");
    _;
   }
//modifier to show that the address deploying the contract is not address zero
  modifier isNotAddressZero () {
    require(msg.sender != address(0), "Invalid Address");
    _;
  }
 
//declaring the addStudent event
 event addStudentEvent (address indexed owner,  address indexed studentAddr, string name, uint8 age); 

 //declaring deleteStudent event
 event deleteStudentFromMappingEvent (address indexed owner,  address indexed studentAddr);



 /**
 *@notice student is added to 'students' array.
 *@param  '_name' the name of the student.
 *@param ' _age' The age of the student
 *@param  '_studentAddr' the address of  student.
 *@dev require that the age of the student to be added must be greater than 18.
 *@dev only the address that deployed the contract(owner) is authourised to add student.
 *@custom:modifier onlyOwner Ensures that only the contract owner can add student to registry.
 *@custom:modifier isNotAddressZero Ensures that the provided address is not the zero address.
 *@notice Emits a `addStudentEvent` event.
 */
 function addStudent(address _studentAddr, string memory _name, uint8 _age) public onlyOwner isNotAddressZero {
  
    require(_age > 18, "student must be 18 years old!");
    require(bytes(_name).length > 0, "Name cannot be blank");

  uint256 _studentId = students.length + 1;
    Student memory student = Student({
  studentAddr: _studentAddr,
  name: _name,
  age: _age,
  studentId: _studentId

    });
//push to student array
  students.push(student);

//add to studentsMapping
    studentsMapping[_studentAddr] = student;

// initiating the 'addStudentEvent'
    emit addStudentEvent (msg.sender, _studentAddr, _name, _age);

 }


/**
*@notice  get student from 'students' array.
*@dev _studentId - 1 is the index of student in the array
*@return  the studentId from the 'student' array
*/
 function getStudent(uint8 _studentId) public view returns (Student memory) {
    return students[ _studentId - 1];
 }


function getStudentFromMapping(address _studentAddr) public view returns (Student memory) {
    return studentsMapping[_studentAddr];
 }


/**
*@notice updates the information of the student in the mapping with the _studentAddr provided if found.
*@dev The function loops through the studentsMapping to find the student with the given address.
*@dev The function returns true if the student was found and updated.
*@dev Only the owner of the contract can call this function.  
*@param '_studentAddr' The new address of the student.
*@param '_name' The new name of the student.
*@param '_age' The new age of the student.
*/

//updating student in the mapping
function updateStudentForMapping (address _studentAddr, string memory _name, uint8 _age) public onlyOwner isNotAddressZero {
bool studentFound = false;
    require(_age > 18, "student must be 18 years old!");
    require(bytes(_name).length > 0, "Name cannot be blank");

   for (uint8 i = 0; i < students.length; i++) {
            if ( students[i].studentAddr == _studentAddr) {
               students[i].name = _name;
                students[i].age = _age;
                 studentFound = true; 
            }
        }
       
}


/**
*@notice updates the information of the student with the provided ID if found.
*@dev The function loops through the students array to find the student with the given ID.
*@dev The function returns true if the student was found and updated.
*@dev Only the owner of the contract can call this function.
*@param '_studentId' The ID of the student to update.
*@param '_studentAddr' The new address of the student.
*@param '_name' The new name of the student.
*@param '_age' The new age of the student.
*/

 function updateStudent(uint8 _studentId, address _studentAddr, string memory _name, uint8 _age) public {
        bool studentFound = false;
        require(owner == msg.sender, "You are not permitted to update student"); 

        for (uint8 i = 0; i < students.length; i++) {
            if (students[i].studentId == _studentId) {
                students[i].studentAddr = _studentAddr;
                students[i].name = _name;
                students[i].age = _age;
                studentFound = true; 
            }
        }
 }





  
/**
 * @notice Deletes a student from the students mapping.
 * @dev The student must exist in the mapping.
 * @dev This function sets the student's address to zero and clears all other fields.
 * @param '_studentAddr' The address of the student to be deleted.
 * @custom:modifier onlyOwner Ensures that only the contract owner can delete student from mapping.
 * @custom:modifier isNotAddressZero Ensures that the provided address is not the zero address.
  * @notice Emits a `deleteStudentFromMappingEvent` event.
 */
function deleteStudentFromMapping(address _studentAddr) public onlyOwner isNotAddressZero{

require(studentsMapping[_studentAddr].studentAddr != address(0), "Student does not exist");

  // delete studentsMapping[_studentAddr];

  Student memory student = Student({
  studentAddr: address(0),
  name: "",
  age: 0,
  studentId: 0

    });

    studentsMapping[_studentAddr] = student;


//initiating the 'deleteStudentFromMappingEvent'.
    emit deleteStudentFromMappingEvent(msg.sender, _studentAddr);
}



/**
*@notice removes the student with the provided Id. 
*@dev only the address that deployed the contract(owner) is authourised to remove student.
*@dev shifts .all students after the removed student to the left to maintain array continuity
*@param '_studentId' index of student to be removed from the registry.
*@return bool Returns true if the student with the Id provided was found and removed, and false if not found and removed.
*/

function deleteStudent(uint _studentId) public  returns(bool) { 
 require(owner == msg.sender, "You are not permitted to delete student");
if ( _studentId >= students.length) {
  return false;
}
for (uint i = _studentId; i < students.length - 1; i++) {
students[i] = students[i + 1];
}
  
students.pop(); 
  return true;
    
}


} 