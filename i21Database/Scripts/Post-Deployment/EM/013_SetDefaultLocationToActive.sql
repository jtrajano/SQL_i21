
PRINT '*** Start set tblEntityLocation active location for default location***'
IF EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEntityLocation' and [COLUMN_NAME] = 'ysnActive')
AND EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEntityLocation' and [COLUMN_NAME] = 'ysnDefaultLocation')
AND NOT EXISTS(SELECT TOP 1 1 FROM tblEntityPreferences WHERE strPreference = 'Set active tblEntityLocation')

BEGIN
	PRINT '*** EXECUTING set tblEntityLocation active location for default location***'
	Exec('UPDATE tblEntityLocation SET ysnActive = ysnDefaultLocation')

	INSERT INTO tblEntityPreferences ( strPreference, strValue)
	VALUES('Set active tblEntityLocation', 1)

END
PRINT '*** End set tblEntityLocation active location for default location***'
