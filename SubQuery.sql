USE University
GO


-- Задание 1. Разработка запросов с подзапросами.

/* 1. Вывести названия всех факультетов, расположенных в том же учреждении, 
что и факультет с деканом "Ковтунов Александр Васильевич"
*/
SELECT f1.FacultyName
FROM Faculties f1
WHERE f1.AdministrationID = (
    SELECT f2.AdministrationID
    FROM Faculties f2
    WHERE f2.DeanName = N'Ковтунов Александр Васильевич'
);

-- 2. Вывести StudentID и имена студентов, у которых средняя оценка выше средней по всем студентам
SELECT s.StudentID, s.LastName, s.FirstName
FROM Students s
WHERE (
    SELECT AVG(g.Grade)
    FROM Grades g
    WHERE g.StudentID = s.StudentID
) > (SELECT AVG(Grade) FROM Grades);

-- 3. Вывести названия кафедр и ФИО заведующих кафедрами, которые относятся к факультету с FacultyID = 1
SELECT DepartmentName, HeadOfDepartment
FROM Departments
WHERE FacultyID = 1;

/* 4. Вывести названия предметов и минимальное количество часов, 
где среднее количество часов больше, чем у предмета с SubjectID = 1
*/
SELECT SubjectName, MIN(Hours) AS MinHours
FROM Subjects
GROUP BY SubjectName
HAVING AVG(Hours) > (SELECT AVG(Hours) FROM Subjects WHERE SubjectID = 1);

-- 5. Вывести фамилии студентов и их группы, если в таблице Groups существуют группы с EducationForm = N'Очная'
SELECT s.LastName, g.GroupName
FROM Students s
INNER JOIN Groups g ON s.GroupID = g.GroupID
WHERE EXISTS (
    SELECT 1
    FROM Groups
    WHERE EducationForm = N'Очная'
)
ORDER BY g.GroupName;

-- 6. Определить преподавателей, которые преподают более одного предмета
SELECT p.LastName, p.FirstName
FROM Professors p
WHERE p.ProfessorID IN (
    SELECT ProfessorID
    FROM Exams
    GROUP BY ProfessorID
    HAVING COUNT(DISTINCT SubjectID) > 1
);


-- Задание 2. Разработка запросов с выражением CASE.

-- 1. Определить категорию стипендии в зависимости от среднего балла
SELECT s.StudentID, s.LastName, 
    CASE
        WHEN AVG(g.Grade) >= 9 THEN N'Повышенная'
        WHEN AVG(g.Grade) >= 8 THEN N'Академическая'
        ELSE N'Отсутствует'
    END AS ScholarshipCategory
FROM Students s
INNER JOIN Grades g ON s.StudentID = g.StudentID
GROUP BY s.StudentID, s.LastName;

-- 2. Определить, выше ли стипендия студента средней стипендии
SELECT ss.StudentID, 
    CASE
        WHEN sch.ScholarshipAmount > (SELECT AVG(ScholarshipAmount) FROM Scholarships) THEN N'Повышенная'
        WHEN sch.ScholarshipAmount = (SELECT AVG(ScholarshipAmount) FROM Scholarships) THEN N'Академическая'
        ELSE N'Социальная'
    END AS ScholarshipStatus
FROM StudentScholarships ss
INNER JOIN Scholarships sch ON ss.ScholarshipID = sch.ScholarshipID;

-- 3. Увеличить стипендию на 10% для повышенных стипендий
UPDATE Scholarships
SET ScholarshipAmount = ScholarshipAmount * 1.10
WHERE ScholarshipType = N'Повышенная';


-- Задание 3. Разработка запросов с табличными выражениями.

-- 1. Вывести все группы месяцев проведения экзаменов
WITH ExamMonths AS (
    SELECT FORMAT(ExamDate, 'yyyy-MM') AS ExamMonth
    FROM Exams
    GROUP BY FORMAT(ExamDate, 'yyyy-MM')
)
SELECT ExamMonth
FROM ExamMonths;

-- 2. Вывести студентов и их стипендии, используя CTE
WITH StudentScholarshipInfo AS (
    SELECT s.LastName, sch.ScholarshipType, sch.ScholarshipAmount
    FROM Students s
    INNER JOIN StudentScholarships ss ON s.StudentID = ss.StudentID
    INNER JOIN Scholarships sch ON ss.ScholarshipID = sch.ScholarshipID
)
SELECT * FROM StudentScholarshipInfo;