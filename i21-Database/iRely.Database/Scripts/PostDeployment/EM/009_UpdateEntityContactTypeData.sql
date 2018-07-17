PRINT '*** Update Contact Type ***'
IF NOT EXISTS (SELECT TOP 1 1 FROM [tblEMEntityPreferences] WHERE strPreference = 'Update Entity Type' AND strValue = '1')
BEGIN
	PRINT '*** Updating Contact Type ***'
	EXEC(
		'
			UPDATE tblEMEntity set strContactType = ''General'' where intEntityId in (SELECT DISTINCT intEntityContactId from tblEMEntityToContact) 
				and (strContactType = '''' OR strContactType is null)
	')
	INSERT INTO [tblEMEntityPreferences] ( strPreference, strValue)
	VALUES('Update Entity Type', '1' )
END
PRINT '*** End Update Contact Type ***'