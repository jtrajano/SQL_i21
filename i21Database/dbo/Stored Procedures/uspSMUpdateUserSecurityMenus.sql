CREATE PROCEDURE [dbo].[uspSMUpdateUserSecurityMenus]
	@UserSecurityID INT,
	@ForceVisibility BIT = 0
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRANSACTION


	DECLARE @UserRoleID INT
	SELECT @UserRoleID = intUserRoleID FROM tblSMUserSecurity 
	WHERE intUserSecurityID = @UserSecurityID
	
	DECLARE @IsAdmin BIT
	-- Get whether User Role has administrative rights
	SELECT @IsAdmin = ysnAdmin FROM tblSMUserRole WHERE intUserRoleID = @UserRoleID
	
	-- Delete non existing User Security Menus for affected users
	DELETE FROM tblSMUserSecurityMenu
	WHERE intUserSecurityId = @UserSecurityID
		AND intMenuId NOT IN (SELECT intMenuId FROM tblSMUserRoleMenu
								WHERE ysnVisible = 1 AND intUserRoleId = @UserRoleID)
	
	-- Apply User Role Menus into User Menus
	INSERT INTO tblSMUserSecurityMenu(intUserSecurityId, intMenuId, ysnVisible, intSort)
	SELECT @UserSecurityID, intMenuId, @IsAdmin, intSort = intMenuId FROM tblSMUserRoleMenu
	WHERE ysnVisible = 1 
		AND intMenuId NOT IN (SELECT intMenuId FROM tblSMUserSecurityMenu 
								WHERE intUserSecurityId = @UserSecurityID)
		AND intUserRoleId = @UserRoleID
	
	IF (@IsAdmin = 0)
	BEGIN
		DELETE FROM tblSMUserSecurityMenu
		WHERE intUserSecurityId = @UserSecurityID
		AND intMenuId IN (SELECT intMenuID FROM tblSMMasterMenu
							WHERE ((strMenuName = 'Admin' 
									AND strCommand = 'i21' 
									AND intParentMenuID = 0) 
								OR intParentMenuID IN (1, 10)))
	END
	
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
	
	IF (@ForceVisibility = 1)
		UPDATE tblSMUserSecurityMenu
		SET ysnVisible = 1
		WHERE intUserSecurityId = @UserSecurityID
	
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