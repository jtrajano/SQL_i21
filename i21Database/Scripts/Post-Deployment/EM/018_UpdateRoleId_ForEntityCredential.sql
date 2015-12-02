﻿
PRINT '*** Start Adding User Role For Entity Cred***'
IF EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblSMUserRole' and [COLUMN_NAME] = 'strName')
	AND EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblSMUserRole' and [COLUMN_NAME] = 'strDescription')
	AND EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblSMUserRole' and [COLUMN_NAME] = 'strRoleType')
	AND EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblSMUserRole' and [COLUMN_NAME] = 'ysnAdmin')
	AND EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblSMUserRole' and [COLUMN_NAME] = 'intUserRoleID')
	
	AND EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEntityCredential' and [COLUMN_NAME] = 'intEntityRoleId')
	AND EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEntityCredential' and [COLUMN_NAME] = 'intEntityId')

	AND EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEntityToContact' and [COLUMN_NAME] = 'ysnPortalAccess')
	AND EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEntityToContact' and [COLUMN_NAME] = 'intEntityContactId')

	
	AND NOT EXISTS(SELECT TOP 1 1 FROM tblEntityPreferences WHERE strPreference = 'Adding User Role For Entity Cred')

BEGIN
	PRINT '*** EXECUTING  Adding User Role For Entity Cred***'
	Exec('
			declare @hid int
			select @hid = intUserRoleID 
				from tblSMUserRole 
					where strName = ''Help Desk'' and strDescription = ''Default contract role.'' and strRoleType = ''Contact'' and ysnAdmin = 0

			update tblEntityCredential set intEntityRoleId = @hid 	
				where intEntityId in (select intEntityContactId from tblEntityToContact where ysnPortalAccess = 1)
					and intEntityRoleId is null
	')

	INSERT INTO tblEntityPreferences ( strPreference, strValue)
	VALUES('Adding User Role For Entity Cred', 1)

END
PRINT '*** End Adding User Role For Entity Cred***'









