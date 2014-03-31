CREATE PROCEDURE [dbo].[uspSMUpdateUserSecurityMenus]
	@UserSecurityID INT
AS

SET QUOTED_IdENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRANSACTION



	DECLARE @UserRoleID INT
	SELECT @UserRoleID = intUserRoleID FROM tblSMUserSecurity 
	WHERE intUserSecurityID = @UserSecurityID

	-- Delete non existing User Security Menus for affected users
	DELETE FROM tblSMUserSecurityMenu
	WHERE intUserSecurityId = @UserSecurityID
		AND intMenuId NOT IN (SELECT intMenuId FROM tblSMUserRoleMenu
								WHERE ysnVisible = 1 AND intUserRoleId = @UserRoleID)
	
	-- Apply User Role Menus into User Menus
	INSERT INTO tblSMUserSecurityMenu(intUserSecurityId, intMenuId, ysnVisible, intSort)
	SELECT @UserSecurityID, intMenuId, ysnVisible = 1, intSort = intMenuId FROM tblSMUserRoleMenu
	WHERE ysnVisible = 1 
		AND intMenuId NOT IN (SELECT intMenuId FROM tblSMUserSecurityMenu 
								WHERE intUserSecurityId = @UserSecurityID)
		AND intUserRoleId = @UserRoleID
	
	UPDATE tblSMUserSecurityMenu
	SET intParentMenuId = tblPatch.intUserParentID
	FROM (
		SELECT 
			UserMenu.intUserSecurityMenuId,
			intUserParentID = ISNULL((SELECT ISNULL(intUserSecurityMenuId, 0) FROM tblSMUserSecurityMenu tmpA WHERE tmpA.intMenuId = Menu.intParentMenuID AND tmpA.intUserSecurityId = @UserSecurityID), 0)
		FROM tblSMUserSecurityMenu UserMenu
		LEFT JOIN tblSMMasterMenu Menu ON Menu.intMenuID = UserMenu.intMenuId
		WHERE UserMenu.intUserSecurityId = @UserSecurityID
		)tblPatch 
	WHERE tblPatch.intUserSecurityMenuId = tblSMUserSecurityMenu.intUserSecurityMenuId
	AND tblSMUserSecurityMenu.intUserSecurityId = @UserSecurityID
	
	-- Commit changes
	GOTO uspSMUpdateUserSecurityMenus_Commit
--END TRY
--BEGIN CATCH
--	-- Rollback changes in case of errors
--	GOTO uspSMUpdateUserSecurityMenus_Rollback
--END CATCH

---------------------------------------
-----------  Exit Routines  -----------
---------------------------------------
uspSMUpdateUserSecurityMenus_Commit:
	COMMIT TRANSACTION
	GOTO uspSMUpdateUserSecurityMenus_Exit
	
uspSMUpdateUserSecurityMenus_Rollback:
	ROLLBACK TRANSACTION 
	
uspSMUpdateUserSecurityMenus_Exit: