CODEJUDGE SQL & DBMS DATASET
KEYS AND CONSTRAINTS

====================================================
1. batches TABLE
====================================================

PRIMARY KEY
- batch_id

CANDIDATE KEYS
- batch_id
- batch_code

ALTERNATE KEY
- batch_code

UNIQUE CONSTRAINTS
- UNIQUE(batch_code)

NOT NULL CONSTRAINTS
- batch_id
- batch_code
- program
- start_date

CHECK CONSTRAINTS
- CHECK(batch_status IN ('ACTIVE','COMPLETED','PLANNED'))

FOREIGN KEYS
- None

COMPOSITE KEYS
- None

WHY?
- batch_id uniquely identifies each batch.
- batch_code prevents duplicate academic batch names.


====================================================
2. courses TABLE
====================================================

PRIMARY KEY
- course_id

CANDIDATE KEYS
- course_id
- course_code

ALTERNATE KEY
- course_code

UNIQUE CONSTRAINTS
- UNIQUE(course_code)

NOT NULL CONSTRAINTS
- course_id
- course_code
- course_title
- credit_hours

CHECK CONSTRAINTS
- CHECK(credit_hours > 0)
- CHECK(course_status IN ('ACTIVE','INACTIVE','ARCHIVED'))

FOREIGN KEYS
- None

WHY?
- course_code should uniquely identify a course.


====================================================
3. students TABLE
====================================================

PRIMARY KEY
- student_id

CANDIDATE KEYS
- student_id
- roll_number
- email

ALTERNATE KEYS
- roll_number
- email

FOREIGN KEY
- batch_id REFERENCES batches(batch_id)

UNIQUE CONSTRAINTS
- UNIQUE(roll_number)
- UNIQUE(email)

NOT NULL CONSTRAINTS
- student_id
- roll_number
- full_name
- email
- batch_id

CHECK CONSTRAINTS
- CHECK(graduation_year >= 2020)
- CHECK(enrollment_status IN ('ACTIVE','DROPPED','GRADUATED'))

WHY?
- roll_number and email uniquely identify students.
- batch_id ensures referential integrity.


====================================================
4. enrollments TABLE
====================================================

PRIMARY KEY
- enrollment_id

COMPOSITE KEY
- (student_id, course_id)

FOREIGN KEYS
- student_id REFERENCES students(student_id)
- course_id REFERENCES courses(course_id)

UNIQUE CONSTRAINTS
- UNIQUE(student_id, course_id)

NOT NULL CONSTRAINTS
- student_id
- course_id
- enrolled_on

CHECK CONSTRAINTS
- CHECK(final_grade IN ('A','B','C','D','F','I'))

WHY?
- Prevents duplicate enrollments.


====================================================
5. problems TABLE
====================================================

PRIMARY KEY
- problem_id

CANDIDATE KEYS
- problem_id
- problem_code

ALTERNATE KEY
- problem_code

FOREIGN KEY
- course_id REFERENCES courses(course_id)

UNIQUE CONSTRAINTS
- UNIQUE(problem_code)

NOT NULL CONSTRAINTS
- problem_id
- course_id
- problem_code
- title
- difficulty
- max_score

CHECK CONSTRAINTS
- CHECK(difficulty IN ('EASY','MEDIUM','HARD'))
- CHECK(max_score > 0)

WHY?
- problem_code uniquely identifies problems.


====================================================
6. test_cases TABLE
====================================================

PRIMARY KEY
- test_case_id

COMPOSITE KEY
- (problem_id, case_no)

FOREIGN KEY
- problem_id REFERENCES problems(problem_id)

UNIQUE CONSTRAINTS
- UNIQUE(problem_id, case_no)

CHECK CONSTRAINTS
- CHECK(points >= 0)
- CHECK(case_no > 0)

WHY?
- Each testcase number should appear once per problem.


====================================================
7. submissions TABLE
====================================================

PRIMARY KEY
- submission_id

FOREIGN KEYS
- student_id REFERENCES students(student_id)
- problem_id REFERENCES problems(problem_id)
- contest_id REFERENCES contests(contest_id)

NOT NULL CONSTRAINTS
- submission_id
- student_id
- problem_id
- submitted_at
- status

CHECK CONSTRAINTS
- CHECK(score >= 0)
- CHECK(runtime_ms >= 0)
- CHECK(status IN ('ACCEPTED','WRONG ANSWER','TLE','RUNTIME ERROR'))

WHY?
- Maintains valid submission records.


====================================================
8. test_results TABLE
====================================================

PRIMARY KEY
- result_id

COMPOSITE KEY
- (submission_id, test_case_id)

FOREIGN KEYS
- submission_id REFERENCES submissions(submission_id)
- test_case_id REFERENCES test_cases(test_case_id)

UNIQUE CONSTRAINTS
- UNIQUE(submission_id, test_case_id)

CHECK CONSTRAINTS
- CHECK(runtime_ms >= 0)
- CHECK(memory_kb >= 0)
- CHECK(awarded_points >= 0)

WHY?
- One result per testcase per submission.


====================================================
9. attendance TABLE
====================================================

PRIMARY KEY
- attendance_id

COMPOSITE KEY
- (session_id, student_id)

FOREIGN KEYS
- session_id REFERENCES sessions(session_id)
- student_id REFERENCES students(student_id)

UNIQUE CONSTRAINTS
- UNIQUE(session_id, student_id)

CHECK CONSTRAINTS
- CHECK(attendance_status IN ('PRESENT','ABSENT','LATE'))

WHY?
- Prevents duplicate attendance records.


====================================================
10. contest_problems TABLE
====================================================

COMPOSITE PRIMARY KEY
- (contest_id, problem_id)

FOREIGN KEYS
- contest_id REFERENCES contests(contest_id)
- problem_id REFERENCES problems(problem_id)

WHY?
- One problem should appear only once in a contest.


====================================================
11. regrade_requests TABLE
====================================================

PRIMARY KEY
- request_id

FOREIGN KEYS
- submission_id REFERENCES submissions(submission_id)
- student_id REFERENCES students(student_id)

CHECK CONSTRAINTS
- CHECK(request_status IN ('PENDING','APPROVED','REJECTED'))

WHY?
- Maintains valid regrade workflow.


====================================================
12. plagiarism_flags TABLE
====================================================

PRIMARY KEY
- flag_id

FOREIGN KEYS
- submission_id REFERENCES submissions(submission_id)
- matched_submission_id REFERENCES submissions(submission_id)

CHECK CONSTRAINTS
- CHECK(similarity_score BETWEEN 0 AND 100)
- CHECK(submission_id <> matched_submission_id)

WHY?
- Prevents invalid plagiarism records.


====================================================
IMPORTANCE OF CONSTRAINTS
====================================================

PRIMARY KEY
- Uniquely identifies records.

FOREIGN KEY
- Maintains referential integrity.

UNIQUE
- Prevents duplication.

NOT NULL
- Prevents missing important data.

CHECK
- Prevents invalid values.

COMPOSITE KEY
- Handles many-to-many relationships.