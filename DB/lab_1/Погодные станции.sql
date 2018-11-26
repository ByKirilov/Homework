USE master
/*напюыемхе й яхярелмни аюге SQL яепбепю
дкъ янгдюмхъ онкэгнбюрекэяйни аюгш дюммшу*/
GO --пюгдекхрекэ аюрвеи (BATH)

IF  EXISTS (
	SELECT name 
		FROM sys.databases 
		WHERE name = N'KB301_Kirilov'
)
ALTER DATABASE [KB301_Kirilov] set single_user with rollback immediate
GO
/* опнбепъел, ясыеярбсер кх мю яепбепе аюгю дюммшу
я хлемел [хлъ аюгш], еякх дю, рн гюйпшбюел бяе рейсыхе
 янедхмемхъ я щрни аюгни */

IF  EXISTS (
	SELECT name 
		FROM sys.databases 
		WHERE name = N'KB301_Kirilov'
)
DROP DATABASE [KB301_Kirilov]
GO
/* ямнбю опнбепъел, ясыеярбсер кх мю яепбепе аюгю дюммшу
я хлемел [хлъ аюгш], еякх дю, сдюкъел ее я яепбепю */

/* дюммши акнй менаундхл дкъ йнппейрмнцн оепеянгдюмхъ аюгш
дюммшу я хлемел [хлъ аюгш] опх менаундхлнярх */

CREATE DATABASE [KB301_Kirilov]
GO
-- янгдюел аюгс дюммшу

USE [KB301_Kirilov]
GO

IF EXISTS(
  SELECT *
    FROM sys.schemas
   WHERE name = N'Kirilov'
) 
 DROP SCHEMA Kirilov
GO
/*опнбепъел, ясыеярбсер кх б аюге дюммшу
 [хлъ аюгш] яуелю я хлемел тЮЛХКХЪ, еякх дю,
  рн опедбюпхрекэмн сдюкъел ее хг аюгш
  еякх бш сюкъере бяч аюгс жекхйнл - щрю вюярэ яйпхорю ме мсфмю */

CREATE SCHEMA Kirilov 
GO

IF OBJECT_ID('[KB301_Kirilov].Kirilov.Stations', 'U') IS NOT NULL
  DROP TABLE  [KB301_Kirilov].Kirilov.Stations
GO

/*опнбепъел, ясыеярбсер кх б аюге дюммшу
 [хлъ аюгш] х яуеле я хлемел тЮЛХКХЪ рюакхжю ut_students еякх дю, 
  рн опедбюпхрекэмн сдюкъел ее хг аюгш х яуелш.
  еякх бш сюкъере бяч аюгс жекхйнл - щрю вюярэ яйпхорю ме мсфмю */

CREATE TABLE [KB301_Kirilov].Kirilov.Stations
(
	Id smallint NOT NULL, 
	Name nvarchar(30) NULL, 
	Adress nvarchar(30) NULL,
	CONSTRAINT Id_s PRIMARY KEY (Id)
)
GO

IF OBJECT_ID('[KB301_Kirilov].Kirilov.MeasurmentsTypes', 'U') IS NOT NULL
  DROP TABLE  [KB301_Kirilov].Kirilov.MeasurmentsTypes
GO

CREATE TABLE [KB301_Kirilov].Kirilov.MeasurmentsTypes
(
	Id smallint  NOT NULL, 
	MeasurmentsType nvarchar(15) NULL, 
	UnitsType nvarchar(30) NOT NULL,
	CONSTRAINT Id_mt PRIMARY KEY (Id)
)
GO

IF OBJECT_ID('[KB301_Kirilov].Kirilov.Measurments', 'U') IS NOT NULL
  DROP TABLE  [KB301_Kirilov].Kirilov.Measurments
GO

CREATE TABLE [KB301_Kirilov].Kirilov.Measurments
(
	Id_s smallint NOT NULL,
	Id_mt smallint NOT NULL,
	DateAndTime datetime  NOT NULL,
	Value nvarchar(10) NOT NULL
)
GO

ALTER TABLE [KB301_Kirilov].Kirilov.Measurments ADD
	CONSTRAINT FK_Id_mt FOREIGN KEY (Id_mt)
	REFERENCES [KB301_Kirilov].Kirilov.MeasurmentsTypes(Id)
	ON UPDATE CASCADE
GO

ALTER TABLE [KB301_Kirilov].Kirilov.Measurments ADD
	CONSTRAINT FK_Id_s FOREIGN KEY (Id_s)
	REFERENCES [KB301_Kirilov].Kirilov.Stations(Id)
	ON UPDATE CASCADE
GO

SET DATEFORMAT dmy;  
GO

INSERT INTO [KB301_Kirilov].Kirilov.Stations
	(Id, Name, Adress)
	VALUES
	(1, N'лЮР-ЛЕУ', N'рСПЦЕМЕБЮ, 4')
	,(2, N'нАЫЮЦЮ', N'вЮОЮЕБЮ, 16ю')
	,(3, N'дНЛ', N'кЕМХМЮ, 64')
GO

INSERT INTO [KB301_Kirilov].Kirilov.MeasurmentsTypes
	(Id, MeasurmentsType, UnitsType)
	VALUES
	(1, N'рЕЛОЕПЮРСПЮ', N'╟C')
	,(2, N'дЮБКЕМХЕ', N'ЛЛ. ПР. ЯР.')
	,(3, N'бКЮФМНЯРЭ', N'%')
GO

INSERT INTO [KB301_Kirilov].Kirilov.Measurments
	(Id_s, Id_mt, DateAndTime, Value)
	VALUES
	(1, 1, N'13/09/2018', N'12')
	,(1, 2, N'12/09/2018', N'760')
	,(1, 3, N'02/10/2018', N'53')
	,(1, 1, N'05/09/2018', N'17')
	,(2, 3, N'17/09/2018', N'80')
	,(2, 2, N'13/09/2018', N'740')
	,(3, 1, N'14/10/2018', N'13')
	,(3, 2, N'06/09/2018', N'764')
GO

EXEC sp_changedbowner 'sa'	--яЛЕМЮ БКЮДЕКЭЖЮ ДКЪ ОНЯРПНЕМХЪ ДХЮЦПЮЛЛ