GO
	PRINT N'BEGIN CLEAN UP PREFERENCES - update null intUserID to 0'
GO
	UPDATE tblSMPreferences
	SET intUserID = 0 
	WHERE intUserID is null
GO
	PRINT N'END CLEAN UP PREFERENCES - update null intUserID to 0'
GO