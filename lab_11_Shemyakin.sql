use master;
go

if db_id(N'Lab11') is not null
	drop database Lab11;
go

create database Lab11 on
(
	name = Lab11data,
	filename = 'C:\SQL\Lab11data.mdf',
	size = 10,
	maxsize = unlimited,
	filegrowth = 5%
)
log on
(	
	name = Lab11log,
	filename = 'C:\SQL\Lab11log.ldf',
	size = 5MB,
	maxsize = 25MB,
	filegrowth = 5MB
)
go



use Lab11;
go


if OBJECT_ID(N'Student') is not null
	drop table Student;
go

if OBJECT_ID(N'Department') is not null
	drop table Department;
go

if OBJECT_ID(N'Subject') is not null
	drop table Subject;
go

if OBJECT_ID(N'Faculty') is not null
	drop table Faculty;
go

if OBJECT_ID(N'Teacher') is not null
	drop table Teacher;
go

if OBJECT_ID(N'StudentSubject') is not null
	drop table StudentSubject;
go

if OBJECT_ID(N'TeacherSubject') is not null
	drop table TeacherSubject;
go

if OBJECT_ID(N'dbo.CheckEmail') is not null
	drop function CheckEmail;
go

create function dbo.CheckEmail (@email nvarchar(256)) returns bit as
begin
	if @email like '%@%.%'
		return 1
	return 0
end;
go

create table Faculty
(
	FacultyID int identity (1, 1) primary key,
	FacultyName nvarchar(100) unique not null,
	headoffaculty nvarchar(150),
	deanery nvarchar(10)
);

create table Department
(
	DepartmentID int identity (1, 1) primary key,
	DepartmentName nvarchar(100) unique not null check (len(DepartmentName) > 0),
	code nvarchar(10) unique not null check (len(code) > 0),
	headofdepartment nvarchar(150) not null,
	audience nvarchar(10) not null,
	FacultyID int foreign key references Faculty(FacultyID)
	on delete cascade
);

if exists (select * from sys.indexes where name = 'DepartmentIndex' and object_id = object_id('Department'))
	drop index DepartmentIndex on Department;
go
create index DepartmentIndex on Department(DepartmentName, headofdepartment) include (code, audience);
go

create table Student
(
	passbook int identity (1, 1) primary key,
	name nvarchar(50) not null check (len(name) > 0),
	lastname nvarchar(50) not null check (len(lastname) > 0),
	middlename nvarchar(50),
	email nvarchar(256) unique not null check (len(email) > 0 and dbo.CheckEmail(email) = 1),
	phone nvarchar(15) not null,
	DepartmentID int foreign key references Department(DepartmentID)
	on delete cascade
)

if exists (select * from sys.indexes where name = 'StudentIndex' and object_id = object_id('Student'))
	drop index StudentIndex on Student;
go
create index StudentIndex on Student(lastname, name desc) include (middlename, email, phone);
go

create table Subject
(
	id uniqueidentifier primary key default(newid()),
	name nvarchar(100),
	hours int,
	marktype nvarchar(6) default 'зачет',
	description nvarchar(1000),
	DepartmentID int foreign key references Department(DepartmentID)
	on delete cascade
)

create table Teacher
(
	code int identity (1, 1) primary key,
	name nvarchar(50) not null check (len(name) > 0),
	lastname nvarchar(50) not null check (len(lastname) > 0),
	middlename nvarchar(50),
	email nvarchar(256) unique not null check (len(email) > 0 and dbo.CheckEmail(email) = 1),
	phone nvarchar(15) not null,
	DepartmentID int foreign key references Department(DepartmentID)
	on delete cascade
);

create table StudentSubject
(
    StudentID int foreign key references Student(passbook),
    SubjectID uniqueidentifier foreign key references Subject(id),
    primary key (StudentID, SubjectID),
);

create table TeacherSubject
(
    TeacherID int foreign key references Teacher(code),
    SubjectID uniqueidentifier foreign key references Subject(id),
    primary key (TeacherID, SubjectID)
);

if exists (select * from sys.indexes where name = 'TeacherIndex' and object_id = object_id('Teacher'))
	drop index TeacherIndex on Teacher;
go
create index TeacherIndex on Teacher(lastname, name desc) include (middlename, email, phone);
go

if OBJECT_ID(N'StudentView') is not null
	drop view StudentView;
go

create view StudentView as select
	S.name, S.lastname, S.middlename, S.email, S.phone, D.DepartmentID, D.DepartmentName, 
		D.code, D.headofdepartment, D.audience, F.FacultyID, F.FacultyName, F.headoffaculty, F.deanery from Student as S 
	join Department as D on D.DepartmentID = S.DepartmentID
	join Faculty as F on F.FacultyID = D.FacultyID
go

if OBJECT_ID(N'TRIG_STUDENT_UPDATE') is not null
	drop trigger TRIG_STUDENT_UPDATE;
go

if OBJECT_ID(N'TRIG_FACULTY_DELETE') is not null
	drop trigger TRIG_FACULTY_DELETE;
go

create trigger TRIG_FACULTY_DELETE on Faculty after delete as
begin
	throw 50002, 'Невозможно удалить факультет', 1;
	rollback;
end;
go

create trigger TRIG_STUDENT_UPDATE on Student after update as 
begin
	if exists (select * from inserted where len(lastname) < 3)
	begin
		throw 50001, 'Фамилия должна быть длиннее 2 символов', 1;
	end;
end;
go

insert into Faculty (FacultyName, headoffaculty, deanery) values
('Информатика и системы управления', 'Пролетарский А.В', '318ю'),
('Инженерный бизнес и менеджмент', 'Омельченко И.Н', '400ю'),
('Специальное машиностроение', 'Калугин В.Т', '200ю'),
('Машиностроительные технологии', 'Комшин А.С', '532т');
go

insert into Department (DepartmentName, code, headofdepartment, audience, FacultyID) values
('Прикладная математика и информатика', 'ИУ9', 'Иванов И.П','305ю', 1),
('Инновационное предпринимательство', 'ИБМ7', 'Песоцкий Ю.С', '401ю', 2),
('Многоцелевые гусеничные машины и мобильные роботы', 'СМ9', 'Горелов В.А', '250ю', 3);
go

insert into Student (lastname, name, middlename, email, phone, DepartmentID) values
('Иванов', 'Иван', 'Иванович', 'email1@gmail.com', '+79261111111', 1),
('Петров', 'Петр', 'Петрович', 'email2@gmail.com', '+79262222222', 1),
('Максимов', 'Максим', 'Максимович', 'email3@gmail.com', '+79263333333', 2),
('Артемов', 'Артем', 'Артемович', 'email4@gmail.com', '+79264444444', 2),
('Рустамов', 'Рустам', null, 'email5@gmail.com', '+79265555555', 3),
('Егоров', 'Егор', 'Егорьевич', 'email6@gmail.com', '+79266666666', 3);
go

insert into Subject(name, hours, marktype, description, DepartmentID) values
('Функциональный анализ', 120, 'оценка', 'Предмет1', 1),
('РПиРП', 60, 'зачет', 'Предмет2', 1),
('Финансовый анализ', 180, 'оценка', 'Предмет3', 2),
('Цифровое производство', 70, 'зачет', 'Предмет4', 2),
('Проектирование робототехники специального назначения', 150, 'оценка', 'Предмет5', 3),
('Инженерная геометрия', 60, 'зачет', 'Предмет6', 3);
go

insert into Teacher(lastname, name, middlename, email, phone, DepartmentID) values
('Белоусов', 'Григорий', 'Николаевич', 'email_iu9_1@gmail.com', '+79161111111', 1),
('Царев', 'Александр', 'Сергеевич', 'email_iu9_2@gmail.com', '+79162222222', 1),
('Толикова', 'Елена', 'Эдуардовна', 'email_ibm7_1@gmail.com', '+79163333333', 2),
('Сафонов', 'Сергей', 'Владимирович', 'email_ibm7_2@gmail.com', '+79164444444', 2),
('Корсунский', 'Владимир', 'Александрович', 'email_sm9_1@gmail.com', '+79165555555', 3),
('Гринин', 'Валерий', 'Алексеевич', 'email_sm9_2@gmail.com', '+79166666666', 3);
go


/*
select * from Faculty;
select * from Department;
select * from Student;
select * from Teacher;
select * from Subject;
go
*/


/*delete from Faculty where FacultyID = 3;
go*/


select * from StudentView

-- distinct
select distinct  hours as N'Различные часы' from Subject

-- Выбор, упорядочивание и именование полей
select passbook as Зачетка, name as Имя, lastname Фамилия, middlename as Отчество, email as "Электронная почта", phone as Телефон from Student

-- Соединение таблиц
-- inner join
select D.DepartmentID, D.DepartmentName, D.code, D.headofdepartment, D.audience, F.FacultyID, F.FacultyName, 
	F.headoffaculty, F.deanery from Department as D inner join Faculty as F on D.FacultyID = F.FacultyID

-- left join
select D.DepartmentID, D.DepartmentName, D.code, D.headofdepartment, D.audience, F.FacultyID, F.FacultyName, 
	F.headoffaculty, F.deanery from Department as D left join Faculty as F on D.FacultyID = F.FacultyID

-- right join
select D.DepartmentID, D.DepartmentName, D.code, D.headofdepartment, D.audience, F.FacultyID, F.FacultyName, 
	F.headoffaculty, F.deanery from Department as D right join Faculty as F on D.FacultyID = F.FacultyID

-- full outer join
select D.DepartmentID, D.DepartmentName, D.code, D.headofdepartment, D.audience, F.FacultyID, F.FacultyName, 
	F.headoffaculty, F.deanery from Department as D full outer join Faculty as F on D.FacultyID = F.FacultyID


-- Условия выбора записей
-- null
select * from Student where middlename is null
select * from Student where middlename is not null
-- like
select * from Teacher where email like 'email_iu9%'

-- between
select * from Subject where hours between 95 and 165

-- in
select * from Student where name in ('Артем', 'Иван')

--exists
select * from Faculty where exists (select * from Department where Department.FacultyID = FacultyID)

-- Сортировка записей
select * from Subject order by hours asc
select * from Subject order by hours desc

-- Группировка записей
-- count
select F.FacultyName, count(S.passbook) as N'Количество Студентов'
from Student S
join Department D on S.DepartmentID = D.DepartmentID
join Faculty F on D.FacultyID = F.FacultyID
group by F.FacultyName;

-- avg
select F.FacultyName, avg(Su.hours) as N'Среднее Количество Часов'
from Subject Su
join Department D on Su.DepartmentID = D.DepartmentID
join Faculty F on D.FacultyID = F.FacultyID
group by F.FacultyName;

-- sum
select F.FacultyName, sum(Su.hours) as N'Общее Количество Часов'
from Subject Su
join Department D on Su.DepartmentID = D.DepartmentID
join Faculty F on D.FacultyID = F.FacultyID
group by F.FacultyName;

-- min
select F.FacultyName, min(Su.hours) as N'Минимальное Количество Часов'
from Subject Su
join Department D on Su.DepartmentID = D.DepartmentID
join Faculty F on D.FacultyID = F.FacultyID
group by F.FacultyName having avg(Su.hours) > 100;

-- max
select F.FacultyName, max(Su.hours) as N'Максимальное Количество Часов'
from Subject Su
join Department D on Su.DepartmentID = D.DepartmentID
join Faculty F on D.FacultyID = F.FacultyID
group by F.FacultyName having sum(Su.hours) > 200;


-- union
select * from Student where passbook between 1 and 3 union
select * from Student where passbook between 3 and 5

-- union all
select * from Student where passbook between 1 and 3 union all
select * from Student where passbook between 3 and 5

-- except
select * from Student where passbook between 1 and 3 except
select * from Student where passbook between 3 and 5

--intersect
select * from Student where passbook between 1 and 3 intersect
select * from Student where passbook between 3 and 5

-- Вложенные запросы
select * from Subject where hours < (select hours from Subject where name = 'Функциональный анализ')



/*
delete from Department where DepartmentID = 3;
select * from Department;
select * from Student;
*/

-- update Student set lastname = 'Ко' where passbook = 1;
update Student set lastname = 'Александров' where passbook = 1;

select * from Student;
