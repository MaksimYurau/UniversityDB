USE University
GO


-- ������� 1. ������� ������ �� ������ � �������������. �������� SELECT

-- 1. ������� ���� �������� � ����� �� ������� Students
SELECT * 
FROM Students

-- 2. ������� ��������� �������� (������������ ������) �� ������� Faculties
SELECT FacultyName, DeanName, Phone 
FROM Faculties

-- 3. ������� ����� � �������� (�������������� ������) �� ������� Professors
SELECT * 
FROM Professors 
WHERE AcademicDegree = N'������ ����'

-- 4. ��������������� ������ (������� + ������) �� ������� Groups
SELECT GroupName, EducationForm, Speciality 
FROM Groups 
WHERE EducationLevel = N'�����������' AND Coefficient = 1.0

-- 5. ���������� ������ �� ������� Students
SELECT LastName, FirstName, BirthDate 
FROM Students 
ORDER BY LastName ASC, FirstName ASC

-- 6. ���������� ������ Students, Groups � Faculties
SELECT 
    S.LastName AS �������,
    G.GroupName AS ������,
    F.FacultyName AS ���������
FROM Students S
INNER JOIN Groups G ON S.GroupID = G.GroupID
INNER JOIN Faculties F ON G.FacultyID = F.FacultyID
ORDER BY F.FacultyName

-- 7. ������� ������ �� ���� ������ (Students, Grades, Subjects)
SELECT 
    S.LastName AS �������,
    Sub.SubjectName AS �������,
    GR.Grade AS ������
FROM Students S
INNER JOIN Grades GR ON S.StudentID = GR.StudentID
INNER JOIN Subjects Sub ON GR.SubjectID = Sub.SubjectID
WHERE GR.Grade >= 8

-- 8. ����������� ������� (������� ��������)
SELECT 
    LastName,
    FirstName,
    DATEDIFF(YEAR, BirthDate, GETDATE()) AS �������
FROM Students

-- 9. ���������� ������� ��� ������� Grades
SELECT 
    AVG(Grade) AS �������_����,
    MAX(Grade) AS ��������,
    MIN(Grade) AS �������
FROM Grades

-- 10. ����������� ������ �� �����������
SELECT 
    F.FacultyName AS ���������,
    COUNT(S.StudentID) AS ����������_���������
FROM Students S
INNER JOIN Groups G ON S.GroupID = G.GroupID
INNER JOIN Faculties F ON G.FacultyID = F.FacultyID
GROUP BY F.FacultyName

-- 11. ����������� � �������� HAVING
SELECT 
    Sub.SubjectName AS �������,
    AVG(GR.Grade) AS �������_����
FROM Grades GR
INNER JOIN Subjects Sub ON GR.SubjectID = Sub.SubjectID
GROUP BY Sub.SubjectName
HAVING AVG(GR.Grade) > 7.5

-- 12. ������� ������ �� ������������� StudentPerformance
SELECT FullName, GroupName, AverageGrade 
FROM StudentPerformance 
WHERE AverageGrade >= 8 
  AND AverageGrade IS NOT NULL

-- 13. �������� ����� ������� ����� SELECT INTO
SELECT * INTO Students_Backup 
FROM Students;
SELECT * INTO Grades_Backup 
FROM Grades 
WHERE Grade >= 8


-- ������� 2. ������� ��������� ������

-- 1. ������ ������� �������, ������� �������� ������ � �������
/*USE master -- ������������� �� ��������� ���� ������ master
SELECT name, dbname, password, language FROM syslogins
USE University

-- 2. ������ ������� �������, ���������� � ������������� ���� �������
EXEC sp_helpsrvrolemember

-- 3. ������ ������������� ���� ������ University
EXEC sp_helpuser

-- 4. ������ ����� (��� �������������, ��� � ����������������) ���� ������ University
EXEC sp_helprole

-- 5. �������� ����� � ������������� � ����� ���� ������ University
EXEC sp_helprolemember
*/


-- ������� 3. ���������� ������ � �������� � ��������������

-- 1. ���������� ����������� �������� �������� � StudentID = 1.
/* UPDATE Students
SET Phone = '+375 29 765-43-21'
WHERE StudentID = 1
SELECT * FROM Students

-- 2. ���������� �������� ���������� � SubjectID = 1 �� "������� ��� ������".
UPDATE Subjects
SET SubjectName = N'������� ��� ������'
WHERE SubjectID = 1
SELECT * FROM Subjects

-- 3. ������� ���� ��������� � ������ � GroupID = 11 
UPDATE Students
SET GroupID = 11
WHERE GroupID <> 11
SELECT * FROM Students
*/

-- ������� 4. �������� ������ �� ������ � �������������

-- 1. �������� ���� ������, ������������ �� 2023-12-21
/* DELETE FROM Grades
WHERE GradeDate < '2023-12-21'
SELECT * FROM Grades
*/

-- ������� 5. ��������� ��������� �������.

-- 1. ����������� ���� �������� ��������� ���������� �� 1950 ���� �� �������� ����
/* ALTER TABLE Students
ADD CONSTRAINT CHK_Students_BirthDate 
CHECK (BirthDate BETWEEN '1950-01-01' AND GETDATE());
EXEC sp_help 'Students'
*/

-- ������� 6. �������� ������ �� ���� ������.

-- 1. �������� ��������� ������ 
/* DROP TABLE IF EXISTS Students_Backup
DROP TABLE IF EXISTS Grades_Backup
SELECT * FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_NAME IN ('Students_Backup', 'Grades_Backup')
*/

-- ������� ��� ���������������� ����������.

-- ������� 7. �������� ����� ������.

-- 1. �������� ������� Attendance (������������ �������)
CREATE TABLE Attendance (
    AttendanceID INT PRIMARY KEY IDENTITY(1,1),
    StudentID INT NOT NULL FOREIGN KEY REFERENCES Students(StudentID),
    SubjectID INT NOT NULL FOREIGN KEY REFERENCES Subjects(SubjectID),
    AttendanceDate DATE NOT NULL DEFAULT GETDATE(),
    IsPresent BIT NOT NULL DEFAULT 1, -- 1: �������������, 0: ������������
    CONSTRAINT CHK_Attendance_Date CHECK (AttendanceDate <= GETDATE())
)
GO

-- 2. �������� ������� ClassSchedule (���������� �������)
CREATE TABLE ClassSchedule (
    ScheduleID INT PRIMARY KEY IDENTITY(1,1),
    GroupID INT NOT NULL FOREIGN KEY REFERENCES Groups(GroupID),
    SubjectID INT NOT NULL FOREIGN KEY REFERENCES Subjects(SubjectID),
    ProfessorID INT NOT NULL FOREIGN KEY REFERENCES Professors(ProfessorID),
    ClassDate DATE NOT NULL,
    StartTime TIME(0) NOT NULL,
    EndTime TIME(0) NOT NULL,
    Room NVARCHAR(20) NOT NULL,
    CONSTRAINT CHK_Schedule_Time CHECK (EndTime > StartTime)
)
GO

-- 3. ��������� �������� ��� �����������
-- ������ ��� ������ �� ���� ������������
CREATE NONCLUSTERED INDEX IX_Attendance_Date 
ON Attendance(AttendanceDate)

-- ������ ��� ���������� �� ������ � ��������
CREATE NONCLUSTERED INDEX IX_ClassSchedule_GroupSubject 
ON ClassSchedule(GroupID, SubjectID)

-- 4. ���������� ������ � ����� �������
-- ���������� ������ � Attendance
INSERT INTO Attendance (StudentID, SubjectID, IsPresent)
VALUES 
(1, 1, 1),
(2, 1, 0),
(3, 2, 1);

-- ���������� ������ � ClassSchedule
INSERT INTO ClassSchedule (GroupID, SubjectID, ProfessorID, ClassDate, StartTime, EndTime, Room)
VALUES 
(1, 1, 1, '2023-10-10', '09:00', '11:00', N'���. 301'),
(2, 2, 2, '2023-10-11', '14:00', '16:00', N'���. 205');


-- ������� 8. ����������� �������� � �������

-- 1. ������� ������ ��������� � �� ������� ������, ��������������� �� �������� �������� �����
SELECT 
    S.StudentID,
    S.LastName + ' ' + S.FirstName AS FullName,
    AVG(GR.Grade) AS AverageGrade
FROM Students S
INNER JOIN Grades GR ON S.StudentID = GR.StudentID
GROUP BY S.StudentID, S.LastName, S.FirstName
ORDER BY AverageGrade DESC

-- 2. ����� ����������, ��� ������� ���� ��������� ���� 7.5
SELECT 
    F.FacultyName,
    AVG(GR.Grade) AS FacultyAverage
FROM Faculties F
INNER JOIN Groups G ON F.FacultyID = G.FacultyID
INNER JOIN Students S ON G.GroupID = S.GroupID
INNER JOIN Grades GR ON S.StudentID = GR.StudentID
GROUP BY F.FacultyName
HAVING AVG(GR.Grade) > 7.5

-- 3. ������� ���������, ������� �� ����� �� ����� ������
DELETE FROM Students
WHERE StudentID NOT IN (SELECT DISTINCT StudentID FROM Grades)
SELECT * FROM Students

-- 4. ������� ������ ��� ��������� ������ �� ������� ��������
CREATE NONCLUSTERED INDEX IX_Students_LastName
ON Students(LastName)
EXEC sp_helpindex 'Students'


-- ������� 9. ���������� ������ � ��������

-- 1. ���������� ����������� �������� �������� � StudentID = 1.
UPDATE Students
SET Phone = '+375 29 765-43-21'
WHERE StudentID = 1
SELECT * FROM Students

-- 2. ���������� �������� ���������� � SubjectID = 1 �� "������� ��� ������".
UPDATE Subjects
SET SubjectName = N'������� ��� ������'
WHERE SubjectID = 1
SELECT * FROM Subjects

-- 3. ������� ���� ��������� � ������ � GroupID = 11 
UPDATE Students
SET GroupID = 11
WHERE GroupID <> 11
SELECT * FROM Students


-- ������� 10. ���������� ������ � ��������

-- 1. ������� ���������, ��������������� �� 23 ������� 2023 ����, �� 24 ������� 2023 ����
UPDATE Exams
SET ExamDate = '2023-12-24'
WHERE ExamDate = '2023-12-23'
SELECT * FROM Exams WHERE ExamDate = '2023-12-24'


-- ������� 11. ��������� ��������� ������ � �������������

-- 1. ���������� ������ ������� IsActive � ������� Students
ALTER TABLE Students
ADD IsActive BIT NOT NULL DEFAULT 1; -- 1: �������, 0: ���������

-- 2. ��������� ������������� StudentPerformance
USE University
GO

CREATE OR ALTER VIEW StudentPerformance AS
SELECT 
    S.StudentID,
    S.LastName + ' ' + S.FirstName AS FullName,
    G.GroupName,
    F.FacultyName,
    Sub.SubjectName,
    AVG(GR.Grade) AS AverageGrade,
    CASE 
        WHEN AVG(GR.Grade) >= 9.0 THEN N'�������'
        WHEN AVG(GR.Grade) >= 7.0 THEN N'������'
        ELSE N'������� ��������'
    END AS PerformanceStatus
FROM Students S
INNER JOIN Groups G ON S.GroupID = G.GroupID
INNER JOIN Faculties F ON G.FacultyID = F.FacultyID
INNER JOIN Grades GR ON S.StudentID = GR.StudentID
INNER JOIN Subjects Sub ON GR.SubjectID = Sub.SubjectID
WHERE S.IsActive = 1 -- ������ �������� ��������
GROUP BY 
    S.StudentID, 
    S.LastName, 
    S.FirstName, 
    G.GroupName, 
    F.FacultyName, 
    Sub.SubjectName;
GO

-- 3. ������ ������������� email-������� ��� ��������������
CREATE UNIQUE INDEX UQ_Professors_Email 
ON Professors(Email)
WHERE Email IS NOT NULL; -- ��������� ��������� NULL, �� ��������� ���������


-- ������� 12. �������� ������ �� ���� ������

-- 1. �������� ��������� ������ 
DROP TABLE IF EXISTS Students_Backup
DROP TABLE IF EXISTS Grades_Backup
SELECT * FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_NAME IN ('Students_Backup', 'Grades_Backup')
