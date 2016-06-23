CREATE PROCEDURE [dbo].[uspSMMergeRole]
	@fromEntityId int = null,
	@toEntityId int = null
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRANSACTION

BEGIN TRY

	IF(@fromEntityId IS NOT NULL AND @toEntityId IS NOT NULL)
	BEGIN
		-- Merge Menu
		UPDATE RoleMenu SET ysnVisible = 1
		FROM tblSMUserRoleMenu RoleMenu
		INNER JOIN tblEMEntityToRole EntityToRole ON EntityToRole.intEntityRoleId = RoleMenu.intUserRoleId
		WHERE EntityToRole.intEntityId = @toEntityId AND RoleMenu.intMenuId IN 
		(
			SELECT intMenuId FROM tblEMEntityToRole EntityToRole
			INNER JOIN tblSMUserRoleMenu RoleMenu ON EntityToRole.intEntityRoleId = RoleMenu.intUserRoleId
			WHERE RoleMenu.ysnVisible = 1 AND EntityToRole.intEntityId = @fromEntityId
		)

		-- Unset and update Contact
		UPDATE UserRole SET strName = strName + '-' + CAST(@fromEntityId  AS VARCHAR) + ' ' + CONVERT(VARCHAR(8),GETDATE(),112), strDescription = strDescription + ' (merged)'
		FROM tblSMUserRole UserRole
		INNER JOIN tblEMEntityToRole EntityToRole ON EntityToRole.intEntityRoleId = UserRole.intUserRoleID
		WHERE UserRole.ysnAdmin = 0 AND EntityToRole.intEntityId = @fromEntityId

		-- Unset and update Contact Admin
		UPDATE UserRole SET ysnAdmin = 0, strRoleType = 'Contact', strName = strName + ' ' + CONVERT(VARCHAR(8),GETDATE(),112), strDescription = strDescription + ' (merged)'
		FROM tblSMUserRole UserRole
		INNER JOIN tblEMEntityToRole EntityToRole ON EntityToRole.intEntityRoleId = UserRole.intUserRoleID
		WHERE UserRole.ysnAdmin = 1 AND EntityToRole.intEntityId = @fromEntityId

		-- Commit changes
		GOTO uspSMMergeRole_Commit
	END
	
END TRY
BEGIN CATCH
	-- Rollback changes in case of errors
	GOTO uspSMMergeRole_Rollback
END CATCH

---------------------------------------
-----------  Exit Routines  -----------
---------------------------------------
uspSMMergeRole_Commit:
	COMMIT TRANSACTION
	GOTO uspSMMergeRole_Exit
	
uspSMMergeRole_Rollback:
	ROLLBACK TRANSACTION 
	
uspSMMergeRole_Exit: