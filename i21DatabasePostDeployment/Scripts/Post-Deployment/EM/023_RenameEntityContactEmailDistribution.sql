
PRINT '*** Start Update Email Distribution 0001***'
IF EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEMEntity' and [COLUMN_NAME] = 'strEmailDistributionOption')
	AND NOT EXISTS(SELECT TOP 1 1 FROM [tblEMEntityPreferences] WHERE strPreference = 'Update Email Distribution 0001')

BEGIN
	PRINT '*** EXECUTING  Update Email Distribution 0001***'
	Exec('
		update tblEMEntity 
			set strEmailDistributionOption = REPLACE ( strEmailDistributionOption, ''Quotes'' , ''Transport Quote'' ) 
				where strEmailDistributionOption like ''%Quotes%''
	')

	INSERT INTO [tblEMEntityPreferences] ( strPreference, strValue)
	VALUES('Update Email Distribution 0001', 1)

END
PRINT '*** End Update Email Distribution 0001***'