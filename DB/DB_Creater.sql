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