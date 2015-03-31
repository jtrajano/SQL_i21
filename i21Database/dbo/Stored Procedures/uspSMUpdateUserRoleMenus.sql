CREATE PROCEDURE [dbo].[uspSMUpdateUserRoleMenus]
	@UserRoleID INT,
	@BuildUserRole BIT = 1,
	@ForceVisibility BIT = 0
AS

SET QUOTED_IDENTIFIER OFF
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
		SELECT @UserRoleID, intMenuID, (CASE @IsAdmin WHEN 1
										THEN (CASE @ForceVisibility WHEN 1
											THEN 1
											ELSE ISNULL((SELECT ysnVisible FROM tblSMUserRoleMenu tmpA WHERE tmpA.intMenuId = Menu.intParentMenuID AND tmpA.intUserRoleId = @UserRoleID), 0) END)
										ELSE 0 END),
		intSort = intMenuID FROM tblSMMasterMenu Menu
		WHERE intMenuID NOT IN (SELECT intMenuId FROM tblSMUserRoleMenu WHERE intUserRoleId = @UserRoleID)
		
		IF (@IsAdmin = 0)
		BEGIN
			DELETE FROM tblSMUserRoleMenu
			WHERE intUserRoleId = @UserRoleID
			AND intMenuId IN (SELECT intMenuID FROM tblSMMasterMenu
								WHERE ((strMenuName = 'System Manager' 
										AND strCommand = 'i21' 
										AND intParentMenuID = 0)
										OR intParentMenuID IN (1, 10, (SELECT intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Announcements' AND intParentMenuID = 1))))
		END
		
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

		ParentConflicts:

		IF EXISTS (SELECT * FROM (
			SELECT RoleMenu.ysnVisible origVisible, 
				RoleMenu.intUserRoleMenuId,
				ysnVisible = (CASE WHEN EXISTS((SELECT TOP 1 1 FROM tblSMUserRoleMenu tmpA WHERE tmpA.intParentMenuId = RoleMenu.intUserRoleMenuId AND tmpA.intUserRoleId = @UserRoleID AND ysnVisible = 1)) THEN 1 
								WHEN Menu.ysnLeaf = 1 THEN RoleMenu.ysnVisible
								ELSE 0 END)
			FROM tblSMUserRoleMenu RoleMenu
			LEFT JOIN tblSMMasterMenu Menu ON Menu.intMenuID = RoleMenu.intMenuId
			WHERE RoleMenu.intUserRoleId = @UserRoleID
		) tblPatch
		WHERE origVisible <> ysnVisible)
		BEGIN

			UPDATE tblSMUserRoleMenu
			SET ysnVisible = tblPatch.ysnVisible
			FROM (
				SELECT 
					RoleMenu.intUserRoleMenuId,
					ysnVisible = (CASE WHEN EXISTS((SELECT TOP 1 1 FROM tblSMUserRoleMenu tmpA WHERE tmpA.intParentMenuId = RoleMenu.intUserRoleMenuId AND tmpA.intUserRoleId = @UserRoleID AND ysnVisible = 1)) THEN 1 
										WHEN Menu.ysnLeaf = 1 THEN RoleMenu.ysnVisible
										ELSE 0 END)
				FROM tblSMUserRoleMenu RoleMenu
				LEFT JOIN tblSMMasterMenu Menu ON Menu.intMenuID = RoleMenu.intMenuId
				WHERE RoleMenu.intUserRoleId = @UserRoleID
				) tblPatch
			WHERE tblPatch.intUserRoleMenuId = tblSMUserRoleMenu.intUserRoleMenuId
			AND intUserRoleId = @UserRoleID

			IF EXISTS (SELECT * FROM (
				SELECT RoleMenu.ysnVisible origVisible, 
					RoleMenu.intUserRoleMenuId,
					ysnVisible = (CASE WHEN EXISTS((SELECT TOP 1 1 FROM tblSMUserRoleMenu tmpA WHERE tmpA.intParentMenuId = RoleMenu.intUserRoleMenuId AND tmpA.intUserRoleId = @UserRoleID AND ysnVisible = 1)) THEN 1 
									WHEN Menu.ysnLeaf = 1 THEN RoleMenu.ysnVisible
									ELSE 0 END)
				FROM tblSMUserRoleMenu RoleMenu
				LEFT JOIN tblSMMasterMenu Menu ON Menu.intMenuID = RoleMenu.intMenuId
				WHERE RoleMenu.intUserRoleId = @UserRoleID
			) tblPatch
			WHERE origVisible <> ysnVisible)
			BEGIN
				GOTO ParentConflicts
			END
		END

	END
	
	---- Iterate through all affected user securities and apply Master Menus
	--WHILE EXISTS (SELECT TOP 1 1 FROM #tmpUserSecurities)
	--BEGIN
	--	SELECT TOP 1 @UserSecurityID = intUserSecurityID FROM #tmpUserSecurities
	--	print 'User ID :'
	--	print @UserSecurityID
	--	EXEC uspSMUpdateUserSecurityMenus @UserSecurityID, @ForceVisibility
		
	--	DELETE FROM #tmpUserSecurities WHERE intUserSecurityID = @UserSecurityID
	--END

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