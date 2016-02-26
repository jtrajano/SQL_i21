﻿
PRINT '*** Start Update Email Distribution 0001***'
IF EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEntity' and [COLUMN_NAME] = 'strEmailDistributionOption')
	AND NOT EXISTS(SELECT TOP 1 1 FROM tblEntityPreferences WHERE strPreference = 'Update Email Distribution 0001')

BEGIN
	PRINT '*** EXECUTING  Update Email Distribution 0001***'
	Exec('
		update tblEntity 
			set strEmailDistributionOption = REPLACE ( strEmailDistributionOption, ''Quotes'' , ''Transport Quote'' ) 
				where strEmailDistributionOption like ''%Quotes%''
	')

	INSERT INTO tblEntityPreferences ( strPreference, strValue)
	VALUES('Update Email Distribution 0001', 1)

END
PRINT '*** End Update Email Distribution 0001***'