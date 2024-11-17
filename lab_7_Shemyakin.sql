use Lab6;
go

if object_id(N'FacultyView') is not null
	drop view FacultyView;
go

-- Task 1
create view FacultyView as
	select Faculty.FacultyID, Faculty.FacultyName, Faculty.headoffaculty, Faculty.deanery from Faculty
	where FacultyName = 'Информатика и системы управления'
go


select * from FacultyView;
go

-- Task 2

if object_id(N'FacultyView') is not null
	drop view FacultyView;
go

create view FacultyView as
	select F.FacultyID, F.FacultyName, F.headoffaculty, F.deanery, D.code, D.DepartmentName, D.headofdepartment, D.audience
	from Faculty as F join Department as D on F.FacultyID = D.FacultyID with check option
go



select * from FacultyView;
go

-- Task 3

if exists (select * from sys.indexes where name = 'StudentIndex' and object_id = object_id('Student'))
	drop index StudentIndex on Student;
go
create index StudentIndex on Student(lastname, name, email desc) include (middlename, phone);
go

select lastname, name, email from Student where lastname = 'Ivanov';
select lastname, name, email from Student where name = 'Ivan';
select lastname, name, email from Student where email = 'email1@mail.ru';
go

-- Task 4

if object_id(N'StudentView') is not null
    drop view StudentView;
go

create view StudentView with schemabinding as
    select passbook, lastname, name, middlename, email, phone from dbo.Student where name = 'Petr';
go

if exists (select * from sys.indexes where name = 'StudentIndex' and object_id = object_id('Student'))
	drop index StudentIndex on Student;
go

create unique clustered index StudentIndex on StudentView(phone);
go

if exists (select * from sys.indexes where name = 'StudentIndex' and object_id = object_id('Student'))
	drop index StudentIndex on Student;
go

if exists (select * from sys.indexes where name = 'StudentIndex2' and object_id = object_id('Student'))
	drop index StudentIndex2 on Student;
go

create unique nonclustered index StudentIndex2 on StudentView(phone);
go
if exists (select * from sys.indexes where name = 'StudentIndex2' and object_id = object_id('Student'))
	drop index StudentIndex2 on Student;
go
select * from StudentView;
go

