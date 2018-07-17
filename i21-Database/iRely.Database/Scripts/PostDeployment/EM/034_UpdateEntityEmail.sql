PRINT '*** Start Update Entity Email***'
IF NOT EXISTS(SELECT TOP 1 1 FROM [tblEMEntityPreferences] WHERE strPreference = 'Update Entity Email')
BEGIN
	PRINT '***Execute***'
	
	update tblEMEntity set strEmail = '' where strEmail is null


	INSERT INTO [tblEMEntityPreferences] ( strPreference, strValue)
	VALUES('Update Entity Email', 1)
END
PRINT '*** End Update Entity Email***'
