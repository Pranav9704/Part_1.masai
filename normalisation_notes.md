CODEJUDGE DBMS DATASET - NORMALIZATION REASONING

========================================================
1. REPEATED OR REDUNDANT DATA (AT LEAST 3 EXAMPLES)
========================================================

(1) submissions.score vs test_results.awarded_points
-----------------------------------------------------
- submissions.score stores total marks of a submission
- same value can be derived using:
  SUM(test_results.awarded_points)

PROBLEM:
- Two sources of truth exist
- If test_results changes, submissions.score may become inconsistent

-----------------------------------------------------

(2) problems.max_score vs test_cases.points
--------------------------------------------
- problems.max_score represents total marks of a problem
- can be derived from:
  SUM(test_cases.points)

PROBLEM:
- Redundant storage of computed value
- Risk of mismatch between test case updates and problem max_score

-----------------------------------------------------

(3) regrade_requests.student_id vs submissions.student_id
----------------------------------------------------------
- regrade_requests stores student_id
- but student_id can be derived from:
  submissions.submission_id → student_id

PROBLEM:
- Redundant attribute
- Update anomaly if submission ownership changes or mismatch occurs

-----------------------------------------------------

(4) raw_student_import.batch_code repetition
--------------------------------------------
- batch_code repeated for many rows
- actual batch entity already exists in batches table

PROBLEM:
- Repetition of string data instead of FK reference
- increases storage and inconsistency risk

========================================================
2. SEPARATION INTO ANOTHER TABLE IMPROVES DESIGN
========================================================

(1) contest_problems (many-to-many relationship)
--------------------------------------------------
- A contest can have multiple problems
- A problem can appear in multiple contests

WHY SEPARATE TABLE IS NEEDED:
- Avoids storing multiple problem_ids in one column
- Maintains First Normal Form (1NF)
- Supports scalable many-to-many mapping

-----------------------------------------------------

(2) attendance table separation
-------------------------------
- Students attend multiple sessions
- Each session has multiple students

WHY SEPARATE TABLE IS NEEDED:
- Avoids repeating student columns inside sessions
- Prevents sparse/NULL-heavy design
- Ensures proper many-to-many relationship handling

-----------------------------------------------------

(3) test_cases table separation from problems
---------------------------------------------
- Each problem has multiple test cases

WHY SEPARATE TABLE IS NEEDED:
- Prevents repeating input/output columns inside problems
- Supports variable number of test cases per problem
- Improves scalability and normalization

========================================================
3. FUNCTIONAL DEPENDENCY / PARTIAL DEPENDENCY
========================================================

(1) students table functional dependency
----------------------------------------
student_id → roll_number, full_name, email, batch_id

Also:
roll_number → student_id
email → student_id

MEANING:
- student_id uniquely determines all attributes

-----------------------------------------------------

(2) problems table functional dependency
----------------------------------------
problem_id → problem_code, title, difficulty, max_score, course_id

MEANING:
- All problem attributes depend on problem_id

-----------------------------------------------------

(3) partial dependency example (hypothetical enrollment design)
----------------------------------------------------------------
If a composite key is:
(student_id, course_id)

Then:
student_id → student_name
course_id → course_title

PROBLEM:
- Non-key attributes depend only on part of composite key
- This violates 2NF

NOTE:
Current dataset avoids this by separating students and courses tables

========================================================
4. NORMALIZATION LEVEL ASSESSMENT
========================================================

(1) FIRST NORMAL FORM (1NF)
---------------------------
STATUS: YES (Mostly satisfied)

REASONS:
- All attributes are atomic
- No repeating groups inside rows
- Each row has unique identifier

EXAMPLES:
- attendance(session_id, student_id)
- test_cases(problem_id, case_no)

-----------------------------------------------------

(2) SECOND NORMAL FORM (2NF)
----------------------------
STATUS: YES

REASONS:
- Composite key tables are properly separated
- No partial dependency in existing schema
- Junction tables used correctly

EXAMPLES:
- enrollments(student_id, course_id)
- contest_problems(contest_id, problem_id)

-----------------------------------------------------

(3) THIRD NORMAL FORM (3NF)
---------------------------
STATUS: MOSTLY YES

REASONS:
- Most transitive dependencies removed
- Master data separated properly (students, courses, problems)

MINOR VIOLATIONS:
- submissions.score (derived from test_results)
- problems.max_score (derived from test_cases)
- regrade_requests.student_id (transitive dependency)

========================================================
5. TRADE-OFFS IN DESIGN
========================================================

(1) PERFORMANCE vs NORMALIZATION
---------------------------------
- Storing submissions.score improves query speed (leaderboards)
- But creates redundancy and risk of inconsistency

TRADE-OFF:
- Faster reads vs strict normalization

-----------------------------------------------------

(2) DERIVED ATTRIBUTES STORED PHYSICALLY
----------------------------------------
- max_score and score are precomputed values

BENEFIT:
- Faster analytics and reporting

RISK:
- Must maintain consistency using triggers or updates

-----------------------------------------------------

(3) RAW IMPORT TABLE (DENORMALIZED BY DESIGN)
---------------------------------------------
- raw_student_import uses batch_code instead of batch_id

REASON:
- Easier ETL and data ingestion

TRADE-OFF:
- Better flexibility vs strict relational integrity

========================================================
FINAL CONCLUSION
========================================================

- The database is strongly normalized overall
- It satisfies 1NF, 2NF, and mostly 3NF
- Remaining redundancy is intentional for performance and reporting
- Design follows real-world hybrid approach:
  (Normalization + Controlled Denormalization)