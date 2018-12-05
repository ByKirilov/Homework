USE master
/*ОБРАЩЕНИЕ К СИСТЕМНОЙ БАЗЕ SQL СЕРВЕРА
ДЛЯ СОЗДАНИЯ ПОЛЬЗОВАТЕЛЬСКОЙ БАЗЫ ДАННЫХ*/
GO --РАЗДЕЛИТЕЛЬ БАТЧЕЙ (BATH)

IF  EXISTS (
	SELECT name 
		FROM sys.databases 
		WHERE name = N'KB301_Kirilov'
)
ALTER DATABASE [KB301_Kirilov] set single_user with rollback immediate
GO
/* ПРОВЕРЯЕМ, СУЩЕСТВУЕТ ЛИ НА СЕРВЕРЕ БАЗА ДАННЫХ
С ИМЕНЕМ [ИМЯ БАЗЫ], ЕСЛИ ДА, ТО ЗАКРЫВАЕМ ВСЕ ТЕКУЩИЕ
 СОЕДИНЕНИЯ С ЭТОЙ БАЗОЙ */

IF  EXISTS (
	SELECT name 
		FROM sys.databases 
		WHERE name = N'KB301_Kirilov'
)
DROP DATABASE [KB301_Kirilov]
GO
/* СНОВА ПРОВЕРЯЕМ, СУЩЕСТВУЕТ ЛИ НА СЕРВЕРЕ БАЗА ДАННЫХ
С ИМЕНЕМ [ИМЯ БАЗЫ], ЕСЛИ ДА, УДАЛЯЕМ ЕЕ С СЕРВЕРА */

/* ДАННЫЙ БЛОК НЕОБХОДИМ ДЛЯ КОРРЕКТНОГО ПЕРЕСОЗДАНИЯ БАЗЫ
ДАННЫХ С ИМЕНЕМ [ИМЯ БАЗЫ] ПРИ НЕОБХОДИМОСТИ */

CREATE DATABASE [KB301_Kirilov]
GO
-- СОЗДАЕМ БАЗУ ДАННЫХ

USE [KB301_Kirilov]
GO

IF EXISTS(
  SELECT *
    FROM sys.schemas
   WHERE name = N'Kirilov'
) 
 DROP SCHEMA Kirilov
GO
/*ПРОВЕРЯЕМ, СУЩЕСТВУЕТ ЛИ В БАЗЕ ДАННЫХ
 [ИМЯ БАЗЫ] СХЕМА С ИМЕНЕМ Фамилия, ЕСЛИ ДА,
  ТО ПРЕДВАРИТЕЛЬНО УДАЛЯЕМ ЕЕ ИЗ БАЗЫ
  ЕСЛИ ВЫ УАЛЯЕТЕ ВСЮ БАЗУ ЦЕЛИКОМ - ЭТА ЧАСТЬ СКРИПТА НЕ НУЖНА */

CREATE SCHEMA Kirilov 
GO

IF OBJECT_ID('[KB301_Kirilov].Kirilov.Stations', 'U') IS NOT NULL
  DROP TABLE  [KB301_Kirilov].Kirilov.Stations
GO

/*ПРОВЕРЯЕМ, СУЩЕСТВУЕТ ЛИ В БАЗЕ ДАННЫХ
 [ИМЯ БАЗЫ] И СХЕМЕ С ИМЕНЕМ Фамилия ТАБЛИЦА ut_students ЕСЛИ ДА, 
  ТО ПРЕДВАРИТЕЛЬНО УДАЛЯЕМ ЕЕ ИЗ БАЗЫ И СХЕМЫ.
  ЕСЛИ ВЫ УАЛЯЕТЕ ВСЮ БАЗУ ЦЕЛИКОМ - ЭТА ЧАСТЬ СКРИПТА НЕ НУЖНА */

CREATE TABLE [KB301_Kirilov].Kirilov.Stations
(
	s_Id smallint NOT NULL, 
	Name nvarchar(30) NULL, 
	Adress nvarchar(30) NULL,
	CONSTRAINT Id_s PRIMARY KEY (s_Id)
)
GO

IF OBJECT_ID('[KB301_Kirilov].Kirilov.MeasurmentsTypes', 'U') IS NOT NULL
  DROP TABLE  [KB301_Kirilov].Kirilov.MeasurmentsTypes
GO

CREATE TABLE [KB301_Kirilov].Kirilov.MeasurmentsTypes
(
	mt_Id smallint  NOT NULL, 
	MeasurmentsType nvarchar(15) NULL, 
	UnitsType nvarchar(30) NOT NULL,
	CONSTRAINT Id_mt PRIMARY KEY (mt_Id)
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
	Value decimal(10, 5) NOT NULL
)
GO

ALTER TABLE [KB301_Kirilov].Kirilov.Measurments ADD
	CONSTRAINT FK_Id_mt FOREIGN KEY (Id_mt)
	REFERENCES [KB301_Kirilov].Kirilov.MeasurmentsTypes(mt_Id)
	ON UPDATE CASCADE
GO

ALTER TABLE [KB301_Kirilov].Kirilov.Measurments ADD
	CONSTRAINT FK_Id_s FOREIGN KEY (Id_s)
	REFERENCES [KB301_Kirilov].Kirilov.Stations(s_Id)
	ON UPDATE CASCADE
GO

SET DATEFORMAT dmy;  
GO

INSERT INTO [KB301_Kirilov].Kirilov.Stations
	(s_Id, Name, Adress)
	VALUES
	(1, N'Мат-мех', N'Тургенева, 4')
	,(2, N'Общага', N'Чапаева, 16А')
	,(3, N'Дом', N'Ленина, 64')
GO

INSERT INTO [KB301_Kirilov].Kirilov.MeasurmentsTypes
	(mt_Id, MeasurmentsType, UnitsType)
	VALUES
	(1, N'Температура', N'°C')
	,(2, N'Давление', N'мм. рт. ст.')
	,(3, N'Влажность', N'%')
GO

INSERT INTO [KB301_Kirilov].Kirilov.Measurments
	(Id_s, Id_mt, DateAndTime, Value)
	VALUES
	(1, 1, N'13/09/2018', '12.53')
	,(1, 1, N'13/09/2018', '14')
	,(1, 2, N'13/09/2018', '760')
	,(1, 3, N'02/10/2018', '53')
	,(1, 1, N'05/09/2018', '17')
	,(2, 3, N'17/09/2018', '80')
	,(2, 2, N'13/09/2018', '740')
	,(3, 1, N'13/09/2018', '13')
	,(3, 2, N'06/09/2018', '764')
GO

SELECT FORMAT(Kirilov.Measurments.DateAndTime, 'D', 'ru-ru') AS Дата
,CONVERT(decimal(5,1), AVG(Kirilov.Measurments.Value)) AS Измерения
FROM Kirilov.Measurments WHERE Kirilov.Measurments.Id_mt = 1 GROUP BY DateAndTime
GO

SELECT Kirilov.Stations.Name AS Станция
, FORMAT(Kirilov.Measurments.DateAndTime, 'D', 'ru-ru') AS Дата
, Kirilov.Stations.Adress AS Адрес
, CONVERT(decimal(5,1), Kirilov.Measurments.Value) AS Измерения
, Kirilov.MeasurmentsTypes.UnitsType AS Тип_измерения
FROM Kirilov.Measurments inner JOIN Kirilov.MeasurmentsTypes ON Kirilov.Measurments.Id_mt=Kirilov.MeasurmentsTypes.mt_Id inner JOIN Kirilov.Stations ON Kirilov.Measurments.Id_s=Kirilov.Stations.s_Id 
GO

SELECT Kirilov.Stations.Name AS Станция
, FORMAT(Kirilov.Measurments.DateAndTime, 'D', 'ru-ru') AS Дата
, Kirilov.Stations.Adress AS Адрес
, CONVERT(decimal(5,1), Kirilov.Measurments.Value) AS Измерения
, Kirilov.MeasurmentsTypes.UnitsType AS Тип_измерения
Into Kirilov.StationsUpt
FROM Kirilov.Measurments inner JOIN Kirilov.MeasurmentsTypes ON Kirilov.Measurments.Id_mt=Kirilov.MeasurmentsTypes.mt_Id inner JOIN Kirilov.Stations ON Kirilov.Measurments.Id_s=Kirilov.Stations.s_Id 
GO

Select * From Kirilov.StationsUpt
GO

Select Kirilov.StationsUpt.Станция AS Станция
--, Kirilov.StationsUpt.Дата AS Дата
, CONVERT(decimal(5,1), AVG(Kirilov.StationsUpt.Измерения)) AS Среднее_значение
, Kirilov.StationsUpt.Тип_измерения AS Тип_измерения
From Kirilov.StationsUpt
Where (Kirilov.StationsUpt.Тип_измерения = '°C' 
or Kirilov.StationsUpt.Тип_измерения = 'мм. рт. ст.' 
or Kirilov.StationsUpt.Тип_измерения = '%')
--and Kirilov.StationsUpt.Дата = N'13 сентября 2018 г.'
group by Станция, Тип_измерения
Go
