﻿GO
	PRINT N'BEGIN CLEAN UP PREFERENCES - update null intUserID to 0'
GO
	IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.COLUMNS WHERE UPPER(COLUMN_NAME) = 'INTUSERID' and UPPER(TABLE_NAME) = 'TBLSMPREFERENCES') 
		EXEC('UPDATE tblSMPreferences SET intUserID = 0  WHERE intUserID is null')
GO
	PRINT N'END CLEAN UP PREFERENCES - update null intUserID to 0'
GO
	PRINT N'BEGIN Add default value for Terms Code'
GO
	IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.COLUMNS WHERE UPPER(COLUMN_NAME) = 'STRTERMCODE' and UPPER(TABLE_NAME) = 'TBLSMTERM')
		EXEC('UPDATE tblSMTerm SET strTermCode = REPLACE(strTerm, '' '', '''') + CAST(intTermID AS NVARCHAR) WHERE ISNULL(strTermCode, '''') = ''''')
GO
	PRINT N'END Add default value for Terms Code'
GO
	PRINT N'BEGIN Eliminate duplicate Terms Code'
GO
	IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.COLUMNS WHERE UPPER(COLUMN_NAME) = 'STRTERMCODE' and UPPER(TABLE_NAME) = 'TBLSMTERM')
		EXEC('UPDATE tblSMTerm SET strTermCode = REPLACE(strTerm, '' '', '''') + CAST(intTermID AS NVARCHAR) WHERE strTermCode IN ( SELECT strTermCode FROM tblSMTerm GROUP BY strTermCode HAVING COUNT(*) > 1 )')
GO
	PRINT N'END Eliminate duplicate Terms Code'
GO
	/* --------------------------------------- */
	/* - Update Admin to System Manager Menu - */
	/* --------------------------------------- */
	IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Admin' AND strModuleName = 'System Manager' AND intParentMenuID = 0)
	UPDATE tblSMMasterMenu
	SET strMenuName = 'System Manager', strDescription = 'System Manager'
	WHERE strMenuName = 'Admin' AND strModuleName = 'System Manager' AND intParentMenuID = 0
GO

	IF NOT EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblSMMasterMenu' AND [COLUMN_NAME] = 'strCategory') 
	BEGIN
		ALTER TABLE tblSMMasterMenu ADD strCategory NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL
	END

GO
	PRINT N'UPDATE PARENTING AND ICON TYPES'
	
	UPDATE child set intParentMenuID = parent.intParentMenuID,
	strCategory = CASE parent.strMenuName WHEN 'Activities' THEN 'Activity' ELSE CASE parent.strMenuName WHEN 'Reports' THEN 'Report' ELSE parent.strMenuName END END,
	strIcon = CASE parent.strMenuName WHEN 'Activities' THEN 'small-menu-activity'
	ELSE CASE parent.strMenuName WHEN 'Activity' THEN 'small-menu-activity'
	ELSE CASE parent.strMenuName WHEN 'Maintenance' THEN 'small-menu-maintenance' ELSE 'small-menu-report' END END END
	FROM tblSMMasterMenu child
	JOIN tblSMMasterMenu parent ON child.intParentMenuID = parent.intMenuID
	WHERE parent.strMenuName IN ('Activity', 'Activities', 'Maintenance', 'Reports')

	PRINT N'DELETE ALL ACTIVITIES, MAINTENANCE AND REPORTS FOLDER'
	
	DELETE FROM tblSMMasterMenu WHERE strType = 'Folder' AND strModuleName <> '' AND strMenuName in ('Activity', 'Activities', 'Maintenance', 'Reports')

	PRINT N'UPDATE PAYROLL AND INVENTORY SUBFOLDERS'
	UPDATE child SET intParentMenuID = parent.intParentMenuID,
	strCategory = 'Maintenance',
	strIcon = 'small-menu-maintenance'
	FROM tblSMMasterMenu child
	JOIN tblSMMasterMenu parent ON child.intParentMenuID = parent.intMenuID
	WHERE parent.strModuleName = 'Inventory' and parent.strMenuName  = 'RIN'
	
	UPDATE child SET intParentMenuID = parent.intParentMenuID,
	strCategory = 'Maintenance',
	strIcon = 'small-menu-maintenance'
	FROM tblSMMasterMenu child
	JOIN tblSMMasterMenu parent ON child.intParentMenuID = parent.intMenuID
	WHERE parent.strModuleName = 'Payroll' and parent.strMenuName  = 'Payroll Types'

	PRINT N'DELETE PAYROLL AND INVENTORY SUBFOLDERS'
	
	DELETE FROM tblSMMasterMenu WHERE strModuleName = 'Inventory' and strMenuName  = 'RIN'
	DELETE FROM tblSMMasterMenu WHERE strModuleName = 'Payroll' and strMenuName  = 'Payroll Types'


	PRINT N'UPDATE SYSTEM MANAGER MENUS'
	UPDATE child SET strCategory = 'Maintenance',
	strIcon = 'small-menu-maintenance'
	FROM tblSMMasterMenu child 
	JOIN tblSMMasterMenu parent ON child.intParentMenuID = parent.intMenuID
	WHERE parent.strMenuName = 'System Manager' AND parent.intMenuID = 1 AND child.strType = 'screen'

	UPDATE child SET strCategory = 'Maintenance',
	strIcon = 'small-menu-maintenance'
	FROM tblSMMasterMenu child 
	JOIN tblSMMasterMenu parent ON child.intParentMenuID = parent.intMenuID
	WHERE parent.strMenuName = 'Utilities' AND parent.intParentMenuID = 1

	UPDATE child SET strCategory = 'Maintenance',
	strIcon = 'small-menu-maintenance'
	FROM tblSMMasterMenu child 
	JOIN tblSMMasterMenu parent ON child.intParentMenuID = parent.intMenuID
	WHERE parent.strMenuName = 'Announcements' AND parent.intParentMenuID = 1

	PRINT N'UPDATE COMMON INFO MENUS'
	UPDATE child SET strCategory = 'Maintenance',
	strIcon = 'small-menu-maintenance'
	FROM tblSMMasterMenu child 
	JOIN tblSMMasterMenu parent ON child.intParentMenuID = parent.intMenuID
	WHERE parent.strMenuName = 'Common Info'

	PRINT N'UPDATE DASHBOARD MENUS'
	UPDATE child SET strCategory = 'Maintenance',
	strIcon = 'small-menu-maintenance'
	FROM tblSMMasterMenu child 
	JOIN tblSMMasterMenu parent ON child.intParentMenuID = parent.intMenuID
	WHERE parent.strMenuName = 'Dashboard'
	
GO