USE master
/*��������� � ��������� ���� SQL �������
��� �������� ���������������� ���� ������*/
GO --����������� ������ (BATH)

IF  EXISTS (
	SELECT name 
		FROM sys.databases 
		WHERE name = N'KB301_Kirilov'
)
ALTER DATABASE [KB301_Kirilov] set single_user with rollback immediate
GO
/* ���������, ���������� �� �� ������� ���� ������
� ������ [��� ����], ���� ��, �� ��������� ��� �������
 ���������� � ���� ����� */

IF  EXISTS (
	SELECT name 
		FROM sys.databases 
		WHERE name = N'KB301_Kirilov'
)
DROP DATABASE [KB301_Kirilov]
GO
/* ����� ���������, ���������� �� �� ������� ���� ������
� ������ [��� ����], ���� ��, ������� �� � ������� */

/* ������ ���� ��������� ��� ����������� ������������ ����
������ � ������ [��� ����] ��� ������������� */

CREATE DATABASE [KB301_Kirilov]
GO
-- ������� ���� ������

USE [KB301_Kirilov]
GO

IF EXISTS(
  SELECT *
    FROM sys.schemas
   WHERE name = N'Kirilov'
) 
 DROP SCHEMA Kirilov
GO
/*���������, ���������� �� � ���� ������
 [��� ����] ����� � ������ �������, ���� ��,
  �� �������������� ������� �� �� ����
  ���� �� ������� ��� ���� ������� - ��� ����� ������� �� ����� */

CREATE SCHEMA Kirilov 
GO

IF OBJECT_ID('[KB301_Kirilov].Kirilov.Stations', 'U') IS NOT NULL
  DROP TABLE  [KB301_Kirilov].Kirilov.Stations
GO

/*���������, ���������� �� � ���� ������
 [��� ����] � ����� � ������ ������� ������� ut_students ���� ��, 
  �� �������������� ������� �� �� ���� � �����.
  ���� �� ������� ��� ���� ������� - ��� ����� ������� �� ����� */

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

INSERT INTO [KB301_Kirilov].Kirilov.Stations
	(Id, Name, Adress)
	VALUES
	(1, N'���-���', N'���������, 4')
	,(2, N'������', N'�������, 16�')
	,(3, N'���', N'������, 64')
GO

EXEC sp_changedbowner 'sa'

--INSERT INTO [KB301_Kirilov].Kirilov.MeasurmentsTypes
--	(Id, MeasurmentsType, UnitsType)
--	VALUES
--	(1, )
--GO