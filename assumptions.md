CODEJUDGE DBMS PROJECT - ASSUMPTIONS TAKEN

========================================================
1. GENERAL DESIGN ASSUMPTIONS
========================================================
- Each table has a surrogate primary key (INT AUTO_INCREMENT) unless stated otherwise.
- Business codes (batch_code, course_code, problem_code) are assumed UNIQUE.
- Data follows a relational structure suitable for 3NF design.
- Derived values (like submission score) may be stored for performance but are considered logically derivable.

========================================================
2. DATA TYPE ASSUMPTIONS
========================================================
- All IDs (student_id, course_id, etc.) are INTEGER type.
- Names and textual fields use VARCHAR with reasonable limits.
- Dates use DATE or DATETIME based on requirement.
- Boolean fields are represented as BOOLEAN or TINYINT(1).
- Scores, points, and runtime values are non-negative integers.

========================================================
3. KEY AND CONSTRAINT ASSUMPTIONS
========================================================
- Primary keys are always NOT NULL and UNIQUE by default.
- Foreign keys always reference valid parent records (referential integrity enforced).
- Composite keys are used only in mapping tables (M:N relationships).
- UNIQUE constraints are applied to natural identifiers like email, roll_number, and course_code.
- CHECK constraints are assumed to be enforced at database level (or via application logic if unsupported).

========================================================
4. RELATIONSHIP ASSUMPTIONS
========================================================
- One batch contains many students.
- One student can enroll in multiple courses.
- One course contains multiple problems and sessions.
- One contest can include multiple problems.
- One student can make multiple submissions per problem.
- Each submission generates multiple test case results.
- Attendance is recorded per student per session.
- Plagiarism is detected by comparing one submission with another submission.

========================================================
5. DERIVED DATA ASSUMPTIONS
========================================================
- submissions.score is derived from SUM(test_results.awarded_points).
- problems.max_score is derived from SUM(test_cases.points).
- regrade_requests.student_id is derived from submissions.student_id but stored for easier querying.
- These derived fields may become inconsistent if not properly maintained (acknowledged trade-off).

========================================================
6. STAGING TABLE ASSUMPTIONS
========================================================
- raw_student_import is a temporary staging table.
- It may contain dirty, incomplete, or duplicate data.
- It does not enforce foreign key constraints.
- Data from this table must be validated before insertion into students table.

========================================================
7. BUSINESS LOGIC ASSUMPTIONS
========================================================
- Email and roll_number uniquely identify a student.
- course_code uniquely identifies a course.
- problem_code uniquely identifies a problem.
- A student cannot enroll in the same course more than once.
- A test case is uniquely identified within a problem by (problem_id, case_no).
- A submission has one score per attempt per problem (or contest attempt context).

========================================================
8. NORMALIZATION ASSUMPTIONS
========================================================
- Database is designed to be in at least 3NF.
- Some controlled denormalization exists for performance optimization.
- Redundant attributes are intentional in few cases (score, max_score).

========================================================
END OF ASSUMPTIONS
========================================================