
PRINT '*** Start Remove Email To Parent Entity***'
IF EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEntity' and [COLUMN_NAME] = 'strEmail')	
	AND NOT EXISTS(SELECT TOP 1 1 FROM tblEntityPreferences WHERE strPreference = 'Remove Email To Parent Entity')

BEGIN
	PRINT '*** EXECUTING  Remove Email To Parent Entity***'
	Exec('
		UPDATE tblEntity set strEmail = null 
			WHERE intEntityId in (select distinct intEntityId from tblEntityType)
	')

	INSERT INTO tblEntityPreferences ( strPreference, strValue)
	VALUES('Remove Email To Parent Entity', 1)

END
PRINT '*** End Remove Email To Parent Entity***'