use Lab13Db1;
go

if OBJECT_ID('EmployeeInfo') is not null
	drop table EmployeeInfo;
go

create table EmployeeInfo
(
	employee_type nvarchar(50) primary key not null,
	hours_of_work int,
	experience int
)
go

use Lab13Db2;
go

if OBJECT_ID('Employee') is not null
	drop table Employee;
go

create table Employee
(
	EmployeeId int identity(1, 1) primary key,
	name nvarchar(50) not null,
	lastname nvarchar(50) not null,
	email nvarchar(255) not null,
	employee_t nvarchar(50)
)
go

if OBJECT_ID('EmployeeView') is not null
	drop view EmployeeView;
go

create view EmployeeView as
	select E.EmployeeId, E.name, E.lastname, E.email, E.employee_t, E_I.hours_of_work, E_I.experience
	from Employee as E inner join Lab13Db1.dbo.EmployeeInfo as E_I on E.employee_t = E_I.employee_type
go

use Lab13Db1;
go

if OBJECT_ID('EmployeeInfoDelete') is not null
	drop trigger EmployeeInfoDelete;

if OBJECT_ID('EmployeeInfoUpdate') is not null
	drop trigger EmployeeInfoUpdate;
go

create trigger EmployeeInfoUpdate on EmployeeInfo for update as
	if update(employee_type)
		begin
			raiserror('Нельзя менять тип работника', 16, 1)
		end
go

create trigger EmployeeInfoDelete on EmployeeInfo for delete as
	delete t from Lab13Db2.dbo.Employee as t join deleted on t.employee_t = deleted.employee_type;
go


use Lab13Db2;
go

if OBJECT_ID('EmployeeInsert') is not null
	drop trigger EmployeeInsert;

if OBJECT_ID('EmployeeUpdate') is not null
	drop trigger EmployeeUpdate;
go

create trigger EmployeeInsert on Employee for insert as
	if (select count(*)
        from inserted i
        left join Lab13Db1.dbo.EmployeeInfo ei on i.employee_t = ei.employee_type
        where ei.employee_type is null) > 0
		begin
			raiserror('Не существует такого значения employee_type в таблице EmployeeInfo', 16, 1)
			rollback
		end
go

create trigger EmployeeUpdate on Employee for update as
	if update(employee_t) and (select count(*) from inserted i
							   left join Lab13Db1.dbo.EmployeeInfo ei on i.employee_t = ei.employee_type
							   where ei.employee_type is null) > 0
		begin
			raiserror('Не существует такого значения employee_type в таблице EmployeeInfo', 16, 1)
			rollback
		end
go

insert into Lab13Db1.dbo.EmployeeInfo(employee_type, hours_of_work, experience) values
('Manager', 40, 5),
('Developer', 30, 3),
('Designer', 35, 7);
go

-- Неверный случай 
/*insert into Employee(employee_t, name, lastname, email) values
('Programmer', 'Justin', 'Timberlake', 'email4@gmail.com');
go*/


insert into Employee(employee_t, name, lastname, email) values
('Manager', 'Travis', 'Scott', 'email1@gmail.com'),
('Developer', 'Asap', 'Rocky', 'email2@gmail.com'),
('Designer', 'Rick', 'Ross', 'email3@gmail.com');
go


select * from Lab13Db1.dbo.EmployeeInfo;
select * from Lab13Db2.dbo.Employee;
select * from EmployeeView;
go

-- Неверный случай 
/*
update Lab13Db1.dbo.EmployeeInfo set employee_type = 'Secretary' where employee_type = 'Manager'
*/

update Lab13Db1.dbo.EmployeeInfo set hours_of_work = 25 where employee_type = 'Designer'

-- Неверный случай
/*
update Employee	set employee_t = 'Economist' where EmployeeId = 1
*/

update Employee	set employee_t = 'Developer' where EmployeeId = 1


select * from Lab13Db1.dbo.EmployeeInfo;
select * from Lab13Db2.dbo.Employee;
select * from EmployeeView;
go


-- delete from Lab13Db1.dbo.EmployeeInfo where employee_type = 'Designer'

delete from Lab13Db1.dbo.EmployeeInfo where employee_type = 'Developer'

select * from Lab13Db1.dbo.EmployeeInfo;
select * from Lab13Db2.dbo.Employee;
select * from EmployeeView;
go