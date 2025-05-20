USE University
GO


-- Задание 1. Разработка хранимой процедуры с использованием курсора.

-- 1. Подсчитать суммарную стипендию всех студентов, получающих стипендию указанного типа за определенный период
CREATE PROCEDURE pr_TotalScholarship
    @ScholarshipType NVARCHAR(50),
    @StartDate DATE,
    @EndDate DATE,
    @TotalAmount DECIMAL(10,2) OUTPUT
AS
BEGIN
    SET @TotalAmount = 0;
    DECLARE @CurrentAmount DECIMAL(10,2);
    
    -- Объявление курсора
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

-- Проверка работы процедуры
DECLARE @Result DECIMAL(10,2);
EXEC pr_TotalScholarship 
    @ScholarshipType = N'Академическая',
    @StartDate = '2023-09-01',
    @EndDate = '2024-01-31',
    @TotalAmount = @Result OUTPUT;
SELECT @Result AS TotalScholarship;


-- Задание 2. Разработка триггера для запрета изменения данных.

-- 1. Запретить изменение поля BirthDate в таблице Students
USE University
GO

CREATE TRIGGER tr_NoUpdate_BirthDate
ON Students
FOR UPDATE AS
BEGIN
    IF UPDATE(BirthDate)
    BEGIN
        PRINT 'Изменение даты рождения запрещено!';
        ROLLBACK TRANSACTION;
    END
END
GO

-- Проверка триггера
UPDATE Students SET BirthDate = '2005-01-01' WHERE StudentID = 1; -- Вызовет ошибку


-- Задание 3. Разработка хранимой процедуры pr_ScholarshipByType.

-- 1. Подсчитать суммарную стипендию по типу за период
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

-- Проверка
DECLARE @Result DECIMAL(10,2);
EXEC pr_ScholarshipByType 
    @ScholarshipType = N'Социальная',
    @StartDate = '2023-09-01',
    @EndDate = '2024-01-31',
    @Total = @Result OUTPUT;
SELECT @Result AS Total;


-- Задание 4. Разработка хранимой процедуры.

/* 1. Создать хранимую процедуру, которая формирует таблицу с количеством студентов и преподавателей 
по каждому учреждению высшего образования
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

-- Проверка работы процедуры
EXEC pr_InstitutionStats;


-- Задание 5. Создание таблицы Protocol.

-- 1. Логировать изменения в таблице Students
-- Создание таблицы Protocol
CREATE TABLE Protocol (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    DateTime DATETIME DEFAULT GETDATE(),
    [User] NVARCHAR(100) DEFAULT USER_NAME(),
    Action NVARCHAR(10),
    RowNumber INT
);

-- Триггер для логирования изменений
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

-- Проверка
UPDATE Students SET Phone = '+375 29 000-00-00' WHERE StudentID = 1;
SELECT * FROM Protocol;


-- Задание 6. Доработка триггера для автоматического обновления.

-- 1. Обновлять стипендии при изменении оценок
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
    SET NOCOUNT ON; -- Убирает сообщение "(1 row affected)"
    
    DECLARE @StudentID INT, 
            @AvgScore DECIMAL(3,1);

    -- Получаем StudentID из вставленных/обновленных данных
    SELECT @StudentID = StudentID 
    FROM inserted;

    -- Вычисляем средний балл, заменяя NULL на 0
    SELECT @AvgScore = ISNULL(AVG(Grade), 0)
    FROM Grades
    WHERE StudentID = @StudentID;

    -- Обновляем стипендию только если есть оценки
    IF @AvgScore > 0
    BEGIN
        UPDATE StudentScholarships
        SET ScholarshipID = CASE 
            WHEN @AvgScore >= 9.0 THEN 3 -- Повышенная
            WHEN @AvgScore >= 8.0 THEN 1 -- Академическая
            ELSE 4 -- Базовая
        END
        WHERE StudentID = @StudentID;
    END
END
GO

-- Проверка
INSERT INTO Grades (GradeID, StudentID, SubjectID, Grade)
VALUES (7, 1, 4, 10);
SELECT * FROM StudentScholarships WHERE StudentID = 1;


-- Дополнительные задания (транзакции)

-- Задание 7.Транзакция: Добавление студента и назначение стипендии
USE University
GO

BEGIN TRANSACTION;
BEGIN TRY
    -- Добавление нового студента
    INSERT INTO Students (StudentID, LastName, FirstName, MiddleName, GroupID, IsBudget, HasDormitory, BirthDate, MaritalStatus, Phone, Email)
    VALUES (5, 'Иванов', 'Петр', 'Александрович', 1, 1, 0, '2004-03-10', N'Холост', '+375 29 888-88-88', 'petr_ivanov@mail.ru');

    -- Назначение стипендии
    INSERT INTO StudentScholarships (StudentScholarshipID, StudentID, ScholarshipID, StartDate, EndDate)
    VALUES (5, 5, 1, '2023-09-01', '2024-01-31');

    -- Подтверждение транзакции
    COMMIT TRANSACTION;
    PRINT 'Студент и стипендия успешно добавлены.';
END TRY
BEGIN CATCH
    -- Откат транзакции при ошибке
    ROLLBACK TRANSACTION;
    PRINT 'Ошибка: ' + ERROR_MESSAGE();
END CATCH;


-- Задание 8. Транзакция: Обновление оценок и стипендии студента
USE University
GO

BEGIN TRANSACTION;
BEGIN TRY
    -- Обновление оценки студента
    UPDATE Grades 
    SET Grade = 9 
    WHERE StudentID = 1 AND SubjectID = 1 AND GradeDate = '2023-12-20';

    -- Расчет нового среднего балла
    DECLARE @AvgGrade DECIMAL(3,1);
    SELECT @AvgGrade = AVG(Grade) FROM Grades WHERE StudentID = 1;

    -- Обновление стипендии в зависимости от среднего балла
    UPDATE StudentScholarships 
    SET ScholarshipID = CASE 
        WHEN @AvgGrade >= 9 THEN 3  -- Повышенная стипендия
        WHEN @AvgGrade >= 8 THEN 1  -- Академическая стипендия
        ELSE 2                      -- Социальная стипендия
    END
    WHERE StudentID = 1;

    -- Подтверждение транзакции
    COMMIT TRANSACTION;
    PRINT 'Оценка и стипендия студента обновлены.';
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Ошибка: ' + ERROR_MESSAGE();
END CATCH;


-- Задание 9. Транзакция: Перевод студента на бюджет и обновление общежития
USE University
GO

BEGIN TRANSACTION;
BEGIN TRY
    -- Перевод студента на бюджет
    UPDATE Students 
    SET IsBudget = 1 
    WHERE StudentID = 4;

    -- Перевод в общежитие
    UPDATE Students 
    SET HasDormitory = 1 
    WHERE StudentID = 4;

    -- Подтверждение транзакции
    COMMIT TRANSACTION;
    PRINT 'Студент переведен на бюджет и общежитие.';
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Ошибка: ' + ERROR_MESSAGE();
END CATCH;


-- Задание 10. Транзакция с точками сохранения (SAVE TRANSACTION)
USE University
GO

BEGIN TRANSACTION;
BEGIN TRY
    -- Точка сохранения для студентов
    SAVE TRANSACTION SaveStudents;

    -- Обновление телефонов студентов
    UPDATE Students 
    SET Phone = '+375 29 999-99-99' 
    WHERE StudentID = 1;

    -- Обновление email преподавателя
    UPDATE Professors 
    SET Email = 'new_email@mitso.by' 
    WHERE ProfessorID = 1;

    -- Если нужно, можно откатить только часть транзакции
    -- ROLLBACK TRANSACTION SaveStudents;

    -- Подтверждение всей транзакции
    COMMIT TRANSACTION;
    PRINT 'Контакты студентов и преподавателей обновлены.';
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Ошибка: ' + ERROR_MESSAGE();
END CATCH;


-- Задание 11. Транзакция: Массовое удаление устаревших данных
USE University
GO

BEGIN TRANSACTION;
BEGIN TRY
    -- Удаление оценок старше 1 года
    DELETE FROM Grades 
    WHERE GradeDate < DATEADD(YEAR, -1, GETDATE());

    -- Удаление студентов без оценок
    DELETE FROM Students 
    WHERE StudentID NOT IN (SELECT DISTINCT StudentID FROM Grades);

    COMMIT TRANSACTION;
    PRINT 'Устаревшие данные удалены.';
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Ошибка: ' + ERROR_MESSAGE();
END CATCH;