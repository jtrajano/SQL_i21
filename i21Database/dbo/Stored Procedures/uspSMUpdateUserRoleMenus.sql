CREATE PROCEDURE [dbo].[uspSMUpdateUserRoleMenus]
	@UserRoleID INT,
	@BuildUserRole BIT = 1
AS

SET QUOTED_IdENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @UserSecurityID INT
DECLARE @IsAdmin BIT

BEGIN TRANSACTION

-- Transfer affected User Securities to temporary list
SELECT intUserSecurityID
INTO #tmpUserSecurities
FROM tblSMUserSecurity
WHERE intUserRoleID = @UserRoleID

BEGIN TRY

	-- Get whether User Role has administrative rights
	SELECT @IsAdmin = ysnAdmin FROM tblSMUserRole WHERE intUserRoleID = @UserRoleID
	
	-- Check whether or not to build the specified user role according to the Master Menus
	IF (@BuildUserRole = 1)
	BEGIN
		-- Delete non existing User Role Menus for affected roles
		DELETE FROM tblSMUserRoleMenu
		WHERE intUserRoleId = @UserRoleID
		AND intMenuId NOT IN (SELECT intMenuID FROM tblSMMasterMenu)
		
		-- Iterate through all affected user roles and apply Master Menus
		INSERT INTO tblSMUserRoleMenu(intUserRoleId, intMenuId, ysnVisible, intSort)
		SELECT @UserRoleID, intMenuID, @IsAdmin, intSort = intMenuID FROM tblSMMasterMenu
		WHERE intMenuID NOT IN (SELECT intMenuId FROM tblSMUserRoleMenu WHERE intUserRoleId = @UserRoleID)
		
		UPDATE tblSMUserRoleMenu
		SET intParentMenuId = tblPatch.intRoleParentID
		FROM (
			SELECT 
				RoleMenu.intUserRoleMenuId,
				intRoleParentID = ISNULL((SELECT ISNULL(intUserRoleMenuId, 0) FROM tblSMUserRoleMenu tmpA WHERE tmpA.intMenuId = Menu.intParentMenuID AND tmpA.intUserRoleId = @UserRoleID), 0)
			FROM tblSMUserRoleMenu RoleMenu
			LEFT JOIN tblSMMasterMenu Menu ON Menu.intMenuID = RoleMenu.intMenuId
			WHERE RoleMenu.intUserRoleId = @UserRoleID
			)tblPatch 
		WHERE tblPatch.intUserRoleMenuId = tblSMUserRoleMenu.intUserRoleMenuId
		AND intUserRoleId = @UserRoleID
	END
	
	-- Iterate through all affected user securities and apply Master Menus
	WHILE EXISTS (SELECT TOP 1 1 FROM #tmpUserSecurities)
	BEGIN
		SELECT TOP 1 @UserSecurityID = intUserSecurityID FROM #tmpUserSecurities
		print 'User ID :'
		print @UserSecurityID
		EXEC uspSMUpdateUserSecurityMenus @UserSecurityID
		
		DELETE FROM #tmpUserSecurities WHERE intUserSecurityID = @UserSecurityID
	END

	-- Drop temporary tables
	DROP TABLE #tmpUserSecurities
	
	-- Commit changes
	GOTO uspSMUpdateUserRoleMenus_Commit
END TRY
BEGIN CATCH
	-- Rollback changes in case of errors
	GOTO uspSMUpdateUserRoleMenus_Rollback
END CATCH

---------------------------------------
-----------  Exit Routines  -----------
---------------------------------------
uspSMUpdateUserRoleMenus_Commit:
	COMMIT TRANSACTION
	GOTO uspSMUpdateUserRoleMenus_Exit
	
uspSMUpdateUserRoleMenus_Rollback:
	ROLLBACK TRANSACTION 
	
uspSMUpdateUserRoleMenus_Exit: