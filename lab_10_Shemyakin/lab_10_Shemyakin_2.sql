use Lab10;
go

begin transaction
	update Student set name = 'Sergey' where name = 'Ivan';
	select resource_type, resource_subtype, request_mode from sys.dm_tran_locks WHERE request_session_id = @@spid
	waitfor delay '00:00:05';
	rollback transaction
go


/*begin transaction
	update Student set name = 'Sergey' where name = 'Petr';
	waitfor delay '00:00:05';
	select resource_type, resource_subtype, request_mode from sys.dm_tran_locks WHERE request_session_id = @@spid
commit transaction;
go*/


/*begin transaction
	update Student set name = 'Sergey' where name = 'Oleg';
	insert into Student (name, lastname, middlename, email, phone) values
	('Semen', 'Semenov', 'Semenovich', 'email5@gmail.com', '79265555555')
	select resource_type, resource_subtype, request_mode from sys.dm_tran_locks WHERE request_session_id = @@spid
commit transaction;
go*/


/*begin transaction
	insert into Student (name, lastname, middlename, email, phone) values
	('Artem', 'Artemov', 'Artemovich', 'email6@gmail.com', '79266666666')
	select resource_type, resource_subtype, request_mode from sys.dm_tran_locks WHERE request_session_id = @@spid
commit transaction;
go*/