use master;
go

if OBJECT_ID(N'Student') is not null
	drop table Student;
go

if OBJECT_ID(N'Department') is not null
	drop table Department;
go

if OBJECT_ID(N'Faculty') is not null
	drop table Faculty;
go

create table Faculty
(
	FacultyID int identity (1, 1) primary key,
	FacultyName nvarchar(100) unique not null,
	headoffaculty nvarchar(150),
	deanery nvarchar(10)
);
go

create table Department
(
	DepartmentID int identity (1, 1) primary key,
	DepartmentName nvarchar(100) unique not null check (len(DepartmentName) > 0),
	code nvarchar(10) unique not null check (len(code) > 0),
	headofdepartment nvarchar(150) not null,
	audience nvarchar(10) not null,
	FacultyID int foreign key references Faculty(FacultyID)
);

create table Student
(
	passbook int identity(1,1) primary key,
	name nvarchar(50) not null check (len(name) > 0),
	lastname nvarchar(50) not null check (len(lastname) > 0),
	middlename nvarchar(50),
	email nvarchar(256) unique not null check (len(email) > 0),
	phone nvarchar(15) not null
)
go

insert into Faculty (FacultyName, headoffaculty, deanery) values
('����������� � ������� ����������', '������������ �.�', '318�'),
('���������� ������ � ����������', '���������� �.�', '419�');
go

insert into Department (DepartmentName, code, headofdepartment, audience, FacultyID) values
('������������� ����������� � ������������ ����������', '��9', '������ �.�', '305�', 1),
('������������� �������������������', '���7', '�������� �.�', '414�', 2);
go

insert into Student (name, lastname, middlename, email, phone) values
('Ivan', 'Ivanov', 'Ivanovich', 'email1@gmail.com', '79261111111'),
('Petr', 'Petrov', 'Petrovich', 'email2@gmail.com', '79262222222'),
('Oleg', 'Olegov', 'Olegovich', 'email3@gmail.com', '79263333333'),
('Nikita', 'Nikitin', 'Nikitich', 'email4@gmail.com', '79264444444')
go

-- �������
if OBJECT_ID(N'TRIG_INSERT') is not null
	drop trigger TRIG_INSERT;
go

create trigger TRIG_INSERT on Student after insert as
begin
	if exists (select * from inserted where len(name) < 3)
	begin
		raiserror('��� ������ ���� ������� 2 ��������', 16, 1)
	end;
end;
go

/*insert into Student (name, lastname, middlename, email, phone, DepartmentID) values
('Ho', 'Hoho', 'Hohoho', 'email5@gmail.com', '79265555555', 2);
go*/

-- ����������

if OBJECT_ID(N'TRIG_UPDATE') is not null
	drop trigger TRIG_UPDATE;
go

create trigger TRIG_UPDATE on Student after update as 
begin
	if exists (select * from inserted where len(lastname) < 3)
	begin
		throw 50001, '������� ������ ���� ������� 2 ��������', 1;
	end;
end;
go

/*update Student set lastname = 'Ko' where email = 'email4@gmail.com';
go*/
-- �������� 

if OBJECT_ID(N'TRIG_DELETE') is not null
	drop trigger TRIG_UPDATE;
go

create trigger TRIG_DELETE on Student after delete as 
begin
	select * from deleted;
end;
go

delete from Student where lastname = 'Ivanov';
go

-- Task 2

if object_id(N'DepartmentView') is not null
	drop view DepartmentView;
go

create view DepartmentView as
	select D.DepartmentID, D.code, D.DepartmentName, D.headofdepartment, D.audience, F.FacultyName, F.headoffaculty, F.deanery
	from Faculty as F join Department as D on F.FacultyID = D.FacultyID
go


if OBJECT_ID(N'TRIG_DEPARTMENT_INSERT') is not null
	drop trigger TRIG_DEPARTMENT_INSERT;
go

if OBJECT_ID(N'TRIG_DEPARTMENT_UPDATE') is not null
	drop trigger TRIG_DEPARTMENT_UPDATE;
go

if OBJECT_ID(N'TRIG_DEPARTMENT_DELETE') is not null
	drop trigger TRIG_DEPARTMENT_DELETE;
go

-- �������
create trigger TRIG_DEPARTMENT_INSERT on DepartmentView instead of insert as
	begin
		insert into Department (DepartmentName, code, headofdepartment, audience, FacultyID)
		select
			i.DepartmentName,
			i.code,
			i.headofdepartment,
			i.audience,
			F.FacultyID
		from inserted i
		join Faculty F on i.FacultyName = F.FacultyName;
	end;
go

select * from DepartmentView;
go

insert into DepartmentView (code, DepartmentName, headofdepartment, audience, FacultyName) values
('��7', '����������� ���������', '������� �.�', '200�', '����������� � ������� ����������');
go

select * from DepartmentView;
go


-- ����������
/*create trigger TRIG_DEPARTMENT_UPDATE on DepartmentView instead of update as
	begin
		if update(FacultyName) or update(headoffaculty) or update(deanery)
			throw 50001, '���������� �������� ������', 1;
		if update(Departmentname)
			if exists (select * from inserted join Faculty as F on F.FacultyName = inserted.FacultyName)
				update Department set
					Department.code = inserted.code,
					Department.DepartmentName = inserted.DepartmentName,
					Department.headofdepartment = inserted.headofdepartment,
					Department.audience = inserted.audience
				from Department join inserted on Department.DepartmentID = inserted.DepartmentID;
			else throw 50002, '���������� �������� ������, ��������� �� ���������� ������� � ����� ���������', 1;
		else
			begin
				update Department set
					Department.code = inserted.code,
					Department.DepartmentName = inserted.DepartmentName,
					Department.headofdepartment = inserted.headofdepartment,
					Department.audience = inserted.audience
				from Department join inserted on Department.DepartmentID = inserted.DepartmentID
			end;
	end;
go

select * from DepartmentView;
go

/* ��������� ���������� ������
update DepartmentView set FacultyName = 'TEST' where DepartmentID = 2;
go*/

/* ��������� ���������� ������
update DepartmentView set DepartmentName = 'TEST' where DepartmentName = '������������� ������������������';
go*/
/*
update DepartmentView set code = 'TEST' where DepartmentName = '������������� �������������������';
go

select * from DepartmentView;
go*/
*/
create trigger TRIG_DEPARTMENT_DELETE on DepartmentView instead of delete as
	begin
		delete from Department where DepartmentID in (select DepartmentID from deleted);
	end;
go

/*select * from DepartmentView;
delete from DepartmentView where DepartmentName = '������������� �������������������';
select * from DepartmentView;*/


/*-- merge (������ ��� update)
merge into DepartmentView as target
using (
	select '��8' as code, '����������� ���������' as DepartmentName, '������� �.�' as headofdepartment, '100�' as audience, '����������� � ������� ����������' as FacultyName
) as source
on target.DepartmentName = source.DepartmentName
when matched then
	update set
		target.code = source.code,
		target.headofdepartment = source.headofdepartment,
		target.audience = source.audience
when not matched then
	insert (code, DepartmentName, headofdepartment, audience, FacultyName)
	values (source.code, source.DepartmentName, source.headofdepartment, source.audience, source.FacultyName);
go

select * from DepartmentView;*/

-- merge (������ ��� insert)
/*merge into DepartmentView as target
using (
	select '��8' as code, '�������������� ������������' as DepartmentName, '������� �.�' as headofdepartment, '100�' as audience, '����������� � ������� ����������' as FacultyName
) as source
on target.DepartmentName = source.DepartmentName
when matched then
	update set
		target.code = source.code,
		target.headofdepartment = source.headofdepartment,
		target.audience = source.audience
when not matched then
	insert (code, DepartmentName, headofdepartment, audience, FacultyName)
	values (source.code, source.DepartmentName, source.headofdepartment, source.audience, source.FacultyName);
go

select * from DepartmentView;*/


-- CTE
if OBJECT_ID(N'TRIG_DEPARTMENT_UPDATE_CTE') is not null
	drop trigger TRIG_DEPARTMENT_UPDATE_CTE;
go

create trigger TRIG_DEPARTMENT_UPDATE_CTE on DepartmentView instead of update as
begin
	-- ��������, ��� ����������� ������ ����������� �������
	if update(FacultyName) or update(headoffaculty) or update(deanery)
	begin
		throw 50001, '���������� �������� ������', 1;
	end;

	-- ������������� CTE ��� ���������� ������ � ������� Department
	with UpdatedDepartments as (
		select
			i.DepartmentID,
			i.code,
			i.DepartmentName,
			i.headofdepartment,
			i.audience,
			i.FacultyName
		from inserted i
	)
	update Department
	set
		Department.code = u.code,
		Department.DepartmentName = u.DepartmentName,
		Department.headofdepartment = u.headofdepartment,
		Department.audience = u.audience
	from UpdatedDepartments u
	join Department d on u.DepartmentID = d.DepartmentID
	where
		(update(DepartmentName) and exists (select 1 from Faculty f where f.FacultyName = u.FacultyName))
		or not update(DepartmentName);

	-- �������� ������� ���������� ��� ���������� DepartmentName
	if update(DepartmentName)
	begin
		if not exists (select 1 from Faculty f where f.FacultyName = (select FacultyName from inserted))
		begin
			throw 50002, '���������� �������� ������, ��������� �� ���������� ������� � ����� ���������', 1;
		end
	end;
end;
go


select * from DepartmentView;
go

-- ��������� ���������� ������
update DepartmentView set FacultyName = 'TEST' where DepartmentID = 2;
go

-- ��������� ���������� ������
/*update DepartmentView set DepartmentName = 'TEST' where DepartmentName = '������������� ������������������';
go*/

/*update DepartmentView set code = 'TEST' where DepartmentName = '������������� �������������������';
go*/

select * from DepartmentView;
go
