use master;
go

if db_id(N'Lab8') is not null
	drop database Lab8;
go

create database Lab8 on
(
	name = Lab8data,
	filename = 'C:\SQL\Lab8data.mdf',
	size = 10,
	maxsize = unlimited,
	filegrowth = 5%
)
log on
(	
	name = Lab8log,
	filename = 'C:\SQL\Lab8log.ldf',
	size = 5MB,
	maxsize = 25MB,
	filegrowth = 5MB
)
go

use Lab8;
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
	email nvarchar(256) unique not null check (len(email) > 0),
	phone nvarchar(15) not null
)

insert into Student (name, lastname, middlename, email, phone) values
('Ivan', 'Ivanov', 'Ivanovich', 'email1@gmail.com', '79261111111'),
('Petr', 'Petrov', 'Petrovich', 'email2@gmail.com', '79262222222'),
('Oleg', 'Olegov', 'Olegovich', 'email3@gmail.com', '79263333333'),
('Nikita', 'Nikitin', 'Nikitich', 'email4@gmail.com', '79264444444')
go

select * from Student;
go

-- Task 1
if object_id(N'StudentProcedure') is not null
	drop procedure StudentProcedure;
go

create procedure StudentProcedure
	@cursor cursor varying output as
	set @cursor = cursor forward_only static for select passbook, name, lastname, middlename, phone from Student;
	open @cursor;
go

declare @studentcursor cursor;
exec StudentProcedure @cursor = @studentcursor output;
declare @passbook int, @name nvarchar(50), @lastname nvarchar(50), @middlename nvarchar(50), @phone nvarchar(15);

fetch next from @studentcursor into @passbook, @name, @lastname, @middlename, @phone;
while (@@FETCH_STATUS = 0)
	begin
		print cast(@passbook as varchar(40)) + ': ' + @name + ' ' + @lastname + ' ' + @middlename + ' with phone ' + @phone;
		fetch next from @studentcursor into @passbook, @name, @lastname, @middlename, @phone;
	end;
close @studentcursor;
deallocate @studentcursor;
go

print '';
go


-- Task 2 (функция возвращает ФИО)
if object_id(N'FIO') is not null
	drop function FIO;
go
create function FIO(@lastname nvarchar(50), @name nvarchar(50), @middlename nvarchar(50)) 
returns nvarchar(5) as
begin
	declare @ans nvarchar(5);
	set @ans = left(@lastname, 1) + '.' + left(@name, 1) + '.' + left(@middlename, 1);
	return @ans;
end;
go

if object_id(N'StudentProcedure_with_FIO') is not null
	drop procedure StudentProcedure_with_FIO;
go
create procedure StudentProcedure_with_FIO
	@cursor cursor varying output as
	set @cursor = cursor forward_only static for
		select passbook, name, lastname, middlename, phone, dbo.FIO(lastname, name, middlename) as FCs from Student;
	open @cursor;
go

declare @student_FIO_cursor cursor;
exec StudentProcedure_with_FIO @cursor = @student_FIO_cursor output;
declare @passbook int, @name nvarchar(50), @lastname nvarchar(50), @middlename nvarchar(50), @phone nvarchar(15), 
	@FIO nvarchar(5);

fetch next from @student_FIO_cursor into @passbook, @name, @lastname, @middlename, @phone, @FIO;
while (@@FETCH_STATUS = 0)
	begin
		print cast(@passbook as varchar(40)) + ': ' + @name + ' ' + @lastname + ' ' + @middlename + ' with phone ' + @phone +
			' and with FCs ' + @FIO;
		fetch next from @student_FIO_cursor into @passbook, @name, @lastname, @middlename, @phone, @FIO;
	end;
close @student_FIO_cursor;
deallocate @student_FIO_cursor;
go


print '';
go


-- Task 3
if object_id(N'check_name') is not null
	drop function check_name;
go

create function check_name(@name nvarchar(50)) returns int as
begin
	declare @ans int;
	set @ans = 0;
	if len(@name) > 4
		set @ans = 1;
	return @ans;
end;
go

if object_id(N'StudentProcedure2') is not null
	drop procedure StudentProcedure2;
go

create procedure StudentProcedure2 as
	declare @Stdcursor cursor;
	exec StudentProcedure @cursor = @Stdcursor output;
	declare @passbook int, @name nvarchar(50), @lastname nvarchar(50), @middlename nvarchar(50), @phone nvarchar(15);
	declare @check_result int;

	
	fetch next from @Stdcursor into	@passbook, @name, @lastname, @middlename, @phone;

	while (@@FETCH_STATUS = 0)
		begin
			set @check_result = dbo.check_name(@name);
			--print cast(@passbook as varchar(40)) + ': ' + cast(@check_result as varchar)
			if @check_result = 1
				print 'Condition is True for student with passbook ' + cast(@passbook as varchar(40)) + ': ' + @name + ' ' + @lastname + ' ' + @middlename + ' with phone ' + @phone;
			fetch next from @Stdcursor into	@passbook, @name, @lastname, @middlename, @phone;
		end;
	close @Stdcursor;
	deallocate @Stdcursor;
go
exec StudentProcedure2;
go

print '';
go


-- Task 4
if object_id(N'FIOtable') is not null
	drop function FIOtable;
go

create function FIOtable() returns table as 
return (select passbook, name, lastname, middlename, phone, left(lastname, 1) + '.' + left(name, 1) + '.' + left(middlename, 1) as FCs from Student);
go

if object_id(N'FIOtable2') is not null
	drop function FIOtable2;
go

/*create function FIOtable2() 
returns @ans_FIOtable2 table (
	passbook int primary key,
	name nvarchar(50) not null check (len(name) > 0),
	lastname nvarchar(50) not null check (len(lastname) > 0),
	middlename nvarchar(50),
	phone nvarchar(15) not null,
	FCs nvarchar(5) not null
)
as begin
	insert @ans_FIOtable2
	select passbook, name, lastname, middlename, phone, left(lastname, 1) + '.' + left(name, 1) + '.' + left(middlename, 1) as FCs from Student
	return
end;
go*/


if object_id(N'StudentTableProcedure_withFIO') is not null
	drop procedure StudentTableProcedure_withFIO;
go

create procedure StudentTableProcedure_withFIO
	@cursor cursor varying output as
	set @cursor = cursor forward_only static for 
	select passbook, name, lastname, middlename, phone, FCs from dbo.FIOtable(); 
	open @cursor;
go

declare @StudentTableProcedure_withFIO_cursor cursor;
exec StudentProcedure_with_FIO @cursor = @StudentTableProcedure_withFIO_cursor output;
declare @passbook int, @name nvarchar(50), @lastname nvarchar(50), @middlename nvarchar(50), @phone nvarchar(15), @FCs nvarchar(5);

fetch next from @StudentTableProcedure_withFIO_cursor into @passbook, @name, @lastname, @middlename, @phone, @FCs;
while (@@FETCH_STATUS = 0)
	begin
		print cast(@passbook as varchar(40)) + ': ' + @name + ' ' + @lastname + ' ' + @middlename + ' with phone ' + @phone +
			' and with FCs ' + @FCs;
		fetch next from @StudentTableProcedure_withFIO_cursor into @passbook, @name, @lastname, @middlename, @phone, @FCs;
	end;

close @StudentTableProcedure_withFIO_cursor;
deallocate @StudentTableProcedure_withFIO_cursor;
go

print '';
go