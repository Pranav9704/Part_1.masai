CODEJUDGE DBMS - SQL DDL SCHEMA (CLEAN RELATIONAL DESIGN)

========================================================
ASSUMPTIONS
========================================================
1. All IDs (student_id, course_id, etc.) are INTEGER AUTO-INCREMENT.
2. Codes (batch_code, course_code, problem_code) are UNIQUE business identifiers.
3. Derived fields (like submission score) are stored for performance.
4. Status fields are controlled using CHECK constraints.
5. Raw import table is kept separate as staging (no strict FK).

========================================================
1. BATCHES TABLE
========================================================
CREATE TABLE batches (
    batch_id INT PRIMARY KEY AUTO_INCREMENT,
    batch_code VARCHAR(20) UNIQUE NOT NULL,
    program VARCHAR(100) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    batch_status VARCHAR(20) NOT NULL,

    CHECK (batch_status IN ('ACTIVE','COMPLETED','PLANNED'))
);

--------------------------------------------------------

2. COURSES TABLE
--------------------------------------------------------
CREATE TABLE courses (
    course_id INT PRIMARY KEY AUTO_INCREMENT,
    course_code VARCHAR(20) UNIQUE NOT NULL,
    course_title VARCHAR(255) NOT NULL,
    credit_hours INT NOT NULL,
    course_status VARCHAR(20) NOT NULL,

    CHECK (credit_hours > 0),
    CHECK (course_status IN ('ACTIVE','INACTIVE','ARCHIVED'))
);

--------------------------------------------------------

3. STUDENTS TABLE
--------------------------------------------------------
CREATE TABLE students (
    student_id INT PRIMARY KEY AUTO_INCREMENT,
    roll_number VARCHAR(30) UNIQUE NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    batch_id INT NOT NULL,
    admission_date DATE,
    enrollment_status VARCHAR(20) NOT NULL,
    graduation_year INT,

    FOREIGN KEY (batch_id) REFERENCES batches(batch_id),

    CHECK (enrollment_status IN ('ACTIVE','DROPPED','GRADUATED')),
    CHECK (graduation_year >= 2020)
);

--------------------------------------------------------

4. ENROLLMENTS TABLE
--------------------------------------------------------
CREATE TABLE enrollments (
    enrollment_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    enrolled_on DATE NOT NULL,
    enrollment_status VARCHAR(20),
    final_grade CHAR(2),

    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (course_id) REFERENCES courses(course_id),

    UNIQUE (student_id, course_id),

    CHECK (final_grade IN ('A','B','C','D','F','I'))
);

--------------------------------------------------------

5. PROBLEMS TABLE
--------------------------------------------------------
CREATE TABLE problems (
    problem_id INT PRIMARY KEY AUTO_INCREMENT,
    course_id INT NOT NULL,
    problem_code VARCHAR(30) UNIQUE NOT NULL,
    title VARCHAR(255) NOT NULL,
    difficulty VARCHAR(10) NOT NULL,
    max_score INT NOT NULL,
    created_at DATE,
    is_active BOOLEAN DEFAULT TRUE,

    FOREIGN KEY (course_id) REFERENCES courses(course_id),

    CHECK (difficulty IN ('EASY','MEDIUM','HARD')),
    CHECK (max_score > 0)
);

--------------------------------------------------------

6. TEST_CASES TABLE
--------------------------------------------------------
CREATE TABLE test_cases (
    test_case_id INT PRIMARY KEY AUTO_INCREMENT,
    problem_id INT NOT NULL,
    case_no INT NOT NULL,
    input_label TEXT,
    expected_output_label TEXT,
    points INT NOT NULL,
    is_hidden BOOLEAN DEFAULT FALSE,

    FOREIGN KEY (problem_id) REFERENCES problems(problem_id),

    UNIQUE (problem_id, case_no),

    CHECK (case_no > 0),
    CHECK (points >= 0)
);

--------------------------------------------------------

7. CONTESTS TABLE
--------------------------------------------------------
CREATE TABLE contests (
    contest_id INT PRIMARY KEY AUTO_INCREMENT,
    course_id INT NOT NULL,
    contest_title VARCHAR(255) NOT NULL,
    start_time DATETIME NOT NULL,
    end_time DATETIME NOT NULL,
    contest_status VARCHAR(20) NOT NULL,

    FOREIGN KEY (course_id) REFERENCES courses(course_id),

    CHECK (contest_status IN ('UPCOMING','ONGOING','COMPLETED'))
);

--------------------------------------------------------

8. CONTEST_PROBLEMS TABLE
--------------------------------------------------------
CREATE TABLE contest_problems (
    contest_id INT NOT NULL,
    problem_id INT NOT NULL,
    problem_order INT NOT NULL,

    PRIMARY KEY (contest_id, problem_id),

    FOREIGN KEY (contest_id) REFERENCES contests(contest_id),
    FOREIGN KEY (problem_id) REFERENCES problems(problem_id)
);

--------------------------------------------------------

9. SUBMISSIONS TABLE
--------------------------------------------------------
CREATE TABLE submissions (
    submission_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT NOT NULL,
    problem_id INT NOT NULL,
    contest_id INT,
    language VARCHAR(30) NOT NULL,
    submitted_at DATETIME NOT NULL,
    status VARCHAR(30) NOT NULL,
    score INT DEFAULT 0,
    runtime_ms INT,

    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (problem_id) REFERENCES problems(problem_id),
    FOREIGN KEY (contest_id) REFERENCES contests(contest_id),

    CHECK (score >= 0),
    CHECK (runtime_ms >= 0),
    CHECK (status IN ('ACCEPTED','WRONG ANSWER','TLE','RUNTIME ERROR','PENDING'))
);

--------------------------------------------------------

10. TEST_RESULTS TABLE
--------------------------------------------------------
CREATE TABLE test_results (
    result_id INT PRIMARY KEY AUTO_INCREMENT,
    submission_id INT NOT NULL,
    test_case_id INT NOT NULL,
    result_status VARCHAR(20),
    runtime_ms INT,
    memory_kb INT,
    awarded_points INT NOT NULL,

    FOREIGN KEY (submission_id) REFERENCES submissions(submission_id),
    FOREIGN KEY (test_case_id) REFERENCES test_cases(test_case_id),

    UNIQUE (submission_id, test_case_id),

    CHECK (runtime_ms >= 0),
    CHECK (memory_kb >= 0),
    CHECK (awarded_points >= 0)
);

--------------------------------------------------------

11. SESSIONS TABLE
--------------------------------------------------------
CREATE TABLE sessions (
    session_id INT PRIMARY KEY AUTO_INCREMENT,
    course_id INT NOT NULL,
    session_title VARCHAR(255) NOT NULL,
    session_date DATE NOT NULL,
    session_type VARCHAR(30),

    FOREIGN KEY (course_id) REFERENCES courses(course_id)
);

--------------------------------------------------------

12. ATTENDANCE TABLE
--------------------------------------------------------
CREATE TABLE attendance (
    attendance_id INT PRIMARY KEY AUTO_INCREMENT,
    session_id INT NOT NULL,
    student_id INT NOT NULL,
    attendance_status VARCHAR(20) NOT NULL,
    marked_at DATETIME,

    FOREIGN KEY (session_id) REFERENCES sessions(session_id),
    FOREIGN KEY (student_id) REFERENCES students(student_id),

    UNIQUE (session_id, student_id),

    CHECK (attendance_status IN ('PRESENT','ABSENT','LATE'))
);

--------------------------------------------------------

13. REGRAGE_REQUESTS TABLE
--------------------------------------------------------
CREATE TABLE regrade_requests (
    request_id INT PRIMARY KEY AUTO_INCREMENT,
    submission_id INT NOT NULL,
    student_id INT NOT NULL,
    requested_at DATETIME NOT NULL,
    reason TEXT,
    request_status VARCHAR(20) NOT NULL,
    resolved_at DATETIME,

    FOREIGN KEY (submission_id) REFERENCES submissions(submission_id),
    FOREIGN KEY (student_id) REFERENCES students(student_id),

    CHECK (request_status IN ('PENDING','APPROVED','REJECTED'))
);

--------------------------------------------------------

14. PLAGIARISM_FLAGS TABLE
--------------------------------------------------------
CREATE TABLE plagiarism_flags (
    flag_id INT PRIMARY KEY AUTO_INCREMENT,
    submission_id INT NOT NULL,
    matched_submission_id INT NOT NULL,
    similarity_score DECIMAL(5,2),
    flag_status VARCHAR(20),
    created_at DATETIME,

    FOREIGN KEY (submission_id) REFERENCES submissions(submission_id),
    FOREIGN KEY (matched_submission_id) REFERENCES submissions(submission_id),

    CHECK (similarity_score BETWEEN 0 AND 100),
    CHECK (submission_id <> matched_submission_id)
);

--------------------------------------------------------

15. RAW STUDENT IMPORT (STAGING TABLE)
--------------------------------------------------------
CREATE TABLE raw_student_import (
    raw_row_id INT PRIMARY KEY AUTO_INCREMENT,
    roll_number VARCHAR(30),
    full_name VARCHAR(100),
    email VARCHAR(100),
    batch_code VARCHAR(20),
    admission_date DATE,
    import_status VARCHAR(20),
    import_notes TEXT
);

========================================================
END OF SCHEMA DESIGN
========================================================