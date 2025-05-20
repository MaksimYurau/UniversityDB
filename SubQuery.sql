USE University
GO


-- ������� 1. ���������� �������� � ������������.

/* 1. ������� �������� ���� �����������, ������������� � ��� �� ����������, 
��� � ��������� � ������� "�������� ��������� ����������"
*/
SELECT f1.FacultyName
FROM Faculties f1
WHERE f1.AdministrationID = (
    SELECT f2.AdministrationID
    FROM Faculties f2
    WHERE f2.DeanName = N'�������� ��������� ����������'
);

-- 2. ������� StudentID � ����� ���������, � ������� ������� ������ ���� ������� �� ���� ���������
SELECT s.StudentID, s.LastName, s.FirstName
FROM Students s
WHERE (
    SELECT AVG(g.Grade)
    FROM Grades g
    WHERE g.StudentID = s.StudentID
) > (SELECT AVG(Grade) FROM Grades);

-- 3. ������� �������� ������ � ��� ���������� ���������, ������� ��������� � ���������� � FacultyID = 1
SELECT DepartmentName, HeadOfDepartment
FROM Departments
WHERE FacultyID = 1;

/* 4. ������� �������� ��������� � ����������� ���������� �����, 
��� ������� ���������� ����� ������, ��� � �������� � SubjectID = 1
*/
SELECT SubjectName, MIN(Hours) AS MinHours
FROM Subjects
GROUP BY SubjectName
HAVING AVG(Hours) > (SELECT AVG(Hours) FROM Subjects WHERE SubjectID = 1);

-- 5. ������� ������� ��������� � �� ������, ���� � ������� Groups ���������� ������ � EducationForm = N'�����'
SELECT s.LastName, g.GroupName
FROM Students s
INNER JOIN Groups g ON s.GroupID = g.GroupID
WHERE EXISTS (
    SELECT 1
    FROM Groups
    WHERE EducationForm = N'�����'
)
ORDER BY g.GroupName;

-- 6. ���������� ��������������, ������� ��������� ����� ������ ��������
SELECT p.LastName, p.FirstName
FROM Professors p
WHERE p.ProfessorID IN (
    SELECT ProfessorID
    FROM Exams
    GROUP BY ProfessorID
    HAVING COUNT(DISTINCT SubjectID) > 1
);


-- ������� 2. ���������� �������� � ���������� CASE.

-- 1. ���������� ��������� ��������� � ����������� �� �������� �����
SELECT s.StudentID, s.LastName, 
    CASE
        WHEN AVG(g.Grade) >= 9 THEN N'����������'
        WHEN AVG(g.Grade) >= 8 THEN N'�������������'
        ELSE N'�����������'
    END AS ScholarshipCategory
FROM Students s
INNER JOIN Grades g ON s.StudentID = g.StudentID
GROUP BY s.StudentID, s.LastName;

-- 2. ����������, ���� �� ��������� �������� ������� ���������
SELECT ss.StudentID, 
    CASE
        WHEN sch.ScholarshipAmount > (SELECT AVG(ScholarshipAmount) FROM Scholarships) THEN N'����������'
        WHEN sch.ScholarshipAmount = (SELECT AVG(ScholarshipAmount) FROM Scholarships) THEN N'�������������'
        ELSE N'����������'
    END AS ScholarshipStatus
FROM StudentScholarships ss
INNER JOIN Scholarships sch ON ss.ScholarshipID = sch.ScholarshipID;

-- 3. ��������� ��������� �� 10% ��� ���������� ���������
UPDATE Scholarships
SET ScholarshipAmount = ScholarshipAmount * 1.10
WHERE ScholarshipType = N'����������';


-- ������� 3. ���������� �������� � ���������� �����������.

-- 1. ������� ��� ������ ������� ���������� ���������
WITH ExamMonths AS (
    SELECT FORMAT(ExamDate, 'yyyy-MM') AS ExamMonth
    FROM Exams
    GROUP BY FORMAT(ExamDate, 'yyyy-MM')
)
SELECT ExamMonth
FROM ExamMonths;

-- 2. ������� ��������� � �� ���������, ��������� CTE
WITH StudentScholarshipInfo AS (
    SELECT s.LastName, sch.ScholarshipType, sch.ScholarshipAmount
    FROM Students s
    INNER JOIN StudentScholarships ss ON s.StudentID = ss.StudentID
    INNER JOIN Scholarships sch ON ss.ScholarshipID = sch.ScholarshipID
)
SELECT * FROM StudentScholarshipInfo;