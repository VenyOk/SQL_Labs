use Lab12;
go

/*select * from Student;
go
*/

if OBJECT_ID(N'Student') is not null
	drop table Student;
go

create table Student
(
	passbook int identity(1,1) primary key,
	name nvarchar(50) not null check (len(name) > 0),
	lastname nvarchar(50) not null check (len(lastname) > 0),
	email nvarchar(256) not null check (len(email) > 0),
	phone nvarchar(15) not null
)
go

