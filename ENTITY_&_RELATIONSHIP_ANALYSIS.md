================================================================
  CODEJUDGE — ENTITY & RELATIONSHIP ANALYSIS
================================================================

----------------------------------------------------------------
AREA 1: ACADEMIC STRUCTURE
----------------------------------------------------------------

ENTITY: batches
───────────────
Why a separate table:
  A batch is an independent real-world cohort with its own
  timeline and program. Storing it separately avoids repeating
  program and date data on every student row, and lets you query
  or update all students in a batch in one place.

Primary Key:    batch_id
Foreign Keys:   (none)
Composite Key:  (none required)
Unique Columns: batch_code
Not Null:       batch_id, batch_code, program, start_date,
                batch_status
Notes:          (none)


ENTITY: courses
───────────────
Why a separate table:
  A course is an independent academic unit that students enrol
  in and that owns problems, contests, and sessions. Isolating
  it prevents course metadata (title, credits) from being
  repeated across every enrollment, problem, or session row.

Primary Key:    course_id
Foreign Keys:   (none)
Composite Key:  (none required)
Unique Columns: course_code
Not Null:       course_id, course_code, course_title,
                course_status, credit_hours
Notes:          (none)


ENTITY: students
────────────────
Why a separate table:
  A student is the central actor of the whole platform. Every
  submission, attendance mark, and regrade request traces back
  here. Keeping students in their own table avoids duplicating
  personal details across every activity they perform.

Primary Key:    student_id
Foreign Keys:   batch_id --> batches.batch_id
Composite Key:  (none required)
Unique Columns: roll_number, email
Not Null:       student_id, roll_number, full_name, email,
                batch_id, admission_date, enrollment_status
! WARNING:
  roll_number and email are both candidate keys — either can
  uniquely identify a student. Both must be enforced as
  UNIQUE NOT NULL. If either has NULLs or duplicates, student
  identity becomes ambiguous across the platform.


ENTITY: enrollments
───────────────────
Why a separate table:
  Enrollment is a many-to-many relationship between students
  and courses. Without this junction table, you would need to
  store either a list of courses per student or a list of
  students per course — both violate first normal form. It also
  carries enrollment-specific attributes (grade, status) that
  belong to the relationship, not to either entity alone.

Primary Key:    enrollment_id  (surrogate row counter)
Foreign Keys:   student_id --> students.student_id
                course_id  --> courses.course_id
Composite Key:  (student_id, course_id)
                -- a student may only enrol in a given course once
Unique Columns: (student_id, course_id)
Not Null:       enrollment_id, student_id, course_id,
                enrolled_on, enrollment_status
! WARNING:
  enrollment_id is a surrogate row counter. The true business
  uniqueness constraint is the (student_id, course_id)
  composite — duplicate pairs indicate a student was enrolled
  twice in the same course.


----------------------------------------------------------------
AREA 2: PROBLEMS & CONTESTS
----------------------------------------------------------------

ENTITY: problems
────────────────
Why a separate table:
  A problem is a reusable, standalone programming challenge. It
  has its own metadata (difficulty, score, status) and can
  appear in multiple contests. Separating it from contests
  avoids repeating problem details in every contest-problem
  mapping row.

Primary Key:    problem_id
Foreign Keys:   course_id --> courses.course_id
Composite Key:  (none required)
Unique Columns: problem_code
Not Null:       problem_id, course_id, problem_code, title,
                difficulty, max_score, is_active
! WARNING:
  max_score should always equal the sum of points across all
  test cases for this problem. If they diverge, there is an
  inconsistency between two representations of the same fact.


ENTITY: test_cases
──────────────────
Why a separate table:
  Each problem can have multiple test cases, each with its own
  points value and hidden/visible status. Storing them in a
  separate table instead of a flat list on the problem row is
  necessary to model this one-to-many relationship cleanly and
  to reference individual cases in test_results.

Primary Key:    test_case_id
Foreign Keys:   problem_id --> problems.problem_id
Composite Key:  (problem_id, case_no)
                -- case numbers must be unique within a problem,
                   not globally
Unique Columns: (problem_id, case_no)
Not Null:       test_case_id, problem_id, case_no, points,
                is_hidden
Notes:          (none)


ENTITY: contests
────────────────
Why a separate table:
  A contest is a timed evaluation event owned by a course. It
  is distinct from problems (which are reusable) and from
  submissions (which are student acts). Separating contests
  lets you manage scheduling, status, and course ownership
  independently from the problem bank.

Primary Key:    contest_id
Foreign Keys:   course_id --> courses.course_id
Composite Key:  (none required)
Unique Columns: (none beyond PK)
Not Null:       contest_id, course_id, contest_title,
                start_time, end_time, contest_status
Notes:          (none)


ENTITY: contest_problems
────────────────────────
Why a separate table:
  A contest contains many problems, and a problem can appear in
  many contests — a classic many-to-many relationship. This
  mapping table is required to resolve it cleanly. It also
  carries contest-specific ordering (problem_order) that belongs
  to the relationship, not to either entity alone.

Primary Key:    (contest_id, problem_id)  -- natural composite PK;
                no surrogate needed
Foreign Keys:   contest_id --> contests.contest_id
                problem_id --> problems.problem_id
Composite Key:  (contest_id, problem_id) IS the primary key
Unique Columns: (contest_id, problem_id)
Not Null:       contest_id, problem_id, problem_order
Notes:          (none)


----------------------------------------------------------------
AREA 3: SUBMISSIONS & EVALUATION
----------------------------------------------------------------

ENTITY: submissions
───────────────────
Why a separate table:
  A submission is the core transactional event of the platform
  — a student's attempt at solving a problem. It is separate
  from students and problems because it captures the moment of
  execution: which language was used, when it was submitted,
  what the outcome was. It is also the parent of test_results,
  regrade_requests, and plagiarism_flags.

Primary Key:    submission_id
Foreign Keys:   student_id  --> students.student_id
                problem_id  --> problems.problem_id
                contest_id  --> contests.contest_id  (NULLABLE)
Composite Key:  (none required)
Unique Columns: (none beyond PK)
Not Null:       submission_id, student_id, problem_id,
                submitted_at, status
! WARNING:
  contest_id must be nullable — practice submissions outside
  any contest are valid. The score column may duplicate the
  sum of awarded_points in test_results; both must be kept
  consistent or one should be removed.


ENTITY: test_results
────────────────────
Why a separate table:
  When a submission is evaluated, the judge runs it against
  every test case individually and produces a separate result
  for each. Storing these in their own table (rather than
  aggregating onto the submission) preserves per-case details
  like runtime, memory, and awarded points — essential for
  partial-credit grading and debugging.

Primary Key:    result_id  (surrogate row counter)
Foreign Keys:   submission_id --> submissions.submission_id
                test_case_id  --> test_cases.test_case_id
Composite Key:  (submission_id, test_case_id)
                -- a submission should be evaluated against
                   the same test case only once
Unique Columns: (submission_id, test_case_id)
Not Null:       result_id, submission_id, test_case_id,
                result_status, awarded_points
! WARNING:
  Duplicate (submission_id, test_case_id) pairs indicate a
  re-evaluation bug or pipeline issue. The sum of
  awarded_points here should always equal submissions.score
  for the parent submission.


ENTITY: regrade_requests
────────────────────────
Why a separate table:
  A regrade request is a formal appeal workflow separate from
  the submission itself. Keeping it in its own table lets you
  track request lifecycle (pending --> resolved), store the
  student's reason, and query all open appeals without
  touching the submissions table.

Primary Key:    request_id
Foreign Keys:   submission_id --> submissions.submission_id
                student_id    --> students.student_id
Composite Key:  (none required)
Unique Columns: (none beyond PK)
Not Null:       request_id, submission_id, student_id,
                requested_at, request_status
! WARNING:
  student_id is derivable from submission_id via
  submissions.student_id. Storing it here is denormalization
  — convenient for queries but it must always match the parent
  submission's student or the record is inconsistent.


ENTITY: plagiarism_flags
────────────────────────
Why a separate table:
  Plagiarism detection produces a similarity score between two
  specific submissions. This is a relationship between two rows
  in the same table (a self-referencing many-to-many), which
  requires its own table to model. It also carries flag-
  specific data: the similarity score, status, and creation
  date.

Primary Key:    flag_id
Foreign Keys:   submission_id         --> submissions.submission_id
                matched_submission_id --> submissions.submission_id
Composite Key:  (none required)
Unique Columns: (none beyond PK)
Not Null:       flag_id, submission_id, matched_submission_id,
                similarity_score, flag_status, created_at
! WARNING:
  A match between submission A and B could produce two rows
  (A-->B and B-->A). A UNIQUE constraint on
  (LEAST(submission_id, matched_submission_id),
   GREATEST(submission_id, matched_submission_id))
  prevents mirror duplicates.


----------------------------------------------------------------
AREA 4: OPERATIONS & ATTENDANCE
----------------------------------------------------------------

ENTITY: sessions
────────────────
Why a separate table:
  A session (lecture, lab, tutorial) is a discrete scheduled
  event belonging to a course. Separating sessions from
  attendance is necessary because a session has its own
  metadata (date, type, title) and serves as the parent for
  all student attendance records.

Primary Key:    session_id
Foreign Keys:   course_id --> courses.course_id
Composite Key:  (none required)
Unique Columns: (none beyond PK)
Not Null:       session_id, course_id, session_title,
                session_date, session_type
Notes:          (none)


ENTITY: attendance
──────────────────
Why a separate table:
  Attendance is a many-to-many relationship between students
  and sessions. A student can attend many sessions; a session
  has many students. Each combination produces one record with
  its own status (present, absent, late). Flattening this onto
  either parent table is not possible.

Primary Key:    attendance_id  (surrogate row counter)
Foreign Keys:   session_id --> sessions.session_id
                student_id --> students.student_id
Composite Key:  (session_id, student_id)
                -- a student should have exactly one attendance
                   record per session
Unique Columns: (session_id, student_id)
Not Null:       attendance_id, session_id, student_id,
                attendance_status, marked_at
! WARNING:
  attendance_id is a surrogate. The true uniqueness constraint
  is (session_id, student_id). Duplicate pairs mean a student
  was marked twice for the same session.


ENTITY: raw_student_import
──────────────────────────
Why a separate table:
  This is a staging table for unvalidated inbound data —
  typically loaded from spreadsheets before being cleaned and
  promoted into the students table. It must exist separately
  from students because it intentionally relaxes constraints
  (no real FKs, nullable fields, possible duplicates) that the
  students table enforces strictly.

Primary Key:    raw_row_id
Foreign Keys:   (none — batch_code is a label lookup, not a FK)
Composite Key:  (none required)
Unique Columns: (none enforced at this stage)
Not Null:       raw_row_id, import_status
! WARNING:
  batch_code references batches by a readable label, not by
  batch_id — there is no FK constraint enforced. NULL,
  malformed, or duplicate values in roll_number and email are
  expected here and must be caught during validation before
  records are promoted to the students table.


ENTITY: operation_requests
──────────────────────────
Why a separate table:
  Administrative data-change requests (updates, deletes) need
  an audit trail separate from the tables they target. Storing
  them here enables approval workflows and a tamper-evident log
  without cluttering operational tables with approval metadata.

Primary Key:    operation_id
Foreign Keys:   (none — references are stored as plain text)
Composite Key:  (none required)
Unique Columns: (none beyond PK)
Not Null:       operation_id, requested_by, operation_type,
                target_table, target_record_id, requested_at,
                approval_status
! WARNING:
  target_table and target_record_id are plain text — there is
  intentionally no FK constraint, since this table can
  reference any table. This means no referential integrity is
  enforced; the audit log can point to records that no longer
  exist.


================================================================
  SUMMARY: CONSTRAINT REFERENCE TABLE
================================================================

Entity               PK                  Composite Key
-------------------  ------------------  --------------------------
batches              batch_id            --
courses              course_id           --
students             student_id          --
enrollments          enrollment_id       (student_id, course_id)
problems             problem_id          --
test_cases           test_case_id        (problem_id, case_no)
contests             contest_id          --
contest_problems     (contest_id,        IS the primary key
                      problem_id)
submissions          submission_id       --
test_results         result_id           (submission_id,
                                          test_case_id)
regrade_requests     request_id          --
plagiarism_flags     flag_id             --
sessions             session_id          --
attendance           attendance_id       (session_id, student_id)
raw_student_import   raw_row_id          --
operation_requests   operation_id        --


Entity               Notable UNIQUE cols
-------------------  -----------------------------------
batches              batch_code
courses              course_code
students             roll_number, email
enrollments          (student_id, course_id)
problems             problem_code
test_cases           (problem_id, case_no)
contest_problems     (contest_id, problem_id)
test_results         (submission_id, test_case_id)
attendance           (session_id, student_id)


================================================================
  END OF DOCUMENT
================================================================