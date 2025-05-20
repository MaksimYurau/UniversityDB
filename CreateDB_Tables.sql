CREATE DATABASE University
ON PRIMARY 
(NAME = University,
	FILENAME = 'D:\МИТСО\Курсовые работы\3 курс\Системы баз данных\Курсовой проект\UniversityDB\University.mdf',
	SIZE = 5120KB,
	MAXSIZE = UNLIMITED,
	FILEGROWTH = 1024KB)
LOG ON
(NAME = University_log,
	FILENAME = 'D:\МИТСО\Курсовые работы\3 курс\Системы баз данных\Курсовой проект\UniversityDB\University.ldf',
	SIZE = 2048KB,
	MAXSIZE = 2048GB,
	FILEGROWTH = 10%)
GO

USE University
GO

CREATE TABLE HigherEducationInstitution (
    InstitutionID INT PRIMARY KEY,
    Name NVARCHAR(255) NOT NULL UNIQUE,
    Address NVARCHAR(500),
    RectorName NVARCHAR(150) NOT NULL,
    FoundationYear SMALLINT NOT NULL CHECK (FoundationYear BETWEEN 1801 AND YEAR(GETDATE())),
    Phone VARCHAR(20) CHECK (Phone LIKE '+375 [0-9][0-9] [0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]'),
    Email NVARCHAR(100) CHECK (Email LIKE '%_@%_.%_')
)
GO

CREATE TABLE Administration (
    AdministrationID INT PRIMARY KEY,
    Name NVARCHAR(255) NOT NULL,
    InstitutionID INT NOT NULL FOREIGN KEY REFERENCES HigherEducationInstitution(InstitutionID),
    HeadName NVARCHAR(150) NOT NULL,
    Phone VARCHAR(20) CHECK (Phone LIKE '+375 [0-9][0-9] [0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]'),
    Email NVARCHAR(100) CHECK (Email LIKE '%_@%_.%_')
)
GO

CREATE TABLE Faculties (
    FacultyID INT PRIMARY KEY,
    FacultyName NVARCHAR(150) NOT NULL UNIQUE,
    DeanName NVARCHAR(150) NOT NULL,
    AdministrationID INT NOT NULL FOREIGN KEY REFERENCES Administration(AdministrationID),
    Phone VARCHAR(20) CHECK (Phone LIKE '+375 [0-9][0-9] [0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]'),
    Email NVARCHAR(100) CHECK (Email LIKE '%_@%_.%_')
)
GO

CREATE TABLE Departments (
    DepartmentID INT PRIMARY KEY,
    DepartmentName NVARCHAR(150) NOT NULL UNIQUE,
    HeadOfDepartment NVARCHAR(150) NOT NULL,
    FacultyID INT NOT NULL FOREIGN KEY REFERENCES Faculties(FacultyID),
    Phone VARCHAR(20) CHECK (Phone LIKE '+375 [0-9][0-9] [0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]'),
    Email NVARCHAR(100) CHECK (Email LIKE '%_@%_.%_')
)
GO

CREATE TABLE Groups (
    GroupID INT PRIMARY KEY,
    GroupName NVARCHAR(50) NOT NULL UNIQUE,
    EducationForm NVARCHAR(20) NOT NULL CHECK (EducationForm IN (N'Очная', N'Заочная', N'Вечерняя')),
    Coefficient DECIMAL(5,2) NOT NULL CHECK (Coefficient BETWEEN 0.1 AND 10.0),
    FacultyID INT NOT NULL FOREIGN KEY REFERENCES Faculties(FacultyID),
    Speciality NVARCHAR(150) NOT NULL,
    EducationLevel NVARCHAR(50) NOT NULL CHECK (EducationLevel IN (N'Бакалавриат', N'Магистратура', N'Аспирантура'))
)
GO

CREATE TABLE Students (
    StudentID INT PRIMARY KEY,
    LastName NVARCHAR(50) NOT NULL,
    FirstName NVARCHAR(50) NOT NULL,
    MiddleName NVARCHAR(50),
    GroupID INT NOT NULL FOREIGN KEY REFERENCES Groups(GroupID),
    IsBudget BIT NOT NULL DEFAULT 1,
    HasDormitory BIT NOT NULL DEFAULT 0,
    BirthDate DATE NOT NULL CHECK (BirthDate BETWEEN '1900-01-01' AND GETDATE()),
    MaritalStatus NVARCHAR(20) CHECK (MaritalStatus IN (N'Холост', N'Замужем', N'Женат', N'Разведён')),
    Phone VARCHAR(20) CHECK (Phone LIKE '+375 [0-9][0-9] [0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]'),
    Email NVARCHAR(100) CHECK (Email LIKE '%_@%_.%_')
)
GO

CREATE TABLE Professors (
    ProfessorID INT PRIMARY KEY,
    LastName NVARCHAR(50) NOT NULL,
    FirstName NVARCHAR(50) NOT NULL,
    MiddleName NVARCHAR(50),
    TeachingExperience TINYINT NOT NULL CHECK (TeachingExperience BETWEEN 0 AND 60),
    DepartmentID INT NOT NULL FOREIGN KEY REFERENCES Departments(DepartmentID),
    AcademicDegree NVARCHAR(50) CHECK (AcademicDegree IN (N'Кандидат наук', N'Доктор наук')),
    AcademicTitle NVARCHAR(50) CHECK (AcademicTitle IN (N'Доцент', N'Профессор')),
    Phone VARCHAR(20) CHECK (Phone LIKE '+375 [0-9][0-9] [0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]'),
    Email NVARCHAR(100) CHECK (Email LIKE '%_@%_.%_')
)
GO

CREATE TABLE Units (
    UnitID INT PRIMARY KEY,
    UnitName NVARCHAR(255) NOT NULL UNIQUE,
    AdministrationID INT NOT NULL FOREIGN KEY REFERENCES Administration(AdministrationID),
    Address NVARCHAR(500),
    Phone VARCHAR(20) CHECK (Phone LIKE '+375 [0-9][0-9] [0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]'),
    Email NVARCHAR(100) CHECK (Email LIKE '%_@%_.%_')
)
GO

CREATE TABLE Subjects (
    SubjectID INT PRIMARY KEY,
    SubjectName NVARCHAR(150) NOT NULL UNIQUE,
    Hours SMALLINT NOT NULL CHECK (Hours > 0),
    DepartmentID INT NOT NULL FOREIGN KEY REFERENCES Departments(DepartmentID)
)
GO

CREATE TABLE Exams (
    ExamID INT PRIMARY KEY,
    GroupID INT NOT NULL FOREIGN KEY REFERENCES Groups(GroupID),
    SubjectID INT NOT NULL FOREIGN KEY REFERENCES Subjects(SubjectID),
    ProfessorID INT NOT NULL FOREIGN KEY REFERENCES Professors(ProfessorID),
    ExamDate DATE NOT NULL,
    StartTime TIME(0) NOT NULL,
    EndTime TIME(0) NOT NULL,
    Room NVARCHAR(20) NOT NULL,
    CONSTRAINT CHK_Exams_Time CHECK (EndTime > StartTime)
)
GO

CREATE TABLE Grades (
    GradeID INT PRIMARY KEY,
    StudentID INT NOT NULL FOREIGN KEY REFERENCES Students(StudentID),
    SubjectID INT NOT NULL FOREIGN KEY REFERENCES Subjects(SubjectID),
    Grade TINYINT NOT NULL CHECK (Grade BETWEEN 0 AND 10),
    GradeDate DATE NOT NULL DEFAULT GETDATE(),
    CONSTRAINT UQ_Grades_StudentSubject UNIQUE (StudentID, SubjectID)
)
GO

CREATE TABLE Scholarships (
    ScholarshipID INT PRIMARY KEY,
    ScholarshipType NVARCHAR(50) NOT NULL CHECK (ScholarshipType IN (N'Академическая', N'Социальная', N'Повышенная')),
    MinAverageScore DECIMAL(3,1) NOT NULL CHECK (MinAverageScore BETWEEN 0 AND 10),
    MaxAverageScore DECIMAL(3,1),
    ScholarshipAmount DECIMAL(10,2) NOT NULL CHECK (ScholarshipAmount > 0),
    CONSTRAINT CHK_Scholarships_MaxMin CHECK (MaxAverageScore >= MinAverageScore AND MaxAverageScore <= 10)
)
GO

CREATE TABLE StudentScholarships (
    StudentScholarshipID INT PRIMARY KEY,
    StudentID INT NOT NULL FOREIGN KEY REFERENCES Students(StudentID),
    ScholarshipID INT NOT NULL FOREIGN KEY REFERENCES Scholarships(ScholarshipID),
    StartDate DATE NOT NULL DEFAULT GETDATE(),
    EndDate DATE,
    CONSTRAINT UQ_StudentScholarship UNIQUE (StudentID, ScholarshipID),
    CONSTRAINT CHK_StudentScholarships_EndDate CHECK (EndDate > StartDate OR EndDate IS NULL)
)
GO

CREATE UNIQUE INDEX UIX_Faculties_FacultyName ON Faculties(FacultyName);
CREATE UNIQUE INDEX UIX_Departments_DepartmentName ON Departments(DepartmentName);
CREATE UNIQUE INDEX UIX_Groups_GroupName ON Groups(GroupName);
CREATE UNIQUE INDEX UIX_Students_FullName ON Students(LastName, FirstName, MiddleName);
CREATE UNIQUE INDEX UIX_Professors_FullName ON Professors(LastName, FirstName, MiddleName);
CREATE UNIQUE INDEX UIX_Units_UnitName ON Units(UnitName);
CREATE UNIQUE INDEX UIX_Subjects_SubjectName ON Subjects(SubjectName);
CREATE UNIQUE INDEX UIX_Exams_UniqueEntry ON Exams(GroupID, SubjectID, ExamDate);
GO

CREATE INDEX IX_Administration_InstitutionID ON Administration(InstitutionID);
CREATE INDEX IX_Faculties_AdministrationID ON Faculties(AdministrationID);
CREATE INDEX IX_Departments_FacultyID ON Departments(FacultyID);
CREATE INDEX IX_Groups_FacultyID ON Groups(FacultyID);
CREATE INDEX IX_Students_GroupID ON Students(GroupID);
CREATE INDEX IX_Students_BirthDate ON Students(BirthDate);
CREATE INDEX IX_Professors_DepartmentID ON Professors(DepartmentID);
CREATE INDEX IX_Subjects_DepartmentID ON Subjects(DepartmentID);
CREATE INDEX IX_Exams_ProfessorID ON Exams(ProfessorID);
CREATE INDEX IX_Grades_GradeDate ON Grades(GradeDate);
CREATE INDEX IX_StudentScholarships_StartDate ON StudentScholarships(StartDate);
GO