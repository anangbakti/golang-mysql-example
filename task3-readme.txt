URL to eecute : http://localhost:8080/students/1
JSON output example : {"exams":[{"exam_id":19,"course_id":1,"student_id":1,"exam_type":"End","score":60},
                        {"exam_id":20,"course_id":1,"student_id":1,"exam_type":"Mid","score":80}],
                        "student":{"student_id":1,"name":"ANDI","city":"MOJOKERTO","starting_year":2020}}

In the code task3.go for question 3, it outputs a collection of exams taken by a student. 
First, a Student and Exam struct is created based on the database data structure.
Then, in the init method, an attempt is made to establish a database connection.
Next, in the main method, it handles the request '/students/' + id. 
If there is a request, it calls the getStudentAndExams method, 
which in turn calls the getStudentByID method to find the student. 
If the student is found, it then retrieves the collection of exams using the getExamsByStudentID method. 
The next collection of exams is converted to JSON as the response.