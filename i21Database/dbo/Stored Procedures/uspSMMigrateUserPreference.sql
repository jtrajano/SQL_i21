CREATE PROCEDURE [dbo].[uspSMMigrateUserPreference]
AS
BEGIN

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMUserPreference)
	BEGIN
		DECLARE @testCountSMPreferences AS INT
		DECLARE @testCountSMUserPreference AS INT

		SELECT @testCountSMPreferences = COUNT(DISTINCT intUserID) FROM dbo.tblSMPreferences
		SELECT @testCountSMUserPreference = COUNT(intUserSecurityId) FROM dbo.tblSMUserPreference

		PRINT 'Start Insert'
		PRINT CONCAT(@testCountSMPreferences, ' - tblSMPreferences')
		PRINT CONCAT(@testCountSMUserPreference, ' - tblSMUserPreference')

		INSERT INTO [dbo].[tblSMUserPreference]
				   ([intUserSecurityId]
				   ,[intOriginScreensLimit]
				   ,[ysnAllowUserSelfPost]
				   ,[ysnShowReminderList])
		SELECT userId
				--, intEntityId
				, CAST(ISNULL(OriginScreensLimit, 0) AS INT) AS intOriginScreensLimit
				, CAST(AllowUserSelfPost AS BIT) AS ysnAllowUserSelfPost
				, CAST(ISNULL(isShowReminderList, 0) AS BIT) AS ysnisShowReminderList
		FROM (SELECT pref.intUserID userId
				--, sec.intEntityId
				, pref.strPreference colName
				, pref.strValue colVal
				FROM tblSMPreferences pref
				--INNER JOIN dbo.tblSMUserSecurity sec ON pref.intUserID = sec.intUserSecurityID
				WHERE pref.intUserID not in (-1, 0)
				and pref.strPreference in ('OriginScreensLimit', 'AllowUserSelfPost', 'isShowReminderList')
		) AS s
		PIVOT
		(	Max(colVal)
			FOR colName IN (OriginScreensLimit, AllowUserSelfPost, isShowReminderList)
		)AS pivotTable

		DELETE FROM dbo.tblSMPreferences
		WHERE intUserID IN (SELECT intUserSecurityId from dbo.tblSMUserPreference)
		AND strPreference IN ('OriginScreensLimit', 'AllowUserSelfPost', 'isShowReminderList')

		PRINT 'End Insert'
		SELECT @testCountSMPreferences = COUNT(DISTINCT intUserID) FROM dbo.tblSMPreferences
		SELECT @testCountSMUserPreference = COUNT(intUserSecurityId) FROM dbo.tblSMUserPreference

		PRINT CONCAT(@testCountSMPreferences, ' - tblSMPreferences')
		PRINT CONCAT(@testCountSMUserPreference, ' - tblSMUserPreference')	
	END

END