# CodeJudge SQL & DBMS Dataset Dictionary
This package contains raw CSV exports from a coding-practice and evaluation platform. The data is intentionally realistic and may contain quality issues that should be detected through SQL audits.
## Tables
### `batches.csv`
Batch/master cohort data. One row per academic batch. batch_id is the intended identifier; batch_code is a readable code.

- Rows: `6`
- Columns:
  - `batch_id`-primary key
  - `batch_code`-candidate key
  - `program`-descriptor
  - `start_date`-lifecycle dates
  - `end_date`-lifecycle dates
  - `batch_status`-status flag

### `courses.csv`
Course catalog data. course_id is the intended identifier; course_code is expected to be unique in a clean design.

- Rows: `10`
- Columns:
  - `course_id`-primary key
  - `course_code`-candidate key
  - `course_title`-descriptor
  - `course_status`-status flag
  - `credit_hours`-attribute

### `students.csv`
Student master data. student_id is the intended identifier; roll_number and email are likely candidate keys.

- Rows: `320`
- Columns:
  - `student_id`-primary key
  - `roll_number`-candidate key
  - `full_name`-descriptor
  - `email`-candidate key
  - `batch_id`-foreign key
  - `admission_date`-lifecycle dates
  - `enrollment_status`-status flag
  - `graduation_year`-attriute

### `enrollments.csv`
Student-course enrollment records. enrollment_id is a raw row identifier; student_id + course_id is an important composite uniqueness candidate.

- Rows: `719`
- Columns:
  - `enrollment_id`-row identifier
  - `student_id`-foreign key
  - `course_id`-foreign key
  - `enrolled_on`-lifecycle dates
  - `enrollment_status`-status flag
  - `final_grade`-result

### `problems.csv`
Programming problems mapped to courses. problem_id is the intended identifier; problem_code is expected to be unique.

- Rows: `67`
- Columns:
  - `problem_id`-primary key
  - `course_id`-foreign key
  - `problem_code`-candidate key
  - `title`-descriptor
  - `difficulty`-attribute
  - `max_score`-scoring
  - `created_at`-audit date
  - `is_active`-status flag

### `test_cases.csv`
Test cases for programming problems. test_case_id is the intended identifier; problem_id + case_no should identify a test case within a problem.

- Rows: `330`
- Columns:
  - `test_case_id`-primary key
  - `problem_id`-foreign key
  - `case_no`-sequence
  - `input_label`-descriptor
  - `expected_output_label`-descriptor
  - `points`-scoring
  - `is_hidden`-status flag

### `contests.csv`
Coding contests/evaluations linked to courses. contest_id is the intended identifier.

- Rows: `12`
- Columns:
  - `contest_id`-primary key
  - `course_id`-foreign key
  - `contest_title`-descriptor
  - `start_time`-start date
  - `end_time`-end date
  - `contest_status`-status flag

### `contest_problems.csv`
Mapping table between contests and problems. contest_id + problem_id is the intended composite key.

- Rows: `63`
- Columns:
  - `contest_id`-foreign key(contest)
  - `problem_id`-foreign key(problem)
  - `problem_order`-sequence

### `submissions.csv`
Student code submissions against problems and optionally contests. submission_id is the intended identifier.

- Rows: `2501`
- Columns:
  - `submission_id`-primary key
  - `student_id`-foreign key
  - `problem_id`-foreign key(problem)
  - `contest_id`-foreign key(contest)
  - `language`-descriptor
  - `submitted_at`-date
  - `status`-status flag
  - `score`-scoring
  - `runtime_ms`-performance

### `test_results.csv`
Result of running individual test cases for submissions. result_id is the raw identifier; submission_id + test_case_id should usually be unique.

- Rows: `9673`
- Columns:
  - `result_id`-row -row identifier
  - `submission_id`-foreign key(submission)
  - `test_case_id`-foreign key(test case)
  - `result_status`-status flag
  - `runtime_ms`-performance
  - `memory_kb`-performance
  - `awarded_points`-scoring

### `sessions.csv`
Course sessions such as lectures, tutorials, or labs.

- Rows: `48`
- Columns:
  - `session_id`-primary key
  - `course_id`-foreign key(course)
  - `session_title`-descriptor
  - `session_date`-date
  - `session_type`-attribute

### `attendance.csv`
Student attendance for sessions. attendance_id is the raw identifier; session_id + student_id should usually be unique.

- Rows: `2352`
- Columns:
  - `attendance_id`-row identifier
  - `session_id`-foreign key(session)
  - `student_id`-foreign key(student)
  - `attendance_status`-status flag
  - `marked_at`-timestamp

### `regrade_requests.csv`
Requests raised by students for re-evaluating submissions.

- Rows: `80`
- Columns:
  - `request_id`-row identifier
  - `submission_id`-foreign key(submission)
  - `student_id`-foreign key(student)
  - `requested_at`-timestamp
  - `reason`-free text reason for request
  - `request_status`-status flag
  - `resolved_at`-timestamp

### `plagiarism_flags.csv`
Similarity/plagiarism review flags between submissions.

- Rows: `60`
- Columns:
  - `flag_id`-row identifier
  - `submission_id`-foreign key(submission)
  - `matched_submission_id`-foreign key(submission)
  - `similarity_score`-metric
  - `flag_status`-status flag
  - `created_at`-audit date

### `raw_student_import.csv`
Raw staging import of new students. This table is intentionally staging-like and may contain messy records.

- Rows: `80`
- Columns:
  - `raw_row_id`-row identifier
  - `roll_number`-identifirer
  - `full_name`-identifirer
  - `email`-identifier
  - `batch_code`lookup value
  - `admission_date`-date
  - `import_status`-status flag
  - `import_notes`-free text

### `operation_requests.csv`
Administrative data-change requests used for safe update/delete and transaction exercises.

- Rows: `35`
- Columns:
  - `operation_id`-primary key
  - `requested_by`-actor
  - `operation_type`-type of operation
  - `target_table`-refference
  - `target_record_id`-refference
  - `requested_at`-lifecycle dates
  - `reason`-free text reason
  - `approval_status`-status flag
  - `executed_at`-timestamp


Normalization Concerns & Data Quality Flags:_

Issue                              | Location                          | Description
--------------------------------------------------------------------------------------------------------------
Redundant FK                       | regrade_requests.student_id       | Already derivable via submission_id; must stay in sync

Redundant score                    | submissions.score vs              | Two sources of truth for the same value
                                   | SUM(test_results.awarded_points)  |

Max score vs test case points      | problems.max_score vs             | Should always agree; divergence indicates an error
                                   | SUM(test_cases.points)            |

No FK enforcement                  | raw_student_import.batch_code     | Uses a label instead of a real FK to batches

No FK enforcement                  | operation_requests.target_table/id| Text references, no relational constraint

Mirror duplicates                  | plagiarism_flags                  | A↔B match may appear twice as A→B and B→A

Composite key gaps                 | enrollments, attendance,          | enrollment_id, attendance_id, result_id are
                                   | test_results                      | surrogate row counters; actual business
                                   |                                   | uniqueness depends on the composite pairs

Candidate key conflicts            | students                          | Both roll_number and email should be unique;
                                   |                                   | if either has duplicates, record identity
                                   |                                   | is ambiguous