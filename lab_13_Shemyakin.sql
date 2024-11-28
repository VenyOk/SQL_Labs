use master;
go

if db_id(N'Lab13Db1') is not null
	drop database Lab13Db1;
go

if db_id(N'Lab13Db2') is not null
	drop database Lab13Db2;
go

create database Lab13Db1 on
(
	name = Lab13Db1data,
	filename = 'C:\SQL\Lab13Db1data.mdf',
	size = 10,
	maxsize = unlimited,
	filegrowth = 5%
)
log on
(
	name = Lab13Db1log,
	filename = 'C:\SQL\Lab13Db1log.ldf',
	size = 5MB,
	maxsize = 25MB,
	filegrowth = 5MB
)
go

create database Lab13Db2 on
(
	name = Lab13Db2data,
	filename = 'C:\SQL\Lab13Db2data.mdf',
	size = 10,
	maxsize = unlimited,
	filegrowth = 5%
)
log on
(
	name = Lab13Db2log,
	filename = 'C:\SQL\Lab13Db2log.ldf',
	size = 5MB,
	maxsize = 25MB,
	filegrowth = 5MB
)
go

use Lab13Db1;
go

if OBJECT_ID(N'Student') is not null
	drop table Student;
go

create table Student
(
	passbook int not null primary key check (passbook <= 4),
	name nvarchar(50) not null check (len(name) > 0),
	lastname nvarchar(50) not null check (len(lastname) > 0),
	middlename nvarchar(50),
	email nvarchar(256) not null check (len(email) > 0),
	phone nvarchar(15) not null
)
go

use Lab13Db2;
go

if OBJECT_ID(N'Student') is not null
	drop table Student;
go

create table Student
(
	passbook int not null primary key check (passbook > 4),
	name nvarchar(50) not null check (len(name) > 0),
	lastname nvarchar(50) not null check (len(lastname) > 0),
	middlename nvarchar(50),
	email nvarchar(256) not null check (len(email) > 0),
	phone nvarchar(15) not null
)
go

use Lab13Db1;
go

if object_id(N'StudentView') is not null
	drop view StudentView;
go

create view StudentView as
	select * from Lab13Db1.dbo.Student
	union all
	select * from Lab13Db2.dbo.Student;
go

insert into StudentView (passbook, name, lastname, middlename, email, phone) values
(1, 'Ivan', 'Ivanov', 'Ivanovich', 'email1@gmail.com', '79261111111'),
(2, 'Petr', 'Petrov', 'Petrovich', 'email2@gmail.com', '79262222222'),
(3, 'Oleg', 'Olegov', 'Olegovich', 'email3@gmail.com', '79263333333'),
(5, 'Nikita', 'Nikitin', 'Nikitich', 'email4@gmail.com', '79264444444'),
(6, 'Semen', 'Semenov', 'Semenovich', 'email5@gmail.com', '79265555555');
go

select * from StudentView order by passbook;
go

select * from Lab13Db1.dbo.Student;
select * from Lab13Db2.dbo.Student;
go

update StudentView set email = 'email6@gmail.com' where passbook = 3;
update StudentView set email = 'email7@gmail.com' where passbook = 5;
go

select * from Lab13Db1.dbo.Student;
select * from Lab13Db2.dbo.Student;
go

delete from StudentView where passbook = 5;
go

delete from StudentView where passbook = 3;
go

select * from Lab13Db1.dbo.Student;
select * from Lab13Db2.dbo.Student;
go

update StudentView set passbook = 3 where passbook = 6;
go

select * from Lab13Db1.dbo.Student;
select * from Lab13Db2.dbo.Student;

update StudentView set passbook = 5 where passbook = 1;
go

select * from Lab13Db1.dbo.Student;
select * from Lab13Db2.dbo.Student;