GO
	PRINT N'BEGIN INSERT VERSION UPDATE'
GO
	DELETE FROM tblSMBuildNumber
	WHERE strVersionNo = '' OR strVersionNo = NULL

	INSERT INTO tblSMBuildNumber (strVersionNo, dtmLastUpdate)
	SELECT '22.1', getdate()
GO
	PRINT N'END INSERT VERSION UPDATE'
GO