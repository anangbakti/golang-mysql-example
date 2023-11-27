package main

import (
	"database/sql"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"strconv"

	_ "github.com/go-sql-driver/mysql"
)

// Student represents the structure of a student
type Student struct {
	Student_ID int    `json:"student_id"`
	Name       string `json:"name"`
	City       string `json:"city"`
	Year       int    `json:"starting_year"`
}

// Exam represents the structure of an exam
type Exam struct {
	Exam_ID   int    `json:"exam_id"`
	CourseID  int    `json:"course_id"`
	StudentID int    `json:"student_id"`
	ExamType  string `json:"exam_type"`
	Score     int    `json:"score"`
}

// DB is the global variable for the database connection
var DB *sql.DB

func init() {
	var err error

	// Update the connection string with your database information
	connStr := "root:@tcp(127.0.0.1:3306)/School"
	DB, err = sql.Open("mysql", connStr)
	if err != nil {
		log.Fatal(err)
	}

	// Check the database connection
	err = DB.Ping()
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println("Connected to the database")
}

func main() {
	http.HandleFunc("/students/", getStudentAndExams)
	log.Fatal(http.ListenAndServe(":8080", nil))
}

func getStudentByID(id int) (*Student, error) {
	// Query the student from the database
	row := DB.QueryRow("SELECT student_id, name, city, starting_year FROM Students WHERE student_id = ?", id)

	// Populate the Student struct with data from the database
	var student Student
	err := row.Scan(&student.Student_ID, &student.Name, &student.City, &student.Year)
	if err != nil {
		return nil, err
	}

	return &student, nil
}

func getStudentAndExams(w http.ResponseWriter, r *http.Request) {
	// Extract student ID from the URL path
	studentIDStr := r.URL.Path[len("/students/"):]
	studentID, err := strconv.Atoi(studentIDStr)
	if err != nil {
		http.Error(w, "Invalid student ID", http.StatusBadRequest)
		return
	}

	// Query the student information
	student, err := getStudentByID(studentID)
	if err != nil {
		http.Error(w, "Failed to fetch student information", http.StatusInternalServerError)
		return
	}

	// Query the exams for the student
	exams, err := getExamsByStudentID(studentID)
	if err != nil {
		http.Error(w, "Failed to fetch exams", http.StatusInternalServerError)
		return
	}

	// Create the response JSON
	response := map[string]interface{}{
		"student": student,
		"exams":   exams,
	}

	// Convert the response to JSON
	responseJSON, err := json.Marshal(response)
	if err != nil {
		http.Error(w, "Failed to marshal JSON", http.StatusInternalServerError)
		return
	}

	// Set the content type and write the response
	w.Header().Set("Content-Type", "application/json")
	w.Write(responseJSON)
}

func getExamsByStudentID(studentID int) ([]Exam, error) {
	// Query the exams for the student
	rows, err := DB.Query("SELECT exam_id, course_id, student_id, exam_type, score FROM Exams WHERE student_id = ?", studentID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	// Populate the Exam structs with data from the database
	var exams []Exam
	for rows.Next() {
		var exam Exam
		err := rows.Scan(&exam.Exam_ID, &exam.CourseID, &exam.StudentID, &exam.ExamType, &exam.Score)
		if err != nil {
			return nil, err
		}
		exams = append(exams, exam)
	}

	return exams, nil
}
