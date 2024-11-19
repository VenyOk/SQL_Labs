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
('Информатика и системы управления', 'Пролетарский А.В', '318ю'),
('Инженерный бизнес и менеджмент', 'Омельченко И.Н', '419ю');
go

insert into Department (DepartmentName, code, headofdepartment, audience, FacultyID) values
('Теоретическая информатика и компьютерные технологии', 'ИУ9', 'Иванов И.П', '305ю', 1),
('Инновационное предпринимательство', 'ИБМ7', 'Песоцкий Ю.С', '414ю', 2);
go

insert into Student (name, lastname, middlename, email, phone) values
('Ivan', 'Ivanov', 'Ivanovich', 'email1@gmail.com', '79261111111'),
('Petr', 'Petrov', 'Petrovich', 'email2@gmail.com', '79262222222'),
('Oleg', 'Olegov', 'Olegovich', 'email3@gmail.com', '79263333333'),
('Nikita', 'Nikitin', 'Nikitich', 'email4@gmail.com', '79264444444')
go

-- Вставка
if OBJECT_ID(N'TRIG_INSERT') is not null
	drop trigger TRIG_INSERT;
go

create trigger TRIG_INSERT on Student after insert as
begin
	if exists (select * from inserted where len(name) < 3)
	begin
		raiserror('Имя должно быть длиннее 2 символов', 16, 1)
	end;
end;
go

/*insert into Student (name, lastname, middlename, email, phone, DepartmentID) values
('Ho', 'Hoho', 'Hohoho', 'email5@gmail.com', '79265555555', 2);
go*/

-- Обновление

if OBJECT_ID(N'TRIG_UPDATE') is not null
	drop trigger TRIG_UPDATE;
go

create trigger TRIG_UPDATE on Student after update as 
begin
	if exists (select * from inserted where len(lastname) < 3)
	begin
		throw 50001, 'Фамилия должна быть длиннее 2 символов', 1;
	end;
end;
go

/*update Student set lastname = 'Ko' where email = 'email4@gmail.com';
go*/
-- Удаление 

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

-- Вставка
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
('ИУ7', 'Программная инженерия', 'Рудаков И.В', '200ю', 'Информатика и системы управления');
go

select * from DepartmentView;
go


-- Обновление
/*create trigger TRIG_DEPARTMENT_UPDATE on DepartmentView instead of update as
	begin
		if update(FacultyName) or update(headoffaculty) or update(deanery)
			throw 50001, 'Невозможно изменить данные', 1;
		if update(Departmentname)
			if exists (select * from inserted join Faculty as F on F.FacultyName = inserted.FacultyName)
				update Department set
					Department.code = inserted.code,
					Department.DepartmentName = inserted.DepartmentName,
					Department.headofdepartment = inserted.headofdepartment,
					Department.audience = inserted.audience
				from Department join inserted on Department.DepartmentID = inserted.DepartmentID;
			else throw 50002, 'Невозможно изменить данные, поскольку не существует кафедры с таким названием', 1;
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

/* Обработка ошибочного случая
update DepartmentView set FacultyName = 'TEST' where DepartmentID = 2;
go*/

/* Обработка ошибочного случая
update DepartmentView set DepartmentName = 'TEST' where DepartmentName = 'Инновационное предпринимательств';
go*/
/*
update DepartmentView set code = 'TEST' where DepartmentName = 'Инновационное предпринимательство';
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
delete from DepartmentView where DepartmentName = 'Инновационное предпринимательство';
select * from DepartmentView;*/


/*-- merge (пример для update)
merge into DepartmentView as target
using (
	select 'ИУ8' as code, 'Программная инженерия' as DepartmentName, 'Басараб М.А' as headofdepartment, '100ю' as audience, 'Информатика и системы управления' as FacultyName
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

-- merge (пример для insert)
/*merge into DepartmentView as target
using (
	select 'ИУ8' as code, 'Информационная безопасность' as DepartmentName, 'Басараб М.А' as headofdepartment, '100ю' as audience, 'Информатика и системы управления' as FacultyName
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
	-- Проверка, что обновляются только разрешенные столбцы
	if update(FacultyName) or update(headoffaculty) or update(deanery)
	begin
		throw 50001, 'Невозможно изменить данные', 1;
	end;

	-- Использование CTE для обновления данных в таблице Department
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

	-- Проверка наличия факультета при обновлении DepartmentName
	if update(DepartmentName)
	begin
		if not exists (select 1 from Faculty f where f.FacultyName = (select FacultyName from inserted))
		begin
			throw 50002, 'Невозможно изменить данные, поскольку не существует кафедры с таким названием', 1;
		end
	end;
end;
go


select * from DepartmentView;
go

-- Обработка ошибочного случая
update DepartmentView set FacultyName = 'TEST' where DepartmentID = 2;
go

-- Обработка ошибочного случая
/*update DepartmentView set DepartmentName = 'TEST' where DepartmentName = 'Инновационное предпринимательств';
go*/

/*update DepartmentView set code = 'TEST' where DepartmentName = 'Инновационное предпринимательство';
go*/

select * from DepartmentView;
go
