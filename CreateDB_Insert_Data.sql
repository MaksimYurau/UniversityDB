﻿USE University
GO

-- 1. HigherEducationInstitution
INSERT INTO HigherEducationInstitution (InstitutionID, Name, Address, RectorName, FoundationYear, Phone, Email)
VALUES 
(1, N'Учреждения образования Федерации профсоюзов Беларуси «Международный университет «МИТСО»', N'ул. Казинца 21/3, 220099, г. Минск', N'Поздняков Владимир Михайлович', 1930, '+375 17 279-98-00', 'mitso@mitso.by'),
(2, N'Витебский филиал Учреждения образования Федерации профсоюзов Беларуси «Международный университет «МИТСО»', N'ул. М. Шагала, 8А, 210015, г. Витебск', N'Поздняков Владимир Михайлович', 1994, '+375 21 266-99-88', 'mitsovf@mitsovf.by'),
(3, N'Гомельский филиал Учреждения образования Федерации профсоюзов Беларуси «Международный университет «МИТСО»', N'пр. Октября 46А, 246029, г. Гомель', N'Поздняков Владимир Михайлович', 1991, '+375 23 221-48-71', 'gf@mitso.by');

-- 2. Administration
INSERT INTO Administration (AdministrationID, Name, InstitutionID, HeadName, Phone, Email)
VALUES
(1, N'Администрация Учреждения образования Федерации профсоюзов Беларуси «Международный университет «МИТСО»', 1, N'Поздняков Владимир Михайлович', '+375 17 279-98-00', 'mitso@mitso.by'),
(2, N'Администрация Витебского филиала Учреждения образования Федерации профсоюзов Беларуси «Международный университет «МИТСО»', 2, N'Николаева Ирина Владимировна', '+375 21 266-99-88', 'mitsovf@mitsovf.by'),
(3, N'Администрация Гомельского филиала Учреждения образования Федерации профсоюзов Беларуси «Международный университет «МИТСО»', 3, N'Колесников Сергей Дмитриевич', '+375 23 221-48-71', 'gf@mitso.by');

-- 3. Faculties
INSERT INTO Faculties (FacultyID, FacultyName, DeanName, AdministrationID, Phone, Email)
VALUES
(1, N'Экономический факультет', N'Ковтунов Александр Васильевич', 1, '+375 17 279-98-34', NULL),
(2, N'Юридический факультет', N'Юрочкин Михаил Алексеевич', 1, NULL, NULL),
(3, N'Гуманитарный факультет Витебского филиала', N'Генина Юлия Анатольевна', 2, NULL, NULL),
(4, N'Факультет экономики и права Гомельского филиала', N'Кузнецов Николай Васильевич', 3, NULL, NULL);

-- 4. Departments
INSERT INTO Departments (DepartmentID, DepartmentName, HeadOfDepartment, FacultyID, Phone, Email)
VALUES
(1, N'Кафедра логистики и маркетинга', N'Колеснёва Елена Петровна', 1, NULL, NULL),
(2, N'Кафедра международного права', N'Макарова Мария Юрьевна', 2, NULL, NULL),
(3, N'Кафедра информационных технологий', N'Хорошко Ольга Болеславовна', 1, NULL, NULL),
(4, N'Кафедра иностранных языков и межкультурных коммуникаций', N'Скромблевич Валерия Болеславовна', 1, NULL, NULL),
(5, N'Кафедра социально-гуманитарных дисциплин', N'Пастушеня Александр Николаевич', 2, '+375 17 279-98-86', NULL),
(6, N'Кафедра экономики и менеджмента', N'Чечёткин Сергей Александрович', 1, NULL, NULL),
(7, N'Кафедра уголовно-правовых дисциплин', N'Дедковский Андрей Андреевич', 2, NULL, NULL),
(8, N'Кафедра гражданско-правовых дисциплин и профсоюзной работы', N'Синьков Борис Борисович', 2, NULL, NULL),
(9, N'Кафедра физического воспитания', N'Янович Юрий Адамович', 2, NULL, NULL),
(10, N'Кафедра правоведения и социально-гуманитарных дисциплин Витебского филиала', N'Лавицкий Антон Алексеевич', 3, '+375 21 266-62-58', NULL),
(11, N'Кафедра экономики и информационных технологий Витебского филиала', N'Побяржина Татьяна Павловна', 3, '+375 21 266-61-32', NULL),
(12, N'Кафедра экономики и информационных технологий Гомельского филиала', N'Устименко Оксана Викторовна', 4, NULL, NULL),
(13, N'Кафедра правоведения и социально-гуманитарных дисциплин Гомельского филиала', N'Климович Анна Александровна', 4, NULL, NULL),
(14, N'Кафедра иностранных языков и межкультурных коммуникаций Гомельского филиала', N'Данченко Анна Валентиновна', 4, NULL, NULL);

-- 5. Groups
INSERT INTO Groups (GroupID, GroupName, EducationForm, Coefficient, FacultyID, Speciality, EducationLevel)
VALUES
(1, N'2431 ПР', N'Очная', 1.0, 2, N'Правоведение', N'Бакалавриат'),
(2, N'2432 ПР', N'Очная', 1.0, 2, N'Правоведение', N'Бакалавриат'),
(3, N'2433 ПР', N'Очная', 1.0, 2, N'Правоведение', N'Бакалавриат'),
(4, N'2434 ПР', N'Очная', 1.0, 2, N'Правоведение', N'Бакалавриат'),
(5, N'2435 ПР', N'Очная', 1.0, 2, N'Правоведение', N'Бакалавриат'),
(6, N'2440 МП', N'Очная', 1.0, 2, N'Международное право', N'Бакалавриат'),
(7, N'2441 МП', N'Очная', 1.0, 2, N'Международное право', N'Бакалавриат'),
(8, N'2442 МП', N'Очная', 1.0, 2, N'Международное право', N'Бакалавриат'),
(9, N'2450 ЭП', N'Очная', 1.0, 2, N'Экономическое право', N'Бакалавриат'),
(10, N'2451 ЭП', N'Очная', 1.0, 2, N'Экономическое право', N'Бакалавриат'),
(11, N'2223 УИР', N'Очная', 1.0, 1, N'Управление информационными ресурсами', N'Бакалавриат');

-- 6. Students
INSERT INTO Students (StudentID, LastName, FirstName, MiddleName, GroupID, IsBudget, HasDormitory, BirthDate, MaritalStatus, Phone, Email)
VALUES
(1, N'Иванов', N'Иван', N'Иванович', 1, 1, 0, '2004-05-15', N'Холост', '+375 29 123-45-67', 'ivanov@mail.ru'),
(2, N'Петрова', N'Мария', N'Сергеевна', 1, 1, 1, '2003-03-22', N'Замужем', '+375 33 987-65-43', 'petrova@gmail.com'),
(3, N'Сидоров', N'Алексей', N'Николаевич', 2, 1, 1, '2003-07-10', N'Холост', '+375 25 555-44-33', 'sidorov@mail.ru'),
(4, N'Козлова', N'Елена', N'Викторовна', 2, 0, 0, '2004-01-18', N'Холост', '+375 29 777-88-99', 'kozlova@gmail.com');

-- 7. Professors
INSERT INTO Professors (ProfessorID, LastName, FirstName, MiddleName, TeachingExperience, DepartmentID, AcademicDegree, AcademicTitle, Phone, Email)
VALUES
(1, N'Дурович', N'Александр', N'Петрович', 15, 1, N'Доктор наук', N'Профессор', '+375 17 279-98-17', 'logistics@mitso.by'),
(2, N'Верниковская', N'Оксана', N'Васильевна', 20, 2, N'Кандидат наук', N'Доцент', '+375 17 279-98-17', NULL),
(3, N'Хорошко', N'Ольга', N'Болеславовна', 18, 3, N'Кандидат наук', N'Доцент', '+375 17 279-98-17', NULL),
(4, N'Скромблевич', N'Валерия', N'Болеславовна', 12, 4, N'Кандидат наук', N'Доцент', NULL, NULL);

-- 8. Units
INSERT INTO Units (UnitID, UnitName, AdministrationID, Address, Phone, Email)
VALUES
(1, N'Библиотека', 1, N'ул. Казинца 21/3, к.1', '+375 17 279-98-50', 'library@mitso.by'),
(2, N'Спортивный комплекс', 1, N'ул. Казинца 21/3, к.2', '+375 17 279-98-51', 'sport@mitso.by'),
(3, N'Общежитие №1', 1, N'ул. Казинца 21/3, к.3', '+375 17 279-98-52', 'dormitory@mitso.by');

-- 9. Subjects
INSERT INTO Subjects (SubjectID, SubjectName, Hours, DepartmentID)
VALUES
(1, N'Базы данных', 120, 1),
(2, N'Микроэкономика', 90, 2),
(3, N'Программирование', 150, 3),
(4, N'Английский язык', 100, 4),
(5, N'Философия', 80, 5),
(6, N'Менеджмент', 90, 6),
(7, N'Уголовное право', 120, 7),
(8, N'Гражданское право', 120, 8),
(9, N'Физическая культура', 60, 9);

-- 10. Exams
INSERT INTO Exams (ExamID, GroupID, SubjectID, ProfessorID, ExamDate, StartTime, EndTime, Room)
VALUES
(1, 1, 1, 1, '2023-12-20', '09:00', '11:00', N'Ауд. 310'),
(2, 2, 2, 2, '2023-12-21', '14:00', '16:00', N'Ауд. 205'),
(3, 1, 3, 3, '2023-12-22', '10:00', '12:00', N'Ауд. 105'),
(4, 2, 4, 4, '2023-12-23', '13:00', '15:00', N'Ауд. 210');

-- 11. Grades
INSERT INTO Grades (GradeID, StudentID, SubjectID, Grade, GradeDate)
VALUES
(1, 1, 1, 9, '2023-12-20'),
(2, 2, 1, 8, '2023-12-20'),
(3, 3, 2, 7, '2023-12-21'),
(4, 4, 2, 9, '2023-12-21'),
(5, 1, 3, 8, '2023-12-22'),
(6, 2, 3, 7, '2023-12-22');

-- 12. Scholarships
INSERT INTO Scholarships (ScholarshipID, ScholarshipType, MinAverageScore, MaxAverageScore, ScholarshipAmount)
VALUES
(1, N'Академическая', 8.0, 10.0, 120.00),
(2, N'Социальная', 0.0, NULL, 80.00),
(3, N'Повышенная', 9.0, 10.0, 150.00),
(4, N'Академическая', 7.0, 7.9, 100.00);

-- 13. StudentScholarships
INSERT INTO StudentScholarships (StudentScholarshipID, StudentID, ScholarshipID, StartDate, EndDate)
VALUES
(1, 1, 1, '2023-09-01', '2024-01-31'),
(2, 2, 2, '2023-09-01', NULL),
(3, 3, 1, '2023-09-01', '2024-01-31'),
(4, 4, 4, '2023-09-01', '2024-01-31');