use master;
go

if db_id(N'Lab6') is not null
	drop database Lab6;
go

create database Lab6 on
(
	name = Lab6data,
	filename = 'C:\SQL\Lab6data.mdf',
	size = 10,
	maxsize = unlimited,
	filegrowth = 5%
)

log on
(
	name = Lab6log,
	filename = 'C:\SQL\Lab6log.ldf',
	size = 5MB,
	maxsize = 25MB,
	filegrowth = 5MB
)
go

-- Task 1
use Lab6;
go

if OBJECT_ID(N'Student') is not null
	drop table Student;
go

create table Student
(
	passbook int identity (1, 1) primary key,
	name nvarchar(50) not null check (len(name) > 0),
	lastname nvarchar(50) not null check (len(lastname) > 0),
	middlename nvarchar(50),
	email nvarchar(256) unique not null check (len(email) > 0),
	phone nvarchar(15) not null
)

insert into Student (name, lastname, middlename, email, phone) values
('Ivan', 'Ivanov', 'Ivanovich', 'email1@mail.ru', '+79261111111'),
('Petr', 'Petrov', 'Petrovich', 'email2@mail.ru', '+79262222222');
go
-- @@IDENTITY ограничена текущим сеансом
-- SCOPE_IDENTITY() ограничена текущим сеансом и областью действия
-- IDENT_CURRENT() не ограничена сеансом и облатсью действия но ограничена таблицей
select @@IDENTITY as Student_ID;
go
select SCOPE_IDENTITY() as STUDENT_ID_SCOPE;
go
select IDENT_CURRENT('Student') as Student_ID_CURRENT;
go
select * from Student;
go


insert into Student (name, lastname, middlename, email, phone) values
('Ivan', 'Ivanov', 'Ivanovich', 'email3@mail.ru', '+79263333333'),
('Petr', 'Petrov', 'Petrovich', 'email4@mail.ru', '+79264444444');
go
select @@IDENTITY as Student_ID;
go
select SCOPE_IDENTITY() as STUDENT_ID_SCOPE;
go
select IDENT_CURRENT('Student') as Student_ID_CURRENT;
go
select * from Student;
go
-- Task 3
if OBJECT_ID(N'Subject') is not null
	drop table Subject;
go


create table Subject
(
	id uniqueidentifier primary key default(newid()),
	name nvarchar(100),
	hours int,
	marktype nvarchar(6) default 'зачет',
	description nvarchar(1000)
)

insert into Subject (name, hours, description) values
('Логика и теория алгоритмов', 180, 'Решение РК + ДЗ'),
('Разработка параллельных и распределенных программ', 120, 'Сдача лабораторных работ');
select * from Subject;
go

-- Task 4

if OBJECT_ID(N'TeacherSequence') is not null
	drop sequence TeacherSequence;
go

create sequence TeacherSequence start with 1 increment by 1;
go

if OBJECT_ID(N'Teacher') is not null
	drop table Teacher;
go

create table Teacher
(
	code int primary key,
	name nvarchar(50) not null check (len(name) > 0),
	lastname nvarchar(50) not null check (len(lastname) > 0),
	middlename nvarchar(50),
	email nvarchar(256) unique not null check (len(email) > 0),
	phone nvarchar(15) not null
);
go

insert into Teacher (code, name, lastname, middlename, email, phone) values
(next value for TeacherSequence, 'Boris', 'Borisov', 'Borisovich', 'bbb@mail.ru', '+79263333333'),
(next value for TeacherSequence, 'Artem', 'Artemov', 'Artemovich', 'aaa@mail.ru', '+79264444444'),
(next value for TeacherSequence, 'Aleksandr', 'Aleksandrov', 'Aleksandrovich', 'aaa2@mail.ru', '+79265555555');
go

select * from Teacher;
go

-- Task 5
if OBJECT_ID(N'Faculty') is not null
	drop table Faculty;
go

if OBJECT_ID(N'Department') is not null
	drop table Department;
go

create table Faculty
(
	FacultyID int identity (1, 1) primary key,
	name nvarchar(100) unique not null,
	headoffaculty nvarchar(150),
	deanery nvarchar(10)
);
go
insert into Faculty (name, headoffaculty, deanery) values
('Информатика и ситемы управления', 'Пролетарский А.В', '318ю'),
('Инженерный бизнес и менеджмент', 'Омельченко И.Н', '419ю');
go

select * from Faculty;
go

create table Department
(
	DepartmentID int identity (1, 1) primary key,
	name nvarchar(100) unique not null check (len(name) > 0),
	code nvarchar(10) unique not null check (len(code) > 0),
	headofdepartment nvarchar(150) not null,
	audience nvarchar(10) not null,
	FacultyID int foreign key references Faculty(FacultyID)
	on delete set NULL,
	--on delete no action,
	--on delete set default,
	--on delete cascade,
);

insert into Department (name, code, headofdepartment, audience, FacultyID) values
('Теоретическая информатика и компьютерные технологии', 'ИУ9', 'Иванов И.П', '305ю', 1),
('Инновационное предпринимательство', 'ИБМ7', 'Песоцкий Ю.С', '414ю', 2);
go

select * from Department;
go

delete from	Faculty where FacultyID = 2;
go

select * from Faculty;
go

select * from Department;
go
