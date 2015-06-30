PRINT '*** Update Contact Type ***'
IF NOT EXISTS (SELECT TOP 1 1 FROM tblEntityPreferences WHERE strPreference = 'Update Entity Type' AND strValue = '1')
BEGIN
	PRINT '*** Updating Contact Type ***'
	EXEC(
		'
			UPDATE tblEntity set strContactType = ''General'' where intEntityId in (SELECT DISTINCT intEntityContactId from tblEntityToContact) 
				and (strContactType = '''' OR strContactType is null)
	')
	INSERT INTO tblEntityPreferences ( strPreference, strValue)
	VALUES('Update Entity Type', '1' )
END
PRINT '*** End Update Contact Type ***'