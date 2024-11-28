use Lab13Db1;
go

if OBJECT_ID('Employee') is not null
	drop table Employee;
go

create table Employee (
	EmployeeId int primary key not null,
	name nvarchar(50) not null,
	lastname nvarchar(50) not null,
	email nvarchar(255) not null
);
go

use Lab13Db2;
go

if OBJECT_ID('Employee') is not null
	drop table Employee;
go

create table Employee (
	EmployeeId int primary key not null,
	hours_of_work int,
	experience int
);
go

use Lab13Db1;
go

if OBJECT_ID('EmployeeView') is not null
	drop view EmployeeView;
go

create view EmployeeView as
	select Emp1.EmployeeId, Emp1.name, Emp1.lastname, Emp1.email, Emp2.hours_of_work, Emp2.experience
	from Lab13Db1.dbo.Employee Emp1
	join Lab13Db2.dbo.Employee Emp2 on Emp1.EmployeeId = Emp2.EmployeeId;
go


if OBJECT_ID('TRIG_INSERT') is not null
	drop trigger TRIG_INSERT;
go

create trigger TRIG_INSERT on EmployeeView instead of insert as
begin
	insert into Lab13Db1.dbo.Employee(EmployeeId, name, lastname, email)
		select i.EmployeeId, i.name, i.lastname, i.email from inserted as i;

	insert into Lab13Db2.dbo.Employee(EmployeeId, hours_of_work, experience)
		select i.EmployeeId, i.hours_of_work, i.experience from inserted as i;
end;
go

insert into EmployeeView (EmployeeId, name, lastname, email, hours_of_work, experience) values
(1, 'Slim', 'Shady', 'email1@gmail.com', 40, 5),
(2, 'Max', 'Verstappen', 'email2@gmail.com', 35, 3),
(3, 'Artem', 'Dzuba', 'email3@gmail.com', 38, 7),
(4, 'Octavian', 'August', 'email4@gmail.com', 42, 6),
(5, 'Tayler', 'Durden', 'email5@gmail.com', 36, 4);
go

select * from EmployeeView;
go

if OBJECT_ID('TRIG_UPDATE') is not null
	drop trigger TRIG_UPDATE;
go

create trigger TRIG_UPDATE on EmployeeView instead of update as
begin
	if update(EmployeeId)
	begin
		throw 50001, 'Нельзя изменить EmployeeID', 1;
	end;

	update Lab13Db1.dbo.Employee
		set name = i.name, lastname = i.lastname, email = i.email
		from inserted as i
		join Lab13Db1.dbo.Employee as E on E.EmployeeId = i.EmployeeId;

	update Lab13Db2.dbo.Employee
		set hours_of_work = i.hours_of_work, experience = i.experience
		from inserted as i
		join Lab13Db2.dbo.Employee as Emp on Emp.EmployeeId = i.EmployeeId;
end;
go

if OBJECT_ID('TRIG_DELETE') is not null
	drop trigger TRIG_DELETE;
go

create trigger TRIG_DELETE on EmployeeView instead of delete as
begin
	delete from Lab13Db1.dbo.Employee
	where EmployeeId in (select EmployeeId from deleted);

	delete from Lab13Db2.dbo.Employee
	where EmployeeId in (select EmployeeId from deleted);
end;
go

update EmployeeView set name = 'Marshall', hours_of_work = 45 where EmployeeId = 1;
go

delete from EmployeeView where EmployeeId = 5;
go

select * from EmployeeView;
go
