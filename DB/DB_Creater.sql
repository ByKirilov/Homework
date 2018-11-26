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