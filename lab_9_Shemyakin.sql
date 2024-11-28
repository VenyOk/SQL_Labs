use master;
go

if db_id(N'Lab9') is not null
	drop database Lab9;
go

create database Lab9 on
(
	name = Lab9data,
	filename = 'C:\SQL\Lab9data.mdf',
	size = 10,
	maxsize = unlimited,
	filegrowth = 5%
)
log on
(	
	name = Lab9log,
	filename = 'C:\SQL\Lab9log.ldf',
	size = 5MB,
	maxsize = 25MB,
	filegrowth = 5MB
)
go

use Lab9;
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
go

insert into Student (name, lastname, middlename, email, phone) values
('Ivan', 'Ivanov', 'Ivanovich', 'email1@gmail.com', '79261111111'),
('Petr', 'Petrov', 'Petrovich', 'email2@gmail.com', '79262222222'),
('Oleg', 'Olegov', 'Olegovich', 'email3@gmail.com', '79263333333'),
('Nikita', 'Nikitin', 'Nikitich', 'email4@gmail.com', '79264444444')
go

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

insert into Student (name, lastname, middlename, email, phone) values
('Hov', 'Hoho', 'Hohoho', 'email5@gmail.com', '79265555555'),
('Hov2', 'Hoho2', 'Hohoho2', 'email6@gmail.com', '79266666666');
go
select * from Student

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

update Student set lastname = 'Kov' where email like 'email%'
go

select *from Student

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

if object_id(N'Employee') is not null
	drop table Employee;
go

if object_id(N'EmployeeDetails') is not null
	drop table EmployeeDetails;
go

if object_id(N'EmployeeView') is not null
	drop view EmployeeView;
go

if object_id(N'TRIG_EmployeeView_Insert') is not null
	drop trigger TRIG_EmployeeView_Insert;
go

if object_id(N'TRIG_EmployeeView_Update') is not null
	drop trigger TRIG_EmployeeView_Update;
go

if object_id(N'TRIG_EmployeeView_Delete') is not null
	drop trigger TRIG_EmployeeView_Delete;
go

if object_id(N'TRIG_EmployeeView_Update2') is not null
	drop trigger TRIG_EmployeeView_Update2;
go

create table Employee
(
	EmployeeID int identity(1, 1) primary key not null,
	name nvarchar(50) not null check(len(name) > 0),
	lastname nvarchar(50) not null check(len(lastname) > 0),
	salary int not null 
);
go

create table EmployeeDetails
(
	EmployeeID int primary key,
	years_of_work int not null,
	hours_per_day int not null,
	foreign key (EmployeeID) references Employee(EmployeeID) on delete cascade
);
go

insert into Employee(name, lastname, salary) values
('Bob', 'Marley', 20000),
('Forrest', 'Gump', 30000);
go
insert into EmployeeDetails(years_of_work, hours_per_day, EmployeeID) values
(10, 8, 1),
(20, 8, 2);
go

create view EmployeeView as
select
    E.EmployeeID,
    E.name,
    E.lastname,
    E.salary,
    D.years_of_work,
    D.hours_per_day
from
    Employee E
inner join
    EmployeeDetails D on E.EmployeeID = D.EmployeeID;
go

create trigger TRIG_EmployeeView_Insert on EmployeeView instead of insert as
begin
	if exists (select * from inserted where len(name) < 3)
	begin
		raiserror('Имя должно быть длиннее 2 символов', 16, 1);
		return;
	end;
    insert into Employee (name, lastname, salary)
    select name, lastname, salary
    from inserted;

    insert into EmployeeDetails (EmployeeID, years_of_work, hours_per_day)
    select E.EmployeeID, years_of_work, hours_per_day
    from inserted i
    join Employee E on i.name = E.name and i.lastname = E.lastname;
end;
go

create trigger TRIG_EmployeeView_Update on EmployeeView instead of update as
begin
    if update(EmployeeID)
    begin
        throw 50001, 'Невозможно изменить EmployeeID', 1;
    end;
	if exists (select * from inserted where len(lastname) < 3)
	begin
		throw 50001, 'Фамилия должна быть длиннее 2 символов', 1;
		return;
	end;

    update Employee
    set name = i.name,
        lastname = i.lastname,
        salary = i.salary
    from inserted i
    where Employee.EmployeeID = i.EmployeeID;

    update EmployeeDetails
    set years_of_work = i.years_of_work,
        hours_per_day = i.hours_per_day
    from inserted i
    where EmployeeDetails.EmployeeID = i.EmployeeID;
end;
go

create trigger TRIG_EmployeeView_Delete on EmployeeView instead of delete as
begin
    delete from EmployeeDetails
    where EmployeeID in (select EmployeeID from deleted);

    delete from Employee
    where EmployeeID in (select EmployeeID from deleted);
end;
go

insert into EmployeeView (name, lastname, salary, years_of_work, hours_per_day)
values
    ('P', 'Diddy', 50000, 5, 8);
go

insert into EmployeeView (name, lastname, salary, years_of_work, hours_per_day)
values
	('Justin', 'Biber', 100000, 3, 8),
    ('Travis', 'Scott', 60000, 7, 8),
	('Mike', 'Tyson', 90000, 8, 10);
go

select * from EmployeeView;
go
select * from Employee;
go
select * from EmployeeDetails;
go
update EmployeeView
set salary = 55000, years_of_work = 6
where name = 'Bob' and lastname = 'Marley';
go

delete from EmployeeView
where name = 'Travis' and lastname = 'Scott';
go

select *from EmployeeView;
go

select * from Employee;


-- merge
merge into EmployeeView as target
using (
    select 'Mike', 'Tyson', 70000, 4, 8
    union all
    select 'Bob', 'Marley', 25000, 11, 8
) as source (name, lastname, salary, years_of_work, hours_per_day)
on target.name = source.name and target.lastname = source.lastname
when matched then
    update set
        target.salary = source.salary,
        target.years_of_work = source.years_of_work,
        target.hours_per_day = source.hours_per_day
when not matched then
    insert (name, lastname, salary, years_of_work, hours_per_day)
    values (source.name, source.lastname, source.salary, source.years_of_work, source.hours_per_day);
go

select * from EmployeeView;
go
select * from Employee;
go
select * from EmployeeDetails;
go


if object_id(N'TRIG_EmployeeView_Update') is not null
	drop trigger TRIG_EmployeeView_Update;
go
-- CTE
create trigger TRIG_EmployeeView_Update2 on EmployeeView instead of update as
begin
    if update(EmployeeID)
    begin
        throw 50001, 'Невозможно изменить EmployeeID', 1;
    end;

    with UpdatedEmployees (EmployeeID, name, lastname, salary, years_of_work, hours_per_day) as (
        select i.EmployeeID, i.name, i.lastname, i.salary, i.years_of_work, i.hours_per_day
        from inserted i
    )
    update Employee
    set name = u.name,
        lastname = u.lastname,
        salary = u.salary
    from UpdatedEmployees u
    where Employee.EmployeeID = u.EmployeeID;

	with UpdatedEmployees (EmployeeID, name, lastname, salary, years_of_work, hours_per_day) as (
        select i.EmployeeID, i.name, i.lastname, i.salary, i.years_of_work, i.hours_per_day
        from inserted i
    )

    update EmployeeDetails
    set years_of_work = u.years_of_work,
        hours_per_day = u.hours_per_day
    from UpdatedEmployees u
    where EmployeeDetails.EmployeeID = u.EmployeeID;
end;
go

update EmployeeView
set salary = 55000, years_of_work = 9
where name = 'Bob' and lastname = 'Marley';
go

select * from EmployeeView;
go
select * from Employee;
go
select * from EmployeeDetails;
go