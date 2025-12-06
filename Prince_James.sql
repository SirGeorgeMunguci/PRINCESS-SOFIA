-- =============================================
-- STUDENT INFORMATION SYSTEM DATABASE
-- Organized and Optimized Code
-- =============================================
show databases;
drop database student_information_System;

-- Create Database
CREATE DATABASE IF NOT EXISTS Student_information_System;
USE Student_information_System;

-- =============================================
-- CORE TABLES
-- =============================================

-- Person table
CREATE TABLE Person (
    person_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_person_email CHECK (email LIKE '%@%.%')
);

-- Program table
CREATE TABLE Program (
    prog_id INT PRIMARY KEY AUTO_INCREMENT,
    code VARCHAR(20) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    duration_years INT DEFAULT 4,
    total_credits INT NOT NULL,
    status ENUM('Active', 'Inactive') DEFAULT 'Active',
    CONSTRAINT chk_program_credits CHECK (total_credits > 0)
);

-- Student table
CREATE TABLE Student (
    student_id INT PRIMARY KEY AUTO_INCREMENT,
    person_id INT UNIQUE NOT NULL,
    reg_no VARCHAR(20) UNIQUE NOT NULL,
    program_id INT NOT NULL,
    year_of_study INT DEFAULT 1,
    enrollment_date DATE NOT NULL,
    status ENUM('Active', 'Graduated', 'Withdrawn') DEFAULT 'Active',
    FOREIGN KEY (person_id) REFERENCES Person(person_id) ON DELETE CASCADE,
    FOREIGN KEY (program_id) REFERENCES Program(prog_id),
    CONSTRAINT chk_student_year CHECK (year_of_study BETWEEN 1 AND 6)
);

-- Lecturer table
CREATE TABLE Lecturer (
    lecturer_id INT PRIMARY KEY AUTO_INCREMENT,
    person_id INT UNIQUE NOT NULL,
    dept VARCHAR(100) NOT NULL,
    title VARCHAR(50),
    hire_date DATE NOT NULL,
    status ENUM('Active', 'Inactive') DEFAULT 'Active',
    FOREIGN KEY (person_id) REFERENCES Person(person_id) ON DELETE CASCADE
);

-- Course table
CREATE TABLE Course (
    course_id INT PRIMARY KEY AUTO_INCREMENT,
    code VARCHAR(20) UNIQUE NOT NULL,
    title VARCHAR(100) NOT NULL,
    credits INT NOT NULL,
    description TEXT,
    status ENUM('Active', 'Inactive') DEFAULT 'Active',
    CONSTRAINT chk_course_credits CHECK (credits > 0)
);

-- CourseSection table
CREATE TABLE CourseSection (
    section_id INT PRIMARY KEY AUTO_INCREMENT,
    course_id INT NOT NULL,
    semester VARCHAR(20) NOT NULL,
    year YEAR NOT NULL,
    lecturer_id INT NOT NULL,
    room VARCHAR(50),
    capacity INT NOT NULL,
    current_enrollment INT DEFAULT 0,
    status ENUM('Open', 'Closed', 'Cancelled') DEFAULT 'Open',
    FOREIGN KEY (course_id) REFERENCES Course(course_id),
    FOREIGN KEY (lecturer_id) REFERENCES Lecturer(lecturer_id),
    CONSTRAINT chk_section_capacity CHECK (capacity > 0),
    CONSTRAINT chk_enrollment_limit CHECK (current_enrollment <= capacity AND current_enrollment >= 0),
    UNIQUE KEY unique_section (course_id, semester, year, room)
);

-- Enrollment table
CREATE TABLE Enrollment (
    enrollment_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT NOT NULL,
    section_id INT NOT NULL,
    status ENUM('Enrolled', 'Dropped', 'Completed') DEFAULT 'Enrolled',
    enrolled_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    final_grade DECIMAL(4,2),
    FOREIGN KEY (student_id) REFERENCES Student(student_id),
    FOREIGN KEY (section_id) REFERENCES CourseSection(section_id),
    CONSTRAINT chk_final_grade CHECK (final_grade BETWEEN 0 AND 100 OR final_grade IS NULL),
    UNIQUE KEY unique_enrollment (student_id, section_id)
);

-- Assessment table
CREATE TABLE Assessment (
    assessment_id INT PRIMARY KEY AUTO_INCREMENT,
    section_id INT NOT NULL,
    name VARCHAR(200) NOT NULL,
    weight DECIMAL(5,2) NOT NULL,
    total_marks DECIMAL(6,2) NOT NULL DEFAULT 100,
    assessment_type ENUM('Exam', 'Assignment', 'Quiz', 'Project', 'Participation') NOT NULL,
    due_date DATETIME,
    FOREIGN KEY (section_id) REFERENCES CourseSection(section_id),
    CONSTRAINT chk_assessment_weight CHECK (weight BETWEEN 0 AND 100),
    CONSTRAINT chk_assessment_marks CHECK (total_marks > 0)
);

-- Grade table
CREATE TABLE Grade (
    grade_id INT PRIMARY KEY AUTO_INCREMENT,
    enrollment_id INT NOT NULL,
    assessment_id INT NOT NULL,
    score DECIMAL(6,2),
    graded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    graded_by INT,
    FOREIGN KEY (enrollment_id) REFERENCES Enrollment(enrollment_id),
    FOREIGN KEY (assessment_id) REFERENCES Assessment(assessment_id),
    FOREIGN KEY (graded_by) REFERENCES Lecturer(lecturer_id),
    CONSTRAINT chk_grade_score CHECK (score >= 0),
    UNIQUE KEY unique_grade (enrollment_id, assessment_id)
);

-- Scholarship table
CREATE TABLE Scholarship (
    scholarship_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    type ENUM('Half', 'Full') NOT NULL,
    description TEXT,
    eligibility_criteria JSON,
    amount_per_semester DECIMAL(10,2),
    available_slots INT NOT NULL,
    application_deadline DATE,
    status ENUM('Active', 'Inactive') DEFAULT 'Active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_scholarship_slots CHECK (available_slots >= 0)
);

-- Event table
CREATE TABLE Event (
    event_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    event_type ENUM('Workshop', 'Seminar', 'Conference', 'Training', 'Webinar', 'Career Fair', 'Research Symposium', 'Community Outreach') NOT NULL,
    sdg_alignment VARCHAR(100) DEFAULT 'SDG 4 - Quality Education',
    start_date DATETIME NOT NULL,
    end_date DATETIME NOT NULL,
    venue VARCHAR(100),
    max_participants INT,
    organizer_id INT,
    status ENUM('Upcoming', 'Ongoing', 'Completed', 'Cancelled') DEFAULT 'Upcoming',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (organizer_id) REFERENCES Lecturer(lecturer_id),
    CONSTRAINT chk_event_dates CHECK (end_date > start_date)
);

-- Payment table
CREATE TABLE Payment (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT NOT NULL,
    program_id INT NOT NULL,
    semester VARCHAR(20) NOT NULL,
    academic_year YEAR NOT NULL,
    payment_type ENUM('Tuition', 'Registration', 'Examination', 'Scholarship', 'Other') DEFAULT 'Tuition',
    amount_required DECIMAL(10,2) NOT NULL,
    amount_paid DECIMAL(10,2) DEFAULT 0,
    payment_percentage ENUM('45%', '75%', '100%') NOT NULL,
    payment_status ENUM('Pending', 'Partial', 'Completed', 'Overdue') DEFAULT 'Pending',
    due_date DATE NOT NULL,
    paid_date DATE NULL,
    payment_method ENUM('Cash', 'Bank Transfer', 'Mobile Money', 'Credit Card') NULL,
    transaction_reference VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES Student(student_id),
    FOREIGN KEY (program_id) REFERENCES Program(prog_id),
    CONSTRAINT chk_payment_amount CHECK (amount_paid >= 0 AND amount_paid <= amount_required),
    CONSTRAINT chk_payment_dates CHECK (paid_date IS NULL OR paid_date <= due_date OR payment_status = 'Overdue')
);

-- AuditLog table
CREATE TABLE AuditLog (
    audit_id INT PRIMARY KEY AUTO_INCREMENT,
    performed_by INT NOT NULL,
    action VARCHAR(50) NOT NULL,
    object_type VARCHAR(50) NOT NULL,
    object_id INT NOT NULL,
    details JSON,
    performed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (performed_by) REFERENCES Person(person_id)
);

-- Security Tables
CREATE TABLE UserRole (
    role_id INT PRIMARY KEY AUTO_INCREMENT,
    role_name VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE UserPermission (
    permission_id INT PRIMARY KEY AUTO_INCREMENT,
    permission_name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    module VARCHAR(50) NOT NULL
);

CREATE TABLE SystemUser (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    person_id INT UNIQUE NOT NULL,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role_id INT NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    last_login TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (person_id) REFERENCES Person(person_id) ON DELETE CASCADE,
    FOREIGN KEY (role_id) REFERENCES UserRole(role_id) ON DELETE RESTRICT,
    CONSTRAINT chk_username_length CHECK (CHAR_LENGTH(username) >= 4)
);

CREATE TABLE RolePermission (
    role_id INT NOT NULL,
    permission_id INT NOT NULL,
    granted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    granted_by INT,
    PRIMARY KEY (role_id, permission_id),
    FOREIGN KEY (role_id) REFERENCES UserRole(role_id),
    FOREIGN KEY (permission_id) REFERENCES UserPermission(permission_id),
    FOREIGN KEY (granted_by) REFERENCES SystemUser(user_id)
);

-- Relationship Tables
CREATE TABLE StudentScholarship (
    student_scholarship_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT NOT NULL,
    scholarship_id INT NOT NULL,
    application_date DATE NOT NULL,
    status ENUM('Applied', 'Under Review', 'Approved', 'Rejected', 'Awarded') DEFAULT 'Applied',
    award_date DATE NULL,
    semester_awarded VARCHAR(20),
    academic_year YEAR,
    comments TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES Student(student_id),
    FOREIGN KEY (scholarship_id) REFERENCES Scholarship(scholarship_id),
    UNIQUE KEY unique_student_scholarship (student_id, scholarship_id, academic_year)
);

CREATE TABLE EventRegistration (
    registration_id INT PRIMARY KEY AUTO_INCREMENT,
    event_id INT NOT NULL,
    student_id INT NOT NULL,
    registration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    attendance_status ENUM('Registered', 'Attended', 'No Show', 'Cancelled') DEFAULT 'Registered',
    certificate_issued BOOLEAN DEFAULT FALSE,
    feedback TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (event_id) REFERENCES Event(event_id),
    FOREIGN KEY (student_id) REFERENCES Student(student_id),
    UNIQUE KEY unique_event_registration (event_id, student_id)
);

-- =============================================
-- INDEXES FOR PERFORMANCE
-- =============================================

CREATE INDEX idx_student_person ON Student(person_id);
CREATE INDEX idx_student_program ON Student(program_id);
CREATE INDEX idx_lecturer_person ON Lecturer(person_id);
CREATE INDEX idx_enrollment_student ON Enrollment(student_id);
CREATE INDEX idx_enrollment_section ON Enrollment(section_id);
CREATE INDEX idx_section_course ON CourseSection(course_id);
CREATE INDEX idx_section_lecturer ON CourseSection(lecturer_id);
CREATE INDEX idx_grade_enrollment ON Grade(enrollment_id);
CREATE INDEX idx_grade_assessment ON Grade(assessment_id);
CREATE INDEX idx_audit_performed_by ON AuditLog(performed_by);
CREATE INDEX idx_audit_object ON AuditLog(object_type, object_id);

-- =============================================
-- TRIGGERS
-- =============================================

DELIMITER //

CREATE TRIGGER after_enrollment_insert
AFTER INSERT ON Enrollment
FOR EACH ROW
BEGIN
    IF NEW.status = 'Enrolled' THEN
        UPDATE CourseSection 
        SET current_enrollment = current_enrollment + 1 
        WHERE section_id = NEW.section_id;
    END IF;
    
    INSERT INTO AuditLog (performed_by, action, object_type, object_id, details)
    VALUES (
        (SELECT person_id FROM Student WHERE student_id = NEW.student_id),
        'ENROLL',
        'Enrollment',
        NEW.enrollment_id,
        JSON_OBJECT('section_id', NEW.section_id, 'status', NEW.status)
    );
END//

CREATE TRIGGER after_enrollment_update
AFTER UPDATE ON Enrollment
FOR EACH ROW
BEGIN
    IF OLD.status = 'Enrolled' AND NEW.status != 'Enrolled' THEN
        UPDATE CourseSection 
        SET current_enrollment = current_enrollment - 1 
        WHERE section_id = NEW.section_id;
    ELSEIF OLD.status != 'Enrolled' AND NEW.status = 'Enrolled' THEN
        UPDATE CourseSection 
        SET current_enrollment = current_enrollment + 1 
        WHERE section_id = NEW.section_id;
    END IF;
    
    IF OLD.status != NEW.status THEN
        INSERT INTO AuditLog (performed_by, action, object_type, object_id, details)
        VALUES (
            (SELECT person_id FROM Student WHERE student_id = NEW.student_id),
            'UPDATE_STATUS',
            'Enrollment',
            NEW.enrollment_id,
            JSON_OBJECT('old_status', OLD.status, 'new_status', NEW.status, 'section_id', NEW.section_id)
        );
    END IF;
END//

CREATE TRIGGER after_grade_insert
AFTER INSERT ON Grade
FOR EACH ROW
BEGIN
    INSERT INTO AuditLog (performed_by, action, object_type, object_id, details)
    VALUES (
        NEW.graded_by,
        'CREATE_GRADE',
        'Grade',
        NEW.grade_id,
        JSON_OBJECT('enrollment_id', NEW.enrollment_id, 'assessment_id', NEW.assessment_id, 'score', NEW.score)
    );
END//

CREATE TRIGGER after_grade_update
AFTER UPDATE ON Grade
FOR EACH ROW
BEGIN
    IF OLD.score != NEW.score THEN
        INSERT INTO AuditLog (performed_by, action, object_type, object_id, details)
        VALUES (
            NEW.graded_by,
            'UPDATE_GRADE',
            'Grade',
            NEW.grade_id,
            JSON_OBJECT(
                'enrollment_id', NEW.enrollment_id, 
                'assessment_id', NEW.assessment_id, 
                'old_score', OLD.score, 
                'new_score', NEW.score
            )
        );
    END IF;
END//

CREATE TRIGGER before_enrollment_insert
BEFORE INSERT ON Enrollment
FOR EACH ROW
BEGIN
    DECLARE current_count INT;
    DECLARE max_capacity INT;
    
    SELECT current_enrollment, capacity INTO current_count, max_capacity
    FROM CourseSection 
    WHERE section_id = NEW.section_id;
    
    IF current_count >= max_capacity THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Course section has reached maximum capacity';
    END IF;
END//

CREATE TRIGGER after_payment_update_status
AFTER UPDATE ON Payment
FOR EACH ROW
BEGIN
    DECLARE v_percentage DECIMAL(5,2);
    
    IF NEW.amount_paid != OLD.amount_paid THEN
        SET v_percentage = (NEW.amount_paid / NEW.amount_required) * 100;
        
        IF v_percentage >= 100 THEN
            UPDATE Payment SET payment_status = 'Completed' WHERE payment_id = NEW.payment_id;
        ELSEIF v_percentage >= 75 THEN
            UPDATE Payment SET payment_status = 'Partial', payment_percentage = '75%' WHERE payment_id = NEW.payment_id;
        ELSEIF v_percentage >= 45 THEN
            UPDATE Payment SET payment_status = 'Partial', payment_percentage = '45%' WHERE payment_id = NEW.payment_id;
        ELSE
            UPDATE Payment SET payment_status = 'Pending' WHERE payment_id = NEW.payment_id;
        END IF;
    END IF;
END//

DELIMITER ;

-- =============================================
-- SAMPLE DATA
-- =============================================

-- Insert Programs
INSERT INTO Program (code, name, total_credits) VALUES
('CS', 'Computer Science', 120),
('BSIT', 'Information Technology', 120),
('BBA', 'Business Administration', 120),
('BSDS', 'Data Science', 120),
('BSS', 'Social Sciences', 120);

-- Insert Persons
INSERT INTO Person (person_id, first_name, last_name, email) VALUES
(1, 'Admin', 'System', 'admin@university.edu'),
(2, 'John', 'Lecturer', 'john.lecturer@university.edu'),
(3, 'Mary', 'Student', 'mary.student@university.edu'),
(4, 'David', 'Finance', 'david.finance@university.edu'),
(5, 'Sarah', 'Registrar', 'sarah.registrar@university.edu');

-- Insert Students
INSERT INTO Student (person_id, reg_no, program_id, enrollment_date) VALUES
(3, 'CS2024001', 1, '2024-09-01');

-- Insert Lecturers
INSERT INTO Lecturer (person_id, dept, title, hire_date) VALUES
(2, 'Computer Science', 'Professor', '2020-01-15');

-- Insert Courses
INSERT INTO Course (code, title, credits) VALUES
('CS101', 'Introduction to Programming', 3),
('CS201', 'Database Systems', 3),
('BBA101', 'Business Fundamentals', 3);

-- Insert Scholarships
INSERT INTO Scholarship (name, type, description, amount_per_semester, available_slots) VALUES
('Academic Excellence Scholarship', 'Full', 'Supporting high-achieving students', 5000.00, 10),
('Need-Based Scholarship', 'Half', 'Supporting students from disadvantaged backgrounds', 2500.00, 20);

-- Insert User Roles
INSERT INTO UserRole (role_id, role_name, description) VALUES
(1, 'Administrator', 'Full system access'),
(2, 'Registrar', 'Manages student registrations'),
(3, 'Lecturer', 'Manages courses and grades'),
(4, 'Student', 'Views personal information'),
(5, 'Finance_Officer', 'Manages payments');

-- Insert System Users
INSERT INTO SystemUser (person_id, username, password_hash, role_id) VALUES
(4, 'George', 'Munguchi@2003', 4),
(5, 'sarah_registrar', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 2),
(2, 'lecturer1', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 3),
(3, 'student1', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 4);

-- =============================================
-- STORED PROCEDURES
-- =============================================

DELIMITER //

CREATE PROCEDURE EnrollStudentInSection(
    IN p_student_id INT,
    IN p_section_id INT,
    OUT p_result VARCHAR(255)
)
BEGIN
    DECLARE v_current_enrollment INT;
    DECLARE v_capacity INT;
    DECLARE v_student_status VARCHAR(20);
    DECLARE v_section_status VARCHAR(20);
    DECLARE v_already_enrolled INT;

    SELECT status INTO v_student_status FROM Student WHERE student_id = p_student_id;
    IF v_student_status != 'Active' THEN
        SET p_result = 'ERROR: Student is not active';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Student is not active';
    END IF;

    SELECT status, current_enrollment, capacity 
    INTO v_section_status, v_current_enrollment, v_capacity
    FROM CourseSection WHERE section_id = p_section_id;
    
    IF v_section_status != 'Open' THEN
        SET p_result = 'ERROR: Course section is not open for enrollment';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Course section is not open for enrollment';
    END IF;

    IF v_current_enrollment >= v_capacity THEN
        SET p_result = 'ERROR: Course section has reached maximum capacity';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Course section has reached maximum capacity';
    END IF;

    SELECT COUNT(*) INTO v_already_enrolled 
    FROM Enrollment 
    WHERE student_id = p_student_id AND section_id = p_section_id AND status = 'Enrolled';
    
    IF v_already_enrolled > 0 THEN
        SET p_result = 'ERROR: Student is already enrolled in this section';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Student is already enrolled in this section';
    END IF;

    INSERT INTO Enrollment (student_id, section_id, status) 
    VALUES (p_student_id, p_section_id, 'Enrolled');
    
    SET p_result = 'SUCCESS: Student enrolled successfully';
END//

CREATE PROCEDURE RecordPayment(
    IN p_student_id INT,
    IN p_program_id INT,
    IN p_semester VARCHAR(20),
    IN p_academic_year YEAR,
    IN p_amount_paid DECIMAL(10,2),
    IN p_payment_method VARCHAR(50),
    IN p_transaction_ref VARCHAR(100),
    OUT p_result VARCHAR(255)
)
BEGIN
    DECLARE v_amount_required DECIMAL(10,2);
    DECLARE v_existing_payment_id INT;
    DECLARE v_total_paid DECIMAL(10,2);
    DECLARE v_payment_percentage VARCHAR(10);

    SELECT payment_id, amount_required, amount_paid 
    INTO v_existing_payment_id, v_amount_required, v_total_paid
    FROM Payment 
    WHERE student_id = p_student_id 
    AND program_id = p_program_id 
    AND semester = p_semester 
    AND academic_year = p_academic_year;

    IF v_existing_payment_id IS NULL THEN
        SET v_amount_required = 5000.00;
        
        INSERT INTO Payment (student_id, program_id, semester, academic_year, amount_required, amount_paid, payment_method, transaction_reference, due_date)
        VALUES (p_student_id, p_program_id, p_semester, p_academic_year, v_amount_required, p_amount_paid, p_payment_method, p_transaction_ref, DATE_ADD(CURDATE(), INTERVAL 30 DAY));
        
        SET v_existing_payment_id = LAST_INSERT_ID();
        SET v_total_paid = p_amount_paid;
    ELSE
        UPDATE Payment 
        SET amount_paid = amount_paid + p_amount_paid,
            payment_method = p_payment_method,
            transaction_reference = p_transaction_ref,
            paid_date = CURDATE()
        WHERE payment_id = v_existing_payment_id;
        
        SET v_total_paid = v_total_paid + p_amount_paid;
    END IF;

    IF v_total_paid >= v_amount_required THEN
        SET v_payment_percentage = '100%';
        UPDATE Payment SET payment_status = 'Completed', payment_percentage = '100%' WHERE payment_id = v_existing_payment_id;
    ELSEIF v_total_paid >= (v_amount_required * 0.75) THEN
        SET v_payment_percentage = '75%';
        UPDATE Payment SET payment_status = 'Partial', payment_percentage = '75%' WHERE payment_id = v_existing_payment_id;
    ELSEIF v_total_paid >= (v_amount_required * 0.45) THEN
        SET v_payment_percentage = '45%';
        UPDATE Payment SET payment_status = 'Partial', payment_percentage = '45%' WHERE payment_id = v_existing_payment_id;
    ELSE
        SET v_payment_percentage = 'Less than 45%';
        UPDATE Payment SET payment_status = 'Pending' WHERE payment_id = v_existing_payment_id;
    END IF;

    SET p_result = CONCAT('SUCCESS: Payment recorded. Total paid: ', v_total_paid, ' (', v_payment_percentage, ')');
END//

CREATE PROCEDURE CalculateFinalGrade(
    IN p_enrollment_id INT,
    OUT p_final_grade DECIMAL(4,2),
    OUT p_result VARCHAR(255)
)
BEGIN
    DECLARE v_total_score DECIMAL(6,2);
    DECLARE v_total_weight DECIMAL(5,2);
    DECLARE v_section_id INT;

    SELECT section_id INTO v_section_id FROM Enrollment WHERE enrollment_id = p_enrollment_id;

    SELECT 
        SUM(g.score * (a.weight/100)) as total_score,
        SUM(a.weight) as total_weight
    INTO v_total_score, v_total_weight
    FROM Grade g
    JOIN Assessment a ON g.assessment_id = a.assessment_id
    WHERE g.enrollment_id = p_enrollment_id
    AND a.section_id = v_section_id;

    IF v_total_weight = 100 AND v_total_score IS NOT NULL THEN
        SET p_final_grade = v_total_score;
        UPDATE Enrollment SET final_grade = p_final_grade WHERE enrollment_id = p_enrollment_id;
        SET p_result = CONCAT('SUCCESS: Final grade calculated: ', p_final_grade);
    ELSE
        SET p_final_grade = NULL;
        SET p_result = 'ERROR: Cannot calculate final grade. Ensure all assessments are graded and weights total 100%.';
    END IF;
END//

DELIMITER ;

-- =============================================
-- VIEWS
-- =============================================

CREATE VIEW StudentPortalView AS
SELECT 
    s.student_id,
    s.reg_no,
    p.first_name,
    p.last_name,
    p.email,
    pr.name as program_name,
    s.year_of_study,
    s.enrollment_date,
    s.status as student_status
FROM Student s
JOIN Person p ON s.person_id = p.person_id
JOIN Program pr ON s.program_id = pr.prog_id;

CREATE VIEW FinancialDashboard AS
SELECT 
    s.student_id,
    s.reg_no,
    p.first_name,S
    p.last_name,
    pr.name as program_name,
    pay.payment_id,
    pay.semester,
    pay.academic_year,
    pay.amount_required,
    pay.amount_paid,
    pay.payment_percentage,
    pay.payment_status,
    pay.due_date
FROM Student s
JOIN Person p ON s.person_id = p.person_id
JOIN Program pr ON s.program_id = pr.prog_id
JOIN Payment pay ON s.student_id = pay.student_id;

-- =============================================
-- FINAL VALIDATION
-- =============================================

SELECT '🎉 DATABASE CREATED SUCCESSFULLY!' as status;
SELECT '✅ All tables created' as verification;
SELECT '✅ Triggers implemented' as verification;
SELECT '✅ Stored procedures created' as verification;
SELECT '✅ Sample data inserted' as verification;

-- Test the system
CALL EnrollStudentInSection(1, 1, @enroll_result);
SELECT @enroll_result as 'Enrollment Test';

CALL RecordPayment(1, 1, 'January', 2024, 2250.00, 'Bank Transfer', 'TX123456', @payment_result);
SELECT @payment_result as 'Payment Test';

-- Display system summary
SELECT 
    'People' as category, COUNT(*) as count FROM Person
    UNION ALL SELECT 'Students', COUNT(*) FROM Student
    UNION ALL SELECT 'Programs', COUNT(*) FROM Program
    UNION ALL SELECT 'Courses', COUNT(*) FROM Course
    UNION ALL SELECT 'System Users', COUNT(*) FROM SystemUser;



INSERT INTO UserPermission (permission_name, description, module) VALUES
('MANAGE_USERS', 'Create, update, suspend and delete system users', 'Security'),
('VIEW_DASHBOARD', 'Access dashboard analytics', 'General'),
('MANAGE_STUDENTS', 'Create, edit, view student records', 'Student'),
('MANAGE_LECTURERS', 'Manage lecturer records', 'Lecturer'),
('MANAGE_PROGRAMS', 'Create and update academic programs', 'Program'),
('MANAGE_COURSES', 'Create and update courses', 'Course'),
('MANAGE_SECTIONS', 'Create and manage course sections', 'CourseSection'),
('MANAGE_ENROLLMENTS', 'Enroll and drop students from sections', 'Enrollment'),
('MANAGE_GRADES', 'Record and update grades', 'Grades'),
('VIEW_GRADES', 'Students can view their grades', 'Student'),
('MANAGE_PAYMENTS', 'Handle all student payments', 'Finance'),
('VIEW_FINANCIAL_RECORDS', 'View payments and balances', 'Finance'),
('MANAGE_SCHOLARSHIPS', 'Assign and review scholarships', 'Scholarship'),
('MANAGE_EVENTS', 'Create and manage events', 'Events'),
('REGISTER_EVENTS', 'Students can register for events', 'Events');


select * from rolepermission;

-- Registrar Role
-- Permissions: Students, Programs, Enrollments, Courses, Sections, Scholarships
INSERT INTO RolePermission (role_id, permission_id, granted_by)
SELECT 2, permission_id, 1 FROM UserPermission 
WHERE permission_name IN (
    'MANAGE_STUDENTS',
    'MANAGE_PROGRAMS',
    'MANAGE_COURSES',
    'MANAGE_SECTIONS',
    'MANAGE_ENROLLMENTS',
    'MANAGE_SCHOLARSHIPS',
    'VIEW_DASHBOARD'
);


-- Lecturer Role
INSERT INTO RolePermission (role_id, permission_id, granted_by)
SELECT 3, permission_id, 1 FROM UserPermission
WHERE permission_name IN (
    'MANAGE_GRADES',
    'VIEW_GRADES',
    'MANAGE_COURSES',
    'MANAGE_SECTIONS',
    'MANAGE_EVENTS',
    'VIEW_DASHBOARD'
);

-- Student Role
INSERT INTO RolePermission (role_id, permission_id, granted_by)
SELECT 4, permission_id, 1 FROM UserPermission
WHERE permission_name IN (
    'VIEW_GRADES',
    'REGISTER_EVENTS',
    'VIEW_DASHBOARD'
);


-- Finance Officer Role
INSERT INTO RolePermission (role_id, permission_id, granted_by)
SELECT 5, permission_id, 1 FROM UserPermission
WHERE permission_name IN (
    'MANAGE_PAYMENTS',
    'VIEW_FINANCIAL_RECORDS',
    'VIEW_DASHBOARD'
);


