CREATE PROCEDURE [dbo].[uspSMBuildSecurityMenus]
	@AdministratorOnly BIT = 1
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @UserRoleID INT

BEGIN TRANSACTION

-- Transfer affected User Roles to temporary list
SELECT intUserRoleID
INTO #tmpUserRoles
FROM tblSMUserRole
WHERE ((ysnAdmin = 1) OR @AdministratorOnly = 0)

--Update Root Folder Menus parent to zero (0)
UPDATE tblSMMasterMenu
SET intParentMenuID = 0
WHERE ISNULL(intParentMenuID, 0) = 0

BEGIN TRY

	-- Iterate through all affected user roles and apply Master Menus
	WHILE EXISTS (SELECT TOP 1 1 FROM #tmpUserRoles)
	BEGIN
		SELECT TOP 1 @UserRoleID = intUserRoleID FROM #tmpUserRoles
		
		print @UserRoleID
		
		EXEC uspSMUpdateUserRoleMenus @UserRoleID, @ForceVisibility = 1
		
		DELETE FROM #tmpUserRoles WHERE intUserRoleID = @UserRoleID
	END
	
	-- Drop temporary tables
	DROP TABLE #tmpUserRoles
	
	-- Commit changes
	GOTO uspSMBuildSecurityMenus_Commit
END TRY
BEGIN CATCH
	-- Rollback changes in case of errors
	GOTO uspSMBuildSecurityMenus_Rollback
END CATCH

---------------------------------------
-----------  Exit Routines  -----------
---------------------------------------
uspSMBuildSecurityMenus_Commit:
	COMMIT TRANSACTION
	GOTO uspSMBuildSecurityMenus_Exit
	
uspSMBuildSecurityMenus_Rollback:
	ROLLBACK TRANSACTION 
	
uspSMBuildSecurityMenus_Exit: