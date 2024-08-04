# StudentRegistry Contract

## Description

This PR introduces new features to the StudentRegistry contract:

### Updating Student in Mapping 
* implemented updating a student's name and age from the student mapping. 
* Ensures the student exists before updating.

### Updating Student in Array
* Ensures the student exists before the updating.
* Implemented updating a student's name, age and address in the student array.

### Deleting student in Mapping 
* Implemented updating  a student with their address from the student mapping.
* Ensures the student exists before deleting.

### Deleting student in Array
* Ensures the student exists before deleting .
* Implemented deleting a student with their ID from the student array.

## Events 
- Implemented UpdateStudentEvent and DeleteStudentEvent 
* UpdateStudentEvent returns the student's address, ID, name, and age
* DeleteStudentEvent returns the student's record.