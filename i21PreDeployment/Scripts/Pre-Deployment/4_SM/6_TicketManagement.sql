IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.COLUMNS WHERE UPPER(TABLE_NAME) = 'TBLSMMASTERMENU')
BEGIN

EXEC
('
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = ''Ticket Management'' AND strModuleName = ''Ticket Management'')
	BEGIN
		/* SCALE INTERFACE */

		/* Rename Scale Interface to Scale */
		IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = ''Scale Interface'' AND strModuleName = ''Grain'' AND intParentMenuID = 0)
		UPDATE tblSMMasterMenu SET strMenuName = N''Scale'', strDescription = N''Scale'' WHERE strMenuName = ''Scale Interface'' AND strModuleName = ''Grain'' AND intParentMenuID = 0

		/* Start of Remodule */
		IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = ''Scale'' AND strModuleName = ''Grain'' AND intParentMenuID = 0)
		BEGIN
			DECLARE @ScaleInterfaceOldParentMenuId INT
			SELECT @ScaleInterfaceOldParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = ''Scale'' AND strModuleName = ''Grain'' AND intParentMenuID = 0

			UPDATE tblSMMasterMenu SET strModuleName = ''Scale'' WHERE strMenuName = ''Scale'' AND strModuleName = ''Grain'' AND intParentMenuID = 0
			UPDATE tblSMMasterMenu SET strModuleName = ''Scale'' WHERE strMenuName = ''Scale Tickets'' AND strModuleName = ''Grain'' AND intParentMenuID = @ScaleInterfaceOldParentMenuId
			UPDATE tblSMMasterMenu SET strModuleName = ''Scale'' WHERE strMenuName = ''Ticket Pools'' AND strModuleName = ''Grain'' AND intParentMenuID = @ScaleInterfaceOldParentMenuId
			UPDATE tblSMMasterMenu SET strModuleName = ''Scale'' WHERE strMenuName = ''Scale Station Settings'' AND strModuleName = ''Grain'' AND intParentMenuID = @ScaleInterfaceOldParentMenuId
			UPDATE tblSMMasterMenu SET strModuleName = ''Scale'' WHERE strMenuName = ''Ticket Formats'' AND strModuleName = ''Grain'' AND intParentMenuID = @ScaleInterfaceOldParentMenuId
			UPDATE tblSMMasterMenu SET strModuleName = ''Scale'' WHERE strMenuName = ''Physical Scales'' AND strModuleName = ''Grain'' AND intParentMenuID = @ScaleInterfaceOldParentMenuId
			UPDATE tblSMMasterMenu SET strModuleName = ''Scale'' WHERE strMenuName = ''Grading Equipment'' AND strModuleName = ''Grain'' AND intParentMenuID = @ScaleInterfaceOldParentMenuId

			IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = ''Reports'' AND strModuleName = ''Grain'' AND intParentMenuID = @ScaleInterfaceOldParentMenuId)
			BEGIN
				DECLARE @ScaleInterfaceReportOldParentMenuId INT
				SELECT @ScaleInterfaceReportOldParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = ''Reports'' AND strModuleName = ''Grain'' AND intParentMenuID = @ScaleInterfaceOldParentMenuId

				UPDATE tblSMMasterMenu SET strModuleName = ''Scale'' WHERE strMenuName = ''Reports'' AND strModuleName = ''Grain'' AND intParentMenuID = @ScaleInterfaceOldParentMenuId
				UPDATE tblSMMasterMenu SET strModuleName = ''Scale'' WHERE strMenuName = ''Scale Activity'' AND strModuleName = ''Grain'' AND strType = ''Report'' AND intParentMenuID = @ScaleInterfaceReportOldParentMenuId
				UPDATE tblSMMasterMenu SET strModuleName = ''Scale'' WHERE strMenuName = ''Unsent Tickets'' AND strModuleName = ''Grain'' AND strType = ''Report'' AND intParentMenuID = @ScaleInterfaceReportOldParentMenuId
			END
		END
		/* End of Remodule */

		/* Rename Scale to Ticket Entry */
		IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = ''Scale'' AND strModuleName = ''Scale'' AND intParentMenuID = 0)
		UPDATE tblSMMasterMenu SET strMenuName = N''Ticket Entry'', strDescription = N''Ticket Entry'' WHERE strMenuName = ''Scale'' AND strModuleName = ''Scale'' AND intParentMenuID = 0

		IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = ''Ticket Entry'' AND strModuleName = ''Scale'' AND intParentMenuID = 0)
			INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
			VALUES (N''Ticket Entry'', N''Scale'', 0, N''Ticket Entry'', NULL, N''Folder'', N'''', N''small-folder'', 1, 0, 0, 0, 16, 0)
		ELSE
			UPDATE tblSMMasterMenu SET intSort = 16 WHERE strMenuName = ''Ticket Entry'' AND strModuleName = ''Scale'' AND intParentMenuID = 0

		DECLARE @ScaleInterfaceParentMenuId INT
		SELECT @ScaleInterfaceParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = ''Ticket Entry'' AND strModuleName = ''Scale'' AND intParentMenuID = 0

		IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = ''Reports'' AND strModuleName = ''Scale'' AND intParentMenuID = @ScaleInterfaceParentMenuId)
			INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
			VALUES (N''Reports'', N''Scale'', @ScaleInterfaceParentMenuId, N''Reports'', NULL, N''Folder'', N'''', N''small-folder'', 1, 0, 0, 0, NULL, 1)
		ELSE
			UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = ''small-folder'', strCommand = N'''', intSort = NULL WHERE strMenuName = ''Reports'' AND strModuleName = ''Scale'' AND intParentMenuID = @ScaleInterfaceParentMenuId

		DECLARE @ScaleInterfaceReportParentMenuId INT
		SELECT @ScaleInterfaceReportParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = ''Reports'' AND strModuleName = ''Scale'' AND intParentMenuID = @ScaleInterfaceParentMenuId

		/* START OF PLURALIZING */
		IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = ''Scale Ticket'' AND strModuleName = ''Scale'' AND intParentMenuID = @ScaleInterfaceParentMenuId)
		UPDATE tblSMMasterMenu SET strMenuName = ''Scale Tickets'', strDescription = ''Scale Tickets'' WHERE strMenuName = ''Scale Ticket'' AND strModuleName = ''Scale'' AND intParentMenuID = @ScaleInterfaceParentMenuId
		/* START OF PLURALIZING */

		/* Start of Re-name */
		IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = ''Physical Scale Maintenance'' AND strModuleName = ''Scale'' AND intParentMenuID = @ScaleInterfaceParentMenuId)
		UPDATE tblSMMasterMenu SET strMenuName = ''Physical Scales'', strDescription = ''Physical Scales'' WHERE strMenuName = ''Physical Scale Maintenance'' AND strModuleName = ''Scale'' AND intParentMenuID = @ScaleInterfaceParentMenuId

		IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = ''Grading Equipment Maintenance'' AND strModuleName = ''Scale'' AND intParentMenuID = @ScaleInterfaceParentMenuId)
		UPDATE tblSMMasterMenu SET strMenuName = ''Grading Equipment'', strDescription = ''Grading Equipment'' WHERE strMenuName = ''Grading Equipment Maintenance'' AND strModuleName = ''Scale'' AND intParentMenuID = @ScaleInterfaceParentMenuId

		IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = ''Ticket Pool Maintenance'' AND strModuleName = ''Scale'' AND intParentMenuID = @ScaleInterfaceParentMenuId)
		UPDATE tblSMMasterMenu SET strMenuName = ''Ticket Pools'', strDescription = ''Ticket Pools'' WHERE strMenuName = ''Ticket Pool Maintenance'' AND strModuleName = ''Scale'' AND intParentMenuID = @ScaleInterfaceParentMenuId

		IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = ''Scale Tickets'' AND strModuleName = ''Scale'' AND intParentMenuID = @ScaleInterfaceParentMenuId)
		UPDATE tblSMMasterMenu SET strMenuName = ''Enter Tickets'', strDescription = ''Enter Tickets'' WHERE strMenuName = ''Scale Tickets'' AND strModuleName = ''Scale'' AND intParentMenuID = @ScaleInterfaceParentMenuId
		/* End of Re-name */

		/* Start of moving report */
		UPDATE tblSMMasterMenu SET intParentMenuID = @ScaleInterfaceReportParentMenuId WHERE strMenuName = ''Scale Activity'' AND strModuleName = ''Scale'' AND strType = ''Report'' AND intParentMenuID = @ScaleInterfaceParentMenuId
		UPDATE tblSMMasterMenu SET intParentMenuID = @ScaleInterfaceReportParentMenuId WHERE strMenuName = ''Unsent Tickets'' AND strModuleName = ''Scale'' AND strType = ''Report'' AND intParentMenuID = @ScaleInterfaceParentMenuId
		/* End of moving report */

		IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = ''Enter Tickets'' AND strModuleName = ''Scale'' AND intParentMenuID = @ScaleInterfaceParentMenuId)
			INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
			VALUES (N''Enter Tickets'', N''Scale'', @ScaleInterfaceParentMenuId, N''Enter Tickets'', N''Activity'', N''Screen'', N''Grain.view.ScaleStationSelection'', N''small-menu-activity'', 0, 0, 0, 1, 0, 1)
		ELSE
			UPDATE tblSMMasterMenu SET strCommand = ''Grain.view.ScaleStationSelection'', intSort = 0 WHERE strMenuName = ''Enter Tickets'' AND strModuleName = ''Scale'' AND intParentMenuID = @ScaleInterfaceParentMenuId

		IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = ''Ticket Pools'' AND strModuleName = ''Scale'' AND intParentMenuID = @ScaleInterfaceParentMenuId)
			INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
			VALUES (N''Ticket Pools'', N''Scale'', @ScaleInterfaceParentMenuId, N''Ticket Pools'', N''Maintenance'', N''Screen'', N''Grain.view.TicketPool'', N''small-menu-maintenance'', 0, 0, 0, 1, 4, 1)
		ELSE
			UPDATE tblSMMasterMenu SET strCommand = ''Grain.view.TicketPool'', intSort = 4 WHERE strMenuName = ''Ticket Pools'' AND strModuleName = ''Scale'' AND intParentMenuID = @ScaleInterfaceParentMenuId

		IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = ''Scale Station Settings'' AND strModuleName = ''Scale'' AND intParentMenuID = @ScaleInterfaceParentMenuId)
			INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
			VALUES (N''Scale Station Settings'', N''Scale'', @ScaleInterfaceParentMenuId, N''Scale Station Settings'', N''Maintenance'', N''Screen'', N''Grain.view.ScaleStationSettings'', N''small-menu-maintenance'', 0, 0, 0, 1, 5, 1)
		ELSE
			UPDATE tblSMMasterMenu SET strCommand = ''Grain.view.ScaleStationSettings'', intSort = 5 WHERE strMenuName = ''Scale Station Settings'' AND strModuleName = ''Scale'' AND intParentMenuID = @ScaleInterfaceParentMenuId

		--IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = ''Storage Types'' AND strModuleName = ''Scale'' AND intParentMenuID = @ScaleInterfaceParentMenuId)
		--	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		--	VALUES (N''Storage Types'', N''Scale'', @ScaleInterfaceParentMenuId, N''Storage Type'', N''Maintenance'', N''Screen'', N''Grain.view.StorageType'', N''small-menu-maintenance'', 0, 0, 0, 1, 0, 1)
		--ELSE
		--	UPDATE tblSMMasterMenu SET strCommand = ''Grain.view.StorageType'', intSort = 0 WHERE strMenuName = ''Storage Types'' AND strModuleName = ''Scale'' AND intParentMenuID = @ScaleInterfaceParentMenuId

		IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = ''Storage Types'' AND strModuleName = ''Scale'' AND intParentMenuID = @ScaleInterfaceParentMenuId)
		DELETE FROM tblSMMasterMenu WHERE strMenuName = ''Storage Types'' AND strModuleName = ''Scale'' AND intParentMenuID = @ScaleInterfaceParentMenuId

		IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = ''Ticket Formats'' AND strModuleName = ''Scale'' AND intParentMenuID = @ScaleInterfaceParentMenuId)
			INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
			VALUES (N''Ticket Formats'', N''Scale'', @ScaleInterfaceParentMenuId, N''Ticket Format'', N''Maintenance'', N''Screen'', N''Grain.view.TicketFormats'', N''small-menu-maintenance'', 0, 0, 0, 1, 1, 1)
		ELSE
			UPDATE tblSMMasterMenu SET strCommand = ''Grain.view.TicketFormats'', intSort = 1 WHERE strMenuName = ''Ticket Formats'' AND strModuleName = ''Scale'' AND intParentMenuID = @ScaleInterfaceParentMenuId

		IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = ''Physical Scales'' AND strModuleName = ''Scale'' AND intParentMenuID = @ScaleInterfaceParentMenuId)
			INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
			VALUES (N''Physical Scales'', N''Scale'', @ScaleInterfaceParentMenuId, N''Physical Scales'', N''Maintenance'', N''Screen'', N''Grain.view.PhysicalScale'', N''small-menu-maintenance'', 0, 0, 0, 1, 2, 1)
		ELSE
			UPDATE tblSMMasterMenu SET strCommand = ''Grain.view.PhysicalScale'',  intSort = 2 WHERE strMenuName = ''Physical Scales'' AND strModuleName = ''Scale'' AND intParentMenuID = @ScaleInterfaceParentMenuId

		IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = ''Grading Equipment'' AND strModuleName = ''Scale'' AND intParentMenuID = @ScaleInterfaceParentMenuId)
			INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
			VALUES (N''Grading Equipment'', N''Scale'', @ScaleInterfaceParentMenuId, N''Grading Equipment'', N''Maintenance'', N''Screen'', N''Grain.view.GradingEquipment'', N''small-menu-maintenance'', 0, 0, 0, 1, 3, 1)
		ELSE
			UPDATE tblSMMasterMenu SET strCommand = ''Grain.view.GradingEquipment'', intSort = 3 WHERE strMenuName = ''Grading Equipment'' AND strModuleName = ''Scale'' AND intParentMenuID = @ScaleInterfaceParentMenuId

		IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = ''Scale Activity'' AND strModuleName = ''Scale'' AND intParentMenuID = @ScaleInterfaceReportParentMenuId)
			INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
			VALUES (N''Scale Activity'', N''Scale'', @ScaleInterfaceReportParentMenuId, N''Scale Activity'', N''Report'', N''Report'', N''Scale Activity Report'', N''small-menu-report'', 0, 0, 0, 1, 0, 1)
		ELSE 
			UPDATE tblSMMasterMenu SET strCommand = N''Scale Activity Report'' WHERE strMenuName = ''Scale Activity'' AND strModuleName = ''Scale'' AND intParentMenuID = @ScaleInterfaceReportParentMenuId

		IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = ''Unsent Tickets'' AND strModuleName = ''Scale'' AND intParentMenuID = @ScaleInterfaceReportParentMenuId)
			INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
			VALUES (N''Unsent Tickets'', N''Scale'', @ScaleInterfaceReportParentMenuId, N''Unsent Tickets'', N''Report'', N''Report'', N''Unsent Tickets Report'', N''small-menu-report'', 0, 0, 0, 1, 1, 1)
		ELSE 
			UPDATE tblSMMasterMenu SET strCommand = N''Unsent Tickets Report'' WHERE strMenuName = ''Unsent Tickets'' AND strModuleName = ''Scale'' AND intParentMenuID = @ScaleInterfaceReportParentMenuId

		/* GRAINS */
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = ''Grain'' AND strModuleName = ''Grain'' AND intParentMenuID = 0)
			INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
			VALUES (N''Grain'', N''Grain'', 0, N''Grain'', NULL, N''Folder'', N'''', N''small-folder'', 1, 0, 0, 0, 13, 0)
		ELSE
			UPDATE tblSMMasterMenu SET intSort = 13 WHERE strMenuName = ''Grain'' AND strModuleName = ''Grain'' AND intParentMenuID = 0

		DECLARE @GrainParentMenuId INT
		SELECT @GrainParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = ''Grain'' AND strModuleName = ''Grain'' AND intParentMenuID = 0

		/* START OF PLURALIZING */
		IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = ''Discount Table'' AND strModuleName = ''Grain'' AND intParentMenuID = @GrainParentMenuId)
		UPDATE tblSMMasterMenu SET strMenuName = ''Discount Tables'', strDescription = ''Discount Tables'' WHERE strMenuName = ''Discount Table'' AND strModuleName = ''Grain'' AND intParentMenuID = @GrainParentMenuId

		IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = ''Discount Schedule'' AND strModuleName = ''Grain'' AND intParentMenuID = @GrainParentMenuId)
		UPDATE tblSMMasterMenu SET strMenuName = ''Discount Schedules'', strDescription = ''Discount Schedules'' WHERE strMenuName = ''Discount Schedule'' AND strModuleName = ''Grain'' AND intParentMenuID = @GrainParentMenuId

		IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = ''Storage Type'' AND strModuleName = ''Grain'' AND intParentMenuID = @GrainParentMenuId)
		UPDATE tblSMMasterMenu SET strMenuName = ''Storage Types'', strDescription = ''Storage Types'' WHERE strMenuName = ''Storage Type'' AND strModuleName = ''Grain'' AND intParentMenuID = @GrainParentMenuId
		/* END OF PLURALIZING */

		IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = ''Discount Tables'' AND strModuleName = ''Grain'' AND intParentMenuID = @GrainParentMenuId)
			INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
			VALUES (N''Discount Tables'', N''Grain'', @GrainParentMenuId, N''Discount Tables'', N''Maintenance'', N''Screen'', N''Grain.view.DiscountTable'', N''small-menu-maintenance'', 0, 0, 0, 1, 1, 1)
		ELSE 
			UPDATE tblSMMasterMenu SET strCommand = N''Grain.view.DiscountTable'' WHERE strMenuName = ''Discount Tables'' AND strModuleName = ''Grain'' AND intParentMenuID = @GrainParentMenuId

		IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = ''Discount Schedules'' AND strModuleName = ''Grain'' AND intParentMenuID = @GrainParentMenuId)
			INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
			VALUES (N''Discount Schedules'', N''Grain'', @GrainParentMenuId, N''Discount Schedules'', N''Maintenance'', N''Screen'', N''Grain.view.DiscountSchedule'', N''small-menu-maintenance'', 0, 0, 0, 1, 2, 1)
		ELSE 
			UPDATE tblSMMasterMenu SET strCommand = N''Grain.view.DiscountSchedule'' WHERE strMenuName = ''Discount Schedules'' AND strModuleName = ''Grain'' AND intParentMenuID = @GrainParentMenuId

		IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = ''Storage Types'' AND strModuleName = ''Grain'' AND intParentMenuID = @GrainParentMenuId)
			INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
			VALUES (N''Storage Types'', N''Grain'', @GrainParentMenuId, N''Storage Types'', N''Maintenance'', N''Screen'', N''Grain.view.GrainStorageType'', N''small-menu-maintenance'', 0, 0, 0, 1, 3, 1)
		ELSE 
			UPDATE tblSMMasterMenu SET strCommand = N''Grain.view.GrainStorageType'' WHERE strMenuName = ''Storage Types'' AND strModuleName = ''Grain'' AND intParentMenuID = @GrainParentMenuId

		IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = ''Storage Schedule'' AND strModuleName = ''Grain'' AND intParentMenuID = @GrainParentMenuId)
			INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
			VALUES (N''Storage Schedule'', N''Grain'', @GrainParentMenuId, N''Storage Schedule'', N''Maintenance'', N''Screen'', N''Grain.view.StorageSchedule'', N''small-menu-maintenance'', 0, 0, 0, 1, 4, 1)
		ELSE 
			UPDATE tblSMMasterMenu SET strCommand = N''Grain.view.StorageSchedule'' WHERE strMenuName = ''Storage Schedule'' AND strModuleName = ''Grain'' AND intParentMenuID = @GrainParentMenuId


		IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = ''Storage'' AND strModuleName = ''Grain'' AND intParentMenuID = @GrainParentMenuId)
			INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
			VALUES (N''Storage'', N''Grain'', @GrainParentMenuId, N''Storage'', N''Activity'', N''Screen'', N''Grain.view.Storage'', N''small-menu-activity'', 0, 0, 0, 1, 5, 1)
		ELSE 
			UPDATE tblSMMasterMenu SET strCommand = N''Grain.view.Storage'' WHERE strMenuName = ''Storage'' AND strModuleName = ''Grain'' AND intParentMenuID = @GrainParentMenuId

		IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = ''Storage Transfer'' AND strModuleName = ''Grain'' AND intParentMenuID = @GrainParentMenuId)
			INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
			VALUES (N''Storage Transfer'', N''Grain'', @GrainParentMenuId, N''Storage Transfer'', N''Activity'', N''Screen'', N''Grain.view.TransferStorage'', N''small-menu-activity'', 0, 0, 0, 1, 6, 1)
		ELSE 
			UPDATE tblSMMasterMenu SET strCommand = N''Grain.view.TransferStorage'' WHERE strMenuName = ''Storage Transfer'' AND strModuleName = ''Grain'' AND intParentMenuID = @GrainParentMenuId

		IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = ''Storage Settle'' AND strModuleName = ''Grain'' AND intParentMenuID = @GrainParentMenuId)
			INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
			VALUES (N''Storage Settle'', N''Grain'', @GrainParentMenuId, N''Storage Settle'', N''Activity'', N''Screen'', N''Grain.view.SettleStorage'', N''small-menu-activity'', 0, 0, 0, 1, 7, 1)
		ELSE 
			UPDATE tblSMMasterMenu SET strCommand = N''Grain.view.SettleStorage'' WHERE strMenuName = ''Storage Settle'' AND strModuleName = ''Grain'' AND intParentMenuID = @GrainParentMenuId

		/* START OF DELETING */
		DELETE tblSMMasterMenu WHERE strMenuName = ''Storage Transfer'' AND strModuleName = ''Grain'' AND intParentMenuID = @GrainParentMenuId
		DELETE tblSMMasterMenu WHERE strMenuName = ''Storage Settle'' AND strModuleName = ''Grain'' AND intParentMenuID = @GrainParentMenuId
		/* END OF DELETING */

		IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = ''OffSite'' AND strModuleName = ''Grain'' AND intParentMenuID = @GrainParentMenuId)
			INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
			VALUES (N''OffSite'', N''Grain'', @GrainParentMenuId, N''OffSite'', N''Activity'', N''Screen'', N''Grain.view.OffSite'', N''small-menu-activity'', 0, 0, 0, 1, 5, 1)
		ELSE 
			UPDATE tblSMMasterMenu SET strCommand = N''Grain.view.OffSite'' WHERE strMenuName = ''OffSite'' AND strModuleName = ''Grain'' AND intParentMenuID = @GrainParentMenuId

		-- TICKET MANAGEMENT
	
		-- RENAME GRAIN TO TICKET MANAGEMENT
		UPDATE tblSMMasterMenu SET strMenuName = ''Ticket Management'', strModuleName = ''Ticket Management'' WHERE strMenuName = ''Grain'' AND strModuleName = ''Grain'' AND intParentMenuID = 0

		DECLARE @TicketManagementParentMenuId INT
		SELECT @TicketManagementParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = ''Ticket Management'' AND strModuleName = ''Ticket Management'' AND intParentMenuID = 0
	
		-- MOVE SCALE AND GRAIN MENUS TO TICKET MANAGEMENT
		UPDATE tblSMMasterMenu SET strModuleName = N''Ticket Management'', intParentMenuID = @TicketManagementParentMenuId WHERE strModuleName = ''Scale'' AND intParentMenuID = @ScaleInterfaceParentMenuId
		AND strMenuName IN (''Enter Tickets'', ''Ticket Formats'', ''Physical Scales'', ''Grading Equipment'', ''Physical Scales'', ''Grading Equipment'', ''Ticket Pools'', ''Scale Station Settings'', ''Reports'')

		UPDATE tblSMMasterMenu SET strModuleName = N''Ticket Management'', intParentMenuID = @TicketManagementParentMenuId WHERE strModuleName = ''Grain'' AND intParentMenuID = @GrainParentMenuId
		AND strMenuName IN (''Storage'', ''OffSite'', ''Discount Tables'', ''Discount Schedules'', ''Storage Types'', ''Storage Schedule'')

		DECLARE @TicketManagementReportParentMenuId INT
		SELECT @TicketManagementReportParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = ''Reports'' AND strModuleName = ''Ticket Management'' AND intParentMenuID = @TicketManagementParentMenuId

		UPDATE tblSMMasterMenu SET strModuleName = N''Ticket Management'', intParentMenuID = @TicketManagementReportParentMenuId WHERE strMenuName = ''Scale Activity'' AND strModuleName = ''Scale'' AND intParentMenuID = @ScaleInterfaceReportParentMenuId
		UPDATE tblSMMasterMenu SET strModuleName = N''Ticket Management'', intParentMenuID = @TicketManagementReportParentMenuId WHERE strMenuName = ''Unsent Tickets'' AND strModuleName = ''Scale'' AND intParentMenuID = @ScaleInterfaceReportParentMenuId

		-- DELETE SCALE
		DELETE FROM tblSMMasterMenu WHERE strMenuName = N''Ticket Entry'' AND strModuleName = N''Scale''

	END
')

END