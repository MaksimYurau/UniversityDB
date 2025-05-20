USE University;
GO


-- ������� 1. ������ � ����������� � ����� Transact-SQL.

-- 1. ���������� ���������� � ���������� �������� �� �������
DECLARE 
    @MaxStudentID INT,
    @StudentName NVARCHAR(150),
    @BirthDate DATE;

-- ������� ������� ������������ StudentID
SELECT @MaxStudentID = MAX(StudentID) FROM Students;

-- ����� �������� ������ �� ����� ID
SELECT 
    @StudentName = CONCAT(LastName, ' ', FirstName, ' ', MiddleName),
    @BirthDate = BirthDate
FROM Students
WHERE StudentID = @MaxStudentID;

-- ������� ���������
SELECT 
    @MaxStudentID AS [ID ��������],
    @StudentName AS [���],
    @BirthDate AS [���� ��������];


-- ������� 2: ������ � ���������� ��������� � ����� Transact-SQL.

-- 1. �������� ��������� ������� ��� �������� ������� ������
CREATE TABLE #AverageGrades (
    SubjectName NVARCHAR(150),
    AvgGrade DECIMAL(5,2)
);

INSERT INTO #AverageGrades
SELECT 
    s.SubjectName,
    AVG(g.Grade) AS AvgGrade
FROM Grades g
INNER JOIN Subjects s ON g.SubjectID = s.SubjectID
GROUP BY s.SubjectName;

SELECT * FROM #AverageGrades;
DROP TABLE #AverageGrades;


-- ������� 3. �������� � ������ � ��������� (�� �������) �����������.

-- 1. ��������� ��� ������ ��������� �� ����������
USE University;
GO

CREATE PROCEDURE pr_GetStudentsByFaculty
    @FacultyID INT
AS
BEGIN
    SELECT 
        s.StudentID,
        CONCAT(LastName, ' ', FirstName, ' ', MiddleName) AS FullName,
        g.GroupName
    FROM Students s
    INNER JOIN Groups g ON s.GroupID = g.GroupID
    WHERE g.FacultyID = @FacultyID;
END;
GO

-- ��������
EXEC pr_GetStudentsByFaculty 2;


-- ������� 4. ��������� ������������ �������� ���������.

-- 1. ���������� ��������� ��� ���������� �� �������
USE University;
GO

ALTER PROCEDURE pr_GetStudentsByFaculty
    @FacultyID INT,
    @IsBudget BIT
AS
BEGIN
    SELECT 
        s.StudentID,
        CONCAT(LastName, ' ', FirstName, ' ', MiddleName) AS FullName,
        g.GroupName
    FROM Students s
    INNER JOIN Groups g ON s.GroupID = g.GroupID
    WHERE g.FacultyID = @FacultyID
      AND s.IsBudget = @IsBudget;
END;
GO

-- ��������
EXEC pr_GetStudentsByFaculty 2, 1;


-- ������� 5: �������� �������� ���������.

-- 1. �������� �������� ��������� pr_GetStudentsByFaculty
IF OBJECT_ID('pr_GetStudentsByFaculty', 'P') IS NOT NULL
BEGIN
    DROP PROCEDURE pr_GetStudentsByFaculty;
    SELECT '�������� ��������� pr_GetStudentsByFaculty ������� �������.' AS [���������];
END
ELSE
BEGIN
    SELECT '�������� ��������� pr_GetStudentsByFaculty �� ����������.' AS [���������];
END
GO

-- ������� 6. �������� ������� ���� Scalar.

-- 1. ������� ��� ������� �������� ����� ��������
USE University;
GO

CREATE FUNCTION fn_GetStudentAverageGrade (@StudentID INT)
RETURNS DECIMAL(5,2)
AS
BEGIN
    DECLARE @AvgGrade DECIMAL(5,2);
    SELECT @AvgGrade = AVG(Grade)
    FROM Grades
    WHERE StudentID = @StudentID;
    RETURN @AvgGrade;
END;
GO

-- ��������
SELECT dbo.fn_GetStudentAverageGrade(1) AS [������� ����];


-- ������� 7. �������� ������� ���� Inline Table-valued.

-- 1. ������� ��� ��������� ������ ��������� �� ��������
USE University;
GO

CREATE FUNCTION fn_GetExamsBySubject (@SubjectID INT)
RETURNS TABLE
AS
RETURN (
    SELECT 
        e.ExamDate,
        e.Room,
        g.GroupName
    FROM Exams e
    INNER JOIN Groups g ON e.GroupID = g.GroupID
    WHERE e.SubjectID = @SubjectID
);
GO

-- ��������
SELECT * FROM fn_GetExamsBySubject(1);


-- ������� 8. �������� ������� ���� Multi-statement Table-valued.

-- 1. ������� ��� ������� ���������
USE University;
GO

CREATE FUNCTION fn_GetScholarshipSummary (@MinScore DECIMAL(3,1))
RETURNS @Result TABLE (
    StudentName NVARCHAR(200),
    ScholarshipType NVARCHAR(50),
    Amount DECIMAL(10,2)
)
AS
BEGIN
    INSERT INTO @Result
    SELECT 
        CONCAT(LastName, ' ', FirstName, ' ', MiddleName),
        sc.ScholarshipType,
        sc.ScholarshipAmount
    FROM StudentScholarships ss
    INNER JOIN Scholarships sc ON ss.ScholarshipID = sc.ScholarshipID
    INNER JOIN Students s ON ss.StudentID = s.StudentID
    WHERE sc.MinAverageScore >= @MinScore;

    RETURN;
END;
GO

-- ��������
SELECT * FROM fn_GetScholarshipSummary(8.0);


-- ������� 9. ���������� �������� ��������� pr_TopStudentByGrades

-- 1. ��������� ��� ����������� �������� � ���������� ����������� ������
USE University;
GO

CREATE PROCEDURE pr_TopStudentByGrades
    @Interval INT,
    @StudentName NVARCHAR(200) OUTPUT,
    @TotalGrades INT OUTPUT
AS
BEGIN
    SELECT TOP 1
        @StudentName = CONCAT(LastName, ' ', FirstName, ' ', MiddleName),
        @TotalGrades = COUNT(g.GradeID)
    FROM Grades g
    INNER JOIN Students s ON g.StudentID = s.StudentID
    WHERE g.GradeDate >= DATEADD(DAY, -@Interval, GETDATE())
    GROUP BY s.StudentID, s.LastName, s.FirstName, s.MiddleName
    ORDER BY COUNT(g.GradeID) DESC;
END;
GO

-- ��������
DECLARE @Name NVARCHAR(200), @Total INT;
EXEC pr_TopStudentByGrades 30, @Name OUTPUT, @Total OUTPUT;
SELECT @Name AS [�������], @Total AS [������];


-- ������� 10. ���������� �������� ��������� pr_FacultyStats

-- 1. ��������� ��� �������� ��������� � �������������� �� ����������
USE University;
GO

CREATE PROCEDURE pr_FacultyStats
    @FacultyID INT,
    @StartDate DATE,
    @EndDate DATE,
    @StudentsCount INT OUTPUT,
    @ProfessorsCount INT OUTPUT
AS
BEGIN
    -- ��������
    SELECT @StudentsCount = COUNT(DISTINCT s.StudentID)
    FROM Students s
    INNER JOIN Groups g ON s.GroupID = g.GroupID
    WHERE g.FacultyID = @FacultyID
      AND s.BirthDate BETWEEN @StartDate AND @EndDate;

    -- �������������
    SELECT @ProfessorsCount = COUNT(DISTINCT p.ProfessorID)
    FROM Professors p
    INNER JOIN Departments d ON p.DepartmentID = d.DepartmentID
    WHERE d.FacultyID = @FacultyID;
END;
GO

-- ��������
DECLARE @S INT, @P INT;
EXEC pr_FacultyStats 2, '2000-01-01', '2023-12-31', @S OUTPUT, @P OUTPUT;
SELECT @S AS [��������], @P AS [�������������];


-- ������� 11. ���������� ���������������� ������� fn_CurrentDate

-- 1. ������� ��� ��������� ������� ����
USE University;
GO

CREATE FUNCTION fn_CurrentDate()
RETURNS DATE
AS
BEGIN
    RETURN CAST(GETDATE() AS DATE);
END;
GO

-- ��������
SELECT dbo.fn_CurrentDate() AS [�������];


-- ������� 12. ���������� ���������������� ������� fn_getFullName

-- 1. ������� ��� �������������� ���
USE University;
GO

CREATE FUNCTION fn_FormatFullName (@FullName NVARCHAR(200))
RETURNS NVARCHAR(200)
AS
BEGIN
    SET @FullName = LTRIM(RTRIM(@FullName));
    DECLARE @Parts TABLE (Part NVARCHAR(50));
    INSERT INTO @Parts SELECT value FROM STRING_SPLIT(@FullName, ' ');
    
    DECLARE 
        @LastName NVARCHAR(50) = (SELECT TOP 1 Part FROM @Parts),
        @Initials NVARCHAR(10);

    SET @Initials = (
        SELECT STRING_AGG(LEFT(Part, 1) + '.', '') 
        FROM @Parts 
        WHERE Part <> @LastName
    );

    RETURN UPPER(@LastName + ' ' + @Initials);
END;
GO

-- ��������
SELECT dbo.fn_FormatFullName(N'������ ���� ��������') AS [���];


-- ������� 13. ���������� ���������������� ������� fn_GroupSubjects

-- 1. ������� ��� ����������� ������ �� ���������
USE University;
GO

CREATE FUNCTION fn_GroupSubjects (@Start DATE, @End DATE)
RETURNS TABLE
AS
RETURN (
    SELECT 
        s.SubjectName,
        COUNT(g.GradeID) AS TotalGrades,
        AVG(g.Grade) AS AvgGrade
    FROM Grades g
    INNER JOIN Subjects s ON g.SubjectID = s.SubjectID
    WHERE g.GradeDate BETWEEN @Start AND @End
    GROUP BY s.SubjectName
);
GO

-- ��������
SELECT * FROM fn_GroupSubjects('2023-01-01', '2023-12-31');


-- ������� 14. ���������� ���������������� ������� fn_FilterScholarships

-- 1. ������� ��� ������� ��������� ���������
USE University;
GO

CREATE FUNCTION fn_FilterScholarships (@MinAmount DECIMAL(10,2))
RETURNS @Result TABLE (
    StudentName NVARCHAR(200),
    ScholarshipType NVARCHAR(50),
    Amount DECIMAL(10,2)
)
AS
BEGIN
    INSERT INTO @Result
    SELECT 
        CONCAT(LastName, ' ', FirstName, ' ', MiddleName),
        sc.ScholarshipType,
        sc.ScholarshipAmount
    FROM StudentScholarships ss
    INNER JOIN Scholarships sc ON ss.ScholarshipID = sc.ScholarshipID
    INNER JOIN Students s ON ss.StudentID = s.StudentID
    WHERE sc.ScholarshipAmount >= @MinAmount;

    RETURN;
END;
GO

-- ��������
SELECT * FROM fn_FilterScholarships(100.00);