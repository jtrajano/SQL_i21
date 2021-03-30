--THIS WILL UPDATE THE USER ROLES ENTITY SCREEN VISIBILITY TO ITS NEW PARENT MENU
--19.2 AP > Maintenance > Vendor Inquiry
--20.1 AP > Reports > Vendor Inquiry
--we need to apply its previous permission
--removed deletion in 1_MasterMenu.sql
PRINT 'Start Updating of User Roles for Entity Inquiry screen'

DECLARE @previousVersion NVARCHAR(100)

SELECT TOP 1 @previousVersion = strVersionNo FROM tblSMBuildNumber ORDER BY intVersionID DESC

IF ISNULL(@previousVersion, '') <> '' AND CHARINDEX('19.2', @previousVersion) > 0
BEGIN
	IF OBJECT_ID('tempdb..#TempSMUserRoleMenu') IS NOT NULL
		DROP TABLE #TempSMUserRoleMenu


	Create TABLE #TempSMUserRoleMenu
	(
		[intUserRoleMenuId]			INT		NOT NULL,
		[intUserRoleId]			INT		NOT NULL
	)

	

	--select the entity inquiry screen under maintenance group
	INSERT INTO #TempSMUserRoleMenu([intUserRoleMenuId], [intUserRoleId])
	SELECT [intUserRoleMenuId], [intUserRoleId]
	FROM tblSMUserRoleMenu menuRole
	INNER JOIN tblSMMasterMenu mainMenu on menuRole.intMenuId = mainMenu.intMenuID
	WHERE mainMenu.strCommand = 'EntityManagement.view.EntityInquiry?showSearch=true'
	AND mainMenu.intParentMenuID = (
		SELECT intMenuID FROM tblSMMasterMenu WHERE strModuleName = 'Accounts Payable' AND strMenuName = 'Maintenance' AND strType = 'Folder'
	)
	AND menuRole.ysnVisible = 1



	DECLARE role_cursor CURSOR FOR
	SELECT [intUserRoleMenuId], [intUserRoleId] FROM #TempSMUserRoleMenu

	
	DECLARE @intUserRoleMenuId INT 
	DECLARE @intUserRoleId INT
	DECLARE @intMenuIdForReport INT

	SELECT @intMenuIdForReport = intMenuID FROM tblSMMasterMenu WHERE strCommand = 'EntityManagement.view.EntityInquiry?showSearch=true'
	AND intParentMenuID = (
		SELECT intMenuID FROM tblSMMasterMenu WHERE strModuleName = 'Accounts Payable' AND strMenuName = 'Reports' AND strType = 'Folder'
	)
	
	IF ISNULL(@intMenuIdForReport, 0) <> 0
	BEGIN
		OPEN role_cursor
		FETCH NEXT FROM role_cursor into @intUserRoleMenuId, @intUserRoleId
		WHILE @@FETCH_STATUS = 0
		BEGIN
		
			UPDATE tblSMUserRoleMenu SET ysnVisible = 1 WHERE intUserRoleId = @intUserRoleId and intMenuId = @intMenuIdForReport

		FETCH NEXT FROM role_cursor into @intUserRoleMenuId, @intUserRoleId
		END
	END

	CLOSE role_cursor
	DEALLOCATE role_cursor
END


--DELETE menu under Maintenance group
DECLARE @AccountsPayableMaintenanceParentMenuId INT
SELECT @AccountsPayableMaintenanceParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'Accounts Payable'
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Vendor Inquiry' AND strModuleName = 'Accounts Payable' AND intParentMenuID =  @AccountsPayableMaintenanceParentMenuId)
	DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Vendor Inquiry' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableMaintenanceParentMenuId


--REFRESH menus
PRINT N'START REFRESHING USER ROLE MENUS'
	EXEC [uspSMRefreshUserRoleMenus]
PRINT N'END REFRESHING USER ROLE MENUS'






PRINT 'End Updating of User Roles for Entity Inquiry screen'