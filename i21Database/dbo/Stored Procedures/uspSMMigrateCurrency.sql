CREATE PROCEDURE [dbo].[uspSMMigrateCurrency]

AS

SET QUOTED_IdENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN
	INSERT INTO tblSMCurrency(strCurrency, strDescription, dblDailyRate, dblMinRate, dblMaxRate)
	SELECT sscur_key,
	sscur_desc,
	sscur_daily_rt,
	sscur_min_rt,
	sscur_max_rt
	FROM sscurmst
	WHERE RTRIM(sscur_key)COLLATE DATABASE_DEFAULT  NOT IN (SELECT strCurrency COLLATE DATABASE_DEFAULT  FROM tblSMCurrency)
END