
PRINT '*** Start Remove Email To Parent Entity***'
IF EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEMEntity' and [COLUMN_NAME] = 'strEmail')	
	AND NOT EXISTS(SELECT TOP 1 1 FROM [tblEMEntityPreferences] WHERE strPreference = 'Remove Email To Parent Entity')

BEGIN
	PRINT '*** EXECUTING  Remove Email To Parent Entity***'
	Exec('
		UPDATE tblEMEntity set strEmail = null 
			WHERE intEntityId in (select distinct intEntityId from tblEMEntityType)
	')

	INSERT INTO [tblEMEntityPreferences] ( strPreference, strValue)
	VALUES('Remove Email To Parent Entity', 1)

END
PRINT '*** End Remove Email To Parent Entity***'