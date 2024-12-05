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
	marktype nvarchar(6) default '�����',
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
	throw 50002, '���������� ������� ���������', 1;
	rollback;
end;
go

create trigger TRIG_STUDENT_UPDATE on Student after update as 
begin
	if exists (select * from inserted where len(lastname) < 3)
	begin
		throw 50001, '������� ������ ���� ������� 2 ��������', 1;
	end;
end;
go

insert into Faculty (FacultyName, headoffaculty, deanery) values
('����������� � ������� ����������', '������������ �.�', '318�'),
('���������� ������ � ����������', '���������� �.�', '400�'),
('����������� ��������������', '������� �.�', '200�'),
('������������������ ����������', '������ �.�', '532�');
go

insert into Department (DepartmentName, code, headofdepartment, audience, FacultyID) values
('���������� ���������� � �����������', '��9', '������ �.�','305�', 1),
('������������� �������������������', '���7', '�������� �.�', '401�', 2),
('������������ ���������� ������ � ��������� ������', '��9', '������� �.�', '250�', 3);
go

insert into Student (lastname, name, middlename, email, phone, DepartmentID) values
('������', '����', '��������', 'email1@gmail.com', '+79261111111', 1),
('������', '����', '��������', 'email2@gmail.com', '+79262222222', 1),
('��������', '������', '����������', 'email3@gmail.com', '+79263333333', 2),
('�������', '�����', '���������', 'email4@gmail.com', '+79264444444', 2),
('��������', '������', null, 'email5@gmail.com', '+79265555555', 3),
('������', '����', '���������', 'email6@gmail.com', '+79266666666', 3);
go

insert into Subject(name, hours, marktype, description, DepartmentID) values
('�������������� ������', 120, '������', '�������1', 1),
('�����', 60, '�����', '�������2', 1),
('���������� ������', 180, '������', '�������3', 2),
('�������� ������������', 70, '�����', '�������4', 2),
('�������������� ������������� ������������ ����������', 150, '������', '�������5', 3),
('���������� ���������', 60, '�����', '�������6', 3);
go

insert into Teacher(lastname, name, middlename, email, phone, DepartmentID) values
('��������', '��������', '����������', 'email_iu9_1@gmail.com', '+79161111111', 1),
('�����', '���������', '���������', 'email_iu9_2@gmail.com', '+79162222222', 1),
('��������', '�����', '����������', 'email_ibm7_1@gmail.com', '+79163333333', 2),
('�������', '������', '������������', 'email_ibm7_2@gmail.com', '+79164444444', 2),
('����������', '��������', '�������������', 'email_sm9_1@gmail.com', '+79165555555', 3),
('������', '�������', '����������', 'email_sm9_2@gmail.com', '+79166666666', 3);
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
select distinct  hours as N'��������� ����' from Subject

-- �����, �������������� � ���������� �����
select passbook as �������, name as ���, lastname �������, middlename as ��������, email as "����������� �����", phone as ������� from Student

-- ���������� ������
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


-- ������� ������ �������
-- null
select * from Student where middlename is null
select * from Student where middlename is not null
-- like
select * from Teacher where email like 'email_iu9%'

-- between
select * from Subject where hours between 95 and 165

-- in
select * from Student where name in ('�����', '����')

--exists
select * from Faculty where exists (select * from Department where Department.FacultyID = FacultyID)

-- ���������� �������
select * from Subject order by hours asc
select * from Subject order by hours desc

-- ����������� �������
-- count
select F.FacultyName, count(S.passbook) as N'���������� ���������'
from Student S
join Department D on S.DepartmentID = D.DepartmentID
join Faculty F on D.FacultyID = F.FacultyID
group by F.FacultyName;

-- avg
select F.FacultyName, avg(Su.hours) as N'������� ���������� �����'
from Subject Su
join Department D on Su.DepartmentID = D.DepartmentID
join Faculty F on D.FacultyID = F.FacultyID
group by F.FacultyName;

-- sum
select F.FacultyName, sum(Su.hours) as N'����� ���������� �����'
from Subject Su
join Department D on Su.DepartmentID = D.DepartmentID
join Faculty F on D.FacultyID = F.FacultyID
group by F.FacultyName;

-- min
select F.FacultyName, min(Su.hours) as N'����������� ���������� �����'
from Subject Su
join Department D on Su.DepartmentID = D.DepartmentID
join Faculty F on D.FacultyID = F.FacultyID
group by F.FacultyName having avg(Su.hours) > 100;

-- max
select F.FacultyName, max(Su.hours) as N'������������ ���������� �����'
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

-- ��������� �������
select * from Subject where hours < (select hours from Subject where name = '�������������� ������')



/*
delete from Department where DepartmentID = 3;
select * from Department;
select * from Student;
*/

-- update Student set lastname = '��' where passbook = 1;
update Student set lastname = '�����������' where passbook = 1;

select * from Student;
