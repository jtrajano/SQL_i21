GO
    /* UPDATE ENTITY CREDENTIAL CONCURRENCY */
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMBuildNumber WHERE strVersionNo LIKE '18.3%')
	BEGIN
		EXEC uspSMIncreaseECConcurrency 0
		
		IF OBJECT_ID('tempdb..#updateUserRoleMenus') IS NOT NULL DROP TABLE #updateUserRoleMenus
		CREATE TABLE #updateUserRoleMenus (ysnUpdate BIT)
	END
GO
	/* UPDATE ENTITY CREDENTIAL CONCURRENCY */
		 	

	IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'DPR Compare' AND strModuleName = 'Risk Management' AND intParentMenuID = (SELECT TOP 1 intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Reports' AND strModuleName = 'Risk Management') AND strCommand = N'RiskManagement.view.DPRCompare')
	BEGIN
		EXEC uspSMIncreaseECConcurrency 0
		
		IF OBJECT_ID('tempdb..#updateUserRoleMenus') IS NOT NULL DROP TABLE #updateUserRoleMenus
		CREATE TABLE #updateUserRoleMenus (ysnUpdate BIT)
	END
GO	
	
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Bank File Formats'	AND strModuleName = 'Cash Management' AND (strCommand = 'CashManagement.controller.BankFileFormat' OR strCommand = 'CashManagement.view.BankFileFormat' OR strCommand = 'CashManagement.view.BankFileFormat?showSearch=true'))
	BEGIN
		DELETE FROM tblSMMasterMenu
		
		SET IDENTITY_INSERT [dbo].[tblSMMasterMenu] ON

		/* SYSTEM MANAGER */
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (1, N'System Manager', N'System Manager', 0, N'System Manager', NULL, N'Folder', N'i21', N'small-folder', 1, 0, 0, 0, 1, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (2, N'Users', N'System Manager', 1, N'Users', N'Activity', N'Screen', N'i21.view.EntityUser?showSearch=true', N'small-menu-activity', 0, 0, 0, 1, 0, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (3, N'User Roles', N'System Manager', 1, N'User Roles', N'Activity', N'Screen', N'i21.view.UserRole', N'small-menu-activity', 0, 0, 0, 1, 1, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (4, N'Report Manager', N'System Manager', 1, N'Report Manager', N'Maintenance', N'Screen', N'Reports.controller.ReportManager', N'small-menu-maintenance', 0, 0, 0, 1, 3, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (5, N'Motor Fuel Tax Cycle', N'System Manager', 1, N'Motor Fuel Tax Cycle', N'Maintenance', N'Screen', N'Reports.controller.RunTaxCycle', N'small-menu-maintenance', 0, 0, 0, 1, 4, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (6, N'Company Configuration', N'System Manager', 1, N'Company Configuration', N'Activity', N'Screen', N'i21.view.CompanyPreferences', N'small-menu-activity', 0, 0, 0, 1, 5, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (7, N'Starting Numbers', N'System Manager', 1, N'Starting Numbers', N'Maintenance', N'Screen', N'i21.view.StartingNumbers', N'small-menu-maintenance', 0, 0, 0, 1, 6, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (8, N'Custom Fields', N'System Manager', 1, N'Custom Fields', N'Maintenance', N'Screen', N'GlobalComponentEngine.view.CustomField', N'small-menu-maintenance', 0, 0, 0, 1, 7, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (10, N'Utilities', N'System Manager', 1, N'Utilities', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 9, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (11, N'Imports and Conversions', N'System Manager', 10, N'Imports and Conversions', N'Utility', N'Screen', N'i21.view.OriginConversions', N'small-menu-utility', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (12, N'Import Origin Users', N'System Manager', 10, N'Import Legacy Users', N'Maintenance', N'Screen', N'i21.view.ImportLegacyUsers', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (13, N'Common Info', N'System Manager', 0, N'Common Info', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 2, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (14, N'Countries', N'System Manager', 13, N'Countries', N'Maintenance', N'Screen', N'i21.view.Country?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 0, 1)
		--INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		--VALUES (15, N'Zip Codes', N'System Manager', 13, N'Zip Codes', N'Maintenance', N'Screen', N'i21.view.ZipCode', N'small-menu-maintenance', 0, 0, 0, 1, 1, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (16, N'Currencies', N'System Manager', 13, N'Currencies', N'Activity', N'Screen', N'i21.view.Currency', N'small-menu-activity', 0, 0, 0, 1, 2, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (17, N'Ship Via', N'System Manager', 13, N'Ship Via', N'Maintenance', N'Screen', N'i21.view.ShipVia', N'small-menu-maintenance', 0, 0, 0, 1, 3, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (18, N'Payment Methods', N'System Manager', 13, N'Payment Methods', N'Maintenance', N'Screen', N'i21.view.PaymentMethod', N'small-menu-maintenance', 0, 0, 0, 1, 4, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (19, N'Terms', N'System Manager', 13, N'Terms', N'Maintenance', N'Screen', N'i21.view.Term?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 5, 1)

		/* DASHBOARD */
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (20, N'Dashboard', N'Dashboard', 0, N'Dashboard', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 3, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (21, N'Add Panel', N'Dashboard', 20, N'Add Panel', N'Maintenance', N'Screen', N'Dashboard.view.PanelSettings?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (22, N'Panel Connection', N'Dashboard', 20, N'Panel Connection', N'Maintenance', N'Screen', N'Dashboard.view.Connection', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (23, N'Panels', N'Dashboard', 20, N'Panels', N'Maintenance', N'Screen', N'Dashboard.view.PanelList', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (24, N'Panel Layout', N'Dashboard', 20, N'Panel Layout', N'Maintenance', N'Screen', N'Dashboard.view.PanelLayout', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (25, N'Dashboard Configuration', N'Dashboard', 20, N'Dashboard Configuration', N'Maintenance', N'Screen', N'Dashboard.view.TabSetup', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)

		/* GENERAL LEDGER */
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (26, N'General Ledger', N'General Ledger', 0, N'General Ledger', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 4, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (28, N'General Journals', N'General Ledger', 26, N'General Journals', N'Activity', N'Screen', N'GeneralLedger.view.GeneralJournal', N'small-menu-activity', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (29, N'GL Account Detail', N'General Ledger', 26, N'GL Account Detail', N'Activity', N'Screen', N'GeneralLedger.view.GLAccountDetail', N'small-menu-activity', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (30, N'Batch Posting', N'General Ledger', 26, N'Batch Posting', N'Activity', N'Screen', N'i21.view.BatchPosting?module=GeneralLedger', N'small-menu-activity', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (31, N'Reminder List', N'General Ledger', 26, N'Reminder List', N'Activity', N'Screen', N'GeneralLedger.view.ReminderList', N'small-menu-activity', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (32, N'Import Budgets from CSV', N'General Ledger', 26, N'Import Budgets from CSV', N'Activity', N'Screen', N'GeneralLedger.view.ImportBudgetFromCSV', N'small-menu-activity', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (33, N'Import GL from Subledger', N'General Ledger', 26, N'Import GL from Subledger', N'Import', N'Screen', N'GeneralLedger.view.ImportFromSubledger', N'small-menu-import', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (34, N'Import GL from CSV', N'General Ledger', 26, N'Import GL from CSV', N'Import', N'Screen', N'GeneralLedger.view.ImportFromCSV', N'small-menu-import', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (35, N'GL Import Logs', N'General Ledger', 26, N'GL Import Logs', N'Import', N'Screen', N'GeneralLedger.view.ImportLogs', N'small-menu-import', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (37, N'Chart of Accounts', N'General Ledger', 26, N'Chart of Accounts', N'Setup', N'Screen', N'GeneralLedger.view.ChartOfAccounts', N'small-menu-setup', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (38, N'Account Structure', N'General Ledger', 26, N'Account Structure', N'Setup', N'Screen', N'GeneralLedger.view.AccountStructure', N'small-menu-setup', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (39, N'Account Groups', N'General Ledger', 26, N'Account Groups', N'Setup', N'Screen', N'GeneralLedger.view.AccountGroups', N'small-menu-setup', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (40, N'Segment Accounts', N'General Ledger', 26, N'Segment Accounts', N'Setup', N'Screen', N'GeneralLedger.view.SegmentAccounts', N'small-menu-setup', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (41, N'Build Accounts', N'General Ledger', 26, N'Build Accounts', N'Setup', N'Screen', N'GeneralLedger.view.BuildAccounts', N'small-menu-setup', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (43, N'Clone Account', N'General Ledger', 26, N'Clone Account', N'Maintenance', N'Screen', N'GeneralLedger.view.AccountClone', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (44, N'Fiscal Year', N'General Ledger', 26, N'Fiscal Year', N'Maintenance', N'Screen', N'GeneralLedger.view.FiscalYear', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (46, N'Reallocations', N'General Ledger', 26, N'Reallocations', N'Maintenance', N'Screen', N'GeneralLedger.view.Reallocation', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (47, N'Recurring Journals', N'General Ledger', 26, N'Recurring Journals', N'Maintenance', N'Screen', N'i21.view.RecurringTransaction?type=General Journal', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (48, N'Recurring Journal History', N'General Ledger', 26, N'Recurring Journal History', N'Maintenance', N'Screen', N'GeneralLedger.view.RecurringJournalHistory', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)

		/* FINANCIAL REPORT DESIGNER */
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (49, N'Financial Reports', N'Financial Report Designer', 0, N'Financial Reports', NULL, N'Folder', N'FinancialReportDesigner', N'small-folder', 1, 0, 0, 0, 5, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (50, N'Financial Report Viewer', N'Financial Report Designer', 49, N'Financial Report Viewer', N'Activity', N'Screen', N'FinancialReportDesigner.view.FinancialReports', N'small-menu-activity', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (52, N'Row Designer', N'Financial Report Designer', 49, N'Row Designer', N'Maintenance', N'Screen', N'FinancialReportDesigner.view.RowDesigner', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (53, N'Column Designer', N'Financial Report Designer', 49, N'Column Designer', N'Maintenance', N'Screen', N'FinancialReportDesigner.view.ColumnDesigner', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (54, N'Report Header and Footer', N'Financial Report Designer', 49, N'Report Header and Footer', N'Maintenance', N'Screen', N'FinancialReportDesigner.view.HeaderFooterDesigner', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (55, N'Financial Report Builder', N'Financial Report Designer', 49, N'Financial Report Builder', N'Maintenance', N'Screen', N'FinancialReportDesigner.view.ReportBuilder?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (56, N'Report Templates', N'Financial Report Designer', 49, N'Report Templates', N'Maintenance', N'Screen', N'FinancialReportDesigner.view.Templates', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)


		/* GENERAL LEDGER */
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (58, N'Reallocation', N'General Ledger', 26, N'Reallocation', N'Report', N'Report', N'Reallocation', N'small-menu-report', 0, 0, 0, 1, 4, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (59, N'Chart of Accounts', N'General Ledger', 26, N'Chart of Accounts', N'Report', N'Report', N'Chart of Accounts', N'small-menu-report', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (60, N'Chart of Accounts Adjustment', N'General Ledger', 26, N'Chart of Accounts Adjustment', N'Report', N'Report', N'Chart of Accounts Adjustment', N'small-menu-report', 0, 0, 0, 1, NULL, 1)
		--INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		--VALUES (61, N'General Ledger By Account ID Detail', N'General Ledger', 26, N'General Ledger By Account ID Detail', N'Report', N'Screen', N'Reporting.view.ReportManager?group=General Ledger&report=GeneralLedgerByAccountDetail&direct=true&showCriteria=true', N'small-menu-report', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (62, N'Balance Sheet Standard', N'General Ledger', 26, N'Balance Sheet Standard', N'Report', N'Report', N'Balance Sheet Standard', N'small-menu-report', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (63, N'Income Statement Standard', N'General Ledger', 26, N'Income Statement Standard', N'Report', N'Report', N'Income Statement Standard', N'small-menu-report', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (64, N'Trial Balance', N'General Ledger', 26, N'Trial Balance', N'Report', N'Report', N'Trial Balance', N'small-menu-report', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (65, N'Trial Balance Detail', N'General Ledger', 26, N'Trial Balance Detail', N'Report', N'Screen', N'Reporting.view.ReportManager?group=General Ledger&report=TrialBalanceDetail&direct=true&showCriteria=true', N'small-menu-report', 0, 0, 0, 1, NULL, 1)


		/* TANK MANAGEMENT */
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (66, N'Tank Management', N'Tank Management', 0, N'Tank Management', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 18, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (68, N'Customer Inquiry', N'Tank Management', 66, N'Customer Inquiry', N'Maintenance', N'Screen', N'TankManagement.view.CustomerInquiry?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 0, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (69, N'Consumption Sites', N'Tank Management', 66, N'Consumption Sites', N'Maintenance', N'Screen', N'TankManagement.view.ConsumptionSite?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 1, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (70, N'Clock Reading', N'Tank Management', 66, N'Clock Reading', N'Activity', N'Screen', N'TankManagement.view.ClockReading?showSearch=true', N'small-menu-activity', 0, 0, 0, 1, 0, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (71, N'Synchronize Delivery History', N'Tank Management', 66, N'Synchronize Delivery History', N'Activity', N'Screen', N'TankManagement.view.SyncDeliveryHistory', N'small-menu-activity', 0, 0, 0, 1, 1, 1)
		--INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		--VALUES (72, N'Lease Billing', N'Tank Management', 66, N'Lease Billing', N'Activity', N'Screen', N'TankManagement.view.LeaseBilling', N'small-menu-activity', 0, 0, 0, 1, NULL, 1)
		--INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		--VALUES (73, N'Dispatch Deliveries', N'Tank Management', 66, N'Dispatch Deliveries', N'Activity', N'Screen', N'TankManagement.view.DispatchDelivery', N'small-menu-activity', 0, 0, 0, 1, NULL, 1)
		--INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		--VALUES (75, N'Degree Day Clock', N'Tank Management', 66, N'Degree Day Clock', N'Maintenance', N'Screen', N'TankManagement.view.DegreeDayClock', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (76, N'Devices', N'Tank Management', 66, N'Devices', N'Maintenance', N'Screen', N'TankManagement.view.Device?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 3, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (77, N'Events', N'Tank Management', 66, N'Events', N'Report', N'Screen', N'TankManagement.view.Event?showSearch=true', N'small-menu-report', 0, 0, 0, 1, NULL, 1)
		--INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		--VALUES (78, N'Event Types', N'Tank Management', 66, N'Event Types', N'Maintenance', N'Screen', N'TankManagement.view.EventType', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
		--INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		--VALUES (79, N'Device Types', N'Tank Management', 66, N'Device Types', N'Maintenance', N'Screen', N'TankManagement.view.DeviceType', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
		--INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		--VALUES (80, N'Lease Codes', N'Tank Management', 66, N'Lease Codes', N'Maintenance', N'Screen', N'TankManagement.view.LeaseCode', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
		--INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		--VALUES (81, N'Event Automation', N'Tank Management', 66, N'Event Automation', N'Maintenance', N'Screen', N'TankManagement.view.EventAutomation', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
		--INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		--VALUES (82, N'Meter Types', N'Tank Management', 66, N'Meter Types', N'Maintenance', N'Screen', N'TankManagement.view.MeterType', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
		--INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		--VALUES (83, N'Renew Julian Deliveries', N'Tank Management', 66, N'Renew Julian Deliveries', N'Maintenance', N'Screen', N'TankManagement.view.RenewJulianDelivery', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (84, N'Resolve Sync Conflict', N'Tank Management', 66, N'Resolve Sync Conflict', N'Maintenance', N'Screen', N'TankManagement.view.ResolveSyncConflict', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
		--INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		--VALUES (85, N'Lease Billing Incentive', N'Tank Management', 66, N'Lease Billing Incentive', N'Maintenance', N'Screen', N'TankManagement.view.LeaseBillingMinimum', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (87, N'Delivery Fill', N'Tank Management', 66, N'Delivery Fill', N'Report', N'Screen', N'TankManagement.view.DeliveryFillReportParameter', N'small-menu-report', 0, 0, 0, 1, 1, 1)
		--INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		--VALUES (88, N'Two-Part Delivery Fill Report', N'Tank Management', 66, N'Two-Part Delivery Fill Report', N'Report', N'Report', N'Two-Part Delivery Fill Report', N'small-menu-report', 0, 0, 0, 1, NULL, 1)
		--INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		--VALUES (89, N'Lease Billing Report', N'Tank Management', 66, N'Lease Billing Report', N'Report', N'Report', N'Lease Billing Report', N'small-menu-report', 0, 0, 0, 1, NULL, 1)
		--INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		--VALUES (90, N'Missed Julian Deliveries', N'Tank Management', 66, N'Missed Julian Deliveries', N'Report', N'Report', N'Missed Julian Deliveries', N'small-menu-report', 0, 0, 0, 1, NULL, 1)
		--INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		--VALUES (91, N'Out of Range Burn Rates', N'Tank Management', 66, N'Out of Range Burn Rates', N'Report', N'Report', N'Out of Range Burn Rates', N'small-menu-report', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (92, N'Call Entry Printout', N'Tank Management', 66, N'Call Entry Printout', N'Report', N'Screen', N'TankManagement.view.CallEntryParameter', N'small-menu-report', 0, 0, 0, 1, 0, 1)
		--INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		--VALUES (93, N'Fill Group', N'Tank Management', 66, N'Fill Group', N'Report', N'Report', N'Fill Group', N'small-menu-report', 0, 0, 0, 1, NULL, 1)
		--INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		--VALUES (94, N'Tank Inventory', N'Tank Management', 66, N'Tank Inventory', N'Report', N'Report', N'Tank Inventory', N'small-menu-report', 0, 0, 0, 1, NULL, 1)
		--INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		--VALUES (95, N'Customer List by Route', N'Tank Management', 66, N'Customer List by Route', N'Report', N'Report', N'Customer List by Route', N'small-menu-report', 0, 0, 0, 1, NULL, 1)
		--INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		--VALUES (96, N'Device Actions', N'Tank Management', 66, N'Device Actions', N'Report', N'Report', N'Device Actions', N'small-menu-report', 0, 0, 0, 1, NULL, 1)
		--INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		--VALUES (97, N'Open Call Entries', N'Tank Management', 66, N'Open Call Entries', N'Report', N'Report', N'Open Call Entries', N'small-menu-report', 0, 0, 0, 1, NULL, 1)
		--INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		--VALUES (98, N'Work Order Status', N'Tank Management', 66, N'Work Order Status', N'Report', N'Report', N'Work Order Status', N'small-menu-report', 0, 0, 0, 1, NULL, 1)
		--INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		--VALUES (99, N'Leak Check / Gas Check', N'Tank Management', 66, N'Leak Check / Gas Check', N'Report', N'Report', N'Leak Check / Gas Check', N'small-menu-report', 0, 0, 0, 1, NULL, 1)

		/* CASH MANAGEMENT */
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (100, N'Cash Management', N'Cash Management', 0, N'Cash Management', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 6, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (102, N'Bank Deposits', N'Cash Management', 100, N'Bank Deposits', N'Activity', N'Screen', N'CashManagement.view.BankDeposit?showSearch=true', N'small-menu-activity', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (103, N'Bank Transactions', N'Cash Management', 100, N'Bank Transactions', N'Activity', N'Screen', N'CashManagement.view.BankTransactions?showSearch=true', N'small-menu-activity', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (104, N'Bank Transfers', N'Cash Management', 100, N'Bank Transfers', N'Activity', N'Screen', N'CashManagement.view.BankTransfer?showSearch=true', N'small-menu-activity', 0, 0, 0, 1, NULL, 1)
		--INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		--VALUES (105, N'Miscellaneous Checks', N'Cash Management', 100, N'Miscellaneous Checks', N'Activity', N'Screen', N'CashManagement.view.MiscellaneousChecks?showSearch=true', N'small-menu-activity', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (106, N'Bank Account Register', N'Cash Management', 100, N'Bank Account Register', N'Activity', N'Screen', N'CashManagement.view.BankAccountRegister', N'small-menu-activity', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (107, N'Bank Reconciliation', N'Cash Management', 100, N'Bank Reconciliation', N'Activity', N'Screen', N'CashManagement.view.BankReconciliation', N'small-menu-activity', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (109, N'Banks', N'Cash Management', 100, N'Banks', N'Maintenance', N'Screen', N'CashManagement.view.Banks?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (110, N'Bank Accounts', N'Cash Management', 100, N'Bank Accounts', N'Maintenance', N'Screen', N'CashManagement.view.BankAccounts?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (111, N'Bank File Formats', N'Cash Management', 100, N'Bank File Formats', N'Maintenance', N'Screen', N'CashManagement.view.BankFileFormat?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)

		/* ACCOUNTS PAYABLE */
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (112, N'Purchasing (A/P)', N'Accounts Payable', 0, N'Purchasing (A/P)', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 9, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (114, N'Pay Voucher Details', N'Accounts Payable', 112, N'Pay Voucher Details', N'Activity', N'Screen', N'AccountsPayable.view.PayVouchersDetail?showSearch=true', N'small-menu-activity', 0, 0, 0, 1, 7, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (115, N'Pay Vouchers', N'Accounts Payable', 112, N'Pay Vouchers (Multi-Vendor)', N'Activity', N'Screen', N'AccountsPayable.view.PayVouchers', N'small-menu-activity', 0, 0, 0, 1, 6, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (116, N'Voucher Batch Entry', N'Accounts Payable', 112, N'Voucher Batch Entry', N'Activity', N'Screen', N'AccountsPayable.view.VoucherBatch?showSearch=true', N'small-menu-activity', 0, 0, 0, 1, 1, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (117, N'Batch Posting', N'Accounts Payable', 112, N'Batch Posting', N'Activity', N'Screen', N'i21.view.BatchPosting?module=Purchasing', N'small-menu-activity', 0, 0, 0, 1, 5, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (118, N'Process Payments', N'Accounts Payable', 112, N'Process Payments', N'Activity', N'Screen', N'AccountsPayable.controller.PrintChecks', N'small-menu-activity', 0, 0, 0, 1, 8, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (120, N'Import Vouchers from Origin', N'Accounts Payable', 112, N'Import Vouchers from Origin', N'Import', N'Screen', N'AccountsPayable.view.ImportAPInvoice', N'small-menu-import', 0, 0, 0, 1, 3, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (122, N'Vendors', N'Accounts Payable', 112, N'Vendors', N'Maintenance', N'Screen', N'AccountsPayable.view.EntityVendor?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (125, N'Open Payables', N'Accounts Payable', 112, N'Open Payables', N'Report', N'Screen', N'Reporting.view.ReportManager?group=Purchasing&report=OpenPayables&direct=true&showCriteria=true', N'small-menu-report', 0, 0, 0, 1, NULL, 1)
		--INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		--VALUES (126, N'Vendor History', N'Accounts Payable', 112, N'Vendor History', N'Report', N'Report', N'Vendor History', N'small-menu-report', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (127, N'Cash Requirements', N'Accounts Payable', 112, N'Cash Requirements', N'Report', N'Screen', N'Cash Requirements', N'small-menu-report', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (129, N'Check Register', N'Accounts Payable', 112, N'Check Register', N'Report', N'Report', N'Check Register', N'small-menu-report', 0, 0, 0, 1, NULL, 1)
		--INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		--VALUES (130, N'AP Transactions By GL Account', N'Accounts Payable', 112, N'AP Transactions By GL Account', N'Report', N'Screen', N'Reporting.view.ReportManager?group=Purchasing&report=APTransactionByGLAccount&direct=true&showCriteria=true', N'small-menu-report', 0, 0, 0, 1, NULL, 1)

		/* ACCOUNTS RECEIVABLE */
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (131, N'Sales (A/R)', N'Accounts Receivable', 0, N'Sales (A/R)', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 10, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (134, N'Customers', N'Accounts Receivable', 131, N'Customers', N'Maintenance', N'Screen', N'EntityManagement.view.Entity?showSearch=true&searchCommand=searchEntityCustomer', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (135, N'Customer Contact List', N'Accounts Receivable', 131, N'Customer Contact List', N'Maintenance', N'Screen', N'AccountsReceivable.view.CustomerContactList', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (136, N'Sales Reps', N'System Manager', 131, N'Sales Reps', N'Maintenance', N'Screen', N'AccountsReceivable.view.EntitySalesperson?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (137, N'Market Zone', N'System Manager', 131, N'Market Zone', N'Maintenance', N'Screen', N'AccountsReceivable.view.MarketZone', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)		
		/* WILL BE RENAME FROM Statement Footer Messages TO COMMENT MAINTENANCE */
		-- INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		-- VALUES (138, N'Comment Maintenance', N'Accounts Receivable', 131, N'Comment Maintenance', N'Maintenance', N'Screen', N'AccountsReceivable.view.StatementFooterMessage', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (139, N'Service Charges', N'Accounts Receivable', 131, N'Service Charges', N'Maintenance', N'Screen', N'AccountsReceivable.view.ServiceCharge?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (140, N'Customer Groups', N'Accounts Receivable', 131, N'Customer Groups', N'Maintenance', N'Screen', N'EntityManagement.view.CustomerGroup?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)

		/* HELP DESK */
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (141, N'Help Desk', N'Help Desk', 0, N'Help Desk', NULL, N'Folder', N'HelpDesk', N'small-folder', 1, 0, 0, 0, 22, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (143, N'Tickets', N'Help Desk', 141, N'Tickets', N'Activity', N'Screen', N'HelpDesk.view.TicketList', N'small-menu-activity', 0, 0, 0, 1, 2, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (144, N'Open Tickets', N'Help Desk', 141, N'Open Tickets', N'Activity', N'Screen', N'HelpDesk.view.TicketList', N'small-menu-activity', 0, 0, 0, 1, 3, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (145, N'Tickets Assigned to Me', N'Help Desk', 141, N'Tickets Assigned to Me', N'Activity', N'Screen', N'HelpDesk.view.TicketList', N'small-menu-activity', 0, 0, 0, 1, 4, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (146, N'Create Ticket', N'Help Desk', 141, N'Create Ticket', N'Activity', N'Screen', N'HelpDesk.controller.CreateTicket', N'small-menu-activity', 0, 0, 0, 1, 1, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (148, N'Ticket Groups', N'Help Desk', 141, N'Ticket Groups', N'Maintenance', N'Screen', N'HelpDesk.view.TicketGroup?showSearch=true&searchCommand=Group', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (149, N'Ticket Types', N'Help Desk', 141, N'Ticket Types', N'Maintenance', N'Screen', N'HelpDesk.view.TicketType', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (150, N'Ticket Statuses', N'Help Desk', 141, N'Ticket Statuses', N'Maintenance', N'Screen', N'HelpDesk.view.TicketStatus', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (151, N'Ticket Priorities', N'Help Desk', 141, N'Ticket Priorities', N'Maintenance', N'Screen', N'HelpDesk.view.TicketPriority', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		--VALUES (152, N'Ticket Job Codes', N'Help Desk', 141, N'Ticket Job Codes', N'Maintenance', N'Screen', N'HelpDesk.view.TicketJobCode', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
		--INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (153, N'Products', N'Help Desk', 141, N'Products', N'Maintenance', N'Screen', N'HelpDesk.view.Product?showSearch=true&searchCommand=Product', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (154, N'Help Desk Settings', N'Help Desk', 141, N'Help Desk Settings', N'Maintenance', N'Screen', N'HelpDesk.view.HelpDeskSettings', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (155, N'Email Setup', N'Help Desk', 141, N'Email Setup', N'Maintenance', N'Screen', N'HelpDesk.view.HelpDeskEmailSetup', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)

		SET IDENTITY_INSERT [dbo].[tblSMMasterMenu] OFF

	END
GO

/* DASHBOARD */
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Dashboard' AND strModuleName = 'Dashboard' AND intParentMenuID = 0)
UPDATE tblSMMasterMenu SET intSort = 1 WHERE strMenuName = 'Dashboard' AND strModuleName = 'Dashboard' AND intParentMenuID = 0

DECLARE @DashboardParentMenuId INT
SELECT @DashboardParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Dashboard' AND strModuleName = 'Dashboard' AND intParentMenuID = 0

/* CHANGE SCREEN CATEGORY 1740 TO 1810 */
UPDATE tblSMMasterMenu SET strCategory = 'System', strIcon = 'small-menu-system' WHERE strMenuName IN ('System Dashboard') AND strModuleName = N'Dashboard'

/* CATEGORY FOLDERS */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Dashboards' AND strModuleName = 'Dashboard' AND intParentMenuID = @DashboardParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Dashboards', N'Dashboard', @DashboardParentMenuId, N'Dashboards', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 0 WHERE strMenuName = 'Dashboards' AND strModuleName = 'Dashboard' AND intParentMenuID = @DashboardParentMenuId

DECLARE @DashboardDashboardsParentMenuId INT
SELECT @DashboardDashboardsParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Dashboards' AND strModuleName = 'Dashboard' AND intParentMenuID = @DashboardParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'Dashboard' AND intParentMenuID = @DashboardParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Maintenance', N'Dashboard', @DashboardParentMenuId, N'Maintenance', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 1, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 1 WHERE strMenuName = 'Maintenance' AND strModuleName = 'Dashboard' AND intParentMenuID = @DashboardParentMenuId

DECLARE @DashboardMaintenanceParentMenuId INT
SELECT @DashboardMaintenanceParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'Dashboard' AND intParentMenuID = @DashboardParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'System' AND strModuleName = 'Dashboard' AND intParentMenuID = @DashboardParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'System', N'Dashboard', @DashboardParentMenuId, N'System', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 2, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 2 WHERE strMenuName = 'System' AND strModuleName = 'Dashboard' AND intParentMenuID = @DashboardParentMenuId

DECLARE @DashboardSystemParentMenuId INT
SELECT @DashboardSystemParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'System' AND strModuleName = 'Dashboard' AND intParentMenuID = @DashboardParentMenuId

/* ADD TO RESPECTIVE CATEGORY */ 
UPDATE tblSMMasterMenu SET intParentMenuID = @DashboardDashboardsParentMenuId WHERE intParentMenuID =  @DashboardParentMenuId AND strCategory = 'Dashboards'
UPDATE tblSMMasterMenu SET intParentMenuID = @DashboardMaintenanceParentMenuId WHERE intParentMenuID =  @DashboardParentMenuId AND strCategory = 'Maintenance'
UPDATE tblSMMasterMenu SET intParentMenuID = @DashboardSystemParentMenuId WHERE intParentMenuID IN (@DashboardParentMenuId, @DashboardDashboardsParentMenuId) AND strCategory = 'System'

/* START OF RENAMING  */
UPDATE tblSMMasterMenu SET strMenuName = N'Dashboard Configuration', strDescription = N'Dashboard Configuration' WHERE strMenuName = N'Tabs' AND strModuleName = N'Dashboard' AND intParentMenuID = @DashboardMaintenanceParentMenuId
UPDATE tblSMMasterMenu SET strMenuName = N'Panel Connection', strDescription = N'Panel Connection' WHERE strMenuName = N'Connections' AND strModuleName = N'Dashboard' AND intParentMenuID = @DashboardMaintenanceParentMenuId
/* END OF RENAMING  */

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Dashboard Configuration' AND strModuleName = N'Dashboard' AND intParentMenuID = @DashboardMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 0, strCommand = N'Dashboard.view.TabSetup' WHERE strMenuName = N'Dashboard Configuration' AND strModuleName = N'Dashboard' AND intParentMenuID = @DashboardMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Panels' AND strModuleName = N'Dashboard' AND intParentMenuID = @DashboardMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 1, strCommand = N'Dashboard.view.PanelSettings?showSearch=true' WHERE strMenuName = N'Panels' AND strModuleName = N'Dashboard' AND intParentMenuID = @DashboardMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Panel Connection' AND strModuleName = N'Dashboard' AND intParentMenuID = @DashboardMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 2, strCommand = N'Dashboard.view.Connection' WHERE strMenuName = N'Panel Connection' AND strModuleName = N'Dashboard' AND intParentMenuID = @DashboardMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Panel Layout' AND strModuleName = N'Dashboard' AND intParentMenuID = @DashboardMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 3, strCommand = N'Dashboard.view.PanelLayout' WHERE strMenuName = N'Panel Layout' AND strModuleName = N'Dashboard' AND intParentMenuID = @DashboardMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'System Dashboard' AND strModuleName = 'Dashboard' AND intParentMenuID = @DashboardSystemParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'System Dashboard', N'Dashboard', @DashboardSystemParentMenuId, N'System Dashboard', N'System', N'Home', N'GlobalComponentEngine.view.SystemDashboard', N'small-menu-system', 0, 0, 0, 1, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 0, strCommand = N'GlobalComponentEngine.view.SystemDashboard', strIcon = 'small-menu-dashboard' WHERE strMenuName = 'System Dashboard' AND strModuleName = 'Dashboard' AND intParentMenuID = @DashboardSystemParentMenuId

/* START OF DELETING */
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Add Panel' AND strModuleName = N'Dashboard' AND intParentMenuID = @DashboardMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Display Dashboard' AND strModuleName = 'Dashboard' AND intParentMenuID = @DashboardMaintenanceParentMenuId
/* END OF DELETING */

/* SYSTEM MANAGER */
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'System Manager' AND strModuleName = N'System Manager' AND intParentMenuID = 0)
UPDATE tblSMMasterMenu SET intSort = 2 WHERE strMenuName = N'System Manager' AND strModuleName = N'System Manager' AND intParentMenuID = 0

DECLARE @SystemManagerParentMenuId INT
SELECT @SystemManagerParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'System Manager' AND strModuleName = 'System Manager' AND intParentMenuID = 0

/* CHANGE SCREEN CATEGORY 1730 TO 1810 */
UPDATE tblSMMasterMenu SET strCategory = 'Activity', strIcon = 'small-menu-activity' WHERE strMenuName IN ('Users', 'User Roles', 'Security Policies', 'Company Configuration', 'Locked Records', 'Emails', 'Email History') AND strModuleName = N'System Manager'
UPDATE tblSMMasterMenu SET strCategory = 'Maintenance', strIcon = 'small-menu-maintenance' WHERE strMenuName IN ('Custom Tab Designer', 'File Field Mapping', 'Languages', 'Letters', 'Modules', 'Report Labels', 'Screen Labels', 'Starting Numbers') AND strModuleName = N'System Manager'
UPDATE tblSMMasterMenu SET strCategory = 'Licensing', strIcon = 'small-menu-licensing' WHERE strMenuName IN ('Company Registration', 'License Generator', 'License Types') AND strModuleName = N'System Manager'

/* CATEGORY FOLDERS */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Activities' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intRow], [intConcurrencyId]) 
	VALUES (N'Activities', N'System Manager', @SystemManagerParentMenuId, N'Activities', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 0, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 0, intRow = 0 WHERE strMenuName = 'Activities' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerParentMenuId

DECLARE @SystemManagerActivitiesParentMenuId INT
SELECT @SystemManagerActivitiesParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Activities' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intRow], [intConcurrencyId]) 	
	VALUES (N'Maintenance', N'System Manager', @SystemManagerParentMenuId, N'Maintenance', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 1, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 1, intRow = 0 WHERE strMenuName = 'Maintenance' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerParentMenuId

DECLARE @SystemManagerMaintenanceParentMenuId INT
SELECT @SystemManagerMaintenanceParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Announcements' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intRow], [intConcurrencyId]) 
	VALUES (N'Announcements', N'System Manager', @SystemManagerParentMenuId, N'Announcements', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 2, 0, 2)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 2, intRow = 0 WHERE strMenuName = 'Announcements' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerParentMenuId

DECLARE @AnnouncementsParentMenuId INT
SELECT @AnnouncementsParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Announcements' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Utilities' AND strModuleName = N'System Manager' AND intParentMenuID = @SystemManagerParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'', intSort = 3, intRow = 0 WHERE strMenuName = N'Utilities' AND strModuleName = N'System Manager' AND intParentMenuID = @SystemManagerParentMenuId

DECLARE @UtilitiesParentMenuId INT
SELECT @UtilitiesParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Utilities' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Create' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intRow], [intConcurrencyId]) 
	VALUES (N'Create', N'System Manager', @SystemManagerParentMenuId, N'Create', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 0, 1, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 0, intRow = 1 WHERE strMenuName = 'Create' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerParentMenuId

DECLARE @SystemManagerCreateParentMenuId INT
SELECT @SystemManagerCreateParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Create' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Licensing' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intRow], [intConcurrencyId]) 
	VALUES (N'Licensing', N'System Manager', @SystemManagerParentMenuId, N'Licensing', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 1, 1, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 1, intRow = 1 WHERE strMenuName = 'Licensing' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerParentMenuId

DECLARE @SystemManagerLicensingParentMenuId INT
SELECT @SystemManagerLicensingParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Licensing' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerParentMenuId

/* ADD TO RESPECTIVE CATEGORY */
UPDATE tblSMMasterMenu SET intParentMenuID = @SystemManagerActivitiesParentMenuId WHERE intParentMenuID IN (@SystemManagerMaintenanceParentMenuId, @SystemManagerParentMenuId) AND strCategory = 'Activity'
UPDATE tblSMMasterMenu SET intParentMenuID = @SystemManagerMaintenanceParentMenuId WHERE intParentMenuID IN (@SystemManagerParentMenuId) AND strCategory = 'Maintenance'
UPDATE tblSMMasterMenu SET intParentMenuID = @SystemManagerLicensingParentMenuId WHERE intParentMenuID IN (@SystemManagerMaintenanceParentMenuId, @SystemManagerParentMenuId) AND strCategory = 'Licensing'

/* START OF RENAMING  */
UPDATE tblSMMasterMenu SET strMenuName = N'Custom Tab Designer', intSort = 16 WHERE strMenuName = 'Screen Designer' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerMaintenanceParentMenuId
UPDATE tblSMMasterMenu SET strMenuName = N'Email History' WHERE strMenuName = 'Emails' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerActivitiesParentMenuId
UPDATE tblSMMasterMenu SET strMenuName = 'Announcements' WHERE strMenuName = 'Maintenance' AND strModuleName = 'System Manager' AND intParentMenuID = @AnnouncementsParentMenuId
UPDATE tblSMMasterMenu SET strMenuName = 'Imports and Conversions', strDescription = 'Imports and Conversions' WHERE strMenuName = N'Origin Conversions' AND strModuleName = N'System Manager' AND intParentMenuID = @UtilitiesParentMenuId
UPDATE tblSMMasterMenu SET strMenuName = 'Intercompany Transaction Configuration', strDescription = 'Intercompany Transaction Configuration' WHERE strMenuName = 'Inter-Company Transaction Configuration' AND strModuleName = 'System Manager' AND intParentMenuID = @UtilitiesParentMenuId
UPDATE tblSMMasterMenu SET strMenuName = 'Email Log', strDescription = 'Email Log' WHERE strMenuName = 'Email History' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerActivitiesParentMenuId
/* END OF RENAMING  */

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Users' AND strModuleName = N'System Manager' AND intParentMenuID = @SystemManagerActivitiesParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'i21.view.EntityUser?showSearch=true', intSort = 0 WHERE strMenuName = N'Users' AND strModuleName = N'System Manager' AND intParentMenuID = @SystemManagerActivitiesParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'User Roles' AND strModuleName = N'System Manager' AND intParentMenuID = @SystemManagerActivitiesParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'i21.view.UserRole?showSearch=true', intSort = 1 WHERE strMenuName = N'User Roles' AND strModuleName = N'System Manager' AND intParentMenuID = @SystemManagerActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Portal User Roles' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Portal User Roles', N'System Manager', @SystemManagerActivitiesParentMenuId, N'Portal User Roles', N'Activity', N'Screen', N'i21.view.PortalRole?showSearch=true', N'small-menu-activity', 0, 0, 0, 1, 2, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'i21.view.PortalRole?showSearch=true', intSort = 2 WHERE strMenuName = 'Portal User Roles' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Security Policies' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Security Policies', N'System Manager', @SystemManagerActivitiesParentMenuId, N'Security Policies', N'Activity', N'Screen', N'i21.view.SecurityPolicy?showSearch=true', N'small-menu-activity', 0, 0, 0, 1, 4, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'i21.view.SecurityPolicy?showSearch=true', intSort = 3 WHERE strMenuName = 'Security Policies' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerActivitiesParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Company Configuration' AND strModuleName = N'System Manager' AND intParentMenuID = @SystemManagerActivitiesParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'i21.view.CompanyPreference', intSort = 4 WHERE strMenuName = N'Company Configuration' AND strModuleName = N'System Manager' AND intParentMenuID = @SystemManagerActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Locked Records' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Locked Records', N'System Manager', @SystemManagerActivitiesParentMenuId, N'Locked Records', N'Activity', N'Screen', N'GlobalComponentEngine.view.LockedRecord', N'small-menu-activity', 0, 0, 0, 1, 5, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'GlobalComponentEngine.view.LockedRecord', intSort = 5 WHERE strMenuName = 'Locked Records' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Custom Tab Designer' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Custom Tab Designer', N'System Manager', @SystemManagerMaintenanceParentMenuId, N'Custom Tab Designer', N'Maintenance', N'Screen', N'GlobalComponentEngine.view.ScreenDesigner?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'GlobalComponentEngine.view.ScreenDesigner?showSearch=true', intSort = 0 WHERE strMenuName = 'Custom Tab Designer' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Email Log' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Email Log', N'System Manager', @SystemManagerMaintenanceParentMenuId, N'Email Log', N'Activity', N'Screen', N'GlobalComponentEngine.view.EmailHistory?showSearch=true', N'small-menu-activity', 0, 0, 0, 1, 1, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'GlobalComponentEngine.view.EmailHistory?showSearch=true', intSort = 1 WHERE strMenuName = 'Email Log' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerMaintenanceParentMenuId


IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'File Field Mapping' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'File Field Mapping', N'System Manager', @SystemManagerMaintenanceParentMenuId, N'File Field Mapping', N'Maintenance', N'Screen', N'i21.view.FileFieldMapping?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 2, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'i21.view.FileFieldMapping?showSearch=true', intSort = 2 WHERE strMenuName = 'File Field Mapping' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Languages' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Languages', N'System Manager', @SystemManagerMaintenanceParentMenuId, N'Languages', N'Maintenance', N'Screen', N'i21.view.Language', N'small-menu-maintenance', 0, 0, 0, 1, 3, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'i21.view.Language', intSort = 3 WHERE strMenuName = 'Languages' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Letters' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Letters', N'System Manager', @SystemManagerMaintenanceParentMenuId, N'Letters', N'Maintenance', N'Screen', N'i21.view.Letters?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 4, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'i21.view.Letters?showSearch=true', intSort = 4 WHERE strMenuName = 'Letters' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Modules' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Modules', N'System Manager', @SystemManagerMaintenanceParentMenuId, N'Modules', N'Maintenance', N'Screen', N'i21.view.Module', N'small-menu-maintenance', 0, 0, 0, 1, 5, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'i21.view.Module', intSort = 5 WHERE strMenuName = 'Modules' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Report Labels' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Report Labels', N'System Manager', @SystemManagerMaintenanceParentMenuId, N'Report Labels', N'Maintenance', N'Screen', N'GlobalComponentEngine.view.ReportLabels?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 6, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'GlobalComponentEngine.view.ReportLabels?showSearch=true', intSort = 6 WHERE strMenuName = 'Report Labels' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Screen Labels' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Screen Labels', N'System Manager', @SystemManagerMaintenanceParentMenuId, N'Screen Labels', N'Maintenance', N'Screen', N'GlobalComponentEngine.view.ScreenLabel', N'small-menu-maintenance', 0, 0, 0, 1, 7, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'GlobalComponentEngine.view.ScreenLabel', intSort = 7 WHERE strMenuName = 'Screen Labels' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Starting Numbers' AND strModuleName = N'System Manager' AND intParentMenuID = @SystemManagerMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'i21.view.StartingNumbers', intSort = 8 WHERE strMenuName = N'Starting Numbers' AND strModuleName = N'System Manager' AND intParentMenuID = @SystemManagerMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Announcements' AND strModuleName = 'System Manager' AND intParentMenuID = @AnnouncementsParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Announcements', N'System Manager', @AnnouncementsParentMenuId, N'Announcement Maintenance', N'Announcement', N'Screen', N'i21.view.Announcement', N'small-menu-announcement', 0, 0, 0, 1, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 0, strCommand = 'i21.view.Announcement' WHERE strMenuName = 'Announcements' AND strModuleName = 'System Manager' AND intParentMenuID = @AnnouncementsParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Announcement Types' AND strModuleName = 'System Manager' AND intParentMenuID = @AnnouncementsParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Announcement Types', N'System Manager', @AnnouncementsParentMenuId, N'Announcement Types', N'Announcement', N'Screen', N'i21.view.AnnouncementType', N'small-menu-announcement', 0, 0, 0, 1, 1, 1)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 1, strCommand = 'i21.view.AnnouncementType' WHERE strMenuName = 'Announcement Types' AND strModuleName = 'System Manager' AND intParentMenuID = @AnnouncementsParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'File Downloads' AND strModuleName = 'System Manager' AND intParentMenuID = @UtilitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'File Downloads', N'System Manager', @UtilitiesParentMenuId, N'File Downloads', N'Utility', N'Screen', N'i21.view.FileDownloads', N'small-menu-utility', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 0, strCommand = N'i21.view.FileDownloads' WHERE strMenuName = 'File Downloads' AND strModuleName = 'System Manager' AND intParentMenuID = @UtilitiesParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Imports and Conversions' AND strModuleName = N'System Manager' AND intParentMenuID = @UtilitiesParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 1, strCommand = N'i21.view.OriginConversion' WHERE strMenuName = N'Imports and Conversions' AND strModuleName = N'System Manager' AND intParentMenuID = @UtilitiesParentMenuId

-- IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Intercompany Transaction Configuration' AND strModuleName = 'System Manager' AND intParentMenuID = @UtilitiesParentMenuId)
-- 	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
-- 	VALUES (N'Intercompany Transaction Configuration', N'System Manager', @UtilitiesParentMenuId, N'Intercompany Transaction Configuration', N'Utility', N'Screen', N'i21.view.InterCompanyTransactionConfiguration', N'small-menu-utility', 0, 0, 0, 1, 2, 1)
-- ELSE 
-- 	UPDATE tblSMMasterMenu SET intSort = 2, strCommand = N'i21.view.InterCompanyTransactionConfiguration' WHERE strMenuName = 'Intercompany Transaction Configuration' AND strModuleName = 'System Manager' AND intParentMenuID = @UtilitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'New User' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerCreateParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId])
	VALUES (N'New User', N'System Manager', @SystemManagerCreateParentMenuId, N'New User', N'Create', N'Screen', N'i21.view.EntityUser?action=new', N'small-menu-create', 0, 0, 0, 1, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 0, strCommand = N'i21.view.EntityUser?action=new' WHERE strMenuName = 'New User' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerCreateParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Company Registration' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerLicensingParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Company Registration', N'System Manager', @SystemManagerLicensingParentMenuId, N'Company Registration', N'Licensing', N'Screen', N'GlobalComponentEngine.view.CompanyRegistration?action=close', N'small-menu-licensing', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'GlobalComponentEngine.view.CompanyRegistration?action=close', intSort = 0 WHERE strMenuName = 'Company Registration' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerLicensingParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'License Generator' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerLicensingParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'License Generator', N'System Manager', @SystemManagerLicensingParentMenuId, N'License Generator', N'Licensing', N'Screen', N'GlobalComponentEngine.view.License?showSearch=true', N'small-menu-licensing', 0, 0, 0, 1, 1, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'GlobalComponentEngine.view.License?showSearch=true', intSort = 0 WHERE strMenuName = 'License Generator' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerLicensingParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'License Types' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerLicensingParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'License Types', N'System Manager', @SystemManagerLicensingParentMenuId, N'License Types', N'Licensing', N'Screen', N'GlobalComponentEngine.view.LicenseType', N'small-menu-licensing', 0, 0, 0, 1, 1, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'GlobalComponentEngine.view.LicenseType', intSort = 1 WHERE strMenuName = 'License Types' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerLicensingParentMenuId

--/* Start of Remodule*/
--IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'i21 Updates' AND strModuleName = 'Service Pack' AND intParentMenuID = @UtilitiesParentMenuId)
--UPDATE tblSMMasterMenu SET strModuleName = N'System Manager' WHERE strMenuName = 'i21 Updates' AND strModuleName = 'Service Pack' AND intParentMenuID = @UtilitiesParentMenuId
--IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Announcements' AND strModuleName = N'Help Desk')
--UPDATE tblSMMasterMenu SET strModuleName = 'System Manager' WHERE strMenuName = N'Announcements' AND strModuleName = N'Help Desk'
--IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Announcement Types' AND strModuleName = N'Help Desk')
--UPDATE tblSMMasterMenu SET strModuleName = 'System Manager' WHERE strMenuName = N'Announcement Types' AND strModuleName = N'Help Desk'
--IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Maintenance' AND strModuleName = N'Help Desk' AND strDescription = 'Announcement Maintenance')
--UPDATE tblSMMasterMenu SET strModuleName = 'System Manager' WHERE strMenuName = N'Maintenance' AND strModuleName = N'Help Desk' AND strDescription = 'Announcement Maintenance'
--/* End of Remodule*/


--/* Start Move */
--DECLARE @CommonInfoMenuId INT
--SELECT @CommonInfoMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Common Info' AND strModuleName = 'System Manager' AND intParentMenuID = 0

--IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Announcements' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoMenuId)
--UPDATE tblSMMasterMenu SET intParentMenuID = @SystemManagerParentMenuId WHERE strMenuName = 'Announcements' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoMenuId
--/* End Move */

-- END OF ANNOUNCEMENT

/* Start Delete */
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'i21 Updates' AND strModuleName = 'Service Pack' AND intParentMenuID = @UtilitiesParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Company Setup' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Import Origin Users' AND strModuleName = N'System Manager' AND intParentMenuID = @UtilitiesParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Import Origin Menus' AND strModuleName = 'System Manager' AND intParentMenuID = @UtilitiesParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Custom Fields' AND strModuleName = N'System Manager' AND intParentMenuID = @SystemManagerMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Custom Grid' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Report Manager' AND strModuleName = N'System Manager' AND intParentMenuID = @SystemManagerMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'i21 Updates' AND strModuleName = 'System Manager' AND intParentMenuID = @UtilitiesParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Email Log' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerActivitiesParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Intercompany Transaction Configuration' AND strModuleName = 'System Manager' AND intParentMenuID = @UtilitiesParentMenuId
/* End Delete */

/* COMMON INFO */
IF EXISTS (SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Common Info' AND strModuleName = 'System Manager')
UPDATE tblSMMasterMenu SET intSort = 3, intParentMenuID = 0 FROM tblSMMasterMenu WHERE strMenuName = 'Common Info' AND strModuleName = 'System Manager'

DECLARE @CommonInfoParentMenuId INT
SELECT @CommonInfoParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Common Info' AND strModuleName = 'System Manager' AND intParentMenuID = 0

/* CATEGORY FOLDERS */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Activities' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intRow], [intConcurrencyId]) 
	VALUES (N'Activities', N'System Manager', @CommonInfoParentMenuId, N'Activities', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 0, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 0, intRow = 0 WHERE strMenuName = 'Activities' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intRow], [intConcurrencyId]) 
	VALUES (N'Maintenance', N'System Manager', @CommonInfoParentMenuId, N'Maintenance', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 1, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 1, intRow = 0 WHERE strMenuName = 'Maintenance' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Approvals' AND strModuleName = 'System Manager' AND strType = N'Folder' AND intParentMenuID = @CommonInfoParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intRow], [intConcurrencyId]) 	
	VALUES (N'Approvals', N'System Manager', @CommonInfoParentMenuId, N'Approvals', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 2, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 2, intRow = 0 WHERE strMenuName = 'Approvals' AND strModuleName = 'System Manager' AND strType = N'Folder'  AND intParentMenuID = @CommonInfoParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Tax Setup' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intRow], [intConcurrencyId]) 
	VALUES (N'Tax Setup', N'System Manager', @CommonInfoParentMenuId, N'Tax Setup', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 3, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 3, intRow = 0 WHERE strMenuName = 'Tax Setup' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId

DECLARE @CommonInfoActivitiesParentMenuId INT
SELECT @CommonInfoActivitiesParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Activities' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId

DECLARE @CommonInfoMaintenanceParentMenuId INT
SELECT @CommonInfoMaintenanceParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId

DECLARE @CommonInfoApprovalsParentMenuId INT
SELECT @CommonInfoApprovalsParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Approvals' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId

DECLARE @CommonInfoTaxSetupParentMenuId INT
SELECT @CommonInfoTaxSetupParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Tax Setup' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId

/* CHANGE SCREEN TYPE 1730 */
UPDATE tblSMMasterMenu SET strCategory = 'Activity', strIcon = 'small-menu-activity' WHERE strMenuName = N'Company Locations' AND strModuleName = N'System Manager'
UPDATE tblSMMasterMenu SET strCategory = 'Activity', strIcon = 'small-menu-activity' WHERE strMenuName = N'Recurring Transactions' AND strModuleName = N'System Manager'
UPDATE tblSMMasterMenu SET strCategory = 'Activity', strIcon = 'small-menu-activity' WHERE strMenuName = N'Batch Posting' AND strModuleName = N'System Manager'
UPDATE tblSMMasterMenu SET strCategory = 'Activity', strIcon = 'small-menu-activity' WHERE strMenuName = N'Calendar' AND strModuleName = N'System Manager'
UPDATE tblSMMasterMenu SET strCategory = 'Activity', strIcon = 'small-menu-activity' WHERE strMenuName = N'Currencies' AND strModuleName = N'System Manager'
UPDATE tblSMMasterMenu SET strCategory = 'Activity', strIcon = 'small-menu-activity' WHERE strMenuName = N'Currency Exchange Rates' AND strModuleName = N'System Manager'
UPDATE tblSMMasterMenu SET strCategory = 'Activity', strIcon = 'small-menu-activity' WHERE strMenuName = N'Currency Exchange Rate Types' AND strModuleName = N'System Manager'

UPDATE tblSMMasterMenu SET strCategory = 'Approval', strIcon = 'small-menu-activity' WHERE strMenuName = N'Approvals' AND strModuleName = N'System Manager' AND strType <> 'Folder'
UPDATE tblSMMasterMenu SET strCategory = 'Approval', strIcon = 'small-menu-maintenance' WHERE strMenuName = N'Approver Configuration' AND strModuleName = N'System Manager'
UPDATE tblSMMasterMenu SET strCategory = 'Approval', strIcon = 'small-menu-maintenance' WHERE strMenuName = N'Approver Groups' AND strModuleName = N'System Manager'
UPDATE tblSMMasterMenu SET strCategory = 'Approval', strIcon = 'small-menu-activity' WHERE strMenuName = N'Approval List' AND strModuleName = N'System Manager'

UPDATE tblSMMasterMenu SET strCategory = 'Tax Setup', strIcon = 'small-menu-activity' WHERE strMenuName = N'Tax Class' AND strModuleName = N'System Manager'
UPDATE tblSMMasterMenu SET strCategory = 'Tax Setup', strIcon = 'small-menu-activity' WHERE strMenuName = N'Tax Codes' AND strModuleName = N'System Manager'
UPDATE tblSMMasterMenu SET strCategory = 'Tax Setup', strIcon = 'small-menu-activity' WHERE strMenuName = N'Tax Groups' AND strModuleName = N'System Manager'

/* ADD TO RESPECTIVE CATEGORY */
UPDATE tblSMMasterMenu SET intParentMenuID = @CommonInfoActivitiesParentMenuId WHERE intParentMenuID IN  (@CommonInfoParentMenuId, @CommonInfoMaintenanceParentMenuId) AND strCategory = 'Activity'
UPDATE tblSMMasterMenu SET intParentMenuID = @CommonInfoMaintenanceParentMenuId WHERE intParentMenuID =  @CommonInfoParentMenuId AND strCategory = 'Maintenance'
UPDATE tblSMMasterMenu SET intParentMenuID = @CommonInfoApprovalsParentMenuId WHERE intParentMenuID IN (@CommonInfoParentMenuId, @CommonInfoActivitiesParentMenuId, @CommonInfoMaintenanceParentMenuId) AND strCategory = 'Approval'
UPDATE tblSMMasterMenu SET intParentMenuID = @CommonInfoTaxSetupParentMenuId WHERE intParentMenuID IN (@CommonInfoParentMenuId, @CommonInfoActivitiesParentMenuId, @CommonInfoMaintenanceParentMenuId) AND strCategory = 'Tax Setup'

/* START OF PLURALIZING */
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Country' AND strModuleName = N'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Countries', strDescription = 'Countries' WHERE strMenuName = N'Country' AND strModuleName = N'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Zip Code' AND strModuleName = N'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Zip Codes', strDescription = 'Zip Codes' WHERE strMenuName = N'Zip Code' AND strModuleName = N'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'' AND strModuleName = N'System Manager' AND intParentMenuID = @CommonInfoActivitiesParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Currencies', strDescription = 'Currencies' WHERE strMenuName = N'Currency' AND strModuleName = N'System Manager' AND intParentMenuID = @CommonInfoActivitiesParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Company Location' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoActivitiesParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Company Locations', strDescription = 'Company Locations' WHERE strMenuName = 'Company Location' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoActivitiesParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Tax Group Master' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Tax Group Masters', strDescription = 'Tax Group Masters' WHERE strMenuName = 'Tax Group Master' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Tax Group' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Tax Groups', strDescription = 'Tax Groups' WHERE strMenuName = 'Tax Group' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Tax Code' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Tax Codes', strDescription = 'Tax Codes' WHERE strMenuName = 'Tax Code' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'City' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Cities', strDescription = 'Cities' WHERE strMenuName = 'City' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Currency Exchange Rate' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Currency Exchange Rates', strDescription = 'Currency Exchange Rates' WHERE strMenuName = 'Currency Exchange Rate' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Currency Exchange Rate Type' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Currency Exchange Rate Types', strDescription = 'Currency Exchange Rate Types' WHERE strMenuName = 'Currency Exchange Rate Type' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId
/* END OF PLURALIZING */

/* START OF RENAMING  */
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Document Maintenance' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = N'Document Messages', strDescription = N'Document Messages' WHERE strMenuName = 'Document Maintenance' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Email Result' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = N'Email Log', strDescription = N'Email Log' WHERE strMenuName = 'Email Result' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Document Messages' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = N'Report Messages', strDescription = N'Report Messages' WHERE strMenuName = 'Document Messages' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId
/* END OF RENAMING  */

/* Start Move */
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Motor Fuel Tax Cycle' AND strModuleName = N'System Manager' AND intParentMenuID = @SystemManagerParentMenuId)
UPDATE tblSMMasterMenu SET intParentMenuID = @CommonInfoMaintenanceParentMenuId, intSort = 0 WHERE strMenuName = N'Motor Fuel Tax Cycle' AND strModuleName = N'System Manager' AND intParentMenuID = @SystemManagerParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Market Zone' AND strModuleName = N'Accounts Receivable' AND intParentMenuID = 131)
UPDATE tblSMMasterMenu SET intParentMenuID = @CommonInfoMaintenanceParentMenuId, intSort = 6 WHERE strMenuName = N'Market Zone' AND strModuleName = N'Accounts Receivable' AND intParentMenuID = 131

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Sales Reps' AND strModuleName = N'Accounts Receivable' AND intParentMenuID = 131)
UPDATE tblSMMasterMenu SET intParentMenuID = @CommonInfoMaintenanceParentMenuId, intSort = 11 WHERE strMenuName = N'Sales Reps' AND strModuleName = N'Accounts Receivable' AND intParentMenuID = 131

IF EXISTS(SELECT TOP 1 intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = 131)
BEGIN
	IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Market Zone' AND strModuleName = N'Accounts Receivable' AND intParentMenuID = (SELECT TOP 1 intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = 131))
	UPDATE tblSMMasterMenu SET intParentMenuID = @CommonInfoMaintenanceParentMenuId, intSort = 6 WHERE strMenuName = N'Market Zone' AND strModuleName = N'Accounts Receivable' AND intParentMenuID = (SELECT TOP 1 intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = 131)

	IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Sales Reps' AND strModuleName = N'Accounts Receivable' AND intParentMenuID = (SELECT TOP 1 intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = 131))
	UPDATE tblSMMasterMenu SET intParentMenuID = @CommonInfoMaintenanceParentMenuId, intSort = 11 WHERE strMenuName = N'Sales Reps' AND strModuleName = N'Accounts Receivable' AND intParentMenuID = (SELECT TOP 1 intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = 131)
END
/* End Move */

/* Start Remodule */
UPDATE tblSMMasterMenu SET strModuleName = 'System Manager' WHERE strMenuName = N'Market Zone' AND strModuleName = N'Accounts Receivable' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId
UPDATE tblSMMasterMenu SET strModuleName = 'System Manager' WHERE strMenuName = N'Sales Reps' AND strModuleName = N'Accounts Receivable' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId
/* End Remodule */

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Company Locations' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId])
	VALUES (N'Company Locations', N'System Manager', @CommonInfoActivitiesParentMenuId, N'Company Locations', N'Activity', N'Screen', N'i21.view.CompanyLocation?showSearch=true', N'small-menu-activity', 0, 0, 0, 1, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'i21.view.CompanyLocation?showSearch=true', intSort = 0 WHERE strMenuName = 'Company Locations' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Recurring Transactions' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Recurring Transactions', N'System Manager', @CommonInfoActivitiesParentMenuId, N'Recurring Transactions', N'Activity', N'Screen', N'i21.view.RecurringTransaction', N'small-menu-activity', 0, 0, 0, 1, 1, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'i21.view.RecurringTransaction', intSort = 1 WHERE strMenuName = 'Recurring Transactions' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Batch Posting' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Batch Posting', N'System Manager', @CommonInfoActivitiesParentMenuId, N'Batch Posting', N'Activity', N'Screen', N'i21.view.BatchPosting', N'small-menu-activity', 0, 0, 0, 1, 2, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'i21.view.BatchPosting', intSort = 2 WHERE strMenuName = 'Batch Posting' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Calendar' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Calendar', N'System Manager', @CommonInfoActivitiesParentMenuId, N'Calendar', N'Activity', N'Screen', N'GlobalComponentEngine.view.Calendar', N'small-menu-activity', 0, 0, 0, 1, 3, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'GlobalComponentEngine.view.Calendar', intSort = 3 WHERE strMenuName = 'Calendar' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoActivitiesParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Currencies' AND strModuleName = N'System Manager' AND intParentMenuID = @CommonInfoActivitiesParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'i21.view.Currency', intSort = 4 WHERE strMenuName = N'Currencies' AND strModuleName = N'System Manager' AND intParentMenuID = @CommonInfoActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Currency Exchange Rates' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Currency Exchange Rates', N'System Manager', @CommonInfoActivitiesParentMenuId, N'Currency Exchange Rates', N'Activity', N'Screen', N'i21.view.CurrencyExchangeRate', N'small-menu-activity', 0, 0, 0, 1, 5, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'i21.view.CurrencyExchangeRate', intSort = 5 WHERE strMenuName = 'Currency Exchange Rates' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Currency Exchange Rate Types' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Currency Exchange Rate Types', N'System Manager', @CommonInfoActivitiesParentMenuId, N'Currency Exchange Rate Types', N'Activity', N'Screen', N'i21.view.CurrencyExchangeRateType', N'small-menu-activity', 0, 0, 0, 1, 6, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'i21.view.CurrencyExchangeRateType', intSort = 6 WHERE strMenuName = 'Currency Exchange Rate Types' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Audit Log' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Audit Log', N'System Manager', @CommonInfoMaintenanceParentMenuId, N'Audit Log', N'Maintenance', N'Screen', N'GlobalComponentEngine.view.AuditLogHistory', N'small-menu-maintenance', 0, 0, 0, 1, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'GlobalComponentEngine.view.AuditLogHistory', intSort = 0 WHERE strMenuName = 'Audit Log' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Cities' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Cities', N'System Manager', @CommonInfoMaintenanceParentMenuId, N'Cities', N'Maintenance', N'Screen', N'i21.view.City?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 1, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'i21.view.City?showSearch=true', intSort = 1 WHERE strMenuName = 'Cities' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Countries' AND strModuleName = N'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'i21.view.Country?showSearch=true', intSort = 2 WHERE strMenuName = N'Countries' AND strModuleName = N'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Email Log' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Email Log', N'System Manager', @CommonInfoMaintenanceParentMenuId, N'Email Log', N'Maintenance', N'Screen', N'GlobalComponentEngine.view.ActivityEmailResult?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 3, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'GlobalComponentEngine.view.ActivityEmailResult?showSearch=true', intSort = 3 WHERE strMenuName = 'Email Log' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Entity Group' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Entity Group', N'System Manager', @CommonInfoMaintenanceParentMenuId, N'Entity Group', N'Maintenance', N'Screen', N'EntityManagement.view.EntityGroup?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 4, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = N'EntityManagement.view.EntityGroup?showSearch=true', intSort = 4 WHERE strMenuName = 'Entity Group' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Freight Terms' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Freight Terms', N'System Manager', @CommonInfoMaintenanceParentMenuId, N'Freight Terms', N'Maintenance', N'Screen', N'i21.view.FreightTerm?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 5, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'i21.view.FreightTerm?showSearch=true', intSort = 5 WHERE strMenuName = 'Freight Terms' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Export Log' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId)
    INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
    VALUES (N'Export Log', N'System Manager', @CommonInfoMaintenanceParentMenuId, N'Export Log', N'Maintenance', N'Screen', N'GlobalComponentEngine.view.ExportLog', N'small-menu-maintenance', 0, 0, 0, 1, 6, 1)
ELSE
    UPDATE tblSMMasterMenu SET strCommand = N'GlobalComponentEngine.view.ExportLog', intSort = 6 WHERE strMenuName = 'Export Log' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Lines of Business' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Lines of Business', N'System Manager', @CommonInfoMaintenanceParentMenuId, N'Lines of Business', N'Maintenance', N'Screen', N'i21.view.LineOfBusiness', N'small-menu-maintenance', 0, 0, 0, 1, 7, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = N'i21.view.LineOfBusiness', intSort = 7 WHERE strMenuName = 'Lines of Business' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Market Zone' AND strModuleName = N'Accounts Receivable' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = 'AccountsReceivable.view.MarketZone', intSort = 8 WHERE strMenuName = N'Market Zone' AND strModuleName = N'Accounts Receivable' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Motor Fuel Tax Cycle' AND strModuleName = N'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = 'Reports.controller.RunTaxCycle', intSort = 9 WHERE strMenuName = N'Motor Fuel Tax Cycle' AND strModuleName = N'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Payment Methods' AND strModuleName = N'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'i21.view.PaymentMethod', intSort = 10 WHERE strMenuName = N'Payment Methods' AND strModuleName = N'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Purchasing Groups' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Purchasing Groups', N'System Manager', @CommonInfoMaintenanceParentMenuId, N'Purchasing Groups', N'Maintenance', N'Screen', N'i21.view.PurchasingGroup', N'small-menu-maintenance', 0, 0, 0, 1, 11, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = N'i21.view.PurchasingGroup', intSort = 11 WHERE strMenuName = 'Purchasing Groups' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Report Messages' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Report Messages', N'System Manager', @CommonInfoMaintenanceParentMenuId, N'Report Messages', N'Maintenance', N'Screen', N'i21.view.DocumentMaintenance?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 12, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = N'i21.view.DocumentMaintenance?showSearch=true', intSort = 12 WHERE strMenuName = 'Report Messages' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Sales Reps' AND strModuleName = N'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = 'AccountsReceivable.view.EntitySalesperson?showSearch=true', intSort = 13 WHERE strMenuName = N'Sales Reps' AND strModuleName = N'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Ship Via' AND strModuleName = N'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'i21.view.EntityShipVia?showSearch=true', intSort = 14 WHERE strMenuName = N'Ship Via' AND strModuleName = N'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Terms' AND strModuleName = N'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'i21.view.Term?showSearch=true', intSort = 15 WHERE strMenuName = N'Terms' AND strModuleName = N'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Trucks' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Trucks', N'System Manager', @CommonInfoMaintenanceParentMenuId, N'Trucks', N'Maintenance', N'Screen', N'i21.view.Truck?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 16, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = N'i21.view.Truck?showSearch=true', intSort = 16 WHERE strMenuName = 'Trucks' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Veterinary' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Veterinary', N'System Manager', @CommonInfoMaintenanceParentMenuId, N'Veterinary', N'Maintenance', N'Screen', N'EntityManagement.view.EntityVeterinary?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 17, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = N'EntityManagement.view.EntityVeterinary?showSearch=true', intSort = 17 WHERE strMenuName = 'Veterinary' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Approvals' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoApprovalsParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Approvals', N'System Manager', @CommonInfoApprovalsParentMenuId, N'Approvals', N'Approval', N'Screen', N'i21.view.Approval', N'small-menu-activity', 0, 0, 0, 1, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = N'i21.view.Approval', intSort = 0 WHERE strMenuName = 'Approvals' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoApprovalsParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Approver Configuration' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoApprovalsParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Approver Configuration', N'System Manager', @CommonInfoApprovalsParentMenuId, N'Approver Configuration', N'Approval', N'Screen', N'i21.view.ApproverConfiguration?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 1, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'i21.view.ApproverConfiguration?showSearch=true', intSort = 1 WHERE strMenuName = 'Approver Configuration' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoApprovalsParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Approver Groups' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoApprovalsParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Approver Groups', N'System Manager', @CommonInfoApprovalsParentMenuId, N'Approver Groups', N'Approval', N'Screen', N'i21.view.ApproverGroup?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 2, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = N'i21.view.ApproverGroup?showSearch=true', intSort = 2 WHERE strMenuName = 'Approver Groups' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoApprovalsParentMenuId
	
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Approval List' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoApprovalsParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Approval List', N'System Manager', @CommonInfoApprovalsParentMenuId, N'Approval List', N'Approval', N'Screen', N'i21.view.ApprovalList?showSearch=true', N'small-menu-activity', 0, 0, 0, 1, 3, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'i21.view.ApprovalList?showSearch=true', intSort = 3 WHERE strMenuName = 'Approval List' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoApprovalsParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Tax Class' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoTaxSetupParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Tax Class', N'System Manager', @CommonInfoTaxSetupParentMenuId, N'Tax Class', N'Tax Setup', N'Screen', N'i21.view.TaxClass', N'small-menu-maintenance', 0, 0, 0, 1, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'i21.view.TaxClass', intSort = 0 WHERE strMenuName = 'Tax Class' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoTaxSetupParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Tax Codes' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoTaxSetupParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Tax Codes', N'System Manager', @CommonInfoTaxSetupParentMenuId, N'Tax Codes', N'Tax Setup', N'Screen', N'i21.view.TaxCode?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 1, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'i21.view.TaxCode?showSearch=true', intSort = 1 WHERE strMenuName = 'Tax Codes' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoTaxSetupParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Tax Groups' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoTaxSetupParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Tax Groups', N'System Manager', @CommonInfoTaxSetupParentMenuId, N'Tax Groups', N'Tax Setup', N'Screen', N'i21.view.TaxGroup?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 2, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'i21.view.TaxGroup?showSearch=true', intSort = 2 WHERE strMenuName = 'Tax Groups' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoTaxSetupParentMenuId

/* Start Delete */
--DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Freight Terms' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Reminder List' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Tax Group Masters' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'User Preferences' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Zip Codes' AND strModuleName = N'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Tax Type' AND strModuleName = N'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId 
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Email Log' AND strModuleName = N'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId 
/* END OF DELETING */

/* GENERAL LEDGER */
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'General Ledger' AND strModuleName = 'General Ledger' AND intParentMenuID = 0)
UPDATE tblSMMasterMenu SET intSort = 4 WHERE strMenuName = 'General Ledger' AND strModuleName = 'General Ledger' AND intParentMenuID = 0

DECLARE @GeneralLedgerParentMenuId INT
SELECT @GeneralLedgerParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'General Ledger' AND strModuleName = 'General Ledger' AND intParentMenuID = 0

/* PRE-UPDATE 1730 to 1800 */
UPDATE tblSMMasterMenu SET strCategory = N'Activity', strIcon = N'small-menu-activity' WHERE strMenuName IN ('General Journals', 'GL Account Detail', 'Batch Posting', 'Revalue Currency', 'Consolidate', 'Origin Audit Log') AND strModuleName = 'General Ledger'
UPDATE tblSMMasterMenu SET strCategory = N'Maintenance', strIcon = N'small-menu-maintenance' WHERE strMenuName IN ('Audit Adjustment', 'Clone Account', 'Clone Accounts', 'Fiscal Years', 'Fiscal Year', 'Reallocations', 'Recurring Journals') AND strModuleName = 'General Ledger'
UPDATE tblSMMasterMenu SET strCategory = N'Import', strIcon = N'small-menu-import' WHERE strMenuName IN ('Import GL from Subledger', 'Import GL from CSV', 'GL Import Logs') AND strModuleName = 'General Ledger'
UPDATE tblSMMasterMenu SET strCategory = N'Setup', strIcon = N'small-menu-setup' WHERE strMenuName IN ('Chart of Accounts', 'Account Structure', 'Account Groups', 'Segment Accounts', 'Build Accounts') AND strModuleName = 'General Ledger'

/* CATEGORY FOLDERS */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Activities' AND strModuleName = 'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intRow], [intConcurrencyId]) 
	VALUES (N'Activities', N'General Ledger', @GeneralLedgerParentMenuId, N'Activities', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 0, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 0, intRow = 0 WHERE strMenuName = 'Activities' AND strModuleName = 'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId

DECLARE @GeneralLedgerActivitiesParentMenuId INT
SELECT @GeneralLedgerActivitiesParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Activities' AND strModuleName = 'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intRow], [intConcurrencyId]) 
	VALUES (N'Maintenance', N'General Ledger', @GeneralLedgerParentMenuId, N'Maintenance', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 1, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 1, intRow = 0 WHERE strMenuName = 'Maintenance' AND strModuleName = 'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId

DECLARE @GeneralLedgerMaintenanceParentMenuId INT
SELECT @GeneralLedgerMaintenanceParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Import' AND strModuleName = 'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intRow], [intConcurrencyId]) 
	VALUES (N'Import', N'General Ledger', @GeneralLedgerParentMenuId, N'Import', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 2, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 2, intRow = 0 WHERE strMenuName = 'Import' AND strModuleName = 'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId

DECLARE @GeneralLedgerImportParentMenuId INT
SELECT @GeneralLedgerImportParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Import' AND strModuleName = 'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Reports' AND strModuleName = 'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intRow], [intConcurrencyId]) 
	VALUES (N'Reports', N'General Ledger', @GeneralLedgerParentMenuId, N'Reports', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 3, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 3, intRow = 0 WHERE strMenuName = 'Reports' AND strModuleName = 'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId

DECLARE @GeneralLedgerReportParentMenuId INT
SELECT @GeneralLedgerReportParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Reports' AND strModuleName = 'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Create' AND strModuleName = 'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intRow], [intConcurrencyId]) 
	VALUES (N'Create', N'General Ledger', @GeneralLedgerParentMenuId, N'Create', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 0, 1, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 0, intRow = 1 WHERE strMenuName = 'Create' AND strModuleName = 'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId

DECLARE @GeneralLedgerCreateParentMenuId INT
SELECT @GeneralLedgerCreateParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Create' AND strModuleName = 'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Setup' AND strModuleName = 'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intRow], [intConcurrencyId]) 
	VALUES (N'Setup', N'General Ledger', @GeneralLedgerParentMenuId, N'Setup', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 1, 1, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 1, intRow = 1 WHERE strMenuName = 'Setup' AND strModuleName = 'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId

DECLARE @GeneralLedgerSetupParentMenuId INT
SELECT @GeneralLedgerSetupParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Setup' AND strModuleName = 'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId

/* ADD TO RESPECTIVE CATEGORY */ 
UPDATE tblSMMasterMenu SET intParentMenuID = @GeneralLedgerActivitiesParentMenuId WHERE intParentMenuID =  @GeneralLedgerParentMenuId AND strCategory = 'Activity'
UPDATE tblSMMasterMenu SET intParentMenuID = @GeneralLedgerMaintenanceParentMenuId WHERE intParentMenuID =  @GeneralLedgerParentMenuId AND strCategory = 'Maintenance'
UPDATE tblSMMasterMenu SET intParentMenuID = @GeneralLedgerImportParentMenuId WHERE intParentMenuID =  @GeneralLedgerParentMenuId AND strCategory = 'Import'
UPDATE tblSMMasterMenu SET intParentMenuID = @GeneralLedgerSetupParentMenuId WHERE intParentMenuID =  @GeneralLedgerParentMenuId AND strCategory = 'Setup'

/* START OF PLURALIZING */
--IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'General Journal' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerActivitiesParentMenuId)
--UPDATE tblSMMasterMenu SET strMenuName = 'General Journals', strDescription = 'General Journals' WHERE strMenuName = N'General Journal' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerActivitiesParentMenuId
UPDATE tblSMMasterMenu SET strMenuName = 'Import Budgets from CSV', strDescription = 'Import Budgets from CSV' WHERE strMenuName = N'Import Budget from CSV' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerActivitiesParentMenuId
--IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Reallocation' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerMaintenanceParentMenuId and strCategory = 'Maintenance')
--UPDATE tblSMMasterMenu SET strMenuName = 'Reallocations', strDescription = 'Reallocations' WHERE strMenuName = N'Reallocation' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerMaintenanceParentMenuId and strCategory = 'Maintenance'
--IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Recurring Journal' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerMaintenanceParentMenuId)
--UPDATE tblSMMasterMenu SET strMenuName = 'Recurring Journals', strDescription = 'Recurring Journals' WHERE strMenuName = N'Recurring Journal' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerMaintenanceParentMenuId
/* END OF PLURALIZING */
/* Start of moving report */
--UPDATE tblSMMasterMenu SET intParentMenuID = @GeneralLedgerReportParentMenuId WHERE strMenuName = 'Reallocation' AND strModuleName = 'General Ledger' AND strType = 'Report' AND intParentMenuID = @GeneralLedgerParentMenuId
--UPDATE tblSMMasterMenu SET intParentMenuID = @GeneralLedgerReportParentMenuId WHERE strMenuName = 'General Ledger By Account ID Detail' AND strModuleName = 'General Ledger' AND strType IN ('Report', 'Screen') AND intParentMenuID = @GeneralLedgerParentMenuId
--UPDATE tblSMMasterMenu SET intParentMenuID = @GeneralLedgerReportParentMenuId WHERE strMenuName = 'Trial Balance Detail' AND strModuleName = 'General Ledger' AND strType IN ('Report', 'Screen') AND intParentMenuID = @GeneralLedgerParentMenuId
/* End of moving report */

/* Start of Rename */
UPDATE tblSMMasterMenu SET strMenuName = N'Consolidate GL Entries', strDescription = N'Consolidate GL Entries' WHERE strMenuName = N'Consolidate' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerActivitiesParentMenuId
UPDATE tblSMMasterMenu SET strMenuName = N'Fiscal Year', strDescription = N'Fiscal Year' WHERE strMenuName = N'Fiscal Years' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerMaintenanceParentMenuId
UPDATE tblSMMasterMenu SET strMenuName = N'Clone Account', strDescription = N'Clone Account' WHERE strMenuName = N'Clone Accounts' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerMaintenanceParentMenuId
/* End of Rename */

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'General Journals' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerActivitiesParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 0, strCommand = N'GeneralLedger.view.GeneralJournal?showSearch=true' WHERE strMenuName = N'General Journals' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerActivitiesParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'GL Account Detail' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerActivitiesParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 1, strCommand = N'GeneralLedger.view.GLAccountDetail?showSearch=true' WHERE strMenuName = N'GL Account Detail' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerActivitiesParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Batch Posting' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerActivitiesParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 2, strCommand = N'i21.view.BatchPosting?module=General Ledger' WHERE strMenuName = N'Batch Posting' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Revalue Currency' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Revalue Currency', N'General Ledger', @GeneralLedgerActivitiesParentMenuId, N'Revalue Currency', N'Activity', N'Screen', N'GeneralLedger.view.RevalueCurrency', N'small-menu-activity', 0, 0, 0, 1, 3, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 3, strCommand = N'GeneralLedger.view.RevalueCurrency?showSearch=true' WHERE strMenuName = N'Revalue Currency' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Consolidate GL Entries' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Consolidate GL Entries', N'General Ledger', @GeneralLedgerActivitiesParentMenuId, N'Consolidate GL Entries', N'Activity', N'Screen', N'GeneralLedger.view.Consolidate', N'small-menu-activity', 0, 0, 0, 1, 4, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 4, strCommand = N'GeneralLedger.view.Consolidate' WHERE strMenuName = N'Consolidate GL Entries' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Origin Audit Log' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Origin Audit Log', N'General Ledger', @GeneralLedgerActivitiesParentMenuId, N'Origin Audit Log', N'Activity', N'Screen', N'GeneralLedger.view.OriginAuditLog?showSearch=true', N'small-menu-activity', 0, 0, 0, 1, 5, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 5, strCommand = N'GeneralLedger.view.OriginAuditLog?showSearch=true' WHERE strMenuName = N'Origin Audit Log' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Account Mapping' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Account Mapping', N'General Ledger', @GeneralLedgerMaintenanceParentMenuId, N'Account Mapping', N'Maintenance', N'Screen', N'GeneralLedger.view.AccountMapping?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 0, strCommand = N'GeneralLedger.view.AccountMapping?showSearch=true' WHERE strMenuName = N'Account Mapping' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Audit Adjustment' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Audit Adjustment', N'General Ledger', @GeneralLedgerMaintenanceParentMenuId, N'Audit Adjustment', N'Maintenance', N'Screen', N'GeneralLedger.view.AuditAdjustment?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 1, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 1, strCommand = N'GeneralLedger.view.AuditAdjustment?showSearch=true' WHERE strMenuName = N'Audit Adjustment' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Clone Account' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Clone Account', N'General Ledger', @GeneralLedgerMaintenanceParentMenuId, N'Clone Account', N'Maintenance', N'Screen', N'GeneralLedger.view.AccountClone', N'small-menu-maintenance', 0, 0, 0, 1, 2, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 2, strCommand = N'GeneralLedger.view.AccountClone' WHERE strMenuName = N'Clone Account' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerMaintenanceParentMenuId
	
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Fiscal Year' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 3, strCommand = N'GeneralLedger.view.FiscalYear?showSearch=true' WHERE strMenuName = N'Fiscal Year' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Reallocations' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerMaintenanceParentMenuId and strCategory = 'Maintenance')
UPDATE tblSMMasterMenu SET intSort = 4, strCommand = N'GeneralLedger.view.Reallocation?showSearch=true' WHERE strMenuName = N'Reallocations' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerMaintenanceParentMenuId and strCategory = 'Maintenance'

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Recurring Journals' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Recurring Journals', N'General Ledger', @GeneralLedgerMaintenanceParentMenuId, N'Recurring Journals', N'Maintenance', N'Screen', N'i21.view.RecurringTransaction?type=General Journal', N'small-menu-maintenance', 0, 0, 0, 1, 5, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 5, strCommand = N'i21.view.RecurringTransaction?type=General Journal' WHERE strMenuName = N'Recurring Journals' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerMaintenanceParentMenuId

--IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Vendor Mapping' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerMaintenanceParentMenuId)
--	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
--	VALUES (N'Vendor Mapping', N'General Ledger', @GeneralLedgerMaintenanceParentMenuId, N'Vendor Mapping', N'Maintenance', N'Screen', N'GeneralLedger.view.VendorMapping?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 6, 1)
--ELSE 
--	UPDATE tblSMMasterMenu SET intSort = 6, strCommand = N'GeneralLedger.view.VendorMapping?showSearch=true' WHERE strMenuName = N'Vendor Mapping' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Import GL from Subledger' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerImportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Import GL from Subledger', N'General Ledger', @GeneralLedgerImportParentMenuId, N'Import GL from Subledger', N'Import', N'Screen', N'GeneralLedger.view.ImportFromSubledger', N'small-menu-import', 0, 0, 0, 1, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 0, strCommand = N'GeneralLedger.view.ImportFromSubledger' WHERE strMenuName = N'Import GL from Subledger' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerImportParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Import GL from CSV' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerImportParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 1, strCommand = N'GeneralLedger.view.ImportFromCSV' WHERE strMenuName = N'Import GL from CSV' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerImportParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'GL Import Logs' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerImportParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 2, strCommand = N'GeneralLedger.view.ImportLogs?showSearch=true' WHERE strMenuName = N'GL Import Logs' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerImportParentMenuId

--IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'General Ledger By Account ID Detail' AND strModuleName ='General Ledger' AND intParentMenuID = @GeneralLedgerReportParentMenuId)
--UPDATE tblSMMasterMenu SET intSort = 0, strCommand = N'Reporting.view.ReportManager?group=General Ledger&report=GeneralLedgerByAccountDetail&direct=true&showCriteria=true', strType = 'Screen' WHERE strMenuName = 'General Ledger By Account ID Detail' AND strModuleName ='General Ledger' AND intParentMenuID = @GeneralLedgerReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Out of Balance' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId])
	VALUES (N'Out of Balance', N'General Ledger', @GeneralLedgerReportParentMenuId, N'Out of Balance', N'Report', N'Screen', N'GeneralLedger.view.OutOfBalanceReport?showSearch=true', N'small-menu-report', 0, 0, 0, 1, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 0, strCommand = N'GeneralLedger.view.OutOfBalanceReport?showSearch=true' WHERE strMenuName = N'Out of Balance' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Trial Balance' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId])
	VALUES (N'Trial Balance', N'General Ledger', @GeneralLedgerReportParentMenuId, N'Trial Balance', N'Report', N'Screen', N'GeneralLedger.view.TrialBalanceReport?showSearch=true', N'small-menu-report', 0, 0, 0, 1, 1, 1)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 1, strCommand = N'GeneralLedger.view.TrialBalanceReport?showSearch=true' WHERE strMenuName = N'Trial Balance' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'New General Journal' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerCreateParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId])
	VALUES (N'New General Journal', N'General Ledger', @GeneralLedgerCreateParentMenuId, N'New General Journal', N'Create', N'Screen', N'GeneralLedger.view.GeneralJournal?action=new', N'small-menu-create', 0, 0, 0, 1, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 0, strCommand = N'GeneralLedger.view.GeneralJournal?action=new' WHERE strMenuName = N'New General Journal' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerCreateParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Chart of Accounts' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerSetupParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId])
	VALUES (N'Chart of Accounts', N'General Ledger', @GeneralLedgerSetupParentMenuId, N'Chart of Accounts', N'Setup', N'Screen', N'GeneralLedger.view.ChartOfAccounts', N'small-menu-setup', 0, 0, 0, 1, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 0, strCommand = N'GeneralLedger.view.ChartOfAccounts' WHERE strMenuName = N'Chart of Accounts' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerSetupParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Account Structure' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerSetupParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Account Structure', N'General Ledger', @GeneralLedgerSetupParentMenuId, N'Account Structure', N'Setup', N'Screen', N'GeneralLedger.view.AccountStructure', N'small-menu-setup', 0, 0, 0, 1, 1, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 1, strCommand = N'GeneralLedger.view.AccountStructure' WHERE strMenuName = N'Account Structure' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerSetupParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Account Groups' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerSetupParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Account Groups', N'General Ledger', @GeneralLedgerSetupParentMenuId, N'Account Groups', N'Setup', N'Screen', N'GeneralLedger.view.AccountGroups', N'small-menu-setup', 0, 0, 0, 1, 2, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 2, strCommand = N'GeneralLedger.view.AccountGroups' WHERE strMenuName = N'Account Groups' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerSetupParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Segment Accounts' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerSetupParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Segment Accounts', N'General Ledger', @GeneralLedgerSetupParentMenuId, N'Segment Accounts', N'Setup', N'Screen', N'GeneralLedger.view.SegmentAccounts', N'small-menu-maintenance', 0, 0, 0, 1, 3, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 3, strCommand = N'GeneralLedger.view.SegmentAccounts' WHERE strMenuName = N'Segment Accounts' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerSetupParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Build Accounts' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerSetupParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Build Accounts', N'General Ledger', @GeneralLedgerSetupParentMenuId, N'Build Accounts', N'Setup', N'Screen', N'GeneralLedger.view.BuildAccounts', N'small-menu-maintenance', 0, 0, 0, 1, 4, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 4, strCommand = N'GeneralLedger.view.BuildAccounts' WHERE strMenuName = N'Build Accounts' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerSetupParentMenuId

/* START OF DELETING */
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Account Structure' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Account Groups' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Segment Accounts' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Build Accounts' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Import Budgets from CSV' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerActivitiesParentMenuId
--DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Recurring Journals' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Recurring Journal History' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Balance Sheet Standard' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Income Statement Standard' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Trial Balance' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Reminder List' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerActivitiesParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Chart of Accounts' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId AND strCategory = 'Report'
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Chart of Accounts' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerSetupParentMenuId AND strType = 'Report'
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Chart of Accounts' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerMaintenanceParentMenuId AND strCategory = 'Maintenance'
--DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Clone Account' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Chart of Accounts Adjustment' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId AND strCategory = 'Report'
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Reallocation' AND strModuleName = N'General Ledger' AND strCategory = 'Report'
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Trial Balance Detail New' AND strModuleName = 'General Ledger'
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'General Ledger By Account ID Detail New' AND strModuleName = 'General Ledger'
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Account Adjustment' AND strModuleName ='General Ledger' AND intParentMenuID = @GeneralLedgerActivitiesParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Trial Balance Detail' AND strModuleName ='General Ledger' AND strCategory = 'Report'
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'General Ledger By Account ID Detail' AND strModuleName ='General Ledger' AND strCategory = 'Report'
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Vendor Mapping' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerMaintenanceParentMenuId
/* END OF DELETING */

/* FINANCIAL REPORT DESIGNER */
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Financial Reports' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId)
UPDATE tblSMMasterMenu SET intParentMenuID = 0, strModuleName = N'Financial Report Designer', strCommand = N'FinancialReportDesigner' WHERE strMenuName = N'Financial Reports' AND intParentMenuID = @GeneralLedgerParentMenuId

/* ADD TO RESPECTIVE CATEGORY */ 
UPDATE tblSMMasterMenu SET intParentMenuID = @GeneralLedgerActivitiesParentMenuId WHERE intParentMenuID =  @GeneralLedgerParentMenuId AND strCategory = 'Activity'
UPDATE tblSMMasterMenu SET intParentMenuID = @GeneralLedgerMaintenanceParentMenuId WHERE intParentMenuID =  @GeneralLedgerParentMenuId AND strCategory = 'Maintenance'

/* Remodule Financial Reports -> Financial Report Designer */
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Financial Reports' AND strModuleName = N'Financial Reports' AND intParentMenuID = 0)
UPDATE tblSMMasterMenu SET strModuleName = N'Financial Report Designer', strCommand = N'FinancialReportDesigner' WHERE strMenuName = N'Financial Reports' AND strModuleName = N'Financial Reports' AND intParentMenuID = 0
/* Remodule Financial Reports -> Financial Report Designer */

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Financial Reports' AND strModuleName = 'Financial Report Designer' AND intParentMenuID = 0)
UPDATE tblSMMasterMenu SET intSort = 5 WHERE strMenuName = 'Financial Reports' AND strModuleName = 'Financial Report Designer' AND intParentMenuID = 0

DECLARE @FinancialReportsParentMenuId INT
SELECT @FinancialReportsParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Financial Reports' AND strModuleName = 'Financial Report Designer' AND intParentMenuID = 0

/* Remodule submenus Financial Reports -> Financial Report Designer */
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strModuleName = N'Financial Reports' AND intParentMenuID = @FinancialReportsParentMenuId)
UPDATE tblSMMasterMenu SET strModuleName = 'Financial Report Designer' WHERE strModuleName = N'Financial Reports' AND intParentMenuID = @FinancialReportsParentMenuId
/* Remodule submenus Financial Reports -> Financial Report Designer */

/* CATEGORY FOLDERS */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Activities' AND strModuleName = 'Financial Report Designer' AND intParentMenuID = @FinancialReportsParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Activities', N'Financial Report Designer', @FinancialReportsParentMenuId, N'Activities', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 0 WHERE strMenuName = 'Activities' AND strModuleName = 'Financial Report Designer' AND intParentMenuID = @FinancialReportsParentMenuId

DECLARE @FinancialReportsActivitiesParentMenuId INT
SELECT @FinancialReportsActivitiesParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Activities' AND strModuleName = 'Financial Report Designer' AND intParentMenuID = @FinancialReportsParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'Financial Report Designer' AND intParentMenuID = @FinancialReportsParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Maintenance', N'Financial Report Designer', @FinancialReportsParentMenuId, N'Maintenance', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 1, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 1 WHERE strMenuName = 'Maintenance' AND strModuleName = 'Financial Report Designer' AND intParentMenuID = @FinancialReportsParentMenuId

DECLARE @FinancialReportsMaintenanceParentMenuId INT
SELECT @FinancialReportsMaintenanceParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'Financial Report Designer' AND intParentMenuID = @FinancialReportsParentMenuId

/* ADD TO RESPECTIVE CATEGORY */ 
UPDATE tblSMMasterMenu SET intParentMenuID = @FinancialReportsActivitiesParentMenuId WHERE intParentMenuID =  @FinancialReportsParentMenuId AND strCategory = 'Activity'
UPDATE tblSMMasterMenu SET intParentMenuID = @FinancialReportsMaintenanceParentMenuId WHERE intParentMenuID =  @FinancialReportsParentMenuId AND strCategory = 'Maintenance'

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Financial Report Viewer' AND strModuleName = N'Financial Report Designer' AND intParentMenuID = @FinancialReportsActivitiesParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'FinancialReportDesigner.view.FinancialReports' WHERE strMenuName = N'Financial Report Viewer' AND strModuleName = N'Financial Report Designer' AND intParentMenuID = @FinancialReportsActivitiesParentMenuId

/* START OF RENAMING  */
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Budget Maintenance' AND strModuleName = 'Financial Report Designer' AND intParentMenuID = @FinancialReportsMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Budget', strDescription = 'Budget' WHERE strMenuName = 'Budget Maintenance' AND strModuleName = 'Financial Report Designer' AND intParentMenuID = @FinancialReportsMaintenanceParentMenuId
/* END OF RENAMING  */

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Budget' AND strModuleName = 'Financial Report Designer' AND intParentMenuID = @FinancialReportsMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Budget', N'Financial Report Designer', @FinancialReportsMaintenanceParentMenuId, N'Budget', N'Maintenance', N'Screen', N'FinancialReportDesigner.view.Budget?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 0, strCommand = N'FinancialReportDesigner.view.Budget?showSearch=true' WHERE strMenuName = 'Budget' AND strModuleName = 'Financial Report Designer' AND intParentMenuID = @FinancialReportsMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Financial Report Builder' AND strModuleName = N'Financial Report Designer' AND intParentMenuID = @FinancialReportsMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 1, strCommand = N'FinancialReportDesigner.view.ReportBuilder?showSearch=true' WHERE strMenuName = N'Financial Report Builder' AND strModuleName = N'Financial Report Designer' AND intParentMenuID = @FinancialReportsMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Financial Report Group' AND strModuleName = 'Financial Report Designer' AND intParentMenuID = @FinancialReportsMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Financial Report Group', N'Financial Report Designer', @FinancialReportsMaintenanceParentMenuId, N'Financial Report Group', N'Maintenance', N'Screen', N'FinancialReportDesigner.view.FinancialReportGroup?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 2, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 2, strCommand = N'FinancialReportDesigner.view.FinancialReportGroup?showSearch=true' WHERE strMenuName = 'Financial Report Group' AND strModuleName = 'Financial Report Designer' AND intParentMenuID = @FinancialReportsMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Report Templates' AND strModuleName = N'Financial Report Designer' AND intParentMenuID = @FinancialReportsMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 3, strCommand = N'FinancialReportDesigner.view.Templates' WHERE strMenuName = N'Report Templates' AND strModuleName = N'Financial Report Designer' AND intParentMenuID = @FinancialReportsMaintenanceParentMenuId

/* START OF DELETING */
DELETE FROM tblSMMasterMenu WHERE strMenuName IN ('Financial Report Group', 'Budget Maintenance') AND strModuleName = 'Financial Report Designer' AND intParentMenuID IS NULL
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Row Designer' AND strModuleName = N'Financial Report Designer' AND intParentMenuID = @FinancialReportsMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Column Designer' AND strModuleName = N'Financial Report Designer' AND intParentMenuID = @FinancialReportsMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Report Header and Footer' AND strModuleName = N'Financial Report Designer' AND intParentMenuID = @FinancialReportsMaintenanceParentMenuId
/* END OF DELETING */

/* CASH MANAGEMENT */
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Cash Management' AND strModuleName = 'Cash Management' AND intParentMenuID = 0)
UPDATE tblSMMasterMenu SET intSort = 6 WHERE strMenuName = 'Cash Management' AND strModuleName = 'Cash Management' AND intParentMenuID = 0

DECLARE @CashManagementParentMenuId INT
SELECT @CashManagementParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Cash Management' AND strModuleName = 'Cash Management' AND intParentMenuID = 0

/* CATEGORY FOLDERS */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Activities' AND strModuleName = 'Cash Management' AND intParentMenuID = @CashManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Activities', N'Cash Management', @CashManagementParentMenuId, N'Activities', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 0 WHERE strMenuName = 'Activities' AND strModuleName = 'Cash Management' AND intParentMenuID = @CashManagementParentMenuId

DECLARE @CashManagementActivitiesParentMenuId INT
SELECT @CashManagementActivitiesParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Activities' AND strModuleName = 'Cash Management' AND intParentMenuID = @CashManagementParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'Cash Management' AND intParentMenuID = @CashManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Maintenance', N'Cash Management', @CashManagementParentMenuId, N'Maintenance', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 1, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 1 WHERE strMenuName = 'Maintenance' AND strModuleName = 'Cash Management' AND intParentMenuID = @CashManagementParentMenuId

DECLARE @CashManagementMaintenanceParentMenuId INT
SELECT @CashManagementMaintenanceParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'Cash Management' AND intParentMenuID = @CashManagementParentMenuId

/* ADD TO RESPECTIVE CATEGORY */ 
UPDATE tblSMMasterMenu SET intParentMenuID = @CashManagementActivitiesParentMenuId WHERE intParentMenuID =  @CashManagementParentMenuId AND strCategory = 'Activity'
UPDATE tblSMMasterMenu SET intParentMenuID = @CashManagementMaintenanceParentMenuId WHERE intParentMenuID =  @CashManagementParentMenuId AND strCategory = 'Maintenance'

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Bank Deposits' AND strModuleName = N'Cash Management' AND intParentMenuID = @CashManagementActivitiesParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 0, strCommand = N'CashManagement.view.BankDeposit?showSearch=true' WHERE strMenuName = N'Bank Deposits' AND strModuleName = N'Cash Management' AND intParentMenuID = @CashManagementActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Bank Deposit Batch Entry' AND strModuleName = 'Cash Management' AND intParentMenuID = @CashManagementActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Bank Deposit Batch Entry', N'Cash Management', @CashManagementActivitiesParentMenuId, N'Bank Deposit Batch Entry', N'Activity', N'Screen', N'CashManagement.view.BankTransactionsBatchEntry?showSearch=true', N'small-menu-activity', 0, 0, 0, 1, 1, 1)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 1, strCommand = N'CashManagement.view.BankTransactionsBatchEntry?showSearch=true' WHERE strMenuName = 'Bank Deposit Batch Entry' AND strModuleName = 'Cash Management' AND intParentMenuID = @CashManagementActivitiesParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Bank Transactions' AND strModuleName = N'Cash Management' AND intParentMenuID = @CashManagementActivitiesParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 2, strCommand = N'CashManagement.view.BankTransactions?showSearch=true' WHERE strMenuName = N'Bank Transactions' AND strModuleName = N'Cash Management' AND intParentMenuID = @CashManagementActivitiesParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Bank Transfers' AND strModuleName = N'Cash Management' AND intParentMenuID = @CashManagementActivitiesParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 3, strCommand = N'CashManagement.view.BankTransfer?showSearch=true' WHERE strMenuName = N'Bank Transfers' AND strModuleName = N'Cash Management' AND intParentMenuID = @CashManagementActivitiesParentMenuId

--IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Miscellaneous Checks' AND strModuleName = N'Cash Management' AND intParentMenuID = @CashManagementActivitiesParentMenuId)
--UPDATE tblSMMasterMenu SET intSort = 4, strCommand = N'CashManagement.view.MiscellaneousChecks?showSearch=true' WHERE strMenuName = N'Miscellaneous Checks' AND strModuleName = N'Cash Management' AND intParentMenuID = @CashManagementActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Batch Posting' AND strModuleName = 'Cash Management' AND intParentMenuID = @CashManagementActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Batch Posting', N'Cash Management', @CashManagementActivitiesParentMenuId, N'Batch Posting', N'Activity', N'Screen', N'i21.view.BatchPosting?module=Cash Management', N'small-menu-activity', 0, 0, 0, 1, 4, 1)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 4, strCommand = N'i21.view.BatchPosting?module=Cash Management' WHERE strMenuName = 'Batch Posting' AND strModuleName = 'Cash Management' AND intParentMenuID = @CashManagementActivitiesParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Bank Account Register' AND strModuleName = N'Cash Management' AND intParentMenuID = @CashManagementActivitiesParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 5, strCommand = N'CashManagement.view.BankAccountRegister' WHERE strMenuName = N'Bank Account Register' AND strModuleName = N'Cash Management' AND intParentMenuID = @CashManagementActivitiesParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Bank Reconciliation' AND strModuleName = N'Cash Management' AND intParentMenuID = @CashManagementActivitiesParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 6, strCommand = N'CashManagement.view.BankReconciliation' WHERE strMenuName = N'Bank Reconciliation' AND strModuleName = N'Cash Management' AND intParentMenuID = @CashManagementActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Bank Loan' AND strModuleName = 'Cash Management' AND intParentMenuID = @CashManagementActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Bank Loan', N'Cash Management', @CashManagementActivitiesParentMenuId, N'Bank Loan', N'Activity', N'Screen', N'CashManagement.view.BankLoan?showSearch=true', N'small-menu-activity', 0, 0, 0, 1, 7, 1)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 7, strCommand = N'CashManagement.view.BankLoan?showSearch=true' WHERE strMenuName = 'Bank Loan' AND strModuleName = 'Cash Management' AND intParentMenuID = @CashManagementActivitiesParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Banks' AND strModuleName = N'Cash Management' AND intParentMenuID = @CashManagementMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 0, strCommand = N'CashManagement.view.Banks?showSearch=true' WHERE strMenuName = N'Banks' AND strModuleName = N'Cash Management' AND intParentMenuID = @CashManagementMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Bank Accounts' AND strModuleName = N'Cash Management' AND intParentMenuID = @CashManagementMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 1, strCommand = N'CashManagement.view.BankAccounts?showSearch=true' WHERE strMenuName = N'Bank Accounts' AND strModuleName = N'Cash Management' AND intParentMenuID = @CashManagementMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Bank File Formats' AND strModuleName = N'Cash Management' AND intParentMenuID = @CashManagementMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 2, strCommand = N'CashManagement.view.BankFileFormat?showSearch=true' WHERE strMenuName = N'Bank File Formats' AND strModuleName = N'Cash Management' AND intParentMenuID = @CashManagementMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Reports' AND strModuleName = 'Cash Management' AND intParentMenuID = @CashManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intRow], [intConcurrencyId]) 
	VALUES (N'Reports', N'Cash Management', @CashManagementParentMenuId, N'Reports', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 3, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 0 WHERE strMenuName = 'Reports' AND strModuleName = 'Cash Management' AND intParentMenuID = @CashManagementParentMenuId

DECLARE @CashManagementReportParentMenuId INT
SELECT @CashManagementReportParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Reports' AND strModuleName = 'Cash Management' AND intParentMenuID = @CashManagementParentMenuId


IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Undeposited Fund' AND strModuleName = N'Cash Management' AND intParentMenuID = @CashManagementReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId])
	VALUES (N'Undeposited Fund', N'Cash Management', @CashManagementReportParentMenuId, N'Undeposited Fund', N'Report', N'Screen', N'Reporting.view.ReportManager?group=Cash Management&report=UndepositedFund&reportDesc=Undeposited Fund Report&direct=true&showCriteria=true', N'small-menu-report', 1, 0, 0, 1, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 0, strCommand = N'Reporting.view.ReportManager?group=Cash Management&report=UndepositedFund&reportDesc=Undeposited Fund Report&direct=true&showCriteria=true' WHERE strMenuName = N'Undeposited Fund' AND strModuleName = N'Cash Management' AND intParentMenuID = @CashManagementReportParentMenuId


/* START OF DELETING */
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Positive Pay Export' AND strModuleName = 'Cash Management' AND intParentMenuID = @CashManagementActivitiesParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Bank File Export' AND strModuleName = 'Cash Management' AND intParentMenuID = @CashManagementActivitiesParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Reports' AND strModuleName = 'Cash Management' AND intParentMenuID = @CashManagementActivitiesParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Check Register' AND strModuleName = 'Cash Management'
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Miscellaneous Checks' AND strModuleName = N'Cash Management' AND intParentMenuID = @CashManagementActivitiesParentMenuId
/* END OF DELETING */

/* CREDIT CARD RECONCILIATION */
/* Rename Credit Card Reconciliation to Credit Card Recon */
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Credit Card Reconciliation' AND strModuleName = 'Credit Card Recon' AND intParentMenuID = 0)
UPDATE tblSMMasterMenu SET strMenuName = 'Credit Card Recon', strDescription = 'Credit Card Recon' WHERE strMenuName = 'Credit Card Reconciliation' AND strModuleName = 'Credit Card Recon' AND intParentMenuID = 0

/* Rename Credit Card Recon to Dealer Credit Cards*/
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Credit Card Recon' AND strModuleName = 'Credit Card Recon' AND intParentMenuID = 0)
UPDATE tblSMMasterMenu SET strMenuName = 'Dealer Credit Cards', strDescription = 'Dealer Credit Cards' WHERE strMenuName = 'Credit Card Recon' AND strModuleName = 'Credit Card Recon' AND intParentMenuID = 0

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Dealer Credit Cards' AND strModuleName = 'Credit Card Recon' AND intParentMenuID = 0)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Dealer Credit Cards', N'Credit Card Recon', 0, N'Dealer Credit Cards', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 7, 0)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 7 WHERE strMenuName = 'Dealer Credit Cards' AND strModuleName = 'Credit Card Recon' AND intParentMenuID = 0

DECLARE @CreditCardReconParentMenuId INT
SELECT @CreditCardReconParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Credit Card Recon' AND strModuleName = 'Credit Card Recon' AND intParentMenuID = 0

/* CATEGORY FOLDERS */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Activities' AND strModuleName = 'Credit Card Recon' AND intParentMenuID = @CreditCardReconParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intRow], [intConcurrencyId]) 
	VALUES (N'Activities', N'Credit Card Recon', @CreditCardReconParentMenuId, N'Activities', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 0, 1, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 0, intRow = 0 WHERE strMenuName = 'Activities' AND strModuleName = 'Credit Card Recon' AND intParentMenuID = @CreditCardReconParentMenuId

DECLARE @CreditCardReconActivitiesParentMenuId INT
SELECT @CreditCardReconActivitiesParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Activities' AND strModuleName = 'Credit Card Recon' AND intParentMenuID = @CreditCardReconParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Create' AND strModuleName = 'Credit Card Recon' AND intParentMenuID = @CreditCardReconParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intRow], [intConcurrencyId]) 
	VALUES (N'Create', N'Credit Card Recon', @CreditCardReconParentMenuId, N'Create', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 0, 1, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 0, intRow = 1 WHERE strMenuName = 'Create' AND strModuleName = 'Credit Card Recon' AND intParentMenuID = @CreditCardReconParentMenuId

DECLARE @CreditCardReconCreateParentMenuId INT
SELECT @CreditCardReconCreateParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Create' AND strModuleName = 'Credit Card Recon' AND intParentMenuID = @CreditCardReconParentMenuId

/* ADD TO RESPECTIVE CATEGORY */ 
UPDATE tblSMMasterMenu SET intParentMenuID = @CreditCardReconActivitiesParentMenuId WHERE intParentMenuID =  @CreditCardReconParentMenuId AND strCategory = 'Activity'

/* Rename from Credit Card Recon Entry to Credit Card Recon */
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE (strMenuName = 'Credit Card Recon Entry' OR strMenuName = 'Credit Card Recons') AND strModuleName = 'Credit Card Recon' AND intParentMenuID = @CreditCardReconActivitiesParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Dealer Credit Cards', strDescription = 'Dealer Credit Cards' WHERE (strMenuName = 'Credit Card Recon Entry' OR strMenuName = 'Credit Card Recons') AND strModuleName = 'Credit Card Recon' AND intParentMenuID = @CreditCardReconActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Dealer Credit Cards' AND strModuleName = 'Credit Card Recon' AND intParentMenuID = @CreditCardReconActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Dealer Credit Cards', N'Credit Card Recon', @CreditCardReconActivitiesParentMenuId, N'Dealer Credit Cards', N'Activity', N'Screen', N'CreditCardRecon.view.CreditCardReconciliation?showSearch=true&searchCommand=CreditCardReconciliation', N'small-menu-activity', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'CreditCardRecon.view.CreditCardReconciliation?showSearch=true&searchCommand=CreditCardReconciliation' WHERE strMenuName = 'Dealer Credit Cards' AND strModuleName = 'Credit Card Recon' AND intParentMenuID = @CreditCardReconActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'New Dealer Credit Cards Transaction' AND strModuleName = 'Credit Card Recon' AND intParentMenuID = @CreditCardReconCreateParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'New Dealer Credit Cards Transaction', N'Credit Card Recon', @CreditCardReconCreateParentMenuId, N'New Dealer Credit Cards Transaction', N'Create', N'Screen', N'CreditCardRecon.view.CreditCardReconciliation?action=new', N'small-menu-create', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'CreditCardRecon.view.CreditCardReconciliation?action=new' WHERE strMenuName = 'New Dealer Credit Cards Transaction' AND strModuleName = 'Credit Card Recon' AND intParentMenuID = @CreditCardReconCreateParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Import File Mapper' AND strModuleName = 'Credit Card Recon' AND intParentMenuID = @CreditCardReconActivitiesParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'File Field Mapping', strDescription = 'File Field Mapping', strCommand = 'CreditCardRecon.view.FileFieldMapping' WHERE strMenuName = 'Import File Mapper' AND strModuleName = 'Credit Card Recon' AND intParentMenuID = @CreditCardReconActivitiesParentMenuId

/* START OF DELETING */
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Import Transaction' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CreditCardReconActivitiesParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'File Field Mapping' AND strModuleName = 'Credit Card Recon' AND intParentMenuID = @CreditCardReconActivitiesParentMenuId
/* END OF DELETING */

/* INVENTORY */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Inventory' AND strModuleName = 'Inventory' AND intParentMenuID = 0)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Inventory', N'Inventory', 0, N'Inventory', NULL, N'Folder', N'', N'small-folder', 1, 1, 0, 0, 8, 0)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 8 WHERE strMenuName = 'Inventory' AND strModuleName = 'Inventory' AND intParentMenuID = 0

DECLARE @InventoryParentMenuId INT
SELECT @InventoryParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Inventory' AND strModuleName = 'Inventory' AND intParentMenuID = 0

/* PRE-UPDATE - 1730 */
UPDATE tblSMMasterMenu SET strCategory = N'Report' WHERE strMenuName IN ('Inventory Valuation', 'Inventory Valuation Summary', 'Lot Details', 'Stock Details') AND strModuleName = 'Inventory'

/* CATEGORY FOLDERS */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Activities' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Activities', N'Inventory', @InventoryParentMenuId, N'Activities', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 0 WHERE strMenuName = 'Activities' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId

DECLARE @InventoryActivitiesParentMenuId INT
SELECT @InventoryActivitiesParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Activities' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Maintenance', N'Inventory', @InventoryParentMenuId, N'Maintenance', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 1, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 1 WHERE strMenuName = 'Maintenance' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId

DECLARE @InventoryMaintenanceParentMenuId INT
SELECT @InventoryMaintenanceParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Reports' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId)
    INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
    VALUES (N'Reports', N'Inventory', @InventoryParentMenuId, N'Reports', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 2, 1)
ELSE
    UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 2 WHERE strMenuName = 'Reports' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId

DECLARE @InventoryReportParentMenuId INT
SELECT @InventoryReportParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Reports' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId

/* ADD TO RESPECTIVE CATEGORY */ 
UPDATE tblSMMasterMenu SET intParentMenuID = @InventoryActivitiesParentMenuId WHERE intParentMenuID =  @InventoryParentMenuId AND strCategory = 'Activity'
UPDATE tblSMMasterMenu SET intParentMenuID = @InventoryMaintenanceParentMenuId WHERE intParentMenuID =  @InventoryParentMenuId AND strCategory = 'Maintenance'
UPDATE tblSMMasterMenu SET intParentMenuID = @InventoryReportParentMenuId WHERE intParentMenuID IN (@InventoryParentMenuId, @InventoryMaintenanceParentMenuId) AND strCategory = 'Report'

/* START OF PLURALIZING */
UPDATE tblSMMasterMenu SET strMenuName = 'Inventory Receipts', strDescription = 'Inventory Receipts' WHERE strMenuName = 'Inventory Receipt' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryActivitiesParentMenuId
UPDATE tblSMMasterMenu SET strMenuName = 'Inventory Shipments', strDescription = 'Inventory Shipments' WHERE strMenuName = 'Inventory Shipment' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryActivitiesParentMenuId
UPDATE tblSMMasterMenu SET strMenuName = 'Inventory Transfers', strDescription = 'Inventory Transfers' WHERE strMenuName = 'Inventory Transfer' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryActivitiesParentMenuId
UPDATE tblSMMasterMenu SET strMenuName = 'Inventory Adjustments', strDescription = 'Inventory Adjustments' WHERE strMenuName = 'Inventory Adjustment' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryActivitiesParentMenuId
UPDATE tblSMMasterMenu SET strMenuName = 'Items', strDescription = 'Items' WHERE strMenuName = 'Item' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceParentMenuId
UPDATE tblSMMasterMenu SET strMenuName = 'Fuel Categories', strDescription = 'Fuel Categories' WHERE strMenuName = 'Fuel Category' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceParentMenuId
UPDATE tblSMMasterMenu SET strMenuName = 'Commodities', strDescription = 'Commodities' WHERE strMenuName = 'Commodity' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceParentMenuId
UPDATE tblSMMasterMenu SET strMenuName = 'Fuel Codes', strDescription = 'Fuel Codes' WHERE strMenuName = 'Fuel Code' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceParentMenuId
UPDATE tblSMMasterMenu SET strMenuName = 'Categories', strDescription = 'Categories' WHERE strMenuName = 'Category' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceParentMenuId
UPDATE tblSMMasterMenu SET strMenuName = 'Fuel Types', strDescription = 'Fuel Types' WHERE strMenuName = 'Fuel Type' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceParentMenuId
UPDATE tblSMMasterMenu SET strMenuName = 'Inventory Tags', strDescription = 'Inventory Tags' WHERE strMenuName = 'Inventory Tag' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceParentMenuId
UPDATE tblSMMasterMenu SET strMenuName = 'Storage Unit Types', strDescription = 'Storage Unit Types' WHERE strMenuName = 'Storage Unit Type' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceParentMenuId
UPDATE tblSMMasterMenu SET strMenuName = 'Storage Locations', strDescription = 'Storage Locations' WHERE strMenuName = 'Storage Location' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceParentMenuId
UPDATE tblSMMasterMenu SET strMenuName = 'Contract Documents', strDescription = 'Contract Documents' WHERE strMenuName = 'Contract Document' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceParentMenuId
/* END OF PLURALIZING */

/* START DELETE */
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Retail Inventory' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryActivitiesParentMenuId

/* START OF RENAMING */
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Storage Locations' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = N'Storage Units', strDescription = 'Storage Units' WHERE strMenuName = 'Storage Locations' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceParentMenuId
/* END OF RENAMING */

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Inventory Receipts' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Inventory Receipts', N'Inventory', @InventoryActivitiesParentMenuId, N'Inventory Receipts', N'Activity', N'Screen', N'Inventory.view.InventoryReceipt?showSearch=true', N'small-menu-activity', 1, 1, 0, 1, 0, 0)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Inventory.view.InventoryReceipt?showSearch=true', intSort = 0 WHERE strMenuName = 'Inventory Receipts' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryActivitiesParentMenuId



IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Inventory Shipments' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Inventory Shipments', N'Inventory', @InventoryActivitiesParentMenuId, N'Inventory Shipments', N'Activity', N'Screen', N'Inventory.view.InventoryShipment?showSearch=true', N'small-menu-activity', 1, 1, 0, 1, 1, 0)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Inventory.view.InventoryShipment?showSearch=true', intSort = 1 WHERE strMenuName = 'Inventory Shipments' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Inventory Transfers' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Inventory Transfers', N'Inventory', @InventoryActivitiesParentMenuId, N'Inventory Transfers', N'Activity', N'Screen', N'Inventory.view.InventoryTransfer?showSearch=true', N'small-menu-activity', 1, 1, 0, 1, 2, 0)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Inventory.view.InventoryTransfer?showSearch=true', intSort = 2 WHERE strMenuName = 'Inventory Transfers' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Inventory Adjustments' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId])
	VALUES (N'Inventory Adjustments', N'Inventory', @InventoryActivitiesParentMenuId, N'Inventory Adjustments', N'Activity', N'Screen', N'Inventory.view.InventoryAdjustment?showSearch=true', N'small-menu-activity', 1, 1, 0, 1, 3, 0)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = N'Inventory.view.InventoryAdjustment?showSearch=true', intSort = 4 WHERE strMenuName = 'Inventory Adjustments' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Inventory Count' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId])
	VALUES (N'Inventory Count', N'Inventory', @InventoryActivitiesParentMenuId, N'Inventory Count', N'Activity', N'Screen', N'Inventory.view.InventoryCount?showSearch=true', N'small-menu-activity', 1, 1, 0, 1, 4, 0)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = N'Inventory.view.InventoryCount?showSearch=true', intSort = 4 WHERE strMenuName = 'Inventory Count' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Inventory Count By Category' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Inventory Count By Category', N'Inventory', @InventoryActivitiesParentMenuId, N'Inventory Count By Category', N'Activity', N'Screen', N'Inventory.view.InventoryCountByCategory?showSearch=true', N'small-menu-activity', 1, 1, 0, 1, 5, 0)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = N'Inventory.view.InventoryCountByCategory?showSearch=true', intSort = 5 WHERE strMenuName = 'Inventory Count By Category ' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Storage Measurement Reading' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId])
	VALUES (N'Storage Measurement Reading', N'Inventory', @InventoryActivitiesParentMenuId, N'Storage Measurement Reading', N'Activity', N'Screen', N'Inventory.view.StorageMeasurementReading?showSearch=true', N'small-menu-activity', 1, 1, 0, 1, 6, 0)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = N'Inventory.view.StorageMeasurementReading?showSearch=true', intSort = 6 WHERE strMenuName = 'Storage Measurement Reading' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Blend Production' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Blend Production', N'Inventory', @InventoryActivitiesParentMenuId, N'Blend Production', N'Activity', N'Screen', N'Manufacturing.view.BlendProduction', N'small-menu-activity', 1, 1, 0, 1, 6, 0)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 6, strCommand = N'Manufacturing.view.BlendProduction' WHERE strMenuName = 'Blend Production' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Categories' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Categories', N'Inventory', @InventoryMaintenanceParentMenuId, N'Categories', N'Maintenance', N'Screen', N'Inventory.view.Category?showSearch=true', N'small-menu-maintenance', 1, 1, 0, 1, 0, 0)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Inventory.view.Category?showSearch=true', intSort = 0 WHERE strMenuName = 'Categories' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Commodities' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Commodities', N'Inventory', @InventoryMaintenanceParentMenuId, N'Commodities', N'Maintenance', N'Screen', N'Inventory.view.Commodity?showSearch=true', N'small-menu-maintenance', 1, 1, 0, 1, 1, 0)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Inventory.view.Commodity?showSearch=true', intSort = 1 WHERE strMenuName = 'Commodities' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Fuel Types' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Fuel Types', N'Inventory', @InventoryMaintenanceParentMenuId, N'Fuel Types', N'Maintenance', N'Screen', N'Inventory.view.FuelType?showSearch=true', N'small-menu-maintenance', 1, 1, 0, 1, 2, 0)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Inventory.view.FuelType?showSearch=true', intSort = 2 WHERE strMenuName = 'Fuel Types' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Inventory UOM' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Inventory UOM', N'Inventory', @InventoryMaintenanceParentMenuId, N'Inventory UOM', N'Maintenance', N'Screen', N'Inventory.view.InventoryUOM', N'small-menu-maintenance', 1, 1, 0, 1, 3, 0)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Inventory.view.InventoryUOM', intSort = 3 WHERE strMenuName = 'Inventory UOM' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceParentMenuId
	
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Items' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Items', N'Inventory', @InventoryMaintenanceParentMenuId, N'Items', N'Maintenance', N'Screen', N'Inventory.view.Item?showSearch=true', N'small-menu-maintenance', 1, 1, 0, 1, 4, 0)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Inventory.view.Item?showSearch=true', intSort = 4 WHERE strMenuName = 'Items' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceParentMenuId
	
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Recipe' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceParentMenuId)
	UPDATE	tblSMMasterMenu 
	SET		strCommand = N'Manufacturing.view.Recipe?showSearch=true'
			, intSort = 5 
			, strMenuName = 'Recipes' 
	WHERE	strMenuName = 'Recipe' 
			AND strModuleName = 'Inventory' 
			AND intParentMenuID = @InventoryMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Recipes' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Recipes', N'Inventory', @InventoryMaintenanceParentMenuId, N'Recipes', N'Maintenance', N'Screen', N'Manufacturing.view.Recipe?showSearch=true', N'small-menu-maintenance', 1, 1, 0, 1, 5, 0)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Manufacturing.view.Recipe?showSearch=true', intSort = 5 WHERE strMenuName = 'Recipes' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Storage Units' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Storage Units', N'Inventory', @InventoryMaintenanceParentMenuId, N'Storage Units', N'Maintenance', N'Screen', N'Inventory.view.StorageUnit?showSearch=true', N'small-menu-maintenance', 1, 1, 0, 1, 6, 0)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Inventory.view.StorageUnit?showSearch=true', intSort = 6 WHERE strMenuName = 'Storage Units' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Inventory Valuation' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Inventory Valuation', N'Inventory', @InventoryReportParentMenuId, N'Inventory Valuation', N'Report', N'Screen', N'Inventory.view.InventoryValuation?showSearch=true', N'small-menu-report', 1, 1, 0, 1, 0, 0)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Inventory.view.InventoryValuation?showSearch=true', intSort = 0, strIcon = 'small-menu-report' WHERE strMenuName = 'Inventory Valuation' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Lot Details' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Lot Details', N'Inventory', @InventoryReportParentMenuId, N'Lot Details', N'Report', N'Screen', N'Inventory.view.LotDetail?showSearch=true', N'small-menu-report', 1, 1, 0, 1, 2, 0)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Inventory.view.LotDetail?showSearch=true', intSort = 2, strIcon = 'small-menu-report' WHERE strMenuName = 'Lot Details' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Retail Inventory' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Retail Inventory', N'Inventory', @InventoryReportParentMenuId, N'Retail Inventory', N'Report', N'Screen', N'Inventory.view.RetailInventoryReport', N'small-menu-report', 1, 1, 0, 1, 2, 0)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Inventory.view.RetailInventoryReport', intSort = 2, strIcon = 'small-menu-report' WHERE strMenuName = 'Retail Inventory' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryReportParentMenuId


IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Stock Details' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Stock Details', N'Inventory', @InventoryReportParentMenuId, N'Stock Details', N'Report', N'Screen', N'Inventory.view.StockDetail?showSearch=true', N'small-menu-report', 1, 1, 0, 1, 3, 0)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Inventory.view.StockDetail?showSearch=true', intSort = 3, strIcon = 'small-menu-report' WHERE strMenuName = 'Stock Details' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Blend Details' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Blend Details', N'Inventory', @InventoryReportParentMenuId, N'Blend Details', N'Report', N'Screen', N'Inventory.view.BlendDetail?showSearch=true', N'small-menu-report', 0, 0, 0, 1, 5, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = N'Inventory.view.BlendDetail?showSearch=true', intSort = 5 WHERE strMenuName = 'Blend Details' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryReportParentMenuId

/* START OF DELETING */
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Build Assemblies' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Fuel Categories' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Fuel Codes' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Production Process' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Feed Stock' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Feed Stock UOM' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Fuel Tax Class' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Inventory Tags' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Patronage Category' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Manufacturer' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Reasons' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Storage Unit Types' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Item Substitution' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Certification Programs' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Contract Documents' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Lot Status' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Sample Type' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Brand' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Inventory Count Group' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Line of Business' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Inventory Count Name' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Stock Report' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName IN ('View Stock Details', 'View Lot Details') AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Inventory Valuation Summary' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryReportParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Pack Type' and strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceParentMenuId
IF EXISTS(SELECT strMenuName FROM tblSMMasterMenu WHERE strMenuName =  'Blend Production' AND strModuleName = 'Inventory' AND (SELECT COUNT(strMenuName) FROM tblSMMasterMenu WHERE strMenuName =  'Blend Production' AND strModuleName = 'Inventory') > 1)
BEGIN
	DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Blend Production' AND strModuleName = 'Inventory' AND intMenuID NOT IN
	(
		SELECT TOP 1 intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Blend Production' AND strModuleName = 'Inventory'
	)
END
/* END OF DELETING */

/* ACCOUNTS PAYABLE */

/* Rename from Purchasing (Accounts Payable) to Purchasing (A/P) */
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Purchasing (Accounts Payable)' AND strModuleName = 'Accounts Payable' AND intParentMenuID = 0)
UPDATE tblSMMasterMenu SET strMenuName = 'Purchasing (A/P)', strDescription = 'Purchasing (A/P)' WHERE strMenuName = 'Purchasing (Accounts Payable)' AND strModuleName = 'Accounts Payable' AND intParentMenuID = 0

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Purchasing (A/P)' AND strModuleName = 'Accounts Payable' AND intParentMenuID = 0)
UPDATE tblSMMasterMenu SET intSort = 9 WHERE strMenuName = 'Purchasing (A/P)' AND strModuleName = 'Accounts Payable' AND intParentMenuID = 0

DECLARE @AccountsPayableParentMenuId INT
SELECT @AccountsPayableParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Purchasing (A/P)' AND strModuleName = 'Accounts Payable' AND intParentMenuID = 0

/* PRE-UPDATE 1730 to 1800 */
UPDATE tblSMMasterMenu SET strCategory = N'Activity', strIcon = N'small-menu-activity' WHERE strMenuName IN ('Purchase Orders', 'Vouchers', 'Voucher Batch Entry', 'Pay Vouchers', 'Pay Voucher Details', 'Process Payments', 'Batch Posting') AND strModuleName = 'Accounts Payable'
UPDATE tblSMMasterMenu SET strCategory = N'Maintenance', strIcon = N'small-menu-maintenance' WHERE strMenuName IN ('1099', 'Buyers', 'Liens', 'Vendors') AND strModuleName = 'Accounts Payable'
UPDATE tblSMMasterMenu SET strCategory = N'Import', strIcon = N'small-menu-import' WHERE strMenuName IN ('Import Vouchers from Origin') AND strModuleName = 'Accounts Payable'
UPDATE tblSMMasterMenu SET strCategory = N'Report', strIcon = N'small-menu-report' WHERE strMenuName IN ('AP Transactions By GL Account', 'Cash Requirements', 'Check Register', 'Open Clearing', 'Open Payable Details', 'Open Clearing Detail', 'Open Payables', 'Voucher Checkoff') AND strModuleName = 'Accounts Payable'

/* CATEGORY FOLDERS */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Activities' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intRow], [intConcurrencyId]) 
	VALUES (N'Activities', N'Accounts Payable', @AccountsPayableParentMenuId, N'Activities', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 0, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 0, intRow = 0 WHERE strMenuName = 'Activities' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId

DECLARE @AccountsPayableActivitiesParentMenuId INT
SELECT @AccountsPayableActivitiesParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Activities' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intRow], [intConcurrencyId]) 
	VALUES (N'Maintenance', N'Accounts Payable', @AccountsPayableParentMenuId, N'Maintenance', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 1, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 1, intRow = 0 WHERE strMenuName = 'Maintenance' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId

DECLARE @AccountsPayableMaintenanceParentMenuId INT
SELECT @AccountsPayableMaintenanceParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Import' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intRow], [intConcurrencyId]) 
	VALUES (N'Import', N'Accounts Payable', @AccountsPayableParentMenuId, N'Import', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 2, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 2, intRow = 0 WHERE strMenuName = 'Import' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId

DECLARE @AccountsPayableImportParentMenuId INT
SELECT @AccountsPayableImportParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Import' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Reports' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intRow], [intConcurrencyId])
	VALUES (N'Reports', N'Accounts Payable', @AccountsPayableParentMenuId, N'Reports', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 3, 0, 1)
ELSE
    UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 3, intRow = 0 WHERE strMenuName = 'Reports' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId

DECLARE @AccountsPayableReportParentMenuId INT
SELECT @AccountsPayableReportParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Reports' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Create' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intRow], [intConcurrencyId])
	VALUES (N'Create', N'Accounts Payable', @AccountsPayableParentMenuId, N'Create', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 0, 1, 1)
ELSE
    UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 0, intRow = 1 WHERE strMenuName = 'Create' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId

DECLARE @AccountsPayableCreateParentMenuId INT
SELECT @AccountsPayableCreateParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Create' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId

/* ADD TO RESPECTIVE CATEGORY */ 
UPDATE tblSMMasterMenu SET intParentMenuID = @AccountsPayableActivitiesParentMenuId WHERE intParentMenuID = @AccountsPayableParentMenuId AND strCategory = 'Activity'
UPDATE tblSMMasterMenu SET intParentMenuID = @AccountsPayableMaintenanceParentMenuId WHERE intParentMenuID = @AccountsPayableParentMenuId AND strCategory = 'Maintenance'
UPDATE tblSMMasterMenu SET intParentMenuID = @AccountsPayableImportParentMenuId WHERE intParentMenuID = @AccountsPayableParentMenuId AND strCategory = 'Import'
UPDATE tblSMMasterMenu SET intParentMenuID = @AccountsPayableReportParentMenuId WHERE intParentMenuID = @AccountsPayableParentMenuId AND strCategory = 'Report'
UPDATE tblSMMasterMenu SET intParentMenuID = @AccountsPayableCreateParentMenuId WHERE intParentMenuID = @AccountsPayableParentMenuId AND strCategory = 'Create'

/* START OF PLURALIZING */
/* END OF PLURALIZING */

/* START OF RENAMING  */
UPDATE tblSMMasterMenu SET strMenuName = 'New Payment', strDescription = 'New Payment' WHERE strMenuName = 'New Payable' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableCreateParentMenuId
UPDATE tblSMMasterMenu SET strMenuName = 'New Purchase Order', strDescription = 'New Purchase Order' WHERE strMenuName = 'New Purchase Orders' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableCreateParentMenuId
UPDATE tblSMMasterMenu SET strMenuName = 'New Voucher', strDescription = 'New Voucher' WHERE strMenuName = 'New Vouchers' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableCreateParentMenuId
/* END OF RENAMING  */

/* Start of Moving */
UPDATE tblSMMasterMenu SET intParentMenuID = @AccountsPayableReportParentMenuId WHERE strMenuName = 'Open Payables' AND strModuleName = 'Accounts Payable' AND strType IN ('Screen', 'Report') AND intParentMenuID = @AccountsPayableParentMenuId
UPDATE tblSMMasterMenu SET intParentMenuID = @AccountsPayableReportParentMenuId WHERE strMenuName = 'Open Payable Details' AND strModuleName = 'Accounts Payable' AND strType IN ('Report', 'Screen') AND intParentMenuID = @AccountsPayableParentMenuId
UPDATE tblSMMasterMenu SET intParentMenuID = @AccountsPayableReportParentMenuId WHERE strMenuName = 'Cash Requirements' AND strModuleName = 'Accounts Payable' AND strType = 'Report' AND intParentMenuID = @AccountsPayableParentMenuId
UPDATE tblSMMasterMenu SET intParentMenuID = @AccountsPayableReportParentMenuId WHERE strMenuName = 'Check Register' AND strModuleName = 'Accounts Payable' AND strType = 'Report' AND intParentMenuID = @AccountsPayableParentMenuId
UPDATE tblSMMasterMenu SET intParentMenuID = @AccountsPayableReportParentMenuId WHERE strMenuName = 'AP Transactions by GL Account' AND strModuleName = 'Accounts Payable' AND strType IN ('Report', 'Screen') AND intParentMenuID = @AccountsPayableParentMenuId
/* End of Moving */

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Purchase Orders' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Purchase Orders', N'Accounts Payable', @AccountsPayableActivitiesParentMenuId, N'', N'Activity', N'Screen', N'AccountsPayable.view.PurchaseOrder?showSearch=true', N'small-menu-activity', 1, 0, 0, 1, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'AccountsPayable.view.PurchaseOrder?showSearch=true', intSort = 0 WHERE strMenuName = 'Purchase Orders' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Vouchers' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Vouchers', N'Accounts Payable', @AccountsPayableActivitiesParentMenuId, N'Vouchers', N'Activity', N'Screen', N'AccountsPayable.view.Voucher?showSearch=true', N'small-menu-activity', 0, 0, 0, 1, 1, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'AccountsPayable.view.Voucher?showSearch=true', intSort = 1 WHERE strMenuName = 'Vouchers' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableActivitiesParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Voucher Batch Entry' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableActivitiesParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = 'AccountsPayable.view.VoucherBatch?showSearch=true', intSort = 2 WHERE strMenuName = 'Voucher Batch Entry' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableActivitiesParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Pay Vouchers' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableActivitiesParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = 'AccountsPayable.view.PayVouchers', intSort = 3 WHERE strMenuName = 'Pay Vouchers' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableActivitiesParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Pay Voucher Details' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableActivitiesParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = 'AccountsPayable.view.PayVouchersDetail?showSearch=true', intSort = 4 WHERE strMenuName = 'Pay Voucher Details' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableActivitiesParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Process Payments' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableActivitiesParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = 'AccountsPayable.controller.PrintChecks', intSort = 5 WHERE strMenuName = 'Process Payments' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableActivitiesParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Batch Posting' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableActivitiesParentMenuId) 
UPDATE tblSMMasterMenu SET strCommand = 'i21.view.BatchPosting?module=Purchasing', intSort = 6 WHERE strMenuName = 'Batch Posting' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Basis Advance' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Basis Advance', N'Accounts Payable', @AccountsPayableActivitiesParentMenuId, N'Basis Advance', N'Activity', N'Screen', N'AccountsPayable.view.BasisAdvance', N'small-menu-activity', 0, 0, 0, 1, 7, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'AccountsPayable.view.BasisAdvance', intSort = 7 WHERE strMenuName = 'Basis Advance' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Deferred Payments' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Deferred Payments', N'Accounts Payable', @AccountsPayableActivitiesParentMenuId, N'Deferred Payments', N'Activity', N'Screen', N'AccountsPayable.view.DeferredPayment', N'small-menu-activity', 0, 0, 0, 1, 8, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'AccountsPayable.view.DeferredPayment', intSort = 8 WHERE strMenuName = 'Deferred Payments' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Voucher CheckOff Detail' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Voucher CheckOff Detail', N'Accounts Payable', @AccountsPayableActivitiesParentMenuId, N'Voucher CheckOff Detail', N'Activity', N'Screen', N'AccountsPayable.view.VoucherCheckOffDetail?showSearch=true', N'small-menu-activity', 0, 0, 0, 1, 9, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'AccountsPayable.view.VoucherCheckOffDetail?showSearch=true', intSort = 9 WHERE strMenuName = 'Voucher CheckOff Detail' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = '1099' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'1099', N'Accounts Payable', @AccountsPayableMaintenanceParentMenuId, N'1099', N'Maintenance', N'Screen', N'AccountsPayable.view.Thresholds1099', N'small-menu-maintenance', 1, 0, 0, 1, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'AccountsPayable.view.Thresholds1099', intSort = 0 WHERE strMenuName = '1099' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Buyers' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Buyers', N'Accounts Payable', @AccountsPayableMaintenanceParentMenuId, N'Buyers', N'Maintenance', N'Screen', N'EntityManagement.view.EntityDirect?showSearch=true&searchCommand=EntityBuyer', N'small-menu-maintenance', 1, 0, 0, 1, 1, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'EntityManagement.view.EntityDirect?showSearch=true&searchCommand=EntityBuyer', intSort = 1 WHERE strMenuName = 'Buyers' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Liens' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Liens', N'Accounts Payable', @AccountsPayableMaintenanceParentMenuId, N'Liens', N'Maintenance', N'Screen', N'EntityManagement.view.EntityDirect?showSearch=true&searchCommand=EntityLien', N'small-menu-maintenance', 1, 0, 0, 1, 2, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'EntityManagement.view.EntityDirect?showSearch=true&searchCommand=EntityLien', intSort = 2 WHERE strMenuName = 'Liens' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Vendors' AND strModuleName = N'Accounts Payable' AND intParentMenuID = @AccountsPayableMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'AccountsPayable.view.EntityVendor?showSearch=true', intSort = 3 WHERE strMenuName = N'Vendors' AND strModuleName = N'Accounts Payable' AND intParentMenuID = @AccountsPayableMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Vendor Inquiry' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Vendor Inquiry', N'Accounts Payable', @AccountsPayableMaintenanceParentMenuId, N'Vendor Inquiry', N'Maintenance', N'Screen', N'EntityManagement.view.EntityInquiry?showSearch=true', N'small-menu-maintenance', 1, 0, 0, 1, 4, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'EntityManagement.view.EntityInquiry?showSearch=true', intSort = 4 WHERE strMenuName = 'Vendor Inquiry' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Vendor Mapping' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Vendor Mapping', N'Accounts Payable', @AccountsPayableMaintenanceParentMenuId, N'Vendor Mapping', N'Maintenance', N'Screen', N'GeneralLedger.view.VendorMapping?showSearch=true', N'small-menu-maintenance', 1, 0, 0, 1, 5, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = N'GeneralLedger.view.VendorMapping?showSearch=true', intSort = 5 WHERE strMenuName = 'Vendor Mapping' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Import Vouchers from Origin' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableImportParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = 'AccountsPayable.view.ImportAPInvoice', intSort = 0 WHERE strMenuName = 'Import Vouchers from Origin' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableImportParentMenuId

--IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE intMenuID = 130)-- strMenuName = N'AP Transactions by GL Account' AND strModuleName = N'Accounts Payable' AND intParentMenuID = @AccountsPayableReportParentMenuId AND intMenuID = 130)
--BEGIN
--	/* Start of Re-insert */
--	SET IDENTITY_INSERT [dbo].[tblSMMasterMenu] ON

--	INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
--	VALUES (130, N'AP Transactions By GL Account', N'Accounts Payable', @AccountsPayableReportParentMenuId, N'AP Transactions By GL Account', N'Report', N'Screen', N'Reporting.view.ReportManager?group=Purchasing&report=APTransactionByGLAccount&direct=true&showCriteria=true', N'small-menu-report', 0, 0, 0, 1, 0, 1)

--	SET IDENTITY_INSERT [dbo].[tblSMMasterMenu] OFF
--	/* End of Re-insert */
--END
--ELSE
--	UPDATE tblSMMasterMenu SET strCommand = 'Reporting.view.ReportManager?group=Purchasing&report=APTransactionByGLAccount&direct=true&showCriteria=true', intSort = 0, strDescription = 'AP Transactions By GL Account', strCategory = N'Report', strType = 'Screen' WHERE strMenuName = 'AP Transactions By GL Account' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableReportParentMenuId	

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Cash Requirements' AND strModuleName = N'Accounts Payable' AND intParentMenuID = @AccountsPayableReportParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'Reporting.view.ReportManager?group=Purchasing&report=CashRequirements&direct=true&showCriteria=true', intSort = 1, strType = N'Screen' WHERE strMenuName = N'Cash Requirements' AND strModuleName = N'Accounts Payable' AND intParentMenuID = @AccountsPayableReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Cash Requirement Detail' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Cash Requirement Detail', N'Accounts Payable', @AccountsPayableReportParentMenuId, N'Cash Requirement Detail', N'Report', N'Screen', N'Reporting.view.ReportManager?group=Purchasing&report=CashRequirementDetail&direct=true&showCriteria=true', N'small-menu-report', 1, 0, 0, 1, 2, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = N'Reporting.view.ReportManager?group=Purchasing&report=CashRequirementDetail&direct=true&showCriteria=true', intSort = 2, strCategory = N'Report', strType = 'Screen' WHERE strMenuName = 'Cash Requirement Detail' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableReportParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Check Register' AND strModuleName = N'Accounts Payable' AND intParentMenuID = @AccountsPayableReportParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'Reporting.view.ReportManager?group=Purchasing&report=CheckRegister&direct=true&showCriteria=true', intSort = 3, strType = N'Screen' WHERE strMenuName = N'Check Register' AND strModuleName = N'Accounts Payable' AND intParentMenuID = @AccountsPayableReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Customer Settlement Summary Statement' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Customer Settlement Summary Statement', N'Accounts Payable', @AccountsPayableReportParentMenuId, N'Customer Settlement Summary Statement', N'Report', N'Screen', N'Reporting.view.ReportManager?group=Purchasing&report=PurchaseCustomerSettlement&direct=true&showCriteria=true', N'small-menu-report', 1, 0, 0, 1, 4, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = N'Reporting.view.ReportManager?group=Purchasing&report=PurchaseCustomerSettlement&direct=true&showCriteria=true', intSort = 4, strCategory = N'Report', strType = 'Screen' WHERE strMenuName = 'Customer Settlement Summary Statement' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Inbound Tax' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Inbound Tax', N'Accounts Payable', @AccountsPayableReportParentMenuId, N'Inbound Tax', N'Report', N'Screen', N'Reporting.view.ReportManager?group=Purchasing&report=InboundTaxReport&direct=true&showCriteria=true', N'small-menu-report', 1, 0, 0, 1, 5, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = N'Reporting.view.ReportManager?group=Purchasing&report=InboundTaxReport&direct=true&showCriteria=true', intSort = 5, strCategory = N'Report', strType = 'Screen' WHERE strMenuName = 'Inbound Tax' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Open Clearing' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Open Clearing', N'Accounts Payable', @AccountsPayableReportParentMenuId, N'Open Clearing', N'Report', N'Screen', N'Reporting.view.ReportManager?group=Purchasing&report=OpenClearing&direct=true&showCriteria=true', N'small-menu-report', 1, 0, 0, 1, 6, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'Reporting.view.ReportManager?group=Purchasing&report=OpenClearing&direct=true&showCriteria=true', intSort = 6, strCategory = N'Report', strType = 'Screen' WHERE strMenuName = 'Open Clearing' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Open Payable Details' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Open Payable Details', N'Accounts Payable', @AccountsPayableReportParentMenuId, N'Open Payable Details', N'Report', N'Screen', N'Reporting.view.ReportManager?group=Purchasing&report=OpenPayablesDetail&direct=true&showCriteria=true', N'small-menu-report', 1, 0, 0, 1, 7, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'Reporting.view.ReportManager?group=Purchasing&report=OpenPayablesDetail&direct=true&showCriteria=true', intSort = 7, strCategory = N'Report', strType = 'Screen' WHERE strMenuName = 'Open Payable Details' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Open Clearing Detail' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Open Clearing Detail', N'Accounts Payable', @AccountsPayableReportParentMenuId, N'Open Clearing Detail', N'Report', N'Screen', N'Reporting.view.ReportManager?group=Purchasing&report=OpenClearingDetails&direct=true&showCriteria=true', N'small-menu-report', 1, 0, 0, 1, 8, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'Reporting.view.ReportManager?group=Purchasing&report=OpenClearingDetails&direct=true&showCriteria=true', intSort = 8, strCategory = N'Report', strType = 'Screen' WHERE strMenuName = 'Open Clearing Detail' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableReportParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Open Payables' AND strModuleName = N'Accounts Payable' AND intParentMenuID = @AccountsPayableReportParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'Reporting.view.ReportManager?group=Purchasing&report=OpenPayables&direct=true&showCriteria=true', intSort = 9, strCategory = 'Report', strType = 'Screen' WHERE strMenuName = N'Open Payables' AND strModuleName = N'Accounts Payable' AND intParentMenuID = @AccountsPayableReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Voucher Checkoff' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Voucher Checkoff', N'Accounts Payable', @AccountsPayableReportParentMenuId, N'Voucher Checkoff', N'Report', N'Screen', N'Reporting.view.ReportManager?group=Purchasing&report=VoucherCheckOff&direct=true&showCriteria=true', N'small-menu-report', 1, 0, 0, 1, 10, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'Reporting.view.ReportManager?group=Purchasing&report=VoucherCheckOff&direct=true&showCriteria=true', intSort = 10, strCategory = N'Report', strType = 'Screen' WHERE strMenuName = 'Voucher Checkoff' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'New Purchase Order' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableCreateParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'New Purchase Order', N'Accounts Payable', @AccountsPayableCreateParentMenuId, N'New Purchase Order', N'Create', N'Screen', N'AccountsPayable.view.PurchaseOrder?action=new', N'small-menu-create', 1, 0, 0, 1, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'AccountsPayable.view.PurchaseOrder?action=new', intSort = 0, strDescription = 'New Purchase Order', strCategory = 'Create' WHERE strMenuName = 'New Purchase Order' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableCreateParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'New Voucher' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableCreateParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'New Voucher', N'Accounts Payable', @AccountsPayableCreateParentMenuId, N'New Voucher', N'Create', N'Screen', N'AccountsPayable.view.Voucher?action=new', N'small-menu-create', 0, 0, 0, 1, 1, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'AccountsPayable.view.Voucher?action=new', intSort = 1 WHERE strMenuName = 'New Voucher' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableCreateParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'New Voucher Batch Entry' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableCreateParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'New Voucher Batch Entry', N'Accounts Payable', @AccountsPayableCreateParentMenuId, N'New Voucher Batch Entry', N'Create', N'Screen', N'AccountsPayable.view.VoucherBatch?action=new', N'small-menu-create', 0, 0, 0, 1, 2, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'AccountsPayable.view.VoucherBatch?action=new', intSort = 2 WHERE strMenuName = 'New Voucher Batch Entry' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableCreateParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'New Payment' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableCreateParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'New Payment', N'Accounts Payable', @AccountsPayableCreateParentMenuId, N'New Payment', N'Create', N'Screen', N'AccountsPayable.view.PayVouchersDetail?action=new', N'small-menu-create', 0, 0, 0, 1, 3, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'AccountsPayable.view.PayVouchersDetail?action=new', intSort = 3 WHERE strMenuName = 'New Payment' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableCreateParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'New Buyer' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableCreateParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'New Buyer', N'Accounts Payable', @AccountsPayableCreateParentMenuId, N'New Buyer', N'Create', N'Screen', N'EntityManagement.view.EntityDirect:EntityBuyer?action=new', N'small-menu-create', 0, 0, 0, 1, 4, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'EntityManagement.view.EntityDirect:EntityBuyer?action=new', intSort = 4 WHERE strMenuName = 'New Buyer' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableCreateParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'New Lien' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableCreateParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'New Lien', N'Accounts Payable', @AccountsPayableCreateParentMenuId, N'New Lien', N'Create', N'Screen', N'EntityManagement.view.EntityDirect:EntityLien?action=new', N'small-menu-create', 0, 0, 0, 1, 5, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'EntityManagement.view.EntityDirect:EntityLien?action=new', intSort = 5 WHERE strMenuName = 'New Lien' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableCreateParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'New Vendor' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableCreateParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'New Vendor', N'Accounts Payable', @AccountsPayableCreateParentMenuId, N'New Vendor', N'Create', N'Screen', N'AccountsPayable.view.EntityVendor?action=new', N'small-menu-create', 0, 0, 0, 1, 6, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'AccountsPayable.view.EntityVendor?action=new', intSort = 6 WHERE strMenuName = 'New Vendor' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableCreateParentMenuId

/* START OF DELETING */
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Paid Bills History' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableActivitiesParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Open Payable Details' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'AP Transaction By GLAccount' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableActivitiesParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Recurring Transactions' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableActivitiesParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Open Clearing' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableActivitiesParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Open Clearing Detail' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableActivitiesParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Vendor Expense Approval' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableActivitiesParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Vendor History' AND strModuleName = N'Accounts Payable' AND intParentMenuID = @AccountsPayableReportParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Vendor' AND strModuleName = N'Accounts Payable' AND intParentMenuID = @AccountsPayableActivitiesParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Vendor Contact List' AND strModuleName = N'Accounts Payable' AND intParentMenuID = @AccountsPayableActivitiesParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Voucher Checkoff Detail' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableReportParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'AP Transactions By GL Account' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableReportParentMenuId	
/* END OF DELETING */

/* ACCOUNTS RECEIVABLE */
/* Rename Sales (Account Receivables) to Sales (A/R) */
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Sales (Accounts Receivable)' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = 0)
UPDATE tblSMMasterMenu SET strMenuName = 'Sales (A/R)', strDescription = 'Sales (A/R)' WHERE strMenuName = 'Sales (Accounts Receivable)' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = 0

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Sales (A/R)' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = 0)
UPDATE tblSMMasterMenu SET intSort = 10 WHERE strMenuName = 'Sales (A/R)' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = 0

DECLARE @AccountsReceivableParentMenuId INT
SELECT @AccountsReceivableParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Sales (A/R)' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = 0

/* PRE-UPDATE 1730 to 1800 */
UPDATE tblSMMasterMenu SET strCategory = N'Activity', strIcon = N'small-menu-activity' WHERE strMenuName IN ('Sales Orders', 'Invoices', 'Receive Payments', 'Receive Payment Details', 'Calculate Service Charge', 'Service Charge Invoice', 'Quote Page Builder', 'Batch Posting', 'Batch Printing') AND strModuleName = 'Accounts Receivable'
UPDATE tblSMMasterMenu SET strCategory = N'Maintenance', strIcon = N'small-menu-maintenance' WHERE strMenuName IN ('Account Status Codes', 'Customers', 'Customer Contact List', 'Customer Groups', 'Product Types', 'Quote Templates') AND strModuleName = 'Accounts Receivable'
UPDATE tblSMMasterMenu SET strCategory = N'Commission', strIcon = N'small-menu-commission' WHERE strMenuName IN ('Calculate Commission', 'Commission Approval', 'Commission Plans', 'Commission Schedules') AND strModuleName = 'Accounts Receivable'
UPDATE tblSMMasterMenu SET strCategory = N'Report', strIcon = N'small-menu-report' WHERE strMenuName IN ('Customer Aging Detail', 'Customer Aging', 'Customer Inquiry', 'Customer Statements Detail', 'Customer Statements', 'Invoice History', 'Payment History', 'Restricted Chemicals', 'Tax', 'Unapplied Credits Register', 'Sales Analysis Reports', 'Tax Report Grid') AND strModuleName = 'Accounts Receivable'
UPDATE tblSMMasterMenu SET strCategory = N'Point of Sale', strIcon = N'small-menu-pos' WHERE strMenuName IN ('POS Login', 'POS End Of Day') AND strModuleName = 'Accounts Receivable'
UPDATE tblSMMasterMenu SET strCategory = N'Import', strIcon = N'small-menu-import' WHERE strMenuName IN ('Import Billable from Help Desk', 'Import Invoices from Origin', 'Import Logs', 'Import Transactions from CSV') AND strModuleName = 'Accounts Receivable'

/* CATEGORY FOLDERS */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Activities' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intRow], [intConcurrencyId]) 
	VALUES (N'Activities', N'Accounts Receivable', @AccountsReceivableParentMenuId, N'Activities', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 0, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 0, intRow = 0 WHERE strMenuName = 'Activities' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId

DECLARE @AccountsReceivableActivitiesParentMenuId INT
SELECT @AccountsReceivableActivitiesParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Activities' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intRow], [intConcurrencyId]) 
	VALUES (N'Maintenance', N'Accounts Receivable', @AccountsReceivableParentMenuId, N'Maintenance', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 1, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 1, intRow = 0 WHERE strMenuName = 'Maintenance' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId

DECLARE @AccountsReceivableMaintenanceParentMenuId INT
SELECT @AccountsReceivableMaintenanceParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Commission' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intRow], [intConcurrencyId]) 
	VALUES (N'Commission', N'Accounts Receivable', @AccountsReceivableParentMenuId, N'Commission', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 2, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 2, intRow = 0 WHERE strMenuName = 'Commission' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId

DECLARE @AccountsReceivableCommissionParentMenuId INT
SELECT @AccountsReceivableCommissionParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Commission' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Reports' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intRow], [intConcurrencyId]) 
    VALUES (N'Reports', N'Accounts Receivable', @AccountsReceivableParentMenuId, N'Reports', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 3, 0, 1)
ELSE
    UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 3, intRow = 0 WHERE strMenuName = 'Reports' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId

DECLARE @AccountsReceivableReportParentMenuId INT
SELECT @AccountsReceivableReportParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Reports' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Create' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intRow], [intConcurrencyId]) 
    VALUES (N'Create', N'Accounts Receivable', @AccountsReceivableParentMenuId, N'Create', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 0, 1, 1)
ELSE
    UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 0, intRow = 1 WHERE strMenuName = 'Create' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId

DECLARE @AccountsReceivableCreateParentMenuId INT
SELECT @AccountsReceivableCreateParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Create' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Point of Sale' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intRow], [intConcurrencyId]) 
    VALUES (N'Point of Sale', N'Accounts Receivable', @AccountsReceivableParentMenuId, N'Point of Sale', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 1, 1, 1)
ELSE
    UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 1, intRow = 1 WHERE strMenuName = 'Point of Sale' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId

DECLARE @AccountsReceivablePOSParentMenuId INT
SELECT @AccountsReceivablePOSParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Point of Sale' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Import' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intRow], [intConcurrencyId]) 
    VALUES (N'Import', N'Accounts Receivable', @AccountsReceivableParentMenuId, N'Import', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 2, 1, 1)
ELSE
    UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 2, intRow = 1 WHERE strMenuName = 'Import' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId

DECLARE @AccountsReceivableImportParentMenuId INT
SELECT @AccountsReceivableImportParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Import' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId

/* ADD TO RESPECTIVE CATEGORY */ 
UPDATE tblSMMasterMenu SET intParentMenuID = @AccountsReceivableActivitiesParentMenuId WHERE intParentMenuID =  @AccountsReceivableParentMenuId AND strCategory = 'Activity'
UPDATE tblSMMasterMenu SET intParentMenuID = @AccountsReceivableMaintenanceParentMenuId WHERE intParentMenuID =  @AccountsReceivableParentMenuId AND strCategory = 'Maintenance'
UPDATE tblSMMasterMenu SET intParentMenuID = @AccountsReceivableCommissionParentMenuId WHERE intParentMenuID =  @AccountsReceivableParentMenuId AND strCategory = 'Commission'
UPDATE tblSMMasterMenu SET intParentMenuID = @AccountsReceivableReportParentMenuId WHERE intParentMenuID =  @AccountsReceivableParentMenuId AND strCategory = 'Report'
UPDATE tblSMMasterMenu SET intParentMenuID = @AccountsReceivableCreateParentMenuId WHERE intParentMenuID =  @AccountsReceivableParentMenuId AND strCategory = 'Create'
UPDATE tblSMMasterMenu SET intParentMenuID = @AccountsReceivablePOSParentMenuId WHERE intParentMenuID =  @AccountsReceivableParentMenuId AND strCategory = 'Point of Sale'
UPDATE tblSMMasterMenu SET intParentMenuID = @AccountsReceivableImportParentMenuId WHERE intParentMenuID =  @AccountsReceivableParentMenuId AND strCategory = 'Import'
UPDATE tblSMMasterMenu SET strMenuName = N'Import Transactions from CSV', strDescription = N'Import Transactions from CSV', strCommand = N'AccountsReceivable.view.ImportTransactionsCSV' WHERE strMenuName = 'Import Invoices from CSV' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId
UPDATE tblSMMasterMenu SET strMenuName = N'Tax Report Grid', strDescription = N'Tax Report Grid' WHERE strMenuName = 'Tax Report' AND strModuleName = 'Accounts Receivable' AND strCategory = N'Maintenance' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId
UPDATE tblSMMasterMenu SET strMenuName = N'Commissions', strDescription = N'Commissions' WHERE strMenuName = 'Calculate Commission' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableCommissionParentMenuId

/* Start of moving report */
UPDATE tblSMMasterMenu SET intParentMenuID = @AccountsReceivableReportParentMenuId WHERE strMenuName = 'Sales Analysis Reports' AND strModuleName = 'Accounts Receivable' AND strCategory = 'Report' AND intParentMenuID = @AccountsReceivableMaintenanceParentMenuId
UPDATE tblSMMasterMenu SET intParentMenuID = @AccountsReceivableReportParentMenuId WHERE strMenuName = 'Tax Report Grid' AND strModuleName = 'Accounts Receivable' AND strCategory = 'Report' AND intParentMenuID = @AccountsReceivableMaintenanceParentMenuId
/* End of moving report */

/* Removing Report in Reports - 1730 */
UPDATE tblSMMasterMenu SET strMenuName = 'Customer Aging', strDescription = 'Customer Aging' WHERE strMenuName = 'Customer Aging Report' AND strModuleName = 'Accounts Receivable' AND strCategory = 'Report' AND intParentMenuID = @AccountsReceivableReportParentMenuId
UPDATE tblSMMasterMenu SET strMenuName = 'Customer Inquiry', strDescription = 'Customer Inquiry' WHERE strMenuName = 'Customer Inquiry Report' AND strModuleName = 'Accounts Receivable' AND strCategory = 'Report' AND intParentMenuID = @AccountsReceivableReportParentMenuId
UPDATE tblSMMasterMenu SET strMenuName = 'Customer Statements', strDescription = 'Customer Statements' WHERE strMenuName = 'Customer Statements Report' AND strModuleName = 'Accounts Receivable' AND strCategory = 'Report' AND intParentMenuID = @AccountsReceivableReportParentMenuId
UPDATE tblSMMasterMenu SET strMenuName = 'Payment History', strDescription = 'Payment History' WHERE strMenuName = 'Payment History Report' AND strModuleName = 'Accounts Receivable' AND strCategory = 'Report' AND intParentMenuID = @AccountsReceivableReportParentMenuId
UPDATE tblSMMasterMenu SET strMenuName = 'Unapplied Credits Register', strDescription = 'Unapplied Credits Register' WHERE strMenuName = 'Unapplied Credits Register Report' AND strModuleName = 'Accounts Receivable' AND strCategory = 'Report' AND intParentMenuID = @AccountsReceivableReportParentMenuId
UPDATE tblSMMasterMenu SET strMenuName = 'Customer Statements Detail', strDescription = 'Customer Statements Detail' WHERE strMenuName = 'Customer Statements Detail Report' AND strModuleName = 'Accounts Receivable' AND strCategory = 'Report' AND intParentMenuID = @AccountsReceivableReportParentMenuId
UPDATE tblSMMasterMenu SET strMenuName = 'Invoice History', strDescription = 'Invoice History' WHERE strMenuName = 'Invoice History Report' AND strModuleName = 'Accounts Receivable' AND strCategory = 'Report' AND intParentMenuID = @AccountsReceivableReportParentMenuId
UPDATE tblSMMasterMenu SET strMenuName = 'Tax', strDescription = 'Tax' WHERE strMenuName = 'Tax Report' AND strModuleName = 'Accounts Receivable' AND strCategory = 'Report' AND intParentMenuID = @AccountsReceivableReportParentMenuId
UPDATE tblSMMasterMenu SET strMenuName = 'Customer Aging Detail', strDescription = 'Customer Aging Detail' WHERE strMenuName = 'Customer Aging Detail Report' AND strModuleName = 'Accounts Receivable' AND strCategory = 'Report' AND intParentMenuID = @AccountsReceivableReportParentMenuId
UPDATE tblSMMasterMenu SET strMenuName = 'Restricted Chemicals', strDescription = 'Restricted Chemicals' WHERE strMenuName = 'Restricted Chemicals Report' AND strModuleName = 'Accounts Receivable' AND strCategory = 'Report' AND intParentMenuID = @AccountsReceivableReportParentMenuId
UPDATE tblSMMasterMenu SET strMenuName = 'POS End Of Day', strDescription = 'POS End Of Day' WHERE strMenuName = 'POS End Of Day Report' AND strModuleName = 'Accounts Receivable' AND strCategory = 'Report' AND intParentMenuID = @AccountsReceivableReportParentMenuId
UPDATE tblSMMasterMenu SET strMenuName = 'Receive Multiple Payments', strDescription = 'Receive Multiple Payments' WHERE strMenuName = 'Receive Payment Details' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId
/* End of Removing Report in Reports - 1730 */

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Quote' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Quote', N'Accounts Receivable', @AccountsReceivableActivitiesParentMenuId, N'Quote', N'Activity', N'Screen', N'AccountsReceivable.view.Quote?showSearch=true&searchCommand=Quote', N'small-menu-activity', 1, 0, 0, 1, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 0, strCommand = N'AccountsReceivable.view.Quote?showSearch=true&searchCommand=Quote' WHERE strMenuName = 'Quote' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Sales Orders' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Sales Orders', N'Accounts Receivable', @AccountsReceivableActivitiesParentMenuId, N'Sales Orders', N'Activity', N'Screen', N'AccountsReceivable.view.SalesOrder?showSearch=true', N'small-menu-activity', 1, 0, 0, 1, 1, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 1, strCommand = N'AccountsReceivable.view.SalesOrder?showSearch=true' WHERE strMenuName = 'Sales Orders' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Invoices' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Invoices', N'Accounts Receivable', @AccountsReceivableActivitiesParentMenuId, N'Invoices', N'Activity', N'Screen', N'AccountsReceivable.view.Invoice?showSearch=true', N'small-menu-activity', 1, 0, 0, 1, 2, 1)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 2, strCommand = N'AccountsReceivable.view.Invoice?showSearch=true' WHERE strMenuName = 'Invoices' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Receive Payments' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Receive Payments', N'Accounts Receivable', @AccountsReceivableActivitiesParentMenuId, N'Receive Payments', N'Activity', N'Screen', N'AccountsReceivable.view.ReceivePaymentsDetail?showSearch=true', N'small-menu-activity', 1, 0, 0, 1, 3, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 3, strCommand = N'AccountsReceivable.view.ReceivePaymentsDetail?showSearch=true' WHERE strMenuName = 'Receive Payments' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Receive Multiple Payments' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Receive Multiple Payments', N'Accounts Receivable', @AccountsReceivableActivitiesParentMenuId, N'Receive Multiple Payments', N'Activity', N'Screen', N'AccountsReceivable.view.ReceivePayments', N'small-menu-activity', 1, 0, 0, 1, 4, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 4, strCommand = N'AccountsReceivable.view.ReceivePayments' WHERE strMenuName = 'Receive Multiple Payments' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Calculate Service Charge' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Calculate Service Charge', N'Accounts Receivable', @AccountsReceivableActivitiesParentMenuId, N'Calculate Service Charge', N'Activity', N'Screen', N'AccountsReceivable.view.CalculateServiceCharge', N'small-menu-activity', 1, 0, 0, 1, 5, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 5, strCommand = N'AccountsReceivable.view.CalculateServiceCharge' WHERE strMenuName = 'Calculate Service Charge' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Service Charge Invoice' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Service Charge Invoice', N'Accounts Receivable', @AccountsReceivableActivitiesParentMenuId, N'Service Charge Invoice', N'Activity', N'Screen', N'AccountsReceivable.view.ServiceChargeInvoice', N'small-menu-activity', 1, 0, 0, 1, 6, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 6, strCommand = N'AccountsReceivable.view.ServiceChargeInvoice' WHERE strMenuName = 'Service Charge Invoice' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Batch Posting' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Batch Posting', N'Accounts Receivable', @AccountsReceivableActivitiesParentMenuId, N'Batch Posting', N'Activity', N'Screen', N'AccountsReceivable.view.BatchPostingSearch?showSearch=true', N'small-menu-activity', 1, 0, 0, 1, 8, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 8, strCommand = N'AccountsReceivable.view.BatchPostingSearch?showSearch=true' WHERE strMenuName = 'Batch Posting' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Batch Printing' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Batch Printing', N'Accounts Receivable', @AccountsReceivableActivitiesParentMenuId, N'Batch Printing', N'Activity', N'Screen', N'AccountsReceivable.view.BatchPrinting', N'small-menu-activity', 1, 0, 0, 1, 9, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 9, strCommand = N'AccountsReceivable.view.BatchPrinting' WHERE strMenuName = 'Batch Printing' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Inquire Balance' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Inquire Balance', N'Accounts Receivable', @AccountsReceivableActivitiesParentMenuId, N'Inquire Balance', N'Activity', N'Screen', N'AccountsReceivable.view.CustomerInquiry?showSearch=true', N'small-menu-activity', 1, 0, 0, 1, 10, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 10, strCommand = N'AccountsReceivable.view.CustomerInquiry?showSearch=true' WHERE strMenuName = 'Inquire Balance' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId

-- IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Notes Receivables' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId)
-- 	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
-- 	VALUES (N'Notes Receivables', N'Accounts Receivable', @AccountsReceivableActivitiesParentMenuId, N'Notes Receivables', N'Activity', N'Screen', N'AccountsReceivable.view.NotesReceivable?showSearch=true', N'small-menu-activity', 1, 0, 0, 1, 11, 1)
-- ELSE 
-- 	UPDATE tblSMMasterMenu SET intSort = 11, strCommand = N'AccountsReceivable.view.NotesReceivable?showSearch=true' WHERE strMenuName = 'Notes Receivables' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId

-- IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Calculate Monthly Interest' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId)
-- 	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
-- 	VALUES (N'Calculate Monthly Interest', N'Accounts Receivable', @AccountsReceivableActivitiesParentMenuId, N'Calculate Monthly Interest', N'Activity', N'Screen', N'AccountsReceivable.view.NoteCalculateMonthlyInterest', N'small-menu-activity', 1, 0, 0, 1, 12, 1)
-- ELSE 
-- 	UPDATE tblSMMasterMenu SET intSort = 12, strCommand = N'AccountsReceivable.view.NoteCalculateMonthlyInterest' WHERE strMenuName = 'Calculate Monthly Interest' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Account Status Codes' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Account Status Codes', N'Accounts Receivable', @AccountsReceivableMaintenanceParentMenuId, N'Account Status Codes', N'Maintenance', N'Screen', N'AccountsReceivable.view.AccountStatusCodes?showSearch=true', N'small-menu-maintenance', 1, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 0, strCommand = N'AccountsReceivable.view.AccountStatusCodes?showSearch=true' WHERE strMenuName = 'Account Status Codes' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Customers' AND strModuleName = N'Accounts Receivable' AND intParentMenuID = @AccountsReceivableMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 1, strCommand = N'AccountsReceivable.view.EntityCustomer?showSearch=true' WHERE strMenuName = N'Customers' AND strModuleName = N'Accounts Receivable' AND intParentMenuID = @AccountsReceivableMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Customer Contact List' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 2, strCommand = N'EntityManagement.controller.CustomerContactList' WHERE strMenuName = 'Customer Contact List' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Customer Groups' AND strModuleName = N'Accounts Receivable' AND intParentMenuID = @AccountsReceivableMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 3, strCommand = N'EntityManagement.view.CustomerGroup?showSearch=true' WHERE strMenuName = N'Customer Groups' AND strModuleName = N'Accounts Receivable' AND intParentMenuID = @AccountsReceivableMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Intra-Communitarian Transaction(ICT)' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Intra-Communitarian Transaction(ICT)', N'Accounts Receivable', @AccountsReceivableMaintenanceParentMenuId, N'Intra-Communitarian Transaction', N'Maintenance', N'Screen', N'AccountsReceivable.view.ICT', N'small-menu-maintenance', 1, 0, 0, 1, 4, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 4, strCommand = N'AccountsReceivable.view.ICT' WHERE strMenuName = 'Intra-Communitarian Transaction(ICT)' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableMaintenanceParentMenuId

--IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Market Zone' AND strModuleName = N'Accounts Receivable' AND intParentMenuID = @AccountsReceivableMaintenanceParentMenuId)
--UPDATE tblSMMasterMenu SET intSort = 5, strCommand = N'AccountsReceivable.view.MarketZone' WHERE strMenuName = N'Market Zone' AND strModuleName = N'Accounts Receivable' AND intParentMenuID = @AccountsReceivableMaintenanceParentMenuId

-- IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Note Description' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableMaintenanceParentMenuId)
-- 	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
-- 	VALUES (N'Note Description', N'Accounts Receivable', @AccountsReceivableMaintenanceParentMenuId, N'Note Description', N'Maintenance', N'Screen', N'AccountsReceivable.view.NoteDescription', N'small-menu-maintenance', 1, 0, 0, 1, 5, 1)
-- ELSE 
-- 	UPDATE tblSMMasterMenu SET intSort = 5, strCommand = N'AccountsReceivable.view.NoteDescription' WHERE strMenuName = 'Note Description' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableMaintenanceParentMenuId

-- IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Note Adjustment Type' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableMaintenanceParentMenuId)
-- 	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
-- 	VALUES (N'Note Adjustment Type', N'Accounts Receivable', @AccountsReceivableMaintenanceParentMenuId, N'Note Adjustment Type', N'Maintenance', N'Screen', N'AccountsReceivable.view.NoteAdjustmentType', N'small-menu-maintenance', 1, 0, 0, 1, 6, 1)
-- ELSE 
-- 	UPDATE tblSMMasterMenu SET intSort = 6, strCommand = N'AccountsReceivable.view.NoteAdjustmentType' WHERE strMenuName = 'Note Adjustment Type' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Product Types' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Product Types', N'Accounts Receivable', @AccountsReceivableMaintenanceParentMenuId, N'Product Types', N'Maintenance', N'Screen', N'AccountsReceivable.view.ProductType?showSearch=true', N'small-menu-maintenance', 1, 0, 0, 1, 7, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 7, strCommand = N'AccountsReceivable.view.ProductType?showSearch=true' WHERE strMenuName = 'Product Types' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Quote Templates' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Quote Templates', N'Accounts Receivable', @AccountsReceivableMaintenanceParentMenuId, N'Quote Templates', N'Maintenance', N'Screen', N'AccountsReceivable.view.QuoteTemplate?showSearch=true', N'small-menu-maintenance', 1, 0, 0, 1, 8, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 8, strCommand = N'AccountsReceivable.view.QuoteTemplate?showSearch=true' WHERE strMenuName = 'Quote Templates' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableMaintenanceParentMenuId

--IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Sales Reps' AND strModuleName = N'Accounts Receivable' AND intParentMenuID = @AccountsReceivableMaintenanceParentMenuId)
--UPDATE tblSMMasterMenu SET intSort = 10, strCommand = N'AccountsReceivable.view.EntitySalesperson?showSearch=true' WHERE strMenuName = N'Sales Reps' AND strModuleName = N'Accounts Receivable' AND intParentMenuID = @AccountsReceivableMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Service Charges' AND strModuleName = N'Accounts Receivable' AND intParentMenuID = @AccountsReceivableMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 9, strCommand = N'AccountsReceivable.view.ServiceCharge?showSearch=true' WHERE strMenuName = N'Service Charges' AND strModuleName = N'Accounts Receivable' AND intParentMenuID = @AccountsReceivableMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Commissions' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableCommissionParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Commissions', N'Accounts Receivable', @AccountsReceivableCommissionParentMenuId, N'Commissions', N'Commission', N'Screen', N'AccountsReceivable.view.Commissions?showSearch=true', N'small-menu-commission', 1, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 0, strCommand = N'AccountsReceivable.view.Commissions?showSearch=true' WHERE strMenuName = 'Commissions' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableCommissionParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Commission Approval' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableCommissionParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Commission Approval', N'Accounts Receivable', @AccountsReceivableCommissionParentMenuId, N'Commission Approval', N'Commission', N'Screen', N'AccountsReceivable.view.CommissionApproval', N'small-menu-commission', 1, 0, 0, 1, 1, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 1, strCommand = N'AccountsReceivable.view.CommissionApproval' WHERE strMenuName = 'Commission Approval' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableCommissionParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Commission Plans' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableCommissionParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Commission Plans', N'Accounts Receivable', @AccountsReceivableCommissionParentMenuId, N'Commission Plans', N'Commission', N'Screen', N'AccountsReceivable.view.CommissionPlan?showSearch=true', N'small-menu-commission', 1, 0, 0, 1, 2, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 2, strCommand = N'AccountsReceivable.view.CommissionPlan?showSearch=true' WHERE strMenuName = 'Commission Plans' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableCommissionParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Commission Schedules' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableCommissionParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Commission Schedules', N'Accounts Receivable', @AccountsReceivableCommissionParentMenuId, N'Commission Schedules', N'Commission', N'Screen', N'AccountsReceivable.view.CommissionSchedule?showSearch=true', N'small-menu-commission', 1, 0, 0, 1, 3, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 3, strCommand = N'AccountsReceivable.view.CommissionSchedule?showSearch=true' WHERE strMenuName = 'Commission Schedules' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableCommissionParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Accrual Balance Reconciliation' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId])
	VALUES ( N'Accrual Balance Reconciliation', N'Accounts Receivable', @AccountsReceivableReportParentMenuId, N'Accrual Balance Reconciliation', N'Report', N'Screen', N'Reporting.view.ReportManager?group=Sales&report=AccrualBalanceReconciliation&direct=true', N'small-menu-report', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 0, strCommand = N'Reporting.view.ReportManager?group=Sales&report=AccrualBalanceReconciliation&direct=true' WHERE strMenuName = 'Accrual Balance Reconciliation' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Address Label' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId])
	VALUES ( N'Address Label', N'Accounts Receivable', @AccountsReceivableReportParentMenuId, N'Address Label', N'Report', N'Screen', N'Reporting.view.ReportManager?group=Sales&report=AddressLabel&direct=true', N'small-menu-report', 0, 0, 0, 1, 1, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 1, strCommand = N'Reporting.view.ReportManager?group=Sales&report=AddressLabel&direct=true' WHERE strMenuName = 'Address Label' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Customer Activity' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId])
	VALUES ( N'Customer Activity', N'Accounts Receivable', @AccountsReceivableReportParentMenuId, N'Customer Activity', N'Report', N'Screen', N'Reporting.view.ReportManager?group=Sales&report=CustomerActivity&direct=true', N'small-menu-report', 0, 0, 0, 1, 2, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 2, strCommand = N'Reporting.view.ReportManager?group=Sales&report=CustomerActivity&direct=true' WHERE strMenuName = 'Customer Activity' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Customer Aging Detail' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId])
	VALUES ( N'Customer Aging Detail', N'Accounts Receivable', @AccountsReceivableReportParentMenuId, N'Customer Aging Detail', N'Report', N'Screen', N'Reporting.view.ReportManager?group=Sales&report=CustomerAgingDetail&direct=true', N'small-menu-report', 0, 0, 0, 1, 3, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 3, strCommand = N'Reporting.view.ReportManager?group=Sales&report=CustomerAgingDetail&direct=true' WHERE strMenuName = 'Customer Aging Detail' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Customer Aging' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableReportParentMenuId)	
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES ( N'Customer Aging', N'Accounts Receivable', @AccountsReceivableReportParentMenuId, N'Customer Aging', N'Report', N'Screen', N'Reporting.view.ReportManager?group=Sales&report=CustomerAging&direct=true', N'small-menu-report', 0, 0, 0, 1, 4, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 4, strType = 'Screen', strCommand = N'Reporting.view.ReportManager?group=Sales&report=CustomerAging&direct=true' WHERE strMenuName = 'Customer Aging' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableReportParentMenuId	

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Customer Inquiry' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId])
	VALUES ( N'Customer Inquiry', N'Accounts Receivable', @AccountsReceivableReportParentMenuId, N'Customer Inquiry', N'Report', N'Screen', N'Reporting.view.ReportManager?group=Sales&report=CustomerInquiry&direct=true', N'small-menu-report', 0, 0, 0, 1, 5, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 5, strType = 'Screen', strCommand = N'Reporting.view.ReportManager?group=Sales&report=CustomerInquiry&direct=true' WHERE strMenuName = 'Customer Inquiry' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableReportParentMenuId	

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Customer Statements Detail' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId])
	VALUES ( N'Customer Statements Detail', N'Accounts Receivable', @AccountsReceivableReportParentMenuId, N'Customer Statements Detail', N'Report', N'Screen', N'Reporting.view.ReportManager?group=Sales&report=CustomerStatementDetail&direct=true', N'small-menu-report', 0, 0, 0, 1, 6, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 6, strType = 'Screen', strCommand = N'Reporting.view.ReportManager?group=Sales&report=CustomerStatementDetail&direct=true' WHERE strMenuName = 'Customer Statements Detail' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Customer Statements' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId])
	VALUES ( N'Customer Statements', N'Accounts Receivable', @AccountsReceivableReportParentMenuId, N'Customer Statements', N'Report', N'Screen', N'Reporting.view.ReportManager?group=Sales&report=StatementOfAccount&direct=true', N'small-menu-report', 0, 0, 0, 1, 7, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 7, strType = 'Screen', strCommand = N'Reporting.view.ReportManager?group=Sales&report=StatementOfAccount&direct=true' WHERE strMenuName = 'Customer Statements' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Inventory by Unit of Measure' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId])
	VALUES ( N'Inventory by Unit of Measure', N'Accounts Receivable', @AccountsReceivableReportParentMenuId, N'Inventory by Unit of Measure', N'Report', N'Screen', N'Reporting.view.ReportManager?group=Sales&report=InventoryUOM&direct=true', N'small-menu-report', 0, 0, 0, 1, 8, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 8, strType = 'Screen', strCommand = N'Reporting.view.ReportManager?group=Sales&report=InventoryUOM&direct=true' WHERE strMenuName = 'Inventory by Unit of Measure' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Inventory by Unit of Measure Detail' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId])
	VALUES ( N'Inventory by Unit of Measure Detail', N'Accounts Receivable', @AccountsReceivableReportParentMenuId, N'Inventory by Unit of Measure Detail', N'Report', N'Screen', N'Reporting.view.ReportManager?group=Sales&report=InventoryUOMDetail&direct=true', N'small-menu-report', 0, 0, 0, 1, 9, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 9, strType = 'Screen', strCommand = N'Reporting.view.ReportManager?group=Sales&report=InventoryUOMDetail&direct=true' WHERE strMenuName = 'Inventory by Unit of Measure Detail' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Invoice History' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId])
	VALUES ( N'Invoice History', N'Accounts Receivable', @AccountsReceivableReportParentMenuId, N'Invoice History', N'Report', N'Screen', N'Reporting.view.ReportManager?group=Sales&report=InvoiceHistory&direct=true', N'small-menu-report', 0, 0, 0, 1, 10, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 10, strType = 'Screen', strCommand = N'Reporting.view.ReportManager?group=Sales&report=InvoiceHistory&direct=true' WHERE strMenuName = 'Invoice History' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Outbound Tax' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId])
	VALUES ( N'Outbound Tax', N'Accounts Receivable', @AccountsReceivableReportParentMenuId, N'Outbound Tax', N'Report', N'Screen', N'Reporting.view.ReportManager?group=Sales&report=OutboundTax&direct=true', N'small-menu-report', 0, 0, 0, 1, 11, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 11, strType = 'Screen', strCommand = N'Reporting.view.ReportManager?group=Sales&report=OutboundTax&direct=true' WHERE strMenuName = 'Outbound Tax' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Payment History' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId])
	VALUES ( N'Payment History', N'Accounts Receivable', @AccountsReceivableReportParentMenuId, N'Payment History', N'Report', N'Screen', N'Reporting.view.ReportManager?group=Sales&report=PaymentHistory&direct=true', N'small-menu-report', 0, 0, 0, 1, 12, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 12, strType = 'Screen', strCommand = N'Reporting.view.ReportManager?group=Sales&report=PaymentHistory&direct=true' WHERE strMenuName = 'Payment History' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Restricted Chemicals' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId])
	VALUES ( N'Restricted Chemicals', N'Accounts Receivable', @AccountsReceivableReportParentMenuId, N'Restricted Chemicals', N'Report', N'Screen', N'Reporting.view.ReportManager?group=Sales&report=RestrictedChemical&direct=true', N'small-menu-report', 0, 0, 0, 1, 13, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 13, strCommand = N'Reporting.view.ReportManager?group=Sales&report=RestrictedChemical&direct=true' WHERE strMenuName = 'Restricted Chemicals' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Sales Analysis Reports' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId])
	VALUES ( N'Sales Analysis Reports', N'Accounts Receivable', @AccountsReceivableReportParentMenuId, N'Sales Analysis Reports', N'Report', N'Screen', N'AccountsReceivable.view.SalesAnalysisReport?showSearch=true', N'small-menu-report', 0, 0, 0, 1, 14, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 14, strType = N'Screen', strCommand = N'AccountsReceivable.view.SalesAnalysisReport?showSearch=true', strCategory = N'Report', strIcon = 'small-menu-report' WHERE strMenuName = 'Sales Analysis Reports' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Sales Comparative Report' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId])
	VALUES ( N'Sales Comparative Report', N'Accounts Receivable', @AccountsReceivableReportParentMenuId, N'Sales Comparative Report', N'Report', N'Screen', N'Reporting.view.ReportManager?group=Sales&report=SalesComparativeReport&direct=true', N'small-menu-report', 0, 0, 0, 1, 15, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 15, strType = N'Screen', strCommand = N'Reporting.view.ReportManager?group=Sales&report=SalesComparativeReport&direct=true', strCategory = N'Report', strIcon = 'small-menu-report' WHERE strMenuName = 'Sales Comparative Report' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Sales Trend Report' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId])
	VALUES ( N'Sales Trend Report', N'Accounts Receivable', @AccountsReceivableReportParentMenuId, N'Sales Trend Report', N'Report', N'Screen', N'Reporting.view.ReportManager?group=Sales&report=SalesTrendComparativeReport&direct=true', N'small-menu-report', 0, 0, 0, 1, 16, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 16, strType = N'Screen', strCommand = N'Reporting.view.ReportManager?group=Sales&report=SalesTrendComparativeReport&direct=true' WHERE strMenuName = 'Sales Trend Report' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Tax' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId])
	VALUES ( N'Tax', N'Accounts Receivable', @AccountsReceivableReportParentMenuId, N'Tax', N'Report', N'Screen', N'Reporting.view.ReportManager?group=Sales&report=TaxReport&direct=true', N'small-menu-report', 0, 0, 0, 1, 17, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 17, strCommand = N'Reporting.view.ReportManager?group=Sales&report=TaxReport&direct=true' WHERE strMenuName = 'Tax' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Tax Report Grid' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableReportParentMenuId)	
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES ( N'Tax Report Grid', N'Accounts Receivable', @AccountsReceivableReportParentMenuId, N'Tax Report Grid', N'Report', N'Screen', N'AccountsReceivable.view.TaxReport?showSearch=true', N'small-menu-report', 0, 0, 0, 1, 18, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 18, strType = N'Screen', strCommand = N'AccountsReceivable.view.TaxReport?showSearch=true', strCategory = N'Report', strIcon = 'small-menu-report' WHERE strMenuName = 'Tax Report Grid' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableReportParentMenuId	

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Unapplied Credits Register' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId])
	VALUES ( N'Unapplied Credits Register', N'Accounts Receivable', @AccountsReceivableReportParentMenuId, N'Unapplied Credits Register', N'Report', N'Screen', N'Reporting.view.ReportManager?group=Sales&report=UnappliedCreditsRegister&direct=true', N'small-menu-report', 0, 0, 0, 1, 19, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 19, strType = 'Screen', strCommand = N'Reporting.view.ReportManager?group=Sales&report=UnappliedCreditsRegister&direct=true' WHERE strMenuName = 'Unapplied Credits Register' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'New Quote' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableCreateParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'New Quote', N'Accounts Receivable', @AccountsReceivableCreateParentMenuId, N'New Quote', N'Create', N'Screen', N'AccountsReceivable.view.SalesOrder?action=new&strType=Quote', N'small-menu-create', 1, 0, 0, 1, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 0, strCommand = N'AccountsReceivable.view.SalesOrder?action=new&strType=Quote' WHERE strMenuName = 'New Quote' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableCreateParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'New Sales Order' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableCreateParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'New Sales Order', N'Accounts Receivable', @AccountsReceivableCreateParentMenuId, N'New Sales Order', N'Create', N'Screen', N'AccountsReceivable.view.SalesOrder?action=new', N'small-menu-create', 1, 0, 0, 1, 1, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 1, strCommand = N'AccountsReceivable.view.SalesOrder?action=new' WHERE strMenuName = 'New Sales Order' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableCreateParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'New Invoice' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableCreateParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'New Invoice', N'Accounts Receivable', @AccountsReceivableCreateParentMenuId, N'New Invoice', N'Create', N'Screen', N'AccountsReceivable.view.Invoice?action=new', N'small-menu-create', 1, 0, 0, 1, 2, 1)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 2, strCommand = N'AccountsReceivable.view.Invoice?action=new' WHERE strMenuName = 'New Invoice' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableCreateParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'New Receive Payment' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableCreateParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'New Receive Payment', N'Accounts Receivable', @AccountsReceivableCreateParentMenuId, N'New Receive Payment', N'Create', N'Screen', N'AccountsReceivable.view.ReceivePaymentsDetail?action=new', N'small-menu-create', 1, 0, 0, 1, 3, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 3, strCommand = N'AccountsReceivable.view.ReceivePaymentsDetail?action=new' WHERE strMenuName = 'New Receive Payment' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableCreateParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'New Customer' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableCreateParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'New Customer', N'Accounts Receivable', @AccountsReceivableCreateParentMenuId, N'New Customer', N'Create', N'Screen', N'AccountsReceivable.view.EntityCustomer?action=new', N'small-menu-create', 1, 0, 0, 1, 4, 1)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 4, strCommand = N'AccountsReceivable.view.EntityCustomer?action=new' WHERE strMenuName = 'New Customer' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableCreateParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'POS Login' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivablePOSParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'POS Login', N'Accounts Receivable', @AccountsReceivablePOSParentMenuId, N'POS Login', N'Point of Sale', N'Screen', N'AccountsReceivable.view.PointOfSaleLogin', N'small-menu-pos', 1, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 0, strCommand = N'AccountsReceivable.view.PointOfSaleLogin' WHERE strMenuName = 'POS Login' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivablePOSParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'POS End Of Day' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivablePOSParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId])
	VALUES ( N'POS End Of Day', N'Accounts Receivable', @AccountsReceivablePOSParentMenuId, N'POS End Of Day', N'Point of Sale', N'Screen', N'AccountsReceivable.view.PointOfSaleEndOfDayReport', N'small-menu-pos', 0, 0, 0, 1, 1, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 1, strCommand = N'AccountsReceivable.view.PointOfSaleEndOfDayReport' WHERE strMenuName = 'POS End Of Day' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivablePOSParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Import Billable from Help Desk' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableImportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Import Billable from Help Desk', N'Accounts Receivable', @AccountsReceivableImportParentMenuId, N'Import Billable from Help Desk', N'Import', N'Screen', N'AccountsReceivable.view.ImportBillable', N'small-menu-import', 1, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 0, strCommand = N'AccountsReceivable.view.ImportBillable' WHERE strMenuName = 'Import Billable from Help Desk' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableImportParentMenuId
		
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Import Invoices from Origin' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableImportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Import Invoices from Origin', N'Accounts Receivable', @AccountsReceivableImportParentMenuId, N'Import Invoices from Origin', N'Import', N'Screen', N'AccountsReceivable.view.ImportInvoices', N'small-menu-import', 1, 0, 0, 1, 1, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 1, strCommand = N'AccountsReceivable.view.ImportInvoices' WHERE strMenuName = 'Import Invoices from Origin' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableImportParentMenuId
	
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Import Logs' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableImportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Import Logs', N'Accounts Receivable', @AccountsReceivableImportParentMenuId, N'Import Logs', N'Import', N'Screen', N'AccountsReceivable.view.ImportLog?showSearch=true', N'small-menu-import', 1, 0, 0, 1, 2, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 2, strCommand = N'AccountsReceivable.view.ImportLog?showSearch=true' WHERE strMenuName = 'Import Logs' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableImportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Import Transactions from CSV' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableImportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Import Transactions from CSV', N'Accounts Receivable', @AccountsReceivableImportParentMenuId, N'Import Transactions from CSV', N'Import', N'Screen', N'AccountsReceivable.view.ImportTransactionsCSV', N'small-menu-import', 1, 0, 0, 1, 3, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 3, strCommand = N'AccountsReceivable.view.ImportTransactionsCSV' WHERE strMenuName = 'Import Transactions from CSV' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableImportParentMenuId

/* START OF DELETING */
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Credit Memos' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Bundles' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Customer Aging Report' AND strModuleName = 'Accounts Receivable' AND strCategory = 'Report' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Customer Inquiry Report' AND strModuleName = 'Accounts Receivable' AND strCategory = 'Report' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Customer Statements Report' AND strModuleName = 'Accounts Receivable' AND strCategory = 'Report' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Payment History Report' AND strModuleName = 'Accounts Receivable' AND strCategory = 'Report' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Unapplied Credits Register Report' AND strModuleName = 'Accounts Receivable' AND strCategory = 'Report' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Customer Statements Detail Report' AND strModuleName = 'Accounts Receivable' AND strCategory = 'Report' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Invoice History Report' AND strModuleName = 'Accounts Receivable' AND strCategory = 'Report' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Tax Report' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Quotes' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Customer Aging Detail Report' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Comment Maintenance' AND strModuleName = N'Accounts Receivable' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'POS End Of Day' AND strModuleName = N'Accounts Receivable' AND intParentMenuID = @AccountsReceivableReportParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Customer' AND strModuleName = N'Accounts Receivable' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Make Payments' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Quote Page Builder' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Notes Receivables' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Note Adjustment Type' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Note Description' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Calculate Monthly Interest' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Comment Maintenance' AND strModuleName = N'Accounts Receivable' AND intParentMenuID = @AccountsReceivableMaintenanceParentMenuId

/* END OF DELETING */

/* PAYROLL */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Payroll' AND strModuleName = 'Payroll' AND intParentMenuID = 0)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Payroll', N'Payroll', 0, N'Payroll', NULL, N'Folder', N'', N'small-folder', 1, 1, 0, 0, 11, 0)
ELSE
	UPDATE tblSMMasterMenu SET  intSort = 11 WHERE strMenuName = 'Payroll' AND strModuleName = 'Payroll' AND intParentMenuID = 0

DECLARE @PayrollParentMenuId INT
SELECT @PayrollParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Payroll' AND strModuleName = 'Payroll' AND intParentMenuID = 0

/* CHANGE SCREEN CATEGORY 1730 TO 1810 */
UPDATE tblSMMasterMenu SET strCategory = 'Activity', strIcon = 'small-menu-activity' WHERE strMenuName IN ('Time Off Requests', 'Process Pay Groups', 'Paychecks', 'Batch Posting', 'Process Paychecks', 'Create Payables') AND strModuleName = N'Payroll'
UPDATE tblSMMasterMenu SET strCategory = 'Time Entry', strIcon = 'small-menu-time-entry' WHERE strMenuName IN ('Timecards', 'Timecard Approval', 'Timecard History') AND strModuleName = N'Payroll'
UPDATE tblSMMasterMenu SET strCategory = 'Maintenance', strIcon = 'small-menu-maintenance' WHERE strMenuName IN ('Employees', 'Employee Templates', 'Employee Pay Groups', 'Employee Departments', 'Workers Compensation Codes', 'Tax Types', 'Earning Types', 'Deduction Types', 'Employee Ranks', 'Time Off Types') AND strModuleName = N'Payroll'
UPDATE tblSMMasterMenu SET strCategory = 'Report', strIcon = 'small-menu-report' WHERE strMenuName IN ('Employee Earnings Register', 'Origin Data', 'Quarterly FUI', 'Quarterly SUI', 'Quarterly State Tax', 'Earnings History', 'Earnings History By Department', 'Employee Earnings History', 'Form 941', 'Process W-2', 'Workers Compensation') AND strModuleName = N'Payroll'
UPDATE tblSMMasterMenu SET strCategory = 'Utility', strIcon = 'small-menu-utility' WHERE strMenuName IN ('Paycheck Calculator') AND strModuleName = N'Payroll'
/* CATEGORY FOLDERS */

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Activities' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intRow], [intConcurrencyId]) 
	VALUES (N'Activities', N'Payroll', @PayrollParentMenuId, N'Activities', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 0, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 0, intRow = 0 WHERE strMenuName = 'Activities' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollParentMenuId

DECLARE @PayrollActivitiesParentMenuId INT
SELECT @PayrollActivitiesParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Activities' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Time Entry' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intRow], [intConcurrencyId]) 
	VALUES (N'Time Entry', N'Payroll', @PayrollParentMenuId, N'Time Entry', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 1, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 1, intRow = 0 WHERE strMenuName = 'Time Entry' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollParentMenuId

DECLARE @PayrollTimeEntryParentMenuId INT
SELECT @PayrollTimeEntryParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Time Entry' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intRow], [intConcurrencyId]) 
	VALUES (N'Maintenance', N'Payroll', @PayrollParentMenuId, N'Maintenance', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 2, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 2, intRow = 0 WHERE strMenuName = 'Maintenance' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollParentMenuId

DECLARE @PayrollMaintenanceParentMenuId INT
SELECT @PayrollMaintenanceParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Reports' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intRow], [intConcurrencyId]) 
    VALUES (N'Reports', N'Payroll', @PayrollParentMenuId, N'Reports', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 3, 0, 1)
ELSE
    UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 3, intRow = 0 WHERE strMenuName = 'Reports' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollParentMenuId

DECLARE @PayrollReportParentMenuId INT
SELECT @PayrollReportParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Reports' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Utilities' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intRow], [intConcurrencyId]) 
	VALUES (N'Utilities', N'Payroll', @PayrollParentMenuId, N'Utilities', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 0, 1, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 0, intRow = 1 WHERE strMenuName = 'Utilities' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollParentMenuId

DECLARE @PayrollUtilitiesParentMenuId INT
SELECT @PayrollUtilitiesParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Utilities' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollParentMenuId

/* ADD TO RESPECTIVE CATEGORY */ 
UPDATE tblSMMasterMenu SET intParentMenuID = @PayrollActivitiesParentMenuId WHERE intParentMenuID =  @PayrollParentMenuId AND strCategory = 'Activity'
UPDATE tblSMMasterMenu SET intParentMenuID = @PayrollTimeEntryParentMenuId WHERE intParentMenuID =  @PayrollParentMenuId AND strCategory = 'Time Entry'
UPDATE tblSMMasterMenu SET intParentMenuID = @PayrollMaintenanceParentMenuId WHERE intParentMenuID =  @PayrollParentMenuId AND strCategory = 'Maintenance'
UPDATE tblSMMasterMenu SET intParentMenuID = @PayrollReportParentMenuId WHERE intParentMenuID =  @PayrollParentMenuId AND strCategory = 'Report'
UPDATE tblSMMasterMenu SET intParentMenuID = @PayrollUtilitiesParentMenuId WHERE intParentMenuID =  @PayrollParentMenuId AND strCategory = 'Utility'

/* START OF PLURALIZING */
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Timecard' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollActivitiesParentMenuId)
UPDATE tblSMMasterMenu SET  strMenuName = 'Timecards', strDescription = 'Timecards' WHERE strMenuName = 'Timecard' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollActivitiesParentMenuId
/* END OF PLURALIZING */

/* START OF RENAMING  */
UPDATE tblSMMasterMenu SET  strMenuName = 'Process Paychecks', strDescription = 'Process Paychecks' WHERE strMenuName = 'Print Checks' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollActivitiesParentMenuId
UPDATE tblSMMasterMenu SET strMenuName = 'Timecard Approval', strDescription = 'Timecard Approval' WHERE strMenuName = 'Time Approval' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollActivitiesParentMenuId
UPDATE tblSMMasterMenu SET strMenuName = 'Timecard History', strDescription = 'Timecard History' WHERE strMenuName = 'Time History' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollActivitiesParentMenuId
UPDATE tblSMMasterMenu SET strMenuName = 'Templates', strDescription = 'Timecard History' WHERE strMenuName = 'Employee Templates' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollMaintenanceParentMenuId
UPDATE tblSMMasterMenu SET strMenuName = 'Pay Groups', strDescription = 'Pay Groups' WHERE strMenuName = 'Employee Pay Groups' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollMaintenanceParentMenuId
UPDATE tblSMMasterMenu SET strMenuName = 'Departments', strDescription = 'Departments' WHERE strMenuName = 'Employee Departments' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollMaintenanceParentMenuId
UPDATE tblSMMasterMenu SET strMenuName = 'Earnings Register', strDescription = 'Earnings Register' WHERE strMenuName = 'Employee Earnings Register' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollReportParentMenuId
UPDATE tblSMMasterMenu SET strMenuName = 'Quarterly State', strDescription = 'Quarterly State' WHERE strMenuName = 'Quarterly State Tax' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollReportParentMenuId
UPDATE tblSMMasterMenu SET strMenuName = 'Workers Comp Codes', strDescription = 'Workers Comp Codes' WHERE strMenuName = 'Workers Compensation Codes' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollMaintenanceParentMenuId
UPDATE tblSMMasterMenu SET strMenuName = 'Workers Comp', strDescription = 'Workers Comp' WHERE strMenuName = 'Workers Compensation' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollReportParentMenuId
UPDATE tblSMMasterMenu SET strMenuName = 'Earnings History By Employee', strDescription = 'Earnings History By Employee' WHERE strMenuName = 'Employee Earnings History' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollReportParentMenuId
/* END OF RENAMING  */

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Time Off Requests' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Time Off Requests', N'Payroll', @PayrollActivitiesParentMenuId, N'Time Off Requests', N'Activity', N'Screen', N'Payroll.view.TimeOffRequest?showSearch=true&searchCommand=TimeOffRequest', N'small-menu-activity', 1, 1, 0, 1, 0, 0)
ELSE 
	UPDATE tblSMMasterMenu SET  intSort = 0, strCommand = N'Payroll.view.TimeOffRequest?showSearch=true&searchCommand=TimeOffRequest' WHERE strMenuName = 'Time Off Requests' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Process Pay Groups' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Process Pay Groups', N'Payroll', @PayrollActivitiesParentMenuId, N'Process Pay Groups', N'Activity', N'Screen', N'Payroll.view.ProcessPayGroup', N'small-menu-activity', 1, 1, 0, 1, 1, 0)
ELSE 
	UPDATE tblSMMasterMenu SET  intSort = 1, strCommand = N'Payroll.view.ProcessPayGroup' WHERE strMenuName = 'Process Pay Groups' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Paychecks' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Paychecks', N'Payroll', @PayrollActivitiesParentMenuId, N'Paychecks', N'Activity', N'Screen', N'Payroll.view.Paycheck?showSearch=true&searchCommand=Paycheck', N'small-menu-activity', 1, 1, 0, 1, 2, 0)
ELSE 
	UPDATE tblSMMasterMenu SET  intSort = 2, strCommand = N'Payroll.view.Paycheck?showSearch=true&searchCommand=Paycheck' WHERE strMenuName = 'Paychecks' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Batch Posting' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Batch Posting', N'Payroll', @PayrollActivitiesParentMenuId, N'Batch Posting', N'Activity', N'Screen', N'Payroll.view.BatchPosting', N'small-menu-activity', 1, 1, 0, 1, 3, 0)
ELSE 
	UPDATE tblSMMasterMenu SET  intSort = 3, strCommand = N'Payroll.view.BatchPosting' WHERE strMenuName = 'Batch Posting' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Process Paychecks' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Process Paychecks', N'Payroll', @PayrollActivitiesParentMenuId, N'Process Paychecks', N'Activity', N'Screen', N'Payroll.controller.PrintChecks', N'small-menu-activity', 1, 1, 0, 1, 4, 0)
ELSE 
	UPDATE tblSMMasterMenu SET  intSort = 4, strCommand = N'Payroll.controller.PrintChecks' WHERE strMenuName = 'Process Paychecks' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Create Payables' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Create Payables', N'Payroll', @PayrollActivitiesParentMenuId, N'Create Payables', N'Activity', N'Screen', N'Payroll.view.CreatePayable', N'small-menu-activity', 1, 1, 0, 1, 5, 0)
ELSE 
	UPDATE tblSMMasterMenu SET  intSort = 5, strCommand = N'Payroll.view.CreatePayable' WHERE strMenuName = 'Create Payables' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Timecards' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollTimeEntryParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Timecards', N'Payroll', @PayrollTimeEntryParentMenuId, N'Timecards', N'Time Entry', N'Screen', N'Payroll.view.Timecard', N'small-menu-time-entry', 1, 1, 0, 1, 0, 0)
ELSE 
	UPDATE tblSMMasterMenu SET  intSort = 0, strCommand = N'Payroll.view.Timecard' WHERE strMenuName = 'Timecards' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollTimeEntryParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Timecard Approval' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollTimeEntryParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Timecard Approval', N'Payroll', @PayrollTimeEntryParentMenuId, N'Timecard Approval', N'Time Entry', N'Screen', N'Payroll.view.TimeApproval', N'small-menu-time-entry', 1, 1, 0, 1, 1, 0)
ELSE 
	UPDATE tblSMMasterMenu SET  intSort = 1, strCommand = N'Payroll.view.TimeApproval' WHERE strMenuName = 'Timecard Approval' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollTimeEntryParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Timecard History' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollTimeEntryParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Timecard History', N'Payroll', @PayrollTimeEntryParentMenuId, N'Timecard History', N'Time Entry', N'Screen', N'Payroll.view.TimeHistory?showSearch=true&searchCommand=TimeHistory', N'small-menu-time-entry', 1, 1, 0, 1, 2, 0)
ELSE 
	UPDATE tblSMMasterMenu SET  intSort = 2, strCommand = N'Payroll.view.TimeHistory?showSearch=true&searchCommand=TimeHistory' WHERE strMenuName = 'Timecard History' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollTimeEntryParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Deduction Types' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Deduction Types', N'Payroll', @PayrollMaintenanceParentMenuId, N'Deduction Types', N'Maintenance', N'Screen', N'Payroll.view.DeductionType?showSearch=true&searchCommand=DeductionType', N'small-menu-maintenance', 1, 1, 0, 1, 0, 0)
ELSE 
	UPDATE tblSMMasterMenu SET  intSort = 0, strCommand = N'Payroll.view.DeductionType?showSearch=true&searchCommand=DeductionType' WHERE strMenuName = 'Deduction Types' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Departments' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Departments', N'Payroll', @PayrollMaintenanceParentMenuId, N'Departments', N'Maintenance', N'Screen', N'Payroll.view.EmployeeDepartment?showSearch=true&searchCommand=EmployeeDepartment', N'small-menu-maintenance', 1, 1, 0, 1, 1, 0)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 1, strCommand = N'Payroll.view.EmployeeDepartment?showSearch=true&searchCommand=EmployeeDepartment' WHERE strMenuName = 'Departments' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Earning Types' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Earning Types', N'Payroll', @PayrollMaintenanceParentMenuId, N'Earning Types', N'Payroll Type', N'Screen', N'Payroll.view.EarningType?showSearch=true&searchCommand=EarningType', N'small-menu-maintenance', 1, 1, 0, 1, 2, 0)
ELSE 
	UPDATE tblSMMasterMenu SET  intSort = 2, strCommand = N'Payroll.view.EarningType?showSearch=true&searchCommand=EarningType' WHERE strMenuName = 'Earning Types' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Employees' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Employees', N'Payroll', @PayrollMaintenanceParentMenuId, N'Employees', N'Maintenance', N'Screen', N'Payroll.view.EntityEmployee?showSearch=true', N'small-menu-maintenance', 1, 1, 0, 1, 3, 0)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 3, strCommand = N'Payroll.view.EntityEmployee?showSearch=true' WHERE strMenuName = 'Employees' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Pay Groups' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Pay Groups', N'Payroll', @PayrollMaintenanceParentMenuId, N'Pay Groups', N'Maintenance', N'Screen', N'Payroll.view.EmployeePayGroup', N'small-menu-maintenance', 1, 1, 0, 1, 4, 0)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 4, strCommand = N'Payroll.view.EmployeePayGroup' WHERE strMenuName = 'Pay Groups' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Ranks' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Ranks', N'Payroll', @PayrollMaintenanceParentMenuId, N'Ranks', N'Maintenance', N'Screen', N'Payroll.view.EmployeeRank', N'small-menu-maintenance', 1, 1, 0, 1, 5, 0)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 5, strCommand = N'Payroll.view.EmployeeRank' WHERE strMenuName = 'Ranks' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Tax Types' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Tax Types', N'Payroll', @PayrollMaintenanceParentMenuId, N'Tax Types', N'Maintenance', N'Screen', N'Payroll.view.TaxType?showSearch=true&searchCommand=TaxType', N'small-menu-maintenance', 1, 1, 0, 1, 6, 0)
ELSE 
	UPDATE tblSMMasterMenu SET  intSort = 6, strCommand = N'Payroll.view.TaxType?showSearch=true&searchCommand=TaxType' WHERE strMenuName = 'Tax Types' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Templates' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Templates', N'Payroll', @PayrollMaintenanceParentMenuId, N'Templates', N'Maintenance', N'Screen', N'Payroll.view.EmployeeTemplate?showSearch=true&searchCommand=EmployeeTemplate', N'small-menu-maintenance', 1, 1, 0, 1, 7, 0)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 7, strCommand = N'Payroll.view.EmployeeTemplate?showSearch=true&searchCommand=EmployeeTemplate' WHERE strMenuName = 'Templates' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Time Off Types' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Time Off Types', N'Payroll', @PayrollMaintenanceParentMenuId, N'Time Off Types', N'Maintenance', N'Screen', N'Payroll.view.TimeOffType?showSearch=true&searchCommand=TimeOffType', N'small-menu-maintenance', 1, 1, 0, 1, 8, 0)
ELSE 
	UPDATE tblSMMasterMenu SET  intSort = 8, strCommand = N'Payroll.view.TimeOffType?showSearch=true&searchCommand=TimeOffType' WHERE strMenuName = 'Time Off Types' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Workers Comp Codes' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Workers Comp Codes', N'Payroll', @PayrollMaintenanceParentMenuId, N'Workers Comp Codes', N'Maintenance', N'Screen', N'Payroll.view.WorkersCompensationCodes', N'small-menu-maintenance', 1, 1, 0, 1, 9, 0)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 9, strCommand = N'Payroll.view.WorkersCompensationCodes' WHERE strMenuName = 'Workers Comp Codes' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Earnings History' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Earnings History', N'Payroll', @PayrollReportParentMenuId, N'Earnings History', N'Report', N'Screen', N'Reporting.view.ReportManager?group=Payroll&report=EarningsHistory&direct=true', N'small-menu-report', 1, 0, 0, 1, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 0, strCommand = 'Reporting.view.ReportManager?group=Payroll&report=EarningsHistory&direct=true' WHERE strMenuName = 'Earnings History' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Earnings History By Department' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Earnings History By Department', N'Payroll', @PayrollReportParentMenuId, N'Earnings History By Department', N'Report', N'Screen', N'Reporting.view.ReportManager?group=Payroll&report=EarningsHistoryByDepartment&direct=true', N'small-menu-report', 1, 0, 0, 1, 1, 1)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 1, strCommand = 'Reporting.view.ReportManager?group=Payroll&report=EarningsHistoryByDepartment&direct=true' WHERE strMenuName = 'Earnings History By Department' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Earnings History By Employee' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Earnings History By Employee', N'Payroll', @PayrollReportParentMenuId, N'Earnings History By Employee', N'Report', N'Screen', N'Reporting.view.ReportManager?group=Payroll&report=EmployeeEarningsHistory&direct=true', N'small-menu-report', 1, 0, 0, 1, 2, 1)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 2, strCommand = 'Reporting.view.ReportManager?group=Payroll&report=EmployeeEarningsHistory&direct=true' WHERE strMenuName = 'Earnings History By Employee' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Earnings Register' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Earnings Register', N'Payroll', @PayrollReportParentMenuId, N'Earnings Register', N'Report', N'Screen', N'Reporting.view.ReportManager?group=Payroll&report=EmployeeEarningRegister&direct=true', N'small-menu-report', 1, 0, 0, 1, 3, 1)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 3, strCommand = 'Reporting.view.ReportManager?group=Payroll&report=EmployeeEarningRegister&direct=true' WHERE strMenuName = 'Earnings Register' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Electronic Filing SUI' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Electronic Filing SUI', N'Payroll', @PayrollReportParentMenuId, N'Electronic Filing SUI', N'Report', N'Screen', N'Payroll.view.ElectronicFilingSUI', N'small-menu-report', 1, 0, 0, 1, 4, 1)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 4, strCommand = 'Payroll.view.ElectronicFilingSUI' WHERE strMenuName = 'Electronic Filing SUI' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Form 941' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Form 941', N'Payroll', @PayrollReportParentMenuId, N'Form 941', N'Report', N'Screen', N'Payroll.view.Form941', N'small-menu-report', 1, 0, 0, 1, 5, 1)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 5, strCommand = 'Payroll.view.Form941' WHERE strMenuName = 'Form 941' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Origin Data' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Origin Data', N'Payroll', @PayrollReportParentMenuId, N'Origin Data', N'Report', N'Screen', N'Payroll.view.OriginData?showSearch=true&searchCommand=OriginData', N'small-menu-report', 1, 1, 0, 1, 6, 0)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 6, strCommand = N'Payroll.view.OriginData?showSearch=true&searchCommand=OriginData' WHERE strMenuName = 'Origin Data' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Process W-2' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Process W-2', N'Payroll', @PayrollReportParentMenuId, N'Process W-2', N'Report', N'Screen', N'Payroll.view.ProcessW2', N'small-menu-report', 1, 0, 0, 1, 7, 1)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 7, strCommand = 'Payroll.view.ProcessW2' WHERE strMenuName = 'Process W-2' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Quarterly FUI' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Quarterly FUI', N'Payroll', @PayrollReportParentMenuId, N'Quarterly FUI', N'Report', N'Screen', N'Reporting.view.ReportManager?group=Payroll&report=QuarterlyFUI&direct=true', N'small-menu-report', 1, 0, 0, 1, 8, 1)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 8, strCommand = 'Reporting.view.ReportManager?group=Payroll&report=QuarterlyFUI&direct=true' WHERE strMenuName = 'Quarterly FUI' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Quarterly State' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Quarterly State', N'Payroll', @PayrollReportParentMenuId, N'Quarterly State', N'Report', N'Screen', N'Reporting.view.ReportManager?group=Payroll&report=QuarterlyStateTax&direct=true', N'small-menu-report', 1, 0, 0, 1, 9, 1)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 9, strCommand = 'Reporting.view.ReportManager?group=Payroll&report=QuarterlyStateTax&direct=true' WHERE strMenuName = 'Quarterly State' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Quarterly SUI' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Quarterly SUI', N'Payroll', @PayrollReportParentMenuId, N'Quarterly SUI', N'Report', N'Screen', N'Reporting.view.ReportManager?group=Payroll&report=QuarterlySUI&direct=true', N'small-menu-report', 1, 0, 0, 1, 10, 1)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 10, strCommand = 'Reporting.view.ReportManager?group=Payroll&report=QuarterlySUI&direct=true' WHERE strMenuName = 'Quarterly SUI' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'W-2s' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'W-2s', N'Payroll', @PayrollReportParentMenuId, N'W-2s', N'Report', N'Screen', N'Payroll.view.EmployeeW2?showSearch=true&searchCommand=EmployeeW2&isFloating=true', N'small-menu-report', 1, 0, 0, 1, 11, 1)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 11, strCommand = 'Payroll.view.EmployeeW2?showSearch=true&searchCommand=EmployeeW2&isFloating=true' WHERE strMenuName = 'W-2s' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Workers Comp' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Workers Comp', N'Payroll', @PayrollReportParentMenuId, N'Workers Comp', N'Report', N'Screen', N'Reporting.view.ReportManager?group=Payroll&report=WorkersCompensation&direct=true', N'small-menu-report', 1, 0, 0, 1, 11, 1)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 11, strCommand = 'Reporting.view.ReportManager?group=Payroll&report=WorkersCompensation&direct=true' WHERE strMenuName = 'Workers Comp' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Paycheck Calculator' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollUtilitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Paycheck Calculator', N'Payroll', @PayrollUtilitiesParentMenuId, N'Paycheck Calculator', N'Utility', N'Screen', N'Payroll.view.PaycheckCalculator', N'small-menu-utility', 1, 1, 0, 1, 0, 0)
ELSE 
	UPDATE tblSMMasterMenu SET  intSort = 0, strCategory = 'Utility', strIcon = N'small-menu-utility', strCommand = N'Payroll.view.PaycheckCalculator' WHERE strMenuName = 'Paycheck Calculator' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollUtilitiesParentMenuId

/* START OF DELETING */
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Quarterly FUI' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Quarterly SUI' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Quarterly State Tax' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Earnings History' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Earnings History By Department' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Employee Earnings History' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Form 941' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Process W-2' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Workers Compensation' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Timecard Approval' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollActivitiesParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Timecard History' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollActivitiesParentMenuId
/* END OF DELETING */

/* NOTES RECEIVABLE */
DELETE FROM tblSMMasterMenu WHERE strModuleName = 'Notes Receivable'
--IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Notes Receivable' AND strModuleName = 'Notes Receivable' AND intParentMenuID = 0)
--	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
--	VALUES (N'Notes Receivable', N'Notes Receivable', 0, N'Notes Receivable', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 12, 0)
--ELSE
--	UPDATE tblSMMasterMenu SET intSort = 12 WHERE strMenuName = 'Notes Receivable' AND strModuleName = 'Notes Receivable' AND intParentMenuID = 0

--DECLARE @NotesReceivableParentMenuId INT
--SELECT @NotesReceivableParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Notes Receivable' AND strModuleName = 'Notes Receivable' AND intParentMenuID = 0

--/* CATEGORY FOLDERS */
--IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Activities' AND strModuleName = 'Notes Receivable' AND intParentMenuID = @NotesReceivableParentMenuId)
--	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
--	VALUES (N'Activities', N'Notes Receivable', @NotesReceivableParentMenuId, N'Activities', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 0, 1)
--ELSE
--	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 0 WHERE strMenuName = 'Activities' AND strModuleName = 'Notes Receivable' AND intParentMenuID = @NotesReceivableParentMenuId

--DECLARE @NotesReceivableActivitiesParentMenuId INT
--SELECT @NotesReceivableActivitiesParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Activities' AND strModuleName = 'Notes Receivable' AND intParentMenuID = @NotesReceivableParentMenuId

--IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'Notes Receivable' AND intParentMenuID = @NotesReceivableParentMenuId)
--	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
--	VALUES (N'Maintenance', N'Notes Receivable', @NotesReceivableParentMenuId, N'Maintenance', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 1, 1)
--ELSE
--	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 1 WHERE strMenuName = 'Maintenance' AND strModuleName = 'Notes Receivable' AND intParentMenuID = @NotesReceivableParentMenuId

--DECLARE @NotesReceivableMaintenanceParentMenuId INT
--SELECT @NotesReceivableMaintenanceParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'Notes Receivable' AND intParentMenuID = @NotesReceivableParentMenuId

--/* ADD TO RESPECTIVE CATEGORY */ 
--UPDATE tblSMMasterMenu SET intParentMenuID = @NotesReceivableActivitiesParentMenuId WHERE intParentMenuID =  @NotesReceivableParentMenuId AND strCategory = 'Activity'
--UPDATE tblSMMasterMenu SET intParentMenuID = @NotesReceivableMaintenanceParentMenuId WHERE intParentMenuID =  @NotesReceivableParentMenuId AND strCategory = 'Maintenance'

--IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Reports' AND strModuleName = 'Notes Receivable' AND intParentMenuID = @NotesReceivableParentMenuId)
--    INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
--    VALUES (N'Reports', N'Notes Receivable', @NotesReceivableParentMenuId, N'Reports', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 2, 1)
--ELSE
--    UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 2 WHERE strMenuName = 'Reports' AND strModuleName = 'Notes Receivable' AND intParentMenuID = @NotesReceivableParentMenuId

--DECLARE @NotesReceivableReportParentMenuId INT
--SELECT @NotesReceivableReportParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Reports' AND strModuleName = 'Notes Receivable' AND intParentMenuID = @NotesReceivableParentMenuId

--/* Rename Note Maintenance to Note Receivables */
--IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Note Maintenance' AND strModuleName = 'Notes Receivable' AND intParentMenuID = @NotesReceivableActivitiesParentMenuId)
--UPDATE tblSMMasterMenu SET strMenuName = 'Notes Receivables', strDescription = 'Notes Receivables' WHERE strMenuName = 'Note Maintenance' AND strModuleName = 'Notes Receivable' AND intParentMenuID = @NotesReceivableActivitiesParentMenuId

--/* Start of moving report */
--UPDATE tblSMMasterMenu SET intParentMenuID = @NotesReceivableReportParentMenuId WHERE strMenuName = 'UCC Tracking' AND strModuleName = 'Notes Receivable' AND strType = 'Report' AND intParentMenuID = @NotesReceivableParentMenuId
--UPDATE tblSMMasterMenu SET intParentMenuID = @NotesReceivableReportParentMenuId WHERE strMenuName = 'Aged Notes Receivable' AND strModuleName = 'Notes Receivable' AND strType = 'Report' AND intParentMenuID = @NotesReceivableParentMenuId
--UPDATE tblSMMasterMenu SET intParentMenuID = @NotesReceivableReportParentMenuId WHERE strMenuName = '1098' AND strModuleName = 'Notes Receivable' AND strType = 'Report' AND intParentMenuID = @NotesReceivableParentMenuId
--/* End of moving report */

--IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Notes Receivables' AND strModuleName = 'Notes Receivable' AND intParentMenuID = @NotesReceivableActivitiesParentMenuId)
--	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId])
--	VALUES (N'Notes Receivables', N'Notes Receivable', @NotesReceivableActivitiesParentMenuId, N'Notes Receivables', N'Activity', N'Screen', N'NotesReceivable.view.NotesReceivable', N'small-menu-activity', 0, 0, 0, 1, 0, 1)
--ELSE
--	UPDATE tblSMMasterMenu SET intSort = 0, strCommand = N'NotesReceivable.view.NotesReceivable' WHERE strMenuName = 'Notes Receivables' AND strModuleName = 'Notes Receivable' AND intParentMenuID = @NotesReceivableActivitiesParentMenuId

--IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Calculate Monthly Interest' AND strModuleName = 'Notes Receivable' AND intParentMenuID = @NotesReceivableActivitiesParentMenuId)
--	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
--	VALUES (N'Calculate Monthly Interest', N'Notes Receivable', @NotesReceivableActivitiesParentMenuId, N'Calculate Monthly Interest', N'Activity', N'Screen', N'NotesReceivable.view.CalculateMonthlyInterest', N'small-menu-activity', 0, 0, 0, 1, 1, 1)
--ELSE 
--	UPDATE tblSMMasterMenu SET intSort = 1, strCommand = N'NotesReceivable.view.CalculateMonthlyInterest' WHERE strMenuName = 'Calculate Monthly Interest' AND strModuleName = 'Notes Receivable' AND intParentMenuID = @NotesReceivableActivitiesParentMenuId

--IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Note Description' AND strModuleName = 'Notes Receivable' AND intParentMenuID = @NotesReceivableMaintenanceParentMenuId)
--	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
--	VALUES (N'Note Description', N'Notes Receivable', @NotesReceivableMaintenanceParentMenuId, N'Note Description', N'Maintenance', N'Screen', N'NotesReceivable.view.NoteDescription', N'small-menu-maintenance', 0, 0, 0, 1, 0, 1)
--ELSE 
--	UPDATE tblSMMasterMenu SET intSort = 0, strCommand = N'NotesReceivable.view.NoteDescription' WHERE strMenuName = 'Note Description' AND strModuleName = 'Notes Receivable' AND intParentMenuID = @NotesReceivableMaintenanceParentMenuId

--IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Show Adjustment As' AND strModuleName = 'Notes Receivable' AND intParentMenuID = @NotesReceivableMaintenanceParentMenuId)
--	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
--	VALUES (N'Show Adjustment As', N'Notes Receivable', @NotesReceivableMaintenanceParentMenuId, N'Show Adjustment As', N'Maintenance', N'Screen', N'NotesReceivable.view.ShowAdjustmentAs', N'small-menu-maintenance', 0, 0, 0, 1, 1, 1)
--ELSE 
--	UPDATE tblSMMasterMenu SET intSort = 1, strCommand = N'NotesReceivable.view.ShowAdjustmentAs' WHERE strMenuName = 'Show Adjustment As' AND strModuleName = 'Notes Receivable' AND intParentMenuID = @NotesReceivableMaintenanceParentMenuId

--IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = '1098' AND strModuleName = 'Notes Receivable' AND intParentMenuID = @NotesReceivableReportParentMenuId)
--	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
--	VALUES (N'1098', N'Notes Receivable', @NotesReceivableReportParentMenuId, N'1098', N'Report', N'Report', N'1098', N'small-menu-report', 0, 0, 0, 1, 0, 1)
--ELSE 
--	UPDATE tblSMMasterMenu SET intSort = 0, strCommand = N'1098' WHERE strMenuName = '1098' AND strModuleName = 'Notes Receivable' AND intParentMenuID = @NotesReceivableReportParentMenuId

--IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Aged Notes Receivable' AND strModuleName = 'Notes Receivable' AND intParentMenuID = @NotesReceivableReportParentMenuId)
--	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
--	VALUES (N'Aged Notes Receivable', N'Notes Receivable', @NotesReceivableReportParentMenuId, N'Aged Notes Receivable', N'Report', N'Report', N'Aged Notes Receivable', N'small-menu-report', 0, 0, 0, 1, 1, 1)
--ELSE 
--	UPDATE tblSMMasterMenu SET intSort = 1, strCommand = N'Aged Notes Receivable' WHERE strMenuName = 'Aged Notes Receivable' AND strModuleName = 'Notes Receivable' AND intParentMenuID = @NotesReceivableReportParentMenuId

--IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'UCC Tracking' AND strModuleName = 'Notes Receivable' AND intParentMenuID = @NotesReceivableReportParentMenuId)
--	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
--	VALUES (N'UCC Tracking', N'Notes Receivable', @NotesReceivableReportParentMenuId, N'UCC Tracking', N'Report', N'Report', N'UCC Tracking', N'small-menu-report', 0, 0, 0, 1, 2, 1)
--ELSE 
--	UPDATE tblSMMasterMenu SET intSort = 2, strCommand = N'UCC Tracking' WHERE strMenuName = 'UCC Tracking' AND strModuleName = 'Notes Receivable' AND intParentMenuID = @NotesReceivableReportParentMenuId

/* CONTRACT MANAGEMENT */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Contract Management' AND strModuleName = 'Contract Management' AND intParentMenuID = 0)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Contract Management', N'Contract Management', 0, N'Contract Management', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 12, 0)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 12 WHERE strMenuName = 'Contract Management' AND strModuleName = 'Contract Management' AND intParentMenuID = 0

DECLARE @ContractManagementParentMenuId INT
SELECT @ContractManagementParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Contract Management' AND strModuleName = 'Contract Management' AND intParentMenuID = 0

/* CHANGE SCREEN CATEGORY 1730 TO 1810 */
UPDATE tblSMMasterMenu SET strCategory = 'Planning', strIcon = 'small-menu-planning' WHERE strMenuName IN ('Annual Operation Planning', 'Event Configuration', 'Alert Filter', 'Event Matrix', 'Need Plan') AND strModuleName = N'Contract Management'
UPDATE tblSMMasterMenu SET strCategory = 'Report', strIcon = 'small-menu-report' WHERE strMenuName IN ('Overview') AND strModuleName = N'Contract Management'
UPDATE tblSMMasterMenu SET strCategory = 'Entity', strIcon = 'small-menu-entity' WHERE strMenuName IN ('Brokers', 'Producers') AND strModuleName = N'Contract Management'

/* CHANGE SCREEN CATEGORY 1830 TO 1910 */
UPDATE tblSMMasterMenu SET strCategory = 'Activity', strIcon = 'small-menu-activity' WHERE strMenuName IN ('Broker Commission Processing', 'Reassign') AND strModuleName = N'Contract Management'
UPDATE tblSMMasterMenu SET strCategory = 'Report', strIcon = 'small-menu-report' WHERE strMenuName IN ('Basis Component', 'AOP Vs Actual') AND strModuleName = N'Contract Management'

/* CATEGORY FOLDERS */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Activities' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intRow], [intConcurrencyId]) 
	VALUES (N'Activities', N'Contract Management', @ContractManagementParentMenuId, N'Activities', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 0, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 0, intRow = 0 WHERE strMenuName = 'Activities' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId

DECLARE @ContractManagementActivitiesParentMenuId INT
SELECT @ContractManagementActivitiesParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Activities' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intRow], [intConcurrencyId]) 
	VALUES (N'Maintenance', N'Contract Management', @ContractManagementParentMenuId, N'Maintenance', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 1, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 1, intRow = 0 WHERE strMenuName = 'Maintenance' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId

DECLARE @ContractManagementMaintenanceParentMenuId INT
SELECT @ContractManagementMaintenanceParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Planning' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intRow], [intConcurrencyId]) 
	VALUES (N'Planning', N'Contract Management', @ContractManagementParentMenuId, N'Planning', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 2, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 2, intRow = 0 WHERE strMenuName = 'Planning' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId

DECLARE @ContractManagementPlanningParentMenuId INT
SELECT @ContractManagementPlanningParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Planning' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Reports' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intRow], [intConcurrencyId]) 
	VALUES (N'Reports', N'Contract Management', @ContractManagementParentMenuId, N'Reports', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 3, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 3, intRow = 0 WHERE strMenuName = 'Reports' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId

DECLARE @ContractManagementReportParentMenuId INT
SELECT @ContractManagementReportParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Reports' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Create' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intRow], [intConcurrencyId]) 
	VALUES (N'Create', N'Contract Management', @ContractManagementParentMenuId, N'Create', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 0, 1, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 0, intRow = 1 WHERE strMenuName = 'Create' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId

DECLARE @ContractManagementCreateParentMenuId INT
SELECT @ContractManagementCreateParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Create' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Entity' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intRow], [intConcurrencyId]) 
	VALUES (N'Entity', N'Contract Management', @ContractManagementParentMenuId, N'Entity', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 1, 1, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 1, intRow = 1 WHERE strMenuName = 'Entity' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId

DECLARE @ContractManagementEntityParentMenuId INT
SELECT @ContractManagementEntityParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Entity' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId

/* ADD TO RESPECTIVE CATEGORY */ 
UPDATE tblSMMasterMenu SET intParentMenuID = @ContractManagementActivitiesParentMenuId WHERE intParentMenuID IN (@ContractManagementParentMenuId, @ContractManagementEntityParentMenuId) AND strCategory = 'Activity'
UPDATE tblSMMasterMenu SET intParentMenuID = @ContractManagementMaintenanceParentMenuId WHERE intParentMenuID =  @ContractManagementParentMenuId AND strCategory = 'Maintenance'
UPDATE tblSMMasterMenu SET intParentMenuID = @ContractManagementPlanningParentMenuId WHERE intParentMenuID =  @ContractManagementParentMenuId AND strCategory = 'Planning'
UPDATE tblSMMasterMenu SET intParentMenuID = @ContractManagementReportParentMenuId WHERE intParentMenuID IN (@ContractManagementParentMenuId, @ContractManagementMaintenanceParentMenuId) AND strCategory = 'Report'
UPDATE tblSMMasterMenu SET intParentMenuID = @ContractManagementCreateParentMenuId WHERE intParentMenuID =  @ContractManagementParentMenuId AND strCategory = 'Create'
UPDATE tblSMMasterMenu SET intParentMenuID = @ContractManagementEntityParentMenuId WHERE intParentMenuID =  @ContractManagementParentMenuId AND strCategory = 'Entity'

/* START OF PLURALIZING */
UPDATE tblSMMasterMenu SET strMenuName = 'Contracts', strDescription = 'Contracts' WHERE strMenuName = 'Contract' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementActivitiesParentMenuId
UPDATE tblSMMasterMenu SET strMenuName = 'Contract Texts', strDescription = 'Contract Texts' WHERE strMenuName = 'Contract Text' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceParentMenuId
UPDATE tblSMMasterMenu SET strMenuName = 'Cost Types', strDescription = 'Cost Types' WHERE strMenuName = 'Cost Type' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceParentMenuId
UPDATE tblSMMasterMenu SET strMenuName = 'Books', strDescription = 'Books' WHERE strMenuName = 'Book' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceParentMenuId
/* END OF PLURALIZING */

/* Start of Re-name */
UPDATE tblSMMasterMenu SET strMenuName = 'Approval Term', strDescription = 'Approval Term' WHERE strMenuName = 'Approval Basis' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceParentMenuId
UPDATE tblSMMasterMenu SET strMenuName = 'INCO Term', strDescription = 'INCO Term' WHERE strMenuName = 'Contract Basis' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceParentMenuId
UPDATE tblSMMasterMenu SET strMenuName = 'INCO/Ship Term', strDescription = 'INCO/Ship Term' WHERE strMenuName = 'INCO Term' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceParentMenuId
UPDATE tblSMMasterMenu SET strMenuName = 'Contract Positions', strDescription = 'Contract Positions' WHERE strMenuName = 'Position' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceParentMenuId
UPDATE tblSMMasterMenu SET strCommand = 'ContractManagement.view.ContractTemplate', strMenuName = 'Contract Templates', strDescription = 'Contract Templates' WHERE strMenuName = 'Contract Plans' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceParentMenuId
UPDATE tblSMMasterMenu SET strMenuName = 'Event Filter', strDescription = 'Event Filter' WHERE strMenuName = 'Alert Filter' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementPlanningParentMenuId
/* End of Re-name */

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Contracts' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Contracts', N'Contract Management', @ContractManagementActivitiesParentMenuId, N'Contracts', N'Activity', N'Screen', N'ContractManagement.view.Contract?showSearch=true', N'small-menu-activity', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 0, strCommand = N'ContractManagement.view.Contract?showSearch=true' WHERE strMenuName = 'Contracts' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Item Contracts' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Item Contracts', N'Contract Management', @ContractManagementActivitiesParentMenuId, N'Item Contracts', N'Activity', N'Screen', N'ContractManagement.view.ItemContract?showSearch=true', N'small-menu-activity', 0, 0, 0, 1, 1, 1)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 1, strCommand = N'ContractManagement.view.ItemContract?showSearch=true',[strIcon] = 'small-menu-activity',[strCategory] = 'Activity' WHERE strMenuName = 'Item Contracts' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Price Contracts' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Price Contracts', N'Contract Management', @ContractManagementActivitiesParentMenuId, N'Price Contracts', N'Activity', N'Screen', N'ContractManagement.view.PriceContracts?showSearch=true', N'small-menu-activity', 0, 0, 0, 1, 1, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 2, strCommand = N'ContractManagement.view.PriceContracts?showSearch=true' WHERE strMenuName = 'Price Contracts' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementActivitiesParentMenuId


--IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Contract Adjustments' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementActivitiesParentMenuId)
--	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
--	VALUES (N'Contract Adjustments', N'Contract Management', @ContractManagementActivitiesParentMenuId, N'Contract Adjustments', N'Activity', N'Screen', N'ContractManagement.view.ContractAdjustment?showSearch=true', N'small-menu-activity', 0, 0, 0, 1, 2, 1)
--ELSE 
--	UPDATE tblSMMasterMenu SET intSort = 2, strCommand = N'ContractManagement.view.ContractAdjustment?showSearch=true' WHERE strMenuName = 'Contract Adjustments' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Roll Contracts' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Roll Contracts', N'Contract Management', @ContractManagementActivitiesParentMenuId, N'Roll Contracts', N'Activity', N'Screen', N'ContractManagement.view.RollContracts', N'small-menu-activity', 0, 0, 0, 1, 2, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 3, strCommand = N'ContractManagement.view.RollContracts' WHERE strMenuName = 'Roll Contracts' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Clean Costs & Weights' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Clean Costs & Weights', N'Contract Management', @ContractManagementActivitiesParentMenuId, N'Clean Costs & Weights', N'Activity', N'Screen', N'ContractManagement.view.CleanCostsAndWeights?showSearch=true', N'small-menu-activity', 0, 0, 0, 1, 3, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 4, strCommand = N'ContractManagement.view.CleanCostsAndWeights?showSearch=true' WHERE strMenuName = 'Clean Costs & Weights' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Contract Inquiry' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Contract Inquiry', N'Contract Management', @ContractManagementActivitiesParentMenuId, N'Contract Inquiry', N'Activity', N'Screen', N'ContractManagement.view.ContractInquiry', N'small-menu-activity', 0, 0, 0, 1, 4, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 5, strCommand = N'ContractManagement.view.ContractInquiry' WHERE strMenuName = 'Contract Inquiry' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Contract Status' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Contract Status', N'Contract Management', @ContractManagementActivitiesParentMenuId, N'Contract Status', N'Activity', N'Screen', N'ContractManagement.view.ContractStatus', N'small-menu-activity', 0, 0, 0, 1, 5, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 6, strCommand = N'ContractManagement.view.ContractStatus' WHERE strMenuName = 'Contract Status' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Amendments' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId])
	VALUES (N'Amendments', N'Contract Management', @ContractManagementActivitiesParentMenuId, N'Amendments', N'Activity', N'Screen', N'ContractManagement.view.AmendmentSearch', N'small-menu-activity', 0, 0, 0, 1, 6, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 7, strCommand = N'ContractManagement.view.AmendmentSearch' WHERE strMenuName = 'Amendments' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Broker Commission Processing' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Broker Commission Processing', N'Contract Management', @ContractManagementActivitiesParentMenuId, N'Broker Commission Processing', N'Activity', N'Screen', N'ContractManagement.view.BrokerCommissionProcessing?showSearch=true', N'small-menu-activity', 1, 1, 0, 1, 7, 0)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 8, strCommand = N'ContractManagement.view.BrokerCommissionProcessing?showSearch=true' WHERE strMenuName = 'Broker Commission Processing' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Reassign' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Reassign', N'Contract Management', @ContractManagementActivitiesParentMenuId, N'Reassign', N'Activity', N'Screen', N'ContractManagement.view.Reassign?showSearch=true', N'small-menu-activity', 1, 1, 0, 1, 8, 0)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 9, strCommand = N'ContractManagement.view.Reassign?showSearch=true',[strIcon] = 'small-menu-activity',[strCategory] = 'Activity' WHERE strMenuName = 'Reassign' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Update Balance Quantity' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Update Balance Quantity', N'Contract Management', @ContractManagementActivitiesParentMenuId, N'Update Balance Quantity', N'Activity', N'Screen', N'ContractManagement.view.ImportDataFromCsv?type=Balance&method=POST&title=Update Balance Quantity&allowOverwrite=false', N'small-menu-activity', 1, 1, 0, 1, 9, 0)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 10, strCommand = N'ContractManagement.view.ImportDataFromCsv?type=Balance&method=POST&title=Update Balance Quantity&allowOverwrite=false',[strIcon] = 'small-menu-activity',[strCategory] = 'Activity' WHERE strMenuName = 'Update Balance Quantity' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementActivitiesParentMenuId



DELETE tblSMMasterMenu WHERE strMenuName = 'Amendment' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Amendment and Approvals' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Amendment and Approvals', N'Contract Management', @ContractManagementMaintenanceParentMenuId, N'Amendment', N'Maintenance', N'Screen', N'ContractManagement.view.Amendments', N'small-menu-maintenance', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 0, strCommand = N'ContractManagement.view.Amendments' WHERE strMenuName = 'Amendment and Approvals' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Associations' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Associations', N'Contract Management', @ContractManagementMaintenanceParentMenuId, N'Associations', N'Maintenance', N'Screen', N'ContractManagement.view.Associations?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 1, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 1, strCommand = N'ContractManagement.view.Associations?showSearch=true' WHERE strMenuName = 'Associations' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Books' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Books', N'Contract Management', @ContractManagementMaintenanceParentMenuId, N'Books', N'Maintenance', N'Screen', N'ContractManagement.view.Book?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 2, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 2, strCommand = N'ContractManagement.view.Book?showSearch=true' WHERE strMenuName = 'Books' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Book Vs Entities' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Book Vs Entities', N'Contract Management', @ContractManagementMaintenanceParentMenuId, N'Book Vs Entities', N'Maintenance', N'Screen', N'ContractManagement.view.BookVsEntity', N'small-menu-maintenance', 0, 0, 0, 1, 3, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 3, strCommand = N'ContractManagement.view.BookVsEntity' WHERE strMenuName = 'Book Vs Entities' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Certification Programs' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Certification Programs', N'Contract Management', @ContractManagementMaintenanceParentMenuId, N'Certification Programs', N'Maintenance', N'Screen', N'ContractManagement.view.CertificationProgram?showSearch=true', N'small-menu-maintenance', 1, 1, 0, 1, 4, 0)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 4, strCommand = N'ContractManagement.view.CertificationProgram?showSearch=true' WHERE strMenuName = 'Certification Programs' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Condition' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Condition', N'Contract Management', @ContractManagementMaintenanceParentMenuId, N'Condition', N'Maintenance', N'Screen', N'ContractManagement.view.Condition?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 5, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 5, strCommand = N'ContractManagement.view.Condition?showSearch=true' WHERE strMenuName = 'Condition' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Contract Positions' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Contract Positions', N'Contract Management', @ContractManagementMaintenanceParentMenuId, N'Contract Positions', N'Maintenance', N'Screen', N'ContractManagement.view.Position', N'small-menu-maintenance', 0, 0, 0, 1, 6, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 6, strCommand = N'ContractManagement.view.Position' WHERE strMenuName = 'Contract Positions' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Contract Templates' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Contract Templates', N'Contract Management', @ContractManagementMaintenanceParentMenuId, N'Contract Templates', N'Maintenance', N'Screen', N'ContractManagement.view.ContractTemplate?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 7, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 7, strCommand = N'ContractManagement.view.ContractTemplate?showSearch=true' WHERE strMenuName = 'Contract Templates' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Contract Texts' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Contract Texts', N'Contract Management', @ContractManagementMaintenanceParentMenuId, N'Contract Texts', N'Maintenance', N'Screen', N'ContractManagement.view.ContractText?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 8, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 8, strCommand = N'ContractManagement.view.ContractText?showSearch=true' WHERE strMenuName = 'Contract Texts' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Crop Year' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Crop Year', N'Contract Management', @ContractManagementMaintenanceParentMenuId, N'Crop Year', N'Maintenance', N'Screen', N'ContractManagement.view.CropYear', N'small-menu-maintenance', 0, 0, 0, 1, 9, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 9, strCommand = N'ContractManagement.view.CropYear' WHERE strMenuName = 'Crop Year' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Documents' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Documents', N'Contract Management', @ContractManagementMaintenanceParentMenuId, N'Documents', N'Maintenance', N'Screen', N'ContractManagement.view.ContractDocument?showSearch=true', N'small-menu-maintenance', 1, 1, 0, 1, 10, 0)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 10, strCommand = N'ContractManagement.view.ContractDocument?showSearch=true' WHERE strMenuName = 'Documents' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'INCO/Ship Term' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'INCO/Ship Term', N'Contract Management', @ContractManagementMaintenanceParentMenuId, N'INCO/Ship Term', N'Maintenance', N'Screen', N'ContractManagement.view.INCOShipTerm?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 11, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 11, strCommand = N'ContractManagement.view.INCOShipTerm?showSearch=true' WHERE strMenuName = 'INCO/Ship Term' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Indexes' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Indexes', N'Contract Management', @ContractManagementMaintenanceParentMenuId, N'Indexes', N'Maintenance', N'Screen', N'ContractManagement.view.Index', N'small-menu-maintenance', 0, 0, 0, 1, 12, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 12, strCommand = N'ContractManagement.view.Index' WHERE strMenuName = 'Indexes' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceParentMenuId

DELETE FROM tblSMMasterMenu WHERE strCommand = N'ContractManagement.view.WeightGrade' 

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Weight/Grades' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Weight/Grades', N'Contract Management', @ContractManagementMaintenanceParentMenuId, N'Weight/Grades', N'Maintenance', N'Screen', N'ContractManagement.view.WeightGrades?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 13, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 13, strCommand = N'ContractManagement.view.WeightGrades?showSearch=true' WHERE strMenuName = 'Weight/Grades' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Entity Producer Map' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId])
	VALUES (N'Entity Producer Map', N'Contract Management',@ContractManagementMaintenanceParentMenuId, N'Entity Producer Map', N'Maintenance', N'Screen', N'ContractManagement.view.EntityProducerMap', N'small-menu-maintenance', 0, 0, 0, 1, 14, 1)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 14, strCommand = N'ContractManagement.view.EntityProducerMap' WHERE strMenuName = 'Entity Producer Map' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Annual Operation Planning' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementPlanningParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Annual Operation Planning', N'Contract Management', @ContractManagementPlanningParentMenuId, N'Annual Operation Planning', N'Planning', N'Screen', N'ContractManagement.view.AnnualOperatingPlanning?showSearch=true', N'small-menu-planning', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 0, strCommand = N'ContractManagement.view.AnnualOperatingPlanning?showSearch=true' WHERE strMenuName = 'Annual Operation Planning' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementPlanningParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Event Configuration' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementPlanningParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Event Configuration', N'Contract Management', @ContractManagementPlanningParentMenuId, N'Event Configuration', N'Planning', N'Screen', N'ContractManagement.view.EventConfiguration?showSearch=true', N'small-menu-planning', 0, 0, 0, 1, 1, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 1, strCommand = N'ContractManagement.view.EventConfiguration?showSearch=true' WHERE strMenuName = 'Event Configuration' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementPlanningParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Event Filter' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementPlanningParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId])
	VALUES (N'Event Filter', N'Contract Management', @ContractManagementPlanningParentMenuId, N'Event Filter', N'Planning', N'Screen', N'ContractManagement.view.EventRecipientFilter', N'small-menu-planning', 1, 1, 0, 1, 2, 0)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 2, strCommand = N'ContractManagement.view.EventRecipientFilter' WHERE strMenuName = 'Event Filter' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementPlanningParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Event Matrix' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementPlanningParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Event Matrix', N'Contract Management', @ContractManagementPlanningParentMenuId, N'Event Matrix', N'Planning', N'Screen', N'ContractManagement.view.EventMatrix?showSearch=true', N'small-menu-planning', 0, 0, 0, 1, 3, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 3, strCommand = N'ContractManagement.view.EventMatrix?showSearch=true' WHERE strMenuName = 'Event Matrix' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementPlanningParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Need Plan' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementPlanningParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Need Plan', N'Contract Management', @ContractManagementPlanningParentMenuId, N'Need Plan', N'Planning', N'Screen', N'ContractManagement.view.NeedPlan', N'small-menu-planning', 0, 0, 0, 1, 4, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 4, strCommand = N'ContractManagement.view.NeedPlan' WHERE strMenuName = 'Need Plan' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementPlanningParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'AOP Vs Actual' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'AOP Vs Actual', N'Contract Management', @ContractManagementReportParentMenuId, N'AOP Vs Actual', N'Report', N'Screen', N'Reporting.view.ReportManager?group=Contract Management&report=AOPVsActual&direct=true&showCriteria=true', N'small-menu-report', 1, 1, 0, 1, 0, 0)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 0, strCommand = N'Reporting.view.ReportManager?group=Contract Management&report=AOPVsActual&direct=true&showCriteria=true' WHERE strMenuName = 'AOP Vs Actual' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Basis Component' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Basis Component', N'Contract Management', @ContractManagementReportParentMenuId, N'Basis Component', N'Report', N'Screen', N'Reporting.view.ReportManager?group=Contract Management&report=BasisComponent&direct=true&showCriteria=true', N'small-menu-report', 1, 1, 0, 1, 1, 0)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 1, strCommand = N'Reporting.view.ReportManager?group=Contract Management&report=BasisComponent&direct=true&showCriteria=true' WHERE strMenuName = 'Basis Component' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Closed Contracts' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Closed Contracts', N'Contract Management', @ContractManagementReportParentMenuId, N'Closed Contracts', N'Report', N'Screen', N'ContractManagement.view.Finalized', N'small-menu-report', 1, 1, 0, 1, 2, 0)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 2, strCommand = N'ContractManagement.view.Finalized' WHERE strMenuName = 'Closed Contracts' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Contract Balance' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Contract Balance', N'Contract Management', @ContractManagementReportParentMenuId, N'Contract Balance', N'Report', N'Screen', N'ContractManagement.view.ContractBalance', N'small-menu-report', 1, 1, 0, 1, 3, 0)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 3, strCommand = N'ContractManagement.view.ContractBalance' WHERE strMenuName = 'Contract Balance' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Overview' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Overview', N'Contract Management', @ContractManagementReportParentMenuId, N'Overview', N'Report', N'Screen', N'ContractManagement.view.Overview?showSearch=true', N'small-menu-report', 1, 1, 0, 1, 4, 0)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 4, strCommand = N'ContractManagement.view.Overview?showSearch=true' WHERE strMenuName = 'Overview' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'New Contract' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementCreateParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'New Contract', N'Contract Management', @ContractManagementCreateParentMenuId, N'New Contract', N'Create', N'Screen', N'ContractManagement.view.Contract?action=new', N'small-menu-create', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 0, strCommand = N'ContractManagement.view.Contract?action=new' WHERE strMenuName = 'New Contract' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementCreateParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Rapid Contract Entry' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementCreateParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Rapid Contract Entry', N'Contract Management', @ContractManagementCreateParentMenuId, N'Rapid Contract Entry', N'Create', N'Screen', N'ContractManagement.view.ContractRapidEntry', N'small-menu-create', 0, 0, 0, 1, 1, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 1, strCommand = N'ContractManagement.view.ContractRapidEntry' WHERE strMenuName = 'Rapid Contract Entry' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementCreateParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Brokers' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementEntityParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Brokers', N'Contract Management', @ContractManagementEntityParentMenuId, N'Brokers', N'Entity', N'Screen', N'AccountsPayable.view.EntityVendor?showSearch=true&searchCommand=EntityBroker', N'small-menu-entity', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 0, strCommand = N'AccountsPayable.view.EntityVendor?showSearch=true&searchCommand=EntityBroker' WHERE strMenuName = 'Brokers' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementEntityParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Producers' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementEntityParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Producers', N'Contract Management', @ContractManagementEntityParentMenuId, N'Producers', N'Entity', N'Screen', N'EntityManagement.view.EntityDirect?showSearch=true&searchCommand=EntityProducer', N'small-menu-entity', 1, 1, 0, 1, 1, 0)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 1, strCommand = N'EntityManagement.view.EntityDirect?showSearch=true&searchCommand=EntityProducer' WHERE strMenuName = 'Producers' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementEntityParentMenuId
	
/* Start of Delete */
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Contract Options' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Cost Types' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Freight Rates' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Annual Operating Planning' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Deferred Payment Rates' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Approval Term' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'INCO/Ship Term' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceParentMenuId

DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Contract Adjustments' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementActivitiesParentMenuId
/* End of Delete */

/* RISK MANAGEMENT */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Risk Management' AND strModuleName = 'Risk Management' AND intParentMenuID = 0)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Risk Management', N'Risk Management', 0, N'Risk Management', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 13, 2)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 13 WHERE strMenuName = 'Risk Management' AND strModuleName = 'Risk Management' AND intParentMenuID = 0

DECLARE @RiskManagementParentMenuId INT
SELECT @RiskManagementParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Risk Management' AND strModuleName = 'Risk Management' AND intParentMenuID = 0

/* CHANGE SCREEN CATEGORY 1730 TO 1810 */
UPDATE tblSMMasterMenu SET strCategory = 'Activity', strIcon = 'small-menu-activity' WHERE strMenuName IN ('Position Report', 'Coverage/Risk Inquiry', 'Position by Period Selection', 'Daily Position Inquiry', 'Sourcing Report', 'Reconciliation Broker Statement', 'Collateral', 'Derivative Screen', 'PnL Report') AND strModuleName = N'Risk Management'
UPDATE tblSMMasterMenu SET strCategory = 'Maintenance', strIcon = 'small-menu-maintenance' WHERE strMenuName IN ('Brokerage Accounts', 'Futures Broker', 'Futures Markets', 'Futures Price', 'Futures Trading Months', 'M2M Configuration', 'Market Exchange', 'Options Trading Months', 'Risk Rating Matrix') AND strModuleName = N'Risk Management'

/* CATEGORY FOLDERS */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Activities' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Activities', N'Risk Management', @RiskManagementParentMenuId, N'Activities', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 0 WHERE strMenuName = 'Activities' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementParentMenuId

DECLARE @RiskManagementActivitiesParentMenuId INT
SELECT @RiskManagementActivitiesParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Activities' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Maintenance', N'Risk Management', @RiskManagementParentMenuId, N'Maintenance', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 1, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 1 WHERE strMenuName = 'Maintenance' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementParentMenuId

DECLARE @RiskManagementMaintenanceParentMenuId INT
SELECT @RiskManagementMaintenanceParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Derivatives' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Derivatives', N'Risk Management', @RiskManagementParentMenuId, N'Derivatives', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 2, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 2 WHERE strMenuName = 'Derivatives' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementParentMenuId

DECLARE @RiskManagementDerivativesParentMenuId INT
SELECT @RiskManagementDerivativesParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Derivatives' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Reports' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Reports', N'Risk Management', @RiskManagementParentMenuId, N'Reports', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 3, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 3 WHERE strMenuName = 'Reports' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementParentMenuId

DECLARE @RiskManagementReportParentMenuId INT
SELECT @RiskManagementReportParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Reports' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementParentMenuId

/* ADD TO RESPECTIVE CATEGORY */ 
UPDATE tblSMMasterMenu SET intParentMenuID = @RiskManagementActivitiesParentMenuId WHERE intParentMenuID =  @RiskManagementParentMenuId AND strCategory = 'Activity'
UPDATE tblSMMasterMenu SET intParentMenuID = @RiskManagementMaintenanceParentMenuId WHERE intParentMenuID =  @RiskManagementParentMenuId AND strCategory = 'Maintenance'

/* START OF PLURALIZING */
UPDATE tblSMMasterMenu SET strMenuName = 'Match Futures Purchase & Sales', strDescription = 'Match Futures Purchase & Sales' WHERE strMenuName = 'Match Futures Purchase & Sale' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementMaintenanceParentMenuId
UPDATE tblSMMasterMenu SET strMenuName = 'Futures Markets', strDescription = 'Futures Markets' WHERE strMenuName = 'Futures Market' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementMaintenanceParentMenuId
UPDATE tblSMMasterMenu SET strMenuName = 'Brokerage Accounts', strDescription = 'Brokerage Accounts' WHERE strMenuName = 'Brokerage Account' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementMaintenanceParentMenuId
/* END OF PLURALIZING */

/* START OF RENAMING  */
UPDATE tblSMMasterMenu SET strMenuName = 'Futures/Options Settlement Prices', strDescription = 'Futures/Options Settlement Prices' WHERE strMenuName = 'Futures Settlement Price' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementMaintenanceParentMenuId
UPDATE tblSMMasterMenu SET strMenuName = 'Futures Options Transactions', strDescription = 'Futures Options Transactions' WHERE strMenuName = 'Fut/Opt Transaction' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementMaintenanceParentMenuId
UPDATE tblSMMasterMenu SET strMenuName = 'Futures Trading Months', strDescription = 'Futures Trading Months' WHERE strMenuName = 'Futures Month' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementMaintenanceParentMenuId
UPDATE tblSMMasterMenu SET strMenuName = 'Options Trading Months', strDescription = 'Options Trading Months' WHERE strMenuName = 'Options Month' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementMaintenanceParentMenuId
UPDATE tblSMMasterMenu SET strMenuName = 'Live DPR', strDescription = 'Live DPR' WHERE strMenuName = 'Daily Position Report' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementMaintenanceParentMenuId
UPDATE tblSMMasterMenu SET strMenuName = 'Position Report', strDescription = 'Position Report' WHERE strMenuName = 'Live DPR' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementActivitiesParentMenuId
UPDATE tblSMMasterMenu SET strMenuName = N'Coverage/Risk Inquiry', strDescription = N'Coverage/Risk Inquiry' WHERE strMenuName = 'Coverage Report' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementActivitiesParentMenuId
UPDATE tblSMMasterMenu SET strMenuName = N'Mark To Market', strDescription = N'Mark To Market' WHERE strMenuName = 'M2M Inquiry' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementDerivativesParentMenuId
UPDATE tblSMMasterMenu SET strMenuName = N'Profit and Loss Analysis', strDescription = N'Profit and Loss Analysis'  WHERE strMenuName = 'PnL Report' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementActivitiesParentMenuId
UPDATE tblSMMasterMenu SET strMenuName = N'Position Reconciliation Report', strDescription = N'Position Reconciliation Report' WHERE strMenuName = 'DPR Reconciliation Report' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementReportParentMenuId
/* END OF RENAMING  */

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Position Report' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Position Report', N'Risk Management', @RiskManagementActivitiesParentMenuId, N'Position Report', N'Activity', N'Screen', N'RiskManagement.view.PositionReport', N'small-menu-activity', 0, 0, 0, 1, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 0, strCommand = N'RiskManagement.view.PositionReport' WHERE strMenuName = 'Position Report' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Coverage/Risk Inquiry' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Coverage/Risk Inquiry', N'Risk Management', @RiskManagementActivitiesParentMenuId, N'Coverage/Risk Inquiry', N'Activity', N'Screen', N'RiskManagement.view.RiskPositionInquiry', N'small-menu-activity', 0, 0, 0, 1, 1, 1)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 1, strCommand = N'RiskManagement.view.RiskPositionInquiry' WHERE strMenuName = 'Coverage/Risk Inquiry' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Position by Period Selection' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Position by Period Selection', N'Risk Management', @RiskManagementActivitiesParentMenuId, N'Position by Period Selection', N'Activity', N'Screen', N'RiskManagement.view.PositionByPeriodSelection', N'small-menu-activity', 0, 0, 0, 1, 2, 1)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 2, strCommand = N'RiskManagement.view.PositionByPeriodSelection' WHERE strMenuName = 'Position by Period Selection' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Daily Position Inquiry' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Daily Position Inquiry', N'Risk Management', @RiskManagementActivitiesParentMenuId, N'Daily Position Inquiry', N'Activity', N'Screen', N'RiskManagement.view.DailyPositionInquiry', N'small-menu-activity', 0, 0, 0, 1, 3, 1)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 3, strCommand = N'RiskManagement.view.DailyPositionInquiry' WHERE strMenuName = 'Daily Position Inquiry' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Sourcing Report' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Sourcing Report', N'Risk Management', @RiskManagementActivitiesParentMenuId, N'Sourcing Report', N'Activity', N'Screen', N'RiskManagement.view.SourcingReport', N'small-menu-activity', 0, 0, 0, 1, 4, 1)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 4, strCommand = N'RiskManagement.view.SourcingReport' WHERE strMenuName = 'Sourcing Report' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Reconciliation Broker Statement' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Reconciliation Broker Statement', N'Risk Management', @RiskManagementActivitiesParentMenuId, N'Reconciliation Broker Statement', N'Activity', N'Screen', N'RiskManagement.view.ReconciliationBrokerStatement?showSearch=true', N'small-menu-activity', 0, 0, 0, 1, 5, 1)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 5, strCommand = N'RiskManagement.view.ReconciliationBrokerStatement?showSearch=true' WHERE strMenuName = 'Reconciliation Broker Statement' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Collateral' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Collateral', N'Risk Management', @RiskManagementActivitiesParentMenuId, N'Collateral', N'Activity', N'Screen', N'RiskManagement.view.Collateral?showSearch=true', N'small-menu-activity', 0, 0, 0, 1, 6, 1)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 6, strCommand = N'RiskManagement.view.Collateral?showSearch=true' WHERE strMenuName = 'Collateral' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Profit and Loss Analysis' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Profit and Loss Analysis', N'Risk Management', @RiskManagementActivitiesParentMenuId, N'Profit and Loss Analysis', N'Activity', N'Screen', N'RiskManagement.view.PhysicalPandLBySalesContract', N'small-menu-activity', 0, 0, 0, 1, 8, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 8, strCommand = N'RiskManagement.view.PhysicalPandLBySalesContract' WHERE strMenuName = 'Profit and Loss Analysis' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Position Change Analysis' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Position Change Analysis', N'Risk Management', @RiskManagementActivitiesParentMenuId, N'Position Change Analysis', N'Activity', N'Screen', N'RiskManagement.view.PositionChangeAnalysis', N'small-menu-activity', 0, 0, 0, 1, 9, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 9, strCommand = N'RiskManagement.view.PositionChangeAnalysis' WHERE strMenuName = 'Position Change Analysis' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementActivitiesParentMenuId
	
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Position Analysis Report' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Position Analysis Report', N'Risk Management', @RiskManagementActivitiesParentMenuId, N'Position Analysis Report', N'Activity', N'Screen', N'RiskManagement.view.PositionAnalysisReport', N'small-menu-activity', 0, 0, 0, 1, 10, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 10, strCommand = N'RiskManagement.view.PositionAnalysisReport' WHERE strMenuName = 'Position Analysis Report' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementActivitiesParentMenuId
	
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Currency Exposure' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Currency Exposure', N'Risk Management', @RiskManagementActivitiesParentMenuId, N'Currency Exposure', N'Activity', N'Screen', N'RiskManagement.view.CurrencyExposure?showSearch=true', N'small-menu-activity', 0, 0, 0, 1, 11, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 11, strCommand = N'RiskManagement.view.CurrencyExposure?showSearch=true' WHERE strMenuName = 'Currency Exposure' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Brokerage Accounts' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Brokerage Accounts', N'Risk Management', @RiskManagementMaintenanceParentMenuId, N'Brokerage Accounts', N'Maintenance', N'Screen', N'RiskManagement.view.BrokerageAccount?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 0, strCommand = N'RiskManagement.view.BrokerageAccount?showSearch=true' WHERE strMenuName = 'Brokerage Accounts' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'DPR Summary Log' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'DPR Summary Log', N'Risk Management', @RiskManagementMaintenanceParentMenuId, N'DPR Summary Log', N'Maintenance', N'Screen', N'RiskManagement.view.DPRSummaryLog?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 0, strCommand = N'RiskManagement.view.DPRSummaryLog?showSearch=true' WHERE strMenuName = 'DPR Summary Log' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementMaintenanceParentMenuId

--IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Currency Exposure' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementMaintenanceParentMenuId)
--	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
--	VALUES (N'Currency Exposure', N'Risk Management', @RiskManagementMaintenanceParentMenuId, N'Currency Exposure', N'Maintenance', N'Screen', N'RiskManagement.view.CurrencyExposure?showSearch=true', N'small-menu-maintenance', 1, 0, 0, 1, 1, 1)
--ELSE 
--	UPDATE tblSMMasterMenu SET intSort = 1, strCommand = N'RiskManagement.view.CurrencyExposure?showSearch=true' WHERE strMenuName = 'Currency Exposure' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Futures Broker' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId])
	VALUES (N'Futures Broker', N'Risk Management', @RiskManagementMaintenanceParentMenuId, N'Futures Broker', N'Maintenance', N'Screen', N'AccountsPayable.view.EntityVendor?showSearch=true&searchCommand=EntityFuturesBroker', N'small-menu-maintenance', 0, 0, 0, 1, 1, 1)
ELSE	
	UPDATE tblSMMasterMenu SET intSort = 1, strCommand = N'AccountsPayable.view.EntityVendor?showSearch=true&searchCommand=EntityFuturesBroker' WHERE strMenuName = 'Futures Broker' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Futures Markets' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Futures Markets', N'Risk Management', @RiskManagementMaintenanceParentMenuId, N'Futures Markets', N'Maintenance', N'Screen', N'RiskManagement.view.FuturesMarket?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 2, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 2, strCommand = N'RiskManagement.view.FuturesMarket?showSearch=true' WHERE strMenuName = 'Futures Markets' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Futures Price' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId])
	VALUES (N'Futures Price', N'Risk Management', @RiskManagementMaintenanceParentMenuId, N'Futures Price', N'Maintenance', N'Screen', N'RiskManagement.view.RollCost', N'small-menu-maintenance', 0, 0, 0, 1, 3, 1)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 3, strCommand = N'RiskManagement.view.RollCost' WHERE strMenuName = 'Futures Price' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Futures Trading Months' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Futures Trading Months', N'Risk Management', @RiskManagementMaintenanceParentMenuId, N'Futures Trading Months', N'Maintenance', N'Screen', N'RiskManagement.view.FuturesTradingMonths?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 4, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 4, strCommand = N'RiskManagement.view.FuturesTradingMonths?showSearch=true' WHERE strMenuName = 'Futures Trading Months' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'M2M Configuration' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'M2M Configuration', N'Risk Management', @RiskManagementMaintenanceParentMenuId, N'M2M Configuration', N'Maintenance', N'Screen', N'RiskManagement.view.MToMConfiguration', N'small-menu-maintenance', 0, 0, 0, 1, 5, 1)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 5, strCommand = N'RiskManagement.view.MToMConfiguration' WHERE strMenuName = 'M2M Configuration' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementMaintenanceParentMenuId

--IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Market Exchange' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementMaintenanceParentMenuId)
--	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId])
--	VALUES (N'Market Exchange', N'Risk Management', @RiskManagementMaintenanceParentMenuId, N'Market Exchange', N'Maintenance', N'Screen', N'RiskManagement.view.MarketExchange', N'small-menu-maintenance', 0, 0, 0, 1, 6, 1)
--ELSE
--	UPDATE tblSMMasterMenu SET intSort = 6, strCommand = N'RiskManagement.view.MarketExchange' WHERE strMenuName = 'Market Exchange' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Options Trading Months' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Options Trading Months', N'Risk Management', @RiskManagementMaintenanceParentMenuId, N'Options Trading Months', N'Maintenance', N'Screen', N'RiskManagement.view.OptionsTradingMonths?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 6, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 6, strCommand = N'RiskManagement.view.OptionsTradingMonths?showSearch=true' WHERE strMenuName = 'Options Trading Months' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Risk Rating Matrix' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Risk Rating Matrix', N'Risk Management', @RiskManagementMaintenanceParentMenuId, N'Risk Rating Matrix', N'Maintenance', N'Screen', N'RiskManagement.view.VendorPriceFixationLimit', N'small-menu-Maintenance', 0, 0, 0, 1, 7, 1)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 7, strCommand = N'RiskManagement.view.VendorPriceFixationLimit' WHERE strMenuName = 'Risk Rating Matrix' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Assign Derivatives' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementDerivativesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Assign Derivatives', N'Risk Management', @RiskManagementDerivativesParentMenuId, N'Assign Derivatives', N'Derivative', N'Screen', N'RiskManagement.view.AssignFuturesToContracts', N'small-menu-derivative', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 0, strCommand = N'RiskManagement.view.AssignFuturesToContracts' WHERE strMenuName = 'Assign Derivatives' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementDerivativesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Option Lifecycle' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementDerivativesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Option Lifecycle', N'Risk Management', @RiskManagementDerivativesParentMenuId, N'Option Lifecycle', N'Derivative', N'Screen', N'RiskManagement.view.OptionsLifecycle', N'small-menu-derivative', 0, 0, 0, 1, 1, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 1, strCommand = N'RiskManagement.view.OptionsLifecycle' WHERE strMenuName = 'Option Lifecycle' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementDerivativesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Mark To Market' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementDerivativesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Mark To Market', N'Risk Management', @RiskManagementDerivativesParentMenuId, N'Mark To Market', N'Derivative', N'Screen', N'RiskManagement.view.MarkToMarket?showSearch=true', N'small-menu-derivative', 0, 0, 0, 1, 2, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 2, strCommand = N'RiskManagement.view.MarkToMarket?showSearch=true' WHERE strMenuName = 'Mark To Market' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementDerivativesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Match Derivatives' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementDerivativesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Match Derivatives', N'Risk Management', @RiskManagementDerivativesParentMenuId, N'Match Derivatives', N'Derivative', N'Screen', N'RiskManagement.view.MatchDerivatives?showSearch=true', N'small-menu-derivative', 0, 0, 0, 1, 3, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 3, strCommand = N'RiskManagement.view.MatchDerivatives?showSearch=true' WHERE strMenuName = 'Match Derivatives' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementDerivativesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Settlement Price' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementDerivativesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Settlement Price', N'Risk Management', @RiskManagementDerivativesParentMenuId, N'Settlement Price', N'Derivative', N'Screen', N'RiskManagement.view.FuturesOptionsSettlementPrices?showSearch=true', N'small-menu-derivative', 0, 0, 0, 1, 4, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 4, strCommand = N'RiskManagement.view.FuturesOptionsSettlementPrices?showSearch=true' WHERE strMenuName = 'Settlement Price' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementDerivativesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Derivative Entry' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementDerivativesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Derivative Entry', N'Risk Management', @RiskManagementDerivativesParentMenuId, N'Derivative Entry', N'Derivative', N'Screen', N'RiskManagement.view.DerivativeEntry?showSearch=true', N'small-menu-derivative', 0, 0, 0, 1, 5, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 5, strCommand = N'RiskManagement.view.DerivativeEntry?showSearch=true' WHERE strMenuName = 'Derivative Entry' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementDerivativesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Futures 360' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementDerivativesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Futures 360', N'Risk Management', @RiskManagementDerivativesParentMenuId, N'Futures 360', N'Derivative', N'Screen', N'RiskManagement.view.Futures360', N'small-menu-derivative', 0, 0, 0, 1, 6, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 6, strCommand = N'RiskManagement.view.Futures360' WHERE strMenuName = 'Futures 360' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementDerivativesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Basis Entry' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementDerivativesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Basis Entry', N'Risk Management', @RiskManagementDerivativesParentMenuId, N'Basis Entry', N'Derivative', N'Screen', N'RiskManagement.view.BasisEntry?showSearch=true', N'small-menu-derivative', 0, 0, 0, 1, 7, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 7, strCommand = N'RiskManagement.view.BasisEntry?showSearch=true' WHERE strMenuName = 'Basis Entry' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementDerivativesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Daily Average Price' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementDerivativesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Daily Average Price', N'Risk Management', @RiskManagementDerivativesParentMenuId, N'Daily Average Price', N'Derivative', N'Screen', N'RiskManagement.view.DailyAveragePrice?showSearch=true', N'small-menu-derivative', 0, 0, 0, 1, 8, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 8, strCommand = N'RiskManagement.view.DailyAveragePrice?showSearch=true' WHERE strMenuName = 'Daily Average Price' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementDerivativesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Consolidated Profit/Loss' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Consolidated Profit/Loss', N'Risk Management', @RiskManagementReportParentMenuId, N'Consolidated Profit/Loss', N'Report', N'Screen', N'RiskManagement.view.ConsolidatedPNL', N'small-menu-report', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 0, strCommand = N'RiskManagement.view.ConsolidatedPNL' WHERE strMenuName = 'Consolidated Profit/Loss' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Position Reconciliation Report' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Position Reconciliation Report', N'Risk Management', @RiskManagementReportParentMenuId, N'Position Reconciliation Report', N'Report', N'Screen', N'RiskManagement.view.PositionReconciliationReport', N'small-menu-report', 0, 0, 0, 1, 1, 1)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 1, strCommand = N'RiskManagement.view.PositionReconciliationReport' WHERE strMenuName = 'Position Reconciliation Report' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Periodic Futures Clearing House Statement' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Periodic Futures Clearing House Statement', N'Risk Management', @RiskManagementReportParentMenuId, N'Periodic Futures Clearing House Statement', N'Report', N'Screen', N'Reporting.view.ReportManager?group=Risk Management&report=PeriodicFutClearingHouseStatement&direct=true', N'small-menu-report', 0, 0, 0, 1, 1, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 1, strCommand = N'Reporting.view.ReportManager?group=Risk Management&report=PeriodicFutClearingHouseStatement&direct=true' WHERE strMenuName = 'Periodic Futures Clearing House Statement' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Risk Report By Type' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Risk Report By Type', N'Risk Management', @RiskManagementReportParentMenuId, N'Risk Report By Type', N'Report', N'Screen', N'RiskManagement.view.RiskReportByType', N'small-menu-report', 0, 0, 0, 1, 2, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 2, strCommand = N'RiskManagement.view.RiskReportByType' WHERE strMenuName = 'Risk Report By Type' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'DPR Compare' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'DPR Compare', N'Risk Management', @RiskManagementReportParentMenuId, N'DPR Compare', N'Report', N'Screen', N'RiskManagement.view.DPRCompare', N'small-menu-report', 1, 0, 0, 1, 2, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 2, strCommand = N'RiskManagement.view.DPRCompare' WHERE strMenuName = 'DPR Compare' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Realized Profit/Loss' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Realized Profit/Loss', N'Risk Management', @RiskManagementReportParentMenuId, N'Realized Profit/Loss', N'Report', N'Screen', N'RiskManagement.view.RealizedPNL', N'small-menu-report', 0, 0, 0, 1, 3, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 3, strCommand = N'RiskManagement.view.RealizedPNL' WHERE strMenuName = 'Realized Profit/Loss' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Daily Position Report' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Daily Position Report', N'Risk Management', @RiskManagementReportParentMenuId, N'Daily Position Report', N'Report', N'Screen', N'RiskManagement.view.PositionReport?isReport=true', N'small-menu-report', 0, 0, 0, 1, 1, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 1, strCommand = N'RiskManagement.view.PositionReport?isReport=true' WHERE strMenuName = 'Daily Position Report' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementReportParentMenuId
/* START OF DELETE */
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Futures/Options Settlement Prices' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Futures Options Transactions' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Match Futures Purchase & Sales' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Option Lifecycle' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Futures360' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'M2M Entry' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName IN ('Mark To Market', 'M2M Inquiry') AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Assign Futures To Contracts' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Currency Contract' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Customer Position Inquiry' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementActivitiesParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'M2M Configuration' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementActivitiesParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Derivative Screen' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementActivitiesParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Risk Rating Matrix' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementActivitiesParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Brokerage Accounts' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementActivitiesParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Futures Markets' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementActivitiesParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Market Exchange' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Currency Exposure' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementMaintenanceParentMenuId

/* END OF DELETE */

/* TICKET MANAGEMENT */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Ticket Management' AND strModuleName = 'Ticket Management' AND intParentMenuID = 0)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Ticket Management', N'Ticket Management', 0, N'Ticket Management', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 14, 0)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 14 WHERE strMenuName = 'Ticket Management' AND strModuleName = 'Ticket Management' AND intParentMenuID = 0

DECLARE @TicketManagementParentMenuId INT
SELECT @TicketManagementParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Ticket Management' AND strModuleName = 'Ticket Management' AND intParentMenuID = 0

/* CATEGORY FOLDERS */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Activities' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Activities', N'Ticket Management', @TicketManagementParentMenuId, N'Activities', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 0 WHERE strMenuName = 'Activities' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementParentMenuId

DECLARE @TicketManagementActivitiesParentMenuId INT
SELECT @TicketManagementActivitiesParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Activities' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Maintenance', N'Ticket Management', @TicketManagementParentMenuId, N'Maintenance', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 1, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 1 WHERE strMenuName = 'Maintenance' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementParentMenuId

DECLARE @TicketManagementMaintenanceParentMenuId INT
SELECT @TicketManagementMaintenanceParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Reports' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Reports', N'Ticket Management', @TicketManagementParentMenuId, N'Reports', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 2, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 2 WHERE strMenuName = 'Reports' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementParentMenuId

DECLARE @TicketManagementReportParentMenuId INT
SELECT @TicketManagementReportParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Reports' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Create' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementParentMenuId)
   	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intRow], [intConcurrencyId]) 
    VALUES (N'Create', N'Ticket Management', @TicketManagementParentMenuId, N'Create', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 0, 1, 1)
ELSE
    UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 0, intRow = 1 WHERE strMenuName = 'Create' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementParentMenuId

DECLARE @TicketManagementCreateParentMenuId INT
SELECT @TicketManagementCreateParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Create' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementParentMenuId

/* ADD TO RESPECTIVE CATEGORY */ 
UPDATE tblSMMasterMenu SET intParentMenuID = @TicketManagementActivitiesParentMenuId WHERE intParentMenuID =  @TicketManagementParentMenuId AND strCategory = 'Activity'
UPDATE tblSMMasterMenu SET intParentMenuID = @TicketManagementMaintenanceParentMenuId WHERE intParentMenuID =  @TicketManagementParentMenuId AND strCategory = 'Maintenance'

-- START OF RENAMING
UPDATE tblSMMasterMenu SET strMenuName = N'Tickets' WHERE strMenuName = 'Enter Tickets' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementActivitiesParentMenuId
UPDATE tblSMMasterMenu SET strMenuName = 'Production Evidence' WHERE strMenuName = 'Production Evidence Report' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementReportParentMenuId
UPDATE tblSMMasterMenu SET strMenuName = 'Canadian Storage Receipt', strDescription = 'Canadian Storage Receipt' WHERE strMenuName = 'Storage Statement' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementMaintenanceParentMenuId
UPDATE tblSMMasterMenu SET strMenuName = 'Production History', strDescription = 'Production History' WHERE strMenuName = 'Production Evidence' AND strDescription = 'Production Evidence' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementReportParentMenuId
UPDATE tblSMMasterMenu SET strMenuName = 'Production History by Delivery Sheet', strDescription = 'Production History by Delivery Sheet' WHERE strMenuName = 'Production Evidence by Delivery Sheet' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementReportParentMenuId
-- END OF RENAMING

-- START MOVE CATEGORY
UPDATE tblSMMasterMenu SET intParentMenuID = @TicketManagementActivitiesParentMenuId WHERE strMenuName = 'Delivery Sheets' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementMaintenanceParentMenuId
-- END MOVE CATEGORY

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Tickets' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Tickets', N'Ticket Management', @TicketManagementActivitiesParentMenuId, N'Tickets', N'Activity', N'Screen', N'Grain.view.ScaleStationSelection?showSearch=true', N'small-menu-activity', 0, 0, 0, 1, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'Grain.view.ScaleStationSelection?showSearch=true', intSort = 0 WHERE strMenuName = 'Tickets' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Zero Priced Spot Tickets' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Zero Priced Spot Tickets', N'Ticket Management', @TicketManagementActivitiesParentMenuId, N'Tickets', N'Activity', N'Screen', N'Grain.view.ZeroPricedSpotTickets?showSearch=true', N'small-menu-activity', 0, 0, 0, 1, 1, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'Grain.view.ZeroPricedSpotTickets?showSearch=true', intSort = 1 WHERE strMenuName = 'Zero Priced Spot Tickets' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Storage' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Storage', N'Ticket Management', @TicketManagementActivitiesParentMenuId, N'Storage', N'Activity', N'Screen', N'Grain.view.Storage?showSearch=true', N'small-menu-activity', 0, 0, 0, 1, 2, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Grain.view.Storage?showSearch=true', intSort = 2, strCategory = N'Activity' WHERE strMenuName = 'Storage' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Delivery Sheets' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId])
	VALUES (N'Delivery Sheets', N'Ticket Management', @TicketManagementActivitiesParentMenuId, N'Delivery Sheets', N'Activity', N'Screen', N'Grain.view.DeliverySheet?showSearch=true', N'small-menu-activity', 0, 0, 0, 1, 3, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = N'Grain.view.DeliverySheet?showSearch=true', intSort = 3, strCategory = 'Activity', strIcon = 'small-menu-activity' WHERE strMenuName = 'Delivery Sheets' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Seal Numbers' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementActivitiesParentMenuId)	
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId])
	VALUES (N'Seal Numbers', N'Ticket Management', @TicketManagementActivitiesParentMenuId, N'Seal Numbers', N'Activity', N'Screen', N'Grain.view.TicketSealNumber', N'small-menu-activity', 0, 0, 0, 1, 4, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = N'Grain.view.TicketSealNumber', intSort = 3, strCategory = 'Activity', strIcon = 'small-menu-activity' WHERE strMenuName = 'Seal Numbers' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Canadian Storage Receipt' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Canadian Storage Receipt', N'Ticket Management', @TicketManagementMaintenanceParentMenuId, N'Canadian Storage Receipt', N'Maintenance', N'Screen', N'Grain.view.StorageStatement?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'Grain.view.StorageStatement?showSearch=true', intSort = 0 WHERE strMenuName = 'Canadian Storage Receipt' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Discounts' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Discounts', N'Ticket Management', @TicketManagementMaintenanceParentMenuId, N'Discounts', N'Maintenance', N'Screen', N'Grain.view.DiscountTable?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 1, 1)
ELSE 
    UPDATE tblSMMasterMenu SET strCommand = N'Grain.view.DiscountTable?showSearch=true', intSort = 1 WHERE strMenuName = 'Discounts' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Discount Types' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Discount Types', N'Ticket Management', @TicketManagementMaintenanceParentMenuId, N'Discount Types', N'Maintenance', N'Screen', N'Grain.view.DiscountType', N'small-menu-maintenance', 0, 0, 0, 1, 2, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = N'Grain.view.DiscountType', intSort = 1 WHERE strMenuName = 'Discount Type' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Grading Equipment' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Grading Equipment', N'Ticket Management', @TicketManagementMaintenanceParentMenuId, N'Grading Equipment', N'Maintenance', N'Screen', N'Grain.view.GradingEquipment?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 2, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'Grain.view.GradingEquipment?showSearch=true', intSort = 2 WHERE strMenuName = 'Grading Equipment' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Physical Scales' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Physical Scales', N'Ticket Management', @TicketManagementMaintenanceParentMenuId, N'Physical Scales', N'Maintenance', N'Screen', N'Grain.view.PhysicalScale?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 3, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'Grain.view.PhysicalScale?showSearch=true',  intSort = 3 WHERE strMenuName = 'Physical Scales' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Scale Station Settings' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Scale Station Settings', N'Ticket Management', @TicketManagementMaintenanceParentMenuId, N'Scale Station Settings', N'Maintenance', N'Screen', N'Grain.view.ScaleStationSettings?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 4, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'Grain.view.ScaleStationSettings?showSearch=true', intSort = 4 WHERE strMenuName = 'Scale Station Settings' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Storage Schedule' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Storage Schedule', N'Ticket Management', @TicketManagementMaintenanceParentMenuId, N'Storage Schedule', N'Maintenance', N'Screen', N'Grain.view.StorageSchedule?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 5, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Grain.view.StorageSchedule?showSearch=true', intSort = 5 WHERE strMenuName = 'Storage Schedule' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Storage Types' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Storage Types', N'Ticket Management', @TicketManagementMaintenanceParentMenuId, N'Storage Types', N'Maintenance', N'Screen', N'Grain.view.GrainStorageType', N'small-menu-maintenance', 0, 0, 0, 1, 6, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Grain.view.GrainStorageType', intSort = 6 WHERE strMenuName = 'Storage Types' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Ticket Formats' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Ticket Formats', N'Ticket Management', @TicketManagementMaintenanceParentMenuId, N'Ticket Format', N'Maintenance', N'Screen', N'Grain.view.TicketFormats', N'small-menu-maintenance', 0, 0, 0, 1, 7, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'Grain.view.TicketFormats', intSort = 7 WHERE strMenuName = 'Ticket Formats' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Ticket Pools' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Ticket Pools', N'Ticket Management', @TicketManagementMaintenanceParentMenuId, N'Ticket Pools', N'Maintenance', N'Screen', N'Grain.view.TicketPool?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 8, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'Grain.view.TicketPool?showSearch=true', intSort = 8 WHERE strMenuName = 'Ticket Pools' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Accrued Storage' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Accrued Storage', N'Ticket Management', @TicketManagementReportParentMenuId, N'Accrued Storage Description', N'Report', N'Screen', N'Reporting.view.ReportManager?group=Grain&report=AccruedStorage&direct=true&showCriteria=true', N'small-menu-report', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 0, strDescription = N'Accrued Storage Description', strCommand = N'Reporting.view.ReportManager?group=Grain&report=AccruedStorage&direct=true&showCriteria=true' WHERE strMenuName = 'Accrued Storage' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Grain Inventory Inquiry' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementReportParentMenuId)
    INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
    VALUES (N'Grain Inventory Inquiry', N'Ticket Management', @TicketManagementReportParentMenuId, N'Grain Inventory Inquiry Description', N'Report', N'Screen', N'Grain.view.GrainInventoryInquiry', N'small-menu-report', 0, 0, 0, 1, 1, 1)
ELSE 
    UPDATE tblSMMasterMenu SET intSort = 1, strDescription = N'Grain Inventory Inquiry', strCommand = N'Grain.view.GrainInventoryInquiry' WHERE strMenuName = 'Grain Inventory Inquiry' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Production Evidence' AND strDescription = 'Production Evidence Description' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Production Evidence', N'Ticket Management', @TicketManagementReportParentMenuId, N'Production Evidence Description', N'Report', N'Screen', N'Reporting.view.ReportManager?group=Ticket Management&report=ProductionEvidenceReport&direct=true', N'small-menu-report', 0, 0, 0, 1, 2, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 2, strCommand = N'Reporting.view.ReportManager?group=Ticket Management&report=ProductionEvidenceReport&direct=true' WHERE strMenuName = 'Production Evidence' AND strDescription = 'Production Evidence Description' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Production History' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Production History', N'Ticket Management', @TicketManagementReportParentMenuId, N'Production History', N'Report', N'Screen', N'Reporting.view.ReportManager?group=Ticket Management&report=ProductionHistoryReport&direct=true', N'small-menu-report', 0, 0, 0, 1, 3, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 3, strCommand = N'Reporting.view.ReportManager?group=Ticket Management&report=ProductionHistoryReport&direct=true' WHERE strMenuName = 'Production History' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Production History by Delivery Sheet' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Production History by Delivery Sheet', N'Ticket Management', @TicketManagementReportParentMenuId, N'Production History by Delivery Sheet', N'Report', N'Screen', N'Reporting.view.ReportManager?group=Ticket Management&report=ProductionEvidenceReportByDeliverySheet&direct=true', N'small-menu-report', 0, 0, 0, 1, 4, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 4, strCommand = N'Reporting.view.ReportManager?group=Ticket Management&report=ProductionEvidenceReportByDeliverySheet&direct=true' WHERE strMenuName = 'Production History by Delivery Sheet' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementReportParentMenuId

--IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Scale Activity' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementReportParentMenuId)
--	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
--	VALUES (N'Scale Activity', N'Ticket Management', @TicketManagementReportParentMenuId, N'Scale Activity', N'Report', N'Screen', N'Scale Activity Report', N'small-menu-report', 0, 0, 0, 1, 3, 1)
--ELSE 
--	UPDATE tblSMMasterMenu SET intSort = 3, strCommand = N'Scale Activity Report' WHERE strMenuName = 'Scale Activity' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Storage By Discount Factor' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Storage By Discount Factor', N'Ticket Management', @TicketManagementReportParentMenuId, N'Storage By Discount Factor', N'Report', N'Screen', N'Reporting.view.ReportManager?group=Grain&report=StorageByDiscountFactor&direct=true&showCriteria=true', N'small-menu-report', 0, 0, 0, 1, 5, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 5, strCommand = N'Reporting.view.ReportManager?group=Grain&report=StorageByDiscountFactor&direct=true&showCriteria=true' WHERE strMenuName = 'Storage By Discount Factor' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Storage By Grades' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Storage By Grades', N'Ticket Management', @TicketManagementReportParentMenuId, N'Storage By Grades', N'Report', N'Screen', N'Reporting.view.ReportManager?group=Grain&report=StorageByGrades&direct=true&showCriteria=true', N'small-menu-report', 0, 0, 0, 1, 6, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 6, strCommand = N'Reporting.view.ReportManager?group=Grain&report=StorageByGrades&direct=true&showCriteria=true' WHERE strMenuName = 'Storage By Grades' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementReportParentMenuId

--IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Unsent Tickets' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementReportParentMenuId)
--	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
--	VALUES (N'Unsent Tickets', N'Ticket Management', @TicketManagementReportParentMenuId, N'Unsent Tickets', N'Report', N'Screen', N'Unsent Tickets Report', N'small-menu-report', 0, 0, 0, 1, 6, 1)
--ELSE 
--	UPDATE tblSMMasterMenu SET intSort = 6, strCommand = N'Unsent Tickets Report' WHERE strMenuName = 'Unsent Tickets' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'New Ticket' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementCreateParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intRow], [intConcurrencyId]) 
	VALUES (N'New Ticket', N'Ticket Management', @TicketManagementCreateParentMenuId, N'New Ticket', N'Create', N'Screen', N'Grain.view.ScaleStationSelection?action=new', N'small-menu-create', 0, 0, 0, 1, 0, 1, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 0, strCommand = N'Grain.view.ScaleStationSelection?action=new' WHERE strMenuName = 'New Ticket' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementCreateParentMenuId

/* START OF DELETING */
DELETE FROM tblSMMasterMenu WHERE strMenuName IN('Discount Tables','Discount Schedules')
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'OffSite' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Storage' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Scale Activity' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementReportParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Unsent Tickets' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementReportParentMenuId
/* END OF DELETING */

/* LOGISTICS */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Logistics' AND strModuleName = 'Logistics' AND intParentMenuID = 0)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Logistics', N'Logistics', 0, N'Logistics', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 15, 2)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 15 WHERE strMenuName = 'Logistics' AND strModuleName = 'Logistics' AND intParentMenuID = 0

DECLARE @LogisticsParentMenuId INT
SELECT @LogisticsParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Logistics' AND strModuleName = 'Logistics' AND intParentMenuID = 0

/* CHANGE SCREEN CATEGORY 1730 TO 1810 */
UPDATE tblSMMasterMenu SET strCategory = 'Report', strIcon = 'small-menu-report' WHERE strMenuName IN ('Track Shipments/Documents') AND strModuleName = N'Logistics'

/* CATEGORY FOLDERS */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Activities' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Activities', N'Logistics', @LogisticsParentMenuId, N'Activities', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = NULL WHERE strMenuName = 'Activities' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsParentMenuId

DECLARE @LogisticsActivitiesParentMenuId INT
SELECT @LogisticsActivitiesParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Activities' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Maintenance', N'Logistics', @LogisticsParentMenuId, N'Maintenance', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 1, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 1 WHERE strMenuName = 'Maintenance' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsParentMenuId

DECLARE @LogisticsMaintenanceParentMenuId INT
SELECT @LogisticsMaintenanceParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Report' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Report', N'Logistics', @LogisticsParentMenuId, N'Report', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 2, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 2 WHERE strMenuName = 'Report' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsParentMenuId

DECLARE @LogisticsReportParentMenuId INT
SELECT @LogisticsReportParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Report' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsParentMenuId

/* ADD TO RESPECTIVE CATEGORY */ 
UPDATE tblSMMasterMenu SET intParentMenuID = @LogisticsActivitiesParentMenuId WHERE intParentMenuID =  @LogisticsParentMenuId AND strCategory = 'Activity'
UPDATE tblSMMasterMenu SET intParentMenuID = @LogisticsMaintenanceParentMenuId WHERE intParentMenuID =  @LogisticsParentMenuId AND strCategory = 'Maintenance'
UPDATE tblSMMasterMenu SET intParentMenuID = @LogisticsReportParentMenuId WHERE strModuleName = 'Logistics' AND strCategory = 'Report'

/* START OF PLURALIZING */
UPDATE tblSMMasterMenu SET strMenuName = 'Load Schedules', strDescription = 'Load Schedules' WHERE strMenuName = 'Load Schedule' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsActivitiesParentMenuId
UPDATE tblSMMasterMenu SET strMenuName = 'Container Types', strDescription = 'Container Types' WHERE strMenuName = 'Container Type' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsMaintenanceParentMenuId
UPDATE tblSMMasterMenu SET strMenuName = 'Shipping Lines', strDescription = 'Shipping Lines' WHERE strMenuName = 'Shipping Line' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsActivitiesParentMenuId
UPDATE tblSMMasterMenu SET strMenuName = 'Forwarding Agents', strDescription = 'Forwarding Agents' WHERE strMenuName = 'Forwarding Agent' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsMaintenanceParentMenuId
UPDATE tblSMMasterMenu SET strMenuName = 'Truckers', strDescription = 'Truckers' WHERE strMenuName = 'Trucker' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsMaintenanceParentMenuId
UPDATE tblSMMasterMenu SET strMenuName = 'Terminals', strDescription = 'Terminals' WHERE strMenuName = 'Terminal' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsMaintenanceParentMenuId
/* END OF PLURALIZING */

/* START OF RENAMING  */
UPDATE tblSMMasterMenu SET strMenuName = 'Mass Dispatch Loads' WHERE strMenuName = 'Dispatch Loads' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsActivitiesParentMenuId
UPDATE tblSMMasterMenu SET strMenuName = 'Load / Shipment Schedules', strDescription = 'Load / Shipment Schedules' WHERE strMenuName = 'Load Schedules' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsActivitiesParentMenuId
UPDATE tblSMMasterMenu SET strMenuName = 'Unallocated Inventory and Open Contracts', strDescription = 'Unallocated Inventory and Open Contracts' WHERE strMenuName = 'Unallocated Inventory' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsReportParentMenuId
/* END OF RENAMING  */

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Allocations' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Allocations', N'Logistics', @LogisticsActivitiesParentMenuId, N'Allocations', N'Activity', N'Screen', N'Logistics.view.Allocation?showSearch=true', N'small-menu-activity', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Logistics.view.Allocation?showSearch=true', intSort = 0 WHERE strMenuName = 'Allocations' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Load / Shipment Schedules' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Load / Shipment Schedules', N'Logistics', @LogisticsActivitiesParentMenuId, N'Logistics', N'Activity', N'Screen', N'Logistics.view.ShipmentSchedule?showSearch=true', N'small-menu-activity', 0, 0, 0, 1, 1, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Logistics.view.ShipmentSchedule?showSearch=true', intSort = 1 WHERE strMenuName = 'Load / Shipment Schedules' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Pick Lots' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Pick Lots', N'Logistics', @LogisticsActivitiesParentMenuId, N'Pick Lots', N'Activity', N'Screen', N'Logistics.view.PickLot?showSearch=true', N'small-menu-activity', 0, 0, 0, 1, 2, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Logistics.view.PickLot?showSearch=true', intSort = 2 WHERE strMenuName = 'Pick Lots' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Stock Sales' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Stock Sales', N'Logistics', @LogisticsActivitiesParentMenuId, N'Stock Sales', N'Activity', N'Screen', N'Logistics.view.StockSales?showSearch=true', N'small-menu-activity', 0, 0, 0, 1, 3, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Logistics.view.StockSales?showSearch=true', intSort = 3 WHERE strMenuName = 'Stock Sales' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Least Cost Routing' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Least Cost Routing', N'Logistics', @LogisticsActivitiesParentMenuId, N'Least Cost Routing', N'Activity', N'Screen', N'Logistics.view.LeastCostRouting?showSearch=true', N'small-menu-activity', 0, 0, 0, 1, 4, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Logistics.view.LeastCostRouting?showSearch=true', intSort = 4 WHERE strMenuName = 'Least Cost Routing' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Weight Claims' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Weight Claims', N'Logistics', @LogisticsActivitiesParentMenuId, N'Weight Claims', N'Activity', N'Screen', N'Logistics.view.WeightClaims?showSearch=true', N'small-menu-activity', 0, 0, 0, 1, 5, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Logistics.view.WeightClaims?showSearch=true', intSort = 5 WHERE strMenuName = 'Weight Claims' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Container Types' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Container Types', N'Logistics', @LogisticsMaintenanceParentMenuId, N'Container Types', N'Maintenance', N'Screen', N'Logistics.view.ContainerType?showSearch=true', N'small-menu-Maintenance', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Logistics.view.ContainerType?showSearch=true', intSort = 0 WHERE strMenuName = 'Container Types' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Equipment Type' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Equipment Type', N'Logistics', @LogisticsMaintenanceParentMenuId, N'Equipment Type', N'Maintenance', N'Screen', N'Logistics.view.EquipmentType', N'small-menu-maintenance', 0, 0, 0, 1, 1, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 1, strCommand = N'Logistics.view.EquipmentType' WHERE strMenuName = 'Equipment Type' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Forwarding Agents' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Forwarding Agents', N'Logistics', @LogisticsMaintenanceParentMenuId, N'Forwarding Agents', N'Maintenance', N'Screen', N'AccountsPayable.view.EntityVendor?showSearch=true&searchCommand=EntityForwardingAgent', N'small-menu-maintenance', 0, 0, 0, 1, 2, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 2, strCommand = N'AccountsPayable.view.EntityVendor?showSearch=true&searchCommand=EntityForwardingAgent' WHERE strMenuName = 'Forwarding Agents' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Freight Rate Matrix' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Freight Rate Matrix', N'Logistics', @LogisticsMaintenanceParentMenuId, N'Freight Rate Matrix', N'Maintenance', N'Screen', N'Logistics.view.FreightRateMatrix', N'small-menu-maintenance', 0, 0, 0, 1, 3, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 3, strCommand = N'Logistics.view.FreightRateMatrix' WHERE strMenuName = 'Freight Rate Matrix' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Insurer' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Insurer', N'Logistics', @LogisticsMaintenanceParentMenuId, N'Insurer', N'Maintenance', N'Screen', N'AccountsPayable.view.EntityVendor?showSearch=true&searchCommand=EntityInsurer', N'small-menu-maintenance', 0, 0, 0, 1, 4, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 4, strCommand = N'AccountsPayable.view.EntityVendor?showSearch=true&searchCommand=EntityInsurer' WHERE strMenuName = 'Insurer' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Reason Code' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Reason Code', N'Logistics', @LogisticsMaintenanceParentMenuId, N'Reason Code', N'Maintenance', N'Screen', N'Logistics.view.ReasonCode', N'small-menu-maintenance', 0, 0, 0, 1, 5, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 5, strCommand = N'Logistics.view.ReasonCode' WHERE strMenuName = 'Reason Code' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Shipping Lines' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Shipping Lines', N'Logistics', @LogisticsMaintenanceParentMenuId, N'Shipping Lines', N'Maintenance', N'Screen', N'AccountsPayable.view.EntityVendor?showSearch=true&searchCommand=EntityShippingLine', N'small-menu-maintenance', 0, 0, 0, 1, 6, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 6, strCommand = N'AccountsPayable.view.EntityVendor?showSearch=true&searchCommand=EntityShippingLine' WHERE strMenuName = 'Shipping Lines' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Shipping Mode' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Shipping Mode', N'Logistics', @LogisticsMaintenanceParentMenuId, N'Shipping Mode', N'Maintenance', N'Screen', N'Logistics.view.ShippingMode', N'small-menu-maintenance', 0, 0, 0, 1, 7, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 7, strCommand = N'Logistics.view.ShippingMode' WHERE strMenuName = 'Shipping Mode' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Terminals' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Terminals', N'Logistics', @LogisticsMaintenanceParentMenuId, N'Terminals', N'Maintenance', N'Screen', N'AccountsPayable.view.EntityVendor?showSearch=true&searchCommand=EntityTerminal', N'small-menu-maintenance', 0, 0, 0, 1, 8, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 8, strCommand = N'AccountsPayable.view.EntityVendor?showSearch=true&searchCommand=EntityTerminal' WHERE strMenuName = 'Terminals' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Warehouse Rate Matrix' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Warehouse Rate Matrix', N'Logistics', @LogisticsMaintenanceParentMenuId, N'Warehouse Rate Matrix', N'Maintenance', N'Screen', N'Logistics.view.WarehouseRateMatrix?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 9, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 9, strCommand = N'Logistics.view.WarehouseRateMatrix?showSearch=true' WHERE strMenuName = 'Warehouse Rate Matrix' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Insurance Premium Factor' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Insurance Premium Factor', N'Logistics', @LogisticsMaintenanceParentMenuId, N'Insurance Premium Factor', N'Maintenance', N'Screen', N'Logistics.view.InsurancePremiumFactor?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 10, 1)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 10, strCommand = N'Logistics.view.InsurancePremiumFactor?showSearch=true' WHERE strMenuName = 'Insurance Premium Factor' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Shipping Line Service Contract' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Shipping Line Service Contract', N'Logistics', @LogisticsMaintenanceParentMenuId, N'Shipping Line Service Contract', N'Maintenance', N'Screen', N'Logistics.view.ShippingLineServiceContract?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 11, 1)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 11, strCommand = N'Logistics.view.ShippingLineServiceContract?showSearch=true' WHERE strMenuName = 'Shipping Line Service Contract' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Allocated' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Allocated', N'Logistics', @LogisticsReportParentMenuId, N'Allocated', N'Report', N'Screen', N'Logistics.view.AllocatedReport?showSearch=true', N'small-menu-report', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 0, strCommand = N'Logistics.view.AllocatedReport?showSearch=true' WHERE strMenuName = 'Allocated' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Allocated Inventory' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Allocated Inventory', N'Logistics', @LogisticsReportParentMenuId, N'Allocated Inventory', N'Report', N'Screen', N'Logistics.view.AllocatedInventoryReport?showSearch=true', N'small-menu-report', 0, 0, 0, 1, 1, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 1, strCommand = N'Logistics.view.AllocatedInventoryReport?showSearch=true' WHERE strMenuName = 'Allocated Inventory' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Delivered Not Invoiced' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Delivered Not Invoiced', N'Logistics', @LogisticsReportParentMenuId, N'Delivered Not Invoiced', N'Report', N'Screen', N'Logistics.view.DeliveredNotInvoicedReport?showSearch=true', N'small-menu-report', 0, 0, 0, 1, 2, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 2, strCommand = N'Logistics.view.DeliveredNotInvoicedReport?showSearch=true' WHERE strMenuName = 'Delivered Not Invoiced' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Inventory View' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Inventory View', N'Logistics', @LogisticsReportParentMenuId, N'Inventory View', N'Report', N'Screen', N'Logistics.view.InventoryViewReport?showSearch=true', N'small-menu-report', 0, 0, 0, 1, 3, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 3, strCommand = N'Logistics.view.InventoryViewReport?showSearch=true' WHERE strMenuName = 'Inventory View' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Track Shipments/Documents' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Track Shipments/Documents', N'Logistics', @LogisticsReportParentMenuId, N'Track Shipments/Documents', N'Report', N'Screen', N'Logistics.view.ShipmentTracking?showSearch=true', N'small-menu-report', 0, 0, 0, 1, 4, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 4, strCommand = N'Logistics.view.ShipmentTracking?showSearch=true' WHERE strMenuName = 'Track Shipments/Documents' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Unallocated' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Unallocated', N'Logistics', @LogisticsReportParentMenuId, N'Unallocated', N'Report', N'Screen', N'Logistics.view.UnallocatedReport?showSearch=true', N'small-menu-report', 0, 0, 0, 1, 5, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 5, strCommand = N'Logistics.view.UnallocatedReport?showSearch=true' WHERE strMenuName = 'Unallocated' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Unallocated Inventory and Open Contracts' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Unallocated Inventory and Open Contracts', N'Logistics', @LogisticsReportParentMenuId, N'Unallocated Inventory and Open Contracts', N'Report', N'Screen', N'Logistics.view.UnallocatedInventoryReport?showSearch=true', N'small-menu-report', 0, 0, 0, 1, 6, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 6, strCommand = N'Logistics.view.UnallocatedInventoryReport?showSearch=true' WHERE strMenuName = 'Unallocated Inventory and Open Contracts' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Contract vs Market Differential Analysis' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsReportParentMenuId)
    INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
    VALUES (N'Contract vs Market Differential Analysis', N'Logistics', @LogisticsReportParentMenuId, N'Contract vs Market Differential Analysis', N'Report', N'Screen', N'Logistics.view.ContractVsMarketDifferential', N'small-menu-report', 0, 0, 0, 1, 7, 1)
ELSE
    UPDATE tblSMMasterMenu SET intSort = 6, strCommand = N'Logistics.view.ContractVsMarketDifferential' WHERE strMenuName = 'Contract vs Market Differential Analysis' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsReportParentMenuId
/* START OF DELETING */
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Allocated Contracts List' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Unallocated Contracts List' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Shipments List' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Generate Loads' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Delivery Orders' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Mass Dispatch Loads' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Shipping Instructions' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Inbound Shipments' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Truckers' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Warehouse Rate Matrix' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsActivitiesParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Container Types' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsActivitiesParentMenuId
/* END OF DELETING */

/* MANUFACTURING */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Manufacturing' AND strModuleName = 'Manufacturing' AND intParentMenuID = 0)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Manufacturing', N'Manufacturing', 0, N'Manufacturing', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 16, 0)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 16 WHERE strMenuName = 'Manufacturing' AND strModuleName = 'Manufacturing' AND intParentMenuID = 0

DECLARE @ManufacturingParentMenuId INT
SELECT @ManufacturingParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Manufacturing' AND strModuleName = 'Manufacturing' AND intParentMenuID = 0

/* CATEGORY FOLDERS */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Activities' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intRow], [intConcurrencyId]) 
	VALUES (N'Activities', N'Manufacturing', @ManufacturingParentMenuId, N'Activities', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 0, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 0, intRow = 0 WHERE strMenuName = 'Activities' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingParentMenuId

DECLARE @ManufacturingActivitiesParentMenuId INT
SELECT @ManufacturingActivitiesParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Activities' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intRow], [intConcurrencyId]) 
	VALUES (N'Maintenance', N'Manufacturing', @ManufacturingParentMenuId, N'Maintenance', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 1, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 1, intRow = 0 WHERE strMenuName = 'Maintenance' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingParentMenuId

DECLARE @ManufacturingMaintenanceParentMenuId INT
SELECT @ManufacturingMaintenanceParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Views' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intRow], [intConcurrencyId]) 
	VALUES (N'Views', N'Manufacturing', @ManufacturingParentMenuId, N'Views', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 2, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 2, intRow = 0 WHERE strMenuName = 'Views' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingParentMenuId

DECLARE @ManufacturingViewParentMenuId INT
SELECT @ManufacturingViewParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Views' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Reports' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intRow], [intConcurrencyId]) 
	VALUES (N'Reports', N'Manufacturing', @ManufacturingParentMenuId, N'Reports', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 3, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 3, intRow = 0 WHERE strMenuName = 'Reports' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingParentMenuId

DECLARE @ManufacturingReportParentMenuId INT
SELECT @ManufacturingReportParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Reports' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingParentMenuId

/* ADD TO RESPECTIVE CATEGORY */ 
UPDATE tblSMMasterMenu SET intParentMenuID = @ManufacturingActivitiesParentMenuId WHERE intParentMenuID =  @ManufacturingParentMenuId AND strCategory = 'Activity'
UPDATE tblSMMasterMenu SET intParentMenuID = @ManufacturingMaintenanceParentMenuId WHERE intParentMenuID =  @ManufacturingParentMenuId AND strCategory = 'Maintenance'
UPDATE tblSMMasterMenu SET intParentMenuID = @ManufacturingViewParentMenuId WHERE intParentMenuID =  @ManufacturingParentMenuId AND strCategory = 'View'
UPDATE tblSMMasterMenu SET intParentMenuID = @ManufacturingReportParentMenuId WHERE intParentMenuID =  @ManufacturingParentMenuId AND strCategory = 'Report'

/* START OF PLURALIZING */
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Blend Requirement' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingActivitiesParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Blend Requirements', strDescription = 'Blend Requirements' WHERE strMenuName = 'Blend Requirement' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingActivitiesParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Bag Offs' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingActivitiesParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Bag Off', strDescription = 'Bag Off' WHERE strMenuName = 'Bag Offs' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingActivitiesParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Recipe' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Recipes', strDescription = 'Recipes' WHERE strMenuName = 'Recipe' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingMaintenanceParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Manufacturing Cell' AND strModuleName = 'Inventory' AND intParentMenuID = @ManufacturingMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Manufacturing Cells', strDescription = 'Manufacturing Cells' WHERE strMenuName = 'Manufacturing Cell' AND strModuleName = 'Inventory' AND intParentMenuID = @ManufacturingMaintenanceParentMenuId
/* END OF PLURALIZING */

/* Start of Rename and Remodule */
UPDATE tblSMMasterMenu SET strMenuName = 'Item Receive Life & Custom Label', strDescription = 'Item Receive Life & Custom Label' where strModuleName = 'Manufacturing' AND strCommand = 'Manufacturing.view.ReceiveLife'
UPDATE tblSMMasterMenu SET intParentMenuID = @ManufacturingActivitiesParentMenuId WHERE strMenuName = 'Work Order Staging' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingParentMenuId
UPDATE tblSMMasterMenu SET strMenuName = N'Production Runs View' WHERE strMenuName = 'Process Production Runs View' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingActivitiesParentMenuId
UPDATE tblSMMasterMenu SET strModuleName = 'Manufacturing', intParentMenuID = @ManufacturingActivitiesParentMenuId WHERE strMenuName IN ('Demand Analysis View','Blend Demand') AND strModuleName = 'Contract Management'
UPDATE tblSMMasterMenu SET strCommand = N'Manufacturing.view.ManufacturingCell', strModuleName = 'Manufacturing' WHERE strMenuName = 'Manufacturing Cells' AND strModuleName = 'Inventory' AND intParentMenuID = @ManufacturingActivitiesParentMenuId
UPDATE tblSMMasterMenu SET intParentMenuID = @ManufacturingViewParentMenuId, strCategory = N'View', strIcon = N'small-menu-view' WHERE strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingActivitiesParentMenuId AND strMenuName IN ('Inventory View', 'Transaction View', 'Yield View', 'Traceability', 'Blend Consolidation View', 'Production Runs View', 'Efficiency Views')
UPDATE tblSMMasterMenu SET intParentMenuID = @ManufacturingViewParentMenuId, strCategory = N'View', strIcon = N'small-menu-view' WHERE strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingMaintenanceParentMenuId AND strMenuName = 'Demand Analysis View'
UPDATE tblSMMasterMenu SET intParentMenuID = @ManufacturingReportParentMenuId, strCategory = N'Report', strIcon = N'small-menu-report' WHERE strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingActivitiesParentMenuId AND strMenuName IN ('Ingredient Demand', 'Ingredient Demand Summary')
/* End of Rename and Remodule */

-- Activity

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Work Order Planning' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Work Order Planning', N'Manufacturing', @ManufacturingActivitiesParentMenuId, N'Work Order Planning', N'Activity', N'Screen', N'Manufacturing.view.WorkOrderCreation', N'small-menu-activity', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 0, strCommand = N'Manufacturing.view.WorkOrderCreation' WHERE strMenuName = 'Work Order Planning' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Blend Requirements' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Blend Requirements', N'Manufacturing', @ManufacturingActivitiesParentMenuId, N'Blend Requirements', N'Activity', N'Screen', N'Manufacturing.view.BlendRequirementManager', N'small-menu-activity', 0, 0, 0, 1, 1, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 1, strCommand = N'Manufacturing.view.BlendRequirementManager' WHERE strMenuName = 'Blend Requirements' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Blend Management' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Blend Management', N'Manufacturing', @ManufacturingActivitiesParentMenuId, N'Blend Management', N'Activity', N'Screen', N'Manufacturing.view.BlendManagemen?showSearch=true', N'small-menu-activity', 0, 0, 0, 1, 2, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 2, strCommand = N'Manufacturing.view.BlendManagement?showSearch=true' WHERE strMenuName = 'Blend Management' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Kit Manager' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Kit Manager', N'Manufacturing', @ManufacturingActivitiesParentMenuId, N'Kit Manager', N'Activity', N'Screen', N'Manufacturing.view.KitManager', N'small-menu-activity', 0, 0, 0, 1, 3, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 3, strCommand = N'Manufacturing.view.KitManager' WHERE strMenuName = 'Kit Manager' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Blend Production' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Blend Production', N'Manufacturing', @ManufacturingActivitiesParentMenuId, N'Blend Production', N'Activity', N'Screen', N'Manufacturing.view.BlendProduction', N'small-menu-activity', 0, 0, 0, 1, 4, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 4, strCommand = N'Manufacturing.view.BlendProduction' WHERE strMenuName = 'Blend Production' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Work Order Management' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Work Order Management', N'Manufacturing', @ManufacturingActivitiesParentMenuId, N'Work Order Management', N'Activity', N'Screen', N'Manufacturing.view.WorkOrder?showSearch=true', N'small-menu-activity', 0, 0, 0, 1, 5, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 5, strCommand = N'Manufacturing.view.WorkOrder?showSearch=true' WHERE strMenuName = 'Work Order Management' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Work Order Staging' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Work Order Staging', N'Manufacturing', @ManufacturingActivitiesParentMenuId, N'Work Order Staging', N'Activity', N'Screen', N'Manufacturing.view.WorkOrderStaging', N'small-menu-activity', 0, 0, 0, 1, 6, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 6, strCommand = N'Manufacturing.view.WorkOrderStaging' WHERE strMenuName = 'Work Order Staging' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Finished Goods Production' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Finished Goods Production', N'Manufacturing', @ManufacturingActivitiesParentMenuId, N'Finished Goods Production', N'Activity', N'Screen', N'Manufacturing.view.FinishedGoodsProduction', N'small-menu-activity', 0, 0, 0, 1, 7, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 7, strCommand = N'Manufacturing.view.FinishedGoodsProduction' WHERE strMenuName = 'Finished Goods Production' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Bag Off' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Bag Off', N'Manufacturing', @ManufacturingActivitiesParentMenuId, N'Bag Off', N'Activity', N'Screen', N'Manufacturing.view.BagOff', N'small-menu-activity', 0, 0, 0, 1, 8, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 8, strCommand = N'Manufacturing.view.BagOff' WHERE strMenuName = 'Bag Off' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Release To Warehouse' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Release To Warehouse', N'Manufacturing', @ManufacturingActivitiesParentMenuId, N'Release To Warehouse', N'Activity', N'Screen', N'Manufacturing.view.ReleaseToWarehouse', N'small-menu-activity', 0, 0, 0, 1, 9, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 9, strCommand = N'Manufacturing.view.ReleaseToWarehouse' WHERE strMenuName = 'Release To Warehouse' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Blend Sheet Approval' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Blend Sheet Approval', N'Manufacturing', @ManufacturingActivitiesParentMenuId, N'Blend Sheet Approval', N'Activity', N'Screen', N'Manufacturing.view.BlendSheetApproval', N'small-menu-activity', 0, 0, 0, 1, 10, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 10, strCommand = N'Manufacturing.view.BlendSheetApproval' WHERE strMenuName = 'Blend Sheet Approval' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Work Order Schedule' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Work Order Schedule', N'Manufacturing', @ManufacturingActivitiesParentMenuId, N'Work Order Schedule', N'Activity', N'Screen', N'Manufacturing.view.Schedule?showSearch=true', N'small-menu-activity', 0, 0, 0, 1, 11, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 11, strCommand = N'Manufacturing.view.Schedule?showSearch=true' WHERE strMenuName = 'Work Order Schedule' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Work Order Prod Return' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Work Order Prod Return', N'Manufacturing', @ManufacturingActivitiesParentMenuId, N'Work Order Prod Return', N'Activity', N'Screen', N'Manufacturing.view.WorkOrderProductionReturns', N'small-menu-activity', 0, 0, 0, 1, 12, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 12, strCommand = N'Manufacturing.view.WorkOrderProductionReturns' WHERE strMenuName = 'Work Order Prod Return' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Inventory Shipment Staging' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Inventory Shipment Staging', N'Manufacturing', @ManufacturingActivitiesParentMenuId, N'Inventory Shipment Staging', N'Activity', N'Screen', N'Manufacturing.view.InventoryShipmentStaging', N'small-menu-activity', 0, 0, 0, 1, 13, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 13, strCommand = N'Manufacturing.view.InventoryShipmentStaging' WHERE strMenuName = 'Inventory Shipment Staging' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Shift Activity' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Shift Activity', N'Manufacturing', @ManufacturingActivitiesParentMenuId, N'Shift Activity', N'Activity', N'Screen', N'Manufacturing.view.EfficiencyShiftActivity', N'small-menu-activity', 1, 0, 0, 1, 14, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 14, strCommand = N'Manufacturing.view.EfficiencyShiftActivity', strType = N'Screen' WHERE strMenuName = 'Shift Activity' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Finished Goods Forecast' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Finished Goods Forecast', N'Manufacturing', @ManufacturingActivitiesParentMenuId, N'Finished Goods Forecast', N'Activity', N'Screen', N'Manufacturing.view.FinishedGoodsForecast', N'small-menu-activity', 0, 0, 0, 1, 15, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 15, strCommand = N'Manufacturing.view.FinishedGoodsForecast' WHERE strMenuName = 'Finished Goods Forecast' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingActivitiesParentMenuId

-- Maintenance
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Blend Demand' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Blend Demand', N'Manufacturing', @ManufacturingMaintenanceParentMenuId, N'Blend Demand', N'Maintenance', N'Screen', N'Manufacturing.view.DemandEntry?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 0, strCommand = N'Manufacturing.view.DemandEntry?showSearch=true' WHERE strMenuName = 'Blend Demand' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingMaintenanceParentMenuId	

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Handheld Screen Access' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Handheld Screen Access', N'Manufacturing', @ManufacturingMaintenanceParentMenuId, N'Handheld Screen Access', N'Maintenance', N'Screen', N'Manufacturing.view.HandheldAccess', N'small-menu-maintenance', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 0, strCommand = N'Manufacturing.view.HandheldAccess' WHERE strMenuName = 'Handheld Screen Access' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Item Receive Life & Custom Label' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Item Receive Life & Custom Label', N'Manufacturing', @ManufacturingMaintenanceParentMenuId, N'Item Receive Life & Custom Label', N'Maintenance', N'Screen', N'Manufacturing.view.ReceiveLife', N'small-menu-maintenance', 0, 0, 0, 1, 1, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 1, strCommand = N'Manufacturing.view.ReceiveLife' WHERE strMenuName = 'Item Receive Life & Custom Label' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Item Receive Life & Custom Label' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Item Receive Life & Custom Label', N'Manufacturing', @ManufacturingMaintenanceParentMenuId, N'Item Receive Life & Custom Label', N'Maintenance', N'Screen', N'Manufacturing.view.ReceiveLife', N'small-menu-maintenance', 0, 0, 0, 1, 1, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 1, strCommand = N'Manufacturing.view.ReceiveLife' WHERE strMenuName = 'Item Receive Life & Custom Label' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Manufacturing Cells / Machines' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Manufacturing Cells / Machines', N'Manufacturing', @ManufacturingMaintenanceParentMenuId, N'Manufacturing Cells / Machines', N'Maintenance', N'Screen', N'Manufacturing.view.ManufacturingCell?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 2, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 2, strCommand = N'Manufacturing.view.ManufacturingCell?showSearch=true' WHERE strMenuName = 'Manufacturing Cells / Machines' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Manufacturing Process' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Manufacturing Process', N'Manufacturing', @ManufacturingMaintenanceParentMenuId, N'Manufacturing Process', N'Maintenance', N'Screen', N'Manufacturing.view.ManufacturingProcess?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 3, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 3, strCommand = N'Manufacturing.view.ManufacturingProcess?showSearch=true' WHERE strMenuName = 'Manufacturing Process' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Market Differential' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Market Differential', N'Manufacturing', @ManufacturingMaintenanceParentMenuId, N'Market Differential', N'Maintenance', N'Screen', N'Manufacturing.view.MarketDifferential', N'small-menu-maintenance', 0, 0, 0, 1, 4, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 4, strCommand = N'Manufacturing.view.MarketDifferential' WHERE strMenuName = 'Market Differential' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Production Calendar' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Production Calendar', N'Manufacturing', @ManufacturingMaintenanceParentMenuId, N'Production Calendar', N'Maintenance', N'Screen', N'Manufacturing.view.ProductionCalendar?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 5, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 5, strCommand = N'Manufacturing.view.ProductionCalendar?showSearch=true' WHERE strMenuName = 'Production Calendar' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Production Schedule Rules' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Production Schedule Rules', N'Manufacturing', @ManufacturingMaintenanceParentMenuId, N'Production Schedule Rules', N'Maintenance', N'Screen', N'Manufacturing.view.ProductionScheduleRules?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 6, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 6, strCommand = N'Manufacturing.view.ProductionScheduleRules?showSearch=true' WHERE strMenuName = 'Production Schedule Rules' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Reason' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Reason', N'Manufacturing', @ManufacturingMaintenanceParentMenuId, N'Reason', N'Maintenance', N'Screen', N'Manufacturing.view.Reason?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 7, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 7, strCommand = N'Manufacturing.view.Reason?showSearch=true' WHERE strMenuName = 'Reason' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Recipes' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Recipes', N'Manufacturing', @ManufacturingMaintenanceParentMenuId, N'Recipes', N'Maintenance', N'Screen', N'Manufacturing.view.Recipe?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 8, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 8, strCommand = N'Manufacturing.view.Recipe?showSearch=true' WHERE strMenuName = 'Recipes' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Scheduled Maintenance' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Scheduled Maintenance', N'Manufacturing', @ManufacturingMaintenanceParentMenuId, N'Scheduled Maintenance', N'Maintenance', N'Screen', N'Manufacturing.view.ScheduledMaintenance', N'small-menu-maintenance', 0, 0, 0, 1, 9, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 9, strCommand = N'Manufacturing.view.ScheduledMaintenance' WHERE strMenuName = 'Scheduled Maintenance' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Shifts' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Shifts', N'Manufacturing', @ManufacturingMaintenanceParentMenuId, N'Shifts', N'Maintenance', N'Screen', N'Manufacturing.view.Shift', N'small-menu-maintenance', 0, 0, 0, 1, 10, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 10, strCommand = N'Manufacturing.view.Shift' WHERE strMenuName = 'Shifts' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingMaintenanceParentMenuId
	
-- View

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Blend Consolidation View' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingViewParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Blend Consolidation View', N'Manufacturing', @ManufacturingViewParentMenuId, N'Blend Consolidation View', N'View', N'Screen', N'Manufacturing.view.GenericTransactionView?showSearch=true', N'small-menu-view', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 0, strCommand = N'Manufacturing.view.GenericTransactionView?showSearch=true' WHERE strMenuName = 'Blend Consolidation View' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingViewParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Demand Analysis View' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingViewParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Demand Analysis View', N'Manufacturing', @ManufacturingViewParentMenuId, N'Demand Analysis View', N'View', N'Screen', N'Manufacturing.view.DemandAnalysisView?showSearch=true', N'small-menu-view', 0, 0, 0, 1, 1, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 1, strCommand = N'Manufacturing.view.DemandAnalysisView?showSearch=true' WHERE strMenuName = 'Demand Analysis View' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingViewParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Efficiency Views' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingViewParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Efficiency Views', N'Manufacturing', @ManufacturingViewParentMenuId, N'Efficiency Views', N'View', N'Screen', N'Manufacturing.view.ShiftActivityView?showSearch=true', N'small-menu-view', 0, 0, 0, 1, 2, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 2, strCommand = N'Manufacturing.view.ShiftActivityView?showSearch=true' WHERE strMenuName = 'Efficiency Views' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingViewParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Inventory View' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingViewParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Inventory View', N'Manufacturing', @ManufacturingViewParentMenuId, N'Inventory View', N'View', N'Screen', N'Manufacturing.view.InventoryView?showSearch=true', N'small-menu-view', 0, 0, 0, 1, 3, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 3, strCommand = N'Manufacturing.view.InventoryView?showSearch=true', strType = N'Screen' WHERE strMenuName = 'Inventory View' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingViewParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Outturn P&L View' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingViewParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Outturn P&L View', N'Manufacturing', @ManufacturingViewParentMenuId, N'Outturn P&L View', N'View', N'Screen', N'Manufacturing.view.Outturn', N'small-menu-view', 0, 0, 0, 1, 4, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 4, strCommand = N'Manufacturing.view.Outturn', strType = N'Screen' WHERE strMenuName = 'Outturn P&L View' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingViewParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Production Runs View' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingViewParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Production Runs View', N'Manufacturing', @ManufacturingViewParentMenuId, N'Production Runs View', N'View', N'Screen', N'Manufacturing.view.ProcessProductionRunsView?showSearch=true', N'small-menu-view', 0, 0, 0, 1, 5, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 5, strCommand = N'Manufacturing.view.ProcessProductionRunsView?showSearch=true' WHERE strMenuName = 'Production Runs View' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingViewParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Traceability' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingViewParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Traceability', N'Manufacturing', @ManufacturingViewParentMenuId, N'Traceability', N'View', N'Screen', N'Manufacturing.view.TraceabilityDiagram', N'small-menu-view', 0, 0, 0, 1, 6, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 6, strCommand = N'Manufacturing.view.TraceabilityDiagram' WHERE strMenuName = 'Traceability' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingViewParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Transaction View' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingViewParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Transaction View', N'Manufacturing', @ManufacturingViewParentMenuId, N'Transaction View', N'View', N'Screen', N'Manufacturing.view.TransactionView?showSearch=true', N'small-menu-view', 0, 0, 0, 1, 7, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 7, strCommand = N'Manufacturing.view.TransactionView?showSearch=true' WHERE strMenuName = 'Transaction View' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingViewParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Yield View' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingViewParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Yield View', N'Manufacturing', @ManufacturingViewParentMenuId, N'Yield View', N'View', N'Screen', N'Manufacturing.view.YieldView', N'small-menu-view', 0, 0, 0, 1, 8, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 8, strCommand = N'Manufacturing.view.YieldView' WHERE strMenuName = 'Yield View' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingViewParentMenuId

-- Report
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Ingredient Demand' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Ingredient Demand', N'Manufacturing', @ManufacturingReportParentMenuId, N'Ingredient Demand', N'Report', N'Screen', N'Reporting.view.ReportManager?group=Manufacturing&report=TotalIngredientDemandReport&direct=true&showCriteria=true', N'small-menu-report', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 0, strCommand = N'Reporting.view.ReportManager?group=Manufacturing&report=TotalIngredientDemandReport&direct=true&showCriteria=true' WHERE strMenuName = 'Ingredient Demand' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Ingredient Demand Summary' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Ingredient Demand Summary', N'Manufacturing', @ManufacturingReportParentMenuId, N'Ingredient Demand Summary', N'Report', N'Screen', N'Reporting.view.ReportManager?group=Manufacturing&report=NetBlendKilos&direct=true&showCriteria=true', N'small-menu-report', 0, 0, 0, 1, 1, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 1, strCommand = N'Reporting.view.ReportManager?group=Manufacturing&report=NetBlendKilos&direct=true&showCriteria=true' WHERE strMenuName = 'Ingredient Demand Summary' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Processing Actual Outturn' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Processing Actual Outturn', N'Manufacturing', @ManufacturingReportParentMenuId, N'Processing Actual Outturn', N'Report', N'Screen', N'Reporting.view.ReportManager?group=Manufacturing&report=ActualOutTurnReport&direct=true&showCriteria=true', N'small-menu-report', 0, 0, 0, 1, 2, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 2, strCommand = N'Reporting.view.ReportManager?group=Manufacturing&report=ActualOutTurnReport&direct=true&showCriteria=true' WHERE strMenuName = 'Processing Actual Outturn' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingReportParentMenuId

/* Start of Delete */
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Process Production Produce' AND strModuleName = 'Manufacturing'
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Process Production Consume' AND strModuleName = 'Manufacturing'
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Work Order Production Returns' AND strModuleName = 'Manufacturing'
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Sanitization Staging' AND strModuleName = 'Manufacturing'
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Sanitization Production' AND strModuleName = 'Manufacturing'
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Item Consumption View' AND strModuleName = 'Manufacturing'
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Plant Schedule' AND strModuleName = 'Manufacturing'
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Daily Production Item Report' AND strModuleName = 'Manufacturing'
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Process Production True Up Report' AND strModuleName = 'Manufacturing'
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Holiday Calendar' AND strModuleName = 'Manufacturing'
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Change Over Group' AND strModuleName = 'Manufacturing'
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Multiple Change Over Factors' AND strModuleName = 'Manufacturing'
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Changeover Group' AND strModuleName = 'Manufacturing'
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Multiple Changeover Factors' AND strModuleName = 'Manufacturing'
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Manufacturing Cells' AND strModuleName = 'Manufacturing'
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Machines' AND strModuleName = 'Manufacturing'
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Pack Types' AND strModuleName = 'Manufacturing'
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Link Items to Blenders' AND strModuleName = 'Manufacturing'
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Item Substitution' AND strModuleName = 'Manufacturing'
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Item Substitution View' AND strModuleName = 'Manufacturing'
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Blend Validations' AND strModuleName = 'Manufacturing'
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Budget' AND strModuleName = 'Manufacturing'
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Yield Configuration' AND strModuleName = 'Manufacturing'
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Bin Type' AND strModuleName = 'Manufacturing'
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Downtime View' AND strModuleName = 'Manufacturing'
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Wastage Summary View' AND strModuleName = 'Manufacturing'
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Unallocated Lots View' AND strModuleName = 'Manufacturing'
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Production Summary View' AND strModuleName = 'Manufacturing'
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Production Summary By Line View' AND strModuleName = 'Manufacturing'
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Production Summary By Date View' AND strModuleName = 'Manufacturing'
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Contamination Group' AND strModuleName = 'Manufacturing'
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Item Contamination' AND strModuleName = 'Manufacturing'
--DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Blend Demand' AND strModuleName = 'Manufacturing'
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Traceability By Parent Lot' AND strModuleName = 'Manufacturing'
/* End of Delete */

/* TANK MANAGEMENT */
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Tank Management' AND strModuleName = 'Tank Management' AND intParentMenuID = 0)
UPDATE tblSMMasterMenu SET intSort = 17 WHERE strMenuName = 'Tank Management' AND strModuleName = 'Tank Management' AND intParentMenuID = 0

DECLARE @TankManagementParentMenuId INT
SELECT @TankManagementParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Tank Management' AND strModuleName = 'Tank Management' AND intParentMenuID = 0

/* CHANGE SCREEN CATEGORY 1730 TO 1810 */
UPDATE tblSMMasterMenu SET strCategory = 'Activity', strIcon = 'small-menu-activity' WHERE strMenuName IN ('Clock Reading', 'Synchronize Delivery History', 'Generate Orders', 'Tank Monitor', 'Generate Work Orders', 'Lease', 'Budget Calculation', 'Virtual Meter Billing') AND strModuleName = N'Tank Management'
UPDATE tblSMMasterMenu SET strCategory = 'Maintenance', strIcon = 'small-menu-maintenance' WHERE strMenuName IN ('Customer Inquiry', 'Consumption Sites', 'Devices') AND strModuleName = N'Tank Management'
UPDATE tblSMMasterMenu SET strCategory = 'Report', strIcon = 'small-menu-report' WHERE strMenuName IN ('Deliveries', 'Events') AND strModuleName = N'Tank Management'

/* CATEGORY FOLDERS */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Activities' AND strModuleName = 'Tank Management' AND intParentMenuID = @TankManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Activities', N'Tank Management', @TankManagementParentMenuId, N'Activities', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 0 WHERE strMenuName = 'Activities' AND strModuleName = 'Tank Management' AND intParentMenuID = @TankManagementParentMenuId

DECLARE @TankManagementActivitiesParentMenuId INT
SELECT @TankManagementActivitiesParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Activities' AND strModuleName = 'Tank Management' AND intParentMenuID = @TankManagementParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'Tank Management' AND intParentMenuID = @TankManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Maintenance', N'Tank Management', @TankManagementParentMenuId, N'Maintenance', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 1, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 1 WHERE strMenuName = 'Maintenance' AND strModuleName = 'Tank Management' AND intParentMenuID = @TankManagementParentMenuId

DECLARE @TankManagementMaintenanceParentMenuId INT
SELECT @TankManagementMaintenanceParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'Tank Management' AND intParentMenuID = @TankManagementParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Reports' AND strModuleName = 'Tank Management' AND intParentMenuID = @TankManagementParentMenuId)
    INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
    VALUES (N'Reports', N'Tank Management', @TankManagementParentMenuId, N'Reports', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 2, 1)
ELSE
    UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 2 WHERE strMenuName = 'Reports' AND strModuleName = 'Tank Management' AND intParentMenuID = @TankManagementParentMenuId

DECLARE @TankManagementReportParentMenuId INT
SELECT @TankManagementReportParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Reports' AND strModuleName = 'Tank Management' AND intParentMenuID = @TankManagementParentMenuId

/* ADD TO RESPECTIVE CATEGORY */ 
UPDATE tblSMMasterMenu SET intParentMenuID = @TankManagementActivitiesParentMenuId WHERE intParentMenuID =  @TankManagementParentMenuId AND strCategory = 'Activity'
UPDATE tblSMMasterMenu SET intParentMenuID = @TankManagementMaintenanceParentMenuId WHERE intParentMenuID =  @TankManagementParentMenuId AND strCategory = 'Maintenance'
UPDATE tblSMMasterMenu SET intParentMenuID = @TankManagementReportParentMenuId WHERE intParentMenuID =  @TankManagementParentMenuId AND strCategory = 'Report'

/* START OF PLURALIZING */
--UPDATE tblSMMasterMenu SET strMenuName = 'Event Types', strDescription = 'Event Types' WHERE strMenuName = N'Event Type' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementActivitiesParentMenuId
--UPDATE tblSMMasterMenu SET strMenuName = 'Device Types', strDescription = 'Device Types' WHERE strMenuName = N'Device Type' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementActivitiesParentMenuId
--UPDATE tblSMMasterMenu SET strMenuName = 'Lease Codes', strDescription = 'Lease Codes' WHERE strMenuName = N'Lease Code' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementActivitiesParentMenuId
--UPDATE tblSMMasterMenu SET strMenuName = 'Event Automation', strDescription = 'Event Automation' WHERE strMenuName = N'Event Automation Setup' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementActivitiesParentMenuId
--UPDATE tblSMMasterMenu SET strMenuName = 'Meter Types', strDescription = 'Meter Types' WHERE strMenuName = N'Meter Type' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementActivitiesParentMenuId
/* END OF PLURALIZING */

/* Start of moving report */
UPDATE tblSMMasterMenu SET intParentMenuID = @TankManagementReportParentMenuId WHERE strMenuName IN ('Device Lease Detail', 'On Hold Detail', 'Delivery Fill', 'Delivery Fill Report', 'Two-Part Delivery Fill Report', 'Missed Julian Deliveries') AND strModuleName = 'Tank Management' AND strType = 'Report' AND intParentMenuID = @TankManagementParentMenuId
UPDATE tblSMMasterMenu SET intParentMenuID = @TankManagementReportParentMenuId WHERE strMenuName IN ('Out of Range Burn Rates','Call Entry Printout', 'Fill Group', 'Tank Inventory', 'Customer List by Route', 'Device Actions', 'Leak Check / Gas Check') AND strModuleName = 'Tank Management' AND strType = 'Report' AND intParentMenuID = @TankManagementParentMenuId
/* End of moving report */

/* Rename Menus */
UPDATE tblSMMasterMenu SET strMenuName = 'Delivery Fill' WHERE strMenuName = 'Delivery Fill Report' AND strModuleName = 'Tank Management' AND strCategory = 'Report' AND intParentMenuID = @TankManagementReportParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Clock Reading' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementActivitiesParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 0, strCommand = N'TankManagement.view.ClockReading?showSearch=true' WHERE strMenuName = N'Clock Reading' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementActivitiesParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Synchronize Delivery History' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementActivitiesParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 1, strCommand = N'TankManagement.view.SyncDeliveryHistory' WHERE strMenuName = N'Synchronize Delivery History' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Generate Orders' AND strModuleName = 'Tank Management' AND intParentMenuID = @TankManagementActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Generate Orders', N'Tank Management', @TankManagementActivitiesParentMenuId, N'Generate Orders', N'Activity', N'Screen', N'TankManagement.view.GenerateOrder', N'small-menu-activity', 0, 0, 0, 1, 2, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 2, strCommand = N'TankManagement.view.GenerateOrder' WHERE strMenuName = 'Generate Orders' AND strModuleName = 'Tank Management' AND intParentMenuID = @TankManagementActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Tank Monitor' AND strModuleName = 'Tank Management' AND intParentMenuID = @TankManagementActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Tank Monitor', N'Tank Management', @TankManagementActivitiesParentMenuId, N'Tank Monitor', N'Activity', N'Screen', N'TankManagement.view.ImportWesrocTankMonitorReading', N'small-menu-activity', 0, 0, 0, 1, 3, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 3, strCommand = N'TankManagement.view.ImportWesrocTankMonitorReading' WHERE strMenuName = 'Tank Monitor' AND strModuleName = 'Tank Management' AND intParentMenuID = @TankManagementActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Generate Work Orders' AND strModuleName = 'Tank Management' AND strType = 'Screen' AND intParentMenuID = @TankManagementActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Generate Work Orders', N'Tank Management', @TankManagementActivitiesParentMenuId, N'Generate Work Orders', N'Activity', N'Screen', N'TankManagement.view.GenerateWorkOrder', N'small-menu-activity', 0, 0, 0, 1, 4, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 4, strCommand = N'TankManagement.view.GenerateWorkOrder' WHERE strMenuName = 'Generate Work Orders' AND strModuleName = 'Tank Management' AND strType = 'Screen' AND intParentMenuID = @TankManagementActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Lease' AND strModuleName = 'Tank Management' AND intParentMenuID = @TankManagementActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Lease', N'Tank Management', @TankManagementActivitiesParentMenuId, N'Lease', N'Activity', N'Screen', N'TankManagement.view.Lease?showSearch=true', N'small-menu-activity', 0, 0, 0, 1, 5, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 5, strCategory = N'Activity', strIcon = N'small-menu-activity', strCommand = N'TankManagement.view.Lease?showSearch=true' WHERE strMenuName = 'Lease' AND strModuleName = 'Tank Management' AND intParentMenuID = @TankManagementActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Budget Calculation' AND strModuleName = 'Tank Management' AND strType = 'Screen' AND intParentMenuID = @TankManagementActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Budget Calculation', N'Tank Management', @TankManagementActivitiesParentMenuId, N'Budget Calculation', N'Activity', N'Screen', N'TankManagement.view.BudgetCalculations', N'small-menu-activity', 0, 0, 0, 1, 6, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 6, strCommand = N'TankManagement.view.BudgetCalculations' WHERE strMenuName = 'Budget Calculation' AND strModuleName = 'Tank Management' AND strType = 'Screen' AND intParentMenuID = @TankManagementActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Virtual Meter Billing' AND strModuleName = 'Tank Management' AND strType = 'Screen' AND intParentMenuID = @TankManagementActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Virtual Meter Billing', N'Tank Management', @TankManagementActivitiesParentMenuId, N'Virtual Meter Billing', N'Activity', N'Screen', N'TankManagement.view.VirtualMeterBilling', N'small-menu-activity', 0, 0, 0, 1, 7, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 7, strCommand = N'TankManagement.view.VirtualMeterBilling' WHERE strMenuName = 'Virtual Meter Billing' AND strModuleName = 'Tank Management' AND strType = 'Screen' AND intParentMenuID = @TankManagementActivitiesParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Customer Inquiry' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 0, strCommand = N'TankManagement.view.CustomerInquiry?showSearch=true' WHERE strMenuName = N'Customer Inquiry' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Consumption Sites' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 1, strCommand = N'TankManagement.view.ConsumptionSite?showSearch=true' WHERE strMenuName = N'Consumption Sites' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Devices' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 2, strCommand = N'TankManagement.view.Device?showSearch=true' WHERE strMenuName = N'Devices' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Call Entry Printout' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementReportParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 0, strType = N'Screen', strCommand = N'TankManagement.view.CallEntryParameter' WHERE strMenuName = N'Call Entry Printout' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementReportParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Delivery Fill' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementReportParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 1, strType = N'Screen', strCommand = N'TankManagement.view.DeliveryFillReportParameter' WHERE strMenuName = N'Delivery Fill' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Work Orders' AND strModuleName = 'Tank Management' AND intParentMenuID = @TankManagementReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Work Orders', N'Tank Management', @TankManagementReportParentMenuId, N'Work Orders', N'Report', N'Screen', N'Reporting.view.ReportManager?group=Tank Management&report=WorkOrder&direct=true&showCriteria=false', N'small-menu-report', 0, 0, 0, 1, 2, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 2, strCommand = N'Reporting.view.ReportManager?group=Tank Management&report=WorkOrder&direct=true&showCriteria=false' WHERE strMenuName = 'Work Orders' AND strModuleName = 'Tank Management' AND intParentMenuID = @TankManagementReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Deliveries' AND strModuleName = 'Tank Management' AND strType = 'Screen' AND intParentMenuID = @TankManagementReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Deliveries', N'Tank Management', @TankManagementReportParentMenuId, N'Deliveries', N'Report', N'Screen', N'TankManagement.view.Deliveries?showSearch=true', N'small-menu-report', 0, 0, 0, 1, 3, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 3, strCommand = N'TankManagement.view.Deliveries?showSearch=true' WHERE strMenuName = 'Deliveries' AND strModuleName = 'Tank Management' AND strType = 'Screen' AND intParentMenuID = @TankManagementReportParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Events' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementReportParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 4, strCommand = N'TankManagement.view.Event?showSearch=true' WHERE strMenuName = N'Events' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementReportParentMenuId

/* START OF DELETING */
--DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Open Call Entries' AND strModuleName = N'Tank Management' AND strType = 'Report' AND intParentMenuID = @TankManagementMaintenanceParentMenuId
--DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Work Order Status' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementMaintenanceParentMenuId
--DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Lease Billing Report' AND strModuleName = N'Tank Management' AND strType = 'Report' AND intParentMenuID = @TankManagementParentMenuId
--DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Open Call Entries' AND strModuleName = 'Tank Management' AND strType = 'Screen' AND intParentMenuID = @TankManagementMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Work Orders' AND strModuleName = 'Tank Management' AND strType = 'Screen' AND intParentMenuID = @TankManagementMaintenanceParentMenuId
--DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Resolve Sync Conflict' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementMaintenanceParentMenuId
--DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Dispatch Deliveries' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementMaintenanceParentMenuId
--DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Degree Day Clock' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementMaintenanceParentMenuId
--DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Event Types' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementMaintenanceParentMenuId
--DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Device Types' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementMaintenanceParentMenuId
--DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Lease Codes' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementMaintenanceParentMenuId
--DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Meter Types' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementMaintenanceParentMenuId
--DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Clock Reading History' AND strModuleName = 'Tank Management' AND intParentMenuID = @TankManagementMaintenanceParentMenuId
--DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Lease Billing Incentive' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementMaintenanceParentMenuId
--DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Event Automation' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementMaintenanceParentMenuId
--DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Lease Billing' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementActivitiesParentMenuId
--DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Renew Julian Deliveries' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementMaintenanceParentMenuId
--DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Missed Julian Deliveries' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementReportParentMenuId
--DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Device Actions' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementReportParentMenuId
--DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Device Lease Detail' AND strModuleName = 'Tank Management' AND intParentMenuID = @TankManagementReportParentMenuId
--DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Fill Group' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementReportParentMenuId
--DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Out of Range Burn Rates' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementReportParentMenuId
--DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Leak Check / Gas Check' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementReportParentMenuId
--DELETE FROM tblSMMasterMenu WHERE strMenuName = N'On Hold Detail' AND strModuleName = 'Tank Management' AND intParentMenuID = @TankManagementReportParentMenuId
--DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Customer List by Route' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementReportParentMenuId
--DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Two-Part Delivery Fill Report' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementReportParentMenuId
--DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Tank Inventory' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementReportParentMenuId
/* END OF DELETING */

/* CARD FUELING */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Card Fueling' AND strModuleName = 'Card Fueling' AND intParentMenuID = 0)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Card Fueling', N'Card Fueling', 0, N'Card Fueling', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 18, 1)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 18 WHERE strMenuName = 'Card Fueling' AND strModuleName = 'Card Fueling' AND intParentMenuID = 0

DECLARE @CardFuelingParentMenuId INT
SELECT @CardFuelingParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Card Fueling' AND strModuleName = 'Card Fueling' AND intParentMenuID = 0

/* CHANGE SCREEN CATEGORY 1730 TO 1810 */
UPDATE tblSMMasterMenu SET strCategory = 'Activity', strIcon = 'small-menu-activity' WHERE strMenuName IN ('Invoice') AND strModuleName = N'Card Fueling'
UPDATE tblSMMasterMenu SET strCategory = 'Report', strIcon = 'small-menu-report' WHERE strMenuName IN ('Top Card Lock Customer') AND strModuleName = N'Card Fueling'

/* CATEGORY FOLDERS */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Activities' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingParentMenuId)
   	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intRow], [intConcurrencyId]) 
	VALUES (N'Activities', N'Card Fueling', @CardFuelingParentMenuId, N'Activities', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 0, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 0, intRow = 0 WHERE strMenuName = 'Activities' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingParentMenuId

DECLARE @CardFuelingActivitiesParentMenuId INT
SELECT @CardFuelingActivitiesParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Activities' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingParentMenuId)
   	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intRow], [intConcurrencyId]) 
	VALUES (N'Maintenance', N'Card Fueling', @CardFuelingParentMenuId, N'Maintenance', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 1, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 1, intRow = 0 WHERE strMenuName = 'Maintenance' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingParentMenuId

DECLARE @CardFuelingMaintenanceParentMenuId INT
SELECT @CardFuelingMaintenanceParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Reports' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingParentMenuId)
   	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intRow], [intConcurrencyId]) 
	VALUES (N'Reports', N'Card Fueling', @CardFuelingParentMenuId, N'Reports', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 2, 0, 1)
ELSE
    UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 2, intRow = 0 WHERE strMenuName = 'Reports' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingParentMenuId

DECLARE @CardFuelingReportParentMenuId INT
SELECT @CardFuelingReportParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Reports' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Create' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingParentMenuId)
   	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intRow], [intConcurrencyId]) 
    VALUES (N'Create', N'Card Fueling', @CardFuelingParentMenuId, N'Create', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 0, 1, 1)
ELSE
    UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 0, intRow = 1 WHERE strMenuName = 'Create' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingParentMenuId

DECLARE @CardFuelingCreateParentMenuId INT
SELECT @CardFuelingCreateParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Create' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingParentMenuId

/* ADD TO RESPECTIVE CATEGORY */ 
UPDATE tblSMMasterMenu SET intParentMenuID = @CardFuelingActivitiesParentMenuId WHERE (intParentMenuID =  @CardFuelingParentMenuId OR strModuleName = 'Card Fueling') AND strCategory = 'Activity'
UPDATE tblSMMasterMenu SET intParentMenuID = @CardFuelingMaintenanceParentMenuId WHERE intParentMenuID =  @CardFuelingParentMenuId AND strCategory = 'Maintenance'

/* START OF PLURALIZING */
UPDATE tblSMMasterMenu SET strMenuName = 'Index Pricing by Site Groups', strDescription = 'Index Pricing by Site Groups' WHERE strMenuName = 'Index Pricing By Site Group' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingMaintenanceParentMenuId
UPDATE tblSMMasterMenu SET strMenuName = 'Discount Schedules', strDescription = 'Discount Schedules' WHERE strMenuName = 'Discount Schedule' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingMaintenanceParentMenuId
UPDATE tblSMMasterMenu SET strMenuName = 'Fee Profiles', strDescription = 'Fee Profiles' WHERE strMenuName = 'Fee Profile' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingMaintenanceParentMenuId
UPDATE tblSMMasterMenu SET strMenuName = 'Networks', strDescription = 'Networks' WHERE strMenuName = 'Network' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingMaintenanceParentMenuId
UPDATE tblSMMasterMenu SET strMenuName = 'Price Profiles', strDescription = 'Price Profiles' WHERE strMenuName = 'Price Profile' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingMaintenanceParentMenuId
UPDATE tblSMMasterMenu SET strMenuName = 'Card Types', strDescription = 'Card Types' WHERE strMenuName = 'Card Type' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingMaintenanceParentMenuId
UPDATE tblSMMasterMenu SET strMenuName = 'Fees', strDescription = 'Fees' WHERE strMenuName = 'Fee' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingMaintenanceParentMenuId
UPDATE tblSMMasterMenu SET strMenuName = 'Invoice Cycles', strDescription = 'Invoice Cycles' WHERE strMenuName LIKE 'Invoice Cycle%' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingMaintenanceParentMenuId
UPDATE tblSMMasterMenu SET strMenuName = 'Price Indexes', strDescription = 'Price Indexes' WHERE strMenuName LIKE 'Price Index%' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingMaintenanceParentMenuId
UPDATE tblSMMasterMenu SET strMenuName = 'Price Rule Groups', strDescription = 'Price Rule Groups' WHERE strMenuName LIKE 'Price Rule Group%' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingMaintenanceParentMenuId
UPDATE tblSMMasterMenu SET strMenuName = 'Site Groups', strDescription = 'Site Groups' WHERE strMenuName LIKE 'Site Group%' AND strMenuName NOT LIKE 'Site Group Price Adjustment%' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingMaintenanceParentMenuId
UPDATE tblSMMasterMenu SET strMenuName = 'Site Group Price Adjustments', strDescription = 'Site Group Price Adjustments' WHERE strMenuName LIKE 'Site Group Price Adjustment%' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingMaintenanceParentMenuId
/* END OF PLURALIZING */

/* START OF RENAMING  */
UPDATE tblSMMasterMenu SET strMenuName = 'Card Accounts', strDescription = 'Card Accounts' WHERE strMenuName = 'Accounts' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingMaintenanceParentMenuId
UPDATE tblSMMasterMenu SET strMenuName = 'Remote Price Adjustments', strDescription = 'Remote Price Adjustments' WHERE strMenuName = 'Site Group Price Adjustments' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingMaintenanceParentMenuId
UPDATE tblSMMasterMenu SET strMenuName = N'Group Adjustment Rates', strDescription = 'Group Adjustment Rates' WHERE strMenuName = 'Remote Price Adjustments' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingMaintenanceParentMenuId
UPDATE tblSMMasterMenu SET strMenuName = N'Summary By Customer', strDescription = N'Summary By Customer' WHERE strMenuName = 'Transaction Summary By Customer' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingReportParentMenuId
UPDATE tblSMMasterMenu SET strMenuName = N'Summary By Site', strDescription = N'Summary By Site' WHERE strMenuName = 'Transaction Summary By Site' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingReportParentMenuId
UPDATE tblSMMasterMenu SET strMenuName = N'Summary By Customer/Product/Period', strDescription = N'Summary By Customer/Product/Period' WHERE strMenuName = 'Transaction Summary By Product Category' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingReportParentMenuId
UPDATE tblSMMasterMenu SET strMenuName = N'Purchase Summary', strDescription = N'Purchase Summary' WHERE strMenuName = 'Puchase Summary' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingReportParentMenuId
/* END OF RENAMING  */

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Transaction' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Transaction', N'Card Fueling', @CardFuelingActivitiesParentMenuId, N'Transaction', N'Activity', N'Screen', N'CardFueling.view.Transaction?showSearch=true', N'small-menu-activity', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'CardFueling.view.Transaction?showSearch=true', intSort = 0 WHERE strMenuName = 'Transaction' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Index Pricing By Site Groups' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Index Pricing By Site Groups', N'Card Fueling', @CardFuelingActivitiesParentMenuId, N'Index Pricing By Site Groups', N'Activity', N'Screen', N'CardFueling.view.IndexPricingBySiteGroup?showSearch=true', N'small-menu-activity', 0, 0, 0, 1, 1, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'CardFueling.view.IndexPricingBySiteGroup?showSearch=true', intSort = 1 WHERE strMenuName = 'Index Pricing By Site Groups' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Invoice' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Invoice', N'Card Fueling', @CardFuelingActivitiesParentMenuId, N'Invoice', N'Activity', N'Screen', N'CardFueling.view.Invoice', N'small-menu-activity', 0, 0, 0, 1, 2, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = N'CardFueling.view.Invoice', intSort = 2 WHERE strMenuName = 'Invoice' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Network Cost' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Network Cost', N'Card Fueling', @CardFuelingActivitiesParentMenuId, N'Network Cost', N'Activity', N'Screen', N'CardFueling.view.NetworkCost?showSearch=true', N'small-menu-activity', 0, 0, 0, 1, 3, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = N'CardFueling.view.NetworkCost?showSearch=true', intSort = 3 WHERE strMenuName = 'Network Cost' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Quote' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Quote', N'Card Fueling', @CardFuelingActivitiesParentMenuId, N'Quote', N'Activity', N'Screen', N'CardFueling.view.CSRSingleQuote', N'small-menu-activity', 0, 0, 0, 1, 4, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = N'CardFueling.view.CSRSingleQuote', intSort = 4 WHERE strMenuName = 'Quote' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Generate Quote' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Generate Quote', N'Card Fueling', @CardFuelingActivitiesParentMenuId, N'Generate Quote', N'Activity', N'Screen', N'CardFueling.view.GenerateQuotes', N'small-menu-activity', 0, 0, 0, 1, 5, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = N'CardFueling.view.GenerateQuotes', intSort = 5 WHERE strMenuName = 'Generate Quote' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Usage Alert' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Usage Alert', N'Card Fueling', @CardFuelingActivitiesParentMenuId, N'Usage Alert', N'Activity', N'Screen', N'CardFueling.view.UsageExceptionAlert', N'small-menu-activity', 0, 0, 0, 1, 6, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = N'CardFueling.view.UsageExceptionAlert', intSort = 6 WHERE strMenuName = 'Usage Alert' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Encode Card' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Encode Card', N'Card Fueling', @CardFuelingActivitiesParentMenuId, N'Encode Card', N'Activity', N'Screen', N'CardFueling.view.EncodeCard', N'small-menu-activity', 0, 0, 0, 1, 6, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = N'CardFueling.view.EncodeCard', intSort = 6 WHERE strMenuName = 'Encode Card' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Batch Unpost' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Batch Unpost', N'Card Fueling', @CardFuelingMaintenanceParentMenuId, N'Batch Unpost', N'Maintenance', N'Screen', N'CardFueling.view.BatchUnpost', N'small-menu-maintenance', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'CardFueling.view.BatchUnpost', intSort = 0 WHERE strMenuName = 'Batch Unpost' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Card Accounts' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Card Accounts', N'Card Fueling', @CardFuelingMaintenanceParentMenuId, N'Card Accounts', N'Maintenance', N'Screen', N'CardFueling.view.Account?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 1, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'CardFueling.view.Account?showSearch=true', intSort = 1 WHERE strMenuName = 'Card Accounts' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Group Adjustment Rates' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Group Adjustment Rates', N'Card Fueling', @CardFuelingMaintenanceParentMenuId, N'Group Adjustment Rates', N'Maintenance', N'Screen', N'CardFueling.view.SiteGroupPriceAdjustment?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 2, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = N'CardFueling.view.SiteGroupPriceAdjustment?showSearch=true', intSort = 2 WHERE strMenuName = 'Group Adjustment Rates' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Setup' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Setup', N'Card Fueling', @CardFuelingMaintenanceParentMenuId, N'Setup', N'Maintenance', N'Screen', N'CardFueling.view.Maintenance', N'small-menu-maintenance', 0, 0, 0, 1, 3, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = N'CardFueling.view.Maintenance', intSort = 3 WHERE strMenuName = 'Setup' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Invoice History' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Invoice History', N'Card Fueling', @CardFuelingReportParentMenuId, N'Invoice History', N'Report', N'Screen', N'CardFueling.view.InvoiceProcessHistory', N'small-menu-report', 0, 0, 0, 1, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = N'CardFueling.view.InvoiceProcessHistory', intSort = 0 WHERE strMenuName = 'Invoice History' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Purchase Summary' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Purchase Summary', N'Card Fueling', @CardFuelingReportParentMenuId, N'Purchase Summary', N'Report', N'Screen', N'CardFueling.view.PurchaseSummaryReport', N'small-menu-report', 0, 0, 0, 1, 1, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = N'CardFueling.view.PurchaseSummaryReport', intSort = 1 WHERE strMenuName = 'Purchase Summary' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Summary By Customer' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Summary By Customer', N'Card Fueling', @CardFuelingReportParentMenuId, N'Summary By Customer', N'Report', N'Screen', N'CardFueling.view.CustomerSummaryReportOption', N'small-menu-report', 0, 0, 0, 1, 2, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = N'CardFueling.view.CustomerSummaryReportOption', intSort = 2 WHERE strMenuName = 'Summary By Customer' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Summary By Site' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Summary By Site', N'Card Fueling', @CardFuelingReportParentMenuId, N'Summary By Site', N'Report', N'Screen', N'CardFueling.view.SiteSummaryReportOption', N'small-menu-report', 0, 0, 0, 1, 3, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = N'CardFueling.view.SiteSummaryReportOption', intSort = 3 WHERE strMenuName = 'Summary By Site' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Summary By Customer/Product/Period' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Summary By Customer/Product/Period', N'Card Fueling', @CardFuelingReportParentMenuId, N'Summary By Customer/Product/Period', N'Report', N'Screen', N'Reporting.view.ReportManager?group=Card Fueling&report=TransactionSummaryByCustomerProdPeriod&direct=true&showCriteria=true', N'small-menu-report', 0, 0, 0, 1, 4, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = N'Reporting.view.ReportManager?group=Card Fueling&report=TransactionSummaryByCustomerProdPeriod&direct=true&showCriteria=true', intSort = 4 WHERE strMenuName = 'Summary By Customer/Product/Period' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Taxes by Site/Customer' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Taxes by Site/Customer', N'Card Fueling', @CardFuelingReportParentMenuId, N'Taxes by Site/Customer', N'Report', N'Screen', N'CardFueling.view.SiteCustomerTaxReport', N'small-menu-report', 0, 0, 0, 1, 5, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = N'CardFueling.view.SiteCustomerTaxReport', intSort = 5 WHERE strMenuName = 'Taxes by Site/Customer' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingReportParentMenuId


IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Top Card Lock Customer' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Top Card Lock Customer', N'Card Fueling', @CardFuelingReportParentMenuId, N'Top Card Lock Customer', N'Report', N'Screen', N'CardFueling.view.TopCardLockCustomer', N'small-menu-report', 0, 0, 0, 1, 6, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = N'CardFueling.view.TopCardLockCustomer', intSort = 6 WHERE strMenuName = 'Top Card Lock Customer' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'New Transaction' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingCreateParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'New Transaction', N'Card Fueling', @CardFuelingCreateParentMenuId, N'New Transaction', N'Create', N'Screen', N'CardFueling.view.Transaction?action=new', N'small-menu-create', 0, 0, 0, 1, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = N'CardFueling.view.Transaction?action=new', intRow = NULL, intSort = 0, ysnLeaf = 1 WHERE strMenuName = 'New Transaction' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingCreateParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'New Card Account' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingCreateParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'New Card Account', N'Card Fueling', @CardFuelingCreateParentMenuId, N'New Card Account', N'Create', N'Screen', N'CardFueling.view.Account?action=new', N'small-menu-create', 0, 0, 0, 1, 1, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = N'CardFueling.view.Account?action=new', intSort = 1 WHERE strMenuName = 'New Card Account' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingCreateParentMenuId

/* START OF DELETION */
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Batch Posting' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Discount Schedules' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Fee Profiles' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Fees' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Networks' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Price Profiles' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Card Types' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Invoice Cycles' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Sites' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Price Indexes' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Price Rule Groups' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Site Groups' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Top Card Lock Customer' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingMaintenanceParentMenuId
/* END OF DELETION */

/* STORE */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Store' AND strModuleName = 'Store' AND intParentMenuID = 0)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Store', N'Store', 0, N'Store', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 19, 0)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 19 WHERE strMenuName = 'Store' AND strModuleName = 'Store' AND intParentMenuID = 0

DECLARE @StoreParentMenuId INT
SELECT @StoreParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Store' AND strModuleName = 'Store' AND intParentMenuID = 0

/* CATEGORY FOLDERS */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Activities' AND strModuleName = 'Store' AND intParentMenuID = @StoreParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Activities', N'Store', @StoreParentMenuId, N'Activities', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 0 WHERE strMenuName = 'Activities' AND strModuleName = 'Store' AND intParentMenuID = @StoreParentMenuId

DECLARE @StoreActivitiesParentMenuId INT
SELECT @StoreActivitiesParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Activities' AND strModuleName = 'Store' AND intParentMenuID = @StoreParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Pricebook' AND strModuleName = 'Store' AND intParentMenuID = @StoreParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Pricebook', N'Store', @StoreParentMenuId, N'Pricebook', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 1, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 1 WHERE strMenuName = 'Pricebook' AND strModuleName = 'Store' AND intParentMenuID = @StoreParentMenuId

DECLARE @StorePricebookParentMenuId INT
SELECT @StorePricebookParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Pricebook' AND strModuleName = 'Store' AND intParentMenuID = @StoreParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'Store' AND intParentMenuID = @StoreParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Maintenance', N'Store', @StoreParentMenuId, N'Maintenance', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 2, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 2 WHERE strMenuName = 'Maintenance' AND strModuleName = 'Store' AND intParentMenuID = @StoreParentMenuId

DECLARE @StoreMaintenanceParentMenuId INT
SELECT @StoreMaintenanceParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'Store' AND intParentMenuID = @StoreParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Reports' AND strModuleName = 'Store' AND intParentMenuID = @StoreParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Reports', N'Store', @StoreParentMenuId, N'Reports', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 3, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 3 WHERE strMenuName = 'Reports' AND strModuleName = 'Store' AND intParentMenuID = @StoreParentMenuId

DECLARE @StoreReportParentMenuId INT
SELECT @StoreReportParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Reports' AND strModuleName = 'Store' AND intParentMenuID = @StoreParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Lottery' AND strModuleName = 'Store' AND intParentMenuID = @StoreParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Lottery', N'Store', @StoreParentMenuId, N'Lottery', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 4, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 4 WHERE strMenuName = 'Lottery' AND strModuleName = 'Store' AND intParentMenuID = @StoreParentMenuId

DECLARE @StoreLotteryParentMenuId INT
SELECT @StoreLotteryParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Lottery' AND strModuleName = 'Store' AND intParentMenuID = @StoreParentMenuId

/* ADD TO RESPECTIVE CATEGORY */
UPDATE tblSMMasterMenu SET intParentMenuID = @StoreActivitiesParentMenuId WHERE intParentMenuID =  @StoreParentMenuId AND strCategory = 'Activity'
UPDATE tblSMMasterMenu SET intParentMenuID = @StoreMaintenanceParentMenuId WHERE intParentMenuID =  @StoreParentMenuId AND strCategory = 'Maintenance'


/* START OF RE-NAME */
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Inventory Mass Maintenance' AND strModuleName = 'Store' AND intParentMenuID = @StoreActivitiesParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Inventory Mass', strDescription = 'Inventory Mass' WHERE strMenuName = 'Inventory Mass Maintenance' AND strModuleName = 'Store' AND intParentMenuID = @StoreActivitiesParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Store Maintenance' AND strModuleName = 'Store' AND intParentMenuID = @StoreMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Stores', strDescription = 'Stores' WHERE strMenuName = 'Store Maintenance' AND strModuleName = 'Store' AND intParentMenuID = @StoreMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Register Maintenance' AND strModuleName = 'Store' AND intParentMenuID = @StoreMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Registers', strDescription = 'Registers' WHERE strMenuName = 'Register Maintenance' AND strModuleName = 'Store' AND intParentMenuID = @StoreMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'SubCategory' AND strModuleName = 'Store' AND intParentMenuID = @StoreMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Subcategories', strDescription = 'Subcategories' WHERE strMenuName = 'SubCategory' AND strModuleName = 'Store' AND intParentMenuID = @StoreMaintenanceParentMenuId
/* END OF RE-NAME */

/* START OF REMODULE */
UPDATE tblSMMasterMenu SET strCategory = 'Report', strIcon = 'small-menu-report', intParentMenuID = @StoreReportParentMenuId WHERE strMenuName = 'Checkout Transaction Journal' AND strModuleName = 'Store' AND intParentMenuID = @StoreMaintenanceParentMenuId
UPDATE tblSMMasterMenu SET strCategory = 'Pricebook', strIcon = 'small-menu-pricebook', intParentMenuID = @StorePricebookParentMenuId WHERE strMenuName IN ('Update Item Pricing', 'Retail Price Adjustments', 'Promotions', 'Inventory Mass', 'Update Item Data', 'Update Rebate/Discount') AND strModuleName = 'Store' AND intParentMenuID IN (@StoreActivitiesParentMenuId, @StoreMaintenanceParentMenuId)
/* END OF REMODULE */
/*START OF RENAME OF PRICEBOOK MENUS*/
UPDATE tblSMMasterMenu SET strMenuName = 'Item Quick Entry' WHERE strMenuName = 'Inventory Mass' AND strModuleName = 'Store' AND intParentMenuID = @StorePricebookParentMenuId
/*END RENAME PRICEBOOK MENUS*/

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Update Register' AND strModuleName = 'Store' AND intParentMenuID = @StoreActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Update Register', N'Store', @StoreActivitiesParentMenuId, N'Update Register', N'Activity', N'Screen', N'Store.view.UpdateRegister', N'small-menu-activity', 1, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET  intSort = 0, strCommand = N'Store.view.UpdateRegister' , ysnVisible = 1 WHERE strMenuName = 'Update Register' AND strModuleName = 'Store' AND intParentMenuID = @StoreActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Checkout' AND strModuleName = 'Store' AND intParentMenuID = @StoreActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Checkout', N'Store', @StoreActivitiesParentMenuId, N'Checkout', N'Activity', N'Screen', N'Store.view.CheckoutHeader?showSearch=true&searchCommand=SearchCheckoutHeader', N'small-menu-activity', 1, 0, 0, 1, 1, 1)
ELSE 
	UPDATE tblSMMasterMenu SET  intSort = 1, strCommand = N'Store.view.CheckoutHeader?showSearch=true&searchCommand=SearchCheckoutHeader', ysnVisible = 1 WHERE strMenuName = 'Checkout' AND strModuleName = 'Store' AND intParentMenuID = @StoreActivitiesParentMenuId

-- IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Lottery Book' AND strModuleName = 'Store' AND intParentMenuID = @StoreActivitiesParentMenuId)
-- 	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
-- 	VALUES (N'Lottery Book', N'Store', @StoreActivitiesParentMenuId, N'Lottery Book', N'Activity', N'Screen', N'Store.view.LotteryBook', N'small-menu-activity', 1, 0, 0, 1, 2, 1)
-- ELSE 
-- 	UPDATE tblSMMasterMenu SET  intSort = 2, strCommand = N'Store.view.LotteryBook' , ysnVisible = 1 WHERE strMenuName = 'Lottery Book' AND strModuleName = 'Store' AND intParentMenuID = @StoreActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Mark Up/Down' AND strModuleName = 'Store' AND intParentMenuID = @StoreActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Mark Up/Down', N'Store', @StoreActivitiesParentMenuId, N'Mark Up/Down', N'Activity', N'Screen', N'Store.view.MarkUpDown?showSearch=true&searchCommand=SearchMarkUpDown', N'small-menu-activity', 1, 0, 0, 1, 2, 1)
ELSE 
	UPDATE tblSMMasterMenu SET  intSort = 3, strCommand = N'Store.view.MarkUpDown?showSearch=true&searchCommand=SearchMarkUpDown' , ysnVisible = 1 WHERE strMenuName = 'Mark Up/Down' AND strModuleName = 'Store' AND intParentMenuID = @StoreActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Generate Shelf Tags' AND strModuleName = 'Store' AND intParentMenuID = @StoreActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Generate Shelf Tags', N'Store', @StoreActivitiesParentMenuId, N'Generate Shelf Tags', N'Activity', N'Screen', N'Store.view.GenerateShelfTags', N'small-menu-activity', 1, 0, 0, 1, 3, 1)
ELSE 
	UPDATE tblSMMasterMenu SET  intSort = 4, strCommand = N'Store.view.GenerateShelfTags', ysnVisible = 1 WHERE strMenuName = 'Generate Shelf Tags' AND strModuleName = 'Store' AND intParentMenuID = @StoreActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Handheld Scanners' AND strModuleName = 'Store' AND intParentMenuID = @StoreActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Handheld Scanners', N'Store', @StoreActivitiesParentMenuId, N'Handheld Scanners', N'Activity', N'Screen', N'Store.view.HandheldScanner', N'small-menu-activity', 1, 0, 0, 1, 4, 1)
ELSE 
	UPDATE tblSMMasterMenu SET  intSort = 5, strCommand = N'Store.view.HandheldScanner' WHERE strMenuName = 'Handheld Scanners' AND strModuleName = 'Store' AND intParentMenuID = @StoreActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Update Item Pricing' AND strModuleName = 'Store' AND intParentMenuID = @StorePricebookParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Update Item Pricing', N'Store', @StorePricebookParentMenuId, N'Update Item Pricing', N'Pricebook', N'Screen', N'Store.view.UpdateItemPricing', N'small-menu-pricebook', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 0, strCommand = N'Store.view.UpdateItemPricing' WHERE strMenuName = 'Update Item Pricing' AND strModuleName = 'Store' AND intParentMenuID = @StorePricebookParentMenuId
	
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Retail Price Adjustments' AND strModuleName = 'Store' AND intParentMenuID = @StorePricebookParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Retail Price Adjustments', N'Store', @StorePricebookParentMenuId, N'Retail Price Adjustments', N'Pricebook', N'Screen', N'Store.view.RetailPriceAdjustment?showSearch=true&searchCommand=SearchRetailPriceAdjustment', N'small-menu-pricebook', 0, 0, 0, 1, 1, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 1, strCommand = N'Store.view.RetailPriceAdjustment?showSearch=true&searchCommand=SearchRetailPriceAdjustment' WHERE strMenuName = 'Retail Price Adjustments' AND strModuleName = 'Store' AND intParentMenuID = @StorePricebookParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Revert Mass Pricebook Changes' AND strModuleName = 'Store' AND intParentMenuID = @StorePricebookParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Revert Mass Pricebook Changes', N'Store', @StorePricebookParentMenuId, N'Revert Mass Pricebook Changes', N'Pricebook', N'Screen', N'Store.view.RevertMassPricebookChanges?showSearch=true', N'small-menu-pricebook', 0, 0, 0, 1, 2, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 1, strCommand = N'Store.view.RevertMassPricebookChanges?showSearch=true' WHERE strMenuName = 'Revert Mass Pricebook Changes' AND strModuleName = 'Store' AND intParentMenuID = @StorePricebookParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Promotions' AND strModuleName = 'Store' AND intParentMenuID = @StorePricebookParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Promotions', N'Store', @StorePricebookParentMenuId, N'Promotions', N'Pricebook', N'Screen', N'Store.view.Promotions?showSearch=true&searchCommand=SearchPromotions', N'small-menu-pricebook', 0, 0, 0, 1, 2, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 2, strCommand = N'Store.view.Promotions?showSearch=true&searchCommand=SearchPromotions' WHERE strMenuName = 'Promotions' AND strModuleName = 'Store' AND intParentMenuID = @StorePricebookParentMenuId

-- IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Inventory Mass' AND strModuleName = 'Store' AND intParentMenuID = @StorePricebookParentMenuId)
-- 	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
-- 	VALUES (N'Inventory Mass', N'Store', @StorePricebookParentMenuId, N'Inventory Mass', N'Pricebook', N'Screen', N'Store.view.InventoryMassMaintenance?showSearch=true&searchCommand=SearchInventoryMassMaintenance', N'small-menu-pricebook', 0, 0, 0, 1, 3, 1)
-- ELSE 
-- 	UPDATE tblSMMasterMenu SET intSort = 3, strCommand = N'Store.view.InventoryMassMaintenance?showSearch=true&searchCommand=SearchInventoryMassMaintenance' WHERE strMenuName = 'Inventory Mass' AND strModuleName = 'Store' AND intParentMenuID = @StorePricebookParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Update Item Data' AND strModuleName = 'Store' AND intParentMenuID = @StorePricebookParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Update Item Data', N'Store', @StorePricebookParentMenuId, N'Update Item Data', N'Pricebook', N'Screen', N'Store.view.UpdateItemData', N'small-menu-pricebook', 0, 0, 0, 1, 4, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 4, strCommand = N'Store.view.UpdateItemData' WHERE strMenuName = 'Update Item Data' AND strModuleName = 'Store' AND intParentMenuID = @StorePricebookParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Update Rebate/Discount' AND strModuleName = 'Store' AND intParentMenuID = @StorePricebookParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Update Rebate/Discount', N'Store', @StorePricebookParentMenuId, N'Update Rebate/Discount', N'Pricebook', N'Screen', N'Store.view.UpdateRebateDiscount', N'small-menu-pricebook', 0, 0, 0, 1, 5, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 5, strCommand = N'Store.view.UpdateRebateDiscount' WHERE strMenuName = 'Update Rebate/Discount' AND strModuleName = 'Store' AND intParentMenuID = @StorePricebookParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Copy Promotion' AND strModuleName = 'Store' AND intParentMenuID = @StorePricebookParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Copy Promotion', N'Store', @StorePricebookParentMenuId, N'Copy Promotion', N'Pricebook', N'Screen', N'Store.view.CopyPromotion', N'small-menu-pricebook', 0, 0, 0, 1, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 5, strCommand = N'Store.view.CopyPromotion' WHERE strMenuName = 'Copy Promotion' AND strModuleName = 'Store' AND intParentMenuID = @StorePricebookParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Purge Promotion' AND strModuleName = 'Store' AND intParentMenuID = @StorePricebookParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Purge Promotion', N'Store', @StorePricebookParentMenuId, N'Purge Promotion', N'Pricebook', N'Screen', N'Store.view.PurgePromotion', N'small-menu-pricebook', 0, 0, 0, 1, 3, 1)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 5, strCommand = N'Store.view.PurgePromotion' WHERE strMenuName = 'Purge Promotion' AND strModuleName = 'Store' AND intParentMenuID = @StorePricebookParentMenuId



IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Cigarette Rebate Programs' AND strModuleName = 'Store' AND intParentMenuID = @StoreMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Cigarette Rebate Programs', N'Store', @StoreMaintenanceParentMenuId, N'Cigarette Rebate Programs', N'Maintenance', N'Screen', N'Store.view.CigaretteRebatePrograms?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 0, strCommand = N'Store.view.CigaretteRebatePrograms?showSearch=true' WHERE strMenuName = 'Cigarette Rebate Programs' AND strModuleName = 'Store' AND intParentMenuID = @StoreMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Generate Vendor Rebate File' AND strModuleName = 'Store' AND intParentMenuID = @StoreMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Generate Vendor Rebate File', N'Store', @StoreMaintenanceParentMenuId, N'Generate Vendor Rebate File', N'Maintenance', N'Screen', N'Store.view.GenerateVendorRebateFile', N'small-menu-maintenance', 0, 0, 0, 1, 1, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 1, strCommand = N'Store.view.GenerateVendorRebateFile' WHERE strMenuName = 'Generate Vendor Rebate File' AND strModuleName = 'Store' AND intParentMenuID = @StoreMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Registers' AND strModuleName = 'Store' AND intParentMenuID = @StoreMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Registers', N'Store', @StoreMaintenanceParentMenuId, N'Registers', N'Maintenance', N'Screen', N'Store.view.Register?showSearch=true&searchCommand=SearchRegister', N'small-menu-maintenance', 0, 0, 0, 1, 2, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 2, strCommand = N'Store.view.Register?showSearch=true&searchCommand=SearchRegister' WHERE strMenuName = 'Registers' AND strModuleName = 'Store' AND intParentMenuID = @StoreMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Radiant Item Type Code' AND strModuleName = 'Store' AND intParentMenuID = @StoreMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Radiant Item Type Code', N'Store', @StoreMaintenanceParentMenuId, N'Radiant Item Type Code', N'Maintenance', N'Screen', N'Store.view.RadiantItemTypeCode', N'small-menu-maintenance', 0, 0, 0, 1, 3, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 2, strCommand = N'Store.view.RadiantItemTypeCode' WHERE strMenuName = 'Radiant Item Type Code' AND strModuleName = 'Store' AND intParentMenuID = @StoreMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Stores' AND strModuleName = 'Store' AND intParentMenuID = @StoreMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Stores', N'Store', @StoreMaintenanceParentMenuId, N'Stores', N'Maintenance', N'Screen', N'Store.view.Store?showSearch=true&searchCommand=SearchStore', N'small-menu-maintenance', 0, 0, 0, 1, 4, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 3, strCommand = N'Store.view.Store?showSearch=true&searchCommand=SearchStore' WHERE strMenuName = 'Stores' AND strModuleName = 'Store' AND intParentMenuID = @StoreMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Subcategories' AND strModuleName = 'Store' AND intParentMenuID = @StoreMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Subcategories', N'Store', @StoreMaintenanceParentMenuId, N'Subcategories', N'Maintenance', N'Screen', N'Store.view.SubCategory', N'small-menu-maintenance', 0, 0, 0, 1, 5, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 4, strCommand = N'Store.view.SubCategory' WHERE strMenuName = 'Subcategories' AND strModuleName = 'Store' AND intParentMenuID = @StoreMaintenanceParentMenuId

-- IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Lottery Games' AND strModuleName = 'Store' AND intParentMenuID = @StoreMaintenanceParentMenuId)
-- 	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
-- 	VALUES (N'Lottery Games', N'Store', @StoreMaintenanceParentMenuId, N'Lottery Games', N'Maintenance', N'Screen', N'Store.view.LotteryGame', N'small-menu-maintenance', 0, 0, 0, 1, 6, 1)
-- ELSE
-- 	UPDATE tblSMMasterMenu SET intSort = 4, strCommand = N'Store.view.LotteryGame' WHERE strMenuName = 'Lottery Games' AND strModuleName = 'Store' AND intParentMenuID = @StoreMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Cashier' AND strModuleName = 'Store' AND intParentMenuID = @StoreMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Cashier', N'Store', @StoreMaintenanceParentMenuId, N'Cashier', N'Maintenance', N'Screen', N'Store.view.Cashier', N'small-menu-maintenance', 0, 0, 0, 1, 5, 1)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 4, strCommand = N'Store.view.Cashier' WHERE strMenuName = 'Cashier' AND strModuleName = 'Store' AND intParentMenuID = @StoreMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Checkout Transaction Journal' AND strModuleName = 'Store' AND intParentMenuID = @StoreReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Checkout Transaction Journal', N'Store', @StoreReportParentMenuId, N'Checkout Transaction Journal', N'Report', N'Screen', N'Store.view.CheckoutTransactionJournal?showSearch=true&searchCommand=SearchCheckoutTransactionJournal', N'small-menu-report', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 0, strCommand = N'Store.view.CheckoutTransactionJournal?showSearch=true&searchCommand=SearchCheckoutTransactionJournal' WHERE strMenuName = 'Checkout Transaction Journal' AND strModuleName = 'Store' AND intParentMenuID = @StoreReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Consolidated Checkout' AND strModuleName = 'Store' AND intParentMenuID = @StoreReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Consolidated Checkout', N'Store', @StoreReportParentMenuId, N'Consolidated Checkout', N'Report', N'Screen', N'Store.view.ConsolidatedCheckoutReport', N'small-menu-report', 0, 0, 0, 1, 1, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 1, strCommand = N'Store.view.ConsolidatedCheckoutReport' WHERE strMenuName = 'Consolidated Checkout' AND strModuleName = 'Store' AND intParentMenuID = @StoreReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Department Summary' AND strModuleName = 'Store' AND intParentMenuID = @StoreReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Department Summary', N'Store', @StoreReportParentMenuId, N'Department Summary', N'Report', N'Screen', N'Store.view.DepartmentSummaryReport', N'small-menu-report', 0, 0, 0, 1, 2, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 2, strCommand = N'Store.view.DepartmentSummaryReport' WHERE strMenuName = 'Department Summary' AND strModuleName = 'Store' AND intParentMenuID = @StoreReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Fuel Summary' AND strModuleName = 'Store' AND intParentMenuID = @StoreReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Fuel Summary', N'Store', @StoreReportParentMenuId, N'Fuel Summary', N'Report', N'Screen', N'Store.view.FuelSummaryReport', N'small-menu-report', 0, 0, 0, 1, 3, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 3, strCommand = N'Store.view.FuelSummaryReport' WHERE strMenuName = 'Fuel Summary' AND strModuleName = 'Store' AND intParentMenuID = @StoreReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Item Movement' AND strModuleName = 'Store' AND intParentMenuID = @StoreReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Item Movement', N'Store', @StoreReportParentMenuId, N'Item Movement', N'Report', N'Screen', N'Store.view.ItemMovementReport', N'small-menu-report', 0, 0, 0, 1, 4, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 4, strCommand = N'Store.view.ItemMovementReport' WHERE strMenuName = 'Item Movement' AND strModuleName = 'Store' AND intParentMenuID = @StoreReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Payment Options Summary' AND strModuleName = 'Store' AND intParentMenuID = @StoreReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Payment Options Summary', N'Store', @StoreReportParentMenuId, N'Payment Options Summary', N'Report', N'Screen', N'Store.view.PaymentOptionSummaryReport', N'small-menu-report', 0, 0, 0, 1, 5, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 5, strCommand = N'Store.view.PaymentOptionSummaryReport' WHERE strMenuName = 'Payment Options Summary' AND strModuleName = 'Store' AND intParentMenuID = @StoreReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Cashier Report' AND strModuleName = 'Store' AND intParentMenuID = @StoreReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Cashier Report', N'Store', @StoreReportParentMenuId, N'Cashier Report', N'Report', N'Screen', N'Store.view.CashierReport', N'small-menu-report', 0, 0, 0, 1, 6, 1)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 5, strCommand = N'Store.view.CashierReport' WHERE strMenuName = 'Cashier Report' AND strModuleName = 'Store' AND intParentMenuID = @StoreReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Purchase Vs Sale Variance' AND strModuleName = 'Store' AND intParentMenuID = @StoreReportParentMenuId)	
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Purchase Vs Sale Variance', N'Store', @StoreReportParentMenuId, N'Purchase Vs Sale Variance', N'Report', N'Screen', N'Store.view.PurchaseVsVarianceReport', N'small-menu-report', 0, 0, 0, 1, 7, 1)	
ELSE
	UPDATE tblSMMasterMenu SET intSort = 6, strCommand = N'Store.view.PurchaseVsVarianceReport' WHERE strMenuName = 'Purchase Vs Sale Variance' AND strModuleName = 'Store' AND intParentMenuID = @StoreReportParentMenuId

--Lottery
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Lottery Games' AND strModuleName = 'Store' AND intParentMenuID = @StoreLotteryParentMenuId)	
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Lottery Games', N'Store', @StoreLotteryParentMenuId, N'Lottery Games', N'Lottery', N'Screen', N'Store.view.LotteryGame', N'small-menu-lottery', 0, 0, 0, 1, 0, 1)	
ELSE
	UPDATE tblSMMasterMenu SET intSort = 0, strCommand = N'Store.view.LotteryGame' WHERE strMenuName = 'Lottery Games' AND strModuleName = 'Store' AND intParentMenuID = @StoreLotteryParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Lottery Books' AND strModuleName = 'Store' AND intParentMenuID = @StoreLotteryParentMenuId)	
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Lottery Books', N'Store', @StoreLotteryParentMenuId, N'Lottery Books', N'Lottery', N'Screen', N'Store.view.LotteryBook', N'small-menu-lottery', 0, 0, 0, 1, 1, 1)	
ELSE
	UPDATE tblSMMasterMenu SET intSort = 0, strCommand = N'Store.view.LotteryBook' WHERE strMenuName = 'Lottery Books' AND strModuleName = 'Store' AND intParentMenuID = @StoreLotteryParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Lottery Count Sheet' AND strModuleName = 'Store' AND intParentMenuID = @StoreLotteryParentMenuId)	
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Lottery Count Sheet', N'Store', @StoreLotteryParentMenuId, N'Lottery Count Sheet', N'Lottery', N'Screen', N'Store.view.LotteryCountSheetReport', N'small-menu-lottery', 0, 0, 0, 1, 1, 2)	
ELSE
	UPDATE tblSMMasterMenu SET intSort = 0, strCommand = N'Store.view.LotteryCountSheetReport' WHERE strMenuName = 'Lottery Count Sheet' AND strModuleName = 'Store' AND intParentMenuID = @StoreLotteryParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Lottery Sales Report' AND strModuleName = 'Store' AND intParentMenuID = @StoreLotteryParentMenuId)	
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Lottery Sales Report', N'Store', @StoreLotteryParentMenuId, N'Lottery Sales Report', N'Lottery', N'Screen', N'Store.view.LotterySalesReport', N'small-menu-lottery', 0, 0, 0, 1, 1, 3)	
ELSE
	UPDATE tblSMMasterMenu SET intSort = 0, strCommand = N'Store.view.LotterySalesReport' WHERE strMenuName = 'Lottery Sales Report' AND strModuleName = 'Store' AND intParentMenuID = @StoreLotteryParentMenuId

--END LOTTERY

/* START DELETE */
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Lottery Book' AND strModuleName = 'Store' AND intParentMenuID = @StoreActivitiesParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Lottery Games' AND strModuleName = 'Store' AND intParentMenuID = @StoreMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Promotion Sales ' AND strModuleName = 'Store' AND intParentMenuID = @StoreMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Promotion Item List' AND strModuleName = 'Store' AND intParentMenuID = @StoreMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Copy Promotions' AND strModuleName = 'Store' AND intParentMenuID = @StoreMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Purge Promotions' AND strModuleName = 'Store' AND intParentMenuID = @StoreMaintenanceParentMenuId
--DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Radiant Item Type Code' AND strModuleName = 'Store' AND intParentMenuID = @StoreMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Generate  Vendor Rebates File' AND strModuleName = 'Store' AND intParentMenuID = @StoreMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Inventory Mass' AND strModuleName = 'Store' AND intParentMenuID = @StorePricebookParentMenuId
/* STOP DELETE */

/* CRM - Customer Relation Management */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'CRM' AND strModuleName = 'CRM' AND intParentMenuID = 0)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'CRM', N'CRM', 0, N'Customer Relation Management', NULL, N'Folder', N'', N'small-folder', 1, 1, 0, 0, 20, 0)
ELSE
	UPDATE tblSMMasterMenu SET  intSort = 20 WHERE strMenuName = 'CRM' AND strModuleName = 'CRM' AND intParentMenuID = 0

DECLARE @CRMParentMenuId INT
SELECT @CRMParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'CRM' AND strModuleName = 'CRM' AND intParentMenuID = 0

/* Mover from Activity To Maintenance - 1730 */
UPDATE tblSMMasterMenu SET strCategory = N'Maintenance', strIcon = N'small-menu-maintenance' WHERE strMenuName IN ('Sales Pipe Statuses', 'Sources', 'Types', 'Statuses', 'Milestones', 'Prospect Requirements', 'Sales Entities', 'Leads', 'Customer Licenses') AND strModuleName = 'CRM'

/* CATEGORY FOLDERS */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Activities' AND strModuleName = 'CRM' AND intParentMenuID = @CRMParentMenuId AND strCommand = '')
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intRow], [intConcurrencyId]) 
	VALUES (N'Activities', N'CRM', @CRMParentMenuId, N'Activities', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 0, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET strDescription = 'Activities', strCategory = NULL, strType = 'Folder', strIcon = 'small-folder', strCommand = N'', ysnLeaf = 0, intSort = 0, intRow = 0 WHERE strMenuName = 'Activities' AND strModuleName = 'CRM' AND intParentMenuID = @CRMParentMenuId AND strCommand = ''

DECLARE @CRMActivitiesParentMenuId INT
SELECT @CRMActivitiesParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Activities' AND strModuleName = 'CRM' AND intParentMenuID = @CRMParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'CRM' AND intParentMenuID = @CRMParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intRow], [intConcurrencyId]) 
	VALUES (N'Maintenance', N'CRM', @CRMParentMenuId, N'Maintenance', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 1, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 1, intRow = 0 WHERE strMenuName = 'Maintenance' AND strModuleName = 'CRM' AND intParentMenuID = @CRMParentMenuId

DECLARE @CRMMaintenanceParentMenuId INT
SELECT @CRMMaintenanceParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'CRM' AND intParentMenuID = @CRMParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Create' AND strModuleName = 'CRM' AND intParentMenuID = @CRMParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intRow], [intConcurrencyId]) 
	VALUES (N'Create', N'CRM', @CRMParentMenuId, N'Create', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 0, 1, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 0, intRow = 1 WHERE strMenuName = 'Create' AND strModuleName = 'CRM' AND intParentMenuID = @CRMParentMenuId

DECLARE @CRMCreateParentMenuId INT
SELECT @CRMCreateParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Create' AND strModuleName = 'CRM' AND intParentMenuID = @CRMParentMenuId

/* ADD TO RESPECTIVE CATEGORY */ 
UPDATE tblSMMasterMenu SET intParentMenuID = @CRMActivitiesParentMenuId WHERE intParentMenuID =  @CRMParentMenuId AND strCategory = 'Activity'
UPDATE tblSMMasterMenu SET intParentMenuID = @CRMMaintenanceParentMenuId WHERE intParentMenuID IN (@CRMParentMenuId, @CRMActivitiesParentMenuId)AND strCategory = 'Maintenance'

/* START OF RENAMING  */
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Opportunity' AND strModuleName = 'CRM' AND intParentMenuID = @CRMActivitiesParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Opportunities' WHERE strMenuName = 'Opportunity' AND strModuleName = 'CRM' AND intParentMenuID = @CRMActivitiesParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName IN ('Prospects', 'Prospects and Customers') AND strModuleName = 'CRM' AND intParentMenuID = @CRMActivitiesParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Sales Entities', strDescription = 'Sales Entities' WHERE strMenuName IN ('Prospects', 'Prospects and Customers') AND strModuleName = 'CRM' AND intParentMenuID = @CRMActivitiesParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Competitor Search' AND strModuleName = 'CRM' AND intParentMenuID = @CRMActivitiesParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Competitors', strDescription = 'Competitors' WHERE strMenuName = 'Competitor Search' AND strModuleName = 'CRM' AND intParentMenuID = @CRMActivitiesParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Lead' AND strModuleName = 'CRM' AND intParentMenuID = @CRMActivitiesParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Leads', strDescription = 'Leads' WHERE strMenuName = 'Lead' AND strModuleName = 'CRM' AND intParentMenuID = @CRMActivitiesParentMenuId
/* END OF RENAMING  */

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Activities' AND strModuleName = 'CRM' AND intParentMenuID = @CRMActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Activities', N'CRM', @CRMActivitiesParentMenuId, N'CRM Opportunity Activities', N'Activity', N'Screen', N'CRM.view.Opportunity?showSearch=true&searchCommand=Activity', N'small-menu-activity', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 0, strCommand = N'CRM.view.Opportunity?showSearch=true&searchCommand=Activity', strDescription = N'CRM Opportunity Activities' WHERE strMenuName = 'Activities' AND strModuleName = 'CRM' AND intParentMenuID = @CRMActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Opportunities' AND strModuleName = 'CRM' AND intParentMenuID = @CRMActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Opportunities', N'CRM', @CRMActivitiesParentMenuId, N'CRM Opportunity', N'Activity', N'Screen', N'CRM.view.Opportunity?showSearch=true&searchCommand=Opportunity', N'small-menu-activity', 0, 0, 0, 1, 1, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 1, strCommand = N'CRM.view.Opportunity?showSearch=true&searchCommand=Opportunity' WHERE strMenuName = 'Opportunities' AND strModuleName = 'CRM' AND intParentMenuID = @CRMActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Campaigns' AND strModuleName = 'CRM' AND intParentMenuID = @CRMActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Campaigns', N'CRM', @CRMActivitiesParentMenuId, N'CRM Campaigns', N'Activity', N'Screen', N'CRM.view.Campaign?showSearch=true&searchCommand=Campaign', N'small-menu-activity', 0, 0, 0, 1, 2, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 2, strCommand = N'CRM.view.Campaign?showSearch=true&searchCommand=Campaign' WHERE strMenuName = 'Campaigns' AND strModuleName = 'CRM' AND intParentMenuID = @CRMActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Lost Revenues' AND strModuleName = 'CRM' AND intParentMenuID = @CRMActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Lost Revenues', N'CRM', @CRMActivitiesParentMenuId, N'CRM Lost Revenue', N'Activity', N'Screen', N'CRM.view.LostRevenue', N'small-menu-activity', 0, 0, 0, 1, 3, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 3, strCommand = N'CRM.view.LostRevenue', strDescription = N'CRM Lost Revenue' WHERE strMenuName = 'Lost Revenues' AND strModuleName = 'CRM' AND intParentMenuID = @CRMActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Customer Licenses' AND strModuleName = 'CRM' AND intParentMenuID = @CRMMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Customer Licenses', N'CRM', @CRMMaintenanceParentMenuId, N'CRM Customer Licenses', N'Maintenance', N'Screen', N'CRM.view.CustomerLicense?showSearch=true&searchCommand=CustomerLicense', N'small-menu-maintenance', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 0, strCommand = N'CRM.view.CustomerLicense?showSearch=true&searchCommand=CustomerLicense' WHERE strMenuName = 'Customer Licenses' AND strModuleName = 'CRM' AND intParentMenuID = @CRMMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Leads' AND strModuleName = 'CRM' AND intParentMenuID = @CRMMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId])
	VALUES (N'Leads', N'CRM', @CRMMaintenanceParentMenuId, N'Leads', N'Maintenance', N'Screen', N'AccountsReceivable.view.EntityLead?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 1, 1)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 1, strCommand = N'AccountsReceivable.view.EntityLead?showSearch=true' WHERE strMenuName = 'Leads' AND strModuleName = 'CRM' AND intParentMenuID = @CRMMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Milestones' AND strModuleName = 'CRM' AND intParentMenuID = @CRMMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Milestones', N'CRM', @CRMMaintenanceParentMenuId, N'CRM Milestones', N'Maintenance', N'Screen', N'CRM.view.Milestone', N'small-menu-maintenance', 0, 0, 0, 1, 2, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 2, strCommand = N'CRM.view.Milestone' WHERE strMenuName = 'Milestones' AND strModuleName = 'CRM' AND intParentMenuID = @CRMMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Prospect Requirements' AND strModuleName = 'CRM' AND intParentMenuID = @CRMMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Prospect Requirements', N'CRM', @CRMMaintenanceParentMenuId, N'CRM Prospect Requirements', N'Maintenance', N'Screen', N'CRM.view.ProspectRequirement', N'small-menu-maintenance', 0, 0, 0, 1, 3, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 3, strCommand = N'CRM.view.ProspectRequirement' WHERE strMenuName = 'Prospect Requirements' AND strModuleName = 'CRM' AND intParentMenuID = @CRMMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Sales Entities' AND strModuleName = 'CRM' AND intParentMenuID = @CRMMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId])
	VALUES (N'Sales Entities', N'CRM', @CRMMaintenanceParentMenuId, N'Sales Entities', N'Maintenance', N'Screen', N'AccountsReceivable.view.EntityProspect?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 4, 1)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 4, strCommand = N'AccountsReceivable.view.EntityProspect?showSearch=true' WHERE strMenuName = 'Sales Entities' AND strModuleName = 'CRM' AND intParentMenuID = @CRMMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Sales Pipe Statuses' AND strModuleName = 'CRM' AND intParentMenuID = @CRMMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Sales Pipe Statuses', N'CRM', @CRMMaintenanceParentMenuId, N'CRM Sales Pipe Statuses', N'Maintenance', N'Screen', N'CRM.view.SalesPipeStatus?searchCommand=searchConfig', N'small-menu-maintenance', 0, 0, 0, 1, 5, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 5, strCommand = N'CRM.view.SalesPipeStatus?searchCommand=searchConfig' WHERE strMenuName = 'Sales Pipe Statuses' AND strModuleName = 'CRM' AND intParentMenuID = @CRMMaintenanceParentMenuId
	
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Sources' AND strModuleName = 'CRM' AND intParentMenuID = @CRMMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Sources', N'CRM', @CRMMaintenanceParentMenuId, N'CRM Source', N'Maintenance', N'Screen', N'CRM.view.Source', N'small-menu-maintenance', 0, 0, 0, 1, 6, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 6, strCommand = N'CRM.view.Source', strDescription = N'CRM Source' WHERE strMenuName = 'Sources' AND strModuleName = 'CRM' AND intParentMenuID = @CRMMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Statuses' AND strModuleName = 'CRM' AND intParentMenuID = @CRMMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Statuses', N'CRM', @CRMMaintenanceParentMenuId, N'CRM Status', N'Maintenance', N'Screen', N'CRM.view.Status', N'small-menu-maintenance', 0, 0, 0, 1, 7, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 7, strCommand = N'CRM.view.Status' WHERE strMenuName = 'Statuses' AND strModuleName = 'CRM' AND intParentMenuID = @CRMMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Types' AND strModuleName = 'CRM' AND intParentMenuID = @CRMMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Types', N'CRM', @CRMMaintenanceParentMenuId, N'CRM Type', N'Maintenance', N'Screen', N'CRM.view.Type', N'small-menu-maintenance', 0, 0, 0, 1, 8, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 8, strCommand = N'CRM.view.Type' WHERE strMenuName = 'Types' AND strModuleName = 'CRM' AND intParentMenuID = @CRMMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Competitors' AND strModuleName = 'CRM' AND intParentMenuID = @CRMMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Competitors', N'CRM', @CRMMaintenanceParentMenuId, N'CRM Type', N'Maintenance', N'Screen', N'EntityManagement.view.EntityDirect?showSearch=true&searchCommand=EntityCompetitor', N'small-menu-maintenance', 0, 0, 0, 1, 9, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 9, strCommand = N'EntityManagement.view.EntityDirect?showSearch=true&searchCommand=EntityCompetitor' WHERE strMenuName = 'Competitors' AND strModuleName = 'CRM' AND intParentMenuID = @CRMMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'New Event' AND strModuleName = 'CRM' AND intParentMenuID = @CRMCreateParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'New Event', N'CRM', @CRMCreateParentMenuId, N'CRM New Event', N'Create', N'Screen', N'GlobalComponentEngine.view.Activity?type=event&action=new&entityType=AccountsReceivable.view.EntityProspect&caller=Prospect', N'small-menu-create', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 0, strCommand = N'GlobalComponentEngine.view.Activity?type=event&action=new&entityType=AccountsReceivable.view.EntityProspect&caller=Prospect' WHERE strMenuName = 'New Event' AND strModuleName = 'CRM' AND intParentMenuID = @CRMCreateParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'New Task' AND strModuleName = 'CRM' AND intParentMenuID = @CRMCreateParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'New Task', N'CRM', @CRMCreateParentMenuId, N'CRM New Task', N'Create', N'Screen', N'GlobalComponentEngine.view.Activity?type=task&action=new&entityType=AccountsReceivable.view.EntityProspect&caller=Prospect', N'small-menu-create', 0, 0, 0, 1, 1, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 1, strCommand = N'GlobalComponentEngine.view.Activity?type=task&action=new&entityType=AccountsReceivable.view.EntityProspect&caller=Prospect' WHERE strMenuName = 'New Task' AND strModuleName = 'CRM' AND intParentMenuID = @CRMCreateParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'New Call' AND strModuleName = 'CRM' AND intParentMenuID = @CRMCreateParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'New Call', N'CRM', @CRMCreateParentMenuId, N'CRM New Call', N'Create', N'Screen', N'GlobalComponentEngine.view.Activity?type=call&action=new&entityType=AccountsReceivable.view.EntityProspect&caller=Prospect', N'small-menu-create', 0, 0, 0, 1, 2, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 2, strCommand = N'GlobalComponentEngine.view.Activity?type=call&action=new&entityType=AccountsReceivable.view.EntityProspect&caller=Prospect' WHERE strMenuName = 'New Call' AND strModuleName = 'CRM' AND intParentMenuID = @CRMCreateParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'New Email' AND strModuleName = 'CRM' AND intParentMenuID = @CRMCreateParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'New Email', N'CRM', @CRMCreateParentMenuId, N'CRM New Email', N'Create', N'Screen', N'GlobalComponentEngine.view.ActivityEmail?type=email&action=new&entityType=AccountsReceivable.view.EntityProspect&caller=Prospect', N'small-menu-create', 0, 0, 0, 1, 3, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 3, strCommand = N'GlobalComponentEngine.view.ActivityEmail?type=email&action=new&entityType=AccountsReceivable.view.EntityProspect&caller=Prospect' WHERE strMenuName = 'New Email' AND strModuleName = 'CRM' AND intParentMenuID = @CRMCreateParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'New Opportunity' AND strModuleName = 'CRM' AND intParentMenuID = @CRMCreateParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'New Opportunity', N'CRM', @CRMCreateParentMenuId, N'CRM New Opportunity', N'Create', N'Screen', N'CRM.view.Opportunity?action=new', N'small-menu-create', 0, 0, 0, 1, 4, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 4, strCommand = N'CRM.view.Opportunity?action=new' WHERE strMenuName = 'New Opportunity' AND strModuleName = 'CRM' AND intParentMenuID = @CRMCreateParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'New Campaign' AND strModuleName = 'CRM' AND intParentMenuID = @CRMCreateParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'New Campaign', N'CRM', @CRMCreateParentMenuId, N'CRM New Campaign', N'Create', N'Screen', N'CRM.view.Campaign?action=true', N'small-menu-create', 0, 0, 0, 1, 5, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 5, strCommand = N'CRM.view.Campaign?action=true' WHERE strMenuName = 'New Campaign' AND strModuleName = 'CRM' AND intParentMenuID = @CRMCreateParentMenuId

/* START OF DELETING */
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Create Activity' AND strModuleName = 'CRM' AND intParentMenuID = @CRMActivitiesParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Sales Entity Contacts' AND strModuleName = 'CRM' AND intParentMenuID = @CRMActivitiesParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Lines of Business' AND strModuleName = 'CRM' AND intParentMenuID = @CRMActivitiesParentMenuId
/* END OF DELETING */

/* HELP DESK */
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Help Desk' AND strModuleName = 'Help Desk' AND intParentMenuID = 0)
UPDATE tblSMMasterMenu SET intSort = 21 WHERE strMenuName = 'Help Desk' AND strModuleName = 'Help Desk' AND intParentMenuID = 0

DECLARE @HelpDeskParentMenuId INT
SELECT @HelpDeskParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Help Desk' AND strModuleName = 'Help Desk' AND intParentMenuID = 0

/* CHANGE SCREEN CATEGORY TO 1910 */
UPDATE tblSMMasterMenu SET strCategory = 'Activity', strIcon = 'small-menu-activity' WHERE strMenuName IN ('Projects') AND strModuleName = N'Help Desk'

/* CATEGORY FOLDERS */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Activities' AND strModuleName = 'Help Desk' AND intParentMenuID = @HelpDeskParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Activities', N'Help Desk', @HelpDeskParentMenuId, N'Activities', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 0 WHERE strMenuName = 'Activities' AND strModuleName = 'Help Desk' AND intParentMenuID = @HelpDeskParentMenuId

DECLARE @HelpDeskActivitiesParentMenuId INT
SELECT @HelpDeskActivitiesParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Activities' AND strModuleName = 'Help Desk' AND intParentMenuID = @HelpDeskParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'Help Desk' AND intParentMenuID = @HelpDeskParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Maintenance', N'Help Desk', @HelpDeskParentMenuId, N'Maintenance', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 1, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 1 WHERE strMenuName = 'Maintenance' AND strModuleName = 'Help Desk' AND intParentMenuID = @HelpDeskParentMenuId

DECLARE @HelpDeskMaintenanceParentMenuId INT
SELECT @HelpDeskMaintenanceParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'Help Desk' AND intParentMenuID = @HelpDeskParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Reports' AND strModuleName = 'Help Desk' AND intParentMenuID = @HelpDeskParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Reports', N'Help Desk', @HelpDeskParentMenuId, N'Reports', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 2, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 2 WHERE strMenuName = 'Reports' AND strModuleName = 'Help Desk' AND intParentMenuID = @HelpDeskParentMenuId

DECLARE @HelpDeskReportParentMenuId INT
SELECT @HelpDeskReportParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Reports' AND strModuleName = 'Help Desk' AND intParentMenuID = @HelpDeskParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Import' AND strModuleName = 'Help Desk' AND intParentMenuID = @HelpDeskParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Import', N'Help Desk', @HelpDeskParentMenuId, N'Import', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 3, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 3 WHERE strMenuName = 'Import' AND strModuleName = 'Help Desk' AND intParentMenuID = @HelpDeskParentMenuId

DECLARE @HelpDeskImportParentMenuId INT
SELECT @HelpDeskImportParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Import' AND strModuleName = 'Help Desk' AND intParentMenuID = @HelpDeskParentMenuId

/* ADD TO RESPECTIVE CATEGORY */ 
UPDATE tblSMMasterMenu SET intParentMenuID = @HelpDeskActivitiesParentMenuId WHERE intParentMenuID IN (@HelpDeskParentMenuId, @HelpDeskMaintenanceParentMenuId) AND strCategory = 'Activity'
UPDATE tblSMMasterMenu SET intParentMenuID = @HelpDeskMaintenanceParentMenuId WHERE intParentMenuID =  @HelpDeskParentMenuId AND strCategory = 'Maintenance'

/* RENAME MENU */
UPDATE tblSMMasterMenu SET strMenuName = 'Ticket Summary', strDescription = 'Help Desk Ticket Summary' WHERE strMenuName = N'Call Details' AND strModuleName = 'Help Desk' AND intParentMenuID = @HelpDeskReportParentMenuId
		
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Tickets' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskActivitiesParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 1, strCommand = N'HelpDesk.view.Ticket?showSearch=true&searchCommand=Ticket' WHERE strMenuName = N'Tickets' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskActivitiesParentMenuId

-- IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Export Hours Worked' AND strModuleName = 'Help Desk' AND intParentMenuID = @HelpDeskActivitiesParentMenuId)
-- 	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
-- 	VALUES (N'Export Hours Worked', N'Help Desk', @HelpDeskActivitiesParentMenuId, N'Export Hours Worked', N'Activity', N'Screen', N'HelpDesk.view.ExportHoursWorked', N'small-menu-activity', 0, 0, 0, 1, 2, 1)
-- ELSE 
-- 	UPDATE tblSMMasterMenu SET intSort = 2, strCommand = N'HelpDesk.view.ExportHoursWorked' WHERE strMenuName = 'Export Hours Worked' AND strModuleName = 'Help Desk' AND intParentMenuID = @HelpDeskActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Time Entry' AND strModuleName = 'Help Desk' AND intParentMenuID = @HelpDeskActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Time Entry', N'Help Desk', @HelpDeskActivitiesParentMenuId, N'Time Entry', N'Activity', N'Screen', N'HelpDesk.view.TimeEntry', N'small-menu-activity', 0, 0, 0, 1, 3, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 3, strCommand = N'HelpDesk.view.TimeEntry' WHERE strMenuName = 'Time Entry' AND strModuleName = 'Help Desk' AND intParentMenuID = @HelpDeskActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Projects' AND strModuleName = 'Help Desk' AND intParentMenuID = @HelpDeskActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Projects', N'Help Desk', @HelpDeskActivitiesParentMenuId, N'Help Desk Projects', N'Activity', N'Screen', N'HelpDesk.view.Project?showSearch=true&searchCommand=Project', N'small-menu-activity', 0, 0, 0, 1, 4, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 4, strCommand = N'HelpDesk.view.Project?showSearch=true&searchCommand=Project' WHERE strMenuName = 'Projects' AND strModuleName = 'Help Desk' AND intParentMenuID = @HelpDeskActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Milestones' AND strModuleName = 'Help Desk' AND intParentMenuID = @HelpDeskMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Milestones', N'Help Desk', @HelpDeskMaintenanceParentMenuId, N'Milestones', N'Maintenance', N'Screen', N'HelpDesk.view.Milestone', N'small-menu-maintenance', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 0, strCommand = N'HelpDesk.view.Milestone' WHERE strMenuName = 'Milestones' AND strModuleName = 'Help Desk' AND intParentMenuID = @HelpDeskMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Out of Office Replies' AND strModuleName = 'Help Desk' AND intParentMenuID = @HelpDeskMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Out of Office Replies', N'Help Desk', @HelpDeskMaintenanceParentMenuId, N'Out of Office Replies', N'Maintenance', N'Screen', N'HelpDesk.view.OutOfOfficeReply', N'small-menu-maintenance', 0, 0, 0, 1, 1, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 1, strCommand = N'HelpDesk.view.OutOfOfficeReply' WHERE strMenuName = 'Out of Office Replies' AND strModuleName = 'Help Desk' AND intParentMenuID = @HelpDeskMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Products' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 2, strCommand = N'HelpDesk.view.Product?showSearch=true&searchCommand=Product' WHERE strMenuName = N'Products' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Root Cause' AND strModuleName = 'Help Desk' AND intParentMenuID = @HelpDeskMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Root Cause', N'Help Desk', @HelpDeskMaintenanceParentMenuId, N'Root Cause', N'Maintenance', N'Screen', N'HelpDesk.view.RootCause?showSearch=true&searchCommand=RootCause', N'small-menu-maintenance', 0, 0, 0, 1, 3, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 3, strCommand = N'HelpDesk.view.RootCause?showSearch=true&searchCommand=RootCause' WHERE strMenuName = 'Root Cause' AND strModuleName = 'Help Desk' AND intParentMenuID = @HelpDeskMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Ticket Groups' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 4, strCommand = N'HelpDesk.view.TicketGroup?showSearch=true&searchCommand=Group' WHERE strMenuName = N'Ticket Groups' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Ticket Priorities' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 5, strCommand = N'HelpDesk.view.TicketPriority' WHERE strMenuName = N'Ticket Priorities' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Ticket Statuses' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 6, strCommand = N'HelpDesk.view.TicketStatus' WHERE strMenuName = N'Ticket Statuses' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Ticket Statuses Workflow' AND strModuleName = 'Help Desk' AND intParentMenuID = @HelpDeskMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Ticket Statuses Workflow', N'Help Desk', @HelpDeskMaintenanceParentMenuId, N'Help Desk Ticket Statuses Workflow', N'Maintenance', N'Screen', N'HelpDesk.view.TicketStatusWorkflow', N'small-menu-maintenance', 0, 0, 0, 1, 7, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 7, strCommand = N'HelpDesk.view.TicketStatusWorkflow' WHERE strMenuName = 'Ticket Statuses Workflow' AND strModuleName = 'Help Desk' AND intParentMenuID = @HelpDeskMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Ticket Types' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 8, strCommand = N'HelpDesk.view.TicketType' WHERE strMenuName = N'Ticket Types' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Ticket Summary' AND strModuleName = 'Help Desk' AND intParentMenuID = @HelpDeskReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Ticket Summary', N'Help Desk', @HelpDeskReportParentMenuId, N'Help Desk Ticket Summary', N'Report', N'Screen', N'HelpDesk.view.CallDetailsReport?showSearch=true&searchCommand=CallDetailsReport', N'small-menu-report', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 0, strCommand = N'HelpDesk.view.CallDetailsReport?showSearch=true&searchCommand=CallDetailsReport' WHERE strMenuName = N'Ticket Summary' AND strModuleName = 'Help Desk' AND intParentMenuID = @HelpDeskReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Time / Hours' AND strModuleName = 'Help Desk' AND intParentMenuID = @HelpDeskReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Time / Hours', N'Help Desk', @HelpDeskReportParentMenuId, N'Help Desk Time / Hours', N'Report', N'Screen', N'HelpDesk.view.TimeHoursReport?showSearch=true&searchCommand=TimeHoursReport', N'small-menu-report', 0, 0, 0, 1, 1, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 1, strCommand = N'HelpDesk.view.TimeHoursReport?showSearch=true&searchCommand=TimeHoursReport' WHERE strMenuName = N'Time / Hours' AND strModuleName = 'Help Desk' AND intParentMenuID = @HelpDeskReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Rough Cut Capacity' AND strModuleName = 'Help Desk' AND intParentMenuID = @HelpDeskReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Rough Cut Capacity', N'Help Desk', @HelpDeskReportParentMenuId, N'Help Desk Rough Cut Capacity', N'Report', N'Screen', N'HelpDesk.view.RoughCutCapacityReport?showSearch=true&searchCommand=RoughCutCapacityReport', N'small-menu-report', 0, 0, 0, 1, 2, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 2, strCommand = N'HelpDesk.view.RoughCutCapacityReport?showSearch=true&searchCommand=RoughCutCapacityReport' WHERE strMenuName = N'Rough Cut Capacity' AND strModuleName = 'Help Desk' AND intParentMenuID = @HelpDeskReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Import Tickets from CSV' AND strModuleName = 'Help Desk' AND intParentMenuID = @HelpDeskImportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Import Tickets from CSV', N'Help Desk', @HelpDeskImportParentMenuId, N'Help Desk Import Tickets from CSV', N'Report', N'Screen', N'HelpDesk.view.ImportTicket', N'small-menu-import', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 0, strCommand = N'HelpDesk.view.ImportTicket' WHERE strMenuName = N'Import Tickets from CSV' AND strModuleName = 'Help Desk' AND intParentMenuID = @HelpDeskImportParentMenuId

/* START OF DELETING */
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Help Desk Settings' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Open Tickets' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskActivitiesParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Tickets Assigned to Me' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskActivitiesParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Tickets Reported by Me' AND strModuleName = 'Help Desk' AND intParentMenuID = @HelpDeskMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Create Ticket' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskActivitiesParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Project Lists' AND strModuleName = 'Help Desk' AND intParentMenuID = @HelpDeskMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Email Setup' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Reminder Lists' AND strModuleName = 'Help Desk' AND intParentMenuID = @HelpDeskMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Competitors' AND strModuleName = 'Help Desk' AND intParentMenuID = @CRMParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Ticket Job Codes' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Export Hours Worked' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskActivitiesParentMenuId
/* END OF DELETING */

/* DOCUMENT MANAGEMENT */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Document Management' AND strModuleName = 'Document Management' AND intParentMenuID = 0)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Document Management', N'Document Management', 0, N'Document Management', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 22, 0)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 22 WHERE strMenuName = 'Document Management' AND strModuleName = 'Document Management' AND intParentMenuID = 0

DECLARE @DocumentManagementParentMenuId INT
SELECT @DocumentManagementParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Document Management' AND strModuleName = 'Document Management' AND intParentMenuID = 0

/* CATEGORY FOLDERS */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'Document Management' AND intParentMenuID = @DocumentManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Maintenance', N'Document Management', @DocumentManagementParentMenuId, N'Maintenance', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 0 WHERE strMenuName = 'Maintenance' AND strModuleName = 'Document Management' AND intParentMenuID = @DocumentManagementParentMenuId

DECLARE @DocumentManagementMaintenanceParentMenuId INT
SELECT @DocumentManagementMaintenanceParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'Document Management' AND intParentMenuID = @DocumentManagementParentMenuId

/* ADD TO RESPECTIVE CATEGORY */ 
UPDATE tblSMMasterMenu SET intParentMenuID = @DocumentManagementMaintenanceParentMenuId WHERE intParentMenuID =  @DocumentManagementParentMenuId AND strCategory = 'Maintenance'

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Add Documents' AND strModuleName = 'System Manager' AND intParentMenuID = @DocumentManagementMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Add Documents', N'System Manager', @DocumentManagementMaintenanceParentMenuId, N'Add Documents', N'Maintenance', N'Screen', N'GlobalComponentEngine.view.DocumentPending?activeTab=Add', N'small-menu-maintenance', 0, 0, 0, 1, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = N'GlobalComponentEngine.view.DocumentPending?activeTab=Add', intSort = 0 WHERE strMenuName = 'Add Documents' AND strModuleName = 'System Manager' AND intParentMenuID = @DocumentManagementMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Document Configuration' AND strModuleName = 'System Manager' AND intParentMenuID = @DocumentManagementMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Document Configuration', N'System Manager', @DocumentManagementMaintenanceParentMenuId, N'Document Configuration', N'Maintenance', N'Screen', N'GlobalComponentEngine.view.DocumentConfiguration', N'small-menu-maintenance', 0, 0, 0, 1, 1, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = N'GlobalComponentEngine.view.DocumentConfiguration', intSort = 1 WHERE strMenuName = 'Document Configuration' AND strModuleName = 'System Manager' AND intParentMenuID = @DocumentManagementMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Document Manager' AND strModuleName = 'System Manager' AND intParentMenuID = @DocumentManagementMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Document Manager', N'System Manager', @DocumentManagementMaintenanceParentMenuId, N'Document Manager', N'Maintenance', N'Screen', N'GlobalComponentEngine.view.DocumentManager?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 2, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = N'GlobalComponentEngine.view.DocumentManager?showSearch=true', intSort = 2 WHERE strMenuName = 'Document Manager' AND strModuleName = 'System Manager' AND intParentMenuID = @DocumentManagementMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Document Source' AND strModuleName = 'System Manager' AND intParentMenuID = @DocumentManagementMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Document Source', N'System Manager', @DocumentManagementMaintenanceParentMenuId, N'Document Source', N'Maintenance', N'Screen', N'GlobalComponentEngine.view.DocumentSource', N'small-menu-maintenance', 0, 0, 0, 1, 3, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = N'GlobalComponentEngine.view.DocumentSource', intSort = 3 WHERE strMenuName = 'Document Source' AND strModuleName = 'System Manager' AND intParentMenuID = @DocumentManagementMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Document Type' AND strModuleName = 'System Manager' AND intParentMenuID = @DocumentManagementMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Document Type', N'System Manager', @DocumentManagementMaintenanceParentMenuId, N'Document Type', N'Maintenance', N'Screen', N'GlobalComponentEngine.view.DocumentType?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 4, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = N'GlobalComponentEngine.view.DocumentType?showSearch=true', intSort = 4 WHERE strMenuName = 'Document Type' AND strModuleName = 'System Manager' AND intParentMenuID = @DocumentManagementMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Pending Documents' AND strModuleName = 'System Manager' AND intParentMenuID = @DocumentManagementMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Pending Documents', N'System Manager', @DocumentManagementMaintenanceParentMenuId, N'Pending Documents', N'Maintenance', N'Screen', N'GlobalComponentEngine.view.DocumentPending?activeTab=Pending', N'small-menu-maintenance', 0, 0, 0, 1, 5, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = N'GlobalComponentEngine.view.DocumentPending?activeTab=Pending', intSort = 5 WHERE strMenuName = 'Pending Documents' AND strModuleName = 'System Manager' AND intParentMenuID = @DocumentManagementMaintenanceParentMenuId

/* TRANSPORTS */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Transports' AND strModuleName = 'Transports' AND intParentMenuID = 0)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Transports', N'Transports', 0, N'Transports', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 23, 0)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 23 WHERE strMenuName = 'Transports' AND strModuleName = 'Transports' AND intParentMenuID = 0

DECLARE @TransportsParentMenuId INT
SELECT @TransportsParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Transports' AND strModuleName = 'Transports' AND intParentMenuID = 0



/* CATEGORY FOLDERS */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Activities' AND strModuleName = 'Transports' AND intParentMenuID = @TransportsParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intRow], [intConcurrencyId]) 
	VALUES (N'Activities', N'Transports', @TransportsParentMenuId, N'Activities', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 0, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 0, intRow = 0 WHERE strMenuName = 'Activities' AND strModuleName = 'Transports' AND intParentMenuID = @TransportsParentMenuId

DECLARE @TransportsActivitiesParentMenuId INT
SELECT @TransportsActivitiesParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Activities' AND strModuleName = 'Transports' AND intParentMenuID = @TransportsParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'Transports' AND intParentMenuID = @TransportsParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intRow], [intConcurrencyId]) 
	VALUES (N'Maintenance', N'Transports', @TransportsParentMenuId, N'Maintenance', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 1, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 1, intRow = 0 WHERE strMenuName = 'Maintenance' AND strModuleName = 'Transports' AND intParentMenuID = @TransportsParentMenuId

DECLARE @TransportsMaintenanceParentMenuId INT
SELECT @TransportsMaintenanceParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'Transports' AND intParentMenuID = @TransportsParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Import' AND strModuleName = 'Transports' AND intParentMenuID = @TransportsParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intRow], [intConcurrencyId]) 
	VALUES (N'Import', N'Transports', @TransportsParentMenuId, N'Import', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 1, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 1, intRow = 0 WHERE strMenuName = 'Import' AND strModuleName = 'Transports' AND intParentMenuID = @TransportsParentMenuId

DECLARE @TransportsImportParentMenuId INT
SELECT @TransportsImportParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Import' AND strModuleName = 'Transports' AND intParentMenuID = @TransportsParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Create' AND strModuleName = 'Transports' AND intParentMenuID = @TransportsParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intRow], [intConcurrencyId]) 
	VALUES (N'Create', N'Transports', @TransportsParentMenuId, N'Create', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 0, 1, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 0, intRow = 1 WHERE strMenuName = 'Create' AND strModuleName = 'Transports' AND intParentMenuID = @TransportsParentMenuId




	
DECLARE @TransportsCreateParentMenuId INT
SELECT @TransportsCreateParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Create' AND strModuleName = 'Transports' AND intParentMenuID = @TransportsParentMenuId

/* ADD TO RESPECTIVE CATEGORY */ 
UPDATE tblSMMasterMenu SET intParentMenuID = @TransportsActivitiesParentMenuId WHERE intParentMenuID =  @TransportsParentMenuId AND strCategory = 'Activity'
UPDATE tblSMMasterMenu SET intParentMenuID = @TransportsMaintenanceParentMenuId WHERE intParentMenuID =  @TransportsParentMenuId AND strCategory = 'Maintenance'

/* START OF PLURALIZING  */
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Transport Load' AND strModuleName = 'Transports' AND intParentMenuID = @TransportsActivitiesParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = N'Transport Loads', strDescription = N'Transport Loads' WHERE strMenuName = 'Transport Load' AND strModuleName = 'Transports' AND intParentMenuID = @TransportsActivitiesParentMenuId
/* END OF PLURALIZING  */

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Transport Loads' AND strModuleName = 'Transports' AND intParentMenuID = @TransportsActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Transport Loads', N'Transports', @TransportsActivitiesParentMenuId, N'Transport Loads', N'Activity', N'Screen', N'Transports.view.TransportLoads?showSearch=true&searchCommand=TransportLoad', N'small-menu-activity', 0, 0, 0, 1, 1, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = N'Transports.view.TransportLoads?showSearch=true&searchCommand=TransportLoad', intSort = 1 WHERE strMenuName = 'Transport Loads' AND strModuleName = 'Transports' AND intParentMenuID = @TransportsActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Quote' AND strModuleName = 'Transports' AND intParentMenuID = @TransportsActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Quote', N'Transports', @TransportsActivitiesParentMenuId, N'Quote', N'Activity', N'Screen', N'Transports.view.Quote?showSearch=true&searchCommand=Quote', N'small-menu-activity', 0, 0, 0, 1, 2, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Transports.view.Quote?showSearch=true&searchCommand=Quote', intSort = 2 WHERE strMenuName = 'Quote' AND strModuleName = 'Transports' AND intParentMenuID = @TransportsActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Rack Price' AND strModuleName = 'Transports' AND intParentMenuID = @TransportsActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Rack Price', N'Transports', @TransportsActivitiesParentMenuId, N'Rack Price', N'Activity', N'Screen', N'Transports.view.RackPrice?showSearch=true&searchCommand=RackPrice', N'small-menu-activity', 0, 0, 0, 1, 3, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Transports.view.RackPrice?showSearch=true&searchCommand=RackPrice', intSort = 3 WHERE strMenuName = 'Rack Price' AND strModuleName = 'Transports' AND intParentMenuID = @TransportsActivitiesParentMenuId

DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Supply Point' AND strModuleName = 'Transports'

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Batch Posting' AND strModuleName = 'Transports' AND intParentMenuID = @TransportsActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Batch Posting', N'Transports', @TransportsActivitiesParentMenuId, N'Batch Posting', N'Activity', N'Screen', N'i21.view.BatchPosting?module=Transports', N'small-menu-activity', 0, 0, 0, 1, 4, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'i21.view.BatchPosting?module=Transports', intSort = 4 WHERE strMenuName = 'Batch Posting' AND strModuleName = 'Transports' AND intParentMenuID = @TransportsActivitiesParentMenuId


IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Bulk Plant Freight' AND strModuleName = 'Transports' AND intParentMenuID = @TransportsMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Bulk Plant Freight', N'Transports', @TransportsMaintenanceParentMenuId, N'Bulk Plant Freight', N'Maintenance', N'Screen', N'Transports.view.BulkPlantFreight', N'small-menu-maintenance', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Transports.view.BulkPlantFreight', intSort = 0 WHERE strMenuName = 'Bulk Plant Freight' AND strModuleName = 'Transports' AND intParentMenuID = @TransportsMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Quote Price Adjustment' AND strModuleName = 'Transports' AND intParentMenuID = @TransportsMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Quote Price Adjustment', N'Transports', @TransportsMaintenanceParentMenuId, N'Quote Price Adjustment', N'Maintenance', N'Screen', N'Transports.view.QuotePriceAdjustment?showSearch=true&searchCommand=QuotePriceAdjustment', N'small-menu-maintenance', 0, 0, 0, 1, 1, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Transports.view.QuotePriceAdjustment?showSearch=true&searchCommand=QuotePriceAdjustment', intSort = 1 WHERE strMenuName = 'Quote Price Adjustment' AND strModuleName = 'Transports' AND intParentMenuID = @TransportsMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Cross Reference – Vendor Invoice Import' AND strModuleName = 'Transports' AND intParentMenuID = @TransportsMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Cross Reference – Vendor Invoice Import', N'Transports', @TransportsMaintenanceParentMenuId, N'Cross Reference – Vendor Invoice Import', N'Maintenance', N'Screen', N'Transports.view.CrossReferenceDtn', N'small-menu-maintenance', 0, 0, 0, 1, 1, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = N'Transports.view.CrossReferenceDtn', intSort = 1 WHERE strMenuName = 'Cross Reference – Vendor Invoice Import' AND strModuleName = 'Transports' AND intParentMenuID = @TransportsMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Cross Reference - BOL Import' AND strModuleName = 'Transports' AND intParentMenuID = @TransportsMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Cross Reference - BOL Import', N'Transports', @TransportsMaintenanceParentMenuId, N'Cross Reference - BOL Import', N'Maintenance', N'Screen', N'Transports.view.CrossReferenceBol', N'small-menu-maintenance', 0, 0, 0, 1, 2, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Transports.view.CrossReferenceBol', intSort = 1 WHERE strMenuName = 'Cross Reference - BOL Import' AND strModuleName = 'Transports' AND intParentMenuID = @TransportsMaintenanceParentMenuId	

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Tax Group Override' AND strModuleName = 'Transports' AND intParentMenuID = @TransportsMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Tax Group Override', N'Transports', @TransportsMaintenanceParentMenuId, N'Tax Group Override', N'Maintenance', N'Screen', N'Transports.view.OverrideTaxGroup', N'small-menu-maintenance', 0, 0, 0, 1, 3, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Transports.view.OverrideTaxGroup', intSort = 1 WHERE strMenuName = 'Tax Group Override' AND strModuleName = 'Transports' AND intParentMenuID = @TransportsMaintenanceParentMenuId	


IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Import Rack Price' AND strModuleName = 'Transports' AND intParentMenuID = @TransportsImportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Import Rack Price', N'Transports', @TransportsImportParentMenuId, N'Import Rack Price', N'Import', N'Screen', N'Transports.view.ImportRackPrice', N'small-menu-import', 0, 0, 0, 1, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = N'Transports.view.ImportRackPrice', intSort = 0 WHERE strMenuName = 'Import Rack Price' AND strModuleName = 'Transports' AND intParentMenuID = @TransportsImportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Import Bill Of Lading' AND strModuleName = 'Transports' AND intParentMenuID = @TransportsImportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Import Bill Of Lading', N'Transports', @TransportsImportParentMenuId, N'Import Bill Of Lading', N'Import', N'Screen', N'Transports.view.ImportLoad', N'small-menu-import', 0, 0, 0, 1, 1, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = N'Transports.view.ImportLoad', intSort = 0 WHERE strMenuName = 'Import Bill Of Lading' AND strModuleName = 'Transports' AND intParentMenuID = @TransportsImportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Import Vendor Invoice - DTN' AND strModuleName = 'Transports' AND intParentMenuID = @TransportsImportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Import Vendor Invoice - DTN', N'Transports', @TransportsImportParentMenuId, N'Import Vendor Invoice - DTN', N'Import', N'Screen', N'Transports.view.ImportDtnOutboundInvoice', N'small-menu-import', 0, 0, 0, 1, 2, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = N'Transports.view.ImportDtnOutboundInvoice', intSort = 0 WHERE strMenuName = 'Import Vendor Invoice - DTN' AND strModuleName = 'Transports' AND intParentMenuID = @TransportsImportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'New Rack Price' AND strModuleName = 'Transports' AND intParentMenuID = @TransportsCreateParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'New Rack Price', N'Transports', @TransportsCreateParentMenuId, N'New Rack Price', N'Create', N'Screen', N'Transports.view.RackPrice?action=new', N'small-menu-create', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Transports.view.RackPrice?action=new', intSort = 0 WHERE strMenuName = 'New Rack Price' AND strModuleName = 'Transports' AND intParentMenuID = @TransportsCreateParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'New Transport Load' AND strModuleName = 'Transports' AND intParentMenuID = @TransportsCreateParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'New Transport Load', N'Transports', @TransportsCreateParentMenuId, N'New Transport Load', N'Create', N'Screen', N'Transports.view.TransportLoads?action=new', N'small-menu-Create', 0, 0, 0, 1, 1, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = N'Transports.view.TransportLoads?action=new', intSort = 1 WHERE strMenuName = 'New Transport Load' AND strModuleName = 'Transports' AND intParentMenuID = @TransportsCreateParentMenuId
		
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'New Quote' AND strModuleName = 'Transports' AND intParentMenuID = @TransportsCreateParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'New Quote', N'Transports', @TransportsCreateParentMenuId, N'New Quote', N'Create', N'Screen', N'Transports.view.Quote?action=new', N'small-menu-create', 0, 0, 0, 1, 2, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Transports.view.Quote?action=new', intSort = 2 WHERE strMenuName = 'New Quote' AND strModuleName = 'Transports' AND intParentMenuID = @TransportsCreateParentMenuId


DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Quote Report' AND strModuleName = 'Transports'
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Reports' and strModuleName = 'Transports'



/* METER BILLING */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Meter Billing' AND strModuleName = 'Meter Billing' AND intParentMenuID = 0)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Meter Billing', N'Meter Billing', 0, N'Meter Billing', NULL, N'Folder', N'', N'small-folder', 1, 1, 0, 0, 24, 0)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 24 WHERE strMenuName = 'Meter Billing' AND strModuleName = 'Meter Billing' AND intParentMenuID = 0

DECLARE @MeterBillingParentMenuId INT
SELECT @MeterBillingParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Meter Billing' AND strModuleName = 'Meter Billing' AND intParentMenuID = 0

/* CATEGORY FOLDERS */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Activities' AND strModuleName = 'Meter Billing' AND intParentMenuID = @MeterBillingParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Activities', N'Meter Billing', @MeterBillingParentMenuId, N'Activities', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 0 WHERE strMenuName = 'Activities' AND strModuleName = 'Meter Billing' AND intParentMenuID = @MeterBillingParentMenuId

DECLARE @MeterBillingActivitiesParentMenuId INT
SELECT @MeterBillingActivitiesParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Activities' AND strModuleName = 'Meter Billing' AND intParentMenuID = @MeterBillingParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'Meter Billing' AND intParentMenuID = @MeterBillingParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Maintenance', N'Meter Billing', @MeterBillingParentMenuId, N'Maintenance', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 1, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 1 WHERE strMenuName = 'Maintenance' AND strModuleName = 'Meter Billing' AND intParentMenuID = @MeterBillingParentMenuId

DECLARE @MeterBillingMaintenanceParentMenuId INT
SELECT @MeterBillingMaintenanceParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'Meter Billing' AND intParentMenuID = @MeterBillingParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Create' AND strModuleName = 'Meter Billing' AND intParentMenuID = @MeterBillingParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intRow], [intSort], [intConcurrencyId]) 
	VALUES (N'Create', N'Meter Billing', @MeterBillingParentMenuId, N'Create', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 1, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intRow = 1, intSort = 0 WHERE strMenuName = 'Create' AND strModuleName = 'Meter Billing' AND intParentMenuID = @MeterBillingParentMenuId
	
DECLARE @MeterBillingCreateParentMenuId INT
SELECT @MeterBillingCreateParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Create' AND strModuleName = 'Meter Billing' AND intParentMenuID = @MeterBillingParentMenuId

/* ADD TO RESPECTIVE CATEGORY */ 
UPDATE tblSMMasterMenu SET intParentMenuID = @MeterBillingActivitiesParentMenuId WHERE intParentMenuID =  @MeterBillingParentMenuId AND strCategory = 'Activity'
UPDATE tblSMMasterMenu SET intParentMenuID = @MeterBillingMaintenanceParentMenuId WHERE intParentMenuID =  @MeterBillingParentMenuId AND strCategory = 'Maintenance'
UPDATE tblSMMasterMenu SET intParentMenuID = @MeterBillingCreateParentMenuId WHERE intParentMenuID =  @MeterBillingParentMenuId AND strCategory = 'Create'

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Meter Readings' AND strModuleName = 'Meter Billing' AND intParentMenuID = @MeterBillingActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Meter Readings', N'Meter Billing', @MeterBillingActivitiesParentMenuId, N'Meter Readings', N'Activity', N'Screen', N'MeterBilling.view.MeterReadings?showSearch=true&searchCommand=MeterReadings', N'small-menu-activity', 1, 1, 0, 1, 1, 0)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'MeterBilling.view.MeterReadings?showSearch=true&searchCommand=MeterReadings', intSort = 1 WHERE strMenuName = 'Meter Readings' AND strModuleName = 'Meter Billing' AND intParentMenuID = @MeterBillingActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Batch Posting' AND strModuleName = 'Meter Billing' AND intParentMenuID = @MeterBillingActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Batch Posting', N'Meter Billing', @MeterBillingActivitiesParentMenuId, N'Batch Posting', N'Activity', N'Screen', N'i21.view.BatchPosting?module=Meter Billing', N'small-menu-activity', 1, 1, 0, 1, 2, 0)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'i21.view.BatchPosting?module=Meter Billing', intSort = 2 WHERE strMenuName = 'Batch Posting' AND strModuleName = 'Meter Billing' AND intParentMenuID = @MeterBillingActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Consignment Rate' AND strModuleName = 'Meter Billing' AND intParentMenuID = @MeterBillingMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Consignment Rate', N'Meter Billing', @MeterBillingMaintenanceParentMenuId, N'Consignment Rate', N'Maintenance', N'Screen', N'MeterBilling.view.ConsignmentRate?showSearch=true&searchCommand=ConsignmentRate', N'small-menu-activity', 1, 1, 0, 1, 3, 0)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'MeterBilling.view.ConsignmentRate?showSearch=true&searchCommand=ConsignmentRate', intSort = 3 WHERE strMenuName = 'Consignment Rate' AND strModuleName = 'Meter Billing' AND intParentMenuID = @MeterBillingMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Fueling Point Price Change' AND strModuleName = 'Meter Billing' AND intParentMenuID = @MeterBillingMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Fueling Point Price Change', N'Meter Billing', @MeterBillingMaintenanceParentMenuId, N'Fueling Point Price Change', N'Maintenance', N'Screen', N'MeterBilling.view.FuelingPointPriceChange?showSearch=true&searchCommand=FuelPointPriceChange', N'small-menu-activity', 1, 1, 0, 1, 4, 0)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'MeterBilling.view.FuelingPointPriceChange?showSearch=true&searchCommand=FuelPointPriceChange', intSort = 4 WHERE strMenuName = 'Fueling Point Price Change' AND strModuleName = 'Meter Billing' AND intParentMenuID = @MeterBillingMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Fueling Point Reading' AND strModuleName = 'Meter Billing' AND intParentMenuID = @MeterBillingMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Fueling Point Reading', N'Meter Billing', @MeterBillingMaintenanceParentMenuId, N'Fueling Point Reading', N'Maintenance', N'Screen', N'MeterBilling.view.FuelingPointReading?showSearch=true&searchCommand=FuelPointReading', N'small-menu-activity', 1, 1, 0, 1, 5, 0)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'MeterBilling.view.FuelingPointReading?showSearch=true&searchCommand=FuelPointReading', intSort = 5 WHERE strMenuName = 'Fueling Point Reading' AND strModuleName = 'Meter Billing' AND intParentMenuID = @MeterBillingMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Meter Account' AND strModuleName = 'Meter Billing' AND intParentMenuID = @MeterBillingMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Meter Account', N'Meter Billing', @MeterBillingMaintenanceParentMenuId, N'Meter Account', N'Maintenance', N'Screen', N'MeterBilling.view.MeterAccount?showSearch=true&searchCommand=MeterAccount', N'small-menu-activity', 1, 1, 0, 1, 6, 0)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'MeterBilling.view.MeterAccount?showSearch=true&searchCommand=MeterAccount', intSort = 6 WHERE strMenuName = 'Meter Account' AND strModuleName = 'Meter Billing' AND intParentMenuID = @MeterBillingMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'New Meter Readings' AND strModuleName = 'Meter Billing' AND intParentMenuID = @MeterBillingCreateParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'New Meter Readings', N'Meter Billing', @MeterBillingCreateParentMenuId, N'New Meter Readings', N'Create', N'Screen', N'MeterBilling.view.MeterReadings?action=new', N'small-menu-create', 0, 0, 0, 1, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = N'MeterBilling.view.MeterReadings?action=new', intSort = 0 WHERE strMenuName = 'New Meter Readings' AND strModuleName = 'Meter Billing' AND intParentMenuID = @MeterBillingCreateParentMenuId

/* QUALITY */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Quality' AND strModuleName = 'Quality' AND intParentMenuID = 0)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Quality', N'Quality', 0, N'Quality', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 25, 0)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 25 WHERE strMenuName = 'Quality' AND strModuleName = 'Quality' AND intParentMenuID = 0

DECLARE @QualityParentMenuId INT
SELECT @QualityParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Quality' AND strModuleName = 'Quality' AND intParentMenuID = 0

/* Change Category - 1910 */
UPDATE tblSMMasterMenu SET strCategory = N'Activity', strIcon = N'small-menu-activity' WHERE strMenuName IN ('Sample Entry') AND strModuleName = 'Quality'
UPDATE tblSMMasterMenu SET strCategory = N'Maintenance', strIcon = N'small-menu-maintenance' WHERE strMenuName IN ('Quality View', 'Quality Parameters') AND strModuleName = 'Quality'

/* CATEGORY FOLDERS */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Activities' AND strModuleName = 'Quality' AND intParentMenuID = @QualityParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Activities', N'Quality', @QualityParentMenuId, N'Activities', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 0 WHERE strMenuName = 'Activities' AND strModuleName = 'Quality' AND intParentMenuID = @QualityParentMenuId

DECLARE @QualityActivitiesParentMenuId INT
SELECT @QualityActivitiesParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Activities' AND strModuleName = 'Quality' AND intParentMenuID = @QualityParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'Quality' AND intParentMenuID = @QualityParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Maintenance', N'Quality', @QualityParentMenuId, N'Maintenance', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 1, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 1 WHERE strMenuName = 'Maintenance' AND strModuleName = 'Quality' AND intParentMenuID = @QualityParentMenuId

DECLARE @QualityMaintenanceParentMenuId INT
SELECT @QualityMaintenanceParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'Quality' AND intParentMenuID = @QualityParentMenuId

/* ADD TO RESPECTIVE CATEGORY */ 
UPDATE tblSMMasterMenu SET intParentMenuID = @QualityActivitiesParentMenuId WHERE intParentMenuID IN (@QualityParentMenuId, @QualityMaintenanceParentMenuId) AND strCategory = 'Activity'
UPDATE tblSMMasterMenu SET intParentMenuID = @QualityMaintenanceParentMenuId WHERE intParentMenuID IN (@QualityParentMenuId, @QualityActivitiesParentMenuId) AND strCategory = 'Maintenance'

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Sample Entry' AND strModuleName = 'Quality' AND intParentMenuID = @QualityActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Sample Entry', N'Quality', @QualityActivitiesParentMenuId, N'Sample Entry', N'Activity', N'Screen', N'Quality.view.QualitySample?showSearch=true', N'small-menu-activity', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 0, strCommand = N'Quality.view.QualitySample?showSearch=true' WHERE strMenuName = 'Sample Entry' AND strModuleName = 'Quality' AND intParentMenuID = @QualityActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Quality Parameters' AND strModuleName = 'Quality' AND intParentMenuID = @QualityMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Quality Parameters', N'Quality', @QualityMaintenanceParentMenuId, N'Quality Parameters', N'Maintenance', N'Screen', N'Quality.view.QualityParameters?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 0, strCommand = N'Quality.view.QualityParameters?showSearch=true' WHERE strMenuName = 'Quality Parameters' AND strModuleName = 'Quality' AND intParentMenuID = @QualityMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Quality View' AND strModuleName = 'Quality' AND intParentMenuID = @QualityMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Quality View', N'Quality', @QualityMaintenanceParentMenuId, N'Quality View', N'Maintenance', N'Screen', N'Quality.view.QualityException', N'small-menu-maintenance', 0, 0, 0, 1, 1, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 1, strCommand = N'Quality.view.QualityException' WHERE strMenuName = 'Quality View' AND strModuleName = 'Quality' AND intParentMenuID = @QualityMaintenanceParentMenuId

DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Quality Exception View' AND strModuleName = 'Quality'
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Attribute' AND strModuleName = 'Quality'
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Sample Type' AND strModuleName = 'Quality'
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'List' AND strModuleName = 'Quality'
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Property' AND strModuleName = 'Quality'
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Test' AND strModuleName = 'Quality'
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Quality Template' AND strModuleName = 'Quality'
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Report Property' AND strModuleName = 'Quality'
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Quality Sample' AND strModuleName = 'Quality'
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Contract Quality View' AND strModuleName = 'Quality'
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Lot Quality View' AND strModuleName = 'Quality'

/* WAREHOUSE */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Warehouse' AND strModuleName = 'Warehouse' AND intParentMenuID = 0)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Warehouse', N'Warehouse', 0, N'Warehouse', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 26, 0)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 26 WHERE strMenuName = 'Warehouse' AND strModuleName = 'Warehouse' AND intParentMenuID = 0

DECLARE @WarehouseParentMenuId INT
SELECT @WarehouseParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Warehouse' AND strModuleName = 'Warehouse' AND intParentMenuID = 0

/* CATEGORY FOLDERS */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Activities' AND strModuleName = 'Warehouse' AND intParentMenuID = @WarehouseParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Activities', N'Warehouse', @WarehouseParentMenuId, N'Activities', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 0 WHERE strMenuName = 'Activities' AND strModuleName = 'Warehouse' AND intParentMenuID = @WarehouseParentMenuId

DECLARE @WarehouseActivitiesParentMenuId INT
SELECT @WarehouseActivitiesParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Activities' AND strModuleName = 'Warehouse' AND intParentMenuID = @WarehouseParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'Warehouse' AND intParentMenuID = @WarehouseParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Maintenance', N'Warehouse', @WarehouseParentMenuId, N'Maintenance', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 1, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 1 WHERE strMenuName = 'Maintenance' AND strModuleName = 'Warehouse' AND intParentMenuID = @WarehouseParentMenuId

DECLARE @WarehouseMaintenanceParentMenuId INT
SELECT @WarehouseMaintenanceParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'Warehouse' AND intParentMenuID = @WarehouseParentMenuId

/* ADD TO RESPECTIVE CATEGORY */ 
UPDATE tblSMMasterMenu SET intParentMenuID = @WarehouseActivitiesParentMenuId WHERE intParentMenuID =  @WarehouseParentMenuId AND strCategory = 'Activity'
UPDATE tblSMMasterMenu SET intParentMenuID = @WarehouseMaintenanceParentMenuId WHERE intParentMenuID =  @WarehouseParentMenuId AND strCategory = 'Maintenance'

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Truck' AND strModuleName = 'Warehouse' AND intParentMenuID = @WarehouseActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Truck', N'Warehouse', @WarehouseActivitiesParentMenuId, N'Truck', N'Activity', N'Screen', N'Warehouse.view.Truck', N'small-menu-activity', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 0, strCommand = N'Warehouse.view.Truck' WHERE strMenuName = 'Truck' AND strModuleName = 'Warehouse' AND intParentMenuID = @WarehouseActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Task' AND strModuleName = 'Warehouse' AND intParentMenuID = @WarehouseActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Task', N'Warehouse', @WarehouseActivitiesParentMenuId, N'Task', N'Activity', N'Screen', N'Warehouse.view.Task', N'small-menu-activity', 0, 0, 0, 1, 1, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 1, strCommand = N'Warehouse.view.Task' WHERE strMenuName = 'Task' AND strModuleName = 'Warehouse' AND intParentMenuID = @WarehouseActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Traffic' AND strModuleName = 'Warehouse' AND intParentMenuID = @WarehouseActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Traffic', N'Warehouse', @WarehouseActivitiesParentMenuId, N'Traffic', N'Activity', N'Screen', N'Warehouse.view.Traffic', N'small-menu-activity', 0, 0, 0, 1, 2, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 2, strCommand = N'Warehouse.view.Traffic' WHERE strMenuName = 'Traffic' AND strModuleName = 'Warehouse' AND intParentMenuID = @WarehouseActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Inbound Order' AND strModuleName = 'Warehouse' AND intParentMenuID = @WarehouseActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Inbound Order', N'Warehouse', @WarehouseActivitiesParentMenuId, N'Inbound Order', N'Activity', N'Screen', N'Warehouse.view.InboundOrder', N'small-menu-activity', 0, 0, 0, 1, 3, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 3, strCommand = N'Warehouse.view.InboundOrder' WHERE strMenuName = 'Inbound Order' AND strModuleName = 'Warehouse' AND intParentMenuID = @WarehouseActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Outbound Order' AND strModuleName = 'Warehouse' AND intParentMenuID = @WarehouseActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Outbound Order', N'Warehouse', @WarehouseActivitiesParentMenuId, N'Outbound Order', N'Activity', N'Screen', N'Warehouse.view.OutboundOrder', N'small-menu-activity', 0, 0, 0, 1, 4, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 4, strCommand = N'Warehouse.view.OutboundOrder' WHERE strMenuName = 'Outbound Order' AND strModuleName = 'Warehouse' AND intParentMenuID = @WarehouseActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Cycle Count' AND strModuleName = 'Warehouse' AND intParentMenuID = @WarehouseActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Cycle Count', N'Warehouse', @WarehouseActivitiesParentMenuId, N'Cycle Count', N'Activity', N'Screen', N'Warehouse.view.CycleCount', N'small-menu-activity', 0, 0, 0, 1, 5, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 5, strCommand = N'Warehouse.view.CycleCount' WHERE strMenuName = 'Cycle Count' AND strModuleName = 'Warehouse' AND intParentMenuID = @WarehouseActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Container' AND strModuleName = 'Warehouse' AND intParentMenuID = @WarehouseMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Container', N'Warehouse', @WarehouseMaintenanceParentMenuId, N'Container', N'Maintenance', N'Screen', N'Warehouse.view.Container', N'small-menu-maintenance', 0, 0, 0, 1, 6, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 6, strCommand = N'Warehouse.view.Container' WHERE strMenuName = 'Container' AND strModuleName = 'Warehouse' AND intParentMenuID = @WarehouseMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Container Type' AND strModuleName = 'Warehouse' AND intParentMenuID = @WarehouseMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Container Type', N'Warehouse', @WarehouseMaintenanceParentMenuId, N'Container Type', N'Maintenance', N'Screen', N'Warehouse.view.ContainerType', N'small-menu-maintenance', 0, 0, 0, 1, 7, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 7, strCommand = N'Warehouse.view.ContainerType' WHERE strMenuName = 'Container Type' AND strModuleName = 'Warehouse' AND intParentMenuID = @WarehouseMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'SKU' AND strModuleName = 'Warehouse' AND intParentMenuID = @WarehouseMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'SKU', N'Warehouse', @WarehouseMaintenanceParentMenuId, N'SKU', N'Maintenance', N'Screen', N'Warehouse.view.SKU', N'small-menu-maintenance', 0, 0, 0, 1, 8, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 8, strCommand = N'Warehouse.view.SKU' WHERE strMenuName = 'SKU' AND strModuleName = 'Warehouse' AND intParentMenuID = @WarehouseMaintenanceParentMenuId

/* TAX FORM */
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Tax Form' AND strModuleName = 'Tax Form' AND intParentMenuID = 0)
UPDATE tblSMMasterMenu SET strMenuName = 'Motor Fuel Tax Forms', strDescription = 'Motor Fuel Tax Forms' WHERE strMenuName = 'Tax Form' AND strModuleName = 'Tax Form' AND intParentMenuID = 0

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Motor Fuel Tax Forms' AND strModuleName = 'Tax Form' AND intParentMenuID = 0)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Motor Fuel Tax Forms', N'Tax Form', 0, N'Motor Fuel Tax Forms', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 27, 0)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 27 WHERE strMenuName = 'Motor Fuel Tax Forms' AND strModuleName = 'Tax Form' AND intParentMenuID = 0

DECLARE @TaxFormParentMenuId INT
SELECT @TaxFormParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Motor Fuel Tax Forms' AND strModuleName = 'Tax Form' AND intParentMenuID = 0

/* CATEGORY FOLDERS */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'Tax Form' AND intParentMenuID = @TaxFormParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Maintenance', N'Tax Form', @TaxFormParentMenuId, N'Maintenance', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 0 WHERE strMenuName = 'Maintenance' AND strModuleName = 'Tax Form' AND intParentMenuID = @TaxFormParentMenuId

DECLARE @TaxFormMaintenanceParentMenuId INT
SELECT @TaxFormMaintenanceParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'Tax Form' AND intParentMenuID = @TaxFormParentMenuId

/* ADD TO RESPECTIVE CATEGORY */ 
UPDATE tblSMMasterMenu SET intParentMenuID = @TaxFormMaintenanceParentMenuId WHERE intParentMenuID =  @TaxFormParentMenuId AND strCategory = 'Maintenance'

/* START OF RENAMING  */
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Tax Authority' AND strModuleName = 'Tax Form' AND intParentMenuID = @TaxFormMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Tax Authorities' WHERE strMenuName = 'Tax Authority' AND strModuleName = 'Tax Form' AND intParentMenuID = @TaxFormMaintenanceParentMenuId
/* END OF RENAMING  */

--IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Integration' AND strModuleName = 'Tax Form' AND intParentMenuID = @TaxFormMaintenanceParentMenuId)
--	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId])
--	VALUES (N'Integration', N'Tax Form', @TaxFormMaintenanceParentMenuId, N'Integration', N'Maintenance', N'Screen', N'TaxForm.view.Integration', N'small-menu-maintenance', 0, 0, 0, 1, 0, 1)
--ELSE
--	UPDATE tblSMMasterMenu SET intSort = 0, strCommand = N'TaxForm.view.Integration' WHERE strMenuName = 'Integration' AND strModuleName = 'Tax Form' AND intParentMenuID = @TaxFormMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Tax Authorities' AND strModuleName = 'Tax Form' AND intParentMenuID = @TaxFormMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId])
	VALUES (N'Tax Authorities', N'Tax Form', @TaxFormMaintenanceParentMenuId, N'Tax Authorities', N'Maintenance', N'Screen', N'TaxForm.view.TaxAuthority?showSearch=true&searchCommand=TaxAuthority', N'small-menu-maintenance', 0, 0, 0, 1, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 0, strCommand = N'TaxForm.view.TaxAuthority?showSearch=true&searchCommand=TaxAuthority' WHERE strMenuName = 'Tax Authorities' AND strModuleName = 'Tax Form' AND intParentMenuID = @TaxFormMaintenanceParentMenuId

/* Start Delete */
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Integration' AND strModuleName = 'Tax Form' AND intParentMenuID = @TaxFormMaintenanceParentMenuId
/* End Delete */

/* PATRONAGE */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Patronage' AND strModuleName = 'Patronage' AND intParentMenuID = 0)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Patronage', N'Patronage', 0, N'Patronage', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 28, 0)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 28 WHERE strMenuName = 'Patronage' AND strModuleName = 'Patronage' AND intParentMenuID = 0

DECLARE @PatronageParentMenuId INT
SELECT @PatronageParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Patronage' AND strModuleName = 'Patronage' AND intParentMenuID = 0

UPDATE tblSMMasterMenu SET strCategory = N'Activity', strIcon = N'small-menu-activity' WHERE strModuleName = 'Patronage' AND strMenuName IN ('Process Dividends', 'Equity Details', 'Print Letter', 'Refund Rate', 'Process Refund', 'Stock Details', 'Volume Details')

/* CATEGORY FOLDERS */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Activities' AND strModuleName = 'Patronage' AND intParentMenuID = @PatronageParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Activities', N'Patronage', @PatronageParentMenuId, N'Activities', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 0 WHERE strMenuName = 'Activities' AND strModuleName = 'Patronage' AND intParentMenuID = @PatronageParentMenuId

DECLARE @PatronageActivitiesParentMenuId INT
SELECT @PatronageActivitiesParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Activities' AND strModuleName = 'Patronage' AND intParentMenuID = @PatronageParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'Patronage' AND intParentMenuID = @PatronageParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Maintenance', N'Patronage', @PatronageParentMenuId, N'Maintenance', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 1, 1)
ELSE
	UPDATE tblSMMasterMenu SET  strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 1 WHERE strMenuName = 'Maintenance' AND strModuleName = 'Patronage' AND intParentMenuID = @PatronageParentMenuId

DECLARE @PatronageMaintenanceParentMenuId INT
SELECT @PatronageMaintenanceParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'Patronage' AND intParentMenuID = @PatronageParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Reports' AND strModuleName = 'Patronage' AND intParentMenuID = @PatronageParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Reports', N'Patronage', @PatronageParentMenuId, N'Reports', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 2, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 2 WHERE strMenuName = 'Reports' AND strModuleName = 'Patronage' AND intParentMenuID = @PatronageParentMenuId

DECLARE @PatronageReportParentMenuId INT
SELECT @PatronageReportParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Reports' AND strModuleName = 'Patronage' AND intParentMenuID = @PatronageParentMenuId

/* ADD TO RESPECTIVE CATEGORY */ 
UPDATE tblSMMasterMenu SET intParentMenuID = @PatronageActivitiesParentMenuId WHERE intParentMenuID IN  (@PatronageParentMenuId, @PatronageMaintenanceParentMenuId) AND strCategory = 'Activity'
UPDATE tblSMMasterMenu SET intParentMenuID = @PatronageMaintenanceParentMenuId WHERE intParentMenuID =  @PatronageParentMenuId AND strCategory = 'Maintenance'

/* START OF RENAMING OF MENUS  */
UPDATE tblSMMasterMenu SET strMenuName = 'Process Refund', strDescription = 'Process Refund' WHERE strMenuName = 'Refund Calculation Worksheet' AND strModuleName = 'Patronage' AND intParentMenuID = @PatronageActivitiesParentMenuId
UPDATE tblSMMasterMenu SET strMenuName = 'Refunds', strDescription = 'Refunds' WHERE strMenuName = 'Process Refund' AND strModuleName = 'Patronage' AND intParentMenuID = @PatronageActivitiesParentMenuId
UPDATE tblSMMasterMenu SET strMenuName = 'Dividends', strDescription = 'Dividends' WHERE strMenuName = 'Process Dividends' AND strModuleName = 'Patronage' AND intParentMenuID = @PatronageActivitiesParentMenuId
UPDATE tblSMMasterMenu SET strMenuName = 'Volume', strDescription = 'Volume' WHERE strMenuName = 'Volume Details' AND strModuleName = 'Patronage' AND intParentMenuID = @PatronageActivitiesParentMenuId
UPDATE tblSMMasterMenu SET strMenuName = 'Equity', strDescription = 'Equity' WHERE strMenuName = 'Equity Details' AND strModuleName = 'Patronage' AND intParentMenuID = @PatronageActivitiesParentMenuId
UPDATE tblSMMasterMenu SET strMenuName = 'Stock', strDescription = 'Stock' WHERE strMenuName = 'Stock Details' AND strModuleName = 'Patronage' AND intParentMenuID = @PatronageActivitiesParentMenuId
UPDATE tblSMMasterMenu SET strMenuName = 'Mailer', strDescription = 'Mailer' WHERE strMenuName = 'Print Letter' AND strModuleName = 'Patronage' AND intParentMenuID = @PatronageActivitiesParentMenuId
/* END OF RENAMING OF MENUS */

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Volume' AND strModuleName = 'Patronage' AND intParentMenuID = @PatronageActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Volume', N'Patronage', @PatronageActivitiesParentMenuId, N'Volume', N'Activity', N'Screen', N'Patronage.view.VolumeDetail', N'small-menu-activity', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 0, strCommand = N'Patronage.view.VolumeDetail' WHERE strMenuName = 'Volume' AND strModuleName = 'Patronage' AND intParentMenuID = @PatronageActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Refunds' AND strModuleName = 'Patronage' AND intParentMenuID = @PatronageActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Refunds', N'Patronage', @PatronageActivitiesParentMenuId, N'Refunds', N'Activity', N'Screen', N'Patronage.view.RefundCalculationWorksheet?showSearch=true', N'small-menu-activity', 0, 0, 0, 1, 1, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 1, strCommand = N'Patronage.view.RefundCalculationWorksheet?showSearch=true' WHERE strMenuName = 'Refunds' AND strModuleName = 'Patronage' AND intParentMenuID = @PatronageActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Equity' AND strModuleName = 'Patronage' AND intParentMenuID = @PatronageActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Equity', N'Patronage', @PatronageActivitiesParentMenuId, N'Equity', N'Activity', N'Screen', N'Patronage.view.EquityDetail', N'small-menu-activity', 0, 0, 0, 1, 2, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 2, strCommand = N'Patronage.view.EquityDetail' WHERE strMenuName = 'Equity' AND strModuleName = 'Patronage' AND intParentMenuID = @PatronageActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Stock' AND strModuleName = 'Patronage' AND intParentMenuID = @PatronageActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Stock', N'Patronage', @PatronageActivitiesParentMenuId, N'Stock', N'Activity', N'Screen', N'Patronage.view.CustomerStock?showSearch=true', N'small-menu-activity', 0, 0, 0, 1, 3, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 3, strCommand = N'Patronage.view.CustomerStock?showSearch=true' WHERE strMenuName = 'Stock' AND strModuleName = 'Patronage' AND intParentMenuID = @PatronageActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Dividends' AND strModuleName = 'Patronage' AND intParentMenuID = @PatronageActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Dividends', N'Patronage', @PatronageActivitiesParentMenuId, N'Dividends', N'Activity', N'Screen', N'Patronage.view.ProcessDividend?showSearch=true', N'small-menu-activity', 0, 0, 0, 1, 4, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 4, strCommand = N'Patronage.view.ProcessDividend?showSearch=true' WHERE strMenuName = 'Dividends' AND strModuleName = 'Patronage' AND intParentMenuID = @PatronageActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Mailer' AND strModuleName = 'Patronage' AND intParentMenuID = @PatronageActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId])
	VALUES (N'Mailer', N'Patronage', @PatronageActivitiesParentMenuId, N'Mailer', N'Activity', N'Screen', N'Patronage.view.PrintLetter', N'small-menu-activity', 0, 0, 0, 1, 5, 1)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 5, strCommand = N'Patronage.view.PrintLetter' WHERE strMenuName = 'Mailer' AND strModuleName = 'Patronage' AND intParentMenuID = @PatronageActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Setup' AND strModuleName = 'Patronage' AND intParentMenuID = @PatronageMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId])
	VALUES (N'Setup', N'Patronage', @PatronageMaintenanceParentMenuId, N'Setup', N'Maintenance', N'Screen', N'Patronage.view.Setup', N'small-menu-maintenance', 0, 0, 0, 1, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 0, strCommand = N'Patronage.view.Setup' WHERE strMenuName = 'Setup' AND strModuleName = 'Patronage' AND intParentMenuID = @PatronageMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Customer History' AND strModuleName = 'Patronage' AND intParentMenuID = @PatronageReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId])
	VALUES (N'Customer History', N'Patronage', @PatronageReportParentMenuId, N'Customer History', N'Report', N'Screen', N'Patronage.view.CustomerHistory', N'small-menu-report', 0, 0, 0, 1, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 0, strCommand = N'Patronage.view.CustomerHistory' WHERE strMenuName = 'Customer History' AND strModuleName = 'Patronage' AND intParentMenuID = @PatronageReportParentMenuId

DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Patronage Category' AND strModuleName = 'Patronage' AND intParentMenuID = @PatronageMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Stock Classification' AND strModuleName = 'Patronage' AND intParentMenuID = @PatronageMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Issue Stock' AND strModuleName = 'Patronage' AND intParentMenuID = @PatronageMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Estate/Corporation' AND strModuleName = 'Patronage' AND intParentMenuID = @PatronageMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu  WHERE strMenuName = 'Refund Rate' AND strModuleName = 'Patronage' AND intParentMenuID = @PatronageActivitiesParentMenuId

/* ENERGY TRAC */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Energy Trac' AND strModuleName = 'Energy Trac' AND intParentMenuID = 0)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Energy Trac', N'Energy Trac', 0, N'Energy Trac', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 29, 0)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 29 WHERE strMenuName = 'Energy Trac' AND strModuleName = 'Energy Trac' AND intParentMenuID = 0

DECLARE @EnergyTracParentMenuId INT
SELECT @EnergyTracParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Energy Trac' AND strModuleName = 'Energy Trac' AND intParentMenuID = 0

/* CATEGORY FOLDERS */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Activities' AND strModuleName = 'Energy Trac' AND intParentMenuID = @EnergyTracParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Activities', N'Energy Trac', @EnergyTracParentMenuId, N'Activities', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 0 WHERE strMenuName = 'Activities' AND strModuleName = 'Energy Trac' AND intParentMenuID = @EnergyTracParentMenuId

DECLARE @EnergyTracActivitiesParentMenuId INT
SELECT @EnergyTracActivitiesParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Activities' AND strModuleName = 'Energy Trac' AND intParentMenuID = @EnergyTracParentMenuId

/* ADD TO RESPECTIVE CATEGORY */ 
UPDATE tblSMMasterMenu SET intParentMenuID = @EnergyTracActivitiesParentMenuId WHERE intParentMenuID =  @EnergyTracParentMenuId AND strCategory = 'Activity'

/* START OF RENAMING  */
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Export Filter' AND strModuleName = 'Energy Trac' AND intParentMenuID = @EnergyTracActivitiesParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = N'Export Setup' WHERE strMenuName = 'Export Filter' AND strModuleName = 'Energy Trac' AND intParentMenuID = @EnergyTracActivitiesParentMenuId
/* END OF RENAMING  */

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Export Xml' AND strModuleName = 'Energy Trac' AND intParentMenuID = @EnergyTracActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Export Xml', N'Energy Trac', @EnergyTracActivitiesParentMenuId, N'Export Xml', N'Activity', N'Screen', N'EnergyTrac.view.ExportAll', N'small-menu-activity', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'EnergyTrac.view.ExportAll' WHERE strMenuName = 'Export Xml' AND strModuleName = 'Energy Trac' AND intParentMenuID = @EnergyTracActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Export Setup' AND strModuleName = 'Energy Trac' AND intParentMenuID = @EnergyTracActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Export Setup', N'Energy Trac', @EnergyTracActivitiesParentMenuId, N'Export Setup', N'Activity', N'Screen', N'EnergyTrac.view.ExportFilter', N'small-menu-activity', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'EnergyTrac.view.ExportFilter' WHERE strMenuName = 'Export Setup' AND strModuleName = 'Energy Trac' AND intParentMenuID = @EnergyTracActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Import' AND strModuleName = 'Energy Trac' AND intParentMenuID = @EnergyTracActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Import', N'Energy Trac', @EnergyTracActivitiesParentMenuId, N'Import', N'Activity', N'Screen', N'EnergyTrac.view.Import', N'small-menu-activity', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'EnergyTrac.view.Import' WHERE strMenuName = 'Import' AND strModuleName = 'Energy Trac' AND intParentMenuID = @EnergyTracActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Delivery Metrics' AND strModuleName = 'Energy Trac' AND intParentMenuID = @EnergyTracActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Delivery Metrics', N'Energy Trac', @EnergyTracActivitiesParentMenuId, N'Delivery Metrics', N'Activity', N'Screen', N'EnergyTrac.view.DeliveryMetrics?showSearch=true', N'small-menu-activity', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'EnergyTrac.view.DeliveryMetrics?showSearch=true' WHERE strMenuName = 'Delivery Metrics' AND strModuleName = 'Energy Trac' AND intParentMenuID = @EnergyTracActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Fleet Tracking' AND strModuleName = 'Energy Trac' AND intParentMenuID = @EnergyTracActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId])
	VALUES (N'Fleet Tracking', N'Energy Trac', @EnergyTracActivitiesParentMenuId, N'Fleet Tracking', N'Activity', N'Screen', N'EnergyTrac.view.FleetTracking', N'small-menu-activity', 0, 0, 0, 1, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = N'EnergyTrac.view.FleetTracking' WHERE strMenuName = 'Fleet Tracking' AND strModuleName = 'Energy Trac' AND intParentMenuID = @EnergyTracActivitiesParentMenuId

/* INTEGRATION */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Integration' AND strModuleName = 'Integration' AND intParentMenuID = 0)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Integration', N'Integration', 0, N'Integration', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 30, 0)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 30 WHERE strMenuName = 'Integration' AND strModuleName = 'Integration' AND intParentMenuID = 0

DECLARE @IntegrationParentMenuId INT
SELECT @IntegrationParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Integration' AND strModuleName = 'Integration' AND intParentMenuID = 0

/* CATEGORY FOLDERS */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Activities' AND strModuleName = 'Integration' AND intParentMenuID = @IntegrationParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intRow], [intConcurrencyId]) 
	VALUES (N'Activities', N'Integration', @IntegrationParentMenuId, N'Activities', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 0, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 0 WHERE strMenuName = 'Activities' AND strModuleName = 'Integration' AND intParentMenuID = @IntegrationParentMenuId

DECLARE @IntegrationActivitiesParentMenuId INT
SELECT @IntegrationActivitiesParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Activities' AND strModuleName = 'Integration' AND intParentMenuID = @IntegrationParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'Integration' AND intParentMenuID = @IntegrationParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intRow], [intConcurrencyId]) 
	VALUES (N'Maintenance', N'Integration', @IntegrationParentMenuId, N'Maintenance', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 1, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 1 WHERE strMenuName = 'Maintenance' AND strModuleName = 'Integration' AND intParentMenuID = @IntegrationParentMenuId

DECLARE @IntegrationMaintenanceParentMenuId INT
SELECT @IntegrationMaintenanceParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'Integration' AND intParentMenuID = @IntegrationParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Create' AND strModuleName = 'Integration' AND intParentMenuID = @IntegrationParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intRow], [intConcurrencyId])
	VALUES (N'Create', N'Integration', @IntegrationParentMenuId, N'Create', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 0, 1, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 0, intRow = 1 WHERE strMenuName = 'Create' AND strModuleName = 'Integration' AND intParentMenuID = @IntegrationParentMenuId

DECLARE @IntegrationCreateParentMenuId INT
SELECT @IntegrationCreateParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Create' AND strModuleName = 'Integration' AND intParentMenuID = @IntegrationParentMenuId

/* ADD TO RESPECTIVE CATEGORY */ 
UPDATE tblSMMasterMenu SET intParentMenuID = @IntegrationActivitiesParentMenuId WHERE intParentMenuID =  @IntegrationParentMenuId AND strCategory = 'Activity'
UPDATE tblSMMasterMenu SET intParentMenuID = @IntegrationMaintenanceParentMenuId WHERE intParentMenuID =  @IntegrationParentMenuId AND strCategory = 'Maintenance'
UPDATE tblSMMasterMenu SET intParentMenuID = @IntegrationCreateParentMenuId WHERE intParentMenuID =  @IntegrationParentMenuId AND strCategory = 'Create'

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Processes' AND strModuleName = 'Integration' AND intParentMenuID = @IntegrationActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Processes', N'Integration', @IntegrationActivitiesParentMenuId, N'Processes', N'Activity', N'Screen', N'Integration.view.ProcessSetup?showSearch=true', N'small-menu-activity', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 0, strCommand = N'Integration.view.ProcessSetup?showSearch=true' WHERE strMenuName = 'Processes' AND strModuleName = 'Integration' AND intParentMenuID = @IntegrationActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Connections' AND strModuleName = 'Integration' AND intParentMenuID = @IntegrationMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Connections', N'Integration', @IntegrationMaintenanceParentMenuId, N'Connections', N'Maintenance', N'Screen', N'Integration.view.Connection?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 0, strCommand = N'Integration.view.Connection?showSearch=true' WHERE strMenuName = 'Connections' AND strModuleName = 'Integration' AND intParentMenuID = @IntegrationMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'New Process' AND strModuleName = 'Integration' AND intParentMenuID = @IntegrationCreateParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'New Process', N'Integration', @IntegrationCreateParentMenuId, N'New Process', N'Activity', N'Screen', N'Integration.view.ProcessSetup?action=new', N'small-menu-activity', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 0, strCommand = N'Integration.view.ProcessSetup?action=new' WHERE strMenuName = 'New Process' AND strModuleName = 'Integration' AND intParentMenuID = @IntegrationCreateParentMenuId

/* FIXED ASSETS */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Fixed Assets' AND strModuleName = 'Fixed Assets' AND intParentMenuID = 0)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Fixed Assets', N'Fixed Assets', 0, N'Fixed Assets', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 31, 0)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 31 WHERE strMenuName = 'Fixed Assets' AND strModuleName = 'Fixed Assets' AND intParentMenuID = 0

DECLARE @FixedAssetsParentMenuId INT
SELECT @FixedAssetsParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Fixed Assets' AND strModuleName = 'Fixed Assets' AND intParentMenuID = 0

/* CATEGORY FOLDERS */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Activities' AND strModuleName = 'Fixed Assets' AND intParentMenuID = @FixedAssetsParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Activities', N'Fixed Assets', @FixedAssetsParentMenuId, N'Activities', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 0 WHERE strMenuName = 'Activities' AND strModuleName = 'Fixed Assets' AND intParentMenuID = @FixedAssetsParentMenuId

DECLARE @FixedAssetsActivitiesParentMenuId INT
SELECT @FixedAssetsActivitiesParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Activities' AND strModuleName = 'Fixed Assets' AND intParentMenuID = @FixedAssetsParentMenuId

/* ADD TO RESPECTIVE CATEGORY */ 
UPDATE tblSMMasterMenu SET intParentMenuID = @FixedAssetsActivitiesParentMenuId WHERE intParentMenuID =  @FixedAssetsParentMenuId AND strCategory = 'Activity'

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Fixed Assets' AND strModuleName = 'Fixed Assets' AND intParentMenuID = @FixedAssetsActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Fixed Assets', N'Fixed Assets', @FixedAssetsActivitiesParentMenuId, N'Fixed Assets', N'Activity', N'Screen', N'FixedAssets.view.FixedAssets?showSearch=true', N'small-menu-activity', 1, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'FixedAssets.view.FixedAssets?showSearch=true' WHERE strMenuName = 'Fixed Assets' AND strModuleName = 'Fixed Assets' AND intParentMenuID = @FixedAssetsActivitiesParentMenuId
	
/* VENDOR REBATES */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Vendor Rebates' AND strModuleName = 'Vendor Rebates' AND intParentMenuID = 0)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Vendor Rebates', N'Vendor Rebates', 0, N'Vendor Rebates', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 32, 0)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 32 WHERE strMenuName = 'Vendor Rebates' AND strModuleName = 'Vendor Rebates' AND intParentMenuID = 0

DECLARE @VendorRebatesParentMenuId INT
SELECT @VendorRebatesParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Vendor Rebates' AND strModuleName = 'Vendor Rebates' AND intParentMenuID = 0

/* CATEGORY FOLDERS */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Activities' AND strModuleName = 'Vendor Rebates' AND intParentMenuID = @VendorRebatesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Activities', N'Vendor Rebates', @VendorRebatesParentMenuId, N'Activities', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 0 WHERE strMenuName = 'Activities' AND strModuleName = 'Vendor Rebates' AND intParentMenuID = @VendorRebatesParentMenuId

DECLARE @VendorRebatesActivitiesParentMenuId INT
SELECT @VendorRebatesActivitiesParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Activities' AND strModuleName = 'Vendor Rebates' AND intParentMenuID = @VendorRebatesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'Vendor Rebates' AND intParentMenuID = @VendorRebatesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Maintenance', N'Vendor Rebates', @VendorRebatesParentMenuId, N'Maintenance', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 1, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 1 WHERE strMenuName = 'Maintenance' AND strModuleName = 'Vendor Rebates' AND intParentMenuID = @VendorRebatesParentMenuId

DECLARE @VendorRebatesMaintenanceParentMenuId INT
SELECT @VendorRebatesMaintenanceParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'Vendor Rebates' AND intParentMenuID = @VendorRebatesParentMenuId

/* ADD TO RESPECTIVE CATEGORY */ 
UPDATE tblSMMasterMenu SET intParentMenuID = @VendorRebatesActivitiesParentMenuId WHERE intParentMenuID =  @VendorRebatesParentMenuId AND strCategory = 'Activity'
UPDATE tblSMMasterMenu SET intParentMenuID = @VendorRebatesMaintenanceParentMenuId WHERE intParentMenuID =  @VendorRebatesParentMenuId AND strCategory = 'Maintenance'

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Rebates' AND strModuleName = 'Vendor Rebates' AND intParentMenuID = @VendorRebatesActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Rebates', N'Vendor Rebates', @VendorRebatesActivitiesParentMenuId, N'Rebates', N'Activity', N'Screen', N'VendorRebates.view.Rebates?showSearch=true', N'small-menu-activity', 1, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'VendorRebates.view.Rebates?showSearch=true' WHERE strMenuName = 'Rebates' AND strModuleName = 'Vendor Rebates' AND intParentMenuID = @VendorRebatesActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Setup' AND strModuleName = 'Vendor Rebates' AND intParentMenuID = @VendorRebatesMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Setup', N'Vendor Rebates', @VendorRebatesMaintenanceParentMenuId, N'Setup', N'Maintenance', N'Screen', N'VendorRebates.view.RebateSetup?showSearch=true', N'small-menu-maintenance', 1, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'VendorRebates.view.RebateSetup?showSearch=true' WHERE strMenuName = 'Setup' AND strModuleName = 'Vendor Rebates' AND intParentMenuID = @VendorRebatesMaintenanceParentMenuId

/* BUYBACKS */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Buybacks' AND strModuleName = 'Buybacks' AND intParentMenuID = 0)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Buybacks', N'Buybacks', 0, N'Buybacks', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 33, 0)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 33 WHERE strMenuName = 'Buybacks' AND strModuleName = 'Buybacks' AND intParentMenuID = 0

DECLARE @BuybacksParentMenuId INT
SELECT @BuybacksParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Buybacks' AND strModuleName = 'Buybacks' AND intParentMenuID = 0

/* CATEGORY FOLDERS */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Activities' AND strModuleName = 'Buybacks' AND intParentMenuID = @BuybacksParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Activities', N'Buybacks', @BuybacksParentMenuId, N'Activities', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 0 WHERE strMenuName = 'Activities' AND strModuleName = 'Buybacks' AND intParentMenuID = @BuybacksParentMenuId

DECLARE @BuybacksActivitiesParentMenuId INT
SELECT @BuybacksActivitiesParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Activities' AND strModuleName = 'Buybacks' AND intParentMenuID = @BuybacksParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'Buybacks' AND intParentMenuID = @BuybacksParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Maintenance', N'Buybacks', @BuybacksParentMenuId, N'Maintenance', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 1, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 1 WHERE strMenuName = 'Maintenance' AND strModuleName = 'Buybacks' AND intParentMenuID = @BuybacksParentMenuId

DECLARE @BuybacksMaintenanceParentMenuId INT
SELECT @BuybacksMaintenanceParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'Buybacks' AND intParentMenuID = @BuybacksParentMenuId

/* ADD TO RESPECTIVE CATEGORY */ 
UPDATE tblSMMasterMenu SET intParentMenuID = @BuybacksActivitiesParentMenuId WHERE intParentMenuID =  @BuybacksParentMenuId AND strCategory = 'Activity'
UPDATE tblSMMasterMenu SET intParentMenuID = @BuybacksMaintenanceParentMenuId WHERE intParentMenuID =  @BuybacksParentMenuId AND strCategory = 'Maintenance'

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Buybacks' AND strModuleName = 'Buybacks' AND intParentMenuID = @BuybacksActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Buybacks', N'Buybacks', @BuybacksActivitiesParentMenuId, N'Buybacks', N'Activity', N'Screen', N'Buybacks.view.Buybacks?showSearch=true', N'small-menu-activity', 1, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Buybacks.view.Buybacks?showSearch=true' WHERE strMenuName = 'Buybacks' AND strModuleName = 'Buybacks' AND intParentMenuID = @BuybacksActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Setup' AND strModuleName = 'Buybacks' AND intParentMenuID = @BuybacksMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Setup', N'Buybacks', @BuybacksMaintenanceParentMenuId, N'Setup', N'Maintenance', N'Screen', N'Buybacks.view.BuybackSetup?showSearch=true', N'small-menu-maintenance', 1, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Buybacks.view.BuybackSetup?showSearch=true' WHERE strMenuName = 'Setup' AND strModuleName = 'Buybacks' AND intParentMenuID = @BuybacksMaintenanceParentMenuId

/* MOBILE BILLING */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Mobile Billing' AND strModuleName = 'Mobile Billing' AND intParentMenuID = 0)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Mobile Billing', N'Mobile Billing', 0, N'Mobile Billing', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 34, 0)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 34 WHERE strMenuName = 'Mobile Billing' AND strModuleName = 'Mobile Billing' AND intParentMenuID = 0

DECLARE @MobileBillingParentMenuId INT
SELECT @MobileBillingParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Mobile Billing' AND strModuleName = 'Mobile Billing' AND intParentMenuID = 0

/* CATEGORY FOLDERS */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Activities' AND strModuleName = 'Mobile Billing' AND intParentMenuID = @MobileBillingParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Activities', N'Mobile Billing', @MobileBillingParentMenuId, N'Activities', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 1, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 1 WHERE strMenuName = 'Activities' AND strModuleName = 'Mobile Billing' AND intParentMenuID = @MobileBillingParentMenuId

DECLARE @MobileBillingActivitiesParentMenuId INT
SELECT @MobileBillingActivitiesParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Activities' AND strModuleName = 'Mobile Billing' AND intParentMenuID = @MobileBillingParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'Mobile Billing' AND intParentMenuID = @MobileBillingParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Maintenance', N'Mobile Billing', @MobileBillingParentMenuId, N'Maintenance', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 2, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 2 WHERE strMenuName = 'Maintenance' AND strModuleName = 'Mobile Billing' AND intParentMenuID = @MobileBillingParentMenuId

DECLARE @MobileBillingMaintenanceParentMenuId INT
SELECT @MobileBillingMaintenanceParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'Mobile Billing' AND intParentMenuID = @MobileBillingParentMenuId

/* ADD TO RESPECTIVE CATEGORY */ 
UPDATE tblSMMasterMenu SET intParentMenuID = @MobileBillingActivitiesParentMenuId WHERE intParentMenuID =  @MobileBillingParentMenuId AND strCategory = 'Activity'
UPDATE tblSMMasterMenu SET intParentMenuID = @MobileBillingMaintenanceParentMenuId WHERE intParentMenuID =  @MobileBillingParentMenuId AND strCategory = 'Maintenance'

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Shifts' AND strModuleName = 'Mobile Billing' AND intParentMenuID = @MobileBillingActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Shifts', N'Mobile Billing', @MobileBillingActivitiesParentMenuId, N'Shifts', N'Activity', N'Screen', N'MobileBilling.view.Shift?showSearch=true', N'small-menu-activity', 1, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 0, strCommand = N'MobileBilling.view.Shift?showSearch=true' WHERE strMenuName = 'Shifts' AND strModuleName = 'Mobile Billing' AND intParentMenuID = @MobileBillingActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Invoices' AND strModuleName = 'Mobile Billing' AND intParentMenuID = @MobileBillingActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Invoices', N'Mobile Billing', @MobileBillingActivitiesParentMenuId, N'Invoices', N'Activity', N'Screen', N'MobileBilling.view.Invoice?showSearch=true', N'small-menu-activity', 1, 0, 0, 1, 1, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 1, strCommand = N'MobileBilling.view.Invoice?showSearch=true' WHERE strMenuName = 'Invoices' AND strModuleName = 'Mobile Billing' AND intParentMenuID = @MobileBillingActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Payments' AND strModuleName = 'Mobile Billing' AND intParentMenuID = @MobileBillingActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Payments', N'Mobile Billing', @MobileBillingActivitiesParentMenuId, N'Payments', N'Activity', N'Screen', N'MobileBilling.view.Payment?showSearch=true', N'small-menu-activity', 1, 0, 0, 1, 2, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 2, strCommand = N'MobileBilling.view.Payment?showSearch=true' WHERE strMenuName = 'Payments' AND strModuleName = 'Mobile Billing' AND intParentMenuID = @MobileBillingActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Trucks' AND strModuleName = 'Mobile Billing' AND intParentMenuID = @MobileBillingMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Trucks', N'Mobile Billing', @MobileBillingMaintenanceParentMenuId, N'Trucks', N'Maintenance', N'Screen', N'i21.view.Truck?showSearch=true', N'small-menu-activity', 1, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 0, strCommand = N'i21.view.Truck?showSearch=true' WHERE strMenuName = 'Trucks' AND strModuleName = 'Mobile Billing' AND intParentMenuID = @MobileBillingMaintenanceParentMenuId
----------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------ CONTACT MENUS -------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------- ALL CONTACT MENUS ONLY MUST BE DELETED IN uspSMFixUserRoleMenus ----------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------
/* Account */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Account (Portal)' AND strModuleName = 'System Manager' AND intParentMenuID = 0)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intRow], [intConcurrencyId]) 
	VALUES (N'Account (Portal)', N'System Manager', 0, N'Account (Portal)', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 0, 0, 0)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 0, intRow = 0 WHERE strMenuName = 'Account (Portal)' AND strModuleName = 'System Manager' AND intParentMenuID = 0

DECLARE @AccountPortalParentMenuId INT
SELECT @AccountPortalParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Account (Portal)' AND strModuleName = 'System Manager' AND intParentMenuID = 0

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @AccountPortalParentMenuId)
INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId], [ysnContactOnly]) VALUES (@AccountPortalParentMenuId, 1)

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'My Account (Portal)' AND strModuleName = 'System Manager' AND intParentMenuID = @AccountPortalParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'My Account (Portal)', N'System Manager', @AccountPortalParentMenuId, N'My Account (Portal)', N'Account', N'Screen', N'EntityManagement.view.UserProfile', N'small-menu-account', 1, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 0, strCommand = N'EntityManagement.view.UserProfile' WHERE strMenuName = 'My Account (Portal)' AND strModuleName = 'System Manager' AND intParentMenuID = @AccountPortalParentMenuId

DECLARE @EMMyAccountMenuId INT
SELECT  @EMMyAccountMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = N'My Account (Portal)' AND strModuleName = N'System Manager' AND intParentMenuID = @AccountPortalParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'My Account (Portal)' AND strModuleName = N'System Manager' AND intParentMenuID = @AccountPortalParentMenuId)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @EMMyAccountMenuId)
	INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId], [ysnContactOnly]) VALUES (@EMMyAccountMenuId, 1)
END

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'My Company (Portal)' AND strModuleName = 'System Manager' AND intParentMenuID = @AccountPortalParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'My Company (Portal)', N'System Manager', @AccountPortalParentMenuId, N'My Company (Portal)', N'Account', N'Screen', N'AccountsReceivable.view.EntityCustomer', N'small-menu-account', 1, 0, 0, 1, 1, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 1, strCommand = N'AccountsReceivable.view.EntityCustomer' WHERE strMenuName = 'My Company (Portal)' AND strModuleName = 'System Manager' AND intParentMenuID = @AccountPortalParentMenuId

DECLARE @ARMyCompanyMenuId INT
SELECT  @ARMyCompanyMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = N'My Company (Portal)' AND strModuleName = N'System Manager' AND intParentMenuID = @AccountPortalParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'My Company (Portal)' AND strModuleName = N'System Manager' AND intParentMenuID = @AccountPortalParentMenuId)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @ARMyCompanyMenuId)
	INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId], [ysnContactOnly]) VALUES (@ARMyCompanyMenuId, 1)
END

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'User List (Portal)' AND strDescription = 'User List' AND strModuleName = 'System Manager' AND intParentMenuID = @AccountPortalParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'User List (Portal)', N'System Manager', @AccountPortalParentMenuId, N'User List', N'Account', N'Screen', N'EntityManagement.controller.UserList', N'small-menu-account', 1, 0, 0, 1, 2, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 2, strCommand = N'EntityManagement.controller.UserList' WHERE strMenuName = 'User List (Portal)' AND strDescription = 'User List' AND strModuleName = 'System Manager' AND intParentMenuID = @AccountPortalParentMenuId

DECLARE @SMSalesUserListMenuId INT
SELECT  @SMSalesUserListMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'User List (Portal)' AND strDescription = 'User List' AND strModuleName = 'System Manager' AND intParentMenuID = @AccountPortalParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'User List (Portal)' AND strDescription = 'User List' AND strModuleName = 'System Manager' AND intParentMenuID = @AccountPortalParentMenuId)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @SMSalesUserListMenuId)
	INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId], [ysnContactOnly]) VALUES (@SMSalesUserListMenuId, 1)
END

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Set Permissions (Portal)' AND strModuleName = 'System Manager' AND intParentMenuID = @AccountPortalParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Set Permissions (Portal)', N'System Manager', @AccountPortalParentMenuId, N'Set Permissions (Portal)', N'Account', N'Screen', N'i21.view.PortalRole?showSearch=true', N'small-menu-account', 1, 0, 0, 1, 3, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 3, strCommand = N'i21.view.PortalRole?showSearch=true' WHERE strMenuName = 'Set Permissions (Portal)' AND strModuleName = 'System Manager' AND intParentMenuID = @AccountPortalParentMenuId

DECLARE @SMSetPermissionsMenuId INT
SELECT  @SMSetPermissionsMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = N'Set Permissions (Portal)' AND strModuleName = N'System Manager' AND intParentMenuID = @AccountPortalParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Set Permissions (Portal)' AND strModuleName = N'System Manager' AND intParentMenuID = @AccountPortalParentMenuId)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @SMSetPermissionsMenuId)
	INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId], [ysnContactOnly]) VALUES (@SMSetPermissionsMenuId, 1)
END

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Payment Methods (Portal)' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountPortalParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Payment Methods (Portal)', N'Accounts Receivable', @AccountPortalParentMenuId, N'Payment Methods (Portal)', N'Account', N'Screen', N'GlobalComponentEngine.view.PaymentMethods', N'small-menu-account', 1, 0, 0, 1, 4, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 4, strCommand = N'GlobalComponentEngine.view.PaymentMethods' WHERE strMenuName = 'Payment Methods (Portal)' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountPortalParentMenuId

DECLARE @ARPaymentMethodsMenuId INT
SELECT  @ARPaymentMethodsMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = N'Payment Methods (Portal)' AND strModuleName = N'Accounts Receivable' AND intParentMenuID = @AccountPortalParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Payment Methods (Portal)' AND strModuleName = N'Accounts Receivable' AND intParentMenuID = @AccountPortalParentMenuId)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @ARPaymentMethodsMenuId)
	INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId], [ysnContactOnly]) VALUES (@ARPaymentMethodsMenuId, 1)
END

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Change Password (Portal)' AND strModuleName = 'System Manager' AND intParentMenuID = @AccountPortalParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Change Password (Portal)', N'System Manager', @AccountPortalParentMenuId, N'Change Password (Portal)', N'Account', N'Screen', N'EntityManagement.view.ChangePassword', N'small-menu-account', 1, 0, 0, 1, 5, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 5, strCommand = N'EntityManagement.view.ChangePassword' WHERE strMenuName = 'Change Password (Portal)' AND strModuleName = 'System Manager' AND intParentMenuID = @AccountPortalParentMenuId

DECLARE @EMChangePasswordMenuId INT
SELECT  @EMChangePasswordMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = N'Change Password (Portal)' AND strModuleName = N'System Manager' AND intParentMenuID = @AccountPortalParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Change Password (Portal)' AND strModuleName = N'System Manager' AND intParentMenuID = @AccountPortalParentMenuId)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @EMChangePasswordMenuId)
	INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId], [ysnContactOnly]) VALUES (@EMChangePasswordMenuId, 1)
END

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Balance Inquiry (Portal)' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountPortalParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Balance Inquiry (Portal)', N'Accounts Receivable', @AccountPortalParentMenuId, N'Balance Inquiry (Portal)', N'Account', N'Screen', N'AccountsReceivable.view.CustomerInquiry', N'small-menu-account', 1, 0, 0, 1, 6, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 6, strCommand = N'AccountsReceivable.view.CustomerInquiry' WHERE strMenuName = 'Balance Inquiry (Portal)' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountPortalParentMenuId

DECLARE @EMBalanceInquiryMenuId INT
SELECT  @EMBalanceInquiryMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = N'Balance Inquiry (Portal)' AND strModuleName = N'Accounts Receivable' AND intParentMenuID = @AccountPortalParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Balance Inquiry (Portal)' AND strModuleName = N'Accounts Receivable' AND intParentMenuID = @AccountPortalParentMenuId)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @EMBalanceInquiryMenuId)
	INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId], [ysnContactOnly]) VALUES (@EMBalanceInquiryMenuId, 1)
END

/* Transactions */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Transactions (Portal)' AND strModuleName = 'System Manager' AND intParentMenuID = 0)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intRow], [intConcurrencyId]) 
	VALUES (N'Transactions (Portal)', N'System Manager', 0, N'Transactions (Portal)', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 1, 0, 0)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 1, intRow = 0 WHERE strMenuName = 'Transactions (Portal)' AND strModuleName = 'System Manager' AND intParentMenuID = 0

DECLARE @TransactionsPortalParentMenuId INT
SELECT @TransactionsPortalParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Transactions (Portal)' AND strModuleName = 'System Manager' AND intParentMenuID = 0

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @TransactionsPortalParentMenuId)
INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId], [ysnContactOnly]) VALUES (@TransactionsPortalParentMenuId, 1)

UPDATE tblSMMasterMenu SET strMenuName = 'Purchase Orders (Portal)', strDescription = 'Purchase Orders (Portal)' WHERE strMenuName = 'Orders (Portal)' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @TransactionsPortalParentMenuId
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Purchase Orders (Portal)' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @TransactionsPortalParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Purchase Orders (Portal)', N'Accounts Payable', @TransactionsPortalParentMenuId, N'Purchase Orders (Portal)', N'Transaction', N'Screen', N'AccountsPayable.view.PurchaseOrder?showSearch=true', N'small-menu-transaction', 1, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 0, strCommand = N'AccountsPayable.view.PurchaseOrder?showSearch=true' WHERE strMenuName = 'Purchase Orders (Portal)' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @TransactionsPortalParentMenuId

DECLARE @APPurchaseOrdersMenuId INT
SELECT  @APPurchaseOrdersMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = N'Purchase Orders (Portal)' AND strModuleName = N'Accounts Payable' AND intParentMenuID = @TransactionsPortalParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Purchase Orders (Portal)' AND strModuleName = N'Accounts Payable' AND intParentMenuID = @TransactionsPortalParentMenuId)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @APPurchaseOrdersMenuId)
	INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId], [ysnContactOnly]) VALUES (@APPurchaseOrdersMenuId, 1)
END

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Sales Orders (Portal)' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @TransactionsPortalParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Sales Orders (Portal)', N'Accounts Receivable', @TransactionsPortalParentMenuId, N'Sales Orders (Portal)', N'Transaction', N'Screen', N'AccountsReceivable.view.SalesOrder?showSearch=true', N'small-menu-transaction', 1, 0, 0, 1, 1, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 1, strCommand = N'AccountsReceivable.view.SalesOrder?showSearch=true' WHERE strMenuName = 'Sales Orders (Portal)' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @TransactionsPortalParentMenuId

DECLARE @ARSalesOrdersMenuId INT
SELECT  @ARSalesOrdersMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = N'Sales Orders (Portal)' AND strModuleName = N'Accounts Receivable' AND intParentMenuID = @TransactionsPortalParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Sales Orders (Portal)' AND strModuleName = N'Accounts Receivable' AND intParentMenuID = @TransactionsPortalParentMenuId)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @ARSalesOrdersMenuId)
	INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId], [ysnContactOnly]) VALUES (@ARSalesOrdersMenuId, 1)
END

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Vouchers (Portal)' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @TransactionsPortalParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Vouchers (Portal)', N'Accounts Payable', @TransactionsPortalParentMenuId, N'Vouchers (Portal)', N'Transaction', N'Screen', N'AccountsPayable.view.Voucher?showSearch=true', N'small-menu-transaction', 1, 0, 0, 1, 2, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 2, strCommand = N'AccountsPayable.view.Voucher?showSearch=true' WHERE strMenuName = 'Vouchers (Portal)' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @TransactionsPortalParentMenuId

DECLARE @APVouchersMenuId INT
SELECT  @APVouchersMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = N'Vouchers (Portal)' AND strModuleName = N'Accounts Payable' AND intParentMenuID = @TransactionsPortalParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Vouchers (Portal)' AND strModuleName = N'Accounts Payable' AND intParentMenuID = @TransactionsPortalParentMenuId)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @APVouchersMenuId)
	INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId], [ysnContactOnly]) VALUES (@APVouchersMenuId, 1)
END

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Invoices (Portal)' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @TransactionsPortalParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Invoices (Portal)', N'Accounts Receivable', @TransactionsPortalParentMenuId, N'Invoices (Portal)', N'Transaction', N'Screen', N'AccountsReceivable.view.Invoice?showSearch=true', N'small-menu-transaction', 1, 0, 0, 1, 3, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 3, strCommand = N'AccountsReceivable.view.Invoice?showSearch=true' WHERE strMenuName = 'Invoices (Portal)' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @TransactionsPortalParentMenuId

DECLARE @ARInvoicesMenuId INT
SELECT  @ARInvoicesMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = N'Invoices (Portal)' AND strModuleName = N'Accounts Receivable' AND intParentMenuID = @TransactionsPortalParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Invoices (Portal)' AND strModuleName = N'Accounts Receivable' AND intParentMenuID = @TransactionsPortalParentMenuId)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @ARInvoicesMenuId)
	INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId], [ysnContactOnly]) VALUES (@ARInvoicesMenuId, 1)
END

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Make a Payment (Portal)' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @TransactionsPortalParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Make a Payment (Portal)', N'Accounts Receivable', @TransactionsPortalParentMenuId, N'Make a Payment (Portal)', N'Transaction', N'Screen', N'AccountsReceivable.view.MakePayments', N'small-menu-transaction', 1, 0, 0, 1, 4, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 4, strCommand = N'AccountsReceivable.view.MakePayments' WHERE strMenuName = 'Make a Payment (Portal)' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @TransactionsPortalParentMenuId

DECLARE @ARMakePaymentMenuId INT
SELECT  @ARMakePaymentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = N'Make a Payment (Portal)' AND strModuleName = N'Accounts Receivable' AND intParentMenuID = @TransactionsPortalParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Make a Payment (Portal)' AND strModuleName = N'Accounts Receivable' AND intParentMenuID = @TransactionsPortalParentMenuId)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @ARMakePaymentMenuId)
	INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId], [ysnContactOnly]) VALUES (@ARMakePaymentMenuId, 1)
END

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Payments (Portal)' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @TransactionsPortalParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Payments (Portal)', N'Accounts Receivable', @TransactionsPortalParentMenuId, N'Payments (Portal)', N'Transaction', N'Screen', N'AccountsReceivable.view.ReceivePaymentsDetail?showSearch=true', N'small-menu-transaction', 1, 0, 0, 1, 5, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 5, strCommand = N'AccountsReceivable.view.ReceivePaymentsDetail?showSearch=true' WHERE strMenuName = 'Payments (Portal)' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @TransactionsPortalParentMenuId

DECLARE @ARPaymentsMenuId INT
SELECT  @ARPaymentsMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = N'Payments (Portal)' AND strModuleName = N'Accounts Receivable' AND intParentMenuID = @TransactionsPortalParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Payments (Portal)' AND strModuleName = N'Accounts Receivable' AND intParentMenuID = @TransactionsPortalParentMenuId)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @ARPaymentsMenuId)
	INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId], [ysnContactOnly]) VALUES (@ARPaymentsMenuId, 1)
END

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Payment History (Portal)' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @TransactionsPortalParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Payment History (Portal)', N'Accounts Receivable', @TransactionsPortalParentMenuId, N'Payment History (Portal)', N'Transaction', N'Screen', N'Reporting.view.ReportManager?group=Sales&report=PaymentHistory&direct=true', N'small-menu-transaction', 1, 0, 0, 1, 6, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 6, strCommand = N'Reporting.view.ReportManager?group=Sales&report=PaymentHistory&direct=true' WHERE strMenuName = 'Payment History (Portal)' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @TransactionsPortalParentMenuId

DECLARE @ARPaymentHistoryMenuId INT
SELECT  @ARPaymentHistoryMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = N'Payment History (Portal)' AND strModuleName = N'Accounts Receivable' AND intParentMenuID = @TransactionsPortalParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Payment History (Portal)' AND strModuleName = N'Accounts Receivable' AND intParentMenuID = @TransactionsPortalParentMenuId)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @ARPaymentHistoryMenuId)
	INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId], [ysnContactOnly]) VALUES (@ARPaymentHistoryMenuId, 1)
END

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Contracts (Portal)' AND strModuleName = 'Contract Management' AND intParentMenuID = @TransactionsPortalParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Contracts (Portal)', N'Contract Management', @TransactionsPortalParentMenuId, N'Contracts (Portal)', N'Transaction', N'Screen', N'ContractManagement.view.Contract?showSearch=true', N'small-menu-transaction', 1, 0, 0, 1, 7, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 7, strCommand = N'ContractManagement.view.Contract?showSearch=true' WHERE strMenuName = 'Contracts (Portal)' AND strModuleName = 'Contract Management' AND intParentMenuID = @TransactionsPortalParentMenuId

DECLARE @CTContractsMenuId INT
SELECT  @CTContractsMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = N'Contracts (Portal)' AND strModuleName = N'Contract Management' AND intParentMenuID = @TransactionsPortalParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Contracts (Portal)' AND strModuleName = N'Contract Management' AND intParentMenuID = @TransactionsPortalParentMenuId)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @CTContractsMenuId)
	INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId], [ysnContactOnly]) VALUES (@CTContractsMenuId, 1)
END

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = '1099 (Portal)' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @TransactionsPortalParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'1099 (Portal)', N'Accounts Payable', @TransactionsPortalParentMenuId, N'1099 (Portal)', N'Transaction', N'Screen', N'AccountsPayable.view.Thresholds1099', N'small-menu-transaction', 1, 0, 0, 1, 8, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 8, strCommand = N'AccountsPayable.view.Thresholds1099' WHERE strMenuName = '1099 (Portal)' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @TransactionsPortalParentMenuId

DECLARE @AP1099MenuId INT
SELECT  @AP1099MenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = N'1099 (Portal)' AND strModuleName = N'Accounts Payable' AND intParentMenuID = @TransactionsPortalParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'1099 (Portal)' AND strModuleName = N'Accounts Payable' AND intParentMenuID = @TransactionsPortalParentMenuId)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @AP1099MenuId)
	INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId], [ysnContactOnly]) VALUES (@AP1099MenuId, 1)
END

/* Support */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Support (Portal)' AND strModuleName = 'Help Desk' AND intParentMenuID = 0)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intRow], [intConcurrencyId]) 
	VALUES (N'Support (Portal)', N'Help Desk', 0, N'Support (Portal)', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 2, 0, 0)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 2, intRow = 0 WHERE strMenuName = 'Support (Portal)' AND strModuleName = 'Help Desk' AND intParentMenuID = 0

DECLARE @HelpDeskPortalParentMenuId INT
SELECT @HelpDeskPortalParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Support (Portal)' AND strModuleName = 'Help Desk' AND intParentMenuID = 0

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @HelpDeskPortalParentMenuId)
INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId], [ysnContactOnly]) VALUES (@HelpDeskPortalParentMenuId, 1)

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'My Tickets (Portal)' AND strModuleName = 'Help Desk' AND intParentMenuID = @HelpDeskPortalParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'My Tickets (Portal)', N'Help Desk', @HelpDeskPortalParentMenuId, N'My Tickets (Portal)', N'Support', N'Screen', N'HelpDesk.view.Ticket?showSearch=true&searchCommand=Ticket&isFloating=true&activeTab=Tickets Reported by Me', N'small-menu-support', 1, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 0, strCategory = N'Support', strIcon = N'small-menu-support', strCommand = N'HelpDesk.view.Ticket?showSearch=true&searchCommand=Ticket&isFloating=true&activeTab=Tickets Reported by Me' WHERE strMenuName = 'My Tickets (Portal)' AND strModuleName = 'Help Desk' AND intParentMenuID = @HelpDeskPortalParentMenuId

DECLARE @HDMyTicketsMenuId INT
SELECT  @HDMyTicketsMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = N'My Tickets (Portal)' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskPortalParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'My Tickets (Portal)' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskPortalParentMenuId)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @HDMyTicketsMenuId)
	INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId], [ysnContactOnly]) VALUES (@HDMyTicketsMenuId, 1)
END

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Open Tickets (Portal)' AND strModuleName = 'Help Desk' AND intParentMenuID = @HelpDeskPortalParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Open Tickets (Portal)', N'Help Desk', @HelpDeskPortalParentMenuId, N'Open Tickets (Portal)', N'Support', N'Screen', N'HelpDesk.view.Ticket?showSearch=true&searchCommand=Ticket&isFloating=true&activeTab=Open Tickets', N'small-menu-support', 1, 0, 0, 1, 1, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 1, strCategory = N'Support', strIcon = N'small-menu-support', strCommand = N'HelpDesk.view.Ticket?showSearch=true&searchCommand=Ticket&isFloating=true&activeTab=Open Tickets' WHERE strMenuName = 'Open Tickets (Portal)' AND strModuleName = 'Help Desk' AND intParentMenuID = @HelpDeskPortalParentMenuId

DECLARE @HDOpenTicketsMenuId INT
SELECT  @HDOpenTicketsMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = N'Open Tickets (Portal)' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskPortalParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Open Tickets (Portal)' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskPortalParentMenuId)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @HDOpenTicketsMenuId)
	INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId], [ysnContactOnly]) VALUES (@HDOpenTicketsMenuId, 1)
END

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'All Tickets (Portal)' AND strModuleName = 'Help Desk' AND intParentMenuID = @HelpDeskPortalParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'All Tickets (Portal)', N'Help Desk', @HelpDeskPortalParentMenuId, N'All Tickets (Portal)', N'Support', N'Screen', N'HelpDesk.view.Ticket?showSearch=true&searchCommand=Ticket&isFloating=true&activeTab=All Tickets', N'small-menu-support', 1, 0, 0, 1, 2, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 2, strCategory = N'Support', strIcon = N'small-menu-support', strCommand = N'HelpDesk.view.Ticket?showSearch=true&searchCommand=Ticket&isFloating=true&activeTab=All Tickets' WHERE strMenuName = 'All Tickets (Portal)' AND strModuleName = 'Help Desk' AND intParentMenuID = @HelpDeskPortalParentMenuId

DECLARE @HDAllTicketsMenuId INT
SELECT  @HDAllTicketsMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = N'All Tickets (Portal)' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskPortalParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'All Tickets (Portal)' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskPortalParentMenuId)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @HDAllTicketsMenuId)
	INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId], [ysnContactOnly]) VALUES (@HDAllTicketsMenuId, 1)
END

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Projects (Portal)' AND strModuleName = 'Help Desk' AND intParentMenuID = @HelpDeskPortalParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Projects (Portal)', N'Help Desk', @HelpDeskPortalParentMenuId, N'Projects (Portal)', N'Support', N'Screen', N'HelpDesk.view.Project?showSearch=true&searchCommand=Project', N'small-menu-support', 1, 0, 0, 1, 3, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 3, strCategory = N'Support', strIcon = N'small-menu-support', strCommand = N'HelpDesk.view.Project?showSearch=true&searchCommand=Project' WHERE strMenuName = 'Projects (Portal)' AND strModuleName = 'Help Desk' AND intParentMenuID = @HelpDeskPortalParentMenuId

DECLARE @HDProjectsMenuId INT
SELECT  @HDProjectsMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = N'Projects (Portal)' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskPortalParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Projects (Portal)' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskPortalParentMenuId)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @HDProjectsMenuId)
	INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId], [ysnContactOnly]) VALUES (@HDProjectsMenuId, 1)
END

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Time / Hours (Portal)' AND strModuleName = 'Help Desk' AND intParentMenuID = @HelpDeskPortalParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Time / Hours (Portal)', N'Help Desk', @HelpDeskPortalParentMenuId, N'Time / Hours (Portal)', N'Support', N'Screen', N'HelpDesk.view.TimeHoursReport?showSearch=true&searchCommand=TimeHoursReport', N'small-menu-support', 1, 0, 0, 1, 4, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 4, strCategory = N'Support', strIcon = N'small-menu-support', strCommand = N'HelpDesk.view.TimeHoursReport?showSearch=true&searchCommand=TimeHoursReport' WHERE strMenuName = 'Time / Hours (Portal)' AND strModuleName = 'Help Desk' AND intParentMenuID = @HelpDeskPortalParentMenuId

DECLARE @HDTimeHoursMenuId INT
SELECT  @HDTimeHoursMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = N'Time / Hours (Portal)' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskPortalParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Time / Hours (Portal)' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskPortalParentMenuId)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @HDTimeHoursMenuId)
	INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId], [ysnContactOnly]) VALUES (@HDTimeHoursMenuId, 1)
END

/* CRM */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'CRM (Portal)' AND strModuleName = 'CRM' AND intParentMenuID = 0)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intRow], [intConcurrencyId]) 
	VALUES (N'CRM (Portal)', N'CRM', 0, N'CRM (Portal)', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 3, 0, 0)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 3, intRow = 0 WHERE strMenuName = 'CRM (Portal)' AND strModuleName = 'CRM' AND intParentMenuID = 0

DECLARE @CRMPortalParentMenuId INT
SELECT @CRMPortalParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'CRM (Portal)' AND strModuleName = 'CRM' AND intParentMenuID = 0

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @CRMPortalParentMenuId)
INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId], [ysnContactOnly]) VALUES (@CRMPortalParentMenuId, 1)

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Activities (Portal)' AND strModuleName = 'CRM' AND intParentMenuID = @CRMPortalParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Activities (Portal)', N'CRM', @CRMPortalParentMenuId, N'Activities (Portal)', N'Portal Menu', N'Screen', N'CRM.view.Opportunity?showSearch=true&searchCommand=Activity', N'small-menu-portal', 1, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 0, strCommand = N'CRM.view.Opportunity?showSearch=true&searchCommand=Activity' WHERE strMenuName = 'Activities (Portal)' AND strModuleName = 'CRM' AND intParentMenuID = @CRMPortalParentMenuId

DECLARE @CRMActivitiesMenuId INT
SELECT  @CRMActivitiesMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Activities (Portal)' AND strModuleName = 'CRM' AND intParentMenuID = @CRMPortalParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Activities (Portal)' AND strModuleName = 'CRM' AND intParentMenuID = @CRMPortalParentMenuId)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @CRMActivitiesMenuId)
	INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId], [ysnContactOnly]) VALUES (@CRMActivitiesMenuId, 1)
END

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Opportunities (Portal)' AND strModuleName = 'CRM' AND intParentMenuID = @CRMPortalParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Opportunities (Portal)', N'CRM', @CRMPortalParentMenuId, N'Opportunities (Portal)', N'Portal Menu', N'Screen', N'CRM.view.Opportunity?showSearch=true&searchCommand=Opportunity', N'small-menu-portal', 1, 0, 0, 1, 1, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 1, strCommand = N'CRM.view.Opportunity?showSearch=true&searchCommand=Opportunity' WHERE strMenuName = 'Opportunities (Portal)' AND strModuleName = 'CRM' AND intParentMenuID = @CRMPortalParentMenuId

DECLARE @CRMOpportunitiesMenuId INT
SELECT  @CRMOpportunitiesMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Opportunities (Portal)' AND strModuleName = 'CRM' AND intParentMenuID = @CRMPortalParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Opportunities (Portal)' AND strModuleName = 'CRM' AND intParentMenuID = @CRMPortalParentMenuId)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @CRMOpportunitiesMenuId)
	INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId], [ysnContactOnly]) VALUES (@CRMOpportunitiesMenuId, 1)
END

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Campaigns (Portal)' AND strModuleName = 'CRM' AND intParentMenuID = @CRMPortalParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Campaigns (Portal)', N'CRM', @CRMPortalParentMenuId, N'Campaigns (Portal)', N'Portal Menu', N'Screen', N'CRM.view.Campaign?showSearch=true&searchCommand=Campaign', N'small-menu-portal', 1, 0, 0, 1, 2, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 2, strCommand = N'CRM.view.Campaign?showSearch=true&searchCommand=Campaign' WHERE strMenuName = 'Campaigns (Portal)' AND strModuleName = 'CRM' AND intParentMenuID = @CRMPortalParentMenuId

DECLARE @CRMCampaignsMenuId INT
SELECT  @CRMCampaignsMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Campaigns (Portal)' AND strModuleName = 'CRM' AND intParentMenuID = @CRMPortalParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Campaigns (Portal)' AND strModuleName = 'CRM' AND intParentMenuID = @CRMPortalParentMenuId)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @CRMCampaignsMenuId)
	INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId], [ysnContactOnly]) VALUES (@CRMCampaignsMenuId, 1)
END

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Sales Pipe Statuses (Portal)' AND strModuleName = 'CRM' AND intParentMenuID = @CRMPortalParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Sales Pipe Statuses (Portal)', N'CRM', @CRMPortalParentMenuId, N'Sales Pipe Statuses (Portal)', N'Portal Menu', N'Screen', N'CRM.view.SalesPipeStatus?searchCommand=searchConfig', N'small-menu-portal', 1, 0, 0, 1, 3, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 3, strCommand = N'CRM.view.SalesPipeStatus?searchCommand=searchConfig' WHERE strMenuName = 'Sales Pipe Statuses (Portal)' AND strModuleName = 'CRM' AND intParentMenuID = @CRMPortalParentMenuId

DECLARE @CRMSalesPipeStatusesMenuId INT
SELECT  @CRMSalesPipeStatusesMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Sales Pipe Statuses (Portal)' AND strModuleName = 'CRM' AND intParentMenuID = @CRMPortalParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Sales Pipe Statuses (Portal)' AND strModuleName = 'CRM' AND intParentMenuID = @CRMPortalParentMenuId)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @CRMSalesPipeStatusesMenuId)
	INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId], [ysnContactOnly]) VALUES (@CRMSalesPipeStatusesMenuId, 1)
END

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Sources (Portal)' AND strModuleName = 'CRM' AND intParentMenuID = @CRMPortalParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Sources (Portal)', N'CRM', @CRMPortalParentMenuId, N'Sources (Portal)', N'Portal Menu', N'Screen', N'CRM.view.Source', N'small-menu-portal', 1, 0, 0, 1, 4, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 4, strCommand = N'CRM.view.Source' WHERE strMenuName = 'Sources (Portal)' AND strModuleName = 'CRM' AND intParentMenuID = @CRMPortalParentMenuId

DECLARE @CRMSourcesMenuId INT
SELECT  @CRMSourcesMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Sources (Portal)' AND strModuleName = 'CRM' AND intParentMenuID = @CRMPortalParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Sources (Portal)' AND strModuleName = 'CRM' AND intParentMenuID = @CRMPortalParentMenuId)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @CRMSourcesMenuId)
	INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId], [ysnContactOnly]) VALUES (@CRMSourcesMenuId, 1)
END

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Sales Entities (Portal)' AND strModuleName = 'CRM' AND intParentMenuID = @CRMPortalParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Sales Entities (Portal)', N'CRM', @CRMPortalParentMenuId, N'Sales Entities (Portal)', N'Portal Menu', N'Screen', N'AccountsReceivable.view.EntityProspect?showSearch=true', N'small-menu-portal', 1, 0, 0, 1, 5, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 5, strCommand = N'AccountsReceivable.view.EntityProspect?showSearch=true' WHERE strMenuName = 'Sales Entities (Portal)' AND strModuleName = 'CRM' AND intParentMenuID = @CRMPortalParentMenuId

DECLARE @CRMSalesEntitiesMenuId INT
SELECT  @CRMSalesEntitiesMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Sales Entities (Portal)' AND strModuleName = 'CRM' AND intParentMenuID = @CRMPortalParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Sales Entities (Portal)' AND strModuleName = 'CRM' AND intParentMenuID = @CRMPortalParentMenuId)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @CRMSalesEntitiesMenuId)
	INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId], [ysnContactOnly]) VALUES (@CRMSalesEntitiesMenuId, 1)
END

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Leads (Portal)' AND strModuleName = 'CRM' AND intParentMenuID = @CRMPortalParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Leads (Portal)', N'CRM', @CRMPortalParentMenuId, N'Leads (Portal)', N'Portal Menu', N'Screen', N'AccountsReceivable.view.EntityLead?showSearch=true', N'small-menu-portal', 1, 0, 0, 1, 6, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 6, strCommand = N'AccountsReceivable.view.EntityLead?showSearch=true' WHERE strMenuName = 'Leads (Portal)' AND strModuleName = 'CRM' AND intParentMenuID = @CRMPortalParentMenuId

DECLARE @CRMLeadMenuId INT
SELECT  @CRMLeadMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Leads (Portal)' AND strModuleName = 'CRM' AND intParentMenuID = @CRMPortalParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Leads (Portal)' AND strModuleName = 'CRM' AND intParentMenuID = @CRMPortalParentMenuId)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @CRMLeadMenuId)
	INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId], [ysnContactOnly]) VALUES (@CRMLeadMenuId, 1)
END

/* Grain */
UPDATE tblSMMasterMenu SET strMenuName = 'Grain (Portal)', strDescription = 'Grain (Portal)' WHERE strMenuName = 'Scale (Portal)' AND strModuleName = 'Ticket Management' AND intParentMenuID = 0
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Grain (Portal)' AND strModuleName = 'Ticket Management' AND intParentMenuID = 0)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intRow], [intConcurrencyId]) 
	VALUES ('Grain (Portal)', N'Ticket Management', 0, 'Grain (Portal)', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 0, 1, 0)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 0, intRow = 1 WHERE strMenuName = 'Grain (Portal)' AND strModuleName = 'Ticket Management' AND intParentMenuID = 0

DECLARE @GrainPortalParentMenuId INT
SELECT @GrainPortalParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Grain (Portal)' AND strModuleName = 'Ticket Management' AND intParentMenuID = 0

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @GrainPortalParentMenuId)
INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId], [ysnContactOnly]) VALUES (@GrainPortalParentMenuId, 1)

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Scale Tickets (Portal)' AND strModuleName = 'Ticket Management' AND intParentMenuID = @GrainPortalParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Scale Tickets (Portal)', N'Ticket Management', @GrainPortalParentMenuId, N'Scale Tickets (Portal)', N'Portal Menu', N'Screen', N'Grain.view.ScaleStationSelection?showSearch=true', N'small-menu-portal', 1, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 0, strCommand = N'Grain.view.ScaleStationSelection?showSearch=true' WHERE strMenuName = 'Scale Tickets (Portal)' AND strModuleName = 'Ticket Management' AND intParentMenuID = @GrainPortalParentMenuId

DECLARE @TKScaleTicketsMenuId INT
SELECT  @TKScaleTicketsMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Scale Tickets (Portal)' AND strModuleName = 'Ticket Management' AND intParentMenuID = @GrainPortalParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Scale Tickets (Portal)' AND strModuleName = 'Ticket Management' AND intParentMenuID = @GrainPortalParentMenuId)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @TKScaleTicketsMenuId)
	INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId], [ysnContactOnly]) VALUES (@TKScaleTicketsMenuId, 1)
END

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Storage (Portal)' AND strModuleName = 'Ticket Management' AND intParentMenuID = @GrainPortalParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Storage (Portal)', N'Ticket Management', @GrainPortalParentMenuId, N'Storage (Portal)', N'Portal Menu', N'Screen', N'Grain.view.Storage?showSearch=true', N'small-menu-portal', 1, 0, 0, 1, 1, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 1, strCommand = N'Grain.view.Storage?showSearch=true' WHERE strMenuName = 'Storage (Portal)' AND strModuleName = 'Ticket Management' AND intParentMenuID = @GrainPortalParentMenuId

DECLARE @TKStorageMenuId INT
SELECT  @TKStorageMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Storage (Portal)' AND strModuleName = 'Ticket Management' AND intParentMenuID = @GrainPortalParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Storage (Portal)' AND strModuleName = 'Ticket Management' AND intParentMenuID = @GrainPortalParentMenuId)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @TKStorageMenuId)
	INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId], [ysnContactOnly]) VALUES (@TKStorageMenuId, 1)
END

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Delivery Sheets (Portal)' AND strModuleName = 'Ticket Management' AND intParentMenuID = @GrainPortalParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Delivery Sheets (Portal)', N'Ticket Management', @GrainPortalParentMenuId, N'Delivery Sheets (Portal)', N'Portal Menu', N'Screen', N'Grain.view.DeliverySheet?showSearch=true', N'small-menu-portal', 1, 0, 0, 1, 2, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 2, strCommand = N'Grain.view.DeliverySheet?showSearch=true' WHERE strMenuName = 'Delivery Sheets (Portal)' AND strModuleName = 'Ticket Management' AND intParentMenuID = @GrainPortalParentMenuId

DECLARE @TKDeliverySheetsMenuId INT
SELECT  @TKDeliverySheetsMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Delivery Sheets (Portal)' AND strModuleName = 'Ticket Management' AND intParentMenuID = @GrainPortalParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Delivery Sheets (Portal)' AND strModuleName = 'Ticket Management' AND intParentMenuID = @GrainPortalParentMenuId)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @TKDeliverySheetsMenuId)
	INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId], [ysnContactOnly]) VALUES (@TKDeliverySheetsMenuId, 1)
END

/* Logistics */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Logistics (Portal)' AND strModuleName = 'Logistics' AND intParentMenuID = 0)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intRow], [intConcurrencyId]) 
	VALUES (N'Logistics (Portal)', N'Logistics', 0, N'Logistics (Portal)', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 1, 1, 0)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 1, intRow = 1 WHERE strMenuName = 'Logistics (Portal)' AND strModuleName = 'Logistics' AND intParentMenuID = 0

DECLARE @LogisticsPortalParentMenuId INT
SELECT @LogisticsPortalParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Logistics (Portal)' AND strModuleName = 'Logistics' AND intParentMenuID = 0

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @LogisticsPortalParentMenuId)
INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId], [ysnContactOnly]) VALUES (@LogisticsPortalParentMenuId, 1)

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Load / Shipment Schedules (Portal)' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsPortalParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Load / Shipment Schedules (Portal)', N'Logistics', @LogisticsPortalParentMenuId, N'Load / Shipment Schedules (Portal)', N'Portal Menu', N'Screen', N'Logistics.view.ShipmentSchedule?showSearch=true', N'small-menu-portal', 1, 0, 0, 1, 1, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 1, strCommand = N'Logistics.view.ShipmentSchedule?showSearch=true' WHERE strMenuName = 'Load / Shipment Schedules (Portal)' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsPortalParentMenuId

DECLARE @LGLoadShipmentSchedulesMenuId INT
SELECT  @LGLoadShipmentSchedulesMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Load / Shipment Schedules (Portal)' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsPortalParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Load / Shipment Schedules (Portal)' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsPortalParentMenuId)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @LGLoadShipmentSchedulesMenuId)
	INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId], [ysnContactOnly]) VALUES (@LGLoadShipmentSchedulesMenuId, 1)
END

/* Manufacturing */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Manufacturing (Portal)' AND strModuleName = 'Manufacturing' AND intParentMenuID = 0)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intRow], [intConcurrencyId]) 
	VALUES (N'Manufacturing (Portal)', N'Manufacturing', 0, N'Manufacturing (Portal)', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 2, 1, 0)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 2, intRow = 1 WHERE strMenuName = 'Manufacturing (Portal)' AND strModuleName = 'Manufacturing' AND intParentMenuID = 0

DECLARE @ManufacturingPortalParentMenuId INT
SELECT @ManufacturingPortalParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Manufacturing (Portal)' AND strModuleName = 'Manufacturing' AND intParentMenuID = 0

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @ManufacturingPortalParentMenuId)
INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId], [ysnContactOnly]) VALUES (@ManufacturingPortalParentMenuId, 1)

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Transactions (Portal)' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingPortalParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Transactions (Portal)', N'Manufacturing', @ManufacturingPortalParentMenuId, N'Transactions (Portal)', N'Portal Menu', N'Screen', N'Manufacturing.view.TransactionView?showSearch=true', N'small-menu-portal', 1, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 0, strCommand = N'Manufacturing.view.TransactionView?showSearch=true' WHERE strMenuName = 'Transactions (Portal)' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingPortalParentMenuId

DECLARE @MFTransactionsMenuId INT
SELECT  @MFTransactionsMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Transactions (Portal)' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingPortalParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Transactions (Portal)' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingPortalParentMenuId)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @MFTransactionsMenuId)
	INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId], [ysnContactOnly]) VALUES (@MFTransactionsMenuId, 1)
END

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Inventory (Portal)' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingPortalParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Inventory (Portal)', N'Manufacturing', @ManufacturingPortalParentMenuId, N'Inventory (Portal)', N'Portal Menu', N'Screen', N'Manufacturing.view.InventoryView?showSearch=true', N'small-menu-portal', 1, 0, 0, 1, 1, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 1, strCommand = N'Manufacturing.view.InventoryView?showSearch=true' WHERE strMenuName = 'Inventory (Portal)' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingPortalParentMenuId

DECLARE @MFInventoryMenuId INT
SELECT  @MFInventoryMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Inventory (Portal)' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingPortalParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Inventory (Portal)' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingPortalParentMenuId)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @MFInventoryMenuId)
	INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId], [ysnContactOnly]) VALUES (@MFInventoryMenuId, 1)
END

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Quality (Portal)' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingPortalParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Quality (Portal)', N'Manufacturing', @ManufacturingPortalParentMenuId, N'Quality (Portal)', N'Portal Menu', N'Screen', N'Quality.view.QualityException', N'small-menu-portal', 1, 0, 0, 1, 2, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 2, strCommand = N'Quality.view.QualityException' WHERE strMenuName = 'Quality (Portal)' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingPortalParentMenuId

DECLARE @MFQualityMenuId INT
SELECT  @MFQualityMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Quality (Portal)' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingPortalParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Quality (Portal)' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingPortalParentMenuId)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @MFQualityMenuId)
	INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId], [ysnContactOnly]) VALUES (@MFQualityMenuId, 1)
END

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Sample Entry (Portal)' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingPortalParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Sample Entry (Portal)', N'Manufacturing', @ManufacturingPortalParentMenuId, N'Sample Entry (Portal)', N'Portal Menu', N'Screen', N'Quality.view.QualitySample?showSearch=true', N'small-menu-portal', 1, 0, 0, 1, 3, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 3, strCommand = N'Quality.view.QualitySample?showSearch=true' WHERE strMenuName = 'Sample Entry (Portal)' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingPortalParentMenuId

DECLARE @MFSampleEntryMenuId INT
SELECT  @MFSampleEntryMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Sample Entry (Portal)' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingPortalParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Sample Entry (Portal)' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingPortalParentMenuId)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @MFSampleEntryMenuId)
	INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId], [ysnContactOnly]) VALUES (@MFSampleEntryMenuId, 1)
END

/* Card Fueling */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Card Fueling (Portal)' AND strModuleName = 'Card Fueling' AND intParentMenuID = 0)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intRow], [intConcurrencyId]) 
	VALUES (N'Card Fueling (Portal)', N'Card Fueling', 0, N'Card Fueling (Portal)', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 3, 1, 0)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 3, intRow = 1 WHERE strMenuName = 'Card Fueling (Portal)' AND strModuleName = 'Card Fueling' AND intParentMenuID = 0

DECLARE @CardFuelingPortalParentMenuId INT
SELECT @CardFuelingPortalParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Card Fueling (Portal)' AND strModuleName = 'Card Fueling' AND intParentMenuID = 0

/* START OF RENAMING  */
UPDATE tblSMMasterMenu SET strMenuName = N'Purchase Summary Report (Portal)', strDescription = N'Purchase Summary Report (Portal)' WHERE strMenuName = 'Puchase Summary Report (Portal)' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingPortalParentMenuId
/* END OF RENAMING  */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @CardFuelingPortalParentMenuId)
INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId], [ysnContactOnly]) VALUES (@CardFuelingPortalParentMenuId, 1)

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Transactions (Portal)' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingPortalParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Transactions (Portal)', N'Card Fueling', @CardFuelingPortalParentMenuId, N'Transactions (Portal)', N'Portal Menu', N'Screen', N'CardFueling.view.Transaction?showSearch=true', N'small-menu-portal', 1, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 0, strCommand = N'CardFueling.view.Transaction?showSearch=true' WHERE strMenuName = 'Transactions (Portal)' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingPortalParentMenuId

DECLARE @CFTransactionsMenuId INT
SELECT  @CFTransactionsMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Transactions (Portal)' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingPortalParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Transactions (Portal)' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingPortalParentMenuId)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @CFTransactionsMenuId)
	INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId], [ysnContactOnly]) VALUES (@CFTransactionsMenuId, 1)
END

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Card Accounts (Portal)' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingPortalParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Card Accounts (Portal)', N'Card Fueling', @CardFuelingPortalParentMenuId, N'Card Accounts (Portal)', N'Portal Menu', N'Screen', N'CardFueling.view.Account', N'small-menu-portal', 1, 0, 0, 1, 1, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 1, strCommand = N'CardFueling.view.Account' WHERE strMenuName = 'Card Accounts (Portal)' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingPortalParentMenuId

DECLARE @CFCardAccountsMenuId INT
SELECT  @CFCardAccountsMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Card Accounts (Portal)' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingPortalParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Card Accounts (Portal)' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingPortalParentMenuId)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @CFCardAccountsMenuId)
	INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId], [ysnContactOnly]) VALUES (@CFCardAccountsMenuId, 1)
END

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Quote (Portal)' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingPortalParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Quote (Portal)', N'Card Fueling', @CardFuelingPortalParentMenuId, N'Quote (Portal)', N'Portal Menu', N'Screen', N'CardFueling.view.CSRSingleQuotePortal', N'small-menu-portal', 1, 0, 0, 1, 2, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 2, strCommand = N'CardFueling.view.CSRSingleQuotePortal' WHERE strMenuName = 'Quote (Portal)' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingPortalParentMenuId

DECLARE @CFQuoteMenuId INT
SELECT  @CFQuoteMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Quote (Portal)' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingPortalParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Quote (Portal)' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingPortalParentMenuId)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @CFQuoteMenuId)
	INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId], [ysnContactOnly]) VALUES (@CFQuoteMenuId, 1)
END

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Invoice History (Portal)' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingPortalParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Invoice History (Portal)', N'Card Fueling', @CardFuelingPortalParentMenuId, N'Invoice History (Portal)', N'Portal Menu', N'Screen', N'CardFueling.view.InvoiceProcessHistory', N'small-menu-portal', 1, 0, 0, 1, 3, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 3, strCommand = N'CardFueling.view.InvoiceProcessHistory' WHERE strMenuName = 'Invoice History (Portal)' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingPortalParentMenuId

DECLARE @CFInventoryHistoryMenuId INT
SELECT  @CFInventoryHistoryMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Invoice History (Portal)' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingPortalParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Invoice History (Portal)' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingPortalParentMenuId)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @CFInventoryHistoryMenuId)
	INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId], [ysnContactOnly]) VALUES (@CFInventoryHistoryMenuId, 1)
END

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Purchase Summary Report (Portal)' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingPortalParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Purchase Summary Report (Portal)', N'Card Fueling', @CardFuelingPortalParentMenuId, N'Purchase Summary Report (Portal)', N'Portal Menu', N'Screen', N'CardFueling.view.PurchaseSummaryReport', N'small-menu-portal', 1, 0, 0, 1, 4, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 4, strCommand = N'CardFueling.view.PurchaseSummaryReport' WHERE strMenuName = 'Purchase Summary Report (Portal)' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingPortalParentMenuId

DECLARE @CFPurchaseSummaryReportMenuId INT
SELECT  @CFPurchaseSummaryReportMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Purchase Summary Report (Portal)' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingPortalParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Purchase Summary Report (Portal)' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingPortalParentMenuId)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @CFPurchaseSummaryReportMenuId)
	INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId], [ysnContactOnly]) VALUES (@CFPurchaseSummaryReportMenuId, 1)
END

/* Tank Management */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Tank Management (Portal)' AND strModuleName = 'Tank Management' AND intParentMenuID = 0)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intRow], [intConcurrencyId]) 
	VALUES (N'Tank Management (Portal)', N'Tank Management', 0, N'Tank Management (Portal)', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 0, 2, 0)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 0, intRow = 2 WHERE strMenuName = 'Tank Management (Portal)' AND strModuleName = 'Tank Management' AND intParentMenuID = 0

DECLARE @TankManagementPortalParentMenuId INT
SELECT @TankManagementPortalParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Tank Management (Portal)' AND strModuleName = 'Tank Management' AND intParentMenuID = 0

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @TankManagementPortalParentMenuId)
INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId], [ysnContactOnly]) VALUES (@TankManagementPortalParentMenuId, 1)

/* Rename Consumption Sites (Portal) to My Tanks (Portal) */
UPDATE tblSMMasterMenu SET strMenuName = N'My Tanks (Portal)', strDescription = N'My Tanks (Portal)' WHERE strMenuName = 'Consumption Sites (Portal)' AND strModuleName = 'Tank Management' AND intParentMenuID = @TankManagementPortalParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'My Tanks (Portal)' AND strModuleName = 'Tank Management' AND intParentMenuID = @TankManagementPortalParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'My Tanks (Portal)', N'Tank Management', @TankManagementPortalParentMenuId, N'My Tanks (Portal)', N'Portal Menu', N'Screen', N'TankManagement.view.ConsumptionSite?showSearch=true', N'small-menu-portal', 1, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 0, strCommand = N'TankManagement.view.ConsumptionSite?showSearch=true' WHERE strMenuName = 'My Tanks (Portal)' AND strModuleName = 'Tank Management' AND intParentMenuID = @TankManagementPortalParentMenuId

DECLARE @TMMyTanksMenuId INT
SELECT  @TMMyTanksMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'My Tanks (Portal)' AND strModuleName = 'Tank Management' AND intParentMenuID = @TankManagementPortalParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'My Tanks (Portal)' AND strModuleName = 'Tank Management' AND intParentMenuID = @TankManagementPortalParentMenuId)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @TMMyTanksMenuId)
	INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId], [ysnContactOnly]) VALUES (@TMMyTanksMenuId, 1)
END

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Request Order (Portal)' AND strModuleName = 'Tank Management' AND intParentMenuID = @TankManagementPortalParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Request Order (Portal)', N'Tank Management', @TankManagementPortalParentMenuId, N'Request Order Description (Portal)', N'Portal Menu', N'Screen', N'TankManagement.view.Order?showSearch=true', N'small-menu-portal', 1, 0, 0, 1, 1, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 1, strCommand = N'TankManagement.view.Order?showSearch=true', strDescription = N'Request Order Description (Portal)' WHERE strMenuName = 'Request Order (Portal)' AND strModuleName = 'Tank Management' AND intParentMenuID = @TankManagementPortalParentMenuId

DECLARE @TMRequestOrderMenuId INT
SELECT  @TMRequestOrderMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Request Order (Portal)' AND strModuleName = 'Tank Management' AND intParentMenuID = @TankManagementPortalParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Request Order (Portal)' AND strModuleName = 'Tank Management' AND intParentMenuID = @TankManagementPortalParentMenuId)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @TMRequestOrderMenuId)
	INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId], [ysnContactOnly]) VALUES (@TMRequestOrderMenuId, 1)
END

/* Payroll */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Payroll (Portal)' AND strModuleName = 'Payroll' AND intParentMenuID = 0)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intRow], [intConcurrencyId]) 
	VALUES (N'Payroll (Portal)', N'Payroll', 0, N'Payroll (Portal)', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 1, 2, 0)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 1, intRow = 2 WHERE strMenuName = 'Payroll (Portal)' AND strModuleName = 'Payroll' AND intParentMenuID = 0

DECLARE @PayrollPortalParentMenuId INT
SELECT @PayrollPortalParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Payroll (Portal)' AND strModuleName = 'Payroll' AND intParentMenuID = 0

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @PayrollPortalParentMenuId)
INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId], [ysnContactOnly]) VALUES (@PayrollPortalParentMenuId, 1)

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Employee (Portal)' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollPortalParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Employee (Portal)', N'Payroll', @PayrollPortalParentMenuId, N'Employee (Portal)', N'Portal Menu', N'Screen', N'Payroll.view.EntityEmployee', N'small-menu-portal', 1, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 0, strCommand = N'Payroll.view.EntityEmployee' WHERE strMenuName = 'Employee (Portal)' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollPortalParentMenuId

DECLARE @PREmployeeMenuId INT
SELECT  @PREmployeeMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Employee (Portal)' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollPortalParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Employee (Portal)' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollPortalParentMenuId)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @PREmployeeMenuId)
	INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId], [ysnContactOnly]) VALUES (@PREmployeeMenuId, 1)
END

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Paychecks (Portal)' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollPortalParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Paychecks (Portal)', N'Payroll', @PayrollPortalParentMenuId, N'Paychecks (Portal)', N'Portal Menu', N'Screen', N'Payroll.view.Paycheck?showSearch=true&searchCommand=Paycheck&isFloating=true', N'small-menu-portal', 1, 0, 0, 1, 1, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 1, strCommand = N'Payroll.view.Paycheck?showSearch=true&searchCommand=Paycheck&isFloating=true' WHERE strMenuName = 'Paychecks (Portal)' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollPortalParentMenuId

DECLARE @PRPaychecksMenuId INT
SELECT  @PRPaychecksMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Paychecks (Portal)' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollPortalParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Paychecks (Portal)' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollPortalParentMenuId)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @PRPaychecksMenuId)
	INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId], [ysnContactOnly]) VALUES (@PRPaychecksMenuId, 1)
END

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Time Off Request (Portal)' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollPortalParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Time Off Request (Portal)', N'Payroll', @PayrollPortalParentMenuId, N'Time Off Request (Portal)', N'Portal Menu', N'Screen', N'Payroll.view.TimeOffRequest?showSearch=true&searchCommand=TimeOffRequest&isFloating=true', N'small-menu-portal', 1, 0, 0, 1, 2, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 2, strCommand = N'Payroll.view.TimeOffRequest?showSearch=true&searchCommand=TimeOffRequest&isFloating=true' WHERE strMenuName = 'Time Off Request (Portal)' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollPortalParentMenuId

DECLARE @PRTimeOffRequestMenuId INT
SELECT  @PRTimeOffRequestMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Time Off Request (Portal)' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollPortalParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Time Off Request (Portal)' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollPortalParentMenuId)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @PRTimeOffRequestMenuId)
	INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId], [ysnContactOnly]) VALUES (@PRTimeOffRequestMenuId, 1)
END

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Time Off Calendar (Portal)' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollPortalParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Time Off Calendar (Portal)', N'Payroll', @PayrollPortalParentMenuId, N'Time Off Calendar (Portal)', N'Portal Menu', N'Screen', N'GlobalComponentEngine.view.Calendar', N'small-menu-portal', 1, 0, 0, 1, 3, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 3, strCommand = N'GlobalComponentEngine.view.Calendar' WHERE strMenuName = 'Time Off Calendar (Portal)' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollPortalParentMenuId

DECLARE @PRTimeOffCalendarMenuId INT
SELECT  @PRTimeOffCalendarMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Time Off Calendar (Portal)' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollPortalParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Time Off Calendar (Portal)' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollPortalParentMenuId)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @PRTimeOffCalendarMenuId)
	INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId], [ysnContactOnly]) VALUES (@PRTimeOffCalendarMenuId, 1)
END

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'W-2s (Portal)' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollPortalParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'W-2s (Portal)', N'Payroll', @PayrollPortalParentMenuId, N'W-2s (Portal)', N'Portal Menu', N'Screen', N'Payroll.view.EmployeeW2?showSearch=true&searchCommand=EmployeeW2&isFloating=true', N'small-menu-portal', 1, 0, 0, 1, 4, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 4, strCommand = N'Payroll.view.EmployeeW2?showSearch=true&searchCommand=EmployeeW2&isFloating=true' WHERE strMenuName = 'W-2s (Portal)' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollPortalParentMenuId

DECLARE @PRW2SMenuId INT
SELECT  @PRW2SMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'W-2s (Portal)' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollPortalParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'W-2s (Portal)' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollPortalParentMenuId)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @PRW2SMenuId)
	INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId], [ysnContactOnly]) VALUES (@PRW2SMenuId, 1)
END

/* Risk Management */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Risk Management (Portal)' AND strModuleName = 'Risk Management' AND intParentMenuID = 0)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intRow], [intConcurrencyId]) 
	VALUES (N'Risk Management (Portal)', N'Risk Management', 0, N'Risk Management (Portal)', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 2, 2, 0)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 2, intRow = 2 WHERE strMenuName = 'Risk Management (Portal)' AND strModuleName = 'Risk Management' AND intParentMenuID = 0

DECLARE @RiskManagementPortalParentMenuId INT
SELECT @RiskManagementPortalParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Risk Management (Portal)' AND strModuleName = 'Risk Management' AND intParentMenuID = 0

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @RiskManagementPortalParentMenuId)
INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId], [ysnContactOnly]) VALUES (@RiskManagementPortalParentMenuId, 1)

-- Move from Grain to Risk Management
UPDATE tblSMMasterMenu SET intParentMenuID = @RiskManagementPortalParentMenuId WHERE strMenuName = 'Position Report (Portal)' AND strModuleName = 'Risk Management' AND intParentMenuID = @GrainPortalParentMenuId
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Position Report (Portal)' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementPortalParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Position Report (Portal)', N'Risk Management', @RiskManagementPortalParentMenuId, N'Position Report (Portal)', N'Portal Menu', N'Screen', N'RiskManagement.view.PositionReport', N'small-menu-portal', 1, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 0, strCommand = N'RiskManagement.view.PositionReport' WHERE strMenuName = 'Position Report (Portal)' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementPortalParentMenuId

DECLARE @RKPositionReportMenuId INT
SELECT  @RKPositionReportMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Position Report (Portal)' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementPortalParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Position Report (Portal)' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementPortalParentMenuId)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @RKPositionReportMenuId)
	INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId], [ysnContactOnly]) VALUES (@RKPositionReportMenuId, 1)
END

/* Inventory */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Inventory (Portal)' AND strModuleName = 'Inventory' AND intParentMenuID = 0)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intRow], [intConcurrencyId]) 
	VALUES (N'Inventory (Portal)', N'Inventory', 0, N'Inventory (Portal)', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 3, 2, 0)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 3, intRow = 2 WHERE strMenuName = 'Inventory (Portal)' AND strModuleName = 'Inventory' AND intParentMenuID = 0

DECLARE @InventoryPortalParentMenuId INT
SELECT @InventoryPortalParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Inventory (Portal)' AND strModuleName = 'Inventory' AND intParentMenuID = 0

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @InventoryPortalParentMenuId)
INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId], [ysnContactOnly]) VALUES (@InventoryPortalParentMenuId, 1)

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Inventory Receipts (Portal)' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryPortalParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Inventory Receipts (Portal)', N'Inventory', @InventoryPortalParentMenuId, N'Inventory Receipts (Portal)', N'Portal Menu', N'Screen', N'Inventory.view.InventoryReceipt?showSearch=true', N'small-menu-portal', 1, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 0, strCommand = N'Inventory.view.InventoryReceipt?showSearch=true' WHERE strMenuName = 'Inventory Receipts (Portal)' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryPortalParentMenuId

DECLARE @PRInventoryReceiptsMenuId INT
SELECT  @PRInventoryReceiptsMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Inventory Receipts (Portal)' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryPortalParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Inventory Receipts (Portal)' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryPortalParentMenuId)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @PRInventoryReceiptsMenuId)
	INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId], [ysnContactOnly]) VALUES (@PRInventoryReceiptsMenuId, 1)
END
GO
----------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------- ADJUST uspSMSortOriginMenus' sorting -------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------