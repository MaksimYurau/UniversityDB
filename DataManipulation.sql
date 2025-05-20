USE University
GO


-- Задание 1. Выборка данных из таблиц и представлений. Оператор SELECT

-- 1. Выборка всех столбцов и строк из таблицы Students
SELECT * 
FROM Students

-- 2. Выборка некоторых столбцов (вертикальный фильтр) из таблицы Faculties
SELECT FacultyName, DeanName, Phone 
FROM Faculties

-- 3. Выборка строк с условием (горизонтальный фильтр) из таблицы Professors
SELECT * 
FROM Professors 
WHERE AcademicDegree = N'Доктор наук'

-- 4. Комбинированный фильтр (столбцы + строки) из таблицы Groups
SELECT GroupName, EducationForm, Speciality 
FROM Groups 
WHERE EducationLevel = N'Бакалавриат' AND Coefficient = 1.0

-- 5. Сортировка данных из таблицы Students
SELECT LastName, FirstName, BirthDate 
FROM Students 
ORDER BY LastName ASC, FirstName ASC

-- 6. Соединение таблиц Students, Groups и Faculties
SELECT 
    S.LastName AS Студент,
    G.GroupName AS Группа,
    F.FacultyName AS Факультет
FROM Students S
INNER JOIN Groups G ON S.GroupID = G.GroupID
INNER JOIN Faculties F ON G.FacultyID = F.FacultyID
ORDER BY F.FacultyName

-- 7. Выборка данных из трех таблиц (Students, Grades, Subjects)
SELECT 
    S.LastName AS Студент,
    Sub.SubjectName AS Предмет,
    GR.Grade AS Оценка
FROM Students S
INNER JOIN Grades GR ON S.StudentID = GR.StudentID
INNER JOIN Subjects Sub ON GR.SubjectID = Sub.SubjectID
WHERE GR.Grade >= 8

-- 8. Вычисляемый столбец (возраст студента)
SELECT 
    LastName,
    FirstName,
    DATEDIFF(YEAR, BirthDate, GETDATE()) AS Возраст
FROM Students

-- 9. Агрегатные функции для таблицы Grades
SELECT 
    AVG(Grade) AS Средний_балл,
    MAX(Grade) AS Максимум,
    MIN(Grade) AS Минимум
FROM Grades

-- 10. Группировка данных по факультетам
SELECT 
    F.FacultyName AS Факультет,
    COUNT(S.StudentID) AS Количество_студентов
FROM Students S
INNER JOIN Groups G ON S.GroupID = G.GroupID
INNER JOIN Faculties F ON G.FacultyID = F.FacultyID
GROUP BY F.FacultyName

-- 11. Группировка с условием HAVING
SELECT 
    Sub.SubjectName AS Предмет,
    AVG(GR.Grade) AS Средний_балл
FROM Grades GR
INNER JOIN Subjects Sub ON GR.SubjectID = Sub.SubjectID
GROUP BY Sub.SubjectName
HAVING AVG(GR.Grade) > 7.5

-- 12. Выборка данных из представления StudentPerformance
SELECT FullName, GroupName, AverageGrade 
FROM StudentPerformance 
WHERE AverageGrade >= 8 
  AND AverageGrade IS NOT NULL

-- 13. Создание копии таблицы через SELECT INTO
SELECT * INTO Students_Backup 
FROM Students;
SELECT * INTO Grades_Backup 
FROM Grades 
WHERE Grade >= 8


-- Задание 2. Выборка системных данных

-- 1. Список учётных записей, которым разрешён доступ к серверу
/*USE master -- переключаемся на системную базу данных master
SELECT name, dbname, password, language FROM syslogins
USE University

-- 2. Список учётных записей, включённых в фиксированные роли сервера
EXEC sp_helpsrvrolemember

-- 3. Список пользователей базы данных University
EXEC sp_helpuser

-- 4. Список ролей (как фиксированных, так и пользовательских) базы данных University
EXEC sp_helprole

-- 5. Членство ролей и пользователей в ролях базы данных University
EXEC sp_helprolemember
*/


-- Задание 3. Обновление данных в таблицах и представлениях

-- 1. Обновление контактного телефона студента с StudentID = 1.
/* UPDATE Students
SET Phone = '+375 29 765-43-21'
WHERE StudentID = 1
SELECT * FROM Students

-- 2. Обновление названия дисциплины с SubjectID = 1 на "Системы баз данных".
UPDATE Subjects
SET SubjectName = N'Системы баз данных'
WHERE SubjectID = 1
SELECT * FROM Subjects

-- 3. Перенос всех студентов в группу с GroupID = 11 
UPDATE Students
SET GroupID = 11
WHERE GroupID <> 11
SELECT * FROM Students
*/

-- Задание 4. Удаление данных из таблиц и представлений

-- 1. Удаление всех оценок, выставленных до 2023-12-21
/* DELETE FROM Grades
WHERE GradeDate < '2023-12-21'
SELECT * FROM Grades
*/

-- Задание 5. Изменение структуры таблицы.

-- 1. Ограничение даты рождения студентов диапазоном от 1950 года до текущего года
/* ALTER TABLE Students
ADD CONSTRAINT CHK_Students_BirthDate 
CHECK (BirthDate BETWEEN '1950-01-01' AND GETDATE());
EXEC sp_help 'Students'
*/

-- Задание 6. Удаление таблиц из базы данных.

-- 1. Удаление резервных таблиц 
/* DROP TABLE IF EXISTS Students_Backup
DROP TABLE IF EXISTS Grades_Backup
SELECT * FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_NAME IN ('Students_Backup', 'Grades_Backup')
*/

-- Задания для самостоятельного выполнения.

-- Задание 7. Создание новых таблиц.

-- 1. Создание таблицы Attendance (посещаемость занятий)
CREATE TABLE Attendance (
    AttendanceID INT PRIMARY KEY IDENTITY(1,1),
    StudentID INT NOT NULL FOREIGN KEY REFERENCES Students(StudentID),
    SubjectID INT NOT NULL FOREIGN KEY REFERENCES Subjects(SubjectID),
    AttendanceDate DATE NOT NULL DEFAULT GETDATE(),
    IsPresent BIT NOT NULL DEFAULT 1, -- 1: присутствовал, 0: отсутствовал
    CONSTRAINT CHK_Attendance_Date CHECK (AttendanceDate <= GETDATE())
)
GO

-- 2. Создание таблицы ClassSchedule (расписание занятий)
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

-- 3. Установка индексов для оптимизации
-- Индекс для поиска по дате посещаемости
CREATE NONCLUSTERED INDEX IX_Attendance_Date 
ON Attendance(AttendanceDate)

-- Индекс для расписания по группе и предмету
CREATE NONCLUSTERED INDEX IX_ClassSchedule_GroupSubject 
ON ClassSchedule(GroupID, SubjectID)

-- 4. Добавление данных в новые таблицы
-- Добавление данных в Attendance
INSERT INTO Attendance (StudentID, SubjectID, IsPresent)
VALUES 
(1, 1, 1),
(2, 1, 0),
(3, 2, 1);

-- Добавление данных в ClassSchedule
INSERT INTO ClassSchedule (GroupID, SubjectID, ProfessorID, ClassDate, StartTime, EndTime, Room)
VALUES 
(1, 1, 1, '2023-10-10', '09:00', '11:00', N'Ауд. 301'),
(2, 2, 2, '2023-10-11', '14:00', '16:00', N'Ауд. 205');


-- Задание 8. Продвинутые операции с данными

-- 1. Вывести список студентов с их средним баллом, отсортированный по убыванию среднего балла
SELECT 
    S.StudentID,
    S.LastName + ' ' + S.FirstName AS FullName,
    AVG(GR.Grade) AS AverageGrade
FROM Students S
INNER JOIN Grades GR ON S.StudentID = GR.StudentID
GROUP BY S.StudentID, S.LastName, S.FirstName
ORDER BY AverageGrade DESC

-- 2. Найти факультеты, где средний балл студентов выше 7.5
SELECT 
    F.FacultyName,
    AVG(GR.Grade) AS FacultyAverage
FROM Faculties F
INNER JOIN Groups G ON F.FacultyID = G.FacultyID
INNER JOIN Students S ON G.GroupID = S.GroupID
INNER JOIN Grades GR ON S.StudentID = GR.StudentID
GROUP BY F.FacultyName
HAVING AVG(GR.Grade) > 7.5

-- 3. Удалить студентов, которые не имеют ни одной оценки
DELETE FROM Students
WHERE StudentID NOT IN (SELECT DISTINCT StudentID FROM Grades)
SELECT * FROM Students

-- 4. Создать индекс для ускорения поиска по фамилии студента
CREATE NONCLUSTERED INDEX IX_Students_LastName
ON Students(LastName)
EXEC sp_helpindex 'Students'


-- Задание 9. Обновление данных в таблицах

-- 1. Обновление контактного телефона студента с StudentID = 1.
UPDATE Students
SET Phone = '+375 29 765-43-21'
WHERE StudentID = 1
SELECT * FROM Students

-- 2. Обновление названия дисциплины с SubjectID = 1 на "Системы баз данных".
UPDATE Subjects
SET SubjectName = N'Системы баз данных'
WHERE SubjectID = 1
SELECT * FROM Subjects

-- 3. Перенос всех студентов в группу с GroupID = 11 
UPDATE Students
SET GroupID = 11
WHERE GroupID <> 11
SELECT * FROM Students


-- Задание 10. Обновление данных в таблицах

-- 1. Перенос экзаменов, запланированных на 23 декабря 2023 года, на 24 декабря 2023 года
UPDATE Exams
SET ExamDate = '2023-12-24'
WHERE ExamDate = '2023-12-23'
SELECT * FROM Exams WHERE ExamDate = '2023-12-24'


-- Задание 11. Изменение структуры данных и представлений

-- 1. Добавление нового столбца IsActive в таблицу Students
ALTER TABLE Students
ADD IsActive BIT NOT NULL DEFAULT 1; -- 1: активен, 0: неактивен

-- 2. Изменение представления StudentPerformance
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
        WHEN AVG(GR.Grade) >= 9.0 THEN N'Отлично'
        WHEN AVG(GR.Grade) >= 7.0 THEN N'Хорошо'
        ELSE N'Требует внимания'
    END AS PerformanceStatus
FROM Students S
INNER JOIN Groups G ON S.GroupID = G.GroupID
INNER JOIN Faculties F ON G.FacultyID = F.FacultyID
INNER JOIN Grades GR ON S.StudentID = GR.StudentID
INNER JOIN Subjects Sub ON GR.SubjectID = Sub.SubjectID
WHERE S.IsActive = 1 -- Только активные студенты
GROUP BY 
    S.StudentID, 
    S.LastName, 
    S.FirstName, 
    G.GroupName, 
    F.FacultyName, 
    Sub.SubjectName;
GO

-- 3. Запрет повторяющихся email-адресов для преподавателей
CREATE UNIQUE INDEX UQ_Professors_Email 
ON Professors(Email)
WHERE Email IS NOT NULL; -- Разрешает несколько NULL, но запрещает дубликаты


-- Задание 12. Удаление таблиц из базы данных

-- 1. Удаление резервных таблиц 
DROP TABLE IF EXISTS Students_Backup
DROP TABLE IF EXISTS Grades_Backup
SELECT * FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_NAME IN ('Students_Backup', 'Grades_Backup')
