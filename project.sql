create table Classrooms
(
    classroomID int          not null
        constraint Classrooms_pk
            primary key,
    building    varchar(255) not null
        constraint validBuilding
            check ([building] like '[A-Z]-[0-9][0-9]'),
    room        varchar(255) not null
        constraint validRoom
            check ([room] like '[0-9].[0-9][0-9]'),
    placeLimit  int          not null
)
go

create table CoursesModules
(
    moduleID   int          not null
        constraint CoursesModules_pk
            primary key,
    moduleName varchar(255) not null
)
go

create table CurrencyExchange
(
    currencyID int            not null
        constraint CurrencyExchange_pk
            primary key,
    [from]     varchar(255)   not null,
    [to]       varchar(255)   not null,
    value      decimal(10, 2) not null
)
go

create table Studies
(
    studiesID    int           not null
        constraint Studies_pk
            primary key,
    name         varchar(255)  not null,
    type         varchar(255)  not null
        constraint checkStudiesType
            check ([type] = 'hybrydowe' OR [type] = 'niestacjonarne' OR [type] = 'stacjonarne'),
    studentLimit int           not null,
    examsCount   int default 0 not null
)
go

create table StudiesPractises
(
    practisesID   int          not null
        constraint StudiesPractises_pk
            primary key,
    practisesName varchar(255) not null,
    duration      int          not null
)
go

create table Teachers
(
    teacherID    int          not null
        constraint Teachers_pk
            primary key,
    firstName    varchar(255) not null,
    lastName     varchar(255) not null,
    teacherEmail varchar(255) not null
        constraint uniqueTeacherEmail
            unique
        constraint validTeacherEmail
            check ([teacherEmail] like '%@teacher.projekt.edu.pl'),
    phoneNumber  int          not null
        constraint uniqueTeacherPhoneNumber
            unique
        constraint validTeacherPhoneNumber
            check ([phoneNumber] like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
    title        varchar(255) not null
)
go

create table StudiesSubjects
(
    subjectID   int           not null
        constraint StudiesSubjects_pk
            primary key,
    teacherID   int           not null
        constraint StudiesSubjects_Teachers
            references Teachers,
    totalHours  int           not null,
    subjectName varchar(255)  not null,
    hasExam     bit default 0 not null
)
go

create table StudiesSylabus
(
    studiesID   int        not null
        constraint StudiesSylabus_Studies
            references Studies,
    subjectID   int        not null
        constraint StudiesSylabus_StudiesSubjects
            references StudiesSubjects,
    practisesID int
        constraint StudiesSylabus_StudiesPractices
            references StudiesPractises,
    semester    int        not null
        constraint validSemester
            check ([semester] >= 1 AND [semester] <= 10),
    validDate   varchar(9) not null
        constraint check_validDate
            check ([validDate] like '[1-2][0-9][0-9][0-9]/[1-2][0-9][0-9][0-9]'),
    sylabusID   int        not null
        constraint StudiesSylabus_pk
            primary key
)
go

create table Translators
(
    translatorID       int          not null
        constraint Translators_pk
            primary key,
    firstName          varchar(255) not null,
    lastName           varchar(255) not null,
    translatorEmail    varchar(255) not null
        constraint uniqueTranslatorEmail
            unique
        constraint validTranslatorEmail
            check ([translatorEmail] like '%@translator.projekt.edu.pl'),
    phoneNumber        int          not null
        constraint uniqueTranslatorPhoneNumber
            unique
        constraint validTranslatorPhoneNumber
            check ([phoneNumber] like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
    primaryLanguage    varchar(255),
    translatedLanguage varchar(255)
)
go

create table Courses
(
    courseID        int          not null
        constraint Courses_pk
            primary key,
    courseName      varchar(255) not null,
    price           money        not null,
    language        varchar(255) not null,
    paymentDeadline date         not null,
    moduleID        int          not null
        constraint Courses_CoursesModules_moduleID_fk
            references CoursesModules,
    teacherID       int          not null
        constraint Courses_Teachers_teacherID_fk
            references Teachers,
    type            varchar(255) not null,
    classroomID     int
        constraint Courses_Classrooms_classroomID_fk
            references Classrooms,
    recordedLink    varchar(255) not null,
    translatorID    int          not null
        constraint Courses_Translators_translatorID_fk
            references Translators,
    date            datetime     not null
)
go

create table Lessons
(
    lessonID     int          not null
        constraint Lessons_pk
            primary key,
    subjectID    int          not null
        constraint Lessons_StudiesSubjects
            references StudiesSubjects,
    translatorID int          not null
        constraint Lessons_Translators
            references Translators,
    classroomID  int          not null
        constraint Lessons_Classrooms
            references Classrooms,
    date         datetime     not null
        constraint validLessonDate
            check (CONVERT([varchar], [date], 120) = [date]),
    language     varchar(255) not null
)
go

create table SingleLessons
(
    lessonID        int   not null
        constraint SingleLessons_Lessons_lessonID_fk
            references Lessons,
    userID          int   not null,
    price           money not null,
    paymentDeadline date  not null,
    singleLessonID  int   not null
        constraint SingleLessons_pk
            primary key
)
go

create table Users
(
    userID      int                         not null
        constraint Users_pk
            primary key,
    firstName   varchar(255)                not null,
    lastName    varchar(255)                not null,
    email       varchar(255)                not null
        constraint UniqueEmail
            unique
        constraint ValidEmail
            check ([email] like '%@%'),
    address     varchar(255)                not null,
    phoneNumber int                         not null
        constraint UniquePhoneNumber
            unique
        constraint validPhoneNumber
            check ([phoneNumber] like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
    userType    varchar(255) default 'user' not null
)
go

create table CoursesPresence
(
    presenceID      int  not null
        constraint CoursesPresence_pk
            primary key,
    courseID        int  not null
        constraint CoursesPresence_Courses
            references Courses,
    moduleID        int  not null
        constraint CoursesPresence_CoursesModules
            references CoursesModules,
    userID          int  not null
        constraint CoursesPresence_Users
            references Users,
    wasPresent      bit  not null,
    watchedRecord   bit,
    certificateLink varchar(255),
    meetingDate     date not null,
    hasPaid         bit  not null
)
go

create table Students
(
    studentID    int          not null
        constraint Students_pk
            primary key,
    userID       int          not null
        constraint Students_Users
            references Users,
    studiesID    int          not null
        constraint Students_Studies
            references Studies,
    studentEmail varchar(255) not null
        constraint uniqueStudentEmail
            unique
        constraint validStudentEmail
            check ([studentEmail] like '%@student.projekt.edu.pl')
)
go

create table Attendance
(
    lessonID             int not null
        constraint Attendance_Lessons
            references Lessons,
    studentID            int not null
        constraint Attendance_Students
            references Students,
    wasPresent           bit not null,
    completedInOtherTerm bit not null,
    wasJustificated      bit not null,
    attendenceID         int not null
        constraint Attendance_pk
            primary key
)
go

create table StudentSchedule
(
    studentID   int      not null
        constraint StudentSchedule_Students_studentID_fk
            references Students,
    subjectID   int      not null
        constraint StudentSchedule_StudiesSubjects
            references StudiesSubjects,
    classroomID int      not null
        constraint StudentSchedule_Classrooms
            references Classrooms,
    date        datetime not null
        constraint validScheduleDate
            check (CONVERT([varchar], [date], 120) = [date]),
    scheduleID  int      not null
        constraint StudentSchedule_pk
            primary key
)
go

create table StudiesFinalGrades
(
    gradesID  int   not null
        constraint StudiesFinalGrades_pk
            primary key,
    subjectID int   not null
        constraint StudiesFinalGrades_StudiesSubjects_subjectID_fk
            references StudiesSubjects,
    studentID int   not null
        constraint StudiesFinalGrades_Students_studentID_fk
            references Students,
    grade     float not null
        constraint checkGrade
            check ([grade] = 5 OR [grade] = 4.5 OR [grade] = 4 OR [grade] = 3.5 OR [grade] = 3 OR [grade] = 2)
)
go

create table Webinars
(
    webinarID       int          not null
        constraint Webinars_pk
            primary key,
    teacherID       int          not null
        constraint Webinars_Teachers
            references Teachers,
    translatorID    int          not null
        constraint Webinars_Translators
            references Translators,
    title           varchar(255) not null,
    date            datetime     not null
        constraint check_date
            check (CONVERT([varchar], [date], 120) = [date]),
    price           money        not null
        constraint check_price
            check ([price] >= 0 AND [price] % 0.01 = 0),
    meetLink        varchar(255) not null
        constraint uniqueLink
            unique,
    language        varchar(255) not null,
    paymentDeadline date         not null
)
go

create table PaymentHistory
(
    paymentID      int   not null
        constraint PaymentHistory_pk
            primary key,
    userID         int   not null
        constraint PaymentHistory_Users
            references Users,
    courseID       int
        constraint PaymentHistory_Courses
            references Courses,
    webinarID      int
        constraint PaymentHistory_Webinars
            references Webinars,
    price          money not null,
    isPaid         bit   not null,
    paymentDate    date,
    singleLessonID int
        constraint PaymentHistory_SingleLessons_singleLessonID_fk
            references SingleLessons,
    constraint checkAtLeastOneNotNull
        check ([singleLessonID] IS NOT NULL OR [courseID] IS NOT NULL OR [webinarID] IS NOT NULL)
)
go

create table WebinarsHistory
(
    webinarID    int          not null
        constraint WebinarsHistory_pk
            primary key,
    teacherID    int          not null
        constraint WebinarsHistory_Teachers
            references Teachers,
    title        varchar(255) not null,
    price        money        not null
        constraint check_WebinarHistoryPrice
            check ([price] >= 0 AND [price] % 0.01 = 0),
    date         date         not null
        constraint check_WebinarHistoryDate
            check (CONVERT([varchar], [date], 120) = [date]),
    recordedLink varchar(255) not null
        constraint uniqueWebinarHistoryLink
            unique
)
go

create table WebinarsPresence
(
    webinarPresenceID int not null
        constraint WebinarsPresence_pk
            primary key,
    webinarID         int not null
        constraint WebinarsPresence_WebinarsHistory_webinarID_fk
            references WebinarsHistory,
    userID            int not null
        constraint WebinarsPresence_Users_userID_fk
            references Users,
    certificateLink   varchar(255),
    wasPresent        bit not null
)
go

CREATE VIEW AllCoursesView AS
SELECT
   c.courseID,
   c.courseName AS 'Course Name',
   cm.moduleName AS 'Module Name',
   c.type AS 'Type',
   c.recordedLink AS 'Recorded Link',
   c.language AS 'Course Language',
   t.firstName + ' ' + t.lastName AS 'Teacher',
   tr.firstName + ' ' + tr.lastName AS 'Translator',
   c.price AS 'Course Price',
   c.paymentDeadline AS 'Payment Deadline',
   CASE
       WHEN c.type = 'on-line synchroniczne' THEN c.recordedLink
       WHEN c.type = 'on-line asynchroniczne' THEN c.recordedLink
       WHEN c.type = 'stacjonarne' THEN c.classroomID
       WHEN c.type = 'hybrydowe' THEN
           CASE
               WHEN c.recordedLink IS NOT NULL THEN c.recordedLink
               ELSE c.classroomID
           END
   END AS 'Recorded Link and room',
   c.date AS 'Date'
FROM
   Courses c
LEFT JOIN
   CoursesModules cm ON c.moduleID = cm.moduleID
LEFT JOIN
   Teachers t ON c.teacherID = t.teacherID
LEFT JOIN
   Translators tr ON c.translatorID = tr.translatorID
go

CREATE VIEW DebtorsView AS
SELECT
   p.userID AS 'User ID',
   SUM(p.price) AS 'Total Unpaid Amount',
   CASE
       WHEN p.courseID IS NOT NULL THEN 'Course'
       WHEN p.webinarID IS NOT NULL THEN 'Webinar'
       WHEN p.singleLessonID IS NOT NULL THEN 'Lesson'
   END AS 'Type',
   p.price AS 'Amount',
   p.paymentDate AS 'Final Payment Date',
   DATEDIFF(DAY, p.paymentDate, GETDATE()) AS 'Days Past Deadline'
FROM
   PaymentHistory p
WHERE
   p.isPaid = 0
GROUP BY
   p.userID, CASE
                   WHEN p.courseID IS NOT NULL THEN 'Course'
                   WHEN p.webinarID IS NOT NULL THEN 'Webinar'
                   WHEN p.singleLessonID IS NOT NULL THEN 'Lesson'
               END, p.price, p.paymentDate
go

CREATE VIEW EventsCalendarView AS
SELECT 'Webinar' AS 'Event Type', w.title AS 'Event Name', w.date AS 'Event Date', NULL AS 'Event Location', w.meetLink AS 'Registration Link'
FROM Webinars w
WHERE CONVERT(DATE, w.date) = CONVERT(DATE, GETDATE())


UNION ALL


SELECT 'Paid Lesson' AS 'Event Type', ss.subjectName  AS 'Event Name', l.date AS 'Event Date', cl.building + ' ' + cl.room 'Event Location', NULL AS 'Registration Link'
FROM SingleLessons sl
JOIN Lessons l ON sl.lessonID = l.lessonID
JOIN StudiesSubjects ss ON l.subjectID = ss.subjectID
JOIN Classrooms cl ON l.classroomID = cl.classroomID
WHERE CONVERT(DATE, l.date) = CONVERT(DATE, GETDATE())


UNION ALL


SELECT 'Stationary Course' AS 'Event Type', c.courseName AS 'Event Name', c.date AS 'Event Date', cl.building + ' ' + cl.room AS 'Event Location', c.recordedLink AS 'Registration Link'
FROM Courses c
JOIN CoursesModules cm ON c.moduleID = cm.moduleID
LEFT JOIN Classrooms cl ON c.classroomID = cl.classroomID
WHERE CONVERT(DATE, c.date) = CONVERT(DATE, GETDATE())
go

CREATE VIEW StudentAttendanceStats AS
SELECT
   S.studentID,
   S.userID,
   S.studiesID,
   S.studentEmail,
   ROUND(CAST(SUM(IIF(A.wasPresent = 1, 1, 0)) * 100.0 / COUNT(A.lessonID) AS DECIMAL(5,2)), 2) AS 'CumulativeAttendancePercentage',
   ROUND(CAST(SUM(IIF(A.wasPresent = 1, 1, 0)) * 100.0 / NULLIF(COUNT(DISTINCT S.studentID), 0) - AVG(IIF(A.wasPresent = 1, 1, 0)) * 100.0 AS DECIMAL(5,2)), 2) AS 'DeviationFromDepartmentAverage',
   SUM(IIF(A.wasPresent = 0, 1, 0)) AS 'TotalAbsences',
   SUM(IIF(A.wasPresent = 0 AND (A.completedInOtherTerm = 1 OR A.wasJustificated = 1), 1, 0)) AS 'ExcusedAbsences',
   SUM(IIF(A.wasPresent = 0 AND A.completedInOtherTerm = 0 AND A.wasJustificated = 0, 1, 0)) AS 'UnexcusedAbsences'
FROM
   Students S
LEFT JOIN
   Attendance A ON S.studentID = A.studentID
GROUP BY
   S.studentID, S.userID, S.studiesID, S.studentEmail
go

CREATE VIEW SyllabusView AS
SELECT
   S.studiesID,
   S.name AS 'NazwaKierunku',
   S.type AS 'TypStudiow',
   S.studentLimit AS 'LimitMiejsc',
   SS.validDate AS 'Rocznik',
   SP.practisesName AS 'NazwaPraktyk',
   SP.duration AS 'DlugoscTrwania',
   SB.subjectName AS 'NazwaPrzedmiotu',
   SS.semester AS 'Semestr',
   T.lastName AS 'NauczycielProwadzacy'
FROM
   Studies S
JOIN
   StudiesSylabus SS ON S.studiesID = SS.studiesID
LEFT JOIN
   StudiesPractises SP ON SS.practisesID = SP.practisesID
LEFT JOIN
   StudiesSubjects SB ON SS.subjectID = SB.subjectID
LEFT JOIN
   Teachers T ON SB.teacherID = T.teacherID
go

CREATE VIEW UserFutureWebinarsView AS
SELECT
   webinarID,
   AllWebinars.title AS 'Webinar name',
   date AS 'Date',
   Teachers.lastName AS 'Teacher',
   Translators.lastName AS 'Translator',
   price AS 'Price',
   ISNULL(meetLink, '') AS 'meet link'
FROM
   (SELECT * FROM Webinars WHERE date >= GETDATE()) AS AllWebinars
JOIN
   Teachers ON AllWebinars.teacherID = Teachers.teacherID
JOIN
   Translators ON AllWebinars.translatorID = Translators.translatorID
go

CREATE VIEW UserHistoryWebinarsView AS
SELECT
   webinarID,
   HistoryWebinars.title AS 'Webinar name',
   date AS 'Date',
   Teachers.lastName AS 'Teacher',
   price AS 'Price',
   ISNULL(recordedLink, '') AS 'recorded link'
FROM
   (SELECT * FROM WebinarsHistory WHERE date <= GETDATE()) AS HistoryWebinars
JOIN
   Teachers ON HistoryWebinars.teacherID = Teachers.teacherID
go

CREATE PROCEDURE AddClassroom
(
   @building varchar(255),
   @room varchar(255),
   @placeLimit int
)
AS
BEGIN
   SET NOCOUNT ON
   BEGIN TRY
   IF EXISTS(
       SELECT *
       FROM Classrooms
       WHERE @building = building
       AND @room = room
   )
   BEGIN
       ;
       THROW 52000, N'Classroom is already in database', 1
   END
   DECLARE @classroomID INT
   SELECT @classroomID = ISNULL(MAX(classroomID), 0) + 1
   FROM Classrooms
   INSERT INTO Classrooms(classroomID, building, room, placeLimit)
   VALUES (@classroomID, @building, @room, @placeLimit)
   END TRY
BEGIN CATCH
DECLARE @msg nvarchar(2048)
=N'Error adding Classroom: ' + ERROR_MESSAGE();
THROW 52000, @msg, 1
END CATCH
END
go

CREATE PROCEDURE AddCourse
  @courseName VARCHAR(255),
  @price MONEY,
  @language VARCHAR(255),
  @paymentDeadline DATE,
  @moduleName VARCHAR(255),
  @teacherID INT,
  @translatorID INT,
  @classroomID INT,
  @type VARCHAR(255),
  @recordedLink VARCHAR(255),
  @date DATE
AS
BEGIN
  DECLARE @NewCourseID INT
  DECLARE @NewModuleID INT
    SELECT @NewModuleID = moduleID
    FROM CoursesModules
    WHERE moduleName = @moduleName
    IF @NewModuleID IS NULL
        BEGIN
            SELECT @NewModuleID = ISNULL(MAX(moduleID), 0) + 1 FROM CoursesModules
            INSERT INTO CoursesModules (moduleID, moduleName)
            VALUES (@NewModuleID, @moduleName)
        END
    SELECT @NewCourseID = ISNULL(MAX(courseID), 0) + 1 FROM Courses
        INSERT INTO Courses (courseID, courseName, price, language, paymentDeadline, moduleID, teacherID, type, classroomID, recordedLink, translatorID, date)
        VALUES (@NewCourseID, @courseName, @price, @language, @paymentDeadline, @NewModuleID, @teacherID, @type, @classroomID, @recordedLink, @translatorID, @date)
END
go

CREATE PROCEDURE AddCoursePresence
    @courseID int,
    @userID int,
    @wasPresent bit,
    @watchedRecord bit,
    @certificateLink varchar(255),
    @hasPaid bit
AS
BEGIN
    DECLARE @moduleID int
    SELECT @moduleID = CoursesModules.moduleID
    FROM CoursesModules
    INNER JOIN Courses ON Courses.moduleID = CoursesModules.moduleID
    WHERE courseID = @courseID
    DECLARE @date date
    SELECT @date = date
    FROM Courses
    WHERE courseID = @courseID
    DECLARE @PresenceID int
    BEGIN
        SELECT @PresenceID = ISNULL(MAX(presenceID), 0) + 1 FROM CoursesPresence
        INSERT INTO CoursesPresence (presenceID, courseID, moduleID, userID, wasPresent, watchedRecord, certificateLink, meetingDate, hasPaid)
        VALUES (@PresenceID, @courseID, @moduleID, @userID, @wasPresent, @watchedRecord, @certificateLink, @date, @hasPaid)
    END
END
go

CREATE PROCEDURE AddGrade
(
  @subjectID int,
  @studentID int,
  @grade float
)
AS
BEGIN
  SET NOCOUNT ON
  BEGIN TRY
  IF EXISTS(
      SELECT *
      FROM StudiesFinalGrades
      WHERE @studentID = studentID
      AND @subjectID = subjectID
  )
  BEGIN
      ;
      THROW 52000, N'Grade is already in database', 1
  END
  DECLARE @gradesID INT
  SELECT @gradesID = ISNULL(MAX(gradesID), 0) + 1
  FROM StudiesFinalGrades
  INSERT INTO StudiesFinalGrades(gradesID, subjectID, studentID, grade)
  VALUES (@gradesID, @subjectID, @studentID, @grade)
  END TRY
BEGIN CATCH
DECLARE @msg nvarchar(2048)
=N'Error adding Grade: ' + ERROR_MESSAGE();
THROW 52000, @msg, 1
END CATCH
END
go

CREATE PROCEDURE AddLesson
    @subjectID int,
    @translatorID int,
    @classroomID int,
    @date date,
    @language varchar(255)
AS
BEGIN
    DECLARE @lessonID int
    BEGIN
        SELECT @lessonID = ISNULL(MAX(lessonID), 0) + 1 FROM Lessons
        INSERT INTO Lessons (lessonID, subjectID, translatorID, classroomID, date, language)
        VALUES (@lessonID, @subjectID, @translatorID, @classroomID, @date, @language)
    END
END
go

CREATE PROCEDURE AddLessonPresence
    @lessonID int,
    @studentID int,
    @wasPresent bit,
    @completedInOtherTerm bit,
    @wasJustificated bit
AS
BEGIN
    DECLARE @attendanceID int
    BEGIN
        SELECT @attendanceID = ISNULL(MAX(attendenceID), 0) + 1 FROM Attendance
        INSERT INTO Attendance (attendenceID, lessonID, studentID, wasPresent, completedInOtherTerm, wasJustificated)
        VALUES (@attendanceID, @lessonID, @studentID, @wasPresent, @completedInOtherTerm, @wasJustificated)
    END
END
go

CREATE PROCEDURE AddPayment
    @userID int,
    @courseID int,
    @webinarID int,
    @singleLessonID int,
    @price money,
    @isPaid bit,
    @paymentDate date
AS
BEGIN
    DECLARE @paymentID int
    BEGIN
        SELECT @paymentID = ISNULL(MAX(paymentID), 0) + 1 FROM PaymentHistory
        INSERT INTO PaymentHistory (paymentID, userID, courseID, webinarID, singleLessonID, price, isPaid, paymentDate)
        VALUES (@paymentID, @userID, @courseID, @webinarID, @singleLessonID, @price, @isPaid, @paymentDate)
    END
END
go

CREATE PROCEDURE AddPractise
(
   @practisesName varchar(255),
   @duration INT
)
AS
BEGIN
   SET NOCOUNT ON
   BEGIN TRY
   IF EXISTS(
       SELECT *
       FROM StudiesPractises
       WHERE @practisesName = practisesName
   )
   BEGIN
       ;
       THROW 52000, N'Practise is already in database', 1
   END
   DECLARE @practisesID INT
   SELECT @practisesID = ISNULL(MAX(practisesID), 0) + 1
   FROM StudiesPractises
   INSERT INTO StudiesPractises(practisesID, practisesName, duration)
   VALUES (@practisesID, @practisesName, @duration)
   END TRY
BEGIN CATCH
DECLARE @msg nvarchar(2048)
=N'Error adding Practise: ' + ERROR_MESSAGE();
THROW 52000, @msg, 1
END CATCH
END
go

CREATE PROCEDURE AddSingleLesson
    @lessonID int,
    @userID int,
    @price money,
    @paymentDeadline date
AS
BEGIN
    DECLARE @singleLessonID int
    BEGIN
        SELECT @singleLessonID = ISNULL(MAX(singleLessonID), 0) + 1 FROM SingleLessons
        INSERT INTO SingleLessons (singleLessonID, lessonID, userID, price, paymentDeadline)
        VALUES (@singleLessonID, @lessonID, @userID, @price, @paymentDeadline)
    END
END
go

CREATE PROCEDURE AddStudies
(
   @name varchar(255),
   @type varchar(255),
   @studentLimit int
)
AS
BEGIN
   SET NOCOUNT ON
   BEGIN TRY
   IF EXISTS(
       SELECT *
       FROM Studies
       WHERE @name = name
       AND @type = type
   )
   BEGIN
       ;
       THROW 52000, N'Studies are already in database', 1
   END
   DECLARE @studiesID INT
   SELECT @studiesID = ISNULL(MAX(studiesID), 0) + 1
   FROM Studies
   INSERT INTO Studies(studiesID, name, type, studentLimit)
   VALUES (@studiesID, @name, @type, @studentLimit)
   END TRY
BEGIN CATCH
DECLARE @msg nvarchar(2048)
=N'Error adding Studies: ' + ERROR_MESSAGE();
THROW 52000, @msg, 1
END CATCH
END
go

CREATE PROCEDURE AddStudiesSubject
    @teacherID int,
    @totalHours int,
    @subjectName varchar(255),
    @hasExam bit
AS
BEGIN
    DECLARE @subjectID int
    BEGIN
        SELECT @subjectID = ISNULL(MAX(subjectID), 0) + 1 FROM StudiesSubjects
        INSERT INTO StudiesSubjects (subjectID, teacherID, totalHours, subjectName, hasExam)
        VALUES (@subjectID, @teacherID, @totalHours, @subjectName, @hasExam)
    END
END
go

CREATE PROCEDURE AddTeacher (
    @firstName varchar(255),
    @lastName varchar(255),
    @email varchar(255),
    @phoneNumber int,
    @title varchar(255)
)
AS
BEGIN
    SET NOCOUNT ON
    BEGIN TRY
    IF EXISTS(
        SELECT *
        FROM Teachers
        WHERE @firstName = firstName
        AND @lastName = lastName
        AND @email = email
        AND @phoneNumber = phoneNumber
        AND @title = title
    )
    BEGIN
        ;
        THROW 52000, N'Teacher is already in database', 1
    END
    DECLARE @teacherID INT
    SELECT @teacherID = ISNULL(MAX(teacherID), 0) + 1
    FROM Teachers
    INSERT INTO Teachers(teacherID,firstName,lastName,email,phoneNumber,title)
    VALUES (@teacherID,@firstName,@lastName,@email,@phoneNumber,@title)
    END TRY
BEGIN CATCH
DECLARE @msg nvarchar(2048)
=N'Error adding Teacher: ' + ERROR_MESSAGE();
THROW 52000, @msg, 1
END CATCH
END
go

CREATE PROCEDURE AddToSylabus
    @studiesName varchar(255),
    @studiesType varchar(255),
    @subjectName varchar(255),
    @practisesName varchar(255),
    @semester int,
    @startDate date
AS
    BEGIN
    DECLARE @sylabusID int
    DECLARE @studiesID int
    DECLARE @subjectID int
    DECLARE @practisesID int

    SELECT @studiesID = studiesID
    FROM Studies
    WHERE name = @studiesName
      AND type = @studiesType

    SELECT @subjectID = subjectID
    FROM StudiesSubjects
    WHERE subjectName = @subjectName

    SELECT @practisesID = practisesID
    FROM StudiesPractises
    WHERE practisesName = @practisesName

    SELECT @sylabusID = ISNULL(MAX(sylabusID), 0) + 1
    FROM StudiesSylabus
    INSERT INTO StudiesSylabus (studiesID, subjectID, practisesID, semester, year, sylabusID)
    VALUES (@studiesID, @subjectID, @practisesID, @semester, @startDate, @sylabusID)
END
go

CREATE PROCEDURE AddTranslator
(
   @firstName varchar(255),
   @lastName varchar(255),
   @email varchar(255),
   @phoneNumber int
)
AS
BEGIN
   SET NOCOUNT ON
   BEGIN TRY
   IF EXISTS(
       SELECT *
       FROM Translators
       WHERE @firstName = firstName
        AND @lastName = lastName
        AND @email = email
        AND @phoneNumber = phoneNumber
   )
   BEGIN
       ;
       THROW 52000, N'Translator is already in database', 1
   END
   DECLARE @translatorID INT
   SELECT @translatorID = ISNULL(MAX(translatorID), 0) + 1
   FROM Translators
   INSERT INTO Translators(translatorID, firstName, lastName, email, phoneNumber)
   VALUES (@translatorID, @firstName, @lastName, @email, @phoneNumber)
   END TRY
BEGIN CATCH
DECLARE @msg nvarchar(2048)
=N'Error adding Translator: ' + ERROR_MESSAGE();
THROW 52000, @msg, 1
END CATCH
END
go

CREATE PROCEDURE AddUser
(
   @firstName VARCHAR(255),
   @lastName VARCHAR(255),
   @email VARCHAR(255),
   @address VARCHAR(255),
   @phoneNumber INT
)
AS
BEGIN
   SET NOCOUNT ON
   BEGIN TRY
   IF EXISTS(
       SELECT *
       FROM Users
       WHERE @firstName = firstName
       AND @lastName = lastName
       AND @email = email
       AND @address = address
       AND @phoneNumber = phoneNumber
   )
   BEGIN
       ;
       THROW 52000, N'User is already in database', 1
   END
   DECLARE @userID INT
   SELECT @userID = ISNULL(MAX(userID), 0) + 1
   FROM Users
   INSERT INTO Users(userID, firstName, lastName, email, address, phoneNumber)
   VALUES (@userID, @firstName, @lastName, @email, @address, @phoneNumber)
   END TRY
BEGIN CATCH
DECLARE @msg nvarchar(2048)
=N'Error adding User: ' + ERROR_MESSAGE();
THROW 52000, @msg, 1
END CATCH
END
go

CREATE PROCEDURE AddWebinar
(
    @teacherID int,
    @translatorID int,
    @title varchar(255),
    @date date,
    @price money,
    @meetLink varchar(255),
    @language varchar(255),
    @paymentDeadline date
)
AS
BEGIN
  SET NOCOUNT ON
  BEGIN TRY
  IF EXISTS(
      SELECT *
      FROM Webinars
      WHERE @title = title
       AND @date = date
  )
  BEGIN
      ;
      THROW 52000, N'Webinar is already in database', 1
  END
  DECLARE @webinarID INT
  SELECT @webinarID = ISNULL(MAX(webinarID), 0) + 1
  FROM Webinars
  INSERT INTO Webinars(webinarID, teacherID, translatorID, title, date, price, meetLink, language, paymentDeadline)
  VALUES (@webinarID, @teacherID, @translatorID, @title, @date, @price, @meetLink, @language, @paymentDeadline)
  END TRY
BEGIN CATCH
DECLARE @msg nvarchar(2048)
=N'Error adding Webinar: ' + ERROR_MESSAGE();
THROW 52000, @msg, 1
END CATCH
END
go

CREATE PROCEDURE AddWebinarPresence
    @webinarID int,
    @userID int,
    @certificateLink varchar(255),
    @wasPresent bit
AS
BEGIN
    DECLARE @webinarPresenceID int
    BEGIN
        SELECT @webinarPresenceID = ISNULL(MAX(webinarpresenceID), 0) + 1 FROM WebinarsPresence
        INSERT INTO WebinarsPresence (webinarPresenceID, webinarID, userID, certificateLink, wasPresent)
        VALUES (@webinarPresenceID, @webinarID, @userID, @certificateLink, @wasPresent)
    END
END
go

CREATE PROCEDURE ModifyPermission
    @firstName varchar(255),
    @lastName varchar(255),
    @email varchar(255),
    @newPermission varchar(255)
AS
BEGIN
    SET NOCOUNT ON
    UPDATE Users
    SET userType = @newPermission
    WHERE FirstName = @firstName AND LastName = @lastName AND Email = @email
END
go


