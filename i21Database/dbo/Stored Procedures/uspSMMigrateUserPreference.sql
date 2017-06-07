CREATE PROCEDURE [dbo].[uspSMMigrateUserPreference]
AS
BEGIN

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMUserPreference)
	BEGIN
		DECLARE @testCountSMPreferences AS INT
		DECLARE @testCountSMUserPreference AS INT

		PRINT 'Start Insert'
		INSERT INTO [dbo].[tblSMUserPreference]
				   ([intEntityUserSecurityId]
				   ,[intOriginScreensLimit]
				   ,[ysnAllowUserSelfPost]
				   ,[ysnShowReminderList])
		SELECT entityId
				--, intEntityId
				, CAST(ISNULL(OriginScreensLimit, 0) AS INT) AS intOriginScreensLimit
				, CAST(AllowUserSelfPost AS BIT) AS ysnAllowUserSelfPost
				, CAST(ISNULL(isShowReminderList, 0) AS BIT) AS ysnisShowReminderList
		FROM (SELECT sec.[intEntityId] entityId--pref.intUserID userId
				, pref.strPreference colName
				, pref.strValue colVal
				FROM tblSMPreferences pref
				INNER JOIN dbo.tblSMUserSecurity sec ON pref.intUserID = sec.intUserSecurityIdOld
				WHERE pref.intUserID not in (-1, 0)
				and pref.strPreference in ('OriginScreensLimit', 'AllowUserSelfPost', 'isShowReminderList')
		) AS s
		PIVOT
		(	Max(colVal)
			FOR colName IN (OriginScreensLimit, AllowUserSelfPost, isShowReminderList)
		)AS pivotTable

		DELETE FROM dbo.tblSMPreferences
		WHERE intUserID IN 
		(
			SELECT intUserSecurityIdOld
			FROM dbo.tblSMUserPreference Preference
			INNER JOIN dbo.tblSMUserSecurity UserSecurity 
			ON Preference.intEntityUserSecurityId = UserSecurity.[intEntityId]
		)
		AND strPreference IN ('OriginScreensLimit', 'AllowUserSelfPost', 'isShowReminderList')

		PRINT 'End Insert'
	END

END