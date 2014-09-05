IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sscurmst]') AND type IN (N'U'))
BEGIN 
	EXEC('
		IF EXISTS (SELECT 1 FROM sys.objects WHERE name = ''uspSMMigrateCurrency'' and type = ''P'') 
			DROP PROCEDURE [dbo].[uspSMMigrateCurrency];
	')

	EXEC('
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
	
			DECLARE @intCurrencyId INT
	
			SELECT @intCurrencyId = intCurrencyID FROM tblSMCurrency WHERE strCurrency = (SELECT RTRIM(coctl_base_currency)COLLATE DATABASE_DEFAULT FROM coctlmst)
	
			IF NOT EXISTS(SELECT * FROM tblSMPreferences WHERE strPreference = ''defaultCurrency'' AND strValue IN (SELECT intCurrencyID FROM tblSMCurrency))
			BEGIN
				DELETE FROM tblSMPreferences WHERE strPreference = ''defaultCurrency''

				INSERT INTO tblSMPreferences(intUserID, strPreference, strDescription, strValue, intSort)
				VALUES (0, ''defaultCurrency'', ''defaultCurrency'', @intCurrencyId, 0)
			END
		END
	')
END 