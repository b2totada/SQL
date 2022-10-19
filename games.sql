--drop table publisher
--drop table game
--drop table temp

--create and use new db
create database games
use games
GO

--setting up publisher table
create table publisher(
	name varchar(50) primary key,
	address varchar(50),
	foundation date
)
GO

insert into publisher (name, address, foundation)
values ('Ubisoft', 'valami cím', '1975-08-18')
insert into publisher (name, address, foundation)
values ('CD projekt', 'valami cím2', '1979-10-06')
insert into publisher (name, address, foundation)
values ('EAgames', 'valami cím3', '1976-11-12')
insert into publisher (name, address, foundation)
values ('Bethesda', 'valami cím4', '1977-12-31')
insert into publisher (name, address, foundation)
values ('Rockstar Games', 'valami cím5', '1978-01-20')
GO

--setting up game table
create table game(
	name varchar(50) primary key,
	category varchar(50),
	developer_name varchar(50),
	publisher_name varchar(50),
	constraint publisher_name
    foreign key (publisher_name)
    references publisher(name)
)
GO

--setting up temp table
create table temp(
	name varchar(50),
	category varchar(50),
	developer_name varchar(50),
	publisher_name varchar(50)
)
GO

-- scheduling the loading of data from txt to temp table, the datatransfer from temp to game table and the deletion from temp table
USE msdb

EXEC sp_add_job  
@job_name = N'LoadIntoGame'  
GO

declare @path varchar(max)
set @path = 'C:\Users\Adam\Documents\SQL Server Management Studio\games.txt' --give your filepath here!!!
declare @insert_into_game varchar(max) = N'bulk insert videojatek..temp 
from '''+@path+'''
with
(
	firstrow = 2,
	fieldterminator = '';'',
	rowterminator = ''\n'',
	batchsize = 50
);
insert into videojatek..game(name, category, developer_name, publisher_name)
select distinct name, category, developer_name, publisher_name
from videojatek..temp t
where t.name not in (select name from videojatek..game) and
t.publisher_name in (select name from videojatek..publisher);
delete from videojatek..temp'
--print @insert_into_game
--exec(@insert_into_game)

EXEC sp_add_jobstep  
@job_name = N'LoadIntoGame',  
@step_name = N'InsertIntoGame',  
@subsystem = N'TSQL',  
@command = @insert_into_game,   
@retry_attempts = 0,  
@retry_interval = 1
GO

EXEC sp_add_schedule  --customize to change periodicity!!!
@schedule_name = N'RunEveryMinute',  
@freq_type = 4, --daily basis
@freq_interval = 1, --don't use this
@freq_subday_type = 2, --units between each exec: seconds
@freq_subday_interval = 60 --number of units between each exec
GO

EXEC sp_attach_schedule  
@job_name = N'LoadIntoGame',  
@schedule_name = N'RunEveryMinute'
GO

EXEC sp_add_jobserver  
@job_name = N'LoadIntoGame'
GO

--delete job
--USE msdb 
--EXEC sp_delete_job  
    --@job_name = N'LoadIntoGame' 
--GO

--delete schedule by id
--EXEC dbo.sp_delete_schedule  
    --@schedule_id = 56
--GO

--to see schedules
--select a.schedule_id, a.name, a.owner_sid, b.name
--from 
--msdb..sysschedules a 
--left join master..syslogins b on a.owner_sid=b.sid
--where a.schedule_id not in
--(select schedule_id from msdb..sysjobschedules)
--GO

--check tables
use games
select * from publisher order by name
select * from game order by name
select * from temp order by name
GO
