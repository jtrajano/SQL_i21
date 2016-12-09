PRINT('Set to Inactive all invalid archived reports - Start')
IF EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE UPPER(TABLE_NAME) = 'TBLSRARCHIVE' AND [COLUMN_NAME] = 'strModule') 
BEGIN
	EXEC ('UPDATE tblSRArchive SET ysnIsActive = 0 WHERE strModule = '''' OR strModule IS NULL')
END
GO
PRINT('Set to Inactive all invalid archived reports - End')