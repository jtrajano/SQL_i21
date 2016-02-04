CREATE PROCEDURE [dbo].[uspSMFixUserRoleMenus]
	@UserRoleID INT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @IsAdmin BIT
DECLARE @IsContact BIT

BEGIN TRANSACTION

BEGIN TRY
		-- Get whether User Role has administrative rights
		SELECT @IsAdmin = ysnAdmin FROM tblSMUserRole WHERE intUserRoleID = @UserRoleID
	    SELECT @IsContact = CASE strRoleType WHEN 'Contact Admin' THEN 1 ELSE (CASE strRoleType WHEN 'Contact' THEN 1 ELSE 0 END) END FROM tblSMUserRole WHERE intUserRoleID = @UserRoleID
		
		-- C O N T A C T
		IF (@IsContact = 1)
			BEGIN
				-- DELETE USER MENUS
				DELETE FROM tblSMUserRoleMenu WHERE intMenuId NOT IN (SELECT intMasterMenuId FROM tblSMContactMenu) AND intUserRoleId = @UserRoleID

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
				ELSE
					BEGIN
						DELETE FROM tblSMUserRoleMenu
						WHERE intUserRoleId = @UserRoleID
						AND intMenuId IN (SELECT intMenuID
												FROM tblSMMasterMenu
												WHERE ((strMenuName NOT IN ('System Manager', 'User Roles') AND strModuleName = 'System Manager' AND intParentMenuID = 1) 
												OR intParentMenuID IN (10, (SELECT intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Announcements' AND intParentMenuID = 1))))
					END
			END
		ELSE -- U S E R 
			BEGIN
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
				-- DELETE CONTACT MENUS

				/* HELP DESK */
				DECLARE @HelpDeskParentMenuId INT
				SELECT @HelpDeskParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Help Desk' AND strModuleName = 'Help Desk' AND intParentMenuID = 0

				DECLARE @CreateTicketId INT
				SELECT @CreateTicketId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = N'Create Ticket' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskParentMenuId
				IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Create Ticket' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskParentMenuId)
				BEGIN
					DELETE FROM tblSMUserRoleMenu WHERE intMenuId = @CreateTicketId AND intUserRoleId = @UserRoleID
				END					
				
				DECLARE @ProjectListsId INT
				SELECT @ProjectListsId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Project Lists' AND strModuleName = 'Help Desk' AND intParentMenuID = @HelpDeskParentMenuId
				IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Project Lists' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskParentMenuId)
				BEGIN
					DELETE FROM tblSMUserRoleMenu WHERE intMenuId = @ProjectListsId AND intUserRoleId = @UserRoleID
				END
			END
		
	-- Commit changes
	GOTO uspSMFixUserRoleMenus_Commit
END TRY
BEGIN CATCH
	-- Rollback changes in case of errors
	GOTO uspSMFixUserRoleMenus_Rollback
END CATCH

---------------------------------------
-----------  Exit Routines  -----------
---------------------------------------
uspSMFixUserRoleMenus_Commit:
	COMMIT TRANSACTION
	GOTO uspSMFixUserRoleMenus_Exit
	
uspSMFixUserRoleMenus_Rollback:
	ROLLBACK TRANSACTION 
	
uspSMFixUserRoleMenus_Exit:
