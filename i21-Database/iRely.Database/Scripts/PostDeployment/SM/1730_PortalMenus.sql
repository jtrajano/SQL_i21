GO
	/* UPDATE PORTAL MENUS */
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMigrationLog WHERE strModule = 'System Manager' AND strEvent = 'Update Portal Menus (System Manager) - 1730')
	BEGIN

		EXEC 
		('
			IF EXISTS(select top 1 1 from sys.procedures where name = ''uspSMUpdateContactMenus'')
			DROP PROCEDURE uspSMUpdateContactMenus
		')

		EXEC
		('
			CREATE PROCEDURE [dbo].[uspSMUpdateContactMenus]
			@userRoleId INT
			AS
			BEGIN
	
			EXEC uspSMUpdateUserRoleMenus @userRoleId

			/* ACCOUNT */
			-- My Account
			-- My Company

			--IF EXISTS(SELECT TOP 1 1 FROM tblSMUserRoleMenu rm INNER JOIN tblSMMasterMenu mm ON rm.intMenuId = mm.intMenuID WHERE intUserRoleId = @userRoleId AND strMenuName = ''Customer Contact List'')
			--BEGIN
			--	UPDATE roleMenu SET ysnVisible =
			--	(
			--		SELECT COUNT(*) FROM tblSMUserRoleMenu rm INNER JOIN tblSMMasterMenu mm ON rm.intMenuId = mm.intMenuID WHERE intUserRoleId = @userRoleId AND rm.ysnVisible = 1 AND strMenuName = ''Customer Contact List''
			--	)
			--	FROM tblSMUserRoleMenu roleMenu
			--	INNER JOIN tblSMMasterMenu masterMenu ON roleMenu.intMenuId = masterMenu.intMenuID
			--	WHERE masterMenu.strMenuName = ''User List (Portal)'' AND strDescription = ''Sales - User List'' AND intUserRoleId = @userRoleId
			--END

			--IF EXISTS(SELECT TOP 1 1 FROM tblSMUserRoleMenu rm INNER JOIN tblSMMasterMenu mm ON rm.intMenuId = mm.intMenuID WHERE intUserRoleId = @userRoleId AND strMenuName = ''Vendor Contact List'')
			--BEGIN
			--	UPDATE roleMenu SET ysnVisible =
			--	(
			--		SELECT COUNT(*) FROM tblSMUserRoleMenu rm INNER JOIN tblSMMasterMenu mm ON rm.intMenuId = mm.intMenuID WHERE intUserRoleId = @userRoleId AND rm.ysnVisible = 1 AND strMenuName = ''Vendor Contact List''
			--	)
			--	FROM tblSMUserRoleMenu roleMenu
			--	INNER JOIN tblSMMasterMenu masterMenu ON roleMenu.intMenuId = masterMenu.intMenuID
			--	WHERE masterMenu.strMenuName = ''User List (Portal)'' AND strDescription = ''Purchasing - User List'' AND intUserRoleId = @userRoleId
			--END

			IF EXISTS(SELECT TOP 1 1 FROM tblSMUserRoleMenu rm INNER JOIN tblSMMasterMenu mm ON rm.intMenuId = mm.intMenuID WHERE intUserRoleId = @userRoleId AND strMenuName IN (''Customer Contact List'', ''Vendor Contact List''))
			BEGIN
				UPDATE roleMenu SET ysnVisible =
				(
					SELECT COUNT(*) FROM tblSMUserRoleMenu rm INNER JOIN tblSMMasterMenu mm ON rm.intMenuId = mm.intMenuID WHERE intUserRoleId = @userRoleId AND rm.ysnVisible = 1 AND strMenuName IN (''Customer Contact List'', ''Vendor Contact List'')
				)
				FROM tblSMUserRoleMenu roleMenu
				INNER JOIN tblSMMasterMenu masterMenu ON roleMenu.intMenuId = masterMenu.intMenuID
				WHERE masterMenu.strMenuName = ''User List (Portal)'' AND intUserRoleId = @userRoleId
			END

			IF EXISTS(SELECT TOP 1 1 FROM tblSMUserRoleMenu rm INNER JOIN tblSMMasterMenu mm ON rm.intMenuId = mm.intMenuID WHERE intUserRoleId = @userRoleId AND strMenuName = ''User Roles'')
			BEGIN
				UPDATE roleMenu SET ysnVisible = 
				(
					SELECT COUNT(*) FROM tblSMUserRoleMenu rm INNER JOIN tblSMMasterMenu mm ON rm.intMenuId = mm.intMenuID WHERE intUserRoleId = @userRoleId AND rm.ysnVisible = 1 AND strMenuName = ''User Roles''
				)
				FROM tblSMUserRoleMenu roleMenu
				INNER JOIN tblSMMasterMenu masterMenu ON roleMenu.intMenuId = masterMenu.intMenuID
				WHERE masterMenu.strMenuName = ''Set Permissions (Portal)'' AND intUserRoleId = @userRoleId
			END
	
			-- Payment Methods
			-- Change Password
	
			/* TRANSACTIONS */
			IF EXISTS(SELECT TOP 1 1 FROM tblSMUserRoleMenu rm INNER JOIN tblSMMasterMenu mm ON rm.intMenuId = mm.intMenuID WHERE intUserRoleId = @userRoleId AND strMenuName = ''Purchase Orders'')
			BEGIN
				UPDATE roleMenu SET ysnVisible =
				(
					SELECT COUNT(*) FROM tblSMUserRoleMenu rm INNER JOIN tblSMMasterMenu mm ON rm.intMenuId = mm.intMenuID WHERE intUserRoleId = @userRoleId AND rm.ysnVisible = 1 AND strMenuName = ''Purchase Orders''
				)
				FROM tblSMUserRoleMenu roleMenu
				INNER JOIN tblSMMasterMenu masterMenu ON roleMenu.intMenuId = masterMenu.intMenuID
				WHERE masterMenu.strMenuName = ''Purchase Orders (Portal)'' AND intUserRoleId = @userRoleId
			END

			IF EXISTS(SELECT TOP 1 1 FROM tblSMUserRoleMenu rm INNER JOIN tblSMMasterMenu mm ON rm.intMenuId = mm.intMenuID WHERE intUserRoleId = @userRoleId AND strMenuName = ''Sales Orders'')
			BEGIN
				UPDATE roleMenu SET ysnVisible =
				(
					SELECT COUNT(*) FROM tblSMUserRoleMenu rm INNER JOIN tblSMMasterMenu mm ON rm.intMenuId = mm.intMenuID WHERE intUserRoleId = @userRoleId AND rm.ysnVisible = 1 AND strMenuName = ''Sales Orders''
				)
				FROM tblSMUserRoleMenu roleMenu
				INNER JOIN tblSMMasterMenu masterMenu ON roleMenu.intMenuId = masterMenu.intMenuID
				WHERE masterMenu.strMenuName = ''Sales Orders (Portal)'' AND intUserRoleId = @userRoleId
			END

			IF EXISTS(SELECT TOP 1 1 FROM tblSMUserRoleMenu rm INNER JOIN tblSMMasterMenu mm ON rm.intMenuId = mm.intMenuID WHERE intUserRoleId = @userRoleId AND strMenuName = ''Vouchers'')
			BEGIN
				UPDATE roleMenu SET ysnVisible =
				(
					SELECT COUNT(*) FROM tblSMUserRoleMenu rm INNER JOIN tblSMMasterMenu mm ON rm.intMenuId = mm.intMenuID WHERE intUserRoleId = @userRoleId AND rm.ysnVisible = 1 AND strMenuName = ''Vouchers''
				)
				FROM tblSMUserRoleMenu roleMenu
				INNER JOIN tblSMMasterMenu masterMenu ON roleMenu.intMenuId = masterMenu.intMenuID
				WHERE masterMenu.strMenuName = ''Vouchers (Portal)'' AND intUserRoleId = @userRoleId
			END

			IF EXISTS(SELECT TOP 1 1 FROM tblSMUserRoleMenu rm INNER JOIN tblSMMasterMenu mm ON rm.intMenuId = mm.intMenuID WHERE intUserRoleId = @userRoleId AND strMenuName = ''Invoices'')
			BEGIN
				UPDATE roleMenu SET ysnVisible =
				(
					SELECT COUNT(*) FROM tblSMUserRoleMenu rm INNER JOIN tblSMMasterMenu mm ON rm.intMenuId = mm.intMenuID WHERE intUserRoleId = @userRoleId AND rm.ysnVisible = 1 AND strMenuName = ''Invoices''
				)
				FROM tblSMUserRoleMenu roleMenu
				INNER JOIN tblSMMasterMenu masterMenu ON roleMenu.intMenuId = masterMenu.intMenuID
				WHERE masterMenu.strMenuName = ''Invoices (Portal)'' AND intUserRoleId = @userRoleId
			END

			-- Make a Payment
			-- Payment History

			IF EXISTS(SELECT TOP 1 1 FROM tblSMUserRoleMenu rm INNER JOIN tblSMMasterMenu mm ON rm.intMenuId = mm.intMenuID WHERE intUserRoleId = @userRoleId AND strMenuName = ''Contracts'')
			BEGIN
				UPDATE roleMenu SET ysnVisible =
				(
					SELECT COUNT(*) FROM tblSMUserRoleMenu rm INNER JOIN tblSMMasterMenu mm ON rm.intMenuId = mm.intMenuID WHERE intUserRoleId = @userRoleId AND rm.ysnVisible = 1 AND strMenuName = ''Contracts''
				)
				FROM tblSMUserRoleMenu roleMenu
				INNER JOIN tblSMMasterMenu masterMenu ON roleMenu.intMenuId = masterMenu.intMenuID
				WHERE masterMenu.strMenuName = ''Contracts (Portal)'' AND intUserRoleId = @userRoleId
			END

			/* SUPPORT */
			IF EXISTS(SELECT TOP 1 1 FROM tblSMUserRoleMenu rm INNER JOIN tblSMMasterMenu mm ON rm.intMenuId = mm.intMenuID WHERE intUserRoleId = @userRoleId AND strMenuName = ''Tickets'' AND strModuleName = ''Help Desk'')
			BEGIN
				UPDATE roleMenu SET ysnVisible =
				(
					SELECT COUNT(*) FROM tblSMUserRoleMenu rm INNER JOIN tblSMMasterMenu mm ON rm.intMenuId = mm.intMenuID WHERE intUserRoleId = @userRoleId AND rm.ysnVisible = 1 AND strMenuName = ''Tickets'' AND strModuleName = ''Help Desk''
				)
				FROM tblSMUserRoleMenu roleMenu
				INNER JOIN tblSMMasterMenu masterMenu ON roleMenu.intMenuId = masterMenu.intMenuID
				WHERE masterMenu.strMenuName IN (''My Tickets (Portal)'', ''Open Tickets (Portal)'', ''All Tickets (Portal)'') AND intUserRoleId = @userRoleId
			END

			/* CRM */
			IF EXISTS(SELECT TOP 1 1 FROM tblSMUserRoleMenu rm INNER JOIN tblSMMasterMenu mm ON rm.intMenuId = mm.intMenuID WHERE intUserRoleId = @userRoleId AND strMenuName = ''Activities'')
			BEGIN
				UPDATE roleMenu SET ysnVisible =
				(
					SELECT COUNT(*) FROM tblSMUserRoleMenu rm INNER JOIN tblSMMasterMenu mm ON rm.intMenuId = mm.intMenuID WHERE intUserRoleId = @userRoleId AND rm.ysnVisible = 1 AND strMenuName = ''Activities''
				)
				FROM tblSMUserRoleMenu roleMenu
				INNER JOIN tblSMMasterMenu masterMenu ON roleMenu.intMenuId = masterMenu.intMenuID
				WHERE masterMenu.strMenuName = ''Activities (Portal)'' AND intUserRoleId = @userRoleId
			END

			IF EXISTS(SELECT TOP 1 1 FROM tblSMUserRoleMenu rm INNER JOIN tblSMMasterMenu mm ON rm.intMenuId = mm.intMenuID WHERE intUserRoleId = @userRoleId AND strMenuName = ''Opportunities'')
			BEGIN
				UPDATE roleMenu SET ysnVisible =
				(
					SELECT COUNT(*) FROM tblSMUserRoleMenu rm INNER JOIN tblSMMasterMenu mm ON rm.intMenuId = mm.intMenuID WHERE intUserRoleId = @userRoleId AND rm.ysnVisible = 1 AND strMenuName = ''Opportunities''
				)
				FROM tblSMUserRoleMenu roleMenu
				INNER JOIN tblSMMasterMenu masterMenu ON roleMenu.intMenuId = masterMenu.intMenuID
				WHERE masterMenu.strMenuName = ''Opportunities (Portal)'' AND intUserRoleId = @userRoleId
			END

			IF EXISTS(SELECT TOP 1 1 FROM tblSMUserRoleMenu rm INNER JOIN tblSMMasterMenu mm ON rm.intMenuId = mm.intMenuID WHERE intUserRoleId = @userRoleId AND strMenuName = ''Opportunities'')
			BEGIN
				UPDATE roleMenu SET ysnVisible =
				(
					SELECT COUNT(*) FROM tblSMUserRoleMenu rm INNER JOIN tblSMMasterMenu mm ON rm.intMenuId = mm.intMenuID WHERE intUserRoleId = @userRoleId AND rm.ysnVisible = 1 AND strMenuName = ''Opportunities''
				)
				FROM tblSMUserRoleMenu roleMenu
				INNER JOIN tblSMMasterMenu masterMenu ON roleMenu.intMenuId = masterMenu.intMenuID
				WHERE masterMenu.strMenuName = ''Opportunities (Portal)'' AND intUserRoleId = @userRoleId
			END

			IF EXISTS(SELECT TOP 1 1 FROM tblSMUserRoleMenu rm INNER JOIN tblSMMasterMenu mm ON rm.intMenuId = mm.intMenuID WHERE intUserRoleId = @userRoleId AND strMenuName = ''Campaigns'')
			BEGIN
				UPDATE roleMenu SET ysnVisible =
				(
					SELECT COUNT(*) FROM tblSMUserRoleMenu rm INNER JOIN tblSMMasterMenu mm ON rm.intMenuId = mm.intMenuID WHERE intUserRoleId = @userRoleId AND rm.ysnVisible = 1 AND strMenuName = ''Campaigns''
				)
				FROM tblSMUserRoleMenu roleMenu
				INNER JOIN tblSMMasterMenu masterMenu ON roleMenu.intMenuId = masterMenu.intMenuID
				WHERE masterMenu.strMenuName = ''Campaigns (Portal)'' AND intUserRoleId = @userRoleId
			END

			IF EXISTS(SELECT TOP 1 1 FROM tblSMUserRoleMenu rm INNER JOIN tblSMMasterMenu mm ON rm.intMenuId = mm.intMenuID WHERE intUserRoleId = @userRoleId AND strMenuName = ''Sales Pipe Statuses'')
			BEGIN
				UPDATE roleMenu SET ysnVisible =
				(
					SELECT COUNT(*) FROM tblSMUserRoleMenu rm INNER JOIN tblSMMasterMenu mm ON rm.intMenuId = mm.intMenuID WHERE intUserRoleId = @userRoleId AND rm.ysnVisible = 1 AND strMenuName = ''Sales Pipe Statuses''
				)
				FROM tblSMUserRoleMenu roleMenu
				INNER JOIN tblSMMasterMenu masterMenu ON roleMenu.intMenuId = masterMenu.intMenuID
				WHERE masterMenu.strMenuName = ''Sales Pipe Statuses (Portal)'' AND intUserRoleId = @userRoleId
			END

			IF EXISTS(SELECT TOP 1 1 FROM tblSMUserRoleMenu rm INNER JOIN tblSMMasterMenu mm ON rm.intMenuId = mm.intMenuID WHERE intUserRoleId = @userRoleId AND strMenuName = ''Sources'')
			BEGIN
				UPDATE roleMenu SET ysnVisible =
				(
					SELECT COUNT(*) FROM tblSMUserRoleMenu rm INNER JOIN tblSMMasterMenu mm ON rm.intMenuId = mm.intMenuID WHERE intUserRoleId = @userRoleId AND rm.ysnVisible = 1 AND strMenuName = ''Sources''
				)
				FROM tblSMUserRoleMenu roleMenu
				INNER JOIN tblSMMasterMenu masterMenu ON roleMenu.intMenuId = masterMenu.intMenuID
				WHERE masterMenu.strMenuName = ''Sources (Portal)'' AND intUserRoleId = @userRoleId
			END

			IF EXISTS(SELECT TOP 1 1 FROM tblSMUserRoleMenu rm INNER JOIN tblSMMasterMenu mm ON rm.intMenuId = mm.intMenuID WHERE intUserRoleId = @userRoleId AND strMenuName = ''Sales Entities'')
			BEGIN
				UPDATE roleMenu SET ysnVisible =
				(
					SELECT COUNT(*) FROM tblSMUserRoleMenu rm INNER JOIN tblSMMasterMenu mm ON rm.intMenuId = mm.intMenuID WHERE intUserRoleId = @userRoleId AND rm.ysnVisible = 1 AND strMenuName = ''Sales Entities''
				)
				FROM tblSMUserRoleMenu roleMenu
				INNER JOIN tblSMMasterMenu masterMenu ON roleMenu.intMenuId = masterMenu.intMenuID
				WHERE masterMenu.strMenuName = ''Sales Entities (Portal)'' AND intUserRoleId = @userRoleId
			END

			IF EXISTS(SELECT TOP 1 1 FROM tblSMUserRoleMenu rm INNER JOIN tblSMMasterMenu mm ON rm.intMenuId = mm.intMenuID WHERE intUserRoleId = @userRoleId AND strMenuName = ''Leads'')
			BEGIN
				UPDATE roleMenu SET ysnVisible =
				(
					SELECT COUNT(*) FROM tblSMUserRoleMenu rm INNER JOIN tblSMMasterMenu mm ON rm.intMenuId = mm.intMenuID WHERE intUserRoleId = @userRoleId AND rm.ysnVisible = 1 AND strMenuName = ''Leads''
				)
				FROM tblSMUserRoleMenu roleMenu
				INNER JOIN tblSMMasterMenu masterMenu ON roleMenu.intMenuId = masterMenu.intMenuID
				WHERE masterMenu.strMenuName = ''Leads (Portal)'' AND intUserRoleId = @userRoleId
			END
	
			/* SCALE */
			IF EXISTS(SELECT TOP 1 1 FROM tblSMUserRoleMenu rm INNER JOIN tblSMMasterMenu mm ON rm.intMenuId = mm.intMenuID WHERE intUserRoleId = @userRoleId AND strMenuName = ''Tickets'' AND strModuleName = ''Ticket Management'')
			BEGIN
				UPDATE roleMenu SET ysnVisible =
				(
					SELECT COUNT(*) FROM tblSMUserRoleMenu rm INNER JOIN tblSMMasterMenu mm ON rm.intMenuId = mm.intMenuID WHERE intUserRoleId = @userRoleId AND rm.ysnVisible = 1 AND strMenuName = ''Tickets'' AND strModuleName = ''Ticket Management''
				)
				FROM tblSMUserRoleMenu roleMenu
				INNER JOIN tblSMMasterMenu masterMenu ON roleMenu.intMenuId = masterMenu.intMenuID
				WHERE masterMenu.strMenuName = ''Scale Tickets (Portal)'' AND intUserRoleId = @userRoleId
			END

			IF EXISTS(SELECT TOP 1 1 FROM tblSMUserRoleMenu rm INNER JOIN tblSMMasterMenu mm ON rm.intMenuId = mm.intMenuID WHERE intUserRoleId = @userRoleId AND strMenuName = ''Storage'')
			BEGIN
				UPDATE roleMenu SET ysnVisible =
				(
					SELECT COUNT(*) FROM tblSMUserRoleMenu rm INNER JOIN tblSMMasterMenu mm ON rm.intMenuId = mm.intMenuID WHERE intUserRoleId = @userRoleId AND rm.ysnVisible = 1 AND strMenuName = ''Storage''
				)
				FROM tblSMUserRoleMenu roleMenu
				INNER JOIN tblSMMasterMenu masterMenu ON roleMenu.intMenuId = masterMenu.intMenuID
				WHERE masterMenu.strMenuName = ''Storage (Portal)'' AND intUserRoleId = @userRoleId
			END

			/* LOGISTICS */
			IF EXISTS(SELECT TOP 1 1 FROM tblSMUserRoleMenu rm INNER JOIN tblSMMasterMenu mm ON rm.intMenuId = mm.intMenuID WHERE intUserRoleId = @userRoleId AND strMenuName = ''Load / Shipment Schedules'')
			BEGIN
				UPDATE roleMenu SET ysnVisible =
				(
					SELECT COUNT(*) FROM tblSMUserRoleMenu rm INNER JOIN tblSMMasterMenu mm ON rm.intMenuId = mm.intMenuID WHERE intUserRoleId = @userRoleId AND rm.ysnVisible = 1 AND strMenuName = ''Load / Shipment Schedules''
				)
				FROM tblSMUserRoleMenu roleMenu
				INNER JOIN tblSMMasterMenu masterMenu ON roleMenu.intMenuId = masterMenu.intMenuID
				WHERE masterMenu.strMenuName = ''Load / Shipment Schedules (Portal)'' AND intUserRoleId = @userRoleId
			END

			/* MANUFACTURING */
			IF EXISTS(SELECT TOP 1 1 FROM tblSMUserRoleMenu rm INNER JOIN tblSMMasterMenu mm ON rm.intMenuId = mm.intMenuID WHERE intUserRoleId = @userRoleId AND strMenuName = ''Transaction View'')
			BEGIN
				UPDATE roleMenu SET ysnVisible =
				(
					SELECT COUNT(*) FROM tblSMUserRoleMenu rm INNER JOIN tblSMMasterMenu mm ON rm.intMenuId = mm.intMenuID WHERE intUserRoleId = @userRoleId AND rm.ysnVisible = 1 AND strMenuName = ''Transaction View''
				)
				FROM tblSMUserRoleMenu roleMenu
				INNER JOIN tblSMMasterMenu masterMenu ON roleMenu.intMenuId = masterMenu.intMenuID
				WHERE masterMenu.strMenuName = ''Transactions (Portal)'' AND masterMenu.strModuleName = ''Manufacturing'' AND intUserRoleId = @userRoleId
			END

			IF EXISTS(SELECT TOP 1 1 FROM tblSMUserRoleMenu rm INNER JOIN tblSMMasterMenu mm ON rm.intMenuId = mm.intMenuID WHERE intUserRoleId = @userRoleId AND strMenuName = ''Inventory View'')
			BEGIN
				UPDATE roleMenu SET ysnVisible =
				(
					SELECT COUNT(*) FROM tblSMUserRoleMenu rm INNER JOIN tblSMMasterMenu mm ON rm.intMenuId = mm.intMenuID WHERE intUserRoleId = @userRoleId AND rm.ysnVisible = 1 AND strMenuName = ''Inventory View''
				)
				FROM tblSMUserRoleMenu roleMenu
				INNER JOIN tblSMMasterMenu masterMenu ON roleMenu.intMenuId = masterMenu.intMenuID
				WHERE masterMenu.strMenuName = ''Inventory (Portal)'' AND masterMenu.strModuleName = ''Manufacturing'' AND intUserRoleId = @userRoleId
			END

			IF EXISTS(SELECT TOP 1 1 FROM tblSMUserRoleMenu rm INNER JOIN tblSMMasterMenu mm ON rm.intMenuId = mm.intMenuID WHERE intUserRoleId = @userRoleId AND strMenuName = ''Quality View'')
			BEGIN
				UPDATE roleMenu SET ysnVisible =
				(
					SELECT COUNT(*) FROM tblSMUserRoleMenu rm INNER JOIN tblSMMasterMenu mm ON rm.intMenuId = mm.intMenuID WHERE intUserRoleId = @userRoleId AND rm.ysnVisible = 1 AND strMenuName = ''Quality View''
				)
				FROM tblSMUserRoleMenu roleMenu
				INNER JOIN tblSMMasterMenu masterMenu ON roleMenu.intMenuId = masterMenu.intMenuID
				WHERE masterMenu.strMenuName = ''Quality (Portal)'' AND masterMenu.strModuleName = ''Quality'' AND intUserRoleId = @userRoleId
			END

			IF EXISTS(SELECT TOP 1 1 FROM tblSMUserRoleMenu rm INNER JOIN tblSMMasterMenu mm ON rm.intMenuId = mm.intMenuID WHERE intUserRoleId = @userRoleId AND strMenuName = ''Sample Entry'')
			BEGIN
				UPDATE roleMenu SET ysnVisible =
				(
					SELECT COUNT(*) FROM tblSMUserRoleMenu rm INNER JOIN tblSMMasterMenu mm ON rm.intMenuId = mm.intMenuID WHERE intUserRoleId = @userRoleId AND rm.ysnVisible = 1 AND strMenuName = ''Sample Entry''
				)
				FROM tblSMUserRoleMenu roleMenu
				INNER JOIN tblSMMasterMenu masterMenu ON roleMenu.intMenuId = masterMenu.intMenuID
				WHERE masterMenu.strMenuName = ''Sample Entry (Portal)'' AND masterMenu.strModuleName = ''Quality'' AND intUserRoleId = @userRoleId
			END

			/* CARD FUELING */
			IF EXISTS(SELECT TOP 1 1 FROM tblSMUserRoleMenu rm INNER JOIN tblSMMasterMenu mm ON rm.intMenuId = mm.intMenuID WHERE intUserRoleId = @userRoleId AND strMenuName = ''Card Accounts'')
			BEGIN
				UPDATE roleMenu SET ysnVisible =
				(
					SELECT COUNT(*) FROM tblSMUserRoleMenu rm INNER JOIN tblSMMasterMenu mm ON rm.intMenuId = mm.intMenuID WHERE intUserRoleId = @userRoleId AND rm.ysnVisible = 1 AND strMenuName = ''Transactions''
				)
				FROM tblSMUserRoleMenu roleMenu
				INNER JOIN tblSMMasterMenu masterMenu ON roleMenu.intMenuId = masterMenu.intMenuID
				WHERE masterMenu.strMenuName = ''Transactions (Portal)'' AND masterMenu.strModuleName = ''Card Fueling'' AND intUserRoleId = @userRoleId
			END

			IF EXISTS(SELECT TOP 1 1 FROM tblSMUserRoleMenu rm INNER JOIN tblSMMasterMenu mm ON rm.intMenuId = mm.intMenuID WHERE intUserRoleId = @userRoleId AND strMenuName = ''Customer Contact List'')
			BEGIN
				UPDATE roleMenu SET ysnVisible =
				(
					SELECT COUNT(*) FROM tblSMUserRoleMenu rm INNER JOIN tblSMMasterMenu mm ON rm.intMenuId = mm.intMenuID WHERE intUserRoleId = @userRoleId AND rm.ysnVisible = 1 AND strMenuName = ''Card Accounts''
				)
				FROM tblSMUserRoleMenu roleMenu
				INNER JOIN tblSMMasterMenu masterMenu ON roleMenu.intMenuId = masterMenu.intMenuID
				WHERE masterMenu.strMenuName = ''Card Accounts (Portal)'' AND intUserRoleId = @userRoleId
			END

			/* TANK MANAGEMENT */
			IF EXISTS(SELECT TOP 1 1 FROM tblSMUserRoleMenu rm INNER JOIN tblSMMasterMenu mm ON rm.intMenuId = mm.intMenuID WHERE intUserRoleId = @userRoleId AND strMenuName = ''Consumption Sites'')
			BEGIN
				UPDATE roleMenu SET ysnVisible =
				(
					SELECT COUNT(*) FROM tblSMUserRoleMenu rm INNER JOIN tblSMMasterMenu mm ON rm.intMenuId = mm.intMenuID WHERE intUserRoleId = @userRoleId AND rm.ysnVisible = 1 AND strMenuName = ''Consumption Sites''
				)
				FROM tblSMUserRoleMenu roleMenu
				INNER JOIN tblSMMasterMenu masterMenu ON roleMenu.intMenuId = masterMenu.intMenuID
				WHERE masterMenu.strMenuName = ''Consumption Sites (Portal)'' AND intUserRoleId = @userRoleId
			END

			UPDATE tblSMUserRoleMenu
				SET intParentMenuId = tblPatch.intRoleParentID
				FROM (
					SELECT 
						RoleMenu.intUserRoleMenuId,
						intRoleParentID = ISNULL((SELECT ISNULL(intUserRoleMenuId, 0) FROM tblSMUserRoleMenu tmpA WHERE tmpA.intMenuId = Menu.intParentMenuID AND tmpA.intUserRoleId = @userRoleId), 0)
					FROM tblSMUserRoleMenu RoleMenu
					LEFT JOIN tblSMMasterMenu Menu ON Menu.intMenuID = RoleMenu.intMenuId
					WHERE RoleMenu.intUserRoleId = @userRoleId
					)tblPatch 
				WHERE tblPatch.intUserRoleMenuId = tblSMUserRoleMenu.intUserRoleMenuId
				AND intUserRoleId = @userRoleId

				ParentConflicts:

				IF EXISTS (SELECT * FROM (
					SELECT RoleMenu.ysnVisible origVisible, 
						RoleMenu.intUserRoleMenuId,
						ysnVisible = (CASE WHEN EXISTS((SELECT TOP 1 1 FROM tblSMUserRoleMenu tmpA WHERE tmpA.intParentMenuId = RoleMenu.intUserRoleMenuId AND tmpA.intUserRoleId = @userRoleId AND ysnVisible = 1)) THEN 1 
										WHEN Menu.ysnLeaf = 1 THEN RoleMenu.ysnVisible
										ELSE 0 END)
					FROM tblSMUserRoleMenu RoleMenu
					LEFT JOIN tblSMMasterMenu Menu ON Menu.intMenuID = RoleMenu.intMenuId
					WHERE RoleMenu.intUserRoleId = @userRoleId
				) tblPatch
				WHERE origVisible <> ysnVisible)
				BEGIN

					UPDATE tblSMUserRoleMenu
					SET ysnVisible = tblPatch.ysnVisible
					FROM (
						SELECT 
							RoleMenu.intUserRoleMenuId,
							ysnVisible = (CASE WHEN EXISTS((SELECT TOP 1 1 FROM tblSMUserRoleMenu tmpA WHERE tmpA.intParentMenuId = RoleMenu.intUserRoleMenuId AND tmpA.intUserRoleId = @userRoleId AND ysnVisible = 1)) THEN 1 
												WHEN Menu.ysnLeaf = 1 THEN RoleMenu.ysnVisible
												ELSE 0 END)
						FROM tblSMUserRoleMenu RoleMenu
						LEFT JOIN tblSMMasterMenu Menu ON Menu.intMenuID = RoleMenu.intMenuId
						WHERE RoleMenu.intUserRoleId = @userRoleId
						) tblPatch
					WHERE tblPatch.intUserRoleMenuId = tblSMUserRoleMenu.intUserRoleMenuId
					AND intUserRoleId = @userRoleId

					IF EXISTS (SELECT * FROM (
						SELECT RoleMenu.ysnVisible origVisible, 
							RoleMenu.intUserRoleMenuId,
							ysnVisible = (CASE WHEN EXISTS((SELECT TOP 1 1 FROM tblSMUserRoleMenu tmpA WHERE tmpA.intParentMenuId = RoleMenu.intUserRoleMenuId AND tmpA.intUserRoleId = @userRoleId AND ysnVisible = 1)) THEN 1 
											WHEN Menu.ysnLeaf = 1 THEN RoleMenu.ysnVisible
											ELSE 0 END)
						FROM tblSMUserRoleMenu RoleMenu
						LEFT JOIN tblSMMasterMenu Menu ON Menu.intMenuID = RoleMenu.intMenuId
						WHERE RoleMenu.intUserRoleId = @userRoleId
					) tblPatch
					WHERE origVisible <> ysnVisible)
					BEGIN
						GOTO ParentConflicts
					END
				END
	
			--SELECT * FROM vyuSMUserRoleMenu WHERE intUserRoleId = @userRoleId
			END
		')

		DECLARE @currentRole NVARCHAR(200)
		DECLARE @accountContactMenuId INT

		SELECT @accountContactMenuId = intContactMenuId 
		FROM tblSMMasterMenu mm 
		INNER JOIN tblSMContactMenu cm 
		ON mm.intMenuID = cm.intMasterMenuId 
		WHERE mm.strMenuName = 'Account (Portal)'

		--IF OBJECT_ID('tempdb..#TempContactRoleMenus') IS NOT NULL DROP TABLE #TempContactRoleMenus
		--SELECT * INTO #TempContactRoleMenus FROM tblSMUserRoleMenu WHERE intUserRoleId IN (SELECT intUserRoleID FROM tblSMUserRole WHERE strRoleType IN ('Portal Default', 'Contact Admin', 'Contact') AND intUserRoleID IN (999, 20, 19))

		EXEC [uspSMUpdateContactMenus] 999 

		IF OBJECT_ID('tempdb..#TempContactAdminRoles') IS NOT NULL DROP TABLE #TempContactAdminRoles
		SELECT intUserRoleID INTO #TempContactAdminRoles FROM tblSMUserRole WHERE strRoleType = 'Contact Admin' --AND intUserRoleID = 20

		WHILE EXISTS(SELECT TOP 1 1 FROM #TempContactAdminRoles)
		BEGIN

			SELECT TOP 1 @currentRole = intUserRoleID FROM #TempContactAdminRoles

			EXEC [uspSMUpdateContactMenus] @currentRole 
	
			DELETE FROM #TempContactAdminRoles WHERE intUserRoleID = @currentRole
		END

		IF OBJECT_ID('tempdb..#TempContactRoles') IS NOT NULL DROP TABLE #TempContactRoles
		SELECT intUserRoleID INTO #TempContactRoles FROM tblSMUserRole WHERE strRoleType = 'Contact' --AND intUserRoleID = 19

		WHILE EXISTS(SELECT TOP 1 1 FROM #TempContactRoles)
		BEGIN

			SELECT TOP 1 @currentRole = intUserRoleID FROM #TempContactRoles

			EXEC [uspSMUpdateContactMenus] @currentRole 
	
			DELETE FROM #TempContactRoles WHERE intUserRoleID = @currentRole
		END

		DELETE FROM tblSMUserRoleMenu 
		WHERE intUserRoleId IN (SELECT intUserRoleID FROM tblSMUserRole WHERE strRoleType IN ('Portal Default', 'Contact Admin', 'Contact'))
		AND intMenuId IN (SELECT intMasterMenuId FROM tblSMContactMenu WHERE intContactMenuId < @accountContactMenuId)

		DELETE FROM tblSMContactMenu WHERE intContactMenuId < @accountContactMenuId

		PRINT N'UPDATE PORTAL MENUS'
		INSERT INTO tblSMMigrationLog([strModule], [strEvent], [strDescription], [dtmMigrated]) 
		VALUES('System Manager', 'Update Portal Menus (System Manager) - 1730', 'Update Portal Menus (System Manager) - 1730', GETDATE())
	END
GO