
PRINT '*** Start set tblEMEntityLocation active location for default location***'
IF EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEMEntityLocation' and [COLUMN_NAME] = 'ysnActive')
AND EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEMEntityLocation' and [COLUMN_NAME] = 'ysnDefaultLocation')
AND NOT EXISTS(SELECT TOP 1 1 FROM [tblEMEntityPreferences] WHERE strPreference = 'Set active tblEMEntityLocation')

BEGIN
	PRINT '*** EXECUTING set tblEMEntityLocation active location for default location***'
	Exec('UPDATE tblEMEntityLocation SET ysnActive = isnull(ysnDefaultLocation, 0) where ysnActive is null')

	INSERT INTO [tblEMEntityPreferences] ( strPreference, strValue)
	VALUES('Set active tblEMEntityLocation', 1)

END
PRINT '*** End set tblEMEntityLocation active location for default location***'
