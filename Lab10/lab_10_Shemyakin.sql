use master;
go


if db_id(N'Lab10') is not null
	drop database Lab10;
go

create database Lab10 on
(
	name = Lab10data,
	filename = 'C:\SQL\Lab10data.mdf',
	size = 10,
	maxsize = unlimited,
	filegrowth = 5%
)
log on
(	
	name = Lab10log,
	filename = 'C:\SQL\Lab10log.ldf',
	size = 5MB,
	maxsize = 25MB,
	filegrowth = 5MB
)
go

use Lab10;
go

if OBJECT_ID(N'Student') is not null
	drop table Student;
go

create table Student
(
	passbook int identity(1,1) primary key,
	name nvarchar(50) not null check (len(name) > 0),
	lastname nvarchar(50) not null check (len(lastname) > 0),
	middlename nvarchar(50),
	email nvarchar(256) not null check (len(email) > 0),
	phone nvarchar(15) not null
)

insert into Student (name, lastname, middlename, email, phone) values
('Ivan', 'Ivanov', 'Ivanovich', 'email1@gmail.com', '79261111111'),
('Petr', 'Petrov', 'Petrovich', 'email2@gmail.com', '79262222222'),
('Oleg', 'Olegov', 'Olegovich', 'email3@gmail.com', '79263333333'),
('Nikita', 'Nikitin', 'Nikitich', 'email4@gmail.com', '79264444444')
go

select * from Student;
