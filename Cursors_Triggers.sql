USE University
GO


-- ������� 1. ���������� �������� ��������� � �������������� �������.

-- 1. ���������� ��������� ��������� ���� ���������, ���������� ��������� ���������� ���� �� ������������ ������
CREATE PROCEDURE pr_TotalScholarship
    @ScholarshipType NVARCHAR(50),
    @StartDate DATE,
    @EndDate DATE,
    @TotalAmount DECIMAL(10,2) OUTPUT
AS
BEGIN
    SET @TotalAmount = 0;
    DECLARE @CurrentAmount DECIMAL(10,2);
    
    -- ���������� �������
    DECLARE scholarship_cursor CURSOR LOCAL STATIC FOR
    SELECT ss.StartDate, ss.EndDate, s.ScholarshipAmount
    FROM StudentScholarships ss
    INNER JOIN Scholarships s ON ss.ScholarshipID = s.ScholarshipID
    WHERE s.ScholarshipType = @ScholarshipType
      AND ss.StartDate BETWEEN @StartDate AND @EndDate;
    
    OPEN scholarship_cursor;
    FETCH NEXT FROM scholarship_cursor INTO @StartDate, @EndDate, @CurrentAmount;
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @TotalAmount = @TotalAmount + @CurrentAmount;
        FETCH NEXT FROM scholarship_cursor INTO @StartDate, @EndDate, @CurrentAmount;
    END
    
    CLOSE scholarship_cursor;
    DEALLOCATE scholarship_cursor;
END
GO

-- �������� ������ ���������
DECLARE @Result DECIMAL(10,2);
EXEC pr_TotalScholarship 
    @ScholarshipType = N'�������������',
    @StartDate = '2023-09-01',
    @EndDate = '2024-01-31',
    @TotalAmount = @Result OUTPUT;
SELECT @Result AS TotalScholarship;


-- ������� 2. ���������� �������� ��� ������� ��������� ������.

-- 1. ��������� ��������� ���� BirthDate � ������� Students
USE University
GO

CREATE TRIGGER tr_NoUpdate_BirthDate
ON Students
FOR UPDATE AS
BEGIN
    IF UPDATE(BirthDate)
    BEGIN
        PRINT '��������� ���� �������� ���������!';
        ROLLBACK TRANSACTION;
    END
END
GO

-- �������� ��������
UPDATE Students SET BirthDate = '2005-01-01' WHERE StudentID = 1; -- ������� ������


-- ������� 3. ���������� �������� ��������� pr_ScholarshipByType.

-- 1. ���������� ��������� ��������� �� ���� �� ������
USE University
GO

CREATE PROCEDURE pr_ScholarshipByType
    @ScholarshipType NVARCHAR(50),
    @StartDate DATE,
    @EndDate DATE,
    @Total DECIMAL(10,2) OUTPUT
AS
BEGIN
    SELECT @Total = SUM(s.ScholarshipAmount)
    FROM StudentScholarships ss
    INNER JOIN Scholarships s ON ss.ScholarshipID = s.ScholarshipID
    WHERE s.ScholarshipType = @ScholarshipType
      AND ss.StartDate BETWEEN @StartDate AND @EndDate;
END
GO

-- ��������
DECLARE @Result DECIMAL(10,2);
EXEC pr_ScholarshipByType 
    @ScholarshipType = N'����������',
    @StartDate = '2023-09-01',
    @EndDate = '2024-01-31',
    @Total = @Result OUTPUT;
SELECT @Result AS Total;


-- ������� 4. ���������� �������� ���������.

/* 1. ������� �������� ���������, ������� ��������� ������� � ����������� ��������� � �������������� 
�� ������� ���������� ������� �����������
*/
USE University
GO

CREATE PROCEDURE pr_InstitutionStats
AS
BEGIN
    SELECT 
        hei.Name AS InstitutionName,
        COUNT(DISTINCT s.StudentID) AS StudentsCount,
        COUNT(DISTINCT p.ProfessorID) AS ProfessorsCount
    FROM HigherEducationInstitution hei
    LEFT JOIN Administration a ON hei.InstitutionID = a.InstitutionID
    LEFT JOIN Faculties f ON a.AdministrationID = f.AdministrationID
    LEFT JOIN Groups g ON f.FacultyID = g.FacultyID
    LEFT JOIN Students s ON g.GroupID = s.GroupID
    LEFT JOIN Departments d ON f.FacultyID = d.FacultyID
    LEFT JOIN Professors p ON d.DepartmentID = p.DepartmentID
    GROUP BY hei.Name;
END
GO

-- �������� ������ ���������
EXEC pr_InstitutionStats;


-- ������� 5. �������� ������� Protocol.

-- 1. ���������� ��������� � ������� Students
-- �������� ������� Protocol
CREATE TABLE Protocol (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    DateTime DATETIME DEFAULT GETDATE(),
    [User] NVARCHAR(100) DEFAULT USER_NAME(),
    Action NVARCHAR(10),
    RowNumber INT
);

-- ������� ��� ����������� ���������
USE University
GO

CREATE TRIGGER tr_Students_Protocol
ON Students
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    DECLARE @Action NVARCHAR(10);
    SET @Action = CASE 
        WHEN EXISTS(SELECT * FROM inserted) AND EXISTS(SELECT * FROM deleted) THEN 'Update'
        WHEN EXISTS(SELECT * FROM inserted) THEN 'Insert'
        ELSE 'Delete'
    END;
    
    INSERT INTO Protocol (Action, RowNumber)
    SELECT @Action, COUNT(*) FROM (SELECT * FROM inserted UNION ALL SELECT * FROM deleted) t;
END
GO

-- ��������
UPDATE Students SET Phone = '+375 29 000-00-00' WHERE StudentID = 1;
SELECT * FROM Protocol;


-- ������� 6. ��������� �������� ��� ��������������� ����������.

-- 1. ��������� ��������� ��� ��������� ������
USE University
GO

IF OBJECT_ID('tr_UpdateScholarship', 'TR') IS NOT NULL
    DROP TRIGGER tr_UpdateScholarship;
GO

CREATE TRIGGER tr_UpdateScholarship
ON Grades
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON; -- ������� ��������� "(1 row affected)"
    
    DECLARE @StudentID INT, 
            @AvgScore DECIMAL(3,1);

    -- �������� StudentID �� �����������/����������� ������
    SELECT @StudentID = StudentID 
    FROM inserted;

    -- ��������� ������� ����, ������� NULL �� 0
    SELECT @AvgScore = ISNULL(AVG(Grade), 0)
    FROM Grades
    WHERE StudentID = @StudentID;

    -- ��������� ��������� ������ ���� ���� ������
    IF @AvgScore > 0
    BEGIN
        UPDATE StudentScholarships
        SET ScholarshipID = CASE 
            WHEN @AvgScore >= 9.0 THEN 3 -- ����������
            WHEN @AvgScore >= 8.0 THEN 1 -- �������������
            ELSE 4 -- �������
        END
        WHERE StudentID = @StudentID;
    END
END
GO

-- ��������
INSERT INTO Grades (GradeID, StudentID, SubjectID, Grade)
VALUES (7, 1, 4, 10);
SELECT * FROM StudentScholarships WHERE StudentID = 1;


-- �������������� ������� (����������)

-- ������� 7.����������: ���������� �������� � ���������� ���������
USE University
GO

BEGIN TRANSACTION;
BEGIN TRY
    -- ���������� ������ ��������
    INSERT INTO Students (StudentID, LastName, FirstName, MiddleName, GroupID, IsBudget, HasDormitory, BirthDate, MaritalStatus, Phone, Email)
    VALUES (5, '������', '����', '�������������', 1, 1, 0, '2004-03-10', N'������', '+375 29 888-88-88', 'petr_ivanov@mail.ru');

    -- ���������� ���������
    INSERT INTO StudentScholarships (StudentScholarshipID, StudentID, ScholarshipID, StartDate, EndDate)
    VALUES (5, 5, 1, '2023-09-01', '2024-01-31');

    -- ������������� ����������
    COMMIT TRANSACTION;
    PRINT '������� � ��������� ������� ���������.';
END TRY
BEGIN CATCH
    -- ����� ���������� ��� ������
    ROLLBACK TRANSACTION;
    PRINT '������: ' + ERROR_MESSAGE();
END CATCH;


-- ������� 8. ����������: ���������� ������ � ��������� ��������
USE University
GO

BEGIN TRANSACTION;
BEGIN TRY
    -- ���������� ������ ��������
    UPDATE Grades 
    SET Grade = 9 
    WHERE StudentID = 1 AND SubjectID = 1 AND GradeDate = '2023-12-20';

    -- ������ ������ �������� �����
    DECLARE @AvgGrade DECIMAL(3,1);
    SELECT @AvgGrade = AVG(Grade) FROM Grades WHERE StudentID = 1;

    -- ���������� ��������� � ����������� �� �������� �����
    UPDATE StudentScholarships 
    SET ScholarshipID = CASE 
        WHEN @AvgGrade >= 9 THEN 3  -- ���������� ���������
        WHEN @AvgGrade >= 8 THEN 1  -- ������������� ���������
        ELSE 2                      -- ���������� ���������
    END
    WHERE StudentID = 1;

    -- ������������� ����������
    COMMIT TRANSACTION;
    PRINT '������ � ��������� �������� ���������.';
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT '������: ' + ERROR_MESSAGE();
END CATCH;


-- ������� 9. ����������: ������� �������� �� ������ � ���������� ���������
USE University
GO

BEGIN TRANSACTION;
BEGIN TRY
    -- ������� �������� �� ������
    UPDATE Students 
    SET IsBudget = 1 
    WHERE StudentID = 4;

    -- ������� � ���������
    UPDATE Students 
    SET HasDormitory = 1 
    WHERE StudentID = 4;

    -- ������������� ����������
    COMMIT TRANSACTION;
    PRINT '������� ��������� �� ������ � ���������.';
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT '������: ' + ERROR_MESSAGE();
END CATCH;


-- ������� 10. ���������� � ������� ���������� (SAVE TRANSACTION)
USE University
GO

BEGIN TRANSACTION;
BEGIN TRY
    -- ����� ���������� ��� ���������
    SAVE TRANSACTION SaveStudents;

    -- ���������� ��������� ���������
    UPDATE Students 
    SET Phone = '+375 29 999-99-99' 
    WHERE StudentID = 1;

    -- ���������� email �������������
    UPDATE Professors 
    SET Email = 'new_email@mitso.by' 
    WHERE ProfessorID = 1;

    -- ���� �����, ����� �������� ������ ����� ����������
    -- ROLLBACK TRANSACTION SaveStudents;

    -- ������������� ���� ����������
    COMMIT TRANSACTION;
    PRINT '�������� ��������� � �������������� ���������.';
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT '������: ' + ERROR_MESSAGE();
END CATCH;


-- ������� 11. ����������: �������� �������� ���������� ������
USE University
GO

BEGIN TRANSACTION;
BEGIN TRY
    -- �������� ������ ������ 1 ����
    DELETE FROM Grades 
    WHERE GradeDate < DATEADD(YEAR, -1, GETDATE());

    -- �������� ��������� ��� ������
    DELETE FROM Students 
    WHERE StudentID NOT IN (SELECT DISTINCT StudentID FROM Grades);

    COMMIT TRANSACTION;
    PRINT '���������� ������ �������.';
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT '������: ' + ERROR_MESSAGE();
END CATCH;