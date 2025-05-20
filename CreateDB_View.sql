USE University
GO

-- ������� select-�������, ���������� �� sql-������� � ���� �������������

-- 1. ��������� ������ �������������� � �� ������������� � ����������
CREATE VIEW AllProfessors AS
SELECT 
    ProfessorID,
    LastName + ' ' + FirstName + ' ' + ISNULL(MiddleName, '') AS FullName,
    AcademicDegree,
    AcademicTitle,
    TeachingExperience,
    Phone,
    Email
FROM Professors;
GO

-- ������ �������������
SELECT * FROM AllProfessors;

USE University
GO

-- 2. ��������� ������ ���� ����������� � ��������
CREATE VIEW AllFaculties AS
SELECT 
    FacultyID,
    FacultyName,
    DeanName,
    Phone AS FacultyPhone,
    Email AS FacultyEmail
FROM Faculties;
GO

-- ������ �������������
SELECT * FROM AllFaculties;

USE University
GO

-- 3. ��������� ������ ���� ������������� ������������
CREATE VIEW AllUnits AS
SELECT 
    UnitID,
    UnitName,
    Address,
    Phone AS UnitPhone,
    Email AS UnitEmail
FROM Units;
GO

-- ������ �������������
SELECT * FROM AllUnits;

USE University
GO

-- 4. ��������� ���������� �� ������������
CREATE VIEW UniversityInfo AS
SELECT InstitutionID, Name, Address, RectorName, FoundationYear, Phone, Email 
FROM HigherEducationInstitution;
GO

-- ������ �������������
SELECT * FROM UniversityInfo;

USE University
GO

-- 5. ����������� ��������� ����� ��������� � �� �������
CREATE VIEW ScholarshipTypes AS
SELECT ScholarshipID, ScholarshipType, MinAverageScore, MaxAverageScore, ScholarshipAmount 
FROM Scholarships;
GO

-- ������ �������������
SELECT * FROM ScholarshipTypes;


/*
������������� select-������� (� ����������� �������� ���������� ������ ���� ������ (INNER JOIN/ LEFT JOIN/ � ��.), 
���������� �� sql-������� � ���� �������������
*/

USE University
GO

-- 1. ��������� ������� ������������ ��������� �� �����������
CREATE VIEW StudentPerformance AS
SELECT 
    S.StudentID,
    S.LastName + ' ' + S.FirstName + ' ' + ISNULL(S.MiddleName, '') AS FullName,
    G.GroupName,
    F.FacultyName,
    Sub.SubjectName,
    AVG(GR.Grade) AS AverageGrade,
    CASE 
        WHEN AVG(GR.Grade) >= 9.0 THEN N'�������'
        WHEN AVG(GR.Grade) >= 7.0 THEN N'������'
        WHEN AVG(GR.Grade) >= 4.0 THEN N'�����������������'
        ELSE N'�������������������'
    END AS PerformanceStatus
FROM Students S
INNER JOIN Groups G ON S.GroupID = G.GroupID
INNER JOIN Faculties F ON G.FacultyID = F.FacultyID
INNER JOIN Grades GR ON S.StudentID = GR.StudentID
INNER JOIN Subjects Sub ON GR.SubjectID = Sub.SubjectID
GROUP BY 
    S.StudentID, 
    S.LastName, 
    S.FirstName, 
    S.MiddleName, 
    G.GroupName, 
    F.FacultyName, 
    Sub.SubjectName;
GO

-- ������ �������������
SELECT * FROM StudentPerformance;

USE University
GO

-- 2. ��������� ���������� �� ��������� � ��������
CREATE VIEW ExamDetails AS
SELECT 
    E.ExamID,
    G.GroupName,
    Sub.SubjectName,
    P.LastName + ' ' + P.FirstName AS ProfessorName,
    E.ExamDate,
    E.StartTime,
    E.EndTime,
    E.Room
FROM Exams E
INNER JOIN Groups G ON E.GroupID = G.GroupID
INNER JOIN Subjects Sub ON E.SubjectID = Sub.SubjectID
INNER JOIN Professors P ON E.ProfessorID = P.ProfessorID;
GO

-- ������ �������������
SELECT * FROM ExamDetails;

USE University
GO

-- 3. ��������� ���������� � ��������� � ������������ �����������
CREATE VIEW StudentScholarshipInfo AS
SELECT 
    S.StudentID,
    S.LastName + ' ' + S.FirstName AS StudentName,
    Sc.ScholarshipType,
    SS.StartDate,
    SS.EndDate,
    Sc.ScholarshipAmount
FROM StudentScholarships SS
INNER JOIN Students S ON SS.StudentID = S.StudentID
INNER JOIN Scholarships Sc ON SS.ScholarshipID = Sc.ScholarshipID;
GO

-- ������ �������������
SELECT * FROM StudentScholarshipInfo;

USE University
GO

-- 4. ��������� ���������� �� �������������� � ����������
CREATE VIEW UnitsContact AS
SELECT 
    U.UnitID,
    U.UnitName,
    A.Name AS AdministrationName,
    U.Address,
    U.Phone AS UnitPhone,
    U.Email AS UnitEmail
FROM Units U
INNER JOIN Administration A ON U.AdministrationID = A.AdministrationID;
GO

-- ������ �������������
SELECT * FROM UnitsContact;