CREATE PROCEDURE [dbo].[uspGRMigrateUserPreference]
AS
BEGIN

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGRUserPreference)
	BEGIN
		DECLARE @testCountSMPreferences AS INT
		DECLARE @testCountSMUserPreference AS INT

		SELECT @testCountSMPreferences = COUNT(DISTINCT intUserID) FROM dbo.tblSMPreferences
		SELECT @testCountSMUserPreference = COUNT(intUserSecurityId) FROM dbo.tblGRUserPreference

		PRINT 'Start Insert'
		PRINT CONCAT(@testCountSMPreferences, ' - tblSMPreferences')
		PRINT CONCAT(@testCountSMUserPreference, ' - tblGRUserPreference')

		INSERT INTO [dbo].[tblGRUserPreference]
				   ([intUserSecurityId]
				   ,[strQuoteProvider]
				   ,[strProviderUserId]
				   ,[strProviderPassword]
				   ,[strProviderAccessType])
		SELECT userId
				--, intEntityId
				, CAST(ISNULL(QuoteProvider, '') AS NVARCHAR) AS strQuoteProvider
				, CAST(ISNULL(ProviderUserId, '') AS NVARCHAR) AS strProviderUserId
				, CAST(ISNULL(ProviderPassword, '') AS NVARCHAR) AS strProviderPassword
				, CAST(ISNULL(ProviderAccessType, '') AS NVARCHAR) AS strProviderAccessType
		FROM (SELECT pref.intUserID userId
				--, sec.intEntityId
				, pref.strPreference colName
				, pref.strValue colVal
				FROM tblSMPreferences pref
				--INNER JOIN dbo.tblSMUserSecurity sec ON pref.intUserID = sec.intUserSecurityID
				WHERE pref.intUserID not in (-1, 0)
				and pref.strPreference in ('QuoteProvider', 'ProviderUserId', 'ProviderPassword', 'ProviderAccessType')
		) AS s
		PIVOT
		(	Max(colVal)
			FOR colName IN (DecimalDisplayOption, QuoteProvider, ProviderUserId, ProviderPassword, ProviderAccessType, DisplayOrder)
		)AS pivotTable

		DELETE FROM dbo.tblSMPreferences
		WHERE intUserID IN (SELECT intUserSecurityId from dbo.tblGRUserPreference)
		AND strPreference IN ('DecimalDisplayOption', 'QuoteProvider', 'ProviderUserId', 'ProviderPassword', 'ProviderAccessType', 'DisplayOrder')

		PRINT 'End Insert'
		SELECT @testCountSMPreferences = COUNT(DISTINCT intUserID) FROM dbo.tblSMPreferences
		SELECT @testCountSMUserPreference = COUNT(intUserSecurityId) FROM dbo.tblGRUserPreference

		PRINT CONCAT(@testCountSMPreferences, ' - tblSMPreferences')
		PRINT CONCAT(@testCountSMUserPreference, ' - tblGRUserPreference')	
	END

END