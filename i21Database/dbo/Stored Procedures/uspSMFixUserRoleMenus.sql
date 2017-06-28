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
DECLARE @IsDefaultPortal BIT

BEGIN TRANSACTION

BEGIN TRY
		-- Get whether User Role has administrative rights
		SELECT @IsAdmin = ysnAdmin FROM tblSMUserRole WHERE intUserRoleID = @UserRoleID
	    SELECT @IsContact = CASE strRoleType WHEN 'Contact Admin' THEN 1 ELSE (CASE strRoleType WHEN 'Contact' THEN 1 ELSE 0 END) END FROM tblSMUserRole WHERE intUserRoleID = @UserRoleID
		SELECT @IsDefaultPortal = CASE strRoleType WHEN 'Portal Default' THEN 1 ELSE 0 END FROM tblSMUserRole WHERE intUserRoleID = @UserRoleID

		-- C O N T A C T
		IF (@IsContact = 1 OR @IsDefaultPortal = 1)
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
												WHERE ((strMenuName NOT IN ('System Manager', 'Maintenance') AND strModuleName = 'System Manager' AND intParentMenuID = 1) 
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
				--DECLARE @HelpDeskParentMenuId INT
				--SELECT @HelpDeskParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Help Desk' AND strModuleName = 'Help Desk' AND intParentMenuID = 0

				--DECLARE @CreateTicketId INT
				--SELECT @CreateTicketId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = N'Create Ticket' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskParentMenuId
				--IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Create Ticket' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskParentMenuId)
				--BEGIN
				--	DELETE FROM tblSMUserRoleMenu WHERE intMenuId = @CreateTicketId AND intUserRoleId = @UserRoleID
				--END
				
				--DECLARE @OpenTicketsMenuId INT
				--SELECT  @OpenTicketsMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = N'Open Tickets' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskParentMenuId
				--IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Open Tickets' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskParentMenuId)
				--BEGIN
				--	DELETE FROM tblSMUserRoleMenu WHERE intMenuId = @OpenTicketsMenuId AND intUserRoleId = @UserRoleID
				--END					
				
				--DECLARE @TicketsReportedByMeMenuId INT
				--SELECT  @TicketsReportedByMeMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = N'Tickets Reported by Me' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskParentMenuId
				--IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Tickets Reported by Me' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskParentMenuId)
				--BEGIN
				--	DELETE FROM tblSMUserRoleMenu WHERE intMenuId = @TicketsReportedByMeMenuId AND intUserRoleId = @UserRoleID
				--END

				--DECLARE @ProjectListsId INT
				--SELECT @ProjectListsId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Project Lists' AND strModuleName = 'Help Desk' AND intParentMenuID = @HelpDeskParentMenuId
				--IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Project Lists' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskParentMenuId)
				--BEGIN
				--	DELETE FROM tblSMUserRoleMenu WHERE intMenuId = @ProjectListsId AND intUserRoleId = @UserRoleID
				--END

				/* PURCHASING */
				DECLARE @AccountsPayableParentMenuId INT
				SELECT @AccountsPayableParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Purchasing (Accounts Payable)' AND strModuleName = 'Accounts Payable' AND intParentMenuID = 0

				DECLARE @VendorMenuId INT
				SELECT  @VendorMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = N'Vendor' AND strModuleName = N'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId
				IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Vendor' AND strModuleName = N'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId)
				BEGIN
					DELETE FROM tblSMUserRoleMenu WHERE intMenuId = @VendorMenuId AND intUserRoleId = @UserRoleID
				END

				DECLARE @VendorContactListMenuId INT
				SELECT  @VendorContactListMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = N'Vendor Contact List' AND strModuleName = N'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId
				IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Vendor Contact List' AND strModuleName = N'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId)
				BEGIN
					DELETE FROM tblSMUserRoleMenu WHERE intMenuId = @VendorContactListMenuId AND intUserRoleId = @UserRoleID
				END

				/* SALES */
				DECLARE @AccountsReceivableParentMenuId INT
				SELECT @AccountsReceivableParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Sales (Accounts Receivable)' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = 0

				DECLARE @CustomerMenuId INT
				SELECT  @CustomerMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Customer' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId
				IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Customer' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId)
				BEGIN
					DELETE FROM tblSMUserRoleMenu WHERE intMenuId = @CustomerMenuId AND intUserRoleId = @UserRoleID
				END

				/* GRAIN */
				DECLARE @GrainParentMenuId INT
				SELECT @GrainParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Grain' AND strModuleName = 'Grain' AND intParentMenuID = 0

				DECLARE @StorageSettleMenuId INT
				SELECT  @StorageSettleMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Storage Settle' AND strModuleName = 'Grain' AND intParentMenuID = @GrainParentMenuId
				IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Storage Settle' AND strModuleName = 'Grain' AND intParentMenuID = @GrainParentMenuId)
				BEGIN
					DELETE FROM tblSMUserRoleMenu WHERE intMenuId = @StorageSettleMenuId AND intUserRoleId = @UserRoleID
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
