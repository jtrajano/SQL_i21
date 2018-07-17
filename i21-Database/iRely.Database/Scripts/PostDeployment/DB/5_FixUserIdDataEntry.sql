
PRINT '*** Start Remove Email To Parent Entity***'
IF EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblDBPanel' and [COLUMN_NAME] = 'intUserId')
	AND EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblDBPanelAccess' and [COLUMN_NAME] = 'intUserId')	
	AND EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblDBPanelColumn' and [COLUMN_NAME] = 'intUserId')
	AND EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblDBPanelColumn' and [COLUMN_NAME] = 'strUserName')	
	AND EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblDBPanelFormat' and [COLUMN_NAME] = 'intUserId')	
	AND EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblDBPanelTab' and [COLUMN_NAME] = 'intUserId')	
	AND EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblDBPanelUser' and [COLUMN_NAME] = 'intUserId')	
	AND NOT EXISTS(SELECT TOP 1 1 FROM [tblEMEntityPreferences] WHERE strPreference = 'Update DB UserId From Parent Entity')

BEGIN
	PRINT '*** EXECUTING  Update DB UserId From Parent Entity***'
	
	IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE' AND TABLE_NAME='tblDBPanel')
		BEGIN
			IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE' AND TABLE_NAME='tblSMUserSecurity')
			BEGIN
				Update
					a set
					a.intUserId = b.[intEntityId]
				from
					tblDBPanel a, tblSMUserSecurity b
				where
					a.intUserId = b.intUserSecurityIdOld
					and b.intUserSecurityIdOld is not null
					and a.intUserId != 0
			END
		END
	
	IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE' AND TABLE_NAME='tblDBPanelAccess')
		BEGIN
			IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE' AND TABLE_NAME='tblSMUserSecurity')
			BEGIN
				Update
					a set
					a.intUserId = b.[intEntityId]
				from
					tblDBPanelAccess a, tblSMUserSecurity b
				where
					a.intUserId = b.intUserSecurityIdOld
					and b.intUserSecurityIdOld is not null
					and a.intUserId != 0
			END
		END

	IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE' AND TABLE_NAME='tblDBPanelColumn')
		BEGIN
			IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE' AND TABLE_NAME='tblSMUserSecurity')
			BEGIN
				Update
					a set
					a.intUserId = b.[intEntityId]
					,a.strUserName = b.strUserName
				from
					tblDBPanelColumn a, tblSMUserSecurity b
				where
					a.intUserId = b.intUserSecurityIdOld
					and b.intUserSecurityIdOld is not null
					and a.intUserId != 0
			END
		END

	IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE' AND TABLE_NAME='tblDBPanelFormat')
		BEGIN
			IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE' AND TABLE_NAME='tblSMUserSecurity')
			BEGIN
				Update
					a set
					a.intUserId = b.[intEntityId]
				from
					tblDBPanelFormat a, tblSMUserSecurity b
				where
					a.intUserId = b.intUserSecurityIdOld
					and b.intUserSecurityIdOld is not null
					and a.intUserId != 0
			END
		END
		
	IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE' AND TABLE_NAME='tblDBPanelTab')
		BEGIN
			IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE' AND TABLE_NAME='tblSMUserSecurity')
			BEGIN
				Update
					a set
					a.intUserId = b.[intEntityId]
				from
					tblDBPanelTab a, tblSMUserSecurity b
				where
					a.intUserId = b.intUserSecurityIdOld
					and b.intUserSecurityIdOld is not null
					and a.intUserId != 0
			END
		END

	IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE' AND TABLE_NAME='tblDBPanelUser')
		BEGIN
			IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE' AND TABLE_NAME='tblSMUserSecurity')
			BEGIN
				Update
					a set
					a.intUserId = b.[intEntityId]
				from
					tblDBPanelUser a, tblSMUserSecurity b
				where
					a.intUserId = b.intUserSecurityIdOld
					and b.intUserSecurityIdOld is not null
					and a.intUserId != 0
			END
		END
	
	IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE' AND TABLE_NAME='tblDBUserPreference')
		BEGIN
			IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE' AND TABLE_NAME='tblSMUserSecurity')
			BEGIN
				Delete tblDBUserPreference where intEntityUserSecurityId in (Select intEntityIdOld from tblSMUserSecurity) 

				Update
					a set
					a.intEntityUserSecurityId = b.[intEntityId]
				from
					tblDBUserPreference a, tblSMUserSecurity b
				where
					a.intEntityUserSecurityId = b.intUserSecurityIdOld
					and b.intUserSecurityIdOld is not null
					and a.intEntityUserSecurityId != 0
			END
		END		
		

	INSERT INTO [tblEMEntityPreferences] ( strPreference, strValue)
	VALUES('Update DB UserId From Parent Entity', 1)

END
PRINT '*** End Update DB UserId From Parent Entity***'