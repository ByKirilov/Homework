USE master
GO 

IF  EXISTS (
	SELECT name 
		FROM sys.databases 
		WHERE name = N'KB301_Kirilov'
)
ALTER DATABASE [KB301_Kirilov] set single_user with rollback immediate
GO

IF  EXISTS (
	SELECT name 
		FROM sys.databases 
		WHERE name = N'KB301_Kirilov'
)
DROP DATABASE [KB301_Kirilov]
GO

CREATE DATABASE [KB301_Kirilov] COLLATE Cyrillic_General_CI_AS
GO

USE [KB301_Kirilov]
GO

IF EXISTS(
  SELECT *
    FROM sys.schemas
   WHERE name = N'Kirilov'
) 
 DROP SCHEMA Kirilov
GO

CREATE SCHEMA Kirilov 
GO

CREATE TABLE Kirilov.Tariffs
(
	t_id smallint NOT NULL,
	tarif_name nvarchar(100) NOT NULL,
	subscription_fee int NOT NULL,
	minutes_limit int NOT NULL,
	pay_over_limit float NOT NULL

	CONSTRAINT PK_tar PRIMARY KEY(t_id)
)

INSERT INTO Kirilov.Tariffs
VALUES
(1,N'Áåç àáîíåíñêîé ïëàòû',0,0,1),
(2,N'Áåçëèìèò',1000,44640,0),
(3,N'Ïàêåò 200',150,200,1.5),
(4,N'Ïàêåò 300',200,300,1.7)
GO
SELECT * FROM Kirilov.Tariffs
GO

IF EXISTS(
  SELECT *
    FROM sys.triggers
   WHERE name = N'Kirilov.get_best_tarif'
) 
DROP FUNCTION Kirilov.get_best_tarif
GO

CREATE FUNCTION Kirilov.get_best_tarif (@minutes float)
RETURNS smallint
AS
BEGIN
DECLARE

@id int,
@subsrciption int,
@minutes_limit int,
@pay_over_limit float,
@best_tarif_id int = 0,
@best_price int = 1000000000,
@temp int
DECLARE cur CURSOR FOR
SELECT t_id, subscription_fee, minutes_limit, pay_over_limit from Kirilov.Tariffs
OPEN cur
FETCH NEXT FROM cur INTO @id, @subsrciption, @minutes_limit, @pay_over_limit
WHILE @@FETCH_STATUS = 0
	BEGIN 
		IF (CEILING (@minutes) <= @minutes_limit)
			BEGIN
				--PRINT '1 '
				IF(@subsrciption <= @best_price)
					BEGIN
						SET @best_tarif_id = @id
						SET @best_price = @subsrciption
					END
			END
		ELSE
			BEGIN
				--PRINT '2 '
				SET @temp = CEILING (@minutes) - @minutes_limit
				IF((@subsrciption + @pay_over_limit * @temp) < @best_price)
					BEGIN
						SET @best_tarif_id = @id
						SET @best_price = @subsrciption + @pay_over_limit * @temp
					END
			END
		FETCH NEXT FROM cur INTO @id, @subsrciption, @minutes_limit, @pay_over_limit
	END
	CLOSE cur
	DEALLOCATE cur
	RETURN @best_tarif_id
END
GO

SELECT tarif_name as Ëó÷øèé_òàðèô FROM Kirilov.Tariffs WHERE Kirilov.get_best_tarif(250) = t_id
GO

IF EXISTS(
  SELECT *
    FROM sys.triggers
   WHERE name = N'Timelimits'
) 
DROP PROC Timelimits
GO

CREATE PROC Timelimits 
AS 
	DECLARE
		@counter int = 0,

		@id1 int,
		@f_subscription int,
		@f_minutes_limit int,
		@f_pay_over_limit float,

		@id2 int,
		@s_subscription int,
		@s_minutes_limit int,
		@s_pay_over_limit float,

		@f_crossing_point float,
		@s_crossing_point float,

		@f_coord float,
		@s_coord float
	
		CREATE TABLE #Crossing_points
		(p_id int, coords float)
		
		CREATE TABLE #Limits
		(fromtime float, totime float, tarif nvarchar(100))

		INSERT INTO #Crossing_points
		VALUES ( @counter, 0)
		SET @counter +=1 

		DECLARE cur1 CURSOR FOR

		SELECT t_id, subscription_fee, minutes_limit, pay_over_limit from Kirilov.Tariffs ORDER By subscription_fee
		
		OPEN cur1
		FETCH NEXT FROM cur1 INTO @id1, @f_subscription, @f_minutes_limit, @f_pay_over_limit
		WHILE @@FETCH_STATUS = 0
			BEGIN 
				DECLARE cur2 CURSOR FOR
				SELECT t_id, subscription_fee, minutes_limit, pay_over_limit FROM Kirilov.Tariffs 
				WHERE subscription_fee > @f_subscription 
				ORDER BY subscription_fee 
				OPEN cur2
				FETCH NEXT FROM cur2 INTO @id2, @s_subscription, @s_minutes_limit, @s_pay_over_limit
				WHILE @@FETCH_STATUS = 0
					BEGIN
						SET @f_crossing_point = (@s_subscription - @f_subscription) / @f_pay_over_limit + @f_minutes_limit
						SET @s_crossing_point = (@f_subscription - @s_subscription + @s_minutes_limit * @s_pay_over_limit - @f_minutes_limit * @f_pay_over_limit) / (@s_pay_over_limit - @f_pay_over_limit)
						IF(@s_crossing_point > @s_minutes_limit)
							BEGIN
								INSERT INTO #Crossing_points
								VALUES ( @counter, CEILING(@s_crossing_point))
								SET @counter +=1
							END
						IF(@f_crossing_point < @s_minutes_limit)
							BEGIN
								INSERT INTO #Crossing_points
								VALUES ( @counter, CEILING(@f_crossing_point) )
								SET @counter +=1
							END
						FETCH NEXT FROM cur2 INTO @id2, @s_subscription, @s_minutes_limit, @s_pay_over_limit
					END
					CLOSE cur2
					DEALLOCATE cur2
			FETCH NEXT FROM cur1 INTO @id1, @f_subscription, @f_minutes_limit, @f_pay_over_limit
			END
		CLOSE cur1
		DEALLOCATE cur1
--		select * from #Crossing_points
		DECLARE cur3 CURSOR FOR
		SELECT coords FROM #Crossing_points ORDER BY coords
		OPEN cur3
		FETCH NEXT FROM cur3 INTO @f_coord
		WHILE(@@FETCH_STATUS = 0)
		BEGIN
			FETCH NEXT FROM cur3 INTO @s_coord

			IF (Kirilov.get_best_tarif(@f_coord) != Kirilov.get_best_tarif(@s_coord))
				BEGIN
					INSERT INTO #Limits
					VALUES ( CEILING(@f_coord), CEILING(@s_coord - 1),(SELECT tarif_name as Ëó÷øèé_òàðèô FROM Kirilov.Tariffs WHERE Kirilov.get_best_tarif(@f_coord) = t_id))
					SET @f_coord =  CEILING(@s_coord)

				END
		END
		INSERT INTO #Limits
		VALUES ( CEILING(@f_coord),44640,(SELECT tarif_name as Ëó÷øèé_òàðèô FROM Kirilov.Tariffs WHERE Kirilov.get_best_tarif(@f_coord) = t_id))
		CLOSE cur3
		DEALLOCATE cur3
		SELECT * FROM #Limits
GO

EXEC Timelimits
GO
