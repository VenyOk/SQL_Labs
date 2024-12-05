use Lab10;
go


set transaction isolation level read uncommitted;
begin transaction
	select * from Student;
	waitfor delay '00:00:05';
	select * from Student;
commit transaction;
go


/*set transaction isolation level read committed;
begin transaction
	select * from Student;
	waitfor delay '00:00:05';
	select * from Student;
commit transaction;
go*/


/*set transaction isolation level repeatable read;
begin transaction
	select * from Student;
	waitfor delay '00:00:05';
	select * from Student;
commit transaction;
go*/


/*set transaction isolation level serializable
begin transaction
	select * from Student;
	waitfor delay '00:00:05';
	select * from Student;
commit transaction;
go*/