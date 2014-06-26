GO
	PRINT N'BEGIN CLEAN UP PREFERENCES - update null intUserID to 0'
GO
	IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.COLUMNS WHERE UPPER(COLUMN_NAME) = 'INTUSERID' and UPPER(TABLE_NAME) = 'TBLSMPREFERENCES') 
		EXEC('UPDATE tblSMPreferences SET intUserID = 0  WHERE intUserID is null')
GO
	PRINT N'END CLEAN UP PREFERENCES - update null intUserID to 0'
GO
	PRINT N'BEGIN Add default value for Terms Code'
GO
	UPDATE tblSMTerm
	SET strTermCode = REPLACE(strTerm, ' ', '') + CAST(intTermID AS NVARCHAR)
	WHERE ISNULL(strTermCode, '') = ''
GO
	PRINT N'END Add default value for Terms Code'
GO
	PRINT N'BEGIN Eliminate duplicate Terms Code'
GO
	UPDATE tblSMTerm
	SET strTermCode = REPLACE(strTerm, ' ', '') + CAST(intTermID AS NVARCHAR)
	WHERE strTermCode IN (
		SELECT strTermCode FROM tblSMTerm
		GROUP BY strTermCode
		HAVING COUNT(*) > 1
	)
GO
	PRINT N'END Eliminate duplicate Terms Code'
GO