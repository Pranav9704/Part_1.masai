CODEJUDGE DATABASE - ER DIAGRAM 

========================================================
ENTITIES + RELATIONSHIPS (PK / FK INCLUDED)
========================================================

LEGEND:
PK = Primary Key
FK = Foreign Key
UQ = Unique Key

========================================================
1. BATCHES
========================================================
batches(
    PK batch_id,
    batch_code (UQ),
    program,
    start_date,
    end_date,
    batch_status
)

RELATIONSHIPS:
batches (1) ──────── (N) students


========================================================
2. STUDENTS
========================================================
students(
    PK student_id,
    roll_number (UQ),
    email (UQ),
    full_name,
    FK batch_id,
    admission_date,
    enrollment_status,
    graduation_year
)

RELATIONSHIPS:
students (1) ──────── (N) enrollments
students (1) ──────── (N) submissions
students (1) ──────── (N) attendance
students (N) ──────── (1) batches


========================================================
3. COURSES
========================================================
courses(
    PK course_id,
    course_code (UQ),
    course_title,
    credit_hours,
    course_status
)

RELATIONSHIPS:
courses (1) ──────── (N) problems
courses (1) ──────── (N) sessions
courses (1) ──────── (N) contests
courses (1) ──────── (N) enrollments


========================================================
4. ENROLLMENTS (M:N RESOLUTION)
========================================================
enrollments(
    PK enrollment_id,
    FK student_id,
    FK course_id,
    enrolled_on,
    enrollment_status,
    final_grade
)

RELATIONSHIP:
students (M) ──────── (N) courses
via enrollments


========================================================
5. PROBLEMS
========================================================
problems(
    PK problem_id,
    FK course_id,
    problem_code (UQ),
    title,
    difficulty,
    max_score,
    created_at,
    is_active
)

RELATIONSHIPS:
problems (1) ──────── (N) test_cases
problems (1) ──────── (N) submissions
problems (M) ──────── (N) contests via contest_problems


========================================================
6. TEST CASES
========================================================
test_cases(
    PK test_case_id,
    FK problem_id,
    case_no,
    input_label,
    expected_output_label,
    points,
    is_hidden
)

RELATIONSHIP:
problems (1) ──────── (N) test_cases


========================================================
7. SUBMISSIONS
========================================================
submissions(
    PK submission_id,
    FK student_id,
    FK problem_id,
    FK contest_id,
    language,
    submitted_at,
    status,
    score,
    runtime_ms
)

RELATIONSHIPS:
students (1) ──────── (N) submissions
problems (1) ──────── (N) submissions
contests (1) ──────── (N) submissions
submissions (1) ──────── (N) test_results


========================================================
8. TEST RESULTS
========================================================
test_results(
    PK result_id,
    FK submission_id,
    FK test_case_id,
    result_status,
    runtime_ms,
    memory_kb,
    awarded_points
)

RELATIONSHIPS:
submissions (1) ──────── (N) test_results
test_cases (1) ──────── (N) test_results


========================================================
9. SESSIONS
========================================================
sessions(
    PK session_id,
    FK course_id,
    session_title,
    session_date,
    session_type
)

RELATIONSHIP:
courses (1) ──────── (N) sessions
sessions (1) ──────── (N) attendance


========================================================
10. ATTENDANCE
========================================================
attendance(
    PK attendance_id,
    FK session_id,
    FK student_id,
    attendance_status,
    marked_at
)

RELATIONSHIPS:
students (1) ──────── (N) attendance
sessions (1) ──────── (N) attendance


========================================================
11. CONTESTS
========================================================
contests(
    PK contest_id,
    FK course_id,
    contest_title,
    start_time,
    end_time,
    contest_status
)

RELATIONSHIPS:
contests (1) ──────── (N) submissions
contests (M) ──────── (N) problems via contest_problems


========================================================
12. CONTEST_PROBLEMS (M:N RESOLUTION)
========================================================
contest_problems(
    PK (contest_id, problem_id),
    FK contest_id,
    FK problem_id,
    problem_order
)

RELATIONSHIP:
contests (M) ──────── (N) problems


========================================================
13. REGRADE REQUESTS
========================================================
regrade_requests(
    PK request_id,
    FK submission_id,
    FK student_id,
    requested_at,
    reason,
    request_status,
    resolved_at
)

RELATIONSHIPS:
submissions (1) ──────── (N) regrade_requests
students (1) ──────── (N) regrade_requests


========================================================
14. PLAGIARISM FLAGS
========================================================
plagiarism_flags(
    PK flag_id,
    FK submission_id,
    FK matched_submission_id,
    similarity_score,
    flag_status,
    created_at
)

RELATIONSHIP:
submissions (1) ──────── (N) plagiarism_flags
self relationship:
submissions ──────── submissions (matched_submission_id)


========================================================
15. RAW STUDENT IMPORT (STAGING TABLE)
========================================================
raw_student_import(
    raw_row_id,
    roll_number,
    full_name,
    email,
    batch_code,
    admission_date,
    import_status,
    import_notes
)

NOTE:
- No strict foreign keys
- Used for ETL / data cleaning before inserting into students


========================================================
OVERALL RELATIONSHIP SUMMARY
========================================================

ONE-TO-MANY RELATIONSHIPS:
- batches → students
- courses → problems
- courses → sessions
- courses → contests
- students → enrollments
- students → submissions
- students → attendance
- sessions → attendance
- contests → submissions
- problems → test_cases
- submissions → test_results

MANY-TO-MANY RELATIONSHIPS:
- students ↔ courses (via enrollments)
- contests ↔ problems (via contest_problems)
- submissions ↔ test_cases (via test_results)

SELF RELATIONSHIP:
- submissions → submissions (plagiarism_flags)




                                ┌──────────────────┐
                                │     batches      │
                                │──────────────────│
                                │ PK batch_id      │
                                │ batch_code (UQ)  │
                                └────────┬─────────┘
                                         │ 1
                                         │
                                         │ N
                                ┌────────▼─────────┐
                                │     students     │
                                │──────────────────│
                                │ PK student_id    │
                                │ FK batch_id      │
                                │ roll_number (UQ) │
                                │ email (UQ)       │
                                └────────┬─────────┘
                                         │ 1
                                         │
                                         │ N
                 ┌───────────────────────┼────────────────────────┐
                 │                       │                        │
                 ▼                       ▼                        ▼

      ┌──────────────────┐   ┌──────────────────┐   ┌──────────────────┐
      │   enrollments    │   │   submissions    │   │   attendance     │
      │──────────────────│   │──────────────────│   │──────────────────│
      │ PK enrollment_id │   │ PK submission_id │   │ PK attendance_id │
      │ FK student_id    │   │ FK student_id    │   │ FK student_id    │
      │ FK course_id     │   │ FK problem_id    │   │ FK session_id    │
      │ (student,course) │   │ FK contest_id    │   └────────┬─────────┘
      └────────┬─────────┘   └────────┬─────────┘            │
               │ N                    │ N                     │ N
               │                     │                      │
               │                     ▼                      ▼
               │            ┌──────────────────┐   ┌──────────────────┐
               │            │    test_results  │   │     sessions     │
               │            │──────────────────│   │──────────────────│
               │            │ PK result_id     │   │ PK session_id    │
               │            │ FK submission_id │   │ FK course_id     │
               │            │ FK test_case_id  │   └────────┬─────────┘
               │            └────────┬─────────┘            │ 1
               │                     │ N                   │
               │                     ▼                     │ N
               │            ┌──────────────────┐         ▼
               │            │   test_cases     │   ┌──────────────────┐
               │            │──────────────────│   │    courses       │
               │            │ PK test_case_id  │   │──────────────────│
               │            │ FK problem_id    │   │ PK course_id     │
               │            │ (problem,case_no)│   │ course_code (UQ) │
               │            └────────┬─────────┘   └────────┬─────────┘
               │                     │ N                     │ 1
               │                     ▼                      │
               │            ┌──────────────────┐            │
               │            │    problems      │            │
               │            │──────────────────│            │
               │            │ PK problem_id    │◄───────────┘
               │            │ FK course_id     │
               │            │ problem_code(UQ) │
               │            └────────┬─────────┘
               │                     │ N
               │                     │
               ▼                     ▼

        ┌──────────────────┐   ┌──────────────────┐
        │ contest_problems │   │    contests      │
        │──────────────────│   │──────────────────│
        │ PK (contest_id,  │   │ PK contest_id    │
        │     problem_id)  │   │ FK course_id     │
        │ FK contest_id    │   └────────┬─────────┘
        │ FK problem_id    │            │ 1
        └──────────────────┘            │
                                        │ N
                                ┌───────▼─────────┐
                                │ regrade_requests │
                                │──────────────────│
                                │ PK request_id    │
                                │ FK submission_id │
                                │ FK student_id    │
                                └──────────────────┘

                                ┌──────────────────┐
                                │ plagiarism_flags │
                                │──────────────────│
                                │ PK flag_id       │
                                │ FK submission_id │
                                │ FK matched_sub   │
                                └──────────────────┘