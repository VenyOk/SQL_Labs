use master;
go

-- Task 1

if db_id(N'Lab5') is not null
drop database Lab5;
go

create database Lab5 on
(
	name = Lab5data,
	filename = 'C:\SQL\Lab5data.mdf',
	size = 10,
	maxsize = unlimited,
	filegrowth = 5%
)

log on
(
	name = Lab5log,
	filename = 'C:\SQL\Lab5log.ldf',
	size = 5MB,
	maxsize = 25MB,
	filegrowth = 5MB
)
go

-- Task 2
use Lab5;
go
if OBJECT_ID(N'Student') is not null
	drop table Student;
go

create table Student
(
	passbook INT primary key,
	name nvarchar(50) not null,
	lastname nvarchar(50) not null,
	middlename nvarchar(50) not null,
	phone nvarchar(15) not null,
	email nvarchar(255) unique not null
);
go

select * from Student;
go

-- Task 3

alter database Lab5
add filegroup NewFileGroup;
go

alter database Lab5
add file
(
	name = new_datafile,
	filename = 'C:\SQL\Lab5data.ndf',
	size = 5MB,
	maxsize = 25MB,
	filegrowth = 5MB
) to filegroup NewFileGroup
go


-- Task 4

alter database Lab5
modify filegroup NewFileGroup default;
go

-- Task 5

if OBJECT_ID(N'Teacher') is not null
	drop table Teacher;
go

create table Teacher
(
	teachercode INT primary key,
	name nvarchar(50) not null,
	lastname nvarchar(50) not null,
	middlename nvarchar(50) not null,
	phone nvarchar(12) not null,
	email nvarchar(80) unique not null
);
go

select * from Teacher;
go

-- Task 6

alter database Lab5
modify filegroup [primary] default;
go

select * into TeacherBackup from Teacher;
go

select * from TeacherBackup;
go

drop table Teacher

alter database Lab5
remove file new_datafile;
go

alter database Lab5
remove filegroup NewFileGroup;
go
-- Task 7

if SCHEMA_ID(N'UniSchema') is not null
	drop schema UniSchema;
go

create schema UniSchema;
go

alter schema UniSchema
	transfer TeacherBackup;
go

if OBJECT_ID(N'UniSchema.TeacherBackup') is not null
	drop table UniSchema.TeacherBackup;
go

drop schema UniSchema;
