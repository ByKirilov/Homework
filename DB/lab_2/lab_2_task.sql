USE master
GO

IF  EXISTS (
	SELECT name 
		FROM sys.databases 
		WHERE name = N'KB301_Kirilov'
)
ALTER DATABASE [KB301_Kirilov] set single_user with rollback immediate
DROP DATABASE [KB301_Kirilov]
GO

CREATE DATABASE [KB301_Kirilov]
GO

USE [KB301_Kirilov]
GO

--IF EXISTS(
--  SELECT *
--    FROM sys.schemas
--   WHERE name = N'K'
--) 
-- DROP SCHEMA Kirilov
--GO

--CREATE SCHEMA K
--GO
-- ------------------------------------------------

create table CarInfo (
    CarNumber nvarchar(9) primary key
    constraint CHK_Number check
    (CarNumber like '[ABCEHKMOPTÀÂÑÅÍÊÌÎĞÒ][0-9][0-9][0-9][ABCEHKMOPTÀÂÑÅÍÊÌÎĞÒ][ABCEHKMOPTÀÂÑÅÍÊÌÎĞÒ][127][0-9][0-9]'
	or CarNumber like '[ABCEHKMOPTÀÂÑÅÍÊÌÎĞÒ][0-9][0-9][0-9][ABCEHKMOPTÀÂÑÅÍÊÌÎĞÒ][ABCEHKMOPTÀÂÑÅÍÊÌÎĞÒ][0-9][0-9]')
);
GO

create table RegionCode (
    RegCode varchar(3) primary key,
    RegionName nvarchar(255),
    constraint CHK_Code check (RegCode like '[127][0-9][0-9]' or RegCode like '[0-9][0-9]')
);

create table PostRegionCode (
    PostId int primary key,
    RegCode varchar(3)
    constraint FK_RCode foreign key (RegCode)
    references RegionCode(RegCode)
);

create table ÑarsRegistration (
    PostId int,  
    ArrivalTime time,
    IsDirectionOut bit,
    CarNumber nvarchar(9),
    constraint FK_RegNumber foreign key (CarNumber)
    references CarInfo(CarNumber),
    constraint FK_PostId foreign key (PostId)
    references PostRegionCode(PostId),
    constraint CHK_IsDirectionOut check (IsDirectionOut = 1 or IsDirectionOut = 0)
);
GO

CREATE TRIGGER ArrivalTrigger
on ÑarsRegistration
after insert
as if exists (
    select * from 
    (select top 1 reg.IsDirectionOut as res from ÑarsRegistration as reg, inserted
        where inserted.ArrivalTime > reg.ArrivalTime 
            and inserted.CarNumber = reg.CarNumber
        order by reg.ArrivalTime desc
    ) prevReg, inserted 
    where prevReg.res = 0 and inserted.IsDirectionOut = 0
    )
  RAISERROR ('double in', 16, 1);
  if exists (
    select * from 
    (select top 1 reg.IsDirectionOut as res from ÑarsRegistration as reg, inserted
        where inserted.ArrivalTime > reg.ArrivalTime 
            and inserted.CarNumber = reg.CarNumber
        order by reg.ArrivalTime desc
    ) prevReg, inserted 
    where prevReg.res = 1 and inserted.IsDirectionOut = 1
    )
  RAISERROR ('double out', 16, 2);
GO


insert into CarInfo values ('A123BC196'),
                           ('A124BC102'),
                           ('A124BC174');

insert into RegionCode values 
  ('102', N'Ğåñïóáëèêà Áàøêîğòîñòàí'),
  ('02', N'Ğåñïóáëèêà Áàøêîğòîñòàí'),
  ('196', N'Ñâåğäëîâñêàÿ îáëàñòü'),
  ('96', N'Ñâåğäëîâñêàÿ îáëàñòü'),
  ('174', N'×åëÿáèíñêàÿ îáëàñòü'),
  ('74', N'×åëÿáèíñêàÿ îáëàñòü'),
  ('134', N'Âîëãîãğàäñêàÿ îáëàñòü'),
  ('34', N'Âîëãîãğàäñêàÿ îáëàñòü'),
  ('124', N'Êğàñíîÿğñêèé êğàé'),
  ('24', N'Êğàñíîÿğñêèé êğàé');

insert into PostRegionCode values 
  (1, '196'), 
  (2, '196'),
  (3, '196'),
  (4, '196');

insert into ÑarsRegistration values (1, '11:00', 0, 'A123BC196');
insert into ÑarsRegistration values (1, '13:00', 0, 'A124BC102');
-- insert into ÑarsRegistration values (1, '14:00', 0, 'A124BC102');
insert into ÑarsRegistration values (1, '14:00', 1, 'A123BC196');
insert into ÑarsRegistration values (2, '15:00', 1, 'A124BC102');
insert into ÑarsRegistration values (1, '16:00', 1, 'A124BC174');
-- insert into ÑarsRegistration values (1, '18:00', 1, 'A124BC174');
GO


select * from CarInfo;
select * from RegionCode order by RegionName;
select * from ÑarsRegistration;

go
declare @postRegion varchar(3) = (select RegCode from RegionCode where RegionName='Ñâåğäëîâñêàÿ îáëàñòü')
  
declare @transitCars table (CarNumber varchar(9))
insert into @transitCars 
  select reg1.CarNumber from ÑarsRegistration reg1 
  where SUBSTRING(reg1.CarNumber, 7, 9) != @postRegion and SUBSTRING(reg1.CarNumber, 7, 8) != @postRegion
    and exists(select * from ÑarsRegistration reg2 where reg1.CarNumber = reg2.CarNumber
             and reg1.ArrivalTime < reg2.ArrivalTime
             and reg2.IsDirectionOut = 1
             and reg1.IsDirectionOut = 0
             and reg1.PostId != reg2.PostId)

declare @nonresidentCars table (CarNumber varchar(9)) 
insert into @nonresidentCars select reg1.CarNumber from ÑarsRegistration reg1
where exists(select * from ÑarsRegistration reg2 where reg1.CarNumber = reg2.CarNumber
           and reg1.ArrivalTime < reg2.ArrivalTime
           and reg2.IsDirectionOut = 1
           and reg1.IsDirectionOut = 0
           and reg1.PostId = reg2.PostId)

declare @localCars table (CarNumber varchar(9))
insert into @localCars select reg1.CarNumber from ÑarsRegistration reg1
where SUBSTRING(reg1.CarNumber, 7, 9) = @postRegion or SUBSTRING(reg1.CarNumber, 7, 8) = @postRegion 
and exists(select * from ÑarsRegistration reg2 
           where reg1.CarNumber = reg2.CarNumber
               and reg1.ArrivalTime < reg2.ArrivalTime
               and reg2.IsDirectionOut = 1
               and reg1.IsDirectionOut = 0)


declare @otherCars table(CarNumber varchar(9))
insert into @otherCars select distinct reg.CarNumber from ÑarsRegistration reg
	WHERE
		reg.CarNumber not in (select * from @transitCars) and
		reg.CarNumber not in (select * from @nonresidentCars) and
		reg.CarNumber not in (select * from @localCars)

--select CarNumber as 'transit cars' from @transitCars
--select CarNumber as 'nonresident cars' from @nonresidentCars
--select CarNumber as 'local cars' from @localCars
--select CarNumber as 'other cars' from @otherCars

select count(distinct CarNumber) as 'Number of local cars' from @localCars;
select count(distinct CarNumber) as 'total number of cars' from ÑarsRegistration;
select distinct reg.CarNumber from ÑarsRegistration reg 
  join CarInfo on CarInfo.CarNumber = reg.CarNumber;