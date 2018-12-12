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

create table CarInfo (
    CarNumber nvarchar(9) primary key
    constraint CHK_Number check
    ((CarNumber like '[ABCEHKMOPTАВСЕНКМОРТ][0-9][0-9][0-9][ABCEHKMOPTАВСЕНКМОРТ][ABCEHKMOPTАВСЕНКМОРТ][127][0-9][0-9]'
	or CarNumber like '[ABCEHKMOPTАВСЕНКМОРТ][0-9][0-9][0-9][ABCEHKMOPTАВСЕНКМОРТ][ABCEHKMOPTАВСЕНКМОРТ][0-9][0-9]')
	and SUBSTRING(CarNumber, 2, 3) != '000'));
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

create table СarsRegistration (
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
on СarsRegistration
after insert
as if exists (
    select * from 
    (select top 1 reg.IsDirectionOut as res from СarsRegistration as reg, inserted
        where inserted.ArrivalTime > reg.ArrivalTime 
            and inserted.CarNumber = reg.CarNumber
        order by reg.ArrivalTime desc
    ) prevReg, inserted 
    where prevReg.res = 0 and inserted.IsDirectionOut = 0
    )
  RAISERROR ('double in', 16, 1);
  if exists (
    select * from 
    (select top 1 reg.IsDirectionOut as res from СarsRegistration as reg, inserted
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
                           ('A124BC174'),
						   ('A150BC134'),
						   ('A007BC196'),
						   ('A115BC96'),
						   ('A566BC02'),
						   ('A256BC34'),
						   ('A512BC02');

insert into CarInfo values ('c000AB33');
insert into CarInfo values ('E1111AE174');

insert into RegionCode values 
  ('102', N'Республика Башкортостан'),
  ('02', N'Республика Башкортостан'),
  ('196', N'Свердловская область'),
  ('96', N'Свердловская область'),
  ('174', N'Челябинская область'),
  ('74', N'Челябинская область'),
  ('134', N'Волгоградская область'),
  ('34', N'Волгоградская область'),
  ('124', N'Красноярский край'),
  ('24', N'Красноярский край');

insert into PostRegionCode values 
  (1, '196'), 
  (2, '196'),
  (3, '196'),
  (4, '196');

insert into СarsRegistration values (1, '10:00', 1, 'A007BC196');
insert into СarsRegistration values (1, '11:00', 0, 'A123BC196');
insert into СarsRegistration values (1, '11:10', 1, 'A566BC02');
insert into СarsRegistration values (1, '12:00', 0, 'A150BC134');
insert into СarsRegistration values (1, '13:00', 0, 'A124BC102');
insert into СarsRegistration values (1, '14:00', 1, 'A123BC196');
insert into СarsRegistration values (2, '15:00', 1, 'A124BC102');
insert into СarsRegistration values (2, '15:30', 1, 'A150BC134');
insert into СarsRegistration values (2, '15:40', 1, 'A256BC34');
insert into СarsRegistration values (1, '16:00', 1, 'A124BC174');
insert into СarsRegistration values (1, '17:00', 0, 'A007BC196');
insert into СarsRegistration values (1, '17:05', 0, 'A566BC02');
insert into СarsRegistration values (1, '17:10', 0, 'A512BC02');
insert into СarsRegistration values (1, '17:15', 0, 'A512BC02');
GO


select * from CarInfo;
select * from RegionCode order by RegionName;
select * from СarsRegistration;
GO

declare @postRegion table (RegCode varchar(3)) 
insert into @postRegion 
	select RegCode from RegionCode where RegionName='Свердловская область'

declare @transitCars table (CarNumber varchar(9))
insert into @transitCars 
  select reg1.CarNumber from СarsRegistration reg1 
  where not exists (select * from @postRegion post where SUBSTRING(reg1.CarNumber, 7, 3) = post.RegCode or SUBSTRING(reg1.CarNumber, 7, 2) = post.RegCode)
    and exists(select * from СarsRegistration reg2 where reg1.CarNumber = reg2.CarNumber
             and reg1.ArrivalTime < reg2.ArrivalTime
             and reg2.IsDirectionOut = 1
             and reg1.IsDirectionOut = 0
             and reg1.PostId != reg2.PostId)

declare @nonresidentCars table (CarNumber varchar(9)) 
insert into @nonresidentCars select reg1.CarNumber from СarsRegistration reg1
where exists(select * from СarsRegistration reg2 where reg1.CarNumber = reg2.CarNumber
           and reg1.ArrivalTime < reg2.ArrivalTime
           and reg2.IsDirectionOut = 1
           and reg1.IsDirectionOut = 0
           and reg1.PostId = reg2.PostId)

--select CarNumber as 'nonresident cars', regs.RegionName as 'Region' from @nonresidentCars car join RegionCode regs on (SUBSTRING(car.CarNumber, 7, 3) = regs.RegCode or SUBSTRING(car.CarNumber, 7, 2) = regs.RegCode);

declare @localCars table (CarNumber varchar(9))
insert into @localCars select reg1.CarNumber from СarsRegistration reg1
where exists (select * from @postRegion post where SUBSTRING(reg1.CarNumber, 7, 3) = post.RegCode or SUBSTRING(reg1.CarNumber, 7, 2) = post.RegCode) 
and exists(select * from СarsRegistration reg2 
           where reg1.CarNumber = reg2.CarNumber
               and reg1.ArrivalTime < reg2.ArrivalTime
               and reg2.IsDirectionOut = 0
               and reg1.IsDirectionOut = 1)

select CarNumber as 'local cars' from @localCars


declare @otherCars table(CarNumber varchar(9))
insert into @otherCars select distinct reg.CarNumber from СarsRegistration reg
	WHERE
		reg.CarNumber not in (select * from @transitCars) and
		reg.CarNumber not in (select * from @nonresidentCars) and
		reg.CarNumber not in (select * from @localCars)

select CarNumber as 'transit cars' from @transitCars


select CarNumber as 'other cars' from @otherCars

select count(distinct CarNumber) as 'Number of local cars' from @localCars;
select count(distinct CarNumber) as 'total number of cars' from СarsRegistration;
select distinct reg.CarNumber from СarsRegistration reg 
  join CarInfo on CarInfo.CarNumber = reg.CarNumber;
