GO

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Bank File Formats'	AND strModuleName = 'Cash Management' AND (strCommand = 'CashManagement.controller.BankFileFormat' OR strCommand = 'CashManagement.view.BankFileFormat' OR strCommand = 'CashManagement.view.BankFileFormat?showSearch=true'))
	BEGIN
		DELETE FROM tblSMMasterMenu
		
		SET IDENTITY_INSERT [dbo].[tblSMMasterMenu] ON

		/* SYSTEM MANAGER */
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (1, N'System Manager', N'System Manager', 0, N'System Manager', NULL, N'Folder', N'i21', N'small-folder', 1, 0, 0, 0, 1, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (2, N'Users', N'System Manager', 1, N'Users', N'Maintenance', N'Screen', N'i21.view.EntityUser?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 0, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (3, N'User Roles', N'System Manager', 1, N'User Roles', N'Maintenance', N'Screen', N'i21.view.UserRole', N'small-menu-maintenance', 0, 0, 0, 1, 1, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (4, N'Report Manager', N'System Manager', 1, N'Report Manager', N'Maintenance', N'Screen', N'Reports.controller.ReportManager', N'small-menu-maintenance', 0, 0, 0, 1, 3, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (5, N'Motor Fuel Tax Cycle', N'System Manager', 1, N'Motor Fuel Tax Cycle', N'Maintenance', N'Screen', N'Reports.controller.RunTaxCycle', N'small-menu-maintenance', 0, 0, 0, 1, 4, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (6, N'Company Preferences', N'System Manager', 1, N'Company Preferences', N'Maintenance', N'Screen', N'i21.view.CompanyPreferences', N'small-menu-maintenance', 0, 0, 0, 1, 5, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (7, N'Starting Numbers', N'System Manager', 1, N'Starting Numbers', N'Maintenance', N'Screen', N'i21.view.StartingNumbers', N'small-menu-maintenance', 0, 0, 0, 1, 6, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (8, N'Custom Fields', N'System Manager', 1, N'Custom Fields', N'Maintenance', N'Screen', N'GlobalComponentEngine.view.CustomField', N'small-menu-maintenance', 0, 0, 0, 1, 7, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (10, N'Utilities', N'System Manager', 1, N'Utilities', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 9, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (11, N'Origin Conversions', N'System Manager', 10, N'Origin Conversions', N'Maintenance', N'Screen', N'i21.view.OriginConversions', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (12, N'Import Origin Users', N'System Manager', 10, N'Import Legacy Users', N'Maintenance', N'Screen', N'i21.view.ImportLegacyUsers', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (13, N'Common Info', N'System Manager', 0, N'Common Info', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 2, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (14, N'Countries', N'System Manager', 13, N'Countries', N'Maintenance', N'Screen', N'i21.view.Country', N'small-menu-maintenance', 0, 0, 0, 1, 0, 1)
		--INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		--VALUES (15, N'Zip Codes', N'System Manager', 13, N'Zip Codes', N'Maintenance', N'Screen', N'i21.view.ZipCode', N'small-menu-maintenance', 0, 0, 0, 1, 1, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (16, N'Currencies', N'System Manager', 13, N'Currencies', N'Maintenance', N'Screen', N'i21.view.Currency', N'small-menu-maintenance', 0, 0, 0, 1, 2, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (17, N'Ship Via', N'System Manager', 13, N'Ship Via', N'Maintenance', N'Screen', N'i21.view.ShipVia', N'small-menu-maintenance', 0, 0, 0, 1, 3, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (18, N'Payment Methods', N'System Manager', 13, N'Payment Methods', N'Maintenance', N'Screen', N'i21.view.PaymentMethod', N'small-menu-maintenance', 0, 0, 0, 1, 4, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (19, N'Terms', N'System Manager', 13, N'Terms', N'Maintenance', N'Screen', N'i21.view.Term', N'small-menu-maintenance', 0, 0, 0, 1, 5, 1)

		/* DASHBOARD */
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (20, N'Dashboard', N'Dashboard', 0, N'Dashboard', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 3, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (21, N'Add Panel', N'Dashboard', 20, N'Add Panel', N'Maintenance', N'Screen', N'Dashboard.view.PanelSettings?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (22, N'Connections', N'Dashboard', 20, N'Connections', N'Maintenance', N'Screen', N'Dashboard.view.Connection', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (23, N'Panels', N'Dashboard', 20, N'Panels', N'Maintenance', N'Screen', N'Dashboard.view.PanelList', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (24, N'Panel Layout', N'Dashboard', 20, N'Panel Layout', N'Maintenance', N'Screen', N'Dashboard.view.PanelLayout', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (25, N'Tabs', N'Dashboard', 20, N'Tabs', N'Maintenance', N'Screen', N'Dashboard.view.TabSetup', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)

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
		VALUES (33, N'Import GL from Subledger', N'General Ledger', 26, N'Import GL from Subledger', N'Activity', N'Screen', N'GeneralLedger.view.ImportFromSubledger', N'small-menu-activity', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (34, N'Import GL from CSV', N'General Ledger', 26, N'Import GL from CSV', N'Activity', N'Screen', N'GeneralLedger.view.ImportFromCSV', N'small-menu-activity', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (35, N'GL Import Logs', N'General Ledger', 26, N'GL Import Logs', N'Activity', N'Screen', N'GeneralLedger.view.ImportLogs', N'small-menu-activity', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (37, N'Chart of Accounts', N'General Ledger', 26, N'Chart of Accounts', N'Maintenance', N'Screen', N'GeneralLedger.view.ChartOfAccounts', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (38, N'Account Structure', N'General Ledger', 26, N'Account Structure', N'Maintenance', N'Screen', N'GeneralLedger.view.AccountStructure', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (39, N'Account Groups', N'General Ledger', 26, N'Account Groups', N'Maintenance', N'Screen', N'GeneralLedger.view.AccountGroups', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (40, N'Segment Accounts', N'General Ledger', 26, N'Segment Accounts', N'Maintenance', N'Screen', N'GeneralLedger.view.SegmentAccounts', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (41, N'Build Accounts', N'General Ledger', 26, N'Build Accounts', N'Maintenance', N'Screen', N'GeneralLedger.view.BuildAccounts', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (43, N'Clone Account', N'General Ledger', 26, N'Clone Account', N'Maintenance', N'Screen', N'GeneralLedger.view.AccountClone', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (44, N'Fiscal Year', N'General Ledger', 26, N'Fiscal Year', N'Maintenance', N'Screen', N'GeneralLedger.view.FiscalYear', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (46, N'Reallocations', N'General Ledger', 26, N'Reallocations', N'Maintenance', N'Screen', N'GeneralLedger.view.Reallocation', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (47, N'Recurring Journals', N'General Ledger', 26, N'Recurring Journals', N'Maintenance', N'Screen', N'GeneralLedger.view.RecurringJournal', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
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
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (61, N'General Ledger By Account ID Detail', N'General Ledger', 26, N'General Ledger By Account ID Detail', N'Report', N'Screen', N'Reporting.view.ReportManager?group=General Ledger&report=GeneralLedgerByAccountDetail&direct=true&showCriteria=true', N'small-menu-report', 0, 0, 0, 1, NULL, 1)
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
		VALUES (68, N'Customer Inquiry', N'Tank Management', 66, N'Customer Inquiry', N'Activity', N'Screen', N'TankManagement.view.CustomerInquiry?showSearch=true', N'small-menu-activity', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (69, N'Consumption Sites', N'Tank Management', 66, N'Consumption Sites', N'Activity', N'Screen', N'TankManagement.view.ConsumptionSite?showSearch=true', N'small-menu-activity', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (70, N'Clock Reading', N'Tank Management', 66, N'Clock Reading', N'Activity', N'Screen', N'TankManagement.view.ClockReading?showSearch=true', N'small-menu-activity', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (71, N'Synchronize Delivery History', N'Tank Management', 66, N'Synchronize Delivery History', N'Activity', N'Screen', N'TankManagement.view.SyncDeliveryHistory', N'small-menu-activity', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (72, N'Lease Billing', N'Tank Management', 66, N'Lease Billing', N'Activity', N'Screen', N'TankManagement.view.LeaseBilling', N'small-menu-activity', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (73, N'Dispatch Deliveries', N'Tank Management', 66, N'Dispatch Deliveries', N'Activity', N'Screen', N'TankManagement.view.DispatchDelivery', N'small-menu-activity', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (75, N'Degree Day Clock', N'Tank Management', 66, N'Degree Day Clock', N'Maintenance', N'Screen', N'TankManagement.view.DegreeDayClock', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (76, N'Devices', N'Tank Management', 66, N'Devices', N'Maintenance', N'Screen', N'TankManagement.view.Device?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (77, N'Events', N'Tank Management', 66, N'Events', N'Maintenance', N'Screen', N'TankManagement.view.Event?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (78, N'Event Types', N'Tank Management', 66, N'Event Types', N'Maintenance', N'Screen', N'TankManagement.view.EventType', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (79, N'Device Types', N'Tank Management', 66, N'Device Types', N'Maintenance', N'Screen', N'TankManagement.view.DeviceType', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (80, N'Lease Codes', N'Tank Management', 66, N'Lease Codes', N'Maintenance', N'Screen', N'TankManagement.view.LeaseCode', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (81, N'Event Automation', N'Tank Management', 66, N'Event Automation', N'Maintenance', N'Screen', N'TankManagement.view.EventAutomation', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (82, N'Meter Types', N'Tank Management', 66, N'Meter Types', N'Maintenance', N'Screen', N'TankManagement.view.MeterType', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (83, N'Renew Julian Deliveries', N'Tank Management', 66, N'Renew Julian Deliveries', N'Maintenance', N'Screen', N'TankManagement.view.RenewJulianDelivery', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (84, N'Resolve Sync Conflict', N'Tank Management', 66, N'Resolve Sync Conflict', N'Maintenance', N'Screen', N'TankManagement.view.ResolveSyncConflict', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (85, N'Lease Billing Incentive', N'Tank Management', 66, N'Lease Billing Incentive', N'Maintenance', N'Screen', N'TankManagement.view.LeaseBillingMinimum', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (87, N'Delivery Fill Report', N'Tank Management', 66, N'Delivery Fill Report', N'Report', N'Screen', N'TankManagement.view.DeliveryFillReportParameter', N'small-menu-report', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (88, N'Two-Part Delivery Fill Report', N'Tank Management', 66, N'Two-Part Delivery Fill Report', N'Report', N'Report', N'Two-Part Delivery Fill Report', N'small-menu-report', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (89, N'Lease Billing Report', N'Tank Management', 66, N'Lease Billing Report', N'Report', N'Report', N'Lease Billing Report', N'small-menu-report', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (90, N'Missed Julian Deliveries', N'Tank Management', 66, N'Missed Julian Deliveries', N'Report', N'Report', N'Missed Julian Deliveries', N'small-menu-report', 0, 0, 0, 1, NULL, 1)
		--INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		--VALUES (91, N'Out of Range Burn Rates', N'Tank Management', 66, N'Out of Range Burn Rates', N'Report', N'Report', N'Out of Range Burn Rates', N'small-menu-report', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (92, N'Call Entry Printout', N'Tank Management', 66, N'Call Entry Printout', N'Report', N'Screen', N'TankManagement.view.CallEntryParameter', N'small-menu-report', 0, 0, 0, 1, NULL, 1)
		--INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		--VALUES (93, N'Fill Group', N'Tank Management', 66, N'Fill Group', N'Report', N'Report', N'Fill Group', N'small-menu-report', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (94, N'Tank Inventory', N'Tank Management', 66, N'Tank Inventory', N'Report', N'Report', N'Tank Inventory', N'small-menu-report', 0, 0, 0, 1, NULL, 1)
		--INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		--VALUES (95, N'Customer List by Route', N'Tank Management', 66, N'Customer List by Route', N'Report', N'Report', N'Customer List by Route', N'small-menu-report', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (96, N'Device Actions', N'Tank Management', 66, N'Device Actions', N'Report', N'Report', N'Device Actions', N'small-menu-report', 0, 0, 0, 1, NULL, 1)
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
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (105, N'Miscellaneous Checks', N'Cash Management', 100, N'Miscellaneous Checks', N'Activity', N'Screen', N'CashManagement.view.MiscellaneousChecks?showSearch=true', N'small-menu-activity', 0, 0, 0, 1, NULL, 1)
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
		VALUES (112, N'Purchasing (Accounts Payable)', N'Accounts Payable', 0, N'Purchasing (Accounts Payable)', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 9, 1)
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
		VALUES (120, N'Import Bills from Origin', N'Accounts Payable', 112, N'Import Bills from Origin', N'Activity', N'Screen', N'AccountsPayable.view.ImportAPInvoice', N'small-menu-activity', 0, 0, 0, 1, 3, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (122, N'Vendors', N'Accounts Payable', 112, N'Vendors', N'Maintenance', N'Screen', N'AccountsPayable.view.EntityVendor?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (125, N'Open Payables', N'Accounts Payable', 112, N'Open Payables', N'Report', N'Screen', N'Reporting.view.ReportManager?group=Purchasing&report=OpenPayables&direct=true&showCriteria=true', N'small-menu-report', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (126, N'Vendor History', N'Accounts Payable', 112, N'Vendor History', N'Report', N'Report', N'Vendor History', N'small-menu-report', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (127, N'Cash Requirements', N'Accounts Payable', 112, N'Cash Requirements', N'Report', N'Report', N'Cash Requirements', N'small-menu-report', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (129, N'Check Register', N'Accounts Payable', 112, N'Check Register', N'Report', N'Report', N'Check Register', N'small-menu-report', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (130, N'AP Transactions By GL Account', N'Accounts Payable', 112, N'AP Transactions By GL Account', N'Report', N'Screen', N'Reporting.view.ReportManager?group=Purchasing&report=APTransactionByGLAccount&direct=true', N'small-menu-report', 0, 0, 0, 1, NULL, 1)

		/* ACCOUNTS RECEIVABLE */
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (131, N'Sales (Accounts Receivable)', N'Accounts Receivable', 0, N'Sales (Accounts Receivable)', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 10, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (134, N'Customers', N'Accounts Receivable', 131, N'Customers', N'Maintenance', N'Screen', N'EntityManagement.view.Entity?showSearch=true&searchCommand=searchEntityCustomer', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (135, N'Customer Contact List', N'Accounts Receivable', 131, N'Customer Contact List', N'Maintenance', N'Screen', N'AccountsReceivable.view.CustomerContactList', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (136, N'Sales Reps', N'Accounts Receivable', 131, N'Sales Reps', N'Maintenance', N'Screen', N'EntityManagement.view.Entity?showSearch=true&searchCommand=searchEntitySalesperson', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (137, N'Market Zone', N'Accounts Receivable', 131, N'Market Zone', N'Maintenance', N'Screen', N'AccountsReceivable.view.MarketZone', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
		/* WILL BE RENAME FROM Statement Footer Messages TO COMMENT MAINTENANCE */
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (138, N'Statement Footer Messages', N'Accounts Receivable', 131, N'Statement Footer Messages', N'Maintenance', N'Screen', N'AccountsReceivable.view.StatementFooterMessage', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
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
		VALUES (152, N'Ticket Job Codes', N'Help Desk', 141, N'Ticket Job Codes', N'Maintenance', N'Screen', N'HelpDesk.view.TicketJobCode', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (153, N'Products', N'Help Desk', 141, N'Products', N'Maintenance', N'Screen', N'HelpDesk.view.Product?showSearch=true&searchCommand=Product', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (154, N'Help Desk Settings', N'Help Desk', 141, N'Help Desk Settings', N'Maintenance', N'Screen', N'HelpDesk.view.HelpDeskSettings', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (155, N'Email Setup', N'Help Desk', 141, N'Email Setup', N'Maintenance', N'Screen', N'HelpDesk.view.HelpDeskEmailSetup', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)

		SET IDENTITY_INSERT [dbo].[tblSMMasterMenu] OFF

	END
GO

/* SYSTEM MANAGER */
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'System Manager' AND strModuleName = N'System Manager' AND intParentMenuID = 0)
UPDATE tblSMMasterMenu SET intSort = 1 WHERE strMenuName = N'System Manager' AND strModuleName = N'System Manager' AND intParentMenuID = 0

DECLARE @SystemManagerParentMenuId INT
SELECT @SystemManagerParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'System Manager' AND strModuleName = 'System Manager' AND intParentMenuID = 0

/* CATEGORY FOLDERS */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Maintenance', N'System Manager', @SystemManagerParentMenuId, N'Maintenance', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 0 WHERE strMenuName = 'Maintenance' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerParentMenuId

DECLARE @SystemManagerMaintenanceParentMenuId INT
SELECT @SystemManagerMaintenanceParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerParentMenuId

/* ADD TO RESPECTIVE CATEGORY */
UPDATE tblSMMasterMenu SET intParentMenuID = @SystemManagerMaintenanceParentMenuId WHERE intParentMenuID =  @SystemManagerParentMenuId AND strCategory = 'Maintenance'

/* START OF RENAMING  */
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'User Security' AND strModuleName = N'System Manager' AND intParentMenuID = @SystemManagerMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = N'Users', strDescription = N'Users' WHERE strMenuName = N'User Security' AND strModuleName = N'System Manager' AND intParentMenuID = @SystemManagerMaintenanceParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Company Preferences' AND strModuleName = N'System Manager' AND intParentMenuID = @SystemManagerMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = N'Company Configuration', intSort = 5 WHERE strMenuName = N'Company Preferences' AND strModuleName = N'System Manager' AND intParentMenuID = @SystemManagerMaintenanceParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Screen Designer' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = N'Custom Tab Designer', intSort = 16 WHERE strMenuName = 'Screen Designer' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerMaintenanceParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Emails' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = N'Email History' WHERE strMenuName = 'Emails' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerMaintenanceParentMenuId
/* END OF RENAMING  */

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Users' AND strModuleName = N'System Manager' AND intParentMenuID = @SystemManagerMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'i21.view.EntityUser?showSearch=true', intSort = 0 WHERE strMenuName = N'Users' AND strModuleName = N'System Manager' AND intParentMenuID = @SystemManagerMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'User Roles' AND strModuleName = N'System Manager' AND intParentMenuID = @SystemManagerMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'i21.view.UserRole?showSearch=true', intSort = 1 WHERE strMenuName = N'User Roles' AND strModuleName = N'System Manager' AND intParentMenuID = @SystemManagerMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Company Configuration' AND strModuleName = N'System Manager' AND intParentMenuID = @SystemManagerMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'i21.view.CompanyPreference', intSort = 2 WHERE strMenuName = N'Company Configuration' AND strModuleName = N'System Manager' AND intParentMenuID = @SystemManagerMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Security Policies' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Security Policies', N'System Manager', @SystemManagerMaintenanceParentMenuId, N'Security Policies', N'Maintenance', N'Screen', N'i21.view.SecurityPolicy?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 3, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'i21.view.SecurityPolicy?showSearch=true', intSort = 3 WHERE strMenuName = 'Security Policies' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Starting Numbers' AND strModuleName = N'System Manager' AND intParentMenuID = @SystemManagerMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'i21.view.StartingNumbers', intSort = 4 WHERE strMenuName = N'Starting Numbers' AND strModuleName = N'System Manager' AND intParentMenuID = @SystemManagerMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Locked Records' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Locked Records', N'System Manager', @SystemManagerMaintenanceParentMenuId, N'Locked Records', N'Maintenance', N'Screen', N'GlobalComponentEngine.view.LockedRecord', N'small-menu-maintenance', 0, 0, 0, 1, 5, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'GlobalComponentEngine.view.LockedRecord', intSort = 5 WHERE strMenuName = 'Locked Records' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Screen Labels' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Screen Labels', N'System Manager', @SystemManagerMaintenanceParentMenuId, N'Screen Labels', N'Maintenance', N'Screen', N'GlobalComponentEngine.view.ScreenLabel', N'small-menu-maintenance', 0, 0, 0, 1, 6, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'GlobalComponentEngine.view.ScreenLabel', intSort = 6 WHERE strMenuName = 'Screen Labels' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Email History' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Email History', N'System Manager', @SystemManagerMaintenanceParentMenuId, N'Email History', N'Maintenance', N'Screen', N'GlobalComponentEngine.view.ActivityEmail?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 7, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'GlobalComponentEngine.view.ActivityEmail?showSearch=true', intSort = 7 WHERE strMenuName = 'Email History' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Letters' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Letters', N'System Manager', @SystemManagerMaintenanceParentMenuId, N'Letters', N'Maintenance', N'Screen', N'i21.view.Letters?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 8, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'i21.view.Letters?showSearch=true', intSort = 8 WHERE strMenuName = 'Letters' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Modules' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Modules', N'System Manager', @SystemManagerMaintenanceParentMenuId, N'Modules', N'Maintenance', N'Screen', N'i21.view.Module', N'small-menu-maintenance', 0, 0, 0, 1, 9, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'i21.view.Module', intSort = 9 WHERE strMenuName = 'Modules' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Custom Tab Designer' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Custom Tab Designer', N'System Manager', @SystemManagerMaintenanceParentMenuId, N'Custom Tab Designer', N'Maintenance', N'Screen', N'GlobalComponentEngine.view.ScreenDesigner?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 10, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'GlobalComponentEngine.view.ScreenDesigner?showSearch=true', intSort = 10 WHERE strMenuName = 'Custom Tab Designer' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Company Registration' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Company Registration', N'System Manager', @SystemManagerMaintenanceParentMenuId, N'Company Registration', N'Maintenance', N'Screen', N'GlobalComponentEngine.view.CompanyRegistration', N'small-menu-maintenance', 0, 0, 0, 1, 11, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'GlobalComponentEngine.view.CompanyRegistration', intSort = 11 WHERE strMenuName = 'Company Registration' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'File Field Mapping' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'File Field Mapping', N'System Manager', @SystemManagerMaintenanceParentMenuId, N'File Field Mapping', N'Maintenance', N'Screen', N'i21.view.FileFieldMapping?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 12, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'i21.view.FileFieldMapping?showSearch=true', intSort = 12 WHERE strMenuName = 'File Field Mapping' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'License Generator' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'License Generator', N'System Manager', @SystemManagerMaintenanceParentMenuId, N'License Generator', N'Maintenance', N'Screen', N'GlobalComponentEngine.view.License?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 13, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'GlobalComponentEngine.view.License?showSearch=true', intSort = 13 WHERE strMenuName = 'License Generator' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'License Types' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'License Types', N'System Manager', @SystemManagerMaintenanceParentMenuId, N'License Types', N'Maintenance', N'Screen', N'GlobalComponentEngine.view.LicenseType', N'small-menu-maintenance', 0, 0, 0, 1, 14, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'GlobalComponentEngine.view.LicenseType', intSort = 14 WHERE strMenuName = 'License Types' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Utilities' AND strModuleName = N'System Manager' AND intParentMenuID = @SystemManagerParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'', intSort = 2 WHERE strMenuName = N'Utilities' AND strModuleName = N'System Manager' AND intParentMenuID = @SystemManagerParentMenuId

DECLARE @UtilitiesParentMenuId INT
SELECT @UtilitiesParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Utilities' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerParentMenuId

/* Change Command from i21.view.OriginConversions to i21.view.OriginConversion */
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Origin Conversions' AND strModuleName = N'System Manager' AND intParentMenuID = @UtilitiesParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'i21.view.OriginConversion' WHERE strMenuName = N'Origin Conversions' AND strModuleName = N'System Manager' AND intParentMenuID = @UtilitiesParentMenuId

/* Start of Remodule*/
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'i21 Updates' AND strModuleName = 'Service Pack' AND intParentMenuID = @UtilitiesParentMenuId)
UPDATE tblSMMasterMenu SET strModuleName = N'System Manager' WHERE strMenuName = 'i21 Updates' AND strModuleName = 'Service Pack' AND intParentMenuID = @UtilitiesParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Announcements' AND strModuleName = N'Help Desk')
UPDATE tblSMMasterMenu SET strModuleName = 'System Manager' WHERE strMenuName = N'Announcements' AND strModuleName = N'Help Desk'
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Announcement Types' AND strModuleName = N'Help Desk')
UPDATE tblSMMasterMenu SET strModuleName = 'System Manager' WHERE strMenuName = N'Announcement Types' AND strModuleName = N'Help Desk'
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Maintenance' AND strModuleName = N'Help Desk' AND strDescription = 'Announcement Maintenance')
UPDATE tblSMMasterMenu SET strModuleName = 'System Manager' WHERE strMenuName = N'Maintenance' AND strModuleName = N'Help Desk' AND strDescription = 'Announcement Maintenance'
/* End of Remodule*/

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'File Downloads' AND strModuleName = 'System Manager' AND intParentMenuID = @UtilitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'File Downloads', N'System Manager', @UtilitiesParentMenuId, N'File Downloads', N'Maintenance', N'Screen', N'i21.view.FileDownloads', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'i21.view.FileDownloads' WHERE strMenuName = 'File Downloads' AND strModuleName = 'System Manager' AND intParentMenuID = @UtilitiesParentMenuId

/* Start Move */
DECLARE @CommonInfoMenuId INT
SELECT @CommonInfoMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Common Info' AND strModuleName = 'System Manager' AND intParentMenuID = 0

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Announcements' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoMenuId)
UPDATE tblSMMasterMenu SET intParentMenuID = @SystemManagerParentMenuId WHERE strMenuName = 'Announcements' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoMenuId
/* End Move */

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'i21 Updates' AND strModuleName = 'System Manager' AND intParentMenuID = @UtilitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId])
	VALUES (N'i21 Updates', N'System Manager', @UtilitiesParentMenuId, N'i21 Updates', N'Maintenance', N'Screen', N'ServicePack.view.Patch', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = N'ServicePack.view.Patch' WHERE strMenuName = 'i21 Updates' AND strModuleName = 'System Manager' AND intParentMenuID = @UtilitiesParentMenuId

-- START OF ANNOUNCEMENT
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Announcements' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Announcements', N'System Manager', @SystemManagerParentMenuId, N'Announcements', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 1, 2)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 1 WHERE strMenuName = 'Announcements' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerParentMenuId

DECLARE @AnnouncementsParentMenuId INT
SELECT @AnnouncementsParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Announcements' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Announcement Types' AND strModuleName = 'System Manager' AND intParentMenuID = @AnnouncementsParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Announcement Types', N'System Manager', @AnnouncementsParentMenuId, N'Announcement Types', N'Maintenance', N'Screen', N'i21.view.AnnouncementType', N'small-menu-maintenance', 0, 0, 0, 1, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'i21.view.AnnouncementType' WHERE strMenuName = 'Announcement Types' AND strModuleName = 'System Manager' AND intParentMenuID = @AnnouncementsParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'System Manager' AND intParentMenuID = @AnnouncementsParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Maintenance', N'System Manager', @AnnouncementsParentMenuId, N'Announcement Maintenance', N'Maintenance', N'Screen', N'i21.view.Announcement', N'small-menu-maintenance', 0, 0, 0, 1, 1, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'i21.view.Announcement' WHERE strMenuName = 'Maintenance' AND strModuleName = 'System Manager' AND intParentMenuID = @AnnouncementsParentMenuId

-- END OF ANNOUNCEMENT


/* Start Delete */
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'i21 Updates' AND strModuleName = 'Service Pack' AND intParentMenuID = @UtilitiesParentMenuId)
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'i21 Updates' AND strModuleName = 'Service Pack' AND intParentMenuID = @UtilitiesParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Company Setup' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerMaintenanceParentMenuId)
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Company Setup' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Import Origin Users' AND strModuleName = N'System Manager' AND intParentMenuID = @UtilitiesParentMenuId)
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Import Origin Users' AND strModuleName = N'System Manager' AND intParentMenuID = @UtilitiesParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Import Origin Menus' AND strModuleName = 'System Manager' AND intParentMenuID = @UtilitiesParentMenuId)
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Import Origin Menus' AND strModuleName = 'System Manager' AND intParentMenuID = @UtilitiesParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Custom Fields' AND strModuleName = N'System Manager' AND intParentMenuID = @SystemManagerMaintenanceParentMenuId)
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Custom Fields' AND strModuleName = N'System Manager' AND intParentMenuID = @SystemManagerMaintenanceParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Custom Grid' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerMaintenanceParentMenuId)
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Custom Grid' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Report Manager' AND strModuleName = N'System Manager' AND intParentMenuID = @SystemManagerMaintenanceParentMenuId
/* End Delete */


/* COMMON INFO */
IF EXISTS (SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Common Info' AND strModuleName = 'System Manager')
UPDATE tblSMMasterMenu SET intSort = 2, intParentMenuID = 0 FROM tblSMMasterMenu WHERE strMenuName = 'Common Info' AND strModuleName = 'System Manager'

DECLARE @CommonInfoParentMenuId INT
SELECT @CommonInfoParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Common Info' AND strModuleName = 'System Manager' AND intParentMenuID = 0

/* CATEGORY FOLDERS */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Maintenance', N'System Manager', @CommonInfoParentMenuId, N'Maintenance', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 0 WHERE strMenuName = 'Maintenance' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId

DECLARE @CommonInfoMaintenanceParentMenuId INT
SELECT @CommonInfoMaintenanceParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId

/* ADD TO RESPECTIVE CATEGORY */
UPDATE tblSMMasterMenu SET intParentMenuID = @CommonInfoMaintenanceParentMenuId WHERE intParentMenuID =  @CommonInfoParentMenuId AND strCategory = 'Maintenance'

/* START OF PLURALIZING */
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Country' AND strModuleName = N'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Countries', strDescription = 'Countries' WHERE strMenuName = N'Country' AND strModuleName = N'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Zip Code' AND strModuleName = N'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Zip Codes', strDescription = 'Zip Codes' WHERE strMenuName = N'Zip Code' AND strModuleName = N'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Currency' AND strModuleName = N'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Currencies', strDescription = 'Currencies' WHERE strMenuName = N'Currency' AND strModuleName = N'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Company Location' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Company Locations', strDescription = 'Company Locations' WHERE strMenuName = 'Company Location' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId

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

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Document Messages' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = N'Report Messages', strDescription = N'Report Messages' WHERE strMenuName = 'Document Messages' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId
/* END OF RENAMING  */

/* Start Move */
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Motor Fuel Tax Cycle' AND strModuleName = N'System Manager' AND intParentMenuID = @SystemManagerParentMenuId)
UPDATE tblSMMasterMenu SET intParentMenuID = @CommonInfoMaintenanceParentMenuId, intSort = 20 WHERE strMenuName = N'Motor Fuel Tax Cycle' AND strModuleName = N'System Manager' AND intParentMenuID = @SystemManagerParentMenuId
/* End Move */

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Company Locations' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId])
	VALUES (N'Company Locations', N'System Manager', @CommonInfoMaintenanceParentMenuId, N'Company Locations', N'Maintenance', N'Screen', N'i21.view.CompanyLocation?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 1, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'i21.view.CompanyLocation?showSearch=true', intSort = 1 WHERE strMenuName = 'Company Locations' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Recurring Transactions' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Recurring Transactions', N'System Manager', @CommonInfoMaintenanceParentMenuId, N'Recurring Transactions', N'Maintenance', N'Screen', N'i21.view.RecurringTransaction', N'small-menu-maintenance', 0, 0, 0, 1, 2, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'i21.view.RecurringTransaction', intSort = 2 WHERE strMenuName = 'Recurring Transactions' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Batch Posting' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Batch Posting', N'System Manager', @CommonInfoMaintenanceParentMenuId, N'Batch Posting', N'Maintenance', N'Screen', N'i21.view.BatchPosting', N'small-menu-maintenance', 0, 0, 0, 1, 3, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'i21.view.BatchPosting', intSort = 3 WHERE strMenuName = 'Batch Posting' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Approvals' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Approvals', N'System Manager', @CommonInfoMaintenanceParentMenuId, N'Approvals', N'Maintenance', N'Screen', N'i21.view.Approval', N'small-menu-maintenance', 0, 0, 0, 1, 4, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = N'i21.view.Approval', intSort = 4 WHERE strMenuName = 'Approvals' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Approval List' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Approval List', N'System Manager', @CommonInfoMaintenanceParentMenuId, N'Approval List', N'Maintenance', N'Screen', N'i21.view.ApprovalList?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 5, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'i21.view.ApprovalList?showSearch=true', intSort = 5 WHERE strMenuName = 'Approval List' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Approver Configuration' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Approver Configuration', N'System Manager', @CommonInfoMaintenanceParentMenuId, N'Approver Configuration', N'Maintenance', N'Screen', N'i21.view.ApproverConfiguration?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 6, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'i21.view.ApproverConfiguration?showSearch=true', intSort = 6 WHERE strMenuName = 'Approver Configuration' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Approver Groups' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Approver Groups', N'System Manager', @CommonInfoMaintenanceParentMenuId, N'Approver Groups', N'Maintenance', N'Screen', N'i21.view.ApproverGroup?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 7, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = N'i21.view.ApproverGroup?showSearch=true', intSort = 7 WHERE strMenuName = 'Approver Groups' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Entity Group' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Entity Group', N'System Manager', @CommonInfoMaintenanceParentMenuId, N'Entity Group', N'Maintenance', N'Screen', N'EntityManagement.view.EntityGroup?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 8, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = N'EntityManagement.view.EntityGroup?showSearch=true', intSort = 8 WHERE strMenuName = 'Entity Group' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Lines of Business' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Lines of Business', N'System Manager', @CommonInfoMaintenanceParentMenuId, N'Lines of Business', N'Maintenance', N'Screen', N'i21.view.LineOfBusiness', N'small-menu-maintenance', 0, 0, 0, 1, 9, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = N'i21.view.LineOfBusiness', intSort = 9 WHERE strMenuName = 'Lines of Business' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Terms' AND strModuleName = N'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'i21.view.Term', intSort = 10 WHERE strMenuName = N'Terms' AND strModuleName = N'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Freight Terms' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Freight Terms', N'System Manager', @CommonInfoMaintenanceParentMenuId, N'Freight Terms', N'Maintenance', N'Screen', N'i21.view.FreightTerms', N'small-menu-maintenance', 0, 0, 0, 1, 11, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'i21.view.FreightTerms', intSort = 11 WHERE strMenuName = 'Freight Terms' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Ship Via' AND strModuleName = N'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'i21.view.EntityShipVia?showSearch=true', intSort = 12 WHERE strMenuName = N'Ship Via' AND strModuleName = N'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Payment Methods' AND strModuleName = N'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'i21.view.PaymentMethod', intSort = 13 WHERE strMenuName = N'Payment Methods' AND strModuleName = N'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Cities' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Cities', N'System Manager', @CommonInfoMaintenanceParentMenuId, N'Cities', N'Maintenance', N'Screen', N'i21.view.City', N'small-menu-maintenance', 0, 0, 0, 1, 14, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'i21.view.City', intSort = 14 WHERE strMenuName = 'Cities' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Zip Codes' AND strModuleName = N'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'i21.view.ZipCode', intSort = 15 WHERE strMenuName = N'Zip Codes' AND strModuleName = N'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Countries' AND strModuleName = N'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'i21.view.Country', intSort = 16 WHERE strMenuName = N'Countries' AND strModuleName = N'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Tax Class' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Tax Class', N'System Manager', @CommonInfoMaintenanceParentMenuId, N'Tax Class', N'Maintenance', N'Screen', N'i21.view.TaxClass', N'small-menu-maintenance', 0, 0, 0, 1, 17, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'i21.view.TaxClass', intSort = 17 WHERE strMenuName = 'Tax Class' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Tax Codes' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Tax Codes', N'System Manager', @CommonInfoMaintenanceParentMenuId, N'Tax Codes', N'Maintenance', N'Screen', N'i21.view.TaxCode?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 18, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'i21.view.TaxCode?showSearch=true', intSort = 18 WHERE strMenuName = 'Tax Codes' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Tax Groups' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Tax Groups', N'System Manager', @CommonInfoMaintenanceParentMenuId, N'Tax Groups', N'Maintenance', N'Screen', N'i21.view.TaxGroup?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 19, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'i21.view.TaxGroup?showSearch=true', intSort = 19 WHERE strMenuName = 'Tax Groups' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Purchasing Groups' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Purchasing Groups', N'System Manager', @CommonInfoMaintenanceParentMenuId, N'Purchasing Groups', N'Maintenance', N'Screen', N'i21.view.PurchasingGroup', N'small-menu-maintenance', 0, 0, 0, 1, 20, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = N'i21.view.PurchasingGroup', intSort = 20 WHERE strMenuName = 'Purchasing Groups' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Calendar' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Calendar', N'System Manager', @CommonInfoMaintenanceParentMenuId, N'Calendar', N'Maintenance', N'Screen', N'#calendar', N'small-menu-maintenance', 0, 0, 0, 1, 21, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = '#calendar', intSort = 21 WHERE strMenuName = 'Calendar' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Motor Fuel Tax Cycle' AND strModuleName = N'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = 'Reports.controller.RunTaxCycle', intSort = 22 WHERE strMenuName = N'Motor Fuel Tax Cycle' AND strModuleName = N'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Currencies' AND strModuleName = N'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'i21.view.Currency', intSort = 23 WHERE strMenuName = N'Currencies' AND strModuleName = N'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Currency Exchange Rates' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Currency Exchange Rates', N'System Manager', @CommonInfoMaintenanceParentMenuId, N'Currency Exchange Rates', N'Maintenance', N'Screen', N'i21.view.CurrencyExchangeRate', N'small-menu-maintenance', 0, 0, 0, 1, 24, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'i21.view.CurrencyExchangeRate', intSort = 24 WHERE strMenuName = 'Currency Exchange Rates' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Currency Exchange Rate Types' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Currency Exchange Rate Types', N'System Manager', @CommonInfoMaintenanceParentMenuId, N'Currency Exchange Rate Types', N'Maintenance', N'Screen', N'i21.view.CurrencyExchangeRateType', N'small-menu-maintenance', 0, 0, 0, 1, 25, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'i21.view.CurrencyExchangeRateType', intSort = 25 WHERE strMenuName = 'Currency Exchange Rate Types' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Veterinary' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Veterinary', N'System Manager', @CommonInfoMaintenanceParentMenuId, N'Veterinary', N'Maintenance', N'Screen', N'EntityManagement.view.EntityVeterinary?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 26, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = N'EntityManagement.view.EntityVeterinary?showSearch=true', intSort = 26 WHERE strMenuName = 'Veterinary' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Report Messages' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Report Messages', N'System Manager', @CommonInfoMaintenanceParentMenuId, N'Report Messages', N'Maintenance', N'Screen', N'i21.view.DocumentMaintenance?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 27, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = N'i21.view.DocumentMaintenance?showSearch=true', intSort = 27 WHERE strMenuName = 'Report Messages' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId

/* Start Delete */
--DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Freight Terms' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Reminder List' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Tax Group Masters' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'User Preferences' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Zip Codes' AND strModuleName = N'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Tax Type' AND strModuleName = N'System Manager' AND intParentMenuID = @CommonInfoMaintenanceParentMenuId 
/* END OF DELETING */

/* DASHBOARD */
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Dashboard' AND strModuleName = 'Dashboard' AND intParentMenuID = 0)
UPDATE tblSMMasterMenu SET intSort = 3 WHERE strMenuName = 'Dashboard' AND strModuleName = 'Dashboard' AND intParentMenuID = 0

DECLARE @DashboardParentMenuId INT
SELECT @DashboardParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Dashboard' AND strModuleName = 'Dashboard' AND intParentMenuID = 0

/* CATEGORY FOLDERS */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'Dashboard' AND intParentMenuID = @DashboardParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Maintenance', N'Dashboard', @DashboardParentMenuId, N'Maintenance', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 0 WHERE strMenuName = 'Maintenance' AND strModuleName = 'Dashboard' AND intParentMenuID = @DashboardParentMenuId

DECLARE @DashboardMaintenanceParentMenuId INT
SELECT @DashboardMaintenanceParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'Dashboard' AND intParentMenuID = @DashboardParentMenuId

/* ADD TO RESPECTIVE CATEGORY */ 
UPDATE tblSMMasterMenu SET intParentMenuID = @DashboardMaintenanceParentMenuId WHERE intParentMenuID =  @DashboardParentMenuId AND strCategory = 'Maintenance'

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Display Dashboard' AND strModuleName = 'Dashboard' AND intParentMenuID = @DashboardMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Display Dashboard', N'Dashboard', @DashboardMaintenanceParentMenuId, N'Display Dashboard', N'Maintenance', N'Home', N'', N'small-menu-maintenance', 0, 0, 0, 1, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET strIcon = 'small-menu-dashboard' WHERE strMenuName = 'Display Dashboard' AND strModuleName = 'Dashboard' AND intParentMenuID = @DashboardMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Connections' AND strModuleName = N'Dashboard' AND intParentMenuID = @DashboardMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 2, strCommand = N'Dashboard.view.Connection' WHERE strMenuName = N'Connections' AND strModuleName = N'Dashboard' AND intParentMenuID = @DashboardMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Panels' AND strModuleName = N'Dashboard' AND intParentMenuID = @DashboardMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 3, strCommand = N'Dashboard.view.PanelSettings?showSearch=true' WHERE strMenuName = N'Panels' AND strModuleName = N'Dashboard' AND intParentMenuID = @DashboardMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Panel Layout' AND strModuleName = N'Dashboard' AND intParentMenuID = @DashboardMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 4, strCommand = N'Dashboard.view.PanelLayout' WHERE strMenuName = N'Panel Layout' AND strModuleName = N'Dashboard' AND intParentMenuID = @DashboardMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Tabs' AND strModuleName = N'Dashboard' AND intParentMenuID = @DashboardMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 5, strCommand = N'Dashboard.view.TabSetup' WHERE strMenuName = N'Tabs' AND strModuleName = N'Dashboard' AND intParentMenuID = @DashboardMaintenanceParentMenuId

/* START OF DELETING */
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Add Panel' AND strModuleName = N'Dashboard' AND intParentMenuID = @DashboardMaintenanceParentMenuId
/* END OF DELETING */

/* GENERAL LEDGER */
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'General Ledger' AND strModuleName = 'General Ledger' AND intParentMenuID = 0)
UPDATE tblSMMasterMenu SET intSort = 4 WHERE strMenuName = 'General Ledger' AND strModuleName = 'General Ledger' AND intParentMenuID = 0

DECLARE @GeneralLedgerParentMenuId INT
SELECT @GeneralLedgerParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'General Ledger' AND strModuleName = 'General Ledger' AND intParentMenuID = 0

/* CATEGORY FOLDERS */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Activities' AND strModuleName = 'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Activities', N'General Ledger', @GeneralLedgerParentMenuId, N'Activities', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 0 WHERE strMenuName = 'Activities' AND strModuleName = 'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId

DECLARE @GeneralLedgerActivitiesParentMenuId INT
SELECT @GeneralLedgerActivitiesParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Activities' AND strModuleName = 'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Maintenance', N'General Ledger', @GeneralLedgerParentMenuId, N'Maintenance', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 1, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 1 WHERE strMenuName = 'Maintenance' AND strModuleName = 'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId

DECLARE @GeneralLedgerMaintenanceParentMenuId INT
SELECT @GeneralLedgerMaintenanceParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId

/* ADD TO RESPECTIVE CATEGORY */ 
UPDATE tblSMMasterMenu SET intParentMenuID = @GeneralLedgerActivitiesParentMenuId WHERE intParentMenuID =  @GeneralLedgerParentMenuId AND strCategory = 'Activity'
UPDATE tblSMMasterMenu SET intParentMenuID = @GeneralLedgerMaintenanceParentMenuId WHERE intParentMenuID =  @GeneralLedgerParentMenuId AND strCategory = 'Maintenance'

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Reports' AND strModuleName = 'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Reports', N'General Ledger', @GeneralLedgerParentMenuId, N'Reports', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 2, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 2 WHERE strMenuName = 'Reports' AND strModuleName = 'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId

DECLARE @GeneralLedgerReportParentMenuId INT
SELECT @GeneralLedgerReportParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Reports' AND strModuleName = 'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId

/* START OF PLURALIZING */
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'General Journal' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerActivitiesParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'General Journals', strDescription = 'General Journals' WHERE strMenuName = N'General Journal' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerActivitiesParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Import Budget from CSV' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerActivitiesParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Import Budgets from CSV', strDescription = 'Import Budgets from CSV' WHERE strMenuName = N'Import Budget from CSV' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerActivitiesParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Reallocation' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerMaintenanceParentMenuId and strCategory = 'Maintenance')
UPDATE tblSMMasterMenu SET strMenuName = 'Reallocations', strDescription = 'Reallocations' WHERE strMenuName = N'Reallocation' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerMaintenanceParentMenuId and strCategory = 'Maintenance'

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Recurring Journal' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Recurring Journals', strDescription = 'Recurring Journals' WHERE strMenuName = N'Recurring Journal' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerMaintenanceParentMenuId
/* END OF PLURALIZING */

/* Start of moving report */
UPDATE tblSMMasterMenu SET intParentMenuID = @GeneralLedgerReportParentMenuId WHERE strMenuName = 'Reallocation' AND strModuleName = 'General Ledger' AND strType = 'Report' AND intParentMenuID = @GeneralLedgerParentMenuId
UPDATE tblSMMasterMenu SET intParentMenuID = @GeneralLedgerReportParentMenuId WHERE strMenuName = 'General Ledger By Account ID Detail' AND strModuleName = 'General Ledger' AND strType IN ('Report', 'Screen') AND intParentMenuID = @GeneralLedgerParentMenuId
UPDATE tblSMMasterMenu SET intParentMenuID = @GeneralLedgerReportParentMenuId WHERE strMenuName = 'Trial Balance Detail' AND strModuleName = 'General Ledger' AND strType IN ('Report', 'Screen') AND intParentMenuID = @GeneralLedgerParentMenuId
/* End of moving report */

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'General Journals' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerActivitiesParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 1, strCommand = N'GeneralLedger.view.GeneralJournal?showSearch=true' WHERE strMenuName = N'General Journals' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerActivitiesParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'GL Account Detail' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerActivitiesParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 2, strCommand = N'GeneralLedger.view.GLAccountDetail?showSearch=true' WHERE strMenuName = N'GL Account Detail' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerActivitiesParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Batch Posting' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerActivitiesParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 3, strCommand = N'i21.view.BatchPosting?module=General Ledger' WHERE strMenuName = N'Batch Posting' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerActivitiesParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Import GL from Subledger' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerActivitiesParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 4, strCommand = N'GeneralLedger.view.ImportFromSubledger' WHERE strMenuName = N'Import GL from Subledger' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerActivitiesParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Import GL from CSV' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerActivitiesParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 5, strCommand = N'GeneralLedger.view.ImportFromCSV' WHERE strMenuName = N'Import GL from CSV' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerActivitiesParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'GL Import Logs' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 6, strCommand = N'GeneralLedger.view.ImportLogs?showSearch=true' WHERE strMenuName = N'GL Import Logs' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Origin Audit Log' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Origin Audit Log', N'General Ledger', @GeneralLedgerActivitiesParentMenuId, N'Origin Audit Log', N'Activity', N'Screen', N'GeneralLedger.view.OriginAuditLog', N'small-menu-activity', 0, 0, 0, 1, 7, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 7, strCommand = N'GeneralLedger.view.OriginAuditLog' WHERE strMenuName = N'Origin Audit Log' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerActivitiesParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Fiscal Year' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 8, strCommand = N'GeneralLedger.view.FiscalYear?showSearch=true' WHERE strMenuName = N'Fiscal Year' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Reallocations' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerMaintenanceParentMenuId and strCategory = 'Maintenance')
UPDATE tblSMMasterMenu SET intSort = 9, strCommand = N'GeneralLedger.view.Reallocation?showSearch=true' WHERE strMenuName = N'Reallocations' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerMaintenanceParentMenuId and strCategory = 'Maintenance'

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Revalue Currency' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Revalue Currency', N'General Ledger', @GeneralLedgerActivitiesParentMenuId, N'Revalue Currency', N'Activity', N'Screen', N'GeneralLedger.view.RevalueCurrency', N'small-menu-activity', 0, 0, 0, 1, 10, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 10, strCommand = N'GeneralLedger.view.RevalueCurrency?showSearch=true' WHERE strMenuName = N'Revalue Currency' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Consolidate' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Consolidate', N'General Ledger', @GeneralLedgerActivitiesParentMenuId, N'Consolidate', N'Activity', N'Screen', N'GeneralLedger.view.Consolidate', N'small-menu-activity', 0, 0, 0, 1, 11, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 11, strCommand = N'GeneralLedger.view.Consolidate' WHERE strMenuName = N'Consolidate' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerActivitiesParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'General Ledger By Account ID Detail' AND strModuleName ='General Ledger' AND intParentMenuID = @GeneralLedgerReportParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 1, strCommand = N'Reporting.view.ReportManager?group=General Ledger&report=GeneralLedgerByAccountDetail&direct=true&showCriteria=true', strType = 'Screen' WHERE strMenuName = 'General Ledger By Account ID Detail' AND strModuleName ='General Ledger' AND intParentMenuID = @GeneralLedgerReportParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Trial Balance Detail' AND strModuleName ='General Ledger' AND intParentMenuID = @GeneralLedgerReportParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 2, strCommand = N'Reporting.view.ReportManager?group=General Ledger&report=TrialBalanceDetail&direct=true&showCriteria=true', strType = 'Screen' WHERE strMenuName = 'Trial Balance Detail' AND strModuleName ='General Ledger' AND intParentMenuID = @GeneralLedgerReportParentMenuId

/* START OF DELETING */
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Account Structure' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Account Groups' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Segment Accounts' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Build Accounts' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Import Budgets from CSV' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerActivitiesParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Recurring Journals' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Recurring Journal History' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Balance Sheet Standard' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Income Statement Standard' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Trial Balance' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Reminder List' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerActivitiesParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Chart of Accounts' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId AND strCategory = 'Report'
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Chart of Accounts' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerMaintenanceParentMenuId AND strCategory = 'Maintenance'
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Clone Account' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Chart of Accounts Adjustment' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId AND strCategory = 'Report'
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Reallocation' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerReportParentMenuId AND strCategory = 'Report'
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Trial Balance Detail New' AND strModuleName = 'General Ledger'
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'General Ledger By Account ID Detail New' AND strModuleName = 'General Ledger'
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Account Adjustment' AND strModuleName ='General Ledger' AND intParentMenuID = @GeneralLedgerActivitiesParentMenuId
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

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Financial Report Builder' AND strModuleName = N'Financial Report Designer' AND intParentMenuID = @FinancialReportsMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'FinancialReportDesigner.view.ReportBuilder?showSearch=true' WHERE strMenuName = N'Financial Report Builder' AND strModuleName = N'Financial Report Designer' AND intParentMenuID = @FinancialReportsMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Report Templates' AND strModuleName = N'Financial Report Designer' AND intParentMenuID = @FinancialReportsMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'FinancialReportDesigner.view.Templates' WHERE strMenuName = N'Report Templates' AND strModuleName = N'Financial Report Designer' AND intParentMenuID = @FinancialReportsMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Financial Report Group' AND strModuleName = 'Financial Report Designer' AND intParentMenuID = @FinancialReportsMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Financial Report Group', N'Financial Report Designer', @FinancialReportsMaintenanceParentMenuId, N'Financial Report Group', N'Maintenance', N'Screen', N'FinancialReportDesigner.view.FinancialReportGroup?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'FinancialReportDesigner.view.FinancialReportGroup?showSearch=true' WHERE strMenuName = 'Financial Report Group' AND strModuleName = 'Financial Report Designer' AND intParentMenuID = @FinancialReportsMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Budget' AND strModuleName = 'Financial Report Designer' AND intParentMenuID = @FinancialReportsMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Budget', N'Financial Report Designer', @FinancialReportsMaintenanceParentMenuId, N'Budget', N'Maintenance', N'Screen', N'FinancialReportDesigner.view.Budget?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = N'FinancialReportDesigner.view.Budget?showSearch=true' WHERE strMenuName = 'Budget' AND strModuleName = 'Financial Report Designer' AND intParentMenuID = @FinancialReportsMaintenanceParentMenuId

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

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Miscellaneous Checks' AND strModuleName = N'Cash Management' AND intParentMenuID = @CashManagementActivitiesParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 4, strCommand = N'CashManagement.view.MiscellaneousChecks?showSearch=true' WHERE strMenuName = N'Miscellaneous Checks' AND strModuleName = N'Cash Management' AND intParentMenuID = @CashManagementActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Batch Posting' AND strModuleName = 'Cash Management' AND intParentMenuID = @CashManagementActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Batch Posting', N'Cash Management', @CashManagementActivitiesParentMenuId, N'Batch Posting', N'Activity', N'Screen', N'i21.view.BatchPosting?module=Cash Management', N'small-menu-activity', 0, 0, 0, 1, 5, 1)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 5, strCommand = N'i21.view.BatchPosting?module=Cash Management' WHERE strMenuName = 'Batch Posting' AND strModuleName = 'Cash Management' AND intParentMenuID = @CashManagementActivitiesParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Bank Account Register' AND strModuleName = N'Cash Management' AND intParentMenuID = @CashManagementActivitiesParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 6, strCommand = N'CashManagement.view.BankAccountRegister' WHERE strMenuName = N'Bank Account Register' AND strModuleName = N'Cash Management' AND intParentMenuID = @CashManagementActivitiesParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Bank Reconciliation' AND strModuleName = N'Cash Management' AND intParentMenuID = @CashManagementActivitiesParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 7, strCommand = N'CashManagement.view.BankReconciliation' WHERE strMenuName = N'Bank Reconciliation' AND strModuleName = N'Cash Management' AND intParentMenuID = @CashManagementActivitiesParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Banks' AND strModuleName = N'Cash Management' AND intParentMenuID = @CashManagementMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 8, strCommand = N'CashManagement.view.Banks?showSearch=true' WHERE strMenuName = N'Banks' AND strModuleName = N'Cash Management' AND intParentMenuID = @CashManagementMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Bank Accounts' AND strModuleName = N'Cash Management' AND intParentMenuID = @CashManagementMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 9, strCommand = N'CashManagement.view.BankAccounts?showSearch=true' WHERE strMenuName = N'Bank Accounts' AND strModuleName = N'Cash Management' AND intParentMenuID = @CashManagementMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Bank File Formats' AND strModuleName = N'Cash Management' AND intParentMenuID = @CashManagementMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 10, strCommand = N'CashManagement.view.BankFileFormat?showSearch=true' WHERE strMenuName = N'Bank File Formats' AND strModuleName = N'Cash Management' AND intParentMenuID = @CashManagementMaintenanceParentMenuId

/* START OF DELETING */
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Positive Pay Export' AND strModuleName = 'Cash Management' AND intParentMenuID = @CashManagementActivitiesParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Bank File Export' AND strModuleName = 'Cash Management' AND intParentMenuID = @CashManagementActivitiesParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Reports' AND strModuleName = 'Cash Management' AND intParentMenuID = @CashManagementActivitiesParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Check Register' AND strModuleName = 'Cash Management'
/* END OF DELETING */

/* CREDIT CARD RECONCILIATION */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Credit Card Reconciliation' AND strModuleName = 'Credit Card Recon' AND intParentMenuID = 0)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Credit Card Reconciliation', N'Credit Card Recon', 0, N'Credit Card Reconciliation', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 7, 0)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 7 WHERE strMenuName = 'Credit Card Reconciliation' AND strModuleName = 'Credit Card Recon' AND intParentMenuID = 0

DECLARE @CreditCardReconParentMenuId INT
SELECT @CreditCardReconParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Credit Card Reconciliation' AND strModuleName = 'Credit Card Recon' AND intParentMenuID = 0

/* CATEGORY FOLDERS */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Activities' AND strModuleName = 'Credit Card Recon' AND intParentMenuID = @CreditCardReconParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Activities', N'Credit Card Recon', @CreditCardReconParentMenuId, N'Activities', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 0 WHERE strMenuName = 'Activities' AND strModuleName = 'Credit Card Recon' AND intParentMenuID = @CreditCardReconParentMenuId

DECLARE @CreditCardReconActivitiesParentMenuId INT
SELECT @CreditCardReconActivitiesParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Activities' AND strModuleName = 'Credit Card Recon' AND intParentMenuID = @CreditCardReconParentMenuId

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

/* ADD TO RESPECTIVE CATEGORY */ 
UPDATE tblSMMasterMenu SET intParentMenuID = @InventoryActivitiesParentMenuId WHERE intParentMenuID =  @InventoryParentMenuId AND strCategory = 'Activity'
UPDATE tblSMMasterMenu SET intParentMenuID = @InventoryMaintenanceParentMenuId WHERE intParentMenuID =  @InventoryParentMenuId AND strCategory = 'Maintenance'

/* START OF PLURALIZING */
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Inventory Receipt' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryActivitiesParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Inventory Receipts', strDescription = 'Inventory Receipts' WHERE strMenuName = 'Inventory Receipt' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryActivitiesParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Inventory Shipment' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryActivitiesParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Inventory Shipments', strDescription = 'Inventory Shipments' WHERE strMenuName = 'Inventory Shipment' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryActivitiesParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Inventory Transfer' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryActivitiesParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Inventory Transfers', strDescription = 'Inventory Transfers' WHERE strMenuName = 'Inventory Transfer' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryActivitiesParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Inventory Adjustment' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryActivitiesParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Inventory Adjustments', strDescription = 'Inventory Adjustments' WHERE strMenuName = 'Inventory Adjustment' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryActivitiesParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Item' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Items', strDescription = 'Items' WHERE strMenuName = 'Item' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Fuel Category' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Fuel Categories', strDescription = 'Fuel Categories' WHERE strMenuName = 'Fuel Category' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Commodity' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Commodities', strDescription = 'Commodities' WHERE strMenuName = 'Commodity' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Fuel Code' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Fuel Codes', strDescription = 'Fuel Codes' WHERE strMenuName = 'Fuel Code' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Category' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Categories', strDescription = 'Categories' WHERE strMenuName = 'Category' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Fuel Type' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Fuel Types', strDescription = 'Fuel Types' WHERE strMenuName = 'Fuel Type' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Inventory Tag' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Inventory Tags', strDescription = 'Inventory Tags' WHERE strMenuName = 'Inventory Tag' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Storage Unit Type' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Storage Unit Types', strDescription = 'Storage Unit Types' WHERE strMenuName = 'Storage Unit Type' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Storage Location' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Storage Locations', strDescription = 'Storage Locations' WHERE strMenuName = 'Storage Location' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Contract Document' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Contract Documents', strDescription = 'Contract Documents' WHERE strMenuName = 'Contract Document' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceParentMenuId
/* END OF PLURALIZING */

/* START OF RENAMING */
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Storage Locations' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = N'Storage Units', strDescription = 'Storage Units' WHERE strMenuName = 'Storage Locations' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceParentMenuId
/* END OF RENAMING */

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Inventory Receipts' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Inventory Receipts', N'Inventory', @InventoryActivitiesParentMenuId, N'Inventory Receipts', N'Activity', N'Screen', N'Inventory.view.InventoryReceipt?showSearch=true', N'small-menu-activity', 1, 1, 0, 1, 1, 0)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Inventory.view.InventoryReceipt?showSearch=true', intSort = 1 WHERE strMenuName = 'Inventory Receipts' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Inventory Shipments' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Inventory Shipments', N'Inventory', @InventoryActivitiesParentMenuId, N'Inventory Shipments', N'Activity', N'Screen', N'Inventory.view.InventoryShipment?showSearch=true', N'small-menu-activity', 1, 1, 0, 1, 2, 0)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Inventory.view.InventoryShipment?showSearch=true', intSort = 2 WHERE strMenuName = 'Inventory Shipments' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Inventory Transfers' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Inventory Transfers', N'Inventory', @InventoryActivitiesParentMenuId, N'Inventory Transfers', N'Activity', N'Screen', N'Inventory.view.InventoryTransfer?showSearch=true', N'small-menu-activity', 1, 1, 0, 1, 3, 0)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Inventory.view.InventoryTransfer?showSearch=true', intSort = 3 WHERE strMenuName = 'Inventory Transfers' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Inventory Adjustments' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId])
	VALUES (N'Inventory Adjustments', N'Inventory', @InventoryActivitiesParentMenuId, N'Inventory Adjustments', N'Activity', N'Screen', N'Inventory.view.InventoryAdjustment?showSearch=true', N'small-menu-activity', 1, 1, 0, 1, 4, 0)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = N'Inventory.view.InventoryAdjustment?showSearch=true', intSort = 4 WHERE strMenuName = 'Inventory Adjustments' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Inventory Count' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId])
	VALUES (N'Inventory Count', N'Inventory', @InventoryActivitiesParentMenuId, N'Inventory Count', N'Activity', N'Screen', N'Inventory.view.InventoryCount?showSearch=true', N'small-menu-activity', 1, 1, 0, 1, 5, 0)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = N'Inventory.view.InventoryCount?showSearch=true', intSort = 5 WHERE strMenuName = 'Inventory Count' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Storage Measurement Reading' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId])
	VALUES (N'Storage Measurement Reading', N'Inventory', @InventoryActivitiesParentMenuId, N'Storage Measurement Reading', N'Activity', N'Screen', N'Inventory.view.StorageMeasurementReading?showSearch=true', N'small-menu-activity', 1, 1, 0, 1, 6, 0)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = N'Inventory.view.StorageMeasurementReading?showSearch=true', intSort = 6 WHERE strMenuName = 'Storage Measurement Reading' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Items' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Items', N'Inventory', @InventoryMaintenanceParentMenuId, N'Items', N'Maintenance', N'Screen', N'Inventory.view.Item', N'small-menu-maintenance?showSearch=true', 1, 1, 0, 1, 7, 0)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Inventory.view.Item?showSearch=true', intSort = 7 WHERE strMenuName = 'Items' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Commodities' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Commodities', N'Inventory', @InventoryMaintenanceParentMenuId, N'Commodities', N'Maintenance', N'Screen', N'Inventory.view.Commodity?showSearch=true', N'small-menu-maintenance', 1, 1, 0, 1, 8, 0)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Inventory.view.Commodity?showSearch=true', intSort = 8 WHERE strMenuName = 'Commodities' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Categories' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Categories', N'Inventory', @InventoryMaintenanceParentMenuId, N'Categories', N'Maintenance', N'Screen', N'Inventory.view.Category?showSearch=true', N'small-menu-maintenance', 1, 1, 0, 1, 9, 0)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Inventory.view.Category?showSearch=true', intSort = 9 WHERE strMenuName = 'Categories' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Fuel Types' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Fuel Types', N'Inventory', @InventoryMaintenanceParentMenuId, N'Fuel Types', N'Maintenance', N'Screen', N'Inventory.view.FuelType?showSearch=true', N'small-menu-maintenance', 1, 1, 0, 1, 10, 0)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Inventory.view.FuelType?showSearch=true', intSort = 10 WHERE strMenuName = 'Fuel Types' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Inventory UOM' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Inventory UOM', N'Inventory', @InventoryMaintenanceParentMenuId, N'Inventory UOM', N'Maintenance', N'Screen', N'Inventory.view.InventoryUOM?showSearch=true', N'small-menu-maintenance', 1, 1, 0, 1, 11, 0)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Inventory.view.InventoryUOM?showSearch=true', intSort = 11 WHERE strMenuName = 'Inventory UOM' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceParentMenuId
	
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Storage Units' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Storage Units', N'Inventory', @InventoryMaintenanceParentMenuId, N'Storage Units', N'Maintenance', N'Screen', N'Inventory.view.StorageUnit?showSearch=true', N'small-menu-maintenance', 1, 1, 0, 1, 12, 0)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Inventory.view.StorageUnit?showSearch=true', intSort = 12 WHERE strMenuName = 'Storage Units' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Stock Details' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Stock Details', N'Inventory', @InventoryMaintenanceParentMenuId, N'Stock Details', N'Maintenance', N'Screen', N'Inventory.view.StockDetail?showSearch=true', N'small-menu-report', 1, 1, 0, 1, 14, 0)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Inventory.view.StockDetail?showSearch=true', intSort = 14, strIcon = 'small-menu-report' WHERE strMenuName = 'Stock Details' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Lot Details' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Lot Details', N'Inventory', @InventoryMaintenanceParentMenuId, N'Lot Details', N'Maintenance', N'Screen', N'Inventory.view.LotDetail?showSearch=true', N'small-menu-report', 1, 1, 0, 1, 15, 0)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Inventory.view.LotDetail?showSearch=true', intSort = 15, strIcon = 'small-menu-report' WHERE strMenuName = 'Lot Details' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Inventory Valuation' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Inventory Valuation', N'Inventory', @InventoryMaintenanceParentMenuId, N'Inventory Valuation', N'Maintenance', N'Screen', N'Inventory.view.InventoryValuation?showSearch=true', N'small-menu-report', 1, 1, 0, 1, 17, 0)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Inventory.view.InventoryValuation?showSearch=true', intSort = 17, strIcon = 'small-menu-report' WHERE strMenuName = 'Inventory Valuation' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Inventory Valuation Summary' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Inventory Valuation Summary', N'Inventory', @InventoryMaintenanceParentMenuId, N'Inventory Valuation Summary', N'Maintenance', N'Screen', N'Inventory.view.InventoryValuationSummary?showSearch=true', N'small-menu-report', 1, 1, 0, 1, 18, 0)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Inventory.view.InventoryValuationSummary?showSearch=true', intSort = 18, strIcon = 'small-menu-report' WHERE strMenuName = 'Inventory Valuation Summary' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceParentMenuId

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
/* END OF DELETING */

/* ACCOUNTS PAYABLE */

/* Rename from Purchasing to Purchasing (Accounts Payable) */
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Purchasing' AND strModuleName = 'Accounts Payable' AND intParentMenuID = 0)
UPDATE tblSMMasterMenu SET strMenuName = 'Purchasing (Accounts Payable)', strDescription = 'Purchasing (Accounts Payable)' WHERE strMenuName = 'Purchasing' AND strModuleName = 'Accounts Payable' AND intParentMenuID = 0

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Purchasing (Accounts Payable)' AND strModuleName = 'Accounts Payable' AND intParentMenuID = 0)
UPDATE tblSMMasterMenu SET intSort = 9 WHERE strMenuName = 'Purchasing (Accounts Payable)' AND strModuleName = 'Accounts Payable' AND intParentMenuID = 0

DECLARE @AccountsPayableParentMenuId INT
SELECT @AccountsPayableParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Purchasing (Accounts Payable)' AND strModuleName = 'Accounts Payable' AND intParentMenuID = 0

/* CATEGORY FOLDERS */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Activities' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Activities', N'Accounts Payable', @AccountsPayableParentMenuId, N'Activities', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 0 WHERE strMenuName = 'Activities' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId

DECLARE @AccountsPayableActivitiesParentMenuId INT
SELECT @AccountsPayableActivitiesParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Activities' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Maintenance', N'Accounts Payable', @AccountsPayableParentMenuId, N'Maintenance', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 1, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 1 WHERE strMenuName = 'Maintenance' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId

DECLARE @AccountsPayableMaintenanceParentMenuId INT
SELECT @AccountsPayableMaintenanceParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId

/* ADD TO RESPECTIVE CATEGORY */ 
UPDATE tblSMMasterMenu SET intParentMenuID = @AccountsPayableActivitiesParentMenuId WHERE intParentMenuID =  @AccountsPayableParentMenuId AND strCategory = 'Activity'
UPDATE tblSMMasterMenu SET intParentMenuID = @AccountsPayableMaintenanceParentMenuId WHERE intParentMenuID =  @AccountsPayableParentMenuId AND strCategory = 'Maintenance'

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Reports' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId)
    INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
    VALUES (N'Reports', N'Accounts Payable', @AccountsPayableParentMenuId, N'Reports', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 2, 1)
ELSE
    UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 2 WHERE strMenuName = 'Reports' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId

DECLARE @AccountsPayableReportParentMenuId INT
SELECT @AccountsPayableReportParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Reports' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId

/* START OF PLURALIZING */
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Purchase Order' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableActivitiesParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Purchase Orders', strDescription = 'Purchase Orders' WHERE strMenuName = 'Purchase Order' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableActivitiesParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Pay Bill Detail' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableActivitiesParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Pay Bill Details', strDescription = 'Pay Bill Details' WHERE strMenuName = 'Pay Bill Detail' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableActivitiesParentMenuId
/* END OF PLURALIZING */

/* START OF RENAMING  */
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Bill Entry' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableActivitiesParentMenuId)	
UPDATE tblSMMasterMenu SET strMenuName = 'Bills', strDescription = 'Bills' WHERE strMenuName = 'Bill Entry' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableActivitiesParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Bill Batch Entry' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableActivitiesParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = N'Voucher Batch Entry', strDescription = N'Voucher Batch Entry' WHERE strMenuName = 'Bill Batch Entry' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableActivitiesParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Bills' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableActivitiesParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Vouchers', strDescription = 'Vouchers' WHERE strMenuName = 'Bills' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableActivitiesParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Pay Bill Details' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableActivitiesParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Pay Voucher Details', strDescription = 'Pay Voucher Details' WHERE strMenuName = 'Pay Bill Details' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableActivitiesParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Pay Bills' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableActivitiesParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Pay Vouchers', strDescription = 'Pay Vouchers (Multi-Vendor)' WHERE strMenuName = 'Pay Bills' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableActivitiesParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Import Bills from Origin' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableActivitiesParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Import Vouchers from Origin', strDescription = 'Import Vouchers from Origin' WHERE strMenuName = 'Import Bills from Origin' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableActivitiesParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Print Checks' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableActivitiesParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Process Payments', strDescription = 'Process Payments' WHERE strMenuName = 'Print Checks' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableActivitiesParentMenuId
/* END OF RENAMING  */

/* Start of Moving */
UPDATE tblSMMasterMenu SET intParentMenuID = @AccountsPayableReportParentMenuId WHERE strMenuName = 'Open Payables' AND strModuleName = 'Accounts Payable' AND strType IN ('Screen', 'Report') AND intParentMenuID = @AccountsPayableParentMenuId
UPDATE tblSMMasterMenu SET intParentMenuID = @AccountsPayableReportParentMenuId WHERE strMenuName = 'Open Payable Details' AND strModuleName = 'Accounts Payable' AND strType IN ('Report', 'Screen') AND intParentMenuID = @AccountsPayableParentMenuId
UPDATE tblSMMasterMenu SET intParentMenuID = @AccountsPayableReportParentMenuId WHERE strMenuName = 'Vendor History' AND strModuleName = 'Accounts Payable' AND strType = 'Report' AND intParentMenuID = @AccountsPayableParentMenuId
UPDATE tblSMMasterMenu SET intParentMenuID = @AccountsPayableReportParentMenuId WHERE strMenuName = 'Cash Requirements' AND strModuleName = 'Accounts Payable' AND strType = 'Report' AND intParentMenuID = @AccountsPayableParentMenuId
UPDATE tblSMMasterMenu SET intParentMenuID = @AccountsPayableReportParentMenuId WHERE strMenuName = 'Check Register' AND strModuleName = 'Accounts Payable' AND strType = 'Report' AND intParentMenuID = @AccountsPayableParentMenuId
UPDATE tblSMMasterMenu SET intParentMenuID = @AccountsPayableReportParentMenuId WHERE strMenuName = 'AP Transactions by GL Account' AND strModuleName = 'Accounts Payable' AND strType IN ('Report', 'Screen') AND intParentMenuID = @AccountsPayableParentMenuId
/* End of Moving */

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Purchase Orders' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Purchase Orders', N'Accounts Payable', @AccountsPayableActivitiesParentMenuId, N'', N'Activity', N'Screen', N'AccountsPayable.view.PurchaseOrder?showSearch=true', N'small-menu-activity', 1, 0, 0, 1, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'AccountsPayable.view.PurchaseOrder?showSearch=true', intSort = 0 WHERE strMenuName = 'Purchase Orders' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableActivitiesParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Voucher Batch Entry' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableActivitiesParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = 'AccountsPayable.view.VoucherBatch?showSearch=true', intSort = 1 WHERE strMenuName = 'Voucher Batch Entry' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Vouchers' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Vouchers', N'Accounts Payable', @AccountsPayableActivitiesParentMenuId, N'Vouchers', N'Activity', N'Screen', N'AccountsPayable.view.Voucher?showSearch=true', N'small-menu-activity', 0, 0, 0, 1, 2, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'AccountsPayable.view.Voucher?showSearch=true', intSort = 2 WHERE strMenuName = 'Vouchers' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableActivitiesParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Batch Posting' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableActivitiesParentMenuId) 
UPDATE tblSMMasterMenu SET strCommand = 'i21.view.BatchPosting?module=Purchasing', intSort = 4 WHERE strMenuName = 'Batch Posting' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableActivitiesParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Pay Vouchers' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableActivitiesParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = 'AccountsPayable.view.PayVouchers', intSort = 5 WHERE strMenuName = 'Pay Vouchers' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableActivitiesParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Pay Voucher Details' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableActivitiesParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = 'AccountsPayable.view.PayVouchersDetail?showSearch=true', intSort = 6 WHERE strMenuName = 'Pay Voucher Details' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableActivitiesParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Process Payments' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableActivitiesParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = 'AccountsPayable.controller.PrintChecks', intSort = 7 WHERE strMenuName = 'Process Payments' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Paid Bills History' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Paid Bills History', N'Accounts Payable', @AccountsPayableActivitiesParentMenuId, N'Shows all the payments', N'Activity', N'Screen', N'AccountsPayable.view.PaidBillsHistory', N'small-menu-activity', 1, 0, 0, 1, 8, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'AccountsPayable.view.PaidBillsHistory', intSort = 8 WHERE strMenuName = 'Paid Bills History' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableActivitiesParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Import Vouchers from Origin' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableActivitiesParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = 'AccountsPayable.view.ImportAPInvoice', intSort = 9 WHERE strMenuName = 'Import Vouchers from Origin' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = '1099' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'1099', N'Accounts Payable', @AccountsPayableActivitiesParentMenuId, N'1099', N'Activity', N'Screen', N'AccountsPayable.view.Thresholds1099', N'small-menu-activity', 1, 0, 0, 1, 10, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'AccountsPayable.view.Thresholds1099', intSort = 10 WHERE strMenuName = '1099' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Buyers' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Buyers', N'Accounts Payable', @AccountsPayableActivitiesParentMenuId, N'Buyers', N'Activity', N'Screen', N'EntityManagement.view.EntityDirect?showSearch=true&searchCommand=EntityBuyer', N'small-menu-activity', 1, 0, 0, 1, 11, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'EntityManagement.view.EntityDirect?showSearch=true&searchCommand=EntityBuyer', intSort = 11 WHERE strMenuName = 'Buyers' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Liens' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Liens', N'Accounts Payable', @AccountsPayableActivitiesParentMenuId, N'Liens', N'Activity', N'Screen', N'EntityManagement.view.EntityDirect?showSearch=true&searchCommand=EntityLien', N'small-menu-activity', 1, 0, 0, 1, 12, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'EntityManagement.view.EntityDirect?showSearch=true&searchCommand=EntityLien', intSort = 12 WHERE strMenuName = 'Liens' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableActivitiesParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Vendors' AND strModuleName = N'Accounts Payable' AND intParentMenuID = @AccountsPayableMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'AccountsPayable.view.EntityVendor?showSearch=true', intSort = 13 WHERE strMenuName = N'Vendors' AND strModuleName = N'Accounts Payable' AND intParentMenuID = @AccountsPayableMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Open Payables' AND strModuleName = N'Accounts Payable' AND intParentMenuID = @AccountsPayableReportParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'Reporting.view.ReportManager?group=Purchasing&report=OpenPayables&direct=true&showCriteria=true', intSort = 0, strCategory = 'Report', strType = 'Screen' WHERE strMenuName = N'Open Payables' AND strModuleName = N'Accounts Payable' AND intParentMenuID = @AccountsPayableReportParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Vendor History' AND strModuleName = N'Accounts Payable' AND intParentMenuID = @AccountsPayableReportParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'Reporting.view.ReportManager?group=Purchasing&report=VendorHistory&direct=true&showCriteria=true', intSort = 1, strType = N'Screen' WHERE strMenuName = N'Vendor History' AND strModuleName = N'Accounts Payable' AND intParentMenuID = @AccountsPayableReportParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Cash Requirements' AND strModuleName = N'Accounts Payable' AND intParentMenuID = @AccountsPayableReportParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'Reporting.view.ReportManager?group=Purchasing&report=CashRequirements&direct=true&showCriteria=true', intSort = 2, strType = N'Screen' WHERE strMenuName = N'Cash Requirements' AND strModuleName = N'Accounts Payable' AND intParentMenuID = @AccountsPayableReportParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Check Register' AND strModuleName = N'Accounts Payable' AND intParentMenuID = @AccountsPayableReportParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'Reporting.view.ReportManager?group=Purchasing&report=CheckRegister&direct=true&showCriteria=true', intSort = 3, strType=N'Screen' WHERE strMenuName = N'Check Register' AND strModuleName = N'Accounts Payable' AND intParentMenuID = @AccountsPayableReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Open Payable Details' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Open Payable Details', N'Accounts Payable', @AccountsPayableReportParentMenuId, N'Open Payable Details', N'Report', N'Screen', N'Reporting.view.ReportManager?group=Purchasing&report=OpenPayablesDetail&direct=true&showCriteria=true', N'small-menu-report', 1, 0, 0, 1, 4, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'Reporting.view.ReportManager?group=Purchasing&report=OpenPayablesDetail&direct=true&showCriteria=true', intSort = 4, strCategory = N'Report', strType = 'Screen' WHERE strMenuName = 'Open Payable Details' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE intMenuID = 130)-- strMenuName = N'AP Transactions by GL Account' AND strModuleName = N'Accounts Payable' AND intParentMenuID = @AccountsPayableReportParentMenuId AND intMenuID = 130)
BEGIN
	/* Start of Re-insert */
	SET IDENTITY_INSERT [dbo].[tblSMMasterMenu] ON

	INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (130, N'AP Transactions By GL Account', N'Accounts Payable', @AccountsPayableReportParentMenuId, N'AP Transactions By GL Account', N'Report', N'Screen', N'Reporting.view.ReportManager?group=Purchasing&report=APTransactionByGLAccount&direct=true', N'small-menu-report', 0, 0, 0, 1, 5, 1)

	SET IDENTITY_INSERT [dbo].[tblSMMasterMenu] OFF
	/* End of Re-insert */
END
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'Reporting.view.ReportManager?group=Purchasing&report=APTransactionByGLAccount&direct=true', intSort = 5, strDescription = 'AP Transactions By GL Account', strCategory = N'Report', strType = 'Screen' WHERE strMenuName = 'AP Transactions By GL Account' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableReportParentMenuId	

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Open Clearing Detail' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Open Clearing Detail', N'Accounts Payable', @AccountsPayableReportParentMenuId, N'Open Clearing Detail', N'Report', N'Screen', N'Reporting.view.ReportManager?group=Purchasing&report=OpenClearingDetails&direct=true', N'small-menu-report', 1, 0, 0, 1, 6, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'Reporting.view.ReportManager?group=Purchasing&report=OpenClearingDetails&direct=true', intSort = 6, strCategory = N'Report', strType = 'Screen' WHERE strMenuName = 'Open Clearing Detail' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Open Clearing' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Open Clearing', N'Accounts Payable', @AccountsPayableReportParentMenuId, N'Open Clearing', N'Report', N'Screen', N'Reporting.view.ReportManager?group=Purchasing&report=OpenClearing&direct=true', N'small-menu-report', 1, 0, 0, 1, 7, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'Reporting.view.ReportManager?group=Purchasing&report=OpenClearing&direct=true', intSort = 7, strCategory = N'Report', strType = 'Screen' WHERE strMenuName = 'Open Clearing' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableReportParentMenuId

/* START OF DELETING */
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Paid Bills History' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableActivitiesParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Open Payable Details' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'AP Transaction By GLAccount' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableActivitiesParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Recurring Transactions' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableActivitiesParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Open Clearing' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableActivitiesParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Open Clearing Detail' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableActivitiesParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Vendor Expense Approval' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableActivitiesParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Vendor History' AND strModuleName = N'Accounts Payable' AND intParentMenuID = @AccountsPayableReportParentMenuId
/* END OF DELETING */

/* ACCOUNTS RECEIVABLE */
/* Rename Sales to Sales (Account Receivables) */
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Sales' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = 0)
UPDATE tblSMMasterMenu SET strMenuName = 'Sales (Accounts Receivable)', strDescription = 'Sales (Accounts Receivable)' WHERE strMenuName = 'Sales' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = 0

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Sales (Accounts Receivable)' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = 0)
UPDATE tblSMMasterMenu SET intSort = 10 WHERE strMenuName = 'Sales (Accounts Receivable)' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = 0

DECLARE @AccountsReceivableParentMenuId INT
SELECT @AccountsReceivableParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Sales (Accounts Receivable)' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = 0

/* CATEGORY FOLDERS */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Activities' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Activities', N'Accounts Receivable', @AccountsReceivableParentMenuId, N'Activities', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 0 WHERE strMenuName = 'Activities' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId

DECLARE @AccountsReceivableActivitiesParentMenuId INT
SELECT @AccountsReceivableActivitiesParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Activities' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'Sales' AND intParentMenuID = @AccountsReceivableParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Maintenance', N'Accounts Receivable', @AccountsReceivableParentMenuId, N'Maintenance', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 1, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 1 WHERE strMenuName = 'Maintenance' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId

DECLARE @AccountsReceivableMaintenanceParentMenuId INT
SELECT @AccountsReceivableMaintenanceParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId

/* ADD TO RESPECTIVE CATEGORY */ 
UPDATE tblSMMasterMenu SET intParentMenuID = @AccountsReceivableActivitiesParentMenuId WHERE intParentMenuID =  @AccountsReceivableParentMenuId AND strCategory = 'Activity'
UPDATE tblSMMasterMenu SET intParentMenuID = @AccountsReceivableMaintenanceParentMenuId WHERE intParentMenuID =  @AccountsReceivableParentMenuId AND strCategory = 'Maintenance'

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Reports' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId)
    INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
    VALUES (N'Reports', N'Accounts Receivable', @AccountsReceivableParentMenuId, N'Reports', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 2, 1)
ELSE
    UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 2 WHERE strMenuName = 'Reports' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId

DECLARE @AccountsReceivableReportParentMenuId INT
SELECT @AccountsReceivableReportParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Reports' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId

/* START OF PLURALIZING */
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Quote' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Quotes', strDescription = 'Quotes' WHERE strMenuName = 'Quote' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Sales Order' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Sales Orders', strDescription = 'Sales Orders' WHERE strMenuName = 'Sales Order' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Invoice' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Invoices', strDescription = 'Invoices' WHERE strMenuName = 'Invoice' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Credit Memo' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Credit Memos', strDescription = 'Credit Memos' WHERE strMenuName = 'Credit Memo' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Statement Footer Message' AND strModuleName = N'Accounts Receivable' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Statement Footer Messages', strDescription = 'Statement Footer Messages' WHERE strMenuName = N'Statement Footer Message' AND strModuleName = N'Accounts Receivable' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Service Charge' AND strModuleName = N'Accounts Receivable' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Service Charges', strDescription = 'Service Charges' WHERE strMenuName = N'Service Charge' AND strModuleName = N'Accounts Receivable' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Customer Group' AND strModuleName = N'Accounts Receivable' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Customer Groups', strDescription = 'Customer Groups' WHERE strMenuName = N'Customer Group' AND strModuleName = N'Accounts Receivable' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Receive Payment Detail' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Receive Payment Details', strDescription = 'Receive Payment Details' WHERE strMenuName = 'Receive Payment Detail' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Quote Template' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Quote Templates', strDescription = 'Quote Templates' WHERE strMenuName = 'Quote Template' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Sales Analysis Report' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId)
UPDATE [dbo].[tblSMMasterMenu] SET [strMenuName] = 'Sales Analysis Reports', [strDescription] = 'Sales Analysis Reports', [strType] = 'Screen' ,[strCommand] = 'AccountsReceivable.view.SalesAnalysisReport?showSearch=true' WHERE strMenuName = 'Sales Analysis Report' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId
/* END OF PLURALIZING */

/* Re-name Salesperson to Sales Reps*/
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Salesperson' AND strModuleName = N'Accounts Receivable' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Sales Reps', strDescription = 'Sales Reps' WHERE strMenuName = N'Salesperson' AND strModuleName = N'Accounts Receivable' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId
/* Rename Statement Footer Messages to Comment Maintenance */
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Statement Footer Messages' AND strModuleName = N'Accounts Receivable' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = N'Comment Maintenance', strDescription = N'Comment Maintenance', strCommand = N'AccountsReceivable.view.CommentMaintenance' WHERE strMenuName = N'Statement Footer Messages' AND strModuleName = N'Accounts Receivable' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Import Invoices from CSV' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = N'Import Transactions from CSV', strDescription = N'Import Transactions from CSV', strCommand = N'AccountsReceivable.view.ImportTransactionsCSV' WHERE strMenuName = 'Import Invoices from CSV' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Tax Report' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId)	
UPDATE tblSMMasterMenu SET strMenuName = N'Tax Report Grid', strDescription = N'Tax Report Grid' WHERE strMenuName = 'Tax Report' AND strModuleName = 'Accounts Receivable' AND strCategory = N'Maintenance' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId
/*
	Rename Menu Name from Sales Analysis Report  to Sales Analysis Reports
	Rename Command to AccountsReceivable.view.SalesAnalysisReport?showSearch=true
	Rename Type from Report to Screen
*/

/* Start of moving report */
UPDATE tblSMMasterMenu SET intParentMenuID = @AccountsReceivableReportParentMenuId WHERE strMenuName = 'Customer Aging Report' AND strModuleName = 'Accounts Receivable' AND strCategory = 'Report' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId
UPDATE tblSMMasterMenu SET intParentMenuID = @AccountsReceivableReportParentMenuId WHERE strMenuName = 'Customer Inquiry Report' AND strModuleName = 'Accounts Receivable' AND strCategory = 'Report' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId
UPDATE tblSMMasterMenu SET intParentMenuID = @AccountsReceivableReportParentMenuId WHERE strMenuName = 'Customer Statements Report' AND strModuleName = 'Accounts Receivable' AND strCategory = 'Report' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId
UPDATE tblSMMasterMenu SET intParentMenuID = @AccountsReceivableReportParentMenuId WHERE strMenuName = 'Payment History Report' AND strModuleName = 'Accounts Receivable' AND strCategory = 'Report' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId
UPDATE tblSMMasterMenu SET intParentMenuID = @AccountsReceivableReportParentMenuId WHERE strMenuName = 'Unapplied Credits Register Report' AND strModuleName = 'Accounts Receivable' AND strCategory = 'Report' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId
UPDATE tblSMMasterMenu SET intParentMenuID = @AccountsReceivableReportParentMenuId WHERE strMenuName = 'Customer Statements Detail Report' AND strModuleName = 'Accounts Receivable' AND strCategory = 'Report' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId
UPDATE tblSMMasterMenu SET intParentMenuID = @AccountsReceivableReportParentMenuId WHERE strMenuName = 'Invoice History Report' AND strModuleName = 'Accounts Receivable' AND strCategory = 'Report' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId
/* End of moving report */

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
	VALUES (N'Receive Payments', N'Accounts Receivable', @AccountsReceivableActivitiesParentMenuId, N'Receive Payments', N'Activity', N'Screen', N'AccountsReceivable.view.ReceivePayments', N'small-menu-activity', 1, 0, 0, 1, 3, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 3, strCommand = N'AccountsReceivable.view.ReceivePayments' WHERE strMenuName = 'Receive Payments' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Receive Payment Details' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Receive Payment Details', N'Accounts Receivable', @AccountsReceivableActivitiesParentMenuId, N'Receive Payment Details', N'Activity', N'Screen', N'AccountsReceivable.view.ReceivePaymentsDetail?showSearch=true', N'small-menu-activity', 1, 0, 0, 1, 4, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 4, strCommand = N'AccountsReceivable.view.ReceivePaymentsDetail?showSearch=true' WHERE strMenuName = 'Receive Payment Details' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'POS Login' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'POS Login', N'Accounts Receivable', @AccountsReceivableActivitiesParentMenuId, N'POS Login', N'Activity', N'Screen', N'AccountsReceivable.view.PointOfSaleLogin', N'small-menu-activity', 1, 0, 0, 1, 5, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 5, strCommand = N'AccountsReceivable.view.PointOfSaleLogin' WHERE strMenuName = 'POS Login' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Batch Posting' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Batch Posting', N'Accounts Receivable', @AccountsReceivableActivitiesParentMenuId, N'Batch Posting', N'Activity', N'Screen', N'AccountsReceivable.view.BatchPostingSearch?showSearch=true', N'small-menu-activity', 1, 0, 0, 1, 6, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 6, strCommand = N'AccountsReceivable.view.BatchPostingSearch?showSearch=true' WHERE strMenuName = 'Batch Posting' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Batch Printing' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Batch Printing', N'Accounts Receivable', @AccountsReceivableActivitiesParentMenuId, N'Batch Printing', N'Activity', N'Screen', N'AccountsReceivable.view.BatchPrinting', N'small-menu-activity', 1, 0, 0, 1, 7, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 7, strCommand = N'AccountsReceivable.view.BatchPrinting' WHERE strMenuName = 'Batch Printing' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Import Invoices from Origin' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Import Invoices from Origin', N'Accounts Receivable', @AccountsReceivableActivitiesParentMenuId, N'Import Invoices from Origin', N'Activity', N'Screen', N'AccountsReceivable.view.ImportInvoices', N'small-menu-activity', 1, 0, 0, 1, 8, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 8, strCommand = N'AccountsReceivable.view.ImportInvoices' WHERE strMenuName = 'Import Invoices from Origin' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Import Billable from Help Desk' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Import Billable from Help Desk', N'Accounts Receivable', @AccountsReceivableActivitiesParentMenuId, N'Import Billable from Help Desk', N'Activity', N'Screen', N'AccountsReceivable.view.ImportBillable', N'small-menu-activity', 1, 0, 0, 1, 9, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 9, strCommand = N'AccountsReceivable.view.ImportBillable' WHERE strMenuName = 'Import Billable from Help Desk' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Calculate Service Charge' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Calculate Service Charge', N'Accounts Receivable', @AccountsReceivableActivitiesParentMenuId, N'Calculate Service Charge', N'Activity', N'Screen', N'AccountsReceivable.view.CalculateServiceCharge', N'small-menu-activity', 1, 0, 0, 1, 10, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 10, strCommand = N'AccountsReceivable.view.CalculateServiceCharge' WHERE strMenuName = 'Calculate Service Charge' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Service Charge Invoice' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Service Charge Invoice', N'Accounts Receivable', @AccountsReceivableActivitiesParentMenuId, N'Service Charge Invoice', N'Activity', N'Screen', N'AccountsReceivable.view.ServiceChargeInvoice', N'small-menu-activity', 1, 0, 0, 1, 11, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 11, strCommand = N'AccountsReceivable.view.ServiceChargeInvoice' WHERE strMenuName = 'Service Charge Invoice' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Import Transactions from CSV' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Import Transactions from CSV', N'Accounts Receivable', @AccountsReceivableActivitiesParentMenuId, N'Import Transactions from CSV', N'Activity', N'Screen', N'AccountsReceivable.view.ImportTransactionsCSV', N'small-menu-activity', 1, 0, 0, 1, 12, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 12, strCommand = N'AccountsReceivable.view.ImportTransactionsCSV' WHERE strMenuName = 'Import Transactions from CSV' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Import Logs' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Import Logs', N'Accounts Receivable', @AccountsReceivableActivitiesParentMenuId, N'Import Logs', N'Activity', N'Screen', N'AccountsReceivable.view.ImportLog?showSearch=true', N'small-menu-activity', 1, 0, 0, 1, 13, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 13, strCommand = N'AccountsReceivable.view.ImportLog?showSearch=true' WHERE strMenuName = 'Import Logs' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Quote Page Builder' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Quote Page Builder', N'Accounts Receivable', @AccountsReceivableActivitiesParentMenuId, N'Quote Page Builder', N'Activity', N'Screen', N'AccountsReceivable.view.QuotePageBuilder?showSearch=true', N'small-menu-activity', 1, 0, 0, 1, 14, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 14, strCommand = N'AccountsReceivable.view.QuotePageBuilder?showSearch=true' WHERE strMenuName = 'Quote Page Builder' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Calculate Commission' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Calculate Commission', N'Accounts Receivable', @AccountsReceivableActivitiesParentMenuId, N'Calculate Commission', N'Activity', N'Screen', N'AccountsReceivable.view.CalculateCommission?showSearch=true', N'small-menu-activity', 1, 0, 0, 1, 15, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 15, strCommand = N'AccountsReceivable.view.CalculateCommission?showSearch=true' WHERE strMenuName = 'Calculate Commission' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Commission Approval' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Commission Approval', N'Accounts Receivable', @AccountsReceivableActivitiesParentMenuId, N'Commission Approval', N'Activity', N'Screen', N'AccountsReceivable.view.CommissionApproval', N'small-menu-activity', 1, 0, 0, 1, 16, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 16, strCommand = N'AccountsReceivable.view.CommissionApproval' WHERE strMenuName = 'Commission Approval' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Customers' AND strModuleName = N'Accounts Receivable' AND intParentMenuID = @AccountsReceivableMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 17, strCommand = N'AccountsReceivable.view.EntityCustomer?showSearch=true' WHERE strMenuName = N'Customers' AND strModuleName = N'Accounts Receivable' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Customer Contact List' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 18, strCommand = N'EntityManagement.controller.CustomerContactList' WHERE strMenuName = 'Customer Contact List' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Sales Reps' AND strModuleName = N'Accounts Receivable' AND intParentMenuID = @AccountsReceivableMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 19	, strCommand = N'AccountsReceivable.view.EntitySalesperson?showSearch=true' WHERE strMenuName = N'Sales Reps' AND strModuleName = N'Accounts Receivable' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Market Zone' AND strModuleName = N'Accounts Receivable' AND intParentMenuID = @AccountsReceivableMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 20, strCommand = N'AccountsReceivable.view.MarketZone' WHERE strMenuName = N'Market Zone' AND strModuleName = N'Accounts Receivable' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Service Charges' AND strModuleName = N'Accounts Receivable' AND intParentMenuID = @AccountsReceivableMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 21, strCommand = N'AccountsReceivable.view.ServiceCharge?showSearch=true' WHERE strMenuName = N'Service Charges' AND strModuleName = N'Accounts Receivable' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Customer Groups' AND strModuleName = N'Accounts Receivable' AND intParentMenuID = @AccountsReceivableMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 22, strCommand = N'EntityManagement.view.CustomerGroup?showSearch=true' WHERE strMenuName = N'Customer Groups' AND strModuleName = N'Accounts Receivable' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Account Status Codes' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Account Status Codes', N'Accounts Receivable', @AccountsReceivableMaintenanceParentMenuId, N'Account Status Codes', N'Maintenance', N'Screen', N'AccountsReceivable.view.AccountStatusCodes?showSearch=true', N'small-menu-maintenance', 1, 0, 0, 1, 22, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 22, strCommand = N'AccountsReceivable.view.AccountStatusCodes?showSearch=true' WHERE strMenuName = 'Account Status Codes' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Quote Templates' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Quote Templates', N'Accounts Receivable', @AccountsReceivableMaintenanceParentMenuId, N'Quote Templates', N'Maintenance', N'Screen', N'AccountsReceivable.view.QuoteTemplate?showSearch=true', N'small-menu-maintenance', 1, 0, 0, 1, 23, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 23, strCommand = N'AccountsReceivable.view.QuoteTemplate?showSearch=true' WHERE strMenuName = 'Quote Templates' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Product Types' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Product Types', N'Accounts Receivable', @AccountsReceivableMaintenanceParentMenuId, N'Product Types', N'Maintenance', N'Screen', N'AccountsReceivable.view.ProductType?showSearch=true', N'small-menu-maintenance', 1, 0, 0, 1, 24, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 24, strCommand = N'AccountsReceivable.view.ProductType?showSearch=true' WHERE strMenuName = 'Product Types' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Commission Plans' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Commission Plans', N'Accounts Receivable', @AccountsReceivableMaintenanceParentMenuId, N'Commission Plans', N'Maintenance', N'Screen', N'AccountsReceivable.view.CommissionPlan?showSearch=true', N'small-menu-maintenance', 1, 0, 0, 1, 25, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 25, strCommand = N'AccountsReceivable.view.CommissionPlan?showSearch=true' WHERE strMenuName = 'Commission Plans' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Commission Schedules' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Commission Schedules', N'Accounts Receivable', @AccountsReceivableMaintenanceParentMenuId, N'Commission Schedules', N'Maintenance', N'Screen', N'AccountsReceivable.view.CommissionSchedule?showSearch=true', N'small-menu-maintenance', 1, 0, 0, 1, 26, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 26, strCommand = N'AccountsReceivable.view.CommissionSchedule?showSearch=true' WHERE strMenuName = 'Commission Schedules' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Tax Report Grid' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableMaintenanceParentMenuId)	
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES ( N'Tax Report Grid', N'Accounts Receivable', @AccountsReceivableMaintenanceParentMenuId, N'Tax Report Grid', N'Maintenance', N'Screen', N'AccountsReceivable.view.TaxReport?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 27, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 27, strType = N'Screen', strCommand = N'AccountsReceivable.view.TaxReport?showSearch=true', strCategory = N'Maintenance', strIcon = 'small-menu-maintenance' WHERE strMenuName = 'Tax Report Grid' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableMaintenanceParentMenuId	

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Sales Analysis Reports' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId])
	VALUES ( N'Sales Analysis Reports', N'Accounts Receivable', @AccountsReceivableMaintenanceParentMenuId, N'Sales Analysis Reports', N'Maintenance', N'Screen', N'AccountsReceivable.view.SalesAnalysisReport?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 28, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 28, strType = N'Screen', strCommand = N'AccountsReceivable.view.SalesAnalysisReport?showSearch=true', strCategory = N'Maintenance', strIcon = 'small-menu-maintenance' WHERE strMenuName = 'Sales Analysis Reports' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Customer Aging Report' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableReportParentMenuId)	
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES ( N'Customer Aging Report', N'Accounts Receivable', @AccountsReceivableReportParentMenuId, N'Customer Aging Report', N'Report', N'Screen', N'Reporting.view.ReportManager?group=Sales&report=CustomerAging&direct=true', N'small-menu-report', 0, 0, 0, 1, 1, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 1, strType = 'Screen', strCommand = N'Reporting.view.ReportManager?group=Sales&report=CustomerAging&direct=true' WHERE strMenuName = 'Customer Aging Report' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableReportParentMenuId	

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Customer Inquiry Report' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId])
	VALUES ( N'Customer Inquiry Report', N'Accounts Receivable', @AccountsReceivableReportParentMenuId, N'Customer Inquiry Report', N'Report', N'Screen', N'Reporting.view.ReportManager?group=Sales&report=CustomerInquiry&direct=true', N'small-menu-report', 0, 0, 0, 1, 2, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 2, strType = 'Screen', strCommand = N'Reporting.view.ReportManager?group=Sales&report=CustomerInquiry&direct=true' WHERE strMenuName = 'Customer Inquiry Report' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableReportParentMenuId	

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Customer Statements Report' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId])
	VALUES ( N'Customer Statements Report', N'Accounts Receivable', @AccountsReceivableReportParentMenuId, N'Customer Statements Report', N'Report', N'Screen', N'Reporting.view.ReportManager?group=Sales&report=StatementOfAccount&direct=true', N'small-menu-report', 0, 0, 0, 1, 3, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 2, strType = 'Screen', strCommand = N'Reporting.view.ReportManager?group=Sales&report=StatementOfAccount&direct=true' WHERE strMenuName = 'Customer Statements Report' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Payment History Report' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId])
	VALUES ( N'Payment History Report', N'Accounts Receivable', @AccountsReceivableReportParentMenuId, N'Payment History Report', N'Report', N'Screen', N'Reporting.view.ReportManager?group=Sales&report=PaymentHistory&direct=true', N'small-menu-report', 0, 0, 0, 1, 4, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 3, strType = 'Screen', strCommand = N'Reporting.view.ReportManager?group=Sales&report=PaymentHistory&direct=true' WHERE strMenuName = 'Payment History Report' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Unapplied Credits Register Report' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId])
	VALUES ( N'Unapplied Credits Register Report', N'Accounts Receivable', @AccountsReceivableReportParentMenuId, N'Unapplied Credits Register Report', N'Report', N'Screen', N'Reporting.view.ReportManager?group=Sales&report=UnappliedCreditsRegister&direct=true', N'small-menu-report', 0, 0, 0, 1, 4, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 4, strType = 'Screen', strCommand = N'Reporting.view.ReportManager?group=Sales&report=UnappliedCreditsRegister&direct=true' WHERE strMenuName = 'Unapplied Credits Register Report' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Customer Statements Detail Report' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId])
	VALUES ( N'Customer Statements Detail Report', N'Accounts Receivable', @AccountsReceivableReportParentMenuId, N'Customer Statements Detail Report', N'Report', N'Screen', N'Reporting.view.ReportManager?group=Sales&report=CustomerStatementDetail&direct=true', N'small-menu-report', 0, 0, 0, 1, 5, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 5, strType = 'Screen', strCommand = N'Reporting.view.ReportManager?group=Sales&report=CustomerStatementDetail&direct=true' WHERE strMenuName = 'Customer Statements Detail Report' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Invoice History Report' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId])
	VALUES ( N'Invoice History Report', N'Accounts Receivable', @AccountsReceivableReportParentMenuId, N'Invoice History Report', N'Report', N'Screen', N'Reporting.view.ReportManager?group=Sales&report=InvoiceHistory&direct=true', N'small-menu-report', 0, 0, 0, 1, 6, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 6, strType = 'Screen', strCommand = N'Reporting.view.ReportManager?group=Sales&report=InvoiceHistory&direct=true' WHERE strMenuName = 'Invoice History Report' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Tax Report' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId])
	VALUES ( N'Tax Report', N'Accounts Receivable', @AccountsReceivableReportParentMenuId, N'Tax Report', N'Report', N'Screen', N'Reporting.view.ReportManager?group=Sales&report=Tax&direct=true', N'small-menu-report', 0, 0, 0, 1, 7, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 7, strCommand = N'Reporting.view.ReportManager?group=Sales&report=Tax&direct=true' WHERE strMenuName = 'Tax Report' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Customer Aging Detail Report' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId])
	VALUES ( N'Customer Aging Detail Report', N'Accounts Receivable', @AccountsReceivableReportParentMenuId, N'Customer Aging Detail Report', N'Report', N'Screen', N'Reporting.view.ReportManager?group=Sales&report=CustomerAgingDetail&direct=true', N'small-menu-report', 0, 0, 0, 1, 8, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 8, strCommand = N'Reporting.view.ReportManager?group=Sales&report=CustomerAgingDetail&direct=true' WHERE strMenuName = 'Customer Aging Detail Report' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Restricted Chemicals Report' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId])
	VALUES ( N'Restricted Chemicals Report', N'Accounts Receivable', @AccountsReceivableReportParentMenuId, N'Restricted Chemicals Report', N'Report', N'Screen', N'Reporting.view.ReportManager?group=Sales&report=RestrictedChemical&direct=true', N'small-menu-report', 0, 0, 0, 1, 9, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 9, strCommand = N'Reporting.view.ReportManager?group=Sales&report=RestrictedChemical&direct=true' WHERE strMenuName = 'Restricted Chemicals Report' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'POS End Of Day Report' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId])
	VALUES ( N'POS End Of Day Report', N'Accounts Receivable', @AccountsReceivableReportParentMenuId, N'POS End Of Day Report', N'Report', N'Screen', N'AccountsReceivable.view.PointOfSaleEndOfDayReport', N'small-menu-report', 0, 0, 0, 1, 10, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 10, strCommand = N'AccountsReceivable.view.PointOfSaleEndOfDayReport' WHERE strMenuName = 'POS End Of Day Report' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableReportParentMenuId

/* START OF DELETING */
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Credit Memos' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId)
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
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Comment Maintenance' AND strModuleName = N'Accounts Receivable' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId
/* END OF DELETING */

/* PAYROLL */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Payroll' AND strModuleName = 'Payroll' AND intParentMenuID = 0)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Payroll', N'Payroll', 0, N'Payroll', NULL, N'Folder', N'', N'small-folder', 1, 1, 0, 0, 11, 0)
ELSE
	UPDATE tblSMMasterMenu SET  intSort = 11 WHERE strMenuName = 'Payroll' AND strModuleName = 'Payroll' AND intParentMenuID = 0

DECLARE @PayrollParentMenuId INT
SELECT @PayrollParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Payroll' AND strModuleName = 'Payroll' AND intParentMenuID = 0

/* CATEGORY FOLDERS */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Activities' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Activities', N'Payroll', @PayrollParentMenuId, N'Activities', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 0 WHERE strMenuName = 'Activities' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollParentMenuId

DECLARE @PayrollActivitiesParentMenuId INT
SELECT @PayrollActivitiesParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Activities' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Maintenance', N'Payroll', @PayrollParentMenuId, N'Maintenance', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 1, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 1 WHERE strMenuName = 'Maintenance' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollParentMenuId

DECLARE @PayrollMaintenanceParentMenuId INT
SELECT @PayrollMaintenanceParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollParentMenuId

/* ADD TO RESPECTIVE CATEGORY */ 
UPDATE tblSMMasterMenu SET intParentMenuID = @PayrollActivitiesParentMenuId WHERE intParentMenuID =  @PayrollParentMenuId AND strCategory = 'Activity'
UPDATE tblSMMasterMenu SET intParentMenuID = @PayrollMaintenanceParentMenuId WHERE intParentMenuID =  @PayrollParentMenuId AND strCategory = 'Maintenance'

/* START OF PLURALIZING */
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Timecard' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollActivitiesParentMenuId)
UPDATE tblSMMasterMenu SET  strMenuName = 'Timecards', strDescription = 'Timecards' WHERE strMenuName = 'Timecard' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollActivitiesParentMenuId
/* END OF PLURALIZING */

/* START OF RENAMING  */
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Print Checks' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollActivitiesParentMenuId)
UPDATE tblSMMasterMenu SET  strMenuName = 'Process Paychecks', strDescription = 'Process Paychecks' WHERE strMenuName = 'Print Checks' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollActivitiesParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Time Approval' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollActivitiesParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Timecard Approval', strDescription = 'Timecard Approval' WHERE strMenuName = 'Time Approval' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollActivitiesParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Time History' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollActivitiesParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Timecard History', strDescription = 'Timecard History' WHERE strMenuName = 'Time History' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollActivitiesParentMenuId
/* END OF RENAMING  */

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Time Off Requests' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Time Off Requests', N'Payroll', @PayrollActivitiesParentMenuId, N'Time Off Requests', N'Activity', N'Screen', N'Payroll.view.TimeOffRequest?showSearch=true&searchCommand=TimeOffRequest', N'small-menu-activity', 1, 1, 0, 1, 1, 0)
ELSE 
	UPDATE tblSMMasterMenu SET  intSort = 1, strCommand = N'Payroll.view.TimeOffRequest?showSearch=true&searchCommand=TimeOffRequest' WHERE strMenuName = 'Time Off Requests' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Timecards' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Timecards', N'Payroll', @PayrollActivitiesParentMenuId, N'Timecards', N'Activity', N'Screen', N'Payroll.view.Timecard', N'small-menu-activity', 1, 1, 0, 1, 2, 0)
ELSE 
	UPDATE tblSMMasterMenu SET  intSort = 2, strCommand = N'Payroll.view.Timecard' WHERE strMenuName = 'Timecards' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Timecard Approval' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Timecard Approval', N'Payroll', @PayrollActivitiesParentMenuId, N'Timecard Approval', N'Activity', N'Screen', N'Payroll.view.TimeApproval', N'small-menu-activity', 1, 1, 0, 1, 3, 0)
ELSE 
	UPDATE tblSMMasterMenu SET  intSort = 3, strCommand = N'Payroll.view.TimeApproval' WHERE strMenuName = 'Timecard Approval' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Timecard History' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Timecard History', N'Payroll', @PayrollActivitiesParentMenuId, N'Timecard History', N'Activity', N'Screen', N'Payroll.view.TimeHistory?showSearch=true&searchCommand=TimeHistory', N'small-menu-activity', 1, 1, 0, 1, 4, 0)
ELSE 
	UPDATE tblSMMasterMenu SET  intSort = 4, strCommand = N'Payroll.view.TimeHistory?showSearch=true&searchCommand=TimeHistory' WHERE strMenuName = 'Timecard History' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Process Pay Groups' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Process Pay Groups', N'Payroll', @PayrollActivitiesParentMenuId, N'Process Pay Groups', N'Activity', N'Screen', N'Payroll.view.ProcessPayGroup', N'small-menu-activity', 1, 1, 0, 1, 5, 0)
ELSE 
	UPDATE tblSMMasterMenu SET  intSort = 5, strCommand = N'Payroll.view.ProcessPayGroup' WHERE strMenuName = 'Process Pay Groups' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Paychecks' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Paychecks', N'Payroll', @PayrollActivitiesParentMenuId, N'Paychecks', N'Activity', N'Screen', N'Payroll.view.Paycheck?showSearch=true&searchCommand=Paycheck', N'small-menu-activity', 1, 1, 0, 1, 6, 0)
ELSE 
	UPDATE tblSMMasterMenu SET  intSort = 6, strCommand = N'Payroll.view.Paycheck?showSearch=true&searchCommand=Paycheck' WHERE strMenuName = 'Paychecks' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Batch Posting' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Batch Posting', N'Payroll', @PayrollActivitiesParentMenuId, N'Batch Posting', N'Activity', N'Screen', N'Payroll.view.BatchPosting', N'small-menu-activity', 1, 1, 0, 1, 7, 0)
ELSE 
	UPDATE tblSMMasterMenu SET  intSort = 7, strCommand = N'Payroll.view.BatchPosting' WHERE strMenuName = 'Batch Posting' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Process Paychecks' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Process Paychecks', N'Payroll', @PayrollActivitiesParentMenuId, N'Process Paychecks', N'Activity', N'Screen', N'Payroll.controller.PrintChecks', N'small-menu-activity', 1, 1, 0, 1, 8, 0)
ELSE 
	UPDATE tblSMMasterMenu SET  intSort = 8, strCommand = N'Payroll.controller.PrintChecks' WHERE strMenuName = 'Process Paychecks' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Create Payables' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Create Payables', N'Payroll', @PayrollActivitiesParentMenuId, N'Create Payables', N'Activity', N'Screen', N'Payroll.view.CreatePayable', N'small-menu-activity', 1, 1, 0, 1, 9, 0)
ELSE 
	UPDATE tblSMMasterMenu SET  intSort = 9, strCommand = N'Payroll.view.CreatePayable' WHERE strMenuName = 'Create Payables' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Employees' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Employees', N'Payroll', @PayrollMaintenanceParentMenuId, N'Employees', N'Maintenance', N'Screen', N'Payroll.view.EntityEmployee?showSearch=true', N'small-menu-maintenance', 1, 1, 0, 1, 10, 0)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 10, strCommand = N'Payroll.view.EntityEmployee?showSearch=true' WHERE strMenuName = 'Employees' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Paycheck Calculator' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Paycheck Calculator', N'Payroll', @PayrollMaintenanceParentMenuId, N'Paycheck Calculator', N'Maintenance', N'Screen', N'Payroll.view.PaycheckCalculator', N'small-menu-maintenance', 1, 1, 0, 1, 11, 0)
ELSE 
	UPDATE tblSMMasterMenu SET  intSort = 11, strCategory = 'Maintenance', strIcon = N'small-menu-maintenance', strCommand = N'Payroll.view.PaycheckCalculator' WHERE strMenuName = 'Paycheck Calculator' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollMaintenanceParentMenuId
	
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Employee Templates' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Employee Templates', N'Payroll', @PayrollMaintenanceParentMenuId, N'Employee Templates', N'Maintenance', N'Screen', N'Payroll.view.EmployeeTemplate?showSearch=true&searchCommand=EmployeeTemplate', N'small-menu-maintenance', 1, 1, 0, 1, 12, 0)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 12, strCommand = N'Payroll.view.EmployeeTemplate?showSearch=true&searchCommand=EmployeeTemplate' WHERE strMenuName = 'Employee Templates' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Tax Types' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Tax Types', N'Payroll', @PayrollMaintenanceParentMenuId, N'Tax Types', N'Maintenance', N'Screen', N'Payroll.view.TaxType?showSearch=true&searchCommand=TaxType', N'small-menu-maintenance', 1, 1, 0, 1, 13, 0)
ELSE 
	UPDATE tblSMMasterMenu SET  intSort = 13, strCommand = N'Payroll.view.TaxType?showSearch=true&searchCommand=TaxType' WHERE strMenuName = 'Tax Types' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Earning Types' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Earning Types', N'Payroll', @PayrollMaintenanceParentMenuId, N'Earning Types', N'Maintenance', N'Screen', N'Payroll.view.EarningType?showSearch=true&searchCommand=EarningType', N'small-menu-maintenance', 1, 1, 0, 1, 14, 0)
ELSE 
	UPDATE tblSMMasterMenu SET  intSort = 14, strCommand = N'Payroll.view.EarningType?showSearch=true&searchCommand=EarningType' WHERE strMenuName = 'Earning Types' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Employee Pay Groups' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Employee Pay Groups', N'Payroll', @PayrollMaintenanceParentMenuId, N'Employee Pay Groups', N'Maintenance', N'Screen', N'Payroll.view.EmployeePayGroup', N'small-menu-maintenance', 1, 1, 0, 1, 15, 0)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 15, strCommand = N'Payroll.view.EmployeePayGroup' WHERE strMenuName = 'Employee Pay Groups' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Deduction Types' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Deduction Types', N'Payroll', @PayrollMaintenanceParentMenuId, N'Deduction Types', N'Maintenance', N'Screen', N'Payroll.view.DeductionType?showSearch=true&searchCommand=DeductionType', N'small-menu-maintenance', 1, 1, 0, 1, 16, 0)
ELSE 
	UPDATE tblSMMasterMenu SET  intSort = 16, strCommand = N'Payroll.view.DeductionType?showSearch=true&searchCommand=DeductionType' WHERE strMenuName = 'Deduction Types' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Time Off Types' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Time Off Types', N'Payroll', @PayrollMaintenanceParentMenuId, N'Time Off Types', N'Maintenance', N'Screen', N'Payroll.view.TimeOffType?showSearch=true&searchCommand=TimeOffType', N'small-menu-maintenance', 1, 1, 0, 1, 17, 0)
ELSE 
	UPDATE tblSMMasterMenu SET  intSort = 17, strCommand = N'Payroll.view.TimeOffType?showSearch=true&searchCommand=TimeOffType' WHERE strMenuName = 'Time Off Types' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Employee Departments' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Employee Departments', N'Payroll', @PayrollMaintenanceParentMenuId, N'Employee Departments', N'Maintenance', N'Screen', N'Payroll.view.EmployeeDepartment?showSearch=true&searchCommand=EmployeeDepartment', N'small-menu-maintenance', 1, 1, 0, 1, 18, 0)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 18, strCommand = N'Payroll.view.EmployeeDepartment?showSearch=true&searchCommand=EmployeeDepartment' WHERE strMenuName = 'Employee Departments' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Workers Compensation Codes' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Workers Compensation Codes', N'Payroll', @PayrollMaintenanceParentMenuId, N'Workers Compensation Codes', N'Maintenance', N'Screen', N'Payroll.view.WorkersCompensationCodes', N'small-menu-maintenance', 1, 1, 0, 1, 19, 0)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 19, strCommand = N'Payroll.view.WorkersCompensationCodes' WHERE strMenuName = 'Workers Compensation Codes' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Reports' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollParentMenuId)
    INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
    VALUES (N'Reports', N'Payroll', @PayrollParentMenuId, N'Reports', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 2, 1)
ELSE
    UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 2 WHERE strMenuName = 'Reports' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollParentMenuId

DECLARE @PayrollReportParentMenuId INT
SELECT @PayrollReportParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Reports' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Employee Earnings Register' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Employee Earnings Register', N'Payroll', @PayrollReportParentMenuId, N'Employee Earnings Register', N'Report', N'Screen', N'Reporting.view.ReportManager?group=Payroll&report=EmployeeEarningRegister&direct=true', N'small-menu-report', 1, 0, 0, 1, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 0, strCommand = 'Reporting.view.ReportManager?group=Payroll&report=EmployeeEarningRegister&direct=true' WHERE strMenuName = 'Employee Earnings Register' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Quarterly FUI' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Quarterly FUI', N'Payroll', @PayrollReportParentMenuId, N'Quarterly FUI', N'Report', N'Screen', N'Reporting.view.ReportManager?group=Payroll&report=QuarterlyFUI&direct=true', N'small-menu-report', 1, 0, 0, 1, 1, 1)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 1, strCommand = 'Reporting.view.ReportManager?group=Payroll&report=QuarterlyFUI&direct=true' WHERE strMenuName = 'Quarterly FUI' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Quarterly SUI' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Quarterly SUI', N'Payroll', @PayrollReportParentMenuId, N'Quarterly SUI', N'Report', N'Screen', N'Reporting.view.ReportManager?group=Payroll&report=QuarterlySUI&direct=true', N'small-menu-report', 1, 0, 0, 1, 2, 1)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 2, strCommand = 'Reporting.view.ReportManager?group=Payroll&report=QuarterlySUI&direct=true' WHERE strMenuName = 'Quarterly SUI' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Quarterly State Tax' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Quarterly State Tax', N'Payroll', @PayrollReportParentMenuId, N'Quarterly State Tax', N'Report', N'Screen', N'Reporting.view.ReportManager?group=Payroll&report=QuarterlyStateTax&direct=true', N'small-menu-report', 1, 0, 0, 1, 3, 1)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 3, strCommand = 'Reporting.view.ReportManager?group=Payroll&report=QuarterlyStateTax&direct=true' WHERE strMenuName = 'Quarterly State Tax' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Earnings History' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Earnings History', N'Payroll', @PayrollReportParentMenuId, N'Earnings History', N'Report', N'Screen', N'Reporting.view.ReportManager?group=Payroll&report=EarningsHistory&direct=true', N'small-menu-report', 1, 0, 0, 1, 4, 1)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 4, strCommand = 'Reporting.view.ReportManager?group=Payroll&report=EarningsHistory&direct=true' WHERE strMenuName = 'Earnings History' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Earnings History By Department' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Earnings History By Department', N'Payroll', @PayrollReportParentMenuId, N'Earnings History By Department', N'Report', N'Screen', N'Reporting.view.ReportManager?group=Payroll&report=EarningsHistoryByDepartment&direct=true', N'small-menu-report', 1, 0, 0, 1, 5, 1)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 5, strCommand = 'Reporting.view.ReportManager?group=Payroll&report=EarningsHistoryByDepartment&direct=true' WHERE strMenuName = 'Earnings History By Department' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Employee Earnings History' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Employee Earnings History', N'Payroll', @PayrollReportParentMenuId, N'Employee Earnings History', N'Report', N'Screen', N'Reporting.view.ReportManager?group=Payroll&report=EmployeeEarningsHistory&direct=true', N'small-menu-report', 1, 0, 0, 1, 6, 1)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 6, strCommand = 'Reporting.view.ReportManager?group=Payroll&report=EmployeeEarningsHistory&direct=true' WHERE strMenuName = 'Employee Earnings History' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Form 941' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Form 941', N'Payroll', @PayrollReportParentMenuId, N'Form 941', N'Report', N'Screen', N'Payroll.view.Form941', N'small-menu-report', 1, 0, 0, 1, 7, 1)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 7, strCommand = 'Payroll.view.Form941' WHERE strMenuName = 'Form 941' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Process W-2' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Process W-2', N'Payroll', @PayrollReportParentMenuId, N'Process W-2', N'Report', N'Screen', N'Payroll.view.ProcessW2', N'small-menu-report', 1, 0, 0, 1, 8, 1)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 8, strCommand = 'Payroll.view.ProcessW2' WHERE strMenuName = 'Process W-2' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Workers Compensation' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Workers Compensation', N'Payroll', @PayrollReportParentMenuId, N'Workers Compensation', N'Report', N'Screen', N'Reporting.view.ReportManager?group=Payroll&report=WorkersCompensation&direct=true', N'small-menu-report', 1, 0, 0, 1, 9, 1)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 9, strCommand = 'Reporting.view.ReportManager?group=Payroll&report=WorkersCompensation&direct=true' WHERE strMenuName = 'Workers Compensation' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollReportParentMenuId

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
/* END OF DELETING */

/* NOTES RECEIVABLE */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Notes Receivable' AND strModuleName = 'Notes Receivable' AND intParentMenuID = 0)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Notes Receivable', N'Notes Receivable', 0, N'Notes Receivable', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 12, 0)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 12 WHERE strMenuName = 'Notes Receivable' AND strModuleName = 'Notes Receivable' AND intParentMenuID = 0

DECLARE @NotesReceivableParentMenuId INT
SELECT @NotesReceivableParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Notes Receivable' AND strModuleName = 'Notes Receivable' AND intParentMenuID = 0

/* CATEGORY FOLDERS */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Activities' AND strModuleName = 'Notes Receivable' AND intParentMenuID = @NotesReceivableParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Activities', N'Notes Receivable', @NotesReceivableParentMenuId, N'Activities', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 0 WHERE strMenuName = 'Activities' AND strModuleName = 'Notes Receivable' AND intParentMenuID = @NotesReceivableParentMenuId

DECLARE @NotesReceivableActivitiesParentMenuId INT
SELECT @NotesReceivableActivitiesParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Activities' AND strModuleName = 'Notes Receivable' AND intParentMenuID = @NotesReceivableParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'Notes Receivable' AND intParentMenuID = @NotesReceivableParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Maintenance', N'Notes Receivable', @NotesReceivableParentMenuId, N'Maintenance', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 1, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 1 WHERE strMenuName = 'Maintenance' AND strModuleName = 'Notes Receivable' AND intParentMenuID = @NotesReceivableParentMenuId

DECLARE @NotesReceivableMaintenanceParentMenuId INT
SELECT @NotesReceivableMaintenanceParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'Notes Receivable' AND intParentMenuID = @NotesReceivableParentMenuId

/* ADD TO RESPECTIVE CATEGORY */ 
UPDATE tblSMMasterMenu SET intParentMenuID = @NotesReceivableActivitiesParentMenuId WHERE intParentMenuID =  @NotesReceivableParentMenuId AND strCategory = 'Activity'
UPDATE tblSMMasterMenu SET intParentMenuID = @NotesReceivableMaintenanceParentMenuId WHERE intParentMenuID =  @NotesReceivableParentMenuId AND strCategory = 'Maintenance'

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Reports' AND strModuleName = 'Notes Receivable' AND intParentMenuID = @NotesReceivableParentMenuId)
    INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
    VALUES (N'Reports', N'Notes Receivable', @NotesReceivableParentMenuId, N'Reports', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 2, 1)
ELSE
    UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 2 WHERE strMenuName = 'Reports' AND strModuleName = 'Notes Receivable' AND intParentMenuID = @NotesReceivableParentMenuId

DECLARE @NotesReceivableReportParentMenuId INT
SELECT @NotesReceivableReportParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Reports' AND strModuleName = 'Notes Receivable' AND intParentMenuID = @NotesReceivableParentMenuId

/* Rename Note Maintenance to Note Receivables */
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Note Maintenance' AND strModuleName = 'Notes Receivable' AND intParentMenuID = @NotesReceivableActivitiesParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Notes Receivables', strDescription = 'Notes Receivables' WHERE strMenuName = 'Note Maintenance' AND strModuleName = 'Notes Receivable' AND intParentMenuID = @NotesReceivableActivitiesParentMenuId

/* Start of moving report */
UPDATE tblSMMasterMenu SET intParentMenuID = @NotesReceivableReportParentMenuId WHERE strMenuName = 'UCC Tracking' AND strModuleName = 'Notes Receivable' AND strType = 'Report' AND intParentMenuID = @NotesReceivableParentMenuId
UPDATE tblSMMasterMenu SET intParentMenuID = @NotesReceivableReportParentMenuId WHERE strMenuName = 'Aged Notes Receivable' AND strModuleName = 'Notes Receivable' AND strType = 'Report' AND intParentMenuID = @NotesReceivableParentMenuId
UPDATE tblSMMasterMenu SET intParentMenuID = @NotesReceivableReportParentMenuId WHERE strMenuName = '1098' AND strModuleName = 'Notes Receivable' AND strType = 'Report' AND intParentMenuID = @NotesReceivableParentMenuId
/* End of moving report */

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Notes Receivables' AND strModuleName = 'Notes Receivable' AND intParentMenuID = @NotesReceivableActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId])
	VALUES (N'Notes Receivables', N'Notes Receivable', @NotesReceivableActivitiesParentMenuId, N'Notes Receivables', N'Activity', N'Screen', N'NotesReceivable.view.NotesReceivable', N'small-menu-activity', 0, 0, 0, 1, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = N'NotesReceivable.view.NotesReceivable' WHERE strMenuName = 'Notes Receivables' AND strModuleName = 'Notes Receivable' AND intParentMenuID = @NotesReceivableActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Calculate Monthly Interest' AND strModuleName = 'Notes Receivable' AND intParentMenuID = @NotesReceivableActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Calculate Monthly Interest', N'Notes Receivable', @NotesReceivableActivitiesParentMenuId, N'Calculate Monthly Interest', N'Activity', N'Screen', N'NotesReceivable.view.CalculateMonthlyInterest', N'small-menu-activity', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'NotesReceivable.view.CalculateMonthlyInterest' WHERE strMenuName = 'Calculate Monthly Interest' AND strModuleName = 'Notes Receivable' AND intParentMenuID = @NotesReceivableActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Note Description' AND strModuleName = 'Notes Receivable' AND intParentMenuID = @NotesReceivableMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Note Description', N'Notes Receivable', @NotesReceivableMaintenanceParentMenuId, N'Note Description', N'Maintenance', N'Screen', N'NotesReceivable.view.NoteDescription', N'small-menu-maintenance', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'NotesReceivable.view.NoteDescription' WHERE strMenuName = 'Note Description' AND strModuleName = 'Notes Receivable' AND intParentMenuID = @NotesReceivableMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Show Adjustment As' AND strModuleName = 'Notes Receivable' AND intParentMenuID = @NotesReceivableMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Show Adjustment As', N'Notes Receivable', @NotesReceivableMaintenanceParentMenuId, N'Show Adjustment As', N'Maintenance', N'Screen', N'NotesReceivable.view.ShowAdjustmentAs', N'small-menu-maintenance', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'NotesReceivable.view.ShowAdjustmentAs' WHERE strMenuName = 'Show Adjustment As' AND strModuleName = 'Notes Receivable' AND intParentMenuID = @NotesReceivableMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'UCC Tracking' AND strModuleName = 'Notes Receivable' AND intParentMenuID = @NotesReceivableReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'UCC Tracking', N'Notes Receivable', @NotesReceivableReportParentMenuId, N'UCC Tracking', N'Report', N'Report', N'UCC Tracking', N'small-menu-report', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'UCC Tracking' WHERE strMenuName = 'UCC Tracking' AND strModuleName = 'Notes Receivable' AND intParentMenuID = @NotesReceivableReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Aged Notes Receivable' AND strModuleName = 'Notes Receivable' AND intParentMenuID = @NotesReceivableReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Aged Notes Receivable', N'Notes Receivable', @NotesReceivableReportParentMenuId, N'Aged Notes Receivable', N'Report', N'Report', N'Aged Notes Receivable', N'small-menu-report', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Aged Notes Receivable' WHERE strMenuName = 'Aged Notes Receivable' AND strModuleName = 'Notes Receivable' AND intParentMenuID = @NotesReceivableReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = '1098' AND strModuleName = 'Notes Receivable' AND intParentMenuID = @NotesReceivableReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'1098', N'Notes Receivable', @NotesReceivableReportParentMenuId, N'1098', N'Report', N'Report', N'1098', N'small-menu-report', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'1098' WHERE strMenuName = '1098' AND strModuleName = 'Notes Receivable' AND intParentMenuID = @NotesReceivableReportParentMenuId

/* CONTRACT MANAGEMENT */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Contract Management' AND strModuleName = 'Contract Management' AND intParentMenuID = 0)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Contract Management', N'Contract Management', 0, N'Contract Management', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 13, 0)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 13 WHERE strMenuName = 'Contract Management' AND strModuleName = 'Contract Management' AND intParentMenuID = 0

DECLARE @ContractManagementParentMenuId INT
SELECT @ContractManagementParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Contract Management' AND strModuleName = 'Contract Management' AND intParentMenuID = 0

/* CATEGORY FOLDERS */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Activities' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Activities', N'Contract Management', @ContractManagementParentMenuId, N'Activities', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 0 WHERE strMenuName = 'Activities' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId

DECLARE @ContractManagementActivitiesParentMenuId INT
SELECT @ContractManagementActivitiesParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Activities' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Maintenance', N'Contract Management', @ContractManagementParentMenuId, N'Maintenance', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 1, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 1 WHERE strMenuName = 'Maintenance' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId

DECLARE @ContractManagementMaintenanceParentMenuId INT
SELECT @ContractManagementMaintenanceParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId

/* ADD TO RESPECTIVE CATEGORY */ 
UPDATE tblSMMasterMenu SET intParentMenuID = @ContractManagementActivitiesParentMenuId WHERE intParentMenuID =  @ContractManagementParentMenuId AND strCategory = 'Activity'
UPDATE tblSMMasterMenu SET intParentMenuID = @ContractManagementMaintenanceParentMenuId WHERE intParentMenuID =  @ContractManagementParentMenuId AND strCategory = 'Maintenance'

/* START OF PLURALIZING */
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Contract' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementActivitiesParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Contracts', strDescription = 'Contracts' WHERE strMenuName = 'Contract' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementActivitiesParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Contract Text' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Contract Texts', strDescription = 'Contract Texts' WHERE strMenuName = 'Contract Text' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Cost Type' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Cost Types', strDescription = 'Cost Types' WHERE strMenuName = 'Cost Type' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Book' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Books', strDescription = 'Books' WHERE strMenuName = 'Book' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceParentMenuId
/* END OF PLURALIZING */

/* Start of Re-name */
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Approval Basis' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Approval Term', strDescription = 'Approval Term' WHERE strMenuName = 'Approval Basis' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Contract Basis' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'INCO Term', strDescription = 'INCO Term' WHERE strMenuName = 'Contract Basis' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'INCO Term' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'INCO/Ship Term', strDescription = 'INCO/Ship Term' WHERE strMenuName = 'INCO Term' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Position' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Contract Positions', strDescription = 'Contract Positions' WHERE strMenuName = 'Position' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Contract Plans' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'ContractManagement.view.ContractTemplate', strMenuName = 'Contract Templates', strDescription = 'Contract Templates' WHERE strMenuName = 'Contract Plans' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceParentMenuId
/* End of Re-name */

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Contracts' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Contracts', N'Contract Management', @ContractManagementActivitiesParentMenuId, N'Contracts', N'Activity', N'Screen', N'ContractManagement.view.Contract?showSearch=true', N'small-menu-activity', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 0, strCommand = N'ContractManagement.view.Contract?showSearch=true' WHERE strMenuName = 'Contracts' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Price Contracts' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Price Contracts', N'Contract Management', @ContractManagementActivitiesParentMenuId, N'Price Contracts', N'Activity', N'Screen', N'ContractManagement.view.PriceContractsNew?showSearch=true', N'small-menu-activity', 0, 0, 0, 1, 1, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 1, strCommand = N'ContractManagement.view.PriceContractsNew?showSearch=true' WHERE strMenuName = 'Price Contracts' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Contract Adjustments' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Contract Adjustments', N'Contract Management', @ContractManagementActivitiesParentMenuId, N'Contract Adjustments', N'Activity', N'Screen', N'ContractManagement.view.ContractAdjustment?showSearch=true', N'small-menu-activity', 0, 0, 0, 1, 2, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 2, strCommand = N'ContractManagement.view.ContractAdjustment?showSearch=true' WHERE strMenuName = 'Contract Adjustments' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Roll Contracts' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Roll Contracts', N'Contract Management', @ContractManagementActivitiesParentMenuId, N'Roll Contracts', N'Activity', N'Screen', N'ContractManagement.view.RollContracts', N'small-menu-activity', 0, 0, 0, 1, 3, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 3, strCommand = N'ContractManagement.view.RollContracts' WHERE strMenuName = 'Roll Contracts' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Clean Costs & Weights' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Clean Costs & Weights', N'Contract Management', @ContractManagementActivitiesParentMenuId, N'Clean Costs & Weights', N'Activity', N'Screen', N'ContractManagement.view.CleanCostsAndWeights?showSearch=true', N'small-menu-activity', 0, 0, 0, 1, 4, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 4, strCommand = N'ContractManagement.view.CleanCostsAndWeights?showSearch=true' WHERE strMenuName = 'Clean Costs & Weights' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Contract Inquiry' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Contract Inquiry', N'Contract Management', @ContractManagementActivitiesParentMenuId, N'Contract Inquiry', N'Activity', N'Screen', N'ContractManagement.view.ContractInquiry', N'small-menu-activity', 0, 0, 0, 1, 5, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 5, strCommand = N'ContractManagement.view.ContractInquiry' WHERE strMenuName = 'Contract Inquiry' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Contract Status' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Contract Status', N'Contract Management', @ContractManagementActivitiesParentMenuId, N'Contract Status', N'Activity', N'Screen', N'ContractManagement.view.ContractStatus', N'small-menu-activity', 0, 0, 0, 1, 6, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 6, strCommand = N'ContractManagement.view.ContractStatus' WHERE strMenuName = 'Contract Status' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Contract Texts' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Contract Texts', N'Contract Management', @ContractManagementMaintenanceParentMenuId, N'Contract Texts', N'Maintenance', N'Screen', N'ContractManagement.view.ContractText?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 7, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 7, strCommand = N'ContractManagement.view.ContractText?showSearch=true' WHERE strMenuName = 'Contract Texts' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Crop Year' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Crop Year', N'Contract Management', @ContractManagementMaintenanceParentMenuId, N'Crop Year', N'Maintenance', N'Screen', N'ContractManagement.view.CropYearNew', N'small-menu-maintenance', 0, 0, 0, 1, 8, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 8, strCommand = N'ContractManagement.view.CropYearNew' WHERE strMenuName = 'Crop Year' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Weight/Grades' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Weight/Grades', N'Contract Management', @ContractManagementMaintenanceParentMenuId, N'Weight/Grades', N'Maintenance', N'Screen', N'ContractManagement.view.WeightGradeNew', N'small-menu-maintenance', 0, 0, 0, 1, 9, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 9, strCommand = N'ContractManagement.view.WeightGradeNew' WHERE strMenuName = 'Weight/Grades' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Associations' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Associations', N'Contract Management', @ContractManagementMaintenanceParentMenuId, N'Associations', N'Maintenance', N'Screen', N'ContractManagement.view.Associations', N'small-menu-maintenance', 0, 0, 0, 1, 10, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 10, strCommand = N'ContractManagement.view.Associations' WHERE strMenuName = 'Associations' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Books' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Books', N'Contract Management', @ContractManagementMaintenanceParentMenuId, N'Books', N'Maintenance', N'Screen', N'ContractManagement.view.Book?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 11, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 11, strCommand = N'ContractManagement.view.Book?showSearch=true' WHERE strMenuName = 'Books' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'INCO/Ship Term' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'INCO/Ship Term', N'Contract Management', @ContractManagementMaintenanceParentMenuId, N'INCO/Ship Term', N'Maintenance', N'Screen', N'ContractManagement.view.ContractBasis', N'small-menu-maintenance', 0, 0, 0, 1, 12, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 12, strCommand = N'ContractManagement.view.ContractBasis' WHERE strMenuName = 'INCO/Ship Term' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Contract Positions' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Contract Positions', N'Contract Management', @ContractManagementMaintenanceParentMenuId, N'Contract Positions', N'Maintenance', N'Screen', N'ContractManagement.view.Position', N'small-menu-maintenance', 0, 0, 0, 1, 13, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 13, strCommand = N'ContractManagement.view.Position' WHERE strMenuName = 'Contract Positions' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Contract Templates' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Contract Templates', N'Contract Management', @ContractManagementMaintenanceParentMenuId, N'Contract Templates', N'Maintenance', N'Screen', N'ContractManagement.view.ContractTemplate?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 14, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 14, strCommand = N'ContractManagement.view.ContractTemplate?showSearch=true' WHERE strMenuName = 'Contract Templates' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Indexes' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Indexes', N'Contract Management', @ContractManagementMaintenanceParentMenuId, N'Indexes', N'Maintenance', N'Screen', N'ContractManagement.view.Index', N'small-menu-maintenance', 0, 0, 0, 1, 15, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 15, strCommand = N'ContractManagement.view.Index' WHERE strMenuName = 'Indexes' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Event Configuration' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Event Configuration', N'Contract Management', @ContractManagementMaintenanceParentMenuId, N'Event Configuration', N'Maintenance', N'Screen', N'ContractManagement.view.EventConfiguration?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 16, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 16, strCommand = N'ContractManagement.view.EventConfiguration?showSearch=true' WHERE strMenuName = 'Event Configuration' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Event Matrix' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Event Matrix', N'Contract Management', @ContractManagementMaintenanceParentMenuId, N'Event Matrix', N'Maintenance', N'Screen', N'ContractManagement.view.EventMatrix?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 17, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 17, strCommand = N'ContractManagement.view.EventMatrix?showSearch=true' WHERE strMenuName = 'Event Matrix' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Condition' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Condition', N'Contract Management', @ContractManagementMaintenanceParentMenuId, N'Condition', N'Maintenance', N'Screen', N'ContractManagement.view.Condition', N'small-menu-maintenance', 0, 0, 0, 1, 18, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 18, strCommand = N'ContractManagement.view.Condition' WHERE strMenuName = 'Condition' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Documents' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Documents', N'Contract Management', @ContractManagementMaintenanceParentMenuId, N'Documents', N'Maintenance', N'Screen', N'ContractManagement.view.ContractDocument?showSearch=true', N'small-menu-maintenance', 1, 1, 0, 1, 19, 0)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 19, strCommand = N'ContractManagement.view.ContractDocument?showSearch=true' WHERE strMenuName = 'Documents' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Producers' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Producers', N'Contract Management', @ContractManagementMaintenanceParentMenuId, N'Producers', N'Maintenance', N'Screen', N'EntityManagement.view.EntityDirect?showSearch=true&searchCommand=EntityProducer', N'small-menu-maintenance', 1, 1, 0, 1, 20, 0)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 20, strCommand = N'EntityManagement.view.EntityDirect?showSearch=true&searchCommand=EntityProducer' WHERE strMenuName = 'Producers' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Annual Operation Planning' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Annual Operation Planning', N'Contract Management', @ContractManagementMaintenanceParentMenuId, N'Annual Operation Planning', N'Maintenance', N'Screen', N'ContractManagement.view.AnnualOperatingPlanning?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 21, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 21, strCommand = N'ContractManagement.view.AnnualOperatingPlanning?showSearch=true' WHERE strMenuName = 'Annual Operation Planning' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Brokers' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Brokers', N'Contract Management', @ContractManagementMaintenanceParentMenuId, N'Brokers', N'Maintenance', N'Screen', N'AccountsPayable.view.EntityVendor?showSearch=true&searchCommand=EntityBroker', N'small-menu-maintenance', 0, 0, 0, 1, 22, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 22, strCommand = N'AccountsPayable.view.EntityVendor?showSearch=true&searchCommand=EntityBroker' WHERE strMenuName = 'Brokers' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Amendment' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Amendment', N'Contract Management', @ContractManagementMaintenanceParentMenuId, N'Amendment', N'Maintenance', N'Screen', N'ContractManagement.view.Amendments', N'small-menu-maintenance', 0, 0, 0, 1, 23, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 23, strCommand = N'ContractManagement.view.Amendments' WHERE strMenuName = 'Amendment' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Need Plan' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Need Plan', N'Contract Management', @ContractManagementMaintenanceParentMenuId, N'Need Plan', N'Maintenance', N'Screen', N'ContractManagement.view.NeedPlan', N'small-menu-maintenance', 0, 0, 0, 1, 24, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 24, strCommand = N'ContractManagement.view.NeedPlan' WHERE strMenuName = 'Need Plan' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Certification Programs' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Certification Programs', N'Contract Management', @ContractManagementMaintenanceParentMenuId, N'Certification Programs', N'Maintenance', N'Screen', N'ContractManagement.view.CertificationProgram?showSearch=true', N'small-menu-maintenance', 1, 1, 0, 1, 16, 0)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'ContractManagement.view.CertificationProgram?showSearch=true' WHERE strMenuName = 'Certification Programs' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Basis Component' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Basis Component', N'Contract Management', @ContractManagementMaintenanceParentMenuId, N'Basis Component', N'Maintenance', N'Screen', N'Reporting.view.ReportManager?group=Contract Management&report=BasisComponent&direct=true&showCriteria=true', N'small-menu-maintenance', 1, 1, 0, 1, 17, 0)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Reporting.view.ReportManager?group=Contract Management&report=BasisComponent&direct=true&showCriteria=true' WHERE strMenuName = 'Basis Component' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Overview' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Overview', N'Contract Management', @ContractManagementParentMenuId, N'Overview', N'Maintenance', N'Screen', N'ContractManagement.view.Overview?showSearch=true', N'small-menu-maintenance', 1, 1, 0, 1, 18, 0)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'ContractManagement.view.Overview?showSearch=true' WHERE strMenuName = 'Overview' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId

/* Start of Delete */
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Contract Options' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Cost Types' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Freight Rates' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Annual Operating Planning' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Deferred Payment Rates' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Approval Term' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceParentMenuId
/* End of Delete */

/* RISK MANAGEMENT */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Risk Management' AND strModuleName = 'Risk Management' AND intParentMenuID = 0)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Risk Management', N'Risk Management', 0, N'Risk Management', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 14, 2)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 14 WHERE strMenuName = 'Risk Management' AND strModuleName = 'Risk Management' AND intParentMenuID = 0

DECLARE @RiskManagementParentMenuId INT
SELECT @RiskManagementParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Risk Management' AND strModuleName = 'Risk Management' AND intParentMenuID = 0

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

/* ADD TO RESPECTIVE CATEGORY */ 
UPDATE tblSMMasterMenu SET intParentMenuID = @RiskManagementActivitiesParentMenuId WHERE intParentMenuID =  @RiskManagementParentMenuId AND strCategory = 'Activity'
UPDATE tblSMMasterMenu SET intParentMenuID = @RiskManagementMaintenanceParentMenuId WHERE intParentMenuID =  @RiskManagementParentMenuId AND strCategory = 'Maintenance'

/* START OF PLURALIZING */
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Match Futures Purchase & Sale' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Match Futures Purchase & Sales', strDescription = 'Match Futures Purchase & Sales' WHERE strMenuName = 'Match Futures Purchase & Sale' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Futures Market' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Futures Markets', strDescription = 'Futures Markets' WHERE strMenuName = 'Futures Market' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Brokerage Account' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Brokerage Accounts', strDescription = 'Brokerage Accounts' WHERE strMenuName = 'Brokerage Account' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementMaintenanceParentMenuId
/* END OF PLURALIZING */

/* START OF RENAMING  */
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Futures Settlement Price' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Futures/Options Settlement Prices', strDescription = 'Futures/Options Settlement Prices' WHERE strMenuName = 'Futures Settlement Price' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Fut/Opt Transaction' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Futures Options Transactions', strDescription = 'Futures Options Transactions' WHERE strMenuName = 'Fut/Opt Transaction' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Futures Month' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Futures Trading Months', strDescription = 'Futures Trading Months' WHERE strMenuName = 'Futures Month' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Options Month' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Options Trading Months', strDescription = 'Options Trading Months' WHERE strMenuName = 'Options Month' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Daily Position Report' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Live DPR', strDescription = 'Live DPR' WHERE strMenuName = 'Daily Position Report' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Live DPR' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementActivitiesParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Position Report', strDescription = 'Position Report' WHERE strMenuName = 'Live DPR' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementActivitiesParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Coverage Report' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementActivitiesParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = N'Coverage/Risk Inquiry', strDescription = N'Coverage/Risk Inquiry' WHERE strMenuName = 'Coverage Report' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementActivitiesParentMenuId
/* END OF RENAMING  */

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Position Report' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Position Report', N'Risk Management', @RiskManagementActivitiesParentMenuId, N'Position Report', N'Activity', N'Screen', N'RiskManagement.view.LiveDPR', N'small-menu-activity', 0, 0, 0, 1, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 0, strCommand = N'RiskManagement.view.LiveDPR' WHERE strMenuName = 'Position Report' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Collateral' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Collateral', N'Risk Management', @RiskManagementActivitiesParentMenuId, N'Collateral', N'Activity', N'Screen', N'RiskManagement.view.Collateral', N'small-menu-activity', 0, 0, 0, 1, 2, 1)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 2, strCommand = N'RiskManagement.view.Collateral' WHERE strMenuName = 'Collateral' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Coverage/Risk Inquiry' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Coverage/Risk Inquiry', N'Risk Management', @RiskManagementActivitiesParentMenuId, N'Coverage/Risk Inquiry', N'Activity', N'Screen', N'RiskManagement.view.RiskPositionInquiry', N'small-menu-activity', 0, 0, 0, 1, 3, 1)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 3, strCommand = N'RiskManagement.view.RiskPositionInquiry' WHERE strMenuName = 'Coverage/Risk Inquiry' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'M2M Configuration' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'M2M Configuration', N'Risk Management', @RiskManagementActivitiesParentMenuId, N'M2M Configuration', N'Activity', N'Screen', N'RiskManagement.view.MToMConfiguration', N'small-menu-activity', 0, 0, 0, 1, 4, 1)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 4, strCommand = N'RiskManagement.view.MToMConfiguration' WHERE strMenuName = 'M2M Configuration' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Customer Position Inquiry' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Customer Position Inquiry', N'Risk Management', @RiskManagementActivitiesParentMenuId, N'Customer Position Inquiry', N'Activity', N'Screen', N'RiskManagement.view.CustomerPositionInquiry', N'small-menu-activity', 0, 0, 0, 1, 5, 1)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 5, strCommand = N'RiskManagement.view.CustomerPositionInquiry' WHERE strMenuName = 'Customer Position Inquiry' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Position by Period Selection' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Position by Period Selection', N'Risk Management', @RiskManagementActivitiesParentMenuId, N'Position by Period Selection', N'Activity', N'Screen', N'RiskManagement.view.PositionByPeriodSelection', N'small-menu-activity', 0, 0, 0, 1, 6, 1)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 6, strCommand = N'RiskManagement.view.PositionByPeriodSelection' WHERE strMenuName = 'Position by Period Selection' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Daily Position Inquiry' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Daily Position Inquiry', N'Risk Management', @RiskManagementActivitiesParentMenuId, N'Daily Position Inquiry', N'Activity', N'Screen', N'RiskManagement.view.DailyPositionDetail', N'small-menu-activity', 0, 0, 0, 1, 7, 1)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 7, strCommand = N'RiskManagement.view.DailyPositionDetail' WHERE strMenuName = 'Daily Position Inquiry' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Reconciliation Broker Statement' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Reconciliation Broker Statement', N'Risk Management', @RiskManagementActivitiesParentMenuId, N'Reconciliation Broker Statement', N'Activity', N'Screen', N'RiskManagement.view.ReconciliationBrokerStatement', N'small-menu-activity', 0, 0, 0, 1, 8, 1)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 8, strCommand = N'RiskManagement.view.ReconciliationBrokerStatement' WHERE strMenuName = 'Reconciliation Broker Statement' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Risk Rating Matrix' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Risk Rating Matrix', N'Risk Management', @RiskManagementActivitiesParentMenuId, N'Risk Rating Matrix', N'Activity', N'Screen', N'RiskManagement.view.VendorPriceFixationLimit', N'small-menu-activity', 0, 0, 0, 1, 9, 1)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 9, strCommand = N'RiskManagement.view.VendorPriceFixationLimit' WHERE strMenuName = 'Risk Rating Matrix' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Sourcing Report' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Sourcing Report', N'Risk Management', @RiskManagementActivitiesParentMenuId, N'Sourcing Report', N'Activity', N'Screen', N'RiskManagement.view.SourcingReport', N'small-menu-activity', 0, 0, 0, 1, 10, 1)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 10, strCommand = N'RiskManagement.view.SourcingReport' WHERE strMenuName = 'Sourcing Report' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Derivative Screen' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Derivative Screen', N'Risk Management', @RiskManagementActivitiesParentMenuId, N'Derivative Screen', N'Activity', N'Screen', N'RiskManagement.view.DerivativeScreen', N'small-menu-activity', 0, 0, 0, 1, 11, 1)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 11, strCommand = N'RiskManagement.view.DerivativeScreen' WHERE strMenuName = 'Derivative Screen' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Brokerage Accounts' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Brokerage Accounts', N'Risk Management', @RiskManagementActivitiesParentMenuId, N'Brokerage Accounts', N'Maintenance', N'Screen', N'RiskManagement.view.BrokerageAccount?showSearch=true', N'small-menu-activity', 0, 0, 0, 1, 12, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 12, strCommand = N'RiskManagement.view.BrokerageAccount?showSearch=true' WHERE strMenuName = 'Brokerage Accounts' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Futures Markets' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Futures Markets', N'Risk Management', @RiskManagementActivitiesParentMenuId, N'Futures Markets', N'Maintenance', N'Screen', N'RiskManagement.view.FuturesMarket?showSearch=true', N'small-menu-activity', 0, 0, 0, 1, 130, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 13, strCommand = N'RiskManagement.view.FuturesMarket?showSearch=true' WHERE strMenuName = 'Futures Markets' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementActivitiesParentMenuId


IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Reconciliation Broker Statement' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Reconciliation Broker Statement', N'Risk Management', @RiskManagementActivitiesParentMenuId, N'Reconciliation Broker Statement', N'Activity', N'Screen', N'RiskManagement.view.ReconciliationBrokerStatement?showSearch=true', N'small-menu-activity', 0, 0, 0, 1, 14, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 14, strCommand = N'RiskManagement.view.ReconciliationBrokerStatement?showSearch=true' WHERE strMenuName = 'Reconciliation Broker Statement' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementActivitiesParentMenuId


IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Collateral' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Collateral', N'Risk Management', @RiskManagementActivitiesParentMenuId, N'Collateral', N'Activity', N'Screen', N'RiskManagement.view.Collateral?showSearch=true', N'small-menu-activity', 0, 0, 0, 1, 15, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 15, strCommand = N'RiskManagement.view.Collateral?showSearch=true' WHERE strMenuName = 'Collateral' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Derivative Screen' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Derivative Screen', N'Risk Management', @RiskManagementActivitiesParentMenuId, N'Derivative Screen', N'Activity', N'Screen', N'RiskManagement.view.DerivativeScreen?showSearch=true', N'small-menu-activity', 0, 0, 0, 1, 16, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 16, strCommand = N'RiskManagement.view.DerivativeScreen?showSearch=true' WHERE strMenuName = 'Derivative Screen' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Futures Markets' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Futures Markets', N'Risk Management', @RiskManagementMaintenanceParentMenuId, N'Futures Markets', N'Maintenance', N'Screen', N'RiskManagement.view.FuturesMarket', N'small-menu-maintenance', 0, 0, 0, 1, 17, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 17, strCommand = N'RiskManagement.view.FuturesMarket' WHERE strMenuName = 'Futures Markets' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Futures Trading Months' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Futures Trading Months', N'Risk Management', @RiskManagementMaintenanceParentMenuId, N'Futures Trading Months', N'Maintenance', N'Screen', N'RiskManagement.view.FuturesMonth', N'small-menu-maintenance', 0, 0, 0, 1, 18, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 18, strCommand = N'RiskManagement.view.FuturesMonth' WHERE strMenuName = 'Futures Trading Months' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Options Trading Months' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Options Trading Months', N'Risk Management', @RiskManagementMaintenanceParentMenuId, N'Options Trading Months', N'Maintenance', N'Screen', N'RiskManagement.view.OptionsMonth', N'small-menu-maintenance', 0, 0, 0, 1, 19, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 19, strCommand = N'RiskManagement.view.OptionsMonth' WHERE strMenuName = 'Options Trading Months' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Brokerage Accounts' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Brokerage Accounts', N'Risk Management', @RiskManagementMaintenanceParentMenuId, N'Brokerage Accounts', N'Maintenance', N'Screen', N'RiskManagement.view.BrokerageAccount', N'small-menu-maintenance', 0, 0, 0, 1, 20, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 20, strCommand = N'RiskManagement.view.BrokerageAccount' WHERE strMenuName = 'Brokerage Accounts' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Futures Broker' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId])
	VALUES (N'Futures Broker', N'Risk Management', @RiskManagementMaintenanceParentMenuId, N'Futures Broker', N'Maintenance', N'Screen', N'AccountsPayable.view.EntityVendor?showSearch=true&searchCommand=EntityFuturesBroker', N'small-menu-maintenance', 0, 0, 0, 1, 21, 1)
ELSE	
	UPDATE tblSMMasterMenu SET intSort = 21, strCommand = N'AccountsPayable.view.EntityVendor?showSearch=true&searchCommand=EntityFuturesBroker' WHERE strMenuName = 'Futures Broker' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Market Exchange' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId])
	VALUES (N'Market Exchange', N'Risk Management', @RiskManagementMaintenanceParentMenuId, N'Market Exchange', N'Maintenance', N'Screen', N'RiskManagement.view.MarketExchange', N'small-menu-maintenance', 0, 0, 0, 1, 22, 1)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 22, strCommand = N'RiskManagement.view.MarketExchange' WHERE strMenuName = 'Market Exchange' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Futures Price' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId])
	VALUES (N'Futures Price', N'Risk Management', @RiskManagementMaintenanceParentMenuId, N'Futures Price', N'Maintenance', N'Screen', N'RiskManagement.view.RollCost', N'small-menu-maintenance', 0, 0, 0, 1, 23, 1)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 23, strCommand = N'RiskManagement.view.RollCost' WHERE strMenuName = 'Futures Price' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementMaintenanceParentMenuId

/* START OF DELETE */
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Futures/Options Settlement Prices' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Futures Options Transactions' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Match Futures Purchase & Sales' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Option Lifecycle' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Futures360' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'M2M Entry' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'M2M Inquiry' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Assign Futures To Contracts' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Currency Contract' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementMaintenanceParentMenuId
/* END OF DELETE */

/* TICKET MANAGEMENT */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Ticket Management' AND strModuleName = 'Ticket Management' AND intParentMenuID = 0)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Ticket Management', N'Ticket Management', 0, N'Ticket Management', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 15, 0)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 15 WHERE strMenuName = 'Ticket Management' AND strModuleName = 'Ticket Management' AND intParentMenuID = 0

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

/* ADD TO RESPECTIVE CATEGORY */ 
UPDATE tblSMMasterMenu SET intParentMenuID = @TicketManagementActivitiesParentMenuId WHERE intParentMenuID =  @TicketManagementParentMenuId AND strCategory = 'Activity'
UPDATE tblSMMasterMenu SET intParentMenuID = @TicketManagementMaintenanceParentMenuId WHERE intParentMenuID =  @TicketManagementParentMenuId AND strCategory = 'Maintenance'

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Reports' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Reports', N'Ticket Management', @TicketManagementParentMenuId, N'Reports', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 2, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 2 WHERE strMenuName = 'Reports' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementParentMenuId

DECLARE @TicketManagementReportParentMenuId INT
SELECT @TicketManagementReportParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Reports' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementParentMenuId

-- START OF RENAMING
UPDATE tblSMMasterMenu SET strMenuName = N'Tickets' WHERE strMenuName = 'Enter Tickets' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementActivitiesParentMenuId
-- END OF RENAMING

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Tickets' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Tickets', N'Ticket Management', @TicketManagementActivitiesParentMenuId, N'Tickets', N'Activity', N'Screen', N'Grain.view.ScaleStationSelection?showSearch=true', N'small-menu-activity', 0, 0, 0, 1, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'Grain.view.ScaleStationSelection?showSearch=true', intSort = 0 WHERE strMenuName = 'Tickets' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Ticket Formats' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Ticket Formats', N'Ticket Management', @TicketManagementMaintenanceParentMenuId, N'Ticket Format', N'Maintenance', N'Screen', N'Grain.view.TicketFormats', N'small-menu-maintenance', 0, 0, 0, 1, 1, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'Grain.view.TicketFormats', intSort = 1 WHERE strMenuName = 'Ticket Formats' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Physical Scales' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Physical Scales', N'Ticket Management', @TicketManagementMaintenanceParentMenuId, N'Physical Scales', N'Maintenance', N'Screen', N'Grain.view.PhysicalScale?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 2, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'Grain.view.PhysicalScale?showSearch=true',  intSort = 2 WHERE strMenuName = 'Physical Scales' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Grading Equipment' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Grading Equipment', N'Ticket Management', @TicketManagementMaintenanceParentMenuId, N'Grading Equipment', N'Maintenance', N'Screen', N'Grain.view.GradingEquipment?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 3, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'Grain.view.GradingEquipment?showSearch=true', intSort = 3 WHERE strMenuName = 'Grading Equipment' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Ticket Pools' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Ticket Pools', N'Ticket Management', @TicketManagementMaintenanceParentMenuId, N'Ticket Pools', N'Maintenance', N'Screen', N'Grain.view.TicketPool?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 4, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'Grain.view.TicketPool?showSearch=true', intSort = 4 WHERE strMenuName = 'Ticket Pools' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Scale Station Settings' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Scale Station Settings', N'Ticket Management', @TicketManagementMaintenanceParentMenuId, N'Scale Station Settings', N'Maintenance', N'Screen', N'Grain.view.ScaleStationSettings?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 5, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'Grain.view.ScaleStationSettings?showSearch=true', intSort = 5 WHERE strMenuName = 'Scale Station Settings' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Storage' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Storage', N'Ticket Management', @TicketManagementMaintenanceParentMenuId, N'Storage', N'Maintenance', N'Screen', N'Grain.view.Storage?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 6, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Grain.view.Storage?showSearch=true', intSort = 6, strCategory = N'Maintenance' WHERE strMenuName = 'Storage' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'OffSite' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'OffSite', N'Ticket Management', @TicketManagementMaintenanceParentMenuId, N'OffSite', N'Maintenance', N'Screen', N'Grain.view.OffSite?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 7, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Grain.view.OffSite?showSearch=true', intSort = 7, strCategory = N'Maintenance' WHERE strMenuName = 'OffSite' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementMaintenanceParentMenuId

DELETE FROM tblSMMasterMenu WHERE strMenuName IN('Discount Tables','Discount Schedules')

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Discounts' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Discounts', N'Ticket Management', @TicketManagementMaintenanceParentMenuId, N'Discounts', N'Maintenance', N'Screen', N'Grain.view.DiscountTable?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 8, 1)
ELSE 
    UPDATE tblSMMasterMenu SET strCommand = N'Grain.view.DiscountTable?showSearch=true', intSort = 8 WHERE strMenuName = 'Discounts' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Storage Types' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Storage Types', N'Ticket Management', @TicketManagementMaintenanceParentMenuId, N'Storage Types', N'Maintenance', N'Screen', N'Grain.view.GrainStorageType', N'small-menu-maintenance', 0, 0, 0, 1, 10, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Grain.view.GrainStorageType', intSort = 10 WHERE strMenuName = 'Storage Types' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Storage Schedule' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Storage Schedule', N'Ticket Management', @TicketManagementMaintenanceParentMenuId, N'Storage Schedule', N'Maintenance', N'Screen', N'Grain.view.StorageSchedule?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 11, 4, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Grain.view.StorageSchedule?showSearch=true', intSort = 11 WHERE strMenuName = 'Storage Schedule' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Scale Activity' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Scale Activity', N'Ticket Management', @TicketManagementReportParentMenuId, N'Scale Activity', N'Report', N'Report', N'Scale Activity Report', N'small-menu-report', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Scale Activity Report' WHERE strMenuName = 'Scale Activity' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Unsent Tickets' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Unsent Tickets', N'Ticket Management', @TicketManagementReportParentMenuId, N'Unsent Tickets', N'Report', N'Report', N'Unsent Tickets Report', N'small-menu-report', 0, 0, 0, 1, 1, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Unsent Tickets Report' WHERE strMenuName = 'Unsent Tickets' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Production Evidence Report' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Production Evidence Report', N'Ticket Management', @TicketManagementReportParentMenuId, N'Production Evidence Report', N'Report', N'Screen', N'Reporting.view.ReportManager?group=TicketManagement&report=ProductionEvidenceReport&direct=true', N'small-menu-report', 0, 0, 0, 1, 2, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Reporting.view.ReportManager?group=Ticket Management&report=ProductionEvidenceReport&direct=true' WHERE strMenuName = 'Production Evidence Report' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementReportParentMenuId

/* LOGISTICS */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Logistics' AND strModuleName = 'Logistics' AND intParentMenuID = 0)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Logistics', N'Logistics', 0, N'Logistics', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 16, 2)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 16 WHERE strMenuName = 'Logistics' AND strModuleName = 'Logistics' AND intParentMenuID = 0

DECLARE @LogisticsParentMenuId INT
SELECT @LogisticsParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Logistics' AND strModuleName = 'Logistics' AND intParentMenuID = 0

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

/* ADD TO RESPECTIVE CATEGORY */ 
UPDATE tblSMMasterMenu SET intParentMenuID = @LogisticsActivitiesParentMenuId WHERE intParentMenuID =  @LogisticsParentMenuId AND strCategory = 'Activity'
UPDATE tblSMMasterMenu SET intParentMenuID = @LogisticsMaintenanceParentMenuId WHERE intParentMenuID =  @LogisticsParentMenuId AND strCategory = 'Maintenance'

/* START OF PLURALIZING */
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Load Schedule' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsActivitiesParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Load Schedules', strDescription = 'Load Schedules' WHERE strMenuName = 'Load Schedule' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsActivitiesParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Container Type' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsActivitiesParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Container Types', strDescription = 'Container Types' WHERE strMenuName = 'Container Type' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsActivitiesParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Shipping Line' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsActivitiesParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Shipping Lines', strDescription = 'Shipping Lines' WHERE strMenuName = 'Shipping Line' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsActivitiesParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Forwarding Agent' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Forwarding Agents', strDescription = 'Forwarding Agents' WHERE strMenuName = 'Forwarding Agent' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Trucker' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Truckers', strDescription = 'Truckers' WHERE strMenuName = 'Trucker' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Terminal' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Terminals', strDescription = 'Terminals' WHERE strMenuName = 'Terminal' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsMaintenanceParentMenuId
/* END OF PLURALIZING */

/* START OF RENAMING  */
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Dispatch Loads' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsActivitiesParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Mass Dispatch Loads' WHERE strMenuName = 'Dispatch Loads' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsActivitiesParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Load Schedules' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsActivitiesParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Load / Shipment Schedules', strDescription = 'Load / Shipment Schedules' WHERE strMenuName = 'Load Schedules' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsActivitiesParentMenuId
/* END OF RENAMING  */

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Allocations' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Allocations', N'Logistics', @LogisticsActivitiesParentMenuId, N'Allocations', N'Activity', N'Screen', N'Logistics.view.Allocation?showSearch=true', N'small-menu-activity', 0, 0, 0, 1, 1, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Logistics.view.Allocation?showSearch=true', intSort = 1 WHERE strMenuName = 'Allocations' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Load / Shipment Schedules' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Load / Shipment Schedules', N'Logistics', @LogisticsActivitiesParentMenuId, N'Logistics', N'Activity', N'Screen', N'Logistics.view.ShipmentSchedule?showSearch=true', N'small-menu-activity', 0, 0, 0, 1, 2, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Logistics.view.ShipmentSchedule?showSearch=true', intSort = 2 WHERE strMenuName = 'Load / Shipment Schedules' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Pick Lots' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Pick Lots', N'Logistics', @LogisticsActivitiesParentMenuId, N'Pick Lots', N'Activity', N'Screen', N'Logistics.view.PickLot?showSearch=true', N'small-menu-activity', 0, 0, 0, 1, 3, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Logistics.view.PickLot?showSearch=true', intSort = 3 WHERE strMenuName = 'Pick Lots' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Stock Sales' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Stock Sales', N'Logistics', @LogisticsActivitiesParentMenuId, N'Stock Sales', N'Activity', N'Screen', N'Logistics.view.StockSales?showSearch=true', N'small-menu-activity', 0, 0, 0, 1, 4, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Logistics.view.StockSales?showSearch=true', intSort = 4 WHERE strMenuName = 'Stock Sales' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Least Cost Routing' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Least Cost Routing', N'Logistics', @LogisticsActivitiesParentMenuId, N'Least Cost Routing', N'Activity', N'Screen', N'Logistics.view.LeastCostRouting?showSearch=true', N'small-menu-activity', 0, 0, 0, 1, 5, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Logistics.view.LeastCostRouting?showSearch=true', intSort = 5 WHERE strMenuName = 'Least Cost Routing' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Weight Claims' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Weight Claims', N'Logistics', @LogisticsActivitiesParentMenuId, N'Weight Claims', N'Activity', N'Screen', N'Logistics.view.WeightClaims?showSearch=true', N'small-menu-activity', 0, 0, 0, 1, 6, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Logistics.view.WeightClaims?showSearch=true', intSort = 6 WHERE strMenuName = 'Weight Claims' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Container Types' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Container Types', N'Logistics', @LogisticsActivitiesParentMenuId, N'Container Types', N'Activity', N'Screen', N'Logistics.view.ContainerType?showSearch=true', N'small-menu-activity', 0, 0, 0, 1, 7, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Logistics.view.ContainerType?showSearch=true', intSort = 7 WHERE strMenuName = 'Container Types' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Equipment Type' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Equipment Type', N'Logistics', @LogisticsMaintenanceParentMenuId, N'Equipment Type', N'Maintenance', N'Screen', N'Logistics.view.EquipmentType', N'small-menu-maintenance', 0, 0, 0, 1, 6, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 6, strCommand = N'Logistics.view.EquipmentType' WHERE strMenuName = 'Equipment Type' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Shipping Lines' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Shipping Lines', N'Logistics', @LogisticsMaintenanceParentMenuId, N'Shipping Lines', N'Maintenance', N'Screen', N'AccountsPayable.view.EntityVendor?showSearch=true&searchCommand=EntityShippingLine', N'small-menu-maintenance', 0, 0, 0, 1, 7, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 7, strCommand = N'AccountsPayable.view.EntityVendor?showSearch=true&searchCommand=EntityShippingLine' WHERE strMenuName = 'Shipping Lines' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Forwarding Agents' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Forwarding Agents', N'Logistics', @LogisticsMaintenanceParentMenuId, N'Forwarding Agents', N'Maintenance', N'Screen', N'AccountsPayable.view.EntityVendor?showSearch=true&searchCommand=EntityForwardingAgent', N'small-menu-maintenance', 0, 0, 0, 1, 8, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 8, strCommand = N'AccountsPayable.view.EntityVendor?showSearch=true&searchCommand=EntityForwardingAgent' WHERE strMenuName = 'Forwarding Agents' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Terminals' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Terminals', N'Logistics', @LogisticsMaintenanceParentMenuId, N'Terminals', N'Maintenance', N'Screen', N'AccountsPayable.view.EntityVendor?showSearch=true&searchCommand=EntityTerminal', N'small-menu-maintenance', 0, 0, 0, 1, 9, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 9, strCommand = N'AccountsPayable.view.EntityVendor?showSearch=true&searchCommand=EntityTerminal' WHERE strMenuName = 'Terminals' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Warehouse Rate Matrix' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Warehouse Rate Matrix', N'Logistics', @LogisticsActivitiesParentMenuId, N'Warehouse Rate Matrix', N'Activity', N'Screen', N'Logistics.view.WarehouseRateMatrix?showSearch=true', N'small-menu-activity', 0, 0, 0, 1, 12, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Logistics.view.WarehouseRateMatrix?showSearch=true', intSort = 12 WHERE strMenuName = 'Warehouse Rate Matrix' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Insurer' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Insurer', N'Logistics', @LogisticsMaintenanceParentMenuId, N'Insurer', N'Maintenance', N'Screen', N'AccountsPayable.view.EntityVendor?showSearch=true&searchCommand=EntityInsurer', N'small-menu-maintenance', 0, 0, 0, 1, 11, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 11, strCommand = N'AccountsPayable.view.EntityVendor?showSearch=true&searchCommand=EntityInsurer' WHERE strMenuName = 'Insurer' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Shipping Mode' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Shipping Mode', N'Logistics', @LogisticsMaintenanceParentMenuId, N'Shipping Mode', N'Maintenance', N'Screen', N'Logistics.view.ShippingMode', N'small-menu-maintenance', 0, 0, 0, 1, 12, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 12, strCommand = N'Logistics.view.ShippingMode' WHERE strMenuName = 'Shipping Mode' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Reason Code' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Reason Code', N'Logistics', @LogisticsMaintenanceParentMenuId, N'Reason Code', N'Maintenance', N'Screen', N'Logistics.view.ReasonCode', N'small-menu-maintenance', 0, 0, 0, 1, 13, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 13, strCommand = N'Logistics.view.ReasonCode' WHERE strMenuName = 'Reason Code' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsMaintenanceParentMenuId

/* START OF DELETING */
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Allocated Contracts List' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Unallocated Contracts List' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Shipments List' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Generate Loads' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Delivery Orders' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Mass Dispatch Loads' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsMaintenanceParentMenuId
--DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Weight Claims' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Shipping Instructions' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Inbound Shipments' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Truckers' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsMaintenanceParentMenuId
/* END OF DELETING */

/* MANUFACTURING */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Manufacturing' AND strModuleName = 'Manufacturing' AND intParentMenuID = 0)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Manufacturing', N'Manufacturing', 0, N'Manufacturing', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 17, 0)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 17 WHERE strMenuName = 'Manufacturing' AND strModuleName = 'Manufacturing' AND intParentMenuID = 0

DECLARE @ManufacturingParentMenuId INT
SELECT @ManufacturingParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Manufacturing' AND strModuleName = 'Manufacturing' AND intParentMenuID = 0

/* CATEGORY FOLDERS */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Activities' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Activities', N'Manufacturing', @ManufacturingParentMenuId, N'Activities', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 0 WHERE strMenuName = 'Activities' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingParentMenuId

DECLARE @ManufacturingActivitiesParentMenuId INT
SELECT @ManufacturingActivitiesParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Activities' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Maintenance', N'Manufacturing', @ManufacturingParentMenuId, N'Maintenance', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 1, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 1 WHERE strMenuName = 'Maintenance' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingParentMenuId

DECLARE @ManufacturingMaintenanceParentMenuId INT
SELECT @ManufacturingMaintenanceParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingParentMenuId

/* ADD TO RESPECTIVE CATEGORY */ 
UPDATE tblSMMasterMenu SET intParentMenuID = @ManufacturingActivitiesParentMenuId WHERE intParentMenuID =  @ManufacturingParentMenuId AND strCategory = 'Activity'
UPDATE tblSMMasterMenu SET intParentMenuID = @ManufacturingMaintenanceParentMenuId WHERE intParentMenuID =  @ManufacturingParentMenuId AND strCategory = 'Maintenance'

/* START OF PLURALIZING */
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Blend Requirement' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingActivitiesParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Blend Requirements', strDescription = 'Blend Requirements' WHERE strMenuName = 'Blend Requirement' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingActivitiesParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Bag Off' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingActivitiesParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Bag Offs', strDescription = 'Bag Offs' WHERE strMenuName = 'Bag Off' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingActivitiesParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Recipe' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Recipes', strDescription = 'Recipes' WHERE strMenuName = 'Recipe' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingMaintenanceParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Manufacturing Cell' AND strModuleName = 'Inventory' AND intParentMenuID = @ManufacturingMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Manufacturing Cells', strDescription = 'Manufacturing Cells' WHERE strMenuName = 'Manufacturing Cell' AND strModuleName = 'Inventory' AND intParentMenuID = @ManufacturingMaintenanceParentMenuId
/* END OF PLURALIZING */

/* Start of Rename and Remodule */
UPDATE tblSMMasterMenu SET strMenuName = N'Production Runs View' WHERE strMenuName = 'Process Production Runs View' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingActivitiesParentMenuId
UPDATE tblSMMasterMenu SET strModuleName = 'Manufacturing', intParentMenuID = @ManufacturingActivitiesParentMenuId WHERE strMenuName IN ('Demand Analysis View','Blend Demand') AND strModuleName = 'Contract Management'
UPDATE tblSMMasterMenu SET strCommand = N'Manufacturing.view.ManufacturingCell', strModuleName = 'Manufacturing' WHERE strMenuName = 'Manufacturing Cells' AND strModuleName = 'Inventory' AND intParentMenuID = @ManufacturingActivitiesParentMenuId
/* End of Rename and Remodule */

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Blend Requirements' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Blend Requirements', N'Manufacturing', @ManufacturingActivitiesParentMenuId, N'Blend Requirements', N'Activity', N'Screen', N'Manufacturing.view.BlendRequirementManager', N'small-menu-activity', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Manufacturing.view.BlendRequirementManager' WHERE strMenuName = 'Blend Requirements' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Blend Management' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Blend Management', N'Manufacturing', @ManufacturingActivitiesParentMenuId, N'Blend Management', N'Activity', N'Screen', N'Manufacturing.view.BlendManagemen?showSearch=true', N'small-menu-activity', 0, 0, 0, 1, 1, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 1, strCommand = N'Manufacturing.view.BlendManagement?showSearch=true' WHERE strMenuName = 'Blend Management' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Blend Production' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Blend Production', N'Manufacturing', @ManufacturingActivitiesParentMenuId, N'Blend Production', N'Activity', N'Screen', N'Manufacturing.view.BlendProduction', N'small-menu-activity', 0, 0, 0, 1, 2, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 2, strCommand = N'Manufacturing.view.BlendProduction' WHERE strMenuName = 'Blend Production' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Bag Offs' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Bag Offs', N'Manufacturing', @ManufacturingActivitiesParentMenuId, N'Bag Offs', N'Activity', N'Screen', N'Manufacturing.view.BagOff', N'small-menu-activity', 0, 0, 0, 1, 3, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 3, strCommand = N'Manufacturing.view.BagOff' WHERE strMenuName = 'Bag Offs' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Release To Warehouse' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Release To Warehouse', N'Manufacturing', @ManufacturingActivitiesParentMenuId, N'Release To Warehouse', N'Activity', N'Screen', N'Manufacturing.view.ReleaseToWarehouse', N'small-menu-activity', 0, 0, 0, 1, 4, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 4, strCommand = N'Manufacturing.view.ReleaseToWarehouse' WHERE strMenuName = 'Release To Warehouse' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Kit Manager' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Kit Manager', N'Manufacturing', @ManufacturingActivitiesParentMenuId, N'Kit Manager', N'Activity', N'Screen', N'Manufacturing.view.KitManager', N'small-menu-activity', 0, 0, 0, 1, 5, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 5, strCommand = N'Manufacturing.view.KitManager' WHERE strMenuName = 'Kit Manager' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Blend Sheet Approval' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Blend Sheet Approval', N'Manufacturing', @ManufacturingActivitiesParentMenuId, N'Blend Sheet Approval', N'Activity', N'Screen', N'Manufacturing.view.BlendSheetApproval', N'small-menu-activity', 0, 0, 0, 1, 6, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 6, strCommand = N'Manufacturing.view.BlendSheetApproval' WHERE strMenuName = 'Blend Sheet Approval' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Traceability' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Traceability', N'Manufacturing', @ManufacturingActivitiesParentMenuId, N'Traceability', N'Activity', N'Screen', N'Manufacturing.view.TraceabilityDiagram', N'small-menu-activity', 0, 0, 0, 1, 7, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 7, strCommand = N'Manufacturing.view.TraceabilityDiagram' WHERE strMenuName = 'Traceability' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Work Order Planning' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Work Order Planning', N'Manufacturing', @ManufacturingActivitiesParentMenuId, N'Work Order Planning', N'Activity', N'Screen', N'Manufacturing.view.WorkOrderCreation', N'small-menu-activity', 0, 0, 0, 1, 8, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 8, strCommand = N'Manufacturing.view.WorkOrderCreation' WHERE strMenuName = 'Work Order Planning' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Work Order Management' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Work Order Management', N'Manufacturing', @ManufacturingActivitiesParentMenuId, N'Work Order Management', N'Activity', N'Screen', N'Manufacturing.view.WorkOrder?showSearch=true', N'small-menu-activity', 0, 0, 0, 1, 9, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 9, strCommand = N'Manufacturing.view.WorkOrder?showSearch=true' WHERE strMenuName = 'Work Order Management' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Work Order Schedule' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Work Order Schedule', N'Manufacturing', @ManufacturingActivitiesParentMenuId, N'Work Order Schedule', N'Activity', N'Screen', N'Manufacturing.view.Schedule?showSearch=true', N'small-menu-activity', 0, 0, 0, 1, 10, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 10, strCommand = N'Manufacturing.view.Schedule?showSearch=true' WHERE strMenuName = 'Work Order Schedule' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Finished Goods Production' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Finished Goods Production', N'Manufacturing', @ManufacturingActivitiesParentMenuId, N'Finished Goods Production', N'Activity', N'Screen', N'Manufacturing.view.FinishedGoodsProduction', N'small-menu-activity', 0, 0, 0, 1, 11, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 11, strCommand = N'Manufacturing.view.FinishedGoodsProduction' WHERE strMenuName = 'Finished Goods Production' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingActivitiesParentMenuId
	
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Transaction View' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Transaction View', N'Manufacturing', @ManufacturingActivitiesParentMenuId, N'Transaction View', N'Activity', N'Screen', N'Manufacturing.view.TransactionView?showSearch=true', N'small-menu-activity', 0, 0, 0, 1, 12, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 12, strCommand = N'Manufacturing.view.TransactionView?showSearch=true' WHERE strMenuName = 'Transaction View' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Production Runs View' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Production Runs View', N'Manufacturing', @ManufacturingActivitiesParentMenuId, N'Production Runs View', N'Activity', N'Screen', N'Manufacturing.view.ProcessProductionRunsView?showSearch=true', N'small-menu-activity', 0, 0, 0, 1, 13, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 13, strCommand = N'Manufacturing.view.ProcessProductionRunsView?showSearch=true' WHERE strMenuName = 'Production Runs View' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Traceability By Parent Lot' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Traceability By Parent Lot', N'Manufacturing', @ManufacturingActivitiesParentMenuId, N'Traceability By Parent Lot', N'Activity', N'Screen', N'Manufacturing.view.TraceabilityDiagram?ysnParentLot=true', N'small-menu-activity', 0, 0, 0, 1, 14, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 14, strCommand = N'Manufacturing.view.TraceabilityDiagram?ysnParentLot=true' WHERE strMenuName = 'Traceability By Parent Lot' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Blend Consolidation View' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Blend Consolidation View', N'Manufacturing', @ManufacturingActivitiesParentMenuId, N'Blend Consolidation View', N'Activity', N'Screen', N'Manufacturing.view.GenericTransactionView?showSearch=true', N'small-menu-activity', 0, 0, 0, 1, 15, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 15, strCommand = N'Manufacturing.view.GenericTransactionView?showSearch=true' WHERE strMenuName = 'Blend Consolidation View' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Yield View' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Yield View', N'Manufacturing', @ManufacturingActivitiesParentMenuId, N'Yield View', N'Activity', N'Screen', N'Manufacturing.view.YieldView', N'small-menu-activity', 0, 0, 0, 1, 16, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 16, strCommand = N'Manufacturing.view.YieldView' WHERE strMenuName = 'Yield View' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Efficiency Views' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Efficiency Views', N'Manufacturing', @ManufacturingActivitiesParentMenuId, N'Efficiency Views', N'Activity', N'Screen', N'Manufacturing.view.ShiftActivityView?showSearch=true', N'small-menu-activity', 1, 0, 0, 1, 17, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 17, strCommand = N'Manufacturing.view.ShiftActivityView?showSearch=true' WHERE strMenuName = 'Efficiency Views' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Inventory View' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Inventory View', N'Manufacturing', @ManufacturingActivitiesParentMenuId, N'Inventory View', N'Activity', N'Screen', N'Manufacturing.view.InventoryView?showSearch=true', N'small-menu-activity', 1, 0, 0, 1, 18, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 18, strCommand = N'Manufacturing.view.InventoryView?showSearch=true', strType = N'Screen' WHERE strMenuName = 'Inventory View' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Shift Activity' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Shift Activity', N'Manufacturing', @ManufacturingActivitiesParentMenuId, N'Shift Activity', N'Activity', N'Screen', N'Manufacturing.view.EfficiencyShiftActivity', N'small-menu-activity', 1, 0, 0, 1, 19, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 19, strCommand = N'Manufacturing.view.EfficiencyShiftActivity', strType = N'Screen' WHERE strMenuName = 'Shift Activity' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Finished Goods Forecast' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Finished Goods Forecast', N'Manufacturing', @ManufacturingActivitiesParentMenuId, N'Finished Goods Forecast', N'Activity', N'Screen', N'Manufacturing.view.FinishedGoodsForecast', N'small-menu-activity', 0, 0, 0, 1, 20, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 20, strCommand = N'Manufacturing.view.FinishedGoodsForecast' WHERE strMenuName = 'Finished Goods Forecast' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Demand Analysis View' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Demand Analysis View', N'Manufacturing', @ManufacturingMaintenanceParentMenuId, N'Demand Analysis View', N'Maintenance', N'Screen', N'Manufacturing.view.DemandAnalysisView?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 21, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 21, strCommand = N'Manufacturing.view.DemandAnalysisView?showSearch=true' WHERE strMenuName = 'Demand Analysis View' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Manufacturing Process' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Manufacturing Process', N'Manufacturing', @ManufacturingMaintenanceParentMenuId, N'Manufacturing Process', N'Maintenance', N'Screen', N'Manufacturing.view.ManufacturingProcess?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 22, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 22, strCommand = N'Manufacturing.view.ManufacturingProcess?showSearch=true' WHERE strMenuName = 'Manufacturing Process' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Recipes' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Recipes', N'Manufacturing', @ManufacturingMaintenanceParentMenuId, N'Recipes', N'Maintenance', N'Screen', N'Manufacturing.view.Recipe?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 23, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 23, strCommand = N'Manufacturing.view.Recipe?showSearch=true' WHERE strMenuName = 'Recipes' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Manufacturing Cells / Machines' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Manufacturing Cells / Machines', N'Manufacturing', @ManufacturingMaintenanceParentMenuId, N'Manufacturing Cells / Machines', N'Maintenance', N'Screen', N'Manufacturing.view.ManufacturingCell?showSearch=true', N'small-menu-maintenance', 1, 1, 0, 1, 24, 0)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 24, strCommand = N'Manufacturing.view.ManufacturingCell?showSearch=true' WHERE strMenuName = 'Manufacturing Cells / Machines' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Shifts' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Shifts', N'Manufacturing', @ManufacturingMaintenanceParentMenuId, N'Shifts', N'Maintenance', N'Screen', N'Manufacturing.view.Shift', N'small-menu-maintenance', 0, 0, 0, 1, 25, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 25, strCommand = N'Manufacturing.view.Shift' WHERE strMenuName = 'Shifts' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Production Calendar' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Production Calendar', N'Manufacturing', @ManufacturingMaintenanceParentMenuId, N'Production Calendar', N'Maintenance', N'Screen', N'Manufacturing.view.ProductionCalendar?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 26, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 26, strCommand = N'Manufacturing.view.ProductionCalendar?showSearch=true' WHERE strMenuName = 'Production Calendar' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingMaintenanceParentMenuId
	
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Production Schedule Rules' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Production Schedule Rules', N'Manufacturing', @ManufacturingMaintenanceParentMenuId, N'Production Schedule Rules', N'Maintenance', N'Screen', N'Manufacturing.view.ProductionScheduleRules?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 27, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 27, strCommand = N'Manufacturing.view.ProductionScheduleRules?showSearch=true' WHERE strMenuName = 'Production Schedule Rules' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Reason' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Reason', N'Manufacturing', @ManufacturingMaintenanceParentMenuId, N'Reason', N'Maintenance', N'Screen', N'Manufacturing.view.Reason?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 28, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 28, strCommand = N'Manufacturing.view.Reason?showSearch=true' WHERE strMenuName = 'Reason' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Scheduled Maintenance' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Scheduled Maintenance', N'Manufacturing', @ManufacturingMaintenanceParentMenuId, N'Scheduled Maintenance', N'Maintenance', N'Screen', N'Manufacturing.view.ScheduledMaintenance', N'small-menu-maintenance', 0, 0, 0, 1, 29, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 29, strCommand = N'Manufacturing.view.ScheduledMaintenance' WHERE strMenuName = 'Scheduled Maintenance' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingMaintenanceParentMenuId

/* Start of Delete */
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Process Production Produce' AND strModuleName = 'Manufacturing'
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Process Production Consume' AND strModuleName = 'Manufacturing'
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Work Order Staging' AND strModuleName = 'Manufacturing'
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
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Blend Demand' AND strModuleName = 'Manufacturing'
/* End of Delete */

/* TANK MANAGEMENT */
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Tank Management' AND strModuleName = 'Tank Management' AND intParentMenuID = 0)
UPDATE tblSMMasterMenu SET intSort = 18 WHERE strMenuName = 'Tank Management' AND strModuleName = 'Tank Management' AND intParentMenuID = 0

DECLARE @TankManagementParentMenuId INT
SELECT @TankManagementParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Tank Management' AND strModuleName = 'Tank Management' AND intParentMenuID = 0

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

/* ADD TO RESPECTIVE CATEGORY */ 
UPDATE tblSMMasterMenu SET intParentMenuID = @TankManagementActivitiesParentMenuId WHERE intParentMenuID =  @TankManagementParentMenuId AND strCategory = 'Activity'
UPDATE tblSMMasterMenu SET intParentMenuID = @TankManagementMaintenanceParentMenuId WHERE intParentMenuID =  @TankManagementParentMenuId AND strCategory = 'Maintenance'

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Reports' AND strModuleName = 'Tank Management' AND intParentMenuID = @TankManagementParentMenuId)
    INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
    VALUES (N'Reports', N'Tank Management', @TankManagementParentMenuId, N'Reports', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 2, 1)
ELSE
    UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 2 WHERE strMenuName = 'Reports' AND strModuleName = 'Tank Management' AND intParentMenuID = @TankManagementParentMenuId

DECLARE @TankManagementReportParentMenuId INT
SELECT @TankManagementReportParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Reports' AND strModuleName = 'Tank Management' AND intParentMenuID = @TankManagementParentMenuId

/* START OF PLURALIZING */
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Event Type' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementActivitiesParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Event Types', strDescription = 'Event Types' WHERE strMenuName = N'Event Type' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementActivitiesParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Device Type' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementActivitiesParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Device Types', strDescription = 'Device Types' WHERE strMenuName = N'Device Type' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementActivitiesParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Lease Code' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementActivitiesParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Lease Codes', strDescription = 'Lease Codes' WHERE strMenuName = N'Lease Code' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementActivitiesParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Event Automation Setup' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementActivitiesParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Event Automation', strDescription = 'Event Automation' WHERE strMenuName = N'Event Automation Setup' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementActivitiesParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Meter Type' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementActivitiesParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Meter Types', strDescription = 'Meter Types' WHERE strMenuName = N'Meter Type' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementActivitiesParentMenuId
/* END OF PLURALIZING */

/* Start of moving report */
UPDATE tblSMMasterMenu SET intParentMenuID = @TankManagementReportParentMenuId WHERE strMenuName = 'Device Lease Detail' AND strModuleName = 'Tank Management' AND strType = 'Report' AND intParentMenuID = @TankManagementParentMenuId
UPDATE tblSMMasterMenu SET intParentMenuID = @TankManagementReportParentMenuId WHERE strMenuName = 'On Hold Detail' AND strModuleName = 'Tank Management' AND strType = 'Report' AND intParentMenuID = @TankManagementParentMenuId
UPDATE tblSMMasterMenu SET intParentMenuID = @TankManagementReportParentMenuId WHERE strMenuName = 'Delivery Fill Report' AND strModuleName = 'Tank Management' AND strCategory = 'Report' AND intParentMenuID = @TankManagementParentMenuId
UPDATE tblSMMasterMenu SET intParentMenuID = @TankManagementReportParentMenuId WHERE strMenuName = 'Two-Part Delivery Fill Report' AND strModuleName = 'Tank Management' AND strType = 'Report' AND intParentMenuID = @TankManagementParentMenuId
UPDATE tblSMMasterMenu SET intParentMenuID = @TankManagementReportParentMenuId WHERE strMenuName = 'Missed Julian Deliveries' AND strModuleName = 'Tank Management' AND strType = 'Report' AND intParentMenuID = @TankManagementParentMenuId
UPDATE tblSMMasterMenu SET intParentMenuID = @TankManagementReportParentMenuId WHERE strMenuName = 'Out of Range Burn Rates' AND strModuleName = 'Tank Management' AND strType = 'Report' AND intParentMenuID = @TankManagementParentMenuId
UPDATE tblSMMasterMenu SET intParentMenuID = @TankManagementReportParentMenuId WHERE strMenuName = 'Call Entry Printout' AND strModuleName = 'Tank Management' AND strCategory = 'Report' AND intParentMenuID = @TankManagementParentMenuId
UPDATE tblSMMasterMenu SET intParentMenuID = @TankManagementReportParentMenuId WHERE strMenuName = 'Fill Group' AND strModuleName = 'Tank Management' AND strType = 'Report' AND intParentMenuID = @TankManagementParentMenuId
UPDATE tblSMMasterMenu SET intParentMenuID = @TankManagementReportParentMenuId WHERE strMenuName = 'Tank Inventory' AND strModuleName = 'Tank Management' AND strType = 'Report' AND intParentMenuID = @TankManagementParentMenuId
UPDATE tblSMMasterMenu SET intParentMenuID = @TankManagementReportParentMenuId WHERE strMenuName = 'Customer List by Route' AND strModuleName = 'Tank Management' AND strType = 'Report' AND intParentMenuID = @TankManagementParentMenuId
UPDATE tblSMMasterMenu SET intParentMenuID = @TankManagementReportParentMenuId WHERE strMenuName = 'Device Actions' AND strModuleName = 'Tank Management' AND strType = 'Report' AND intParentMenuID = @TankManagementParentMenuId
UPDATE tblSMMasterMenu SET intParentMenuID = @TankManagementReportParentMenuId WHERE strMenuName = 'Leak Check / Gas Check' AND strModuleName = 'Tank Management' AND strType = 'Report' AND intParentMenuID = @TankManagementParentMenuId
/* End of moving report */

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Customer Inquiry' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementActivitiesParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 0, strCommand = N'TankManagement.view.CustomerInquiry?showSearch=true' WHERE strMenuName = N'Customer Inquiry' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementActivitiesParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Consumption Sites' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementActivitiesParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 1, strCommand = N'TankManagement.view.ConsumptionSite?showSearch=true' WHERE strMenuName = N'Consumption Sites' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementActivitiesParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Clock Reading' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementActivitiesParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 2, strCommand = N'TankManagement.view.ClockReading?showSearch=true' WHERE strMenuName = N'Clock Reading' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementActivitiesParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Synchronize Delivery History' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementActivitiesParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 3, strCommand = N'TankManagement.view.SyncDeliveryHistory' WHERE strMenuName = N'Synchronize Delivery History' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Generate Orders' AND strModuleName = 'Tank Management' AND intParentMenuID = @TankManagementActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Generate Orders', N'Tank Management', @TankManagementActivitiesParentMenuId, N'Generate Orders', N'Activity', N'Screen', N'TankManagement.view.GenerateOrder', N'small-menu-activity', 0, 0, 0, 1, 4, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 4, strCommand = N'TankManagement.view.GenerateOrder' WHERE strMenuName = 'Generate Orders' AND strModuleName = 'Tank Management' AND intParentMenuID = @TankManagementActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Tank Monitor' AND strModuleName = 'Tank Management' AND intParentMenuID = @TankManagementActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Tank Monitor', N'Tank Management', @TankManagementActivitiesParentMenuId, N'Tank Monitor', N'Activity', N'Screen', N'TankManagement.view.ImportWesroc', N'small-menu-activity', 0, 0, 0, 1, 5, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 5, strCommand = N'TankManagement.view.ImportWesroc' WHERE strMenuName = 'Tank Monitor' AND strModuleName = 'Tank Management' AND intParentMenuID = @TankManagementActivitiesParentMenuId

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

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Lease' AND strModuleName = 'Tank Management' AND intParentMenuID = @TankManagementActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Lease', N'Tank Management', @TankManagementActivitiesParentMenuId, N'Lease', N'Activity', N'Screen', N'TankManagement.view.Lease?showSearch=true', N'small-menu-activity', 0, 0, 0, 1, 8, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 8, strCategory = N'Activity', strIcon = N'small-menu-activity', strCommand = N'TankManagement.view.Lease?showSearch=true' WHERE strMenuName = 'Lease' AND strModuleName = 'Tank Management' AND intParentMenuID = @TankManagementActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Deliveries' AND strModuleName = 'Tank Management' AND strType = 'Screen' AND intParentMenuID = @TankManagementMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Deliveries', N'Tank Management', @TankManagementMaintenanceParentMenuId, N'Deliveries', N'Maintenance', N'Screen', N'TankManagement.view.Deliveries?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 9, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 9, strCommand = N'TankManagement.view.Deliveries?showSearch=true' WHERE strMenuName = 'Deliveries' AND strModuleName = 'Tank Management' AND strType = 'Screen' AND intParentMenuID = @TankManagementMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Generate Work Orders' AND strModuleName = 'Tank Management' AND strType = 'Screen' AND intParentMenuID = @TankManagementMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Generate Work Orders', N'Tank Management', @TankManagementMaintenanceParentMenuId, N'Generate Work Orders', N'Maintenance', N'Screen', N'TankManagement.view.GenerateWorkOrder', N'small-menu-maintenance', 0, 0, 0, 1, 10, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 10, strCommand = N'TankManagement.view.GenerateWorkOrder' WHERE strMenuName = 'Generate Work Orders' AND strModuleName = 'Tank Management' AND strType = 'Screen' AND intParentMenuID = @TankManagementMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Devices' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 11, strCommand = N'TankManagement.view.Device?showSearch=true' WHERE strMenuName = N'Devices' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Events' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 12, strCommand = N'TankManagement.view.Event?showSearch=true' WHERE strMenuName = N'Events' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Delivery Fill Report' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementReportParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 0, strType = N'Screen', strCommand = N'TankManagement.view.DeliveryFillReportParameter' WHERE strMenuName = N'Delivery Fill Report' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementReportParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Call Entry Printout' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementReportParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 1, strType = N'Screen', strCommand = N'TankManagement.view.CallEntryParameter' WHERE strMenuName = N'Call Entry Printout' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementReportParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Work Orders' AND strModuleName = 'Tank Management' AND intParentMenuID = @TankManagementReportParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Work Orders', N'Tank Management', @TankManagementReportParentMenuId, N'Work Orders', N'Report', N'Screen', N'Reporting.view.ReportManager?group=Tank Management&report=WorkOrder&direct=true&showCriteria=false', N'small-menu-report', 0, 0, 0, 1, 2, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 2, strCommand = N'Reporting.view.ReportManager?group=Tank Management&report=WorkOrder&direct=true&showCriteria=false' WHERE strMenuName = 'Work Orders' AND strModuleName = 'Tank Management' AND intParentMenuID = @TankManagementReportParentMenuId

/* START OF DELETING */
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Open Call Entries' AND strModuleName = N'Tank Management' AND strType = 'Report' AND intParentMenuID = @TankManagementMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Work Order Status' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Lease Billing Report' AND strModuleName = N'Tank Management' AND strType = 'Report' AND intParentMenuID = @TankManagementParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Open Call Entries' AND strModuleName = 'Tank Management' AND strType = 'Screen' AND intParentMenuID = @TankManagementMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Work Orders' AND strModuleName = 'Tank Management' AND strType = 'Screen' AND intParentMenuID = @TankManagementMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Resolve Sync Conflict' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Dispatch Deliveries' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Degree Day Clock' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Event Types' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Device Types' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Lease Codes' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Meter Types' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Clock Reading History' AND strModuleName = 'Tank Management' AND intParentMenuID = @TankManagementMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Lease Billing Incentive' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Event Automation' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Lease Billing' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementActivitiesParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Renew Julian Deliveries' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Missed Julian Deliveries' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementReportParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Device Actions' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementReportParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Device Lease Detail' AND strModuleName = 'Tank Management' AND intParentMenuID = @TankManagementReportParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Fill Group' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementReportParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Out of Range Burn Rates' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementReportParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Leak Check / Gas Check' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementReportParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'On Hold Detail' AND strModuleName = 'Tank Management' AND intParentMenuID = @TankManagementReportParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Customer List by Route' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementReportParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Two-Part Delivery Fill Report' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementReportParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Tank Inventory' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementReportParentMenuId
/* END OF DELETING */

/* CARD FUELING */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Card Fueling' AND strModuleName = 'Card Fueling' AND intParentMenuID = 0)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Card Fueling', N'Card Fueling', 0, N'Card Fueling', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 19, 1)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 19 WHERE strMenuName = 'Card Fueling' AND strModuleName = 'Card Fueling' AND intParentMenuID = 0

DECLARE @CardFuelingParentMenuId INT
SELECT @CardFuelingParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Card Fueling' AND strModuleName = 'Card Fueling' AND intParentMenuID = 0

/* CATEGORY FOLDERS */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Activities' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Activities', N'Card Fueling', @CardFuelingParentMenuId, N'Activities', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 0 WHERE strMenuName = 'Activities' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingParentMenuId

DECLARE @CardFuelingActivitiesParentMenuId INT
SELECT @CardFuelingActivitiesParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Activities' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Maintenance', N'Card Fueling', @CardFuelingParentMenuId, N'Maintenance', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 1, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 1 WHERE strMenuName = 'Maintenance' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingParentMenuId

DECLARE @CardFuelingMaintenanceParentMenuId INT
SELECT @CardFuelingMaintenanceParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingParentMenuId

/* ADD TO RESPECTIVE CATEGORY */ 
UPDATE tblSMMasterMenu SET intParentMenuID = @CardFuelingActivitiesParentMenuId WHERE intParentMenuID =  @CardFuelingParentMenuId AND strCategory = 'Activity'
UPDATE tblSMMasterMenu SET intParentMenuID = @CardFuelingMaintenanceParentMenuId WHERE intParentMenuID =  @CardFuelingParentMenuId AND strCategory = 'Maintenance'

/* START OF PLURALIZING */
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Index Pricing By Site Group' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Index Pricing by Site Groups', strDescription = 'Index Pricing by Site Groups' WHERE strMenuName = 'Index Pricing By Site Group' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Discount Schedule' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Discount Schedules', strDescription = 'Discount Schedules' WHERE strMenuName = 'Discount Schedule' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Fee Profile' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Fee Profiles', strDescription = 'Fee Profiles' WHERE strMenuName = 'Fee Profile' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Network' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Networks', strDescription = 'Networks' WHERE strMenuName = 'Network' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Price Profile' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Price Profiles', strDescription = 'Price Profiles' WHERE strMenuName = 'Price Profile' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Card Type' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Card Types', strDescription = 'Card Types' WHERE strMenuName = 'Card Type' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Fee' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Fees', strDescription = 'Fees' WHERE strMenuName = 'Fee' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName LIKE 'Invoice Cycle%' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Invoice Cycles', strDescription = 'Invoice Cycles' WHERE strMenuName LIKE 'Invoice Cycle%' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName LIKE 'Price Index%' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Price Indexes', strDescription = 'Price Indexes' WHERE strMenuName LIKE 'Price Index%' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName LIKE 'Price Rule Group%' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Price Rule Groups', strDescription = 'Price Rule Groups' WHERE strMenuName LIKE 'Price Rule Group%' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName LIKE 'Site Group%' AND strMenuName NOT LIKE 'Site Group Price Adjustment%' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Site Groups', strDescription = 'Site Groups' WHERE strMenuName LIKE 'Site Group%' AND strMenuName NOT LIKE 'Site Group Price Adjustment%' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName LIKE 'Site Group Price Adjustment%' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Site Group Price Adjustments', strDescription = 'Site Group Price Adjustments' WHERE strMenuName LIKE 'Site Group Price Adjustment%' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingMaintenanceParentMenuId
/* END OF PLURALIZING */

/* START OF RENAMING  */
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Accounts' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Card Accounts', strDescription = 'Card Accounts' WHERE strMenuName = 'Accounts' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Site Group Price Adjustments' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Remote Price Adjustments', strDescription = 'Remote Price Adjustments' WHERE strMenuName = 'Site Group Price Adjustments' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingMaintenanceParentMenuId
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

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Card Accounts' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Card Accounts', N'Card Fueling', @CardFuelingMaintenanceParentMenuId, N'Card Accounts', N'Maintenance', N'Screen', N'CardFueling.view.Account?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 2, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'CardFueling.view.Account?showSearch=true', intSort = 2 WHERE strMenuName = 'Card Accounts' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Remote Price Adjustments' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Remote Price Adjustments', N'Card Fueling', @CardFuelingMaintenanceParentMenuId, N'Remote Price Adjustments', N'Maintenance', N'Screen', N'CardFueling.view.SiteGroupPriceAdjustment', N'small-menu-maintenance', 0, 0, 0, 1, 3, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = N'CardFueling.view.SiteGroupPriceAdjustment', intSort = 3 WHERE strMenuName = 'Remote Price Adjustments' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Invoice' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Invoice', N'Card Fueling', @CardFuelingMaintenanceParentMenuId, N'Invoice', N'Maintenance', N'Screen', N'CardFueling.view.Invoice', N'small-menu-maintenance', 0, 0, 0, 1, 4, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = N'CardFueling.view.Invoice', intSort = 4 WHERE strMenuName = 'Invoice' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Setup' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Setup', N'Card Fueling', @CardFuelingMaintenanceParentMenuId, N'Setup', N'Maintenance', N'Screen', N'CardFueling.view.Maintenance', N'small-menu-maintenance', 0, 0, 0, 1, 5, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = N'CardFueling.view.Maintenance', intSort = 5 WHERE strMenuName = 'Setup' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingMaintenanceParentMenuId

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
/* END OF DELETION */

/* STORE */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Store' AND strModuleName = 'Store' AND intParentMenuID = 0)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Store', N'Store', 0, N'Store', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 20, 0)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 20 WHERE strMenuName = 'Store' AND strModuleName = 'Store' AND intParentMenuID = 0

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

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'Store' AND intParentMenuID = @StoreParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Maintenance', N'Store', @StoreParentMenuId, N'Maintenance', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 1, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 1 WHERE strMenuName = 'Maintenance' AND strModuleName = 'Store' AND intParentMenuID = @StoreParentMenuId

DECLARE @StoreMaintenanceParentMenuId INT
SELECT @StoreMaintenanceParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'Store' AND intParentMenuID = @StoreParentMenuId

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

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Update Item Pricing' AND strModuleName = 'Store' AND intParentMenuID = @StoreActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Update Item Pricing', N'Store', @StoreActivitiesParentMenuId, N'Update Item Pricing', N'Activity', N'Screen', N'Store.view.UpdateItemPricing', N'small-menu-activity', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 0, strCommand = N'Store.view.UpdateItemPricing' WHERE strMenuName = 'Update Item Pricing' AND strModuleName = 'Store' AND intParentMenuID = @StoreActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Update Rebate/Discount' AND strModuleName = 'Store' AND intParentMenuID = @StoreActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Update Rebate/Discount', N'Store', @StoreActivitiesParentMenuId, N'Update Rebate/Discount', N'Activity', N'Screen', N'Store.view.UpdateRebateDiscount', N'small-menu-activity', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 1, strCommand = N'Store.view.UpdateRebateDiscount' WHERE strMenuName = 'Update Rebate/Discount' AND strModuleName = 'Store' AND intParentMenuID = @StoreActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Update Item Data' AND strModuleName = 'Store' AND intParentMenuID = @StoreActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Update Item Data', N'Store', @StoreActivitiesParentMenuId, N'Update Item Data', N'Activity', N'Screen', N'Store.view.UpdateItemData', N'small-menu-activity', 0, 0, 0, 1, 2, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 2, strCommand = N'Store.view.UpdateItemData' WHERE strMenuName = 'Update Item Data' AND strModuleName = 'Store' AND intParentMenuID = @StoreActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Inventory Mass' AND strModuleName = 'Store' AND intParentMenuID = @StoreActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Inventory Mass', N'Store', @StoreActivitiesParentMenuId, N'Inventory Mass', N'Activity', N'Screen', N'Store.view.InventoryMassMaintenance', N'small-menu-activity', 0, 0, 0, 1, 3, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 3, strCommand = N'Store.view.InventoryMassMaintenance' WHERE strMenuName = 'Inventory Mass' AND strModuleName = 'Store' AND intParentMenuID = @StoreActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Update Register' AND strModuleName = 'Store' AND intParentMenuID = @StoreActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Update Register', N'Store', @StoreActivitiesParentMenuId, N'Update Register', N'Activity', N'Screen', N'Store.view.UpdateRegister', N'small-menu-activity', 1, 0, 0, 1, 4, 1)
ELSE 
	UPDATE tblSMMasterMenu SET  intSort = 4, strCommand = N'Store.view.UpdateRegister' , ysnVisible = 1 WHERE strMenuName = 'Update Register' AND strModuleName = 'Store' AND intParentMenuID = @StoreActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Mark Up/Down' AND strModuleName = 'Store' AND intParentMenuID = @StoreActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Mark Up/Down', N'Store', @StoreActivitiesParentMenuId, N'Mark Up/Down', N'Activity', N'Screen', N'Store.view.MarkUpDown?showSearch=true&searchCommand=SearchMarkUpDown', N'small-menu-activity', 1, 0, 0, 1, 5, 1)
ELSE 
	UPDATE tblSMMasterMenu SET  intSort = 5, strCommand = N'Store.view.MarkUpDown?showSearch=true&searchCommand=SearchMarkUpDown' , ysnVisible = 1 WHERE strMenuName = 'Mark Up/Down' AND strModuleName = 'Store' AND intParentMenuID = @StoreActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Checkout' AND strModuleName = 'Store' AND intParentMenuID = @StoreActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Checkout', N'Store', @StoreActivitiesParentMenuId, N'Checkout', N'Activity', N'Screen', N'Store.view.CheckoutHeader?showSearch=true&searchCommand=SearchCheckoutHeader', N'small-menu-activity', 1, 0, 0, 1, 6, 1)
ELSE 
	UPDATE tblSMMasterMenu SET  intSort = 6, strCommand = N'Store.view.CheckoutHeader?showSearch=true&searchCommand=SearchCheckoutHeader', ysnVisible = 1 WHERE strMenuName = 'Checkout' AND strModuleName = 'Store' AND intParentMenuID = @StoreActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Stores' AND strModuleName = 'Store' AND intParentMenuID = @StoreMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Stores', N'Store', @StoreMaintenanceParentMenuId, N'Stores', N'Maintenance', N'Screen', N'Store.view.Store?showSearch=true&searchCommand=SearchStore', N'small-menu-maintenance', 0, 0, 0, 1, 7, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 7, strCommand = N'Store.view.Store?showSearch=true&searchCommand=SearchStore' WHERE strMenuName = 'Stores' AND strModuleName = 'Store' AND intParentMenuID = @StoreMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Registers' AND strModuleName = 'Store' AND intParentMenuID = @StoreMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Registers', N'Store', @StoreMaintenanceParentMenuId, N'Registers', N'Maintenance', N'Screen', N'Store.view.Register?showSearch=true&searchCommand=SearchRegister', N'small-menu-maintenance', 0, 0, 0, 1, 8, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 8, strCommand = N'Store.view.Register?showSearch=true&searchCommand=SearchRegister' WHERE strMenuName = 'Registers' AND strModuleName = 'Store' AND intParentMenuID = @StoreMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Subcategories' AND strModuleName = 'Store' AND intParentMenuID = @StoreMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Subcategories', N'Store', @StoreMaintenanceParentMenuId, N'Subcategories', N'Maintenance', N'Screen', N'Store.view.SubCategory', N'small-menu-maintenance', 0, 0, 0, 1, 9, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 9, strCommand = N'Store.view.SubCategory' WHERE strMenuName = 'Subcategories' AND strModuleName = 'Store' AND intParentMenuID = @StoreMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Retail Price Adjustments' AND strModuleName = 'Store' AND intParentMenuID = @StoreMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Retail Price Adjustments', N'Store', @StoreMaintenanceParentMenuId, N'Retail Price Adjustments', N'Maintenance', N'Screen', N'Store.view.RetailPriceAdjustment?showSearch=true&searchCommand=SearchRetailPriceAdjustment', N'small-menu-maintenance', 0, 0, 0, 1, 10, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 10, strCommand = N'Store.view.RetailPriceAdjustment?showSearch=true&searchCommand=SearchRetailPriceAdjustment' WHERE strMenuName = 'Retail Price Adjustments' AND strModuleName = 'Store' AND intParentMenuID = @StoreMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Promotions' AND strModuleName = 'Store' AND intParentMenuID = @StoreMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Promotions', N'Store', @StoreMaintenanceParentMenuId, N'Promotions', N'Maintenance', N'Screen', N'Store.view.Promotions?showSearch=true&searchCommand=SearchPromotions', N'small-menu-maintenance', 0, 0, 0, 1, 11, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 11, strCommand = N'Store.view.Promotions?showSearch=true&searchCommand=SearchPromotions' WHERE strMenuName = 'Promotions' AND strModuleName = 'Store' AND intParentMenuID = @StoreMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Generate Vendor Rebate File' AND strModuleName = 'Store' AND intParentMenuID = @StoreMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Generate Vendor Rebate File', N'Store', @StoreMaintenanceParentMenuId, N'Generate Vendor Rebate File', N'Maintenance', N'Screen', N'Store.view.GenerateVendorRebateFile', N'small-menu-maintenance', 0, 0, 0, 1, 12, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 12, strCommand = N'Store.view.GenerateVendorRebateFile' WHERE strMenuName = 'Generate Vendor Rebate File' AND strModuleName = 'Store' AND intParentMenuID = @StoreMaintenanceParentMenuId

/* START DELETE */
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Promotion Sales' AND strModuleName = 'Store' AND intParentMenuID = @StoreMaintenanceParentMenuId)
   DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Promotion Sales ' AND strModuleName = 'Store' AND intParentMenuID = @StoreMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Promotion Item List' AND strModuleName = 'Store' AND intParentMenuID = @StoreMaintenanceParentMenuId)
   DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Promotion Item List' AND strModuleName = 'Store' AND intParentMenuID = @StoreMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Copy Promotions' AND strModuleName = 'Store' AND intParentMenuID = @StoreMaintenanceParentMenuId)
   DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Copy Promotions' AND strModuleName = 'Store' AND intParentMenuID = @StoreMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Purge Promotions' AND strModuleName = 'Store' AND intParentMenuID = @StoreMaintenanceParentMenuId)
   DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Purge Promotions' AND strModuleName = 'Store' AND intParentMenuID = @StoreMaintenanceParentMenuId
/* STOP DELETE */

/* CRM - Customer Relation Management */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'CRM' AND strModuleName = 'CRM' AND intParentMenuID = 0)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'CRM', N'CRM', 0, N'Customer Relation Management', NULL, N'Folder', N'', N'small-folder', 1, 1, 0, 0, 21, 0)
ELSE
	UPDATE tblSMMasterMenu SET  intSort = 21 WHERE strMenuName = 'CRM' AND strModuleName = 'CRM' AND intParentMenuID = 0

DECLARE @CRMParentMenuId INT
SELECT @CRMParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'CRM' AND strModuleName = 'CRM' AND intParentMenuID = 0

/* CATEGORY FOLDERS */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Activities' AND strModuleName = 'CRM' AND intParentMenuID = @CRMParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Activities', N'CRM', @CRMParentMenuId, N'Activities', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 0 WHERE strMenuName = 'Activities' AND strModuleName = 'CRM' AND intParentMenuID = @CRMParentMenuId

DECLARE @CRMActivitiesParentMenuId INT
SELECT @CRMActivitiesParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Activities' AND strModuleName = 'CRM' AND intParentMenuID = @CRMParentMenuId

/* ADD TO RESPECTIVE CATEGORY */ 
UPDATE tblSMMasterMenu SET intParentMenuID = @CRMActivitiesParentMenuId WHERE intParentMenuID =  @CRMParentMenuId AND strCategory = 'Activity'

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
	VALUES (N'Activities', N'CRM', @CRMActivitiesParentMenuId, N'CRM Opportunity Activities', N'Activity', N'Screen', N'CRM.view.Opportunity?showSearch=true&searchCommand=Activity', N'small-menu-activity', 0, 0, 0, 1, 1, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'CRM.view.Opportunity?showSearch=true&searchCommand=Activity', strDescription = N'CRM Opportunity Activities' WHERE strMenuName = 'Activities' AND strModuleName = 'CRM' AND intParentMenuID = @CRMActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Opportunities' AND strModuleName = 'CRM' AND intParentMenuID = @CRMActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Opportunities', N'CRM', @CRMActivitiesParentMenuId, N'CRM Opportunity', N'Activity', N'Screen', N'CRM.view.Opportunity?showSearch=true&searchCommand=Opportunity', N'small-menu-activity', 0, 0, 0, 1, 2, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'CRM.view.Opportunity?showSearch=true&searchCommand=Opportunity' WHERE strMenuName = 'Opportunities' AND strModuleName = 'CRM' AND intParentMenuID = @CRMActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Campaigns' AND strModuleName = 'CRM' AND intParentMenuID = @CRMActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Campaigns', N'CRM', @CRMActivitiesParentMenuId, N'CRM Campaigns', N'Activity', N'Screen', N'CRM.view.Campaign?showSearch=true&searchCommand=Campaign', N'small-menu-activity', 0, 0, 0, 1, 3, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'CRM.view.Campaign?showSearch=true&searchCommand=Campaign' WHERE strMenuName = 'Campaigns' AND strModuleName = 'CRM' AND intParentMenuID = @CRMActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Sales Pipe Statuses' AND strModuleName = 'CRM' AND intParentMenuID = @CRMActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Sales Pipe Statuses', N'CRM', @CRMActivitiesParentMenuId, N'CRM Sales Pipe Statuses', N'Activity', N'Screen', N'CRM.view.SalesPipeStatus?searchCommand=searchConfig', N'small-menu-activity', 0, 0, 0, 1, 4, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 4, strCommand = N'CRM.view.SalesPipeStatus?searchCommand=searchConfig' WHERE strMenuName = 'Sales Pipe Statuses' AND strModuleName = 'CRM' AND intParentMenuID = @CRMActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Lost Revenues' AND strModuleName = 'CRM' AND intParentMenuID = @CRMActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Lost Revenues', N'CRM', @CRMActivitiesParentMenuId, N'CRM Lost Revenue', N'Activity', N'Screen', N'CRM.view.LostRevenue', N'small-menu-activity', 0, 0, 0, 1, 5, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 5, strCommand = N'CRM.view.LostRevenue', strDescription = N'CRM Lost Revenue' WHERE strMenuName = 'Lost Revenues' AND strModuleName = 'CRM' AND intParentMenuID = @CRMActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Sources' AND strModuleName = 'CRM' AND intParentMenuID = @CRMActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Sources', N'CRM', @CRMActivitiesParentMenuId, N'CRM Source', N'Activity', N'Screen', N'CRM.view.Source', N'small-menu-activity', 0, 0, 0, 1, 7, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 7, strCommand = N'CRM.view.Source', strDescription = N'CRM Source' WHERE strMenuName = 'Sources' AND strModuleName = 'CRM' AND intParentMenuID = @CRMActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Types' AND strModuleName = 'CRM' AND intParentMenuID = @CRMActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Types', N'CRM', @CRMActivitiesParentMenuId, N'CRM Type', N'Activity', N'Screen', N'CRM.view.Type', N'small-menu-activity', 0, 0, 0, 1, 8, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 8, strCommand = N'CRM.view.Type' WHERE strMenuName = 'Types' AND strModuleName = 'CRM' AND intParentMenuID = @CRMActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Statuses' AND strModuleName = 'CRM' AND intParentMenuID = @CRMActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Statuses', N'CRM', @CRMActivitiesParentMenuId, N'CRM Status', N'Activity', N'Screen', N'CRM.view.Status', N'small-menu-activity', 0, 0, 0, 1, 9, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 9, strCommand = N'CRM.view.Status' WHERE strMenuName = 'Statuses' AND strModuleName = 'CRM' AND intParentMenuID = @CRMActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Milestones' AND strModuleName = 'CRM' AND intParentMenuID = @CRMActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Milestones', N'CRM', @CRMActivitiesParentMenuId, N'CRM Milestones', N'Activity', N'Screen', N'CRM.view.Milestone', N'small-menu-activity', 0, 0, 0, 1, 10, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 10, strCommand = N'CRM.view.Milestone' WHERE strMenuName = 'Milestones' AND strModuleName = 'CRM' AND intParentMenuID = @CRMActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Customer Licenses' AND strModuleName = 'CRM' AND intParentMenuID = @CRMActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Customer Licenses', N'CRM', @CRMActivitiesParentMenuId, N'CRM Customer Licenses', N'Activity', N'Screen', N'CRM.view.CustomerLicense?showSearch=true&searchCommand=CustomerLicense', N'small-menu-activity', 0, 0, 0, 1, 11, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 11, strCommand = N'CRM.view.CustomerLicense?showSearch=true&searchCommand=CustomerLicense' WHERE strMenuName = 'Customer Licenses' AND strModuleName = 'CRM' AND intParentMenuID = @CRMActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Sales Entities' AND strModuleName = 'CRM' AND intParentMenuID = @CRMActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId])
	VALUES (N'Sales Entities', N'CRM', @CRMActivitiesParentMenuId, N'Sales Entities', N'Activity', N'Screen', N'EntityManagement.view.EntityDirect?showSearch=true&searchCommand=EntityProspect', N'small-menu-activity', 0, 0, 0, 1, 12, 1)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 12, strCommand = N'EntityManagement.view.EntityDirect?showSearch=true&searchCommand=EntityProspect' WHERE strMenuName = 'Sales Entities' AND strModuleName = 'CRM' AND intParentMenuID = @CRMActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Leads' AND strModuleName = 'CRM' AND intParentMenuID = @CRMActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId])
	VALUES (N'Leads', N'CRM', @CRMActivitiesParentMenuId, N'Leads', N'Activity', N'Screen', N'AccountsReceivable.view.EntityLead?showSearch=true', N'small-menu-activity', 0, 0, 0, 1, 13, 1)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 13, strCommand = N'AccountsReceivable.view.EntityLead?showSearch=true' WHERE strMenuName = 'Leads' AND strModuleName = 'CRM' AND intParentMenuID = @CRMActivitiesParentMenuId

/* START OF DELETING */
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Create Activity' AND strModuleName = 'CRM' AND intParentMenuID = @CRMActivitiesParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Sales Entity Contacts' AND strModuleName = 'CRM' AND intParentMenuID = @CRMActivitiesParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Lines of Business' AND strModuleName = 'CRM' AND intParentMenuID = @CRMActivitiesParentMenuId
/* END OF DELETING */

/* HELP DESK */
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Help Desk' AND strModuleName = 'Help Desk' AND intParentMenuID = 0)
UPDATE tblSMMasterMenu SET intSort = 22 WHERE strMenuName = 'Help Desk' AND strModuleName = 'Help Desk' AND intParentMenuID = 0

DECLARE @HelpDeskParentMenuId INT
SELECT @HelpDeskParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Help Desk' AND strModuleName = 'Help Desk' AND intParentMenuID = 0

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

/* ADD TO RESPECTIVE CATEGORY */ 
UPDATE tblSMMasterMenu SET intParentMenuID = @HelpDeskActivitiesParentMenuId WHERE intParentMenuID =  @HelpDeskParentMenuId AND strCategory = 'Activity'
UPDATE tblSMMasterMenu SET intParentMenuID = @HelpDeskMaintenanceParentMenuId WHERE intParentMenuID =  @HelpDeskParentMenuId AND strCategory = 'Maintenance'

/* Start of Re-insert */
--IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Open Tickets' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskParentMenuId)
--BEGIN
--	SET IDENTITY_INSERT [dbo].[tblSMMasterMenu] ON

--	INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
--	VALUES (144, N'Open Tickets', N'Help Desk', 141, N'Open Tickets', N'Activity', N'Screen', N'HelpDesk.view.TicketList', N'small-menu-activity', 0, 0, 0, 1, 3, 1)

--	SET IDENTITY_INSERT [dbo].[tblSMMasterMenu] OFF
--END
/* End of Re-insert */
		
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Tickets' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskActivitiesParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 1, strCommand = N'HelpDesk.view.Ticket?showSearch=true&searchCommand=Ticket' WHERE strMenuName = N'Tickets' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Export Hours Worked' AND strModuleName = 'Help Desk' AND intParentMenuID = @HelpDeskActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Export Hours Worked', N'Help Desk', @HelpDeskActivitiesParentMenuId, N'Export Hours Worked', N'Activity', N'Screen', N'HelpDesk.view.ExportHoursWorked', N'small-menu-activity', 0, 0, 0, 1, 2, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 2, strCommand = N'HelpDesk.view.ExportHoursWorked' WHERE strMenuName = 'Export Hours Worked' AND strModuleName = 'Help Desk' AND intParentMenuID = @HelpDeskActivitiesParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Ticket Groups' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 3, strCommand = N'HelpDesk.view.TicketGroup?showSearch=true&searchCommand=Group' WHERE strMenuName = N'Ticket Groups' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Ticket Types' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 4, strCommand = N'HelpDesk.view.TicketType' WHERE strMenuName = N'Ticket Types' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Ticket Statuses' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 5, strCommand = N'HelpDesk.view.TicketStatus' WHERE strMenuName = N'Ticket Statuses' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Ticket Priorities' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 6, strCommand = N'HelpDesk.view.TicketPriority' WHERE strMenuName = N'Ticket Priorities' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Ticket Job Codes' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 7, strCommand = N'HelpDesk.view.TicketJobCode' WHERE strMenuName = N'Ticket Job Codes' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskMaintenanceParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Products' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 8, strCommand = N'HelpDesk.view.Product?showSearch=true&searchCommand=Product' WHERE strMenuName = N'Products' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Projects' AND strModuleName = 'Help Desk' AND intParentMenuID = @HelpDeskMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Projects', N'Help Desk', @HelpDeskMaintenanceParentMenuId, N'Help Desk Projects', N'Maintenance', N'Screen', N'HelpDesk.view.Project?showSearch=true&searchCommand=Project', N'small-menu-maintenance', 0, 0, 0, 1, 9, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 9, strCommand = N'HelpDesk.view.Project?showSearch=true&searchCommand=Project' WHERE strMenuName = 'Projects' AND strModuleName = 'Help Desk' AND intParentMenuID = @HelpDeskMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Milestones' AND strModuleName = 'Help Desk' AND intParentMenuID = @HelpDeskMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Milestones', N'Help Desk', @HelpDeskMaintenanceParentMenuId, N'Milestones', N'Maintenance', N'Screen', N'HelpDesk.view.Milestone', N'small-menu-maintenance', 0, 0, 0, 1, 10, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 10, strCommand = N'HelpDesk.view.Milestone' WHERE strMenuName = 'Milestones' AND strModuleName = 'Help Desk' AND intParentMenuID = @HelpDeskMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Out of Office Replies' AND strModuleName = 'Help Desk' AND intParentMenuID = @HelpDeskMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Out of Office Replies', N'Help Desk', @HelpDeskMaintenanceParentMenuId, N'Out of Office Replies', N'Maintenance', N'Screen', N'HelpDesk.view.OutOfOfficeReply', N'small-menu-maintenance', 0, 0, 0, 1, 11, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 11, strCommand = N'HelpDesk.view.OutOfOfficeReply' WHERE strMenuName = 'Out of Office Replies' AND strModuleName = 'Help Desk' AND intParentMenuID = @HelpDeskMaintenanceParentMenuId

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
/* END OF DELETING */

/* DOCUMENT MANAGEMENT */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Document Management' AND strModuleName = 'Document Management' AND intParentMenuID = 0)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Document Management', N'Document Management', 0, N'Document Management', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 23, 0)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 23 WHERE strMenuName = 'Document Management' AND strModuleName = 'Document Management' AND intParentMenuID = 0

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

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Document Manager' AND strModuleName = 'System Manager' AND intParentMenuID = @DocumentManagementMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Document Manager', N'System Manager', @DocumentManagementMaintenanceParentMenuId, N'Document Manager', N'Maintenance', N'Screen', N'GlobalComponentEngine.view.DocumentManager?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = N'GlobalComponentEngine.view.DocumentManager?showSearch=true', intSort = 0 WHERE strMenuName = 'Document Manager' AND strModuleName = 'System Manager' AND intParentMenuID = @DocumentManagementMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Add Documents' AND strModuleName = 'System Manager' AND intParentMenuID = @DocumentManagementMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Add Documents', N'System Manager', @DocumentManagementMaintenanceParentMenuId, N'Add Documents', N'Maintenance', N'Screen', N'GlobalComponentEngine.view.DocumentPending?activeTab=Add', N'small-menu-maintenance', 0, 0, 0, 1, 1, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = N'GlobalComponentEngine.view.DocumentPending?activeTab=Add', intSort = 1 WHERE strMenuName = 'Add Documents' AND strModuleName = 'System Manager' AND intParentMenuID = @DocumentManagementMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Pending Documents' AND strModuleName = 'System Manager' AND intParentMenuID = @DocumentManagementMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Pending Documents', N'System Manager', @DocumentManagementMaintenanceParentMenuId, N'Pending Documents', N'Maintenance', N'Screen', N'GlobalComponentEngine.view.DocumentPending?activeTab=Pending', N'small-menu-maintenance', 0, 0, 0, 1, 2, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = N'GlobalComponentEngine.view.DocumentPending?activeTab=Pending', intSort = 2 WHERE strMenuName = 'Pending Documents' AND strModuleName = 'System Manager' AND intParentMenuID = @DocumentManagementMaintenanceParentMenuId

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

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Document Configuration' AND strModuleName = 'System Manager' AND intParentMenuID = @DocumentManagementMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Document Configuration', N'System Manager', @DocumentManagementMaintenanceParentMenuId, N'Document Configuration', N'Maintenance', N'Screen', N'GlobalComponentEngine.view.DocumentConfiguration', N'small-menu-maintenance', 0, 0, 0, 1, 5, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = N'GlobalComponentEngine.view.DocumentConfiguration', intSort = 5 WHERE strMenuName = 'Document Configuration' AND strModuleName = 'System Manager' AND intParentMenuID = @DocumentManagementMaintenanceParentMenuId

/* TRANSPORTS */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Transports' AND strModuleName = 'Transports' AND intParentMenuID = 0)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Transports', N'Transports', 0, N'Transports', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 24, 0)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 24 WHERE strMenuName = 'Transports' AND strModuleName = 'Transports' AND intParentMenuID = 0

DECLARE @TransportsParentMenuId INT
SELECT @TransportsParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Transports' AND strModuleName = 'Transports' AND intParentMenuID = 0

/* CATEGORY FOLDERS */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Activities' AND strModuleName = 'Transports' AND intParentMenuID = @TransportsParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Activities', N'Transports', @TransportsParentMenuId, N'Activities', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 0 WHERE strMenuName = 'Activities' AND strModuleName = 'Transports' AND intParentMenuID = @TransportsParentMenuId

DECLARE @TransportsActivitiesParentMenuId INT
SELECT @TransportsActivitiesParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Activities' AND strModuleName = 'Transports' AND intParentMenuID = @TransportsParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'Transports' AND intParentMenuID = @TransportsParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Maintenance', N'Transports', @TransportsParentMenuId, N'Maintenance', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 1 WHERE strMenuName = 'Maintenance' AND strModuleName = 'Transports' AND intParentMenuID = @TransportsParentMenuId

DECLARE @TransportsMaintenanceParentMenuId INT
SELECT @TransportsMaintenanceParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'Transports' AND intParentMenuID = @TransportsParentMenuId

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

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Quote Price Adjustment' AND strModuleName = 'Transports' AND intParentMenuID = @TransportsMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Quote Price Adjustment', N'Transports', @TransportsMaintenanceParentMenuId, N'Quote Price Adjustment', N'Maintenance', N'Screen', N'Transports.view.QuotePriceAdjustment?showSearch=true&searchCommand=QuotePriceAdjustment', N'small-menu-maintenance', 0, 0, 0, 1, 5, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Transports.view.QuotePriceAdjustment?showSearch=true&searchCommand=QuotePriceAdjustment', intSort = 5 WHERE strMenuName = 'Quote Price Adjustment' AND strModuleName = 'Transports' AND intParentMenuID = @TransportsMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Bulk Plant Freight' AND strModuleName = 'Transports' AND intParentMenuID = @TransportsMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Bulk Plant Freight', N'Transports', @TransportsMaintenanceParentMenuId, N'Bulk Plant Freight', N'Maintenance', N'Screen', N'Transports.view.BulkPlantFreight', N'small-menu-maintenance', 0, 0, 0, 1, 6, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Transports.view.BulkPlantFreight', intSort = 6 WHERE strMenuName = 'Bulk Plant Freight' AND strModuleName = 'Transports' AND intParentMenuID = @TransportsMaintenanceParentMenuId

/* METER BILLING */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Meter Billing' AND strModuleName = 'Meter Billing' AND intParentMenuID = 0)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Meter Billing', N'Meter Billing', 0, N'Meter Billing', NULL, N'Folder', N'', N'small-folder', 1, 1, 0, 0, 25, 0)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 25 WHERE strMenuName = 'Meter Billing' AND strModuleName = 'Meter Billing' AND intParentMenuID = 0

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

/* ADD TO RESPECTIVE CATEGORY */ 
UPDATE tblSMMasterMenu SET intParentMenuID = @MeterBillingActivitiesParentMenuId WHERE intParentMenuID =  @MeterBillingParentMenuId AND strCategory = 'Activity'
UPDATE tblSMMasterMenu SET intParentMenuID = @MeterBillingMaintenanceParentMenuId WHERE intParentMenuID =  @MeterBillingParentMenuId AND strCategory = 'Maintenance'

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

/* END of Meter Billing */

/* QUALITY */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Quality' AND strModuleName = 'Quality' AND intParentMenuID = 0)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Quality', N'Quality', 0, N'Quality', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 26, 0)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 26 WHERE strMenuName = 'Quality' AND strModuleName = 'Quality' AND intParentMenuID = 0

DECLARE @QualityParentMenuId INT
SELECT @QualityParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Quality' AND strModuleName = 'Quality' AND intParentMenuID = 0

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
UPDATE tblSMMasterMenu SET intParentMenuID = @QualityActivitiesParentMenuId WHERE intParentMenuID =  @QualityParentMenuId AND strCategory = 'Activity'
UPDATE tblSMMasterMenu SET intParentMenuID = @QualityMaintenanceParentMenuId WHERE intParentMenuID =  @QualityParentMenuId AND strCategory = 'Maintenance'

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Quality View' AND strModuleName = 'Quality' AND intParentMenuID = @QualityActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Quality View', N'Quality', @QualityActivitiesParentMenuId, N'Quality View', N'Activity', N'Screen', N'Quality.view.QualityException', N'small-menu-activity', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Quality.view.QualityException' WHERE strMenuName = 'Quality View' AND strModuleName = 'Quality' AND intParentMenuID = @QualityActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Quality Parameters' AND strModuleName = 'Quality' AND intParentMenuID = @QualityActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Quality Parameters', N'Quality', @QualityActivitiesParentMenuId, N'Quality Parameters', N'Activity', N'Screen', N'Quality.view.QualityParameters?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Quality.view.QualityParameters?showSearch=true' WHERE strMenuName = 'Quality Parameters' AND strModuleName = 'Quality' AND intParentMenuID = @QualityActivitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Sample Entry' AND strModuleName = 'Quality' AND intParentMenuID = @QualityMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Sample Entry', N'Quality', @QualityMaintenanceParentMenuId, N'Sample Entry', N'Maintenance', N'Screen', N'Quality.view.QualitySample?showSearch=true', N'small-menu-activity', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Quality.view.QualitySample?showSearch=true' WHERE strMenuName = 'Sample Entry' AND strModuleName = 'Quality' AND intParentMenuID = @QualityMaintenanceParentMenuId

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
	VALUES (N'Warehouse', N'Warehouse', 0, N'Warehouse', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 27, 0)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 27 WHERE strMenuName = 'Warehouse' AND strModuleName = 'Warehouse' AND intParentMenuID = 0

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
	VALUES (N'Motor Fuel Tax Forms', N'Tax Form', 0, N'Motor Fuel Tax Forms', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 28, 0)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 28 WHERE strMenuName = 'Motor Fuel Tax Forms' AND strModuleName = 'Tax Form' AND intParentMenuID = 0

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

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Tax Authorities' AND strModuleName = 'Tax Form' AND intParentMenuID = @TaxFormMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId])
	VALUES (N'Tax Authorities', N'Tax Form', @TaxFormMaintenanceParentMenuId, N'Tax Authorities', N'Maintenance', N'Screen', N'TaxForm.view.TaxAuthority?showSearch=true&searchCommand=TaxAuthority', N'small-menu-maintenance', 0, 0, 0, 1, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = N'TaxForm.view.TaxAuthority?showSearch=true&searchCommand=TaxAuthority' WHERE strMenuName = 'Tax Authorities' AND strModuleName = 'Tax Form' AND intParentMenuID = @TaxFormMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Integration' AND strModuleName = 'Tax Form' AND intParentMenuID = @TaxFormMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId])
	VALUES (N'Integration', N'Tax Form', @TaxFormMaintenanceParentMenuId, N'Integration', N'Maintenance', N'Screen', N'TaxForm.view.Integration', N'small-menu-maintenance', 0, 0, 0, 1, 1, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = N'TaxForm.view.Integration' WHERE strMenuName = 'Integration' AND strModuleName = 'Tax Form' AND intParentMenuID = @TaxFormMaintenanceParentMenuId

/* PATRONAGE */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Patronage' AND strModuleName = 'Patronage' AND intParentMenuID = 0)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Patronage', N'Patronage', 0, N'Patronage', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 29, 0)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 29 WHERE strMenuName = 'Patronage' AND strModuleName = 'Patronage' AND intParentMenuID = 0

DECLARE @PatronageParentMenuId INT
SELECT @PatronageParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Patronage' AND strModuleName = 'Patronage' AND intParentMenuID = 0

/* CATEGORY FOLDERS */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'Patronage' AND intParentMenuID = @PatronageParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Maintenance', N'Patronage', @PatronageParentMenuId, N'Maintenance', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 0 WHERE strMenuName = 'Maintenance' AND strModuleName = 'Patronage' AND intParentMenuID = @PatronageParentMenuId

DECLARE @PatronageMaintenanceParentMenuId INT
SELECT @PatronageMaintenanceParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'Patronage' AND intParentMenuID = @PatronageParentMenuId

/* ADD TO RESPECTIVE CATEGORY */ 
UPDATE tblSMMasterMenu SET intParentMenuID = @PatronageMaintenanceParentMenuId WHERE intParentMenuID =  @PatronageParentMenuId AND strCategory = 'Maintenance'

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Refund Calculation Worksheet' AND strModuleName = 'Patronage' AND intParentMenuID = @PatronageMaintenanceParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Process Refund', strDescription = 'Process Refund' WHERE strMenuName = 'Refund Calculation Worksheet' AND strModuleName = 'Patronage' AND intParentMenuID = @PatronageMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Refund Rate' AND strModuleName = 'Patronage' AND intParentMenuID = @PatronageMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Refund Rate', N'Patronage', @PatronageMaintenanceParentMenuId, N'Refund Rate', N'Maintenance', N'Screen', N'Patronage.view.RefundRate?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 2, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Patronage.view.RefundRate?showSearch=true' WHERE strMenuName = 'Refund Rate' AND strModuleName = 'Patronage' AND intParentMenuID = @PatronageMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Estate/Corporation' AND strModuleName = 'Patronage' AND intParentMenuID = @PatronageMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Estate/Corporation', N'Patronage', @PatronageMaintenanceParentMenuId, N'Estate/Corporation', N'Maintenance', N'Screen', N'Patronage.view.EstateCorporation?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 4, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Patronage.view.EstateCorporation?showSearch=true' WHERE strMenuName = 'Estate/Corporation' AND strModuleName = 'Patronage' AND intParentMenuID = @PatronageMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Process Refund' AND strModuleName = 'Patronage' AND intParentMenuID = @PatronageMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Process Refund', N'Patronage', @PatronageMaintenanceParentMenuId, N'Process Refund', N'Maintenance', N'Screen', N'Patronage.view.RefundCalculationWorksheet?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 5, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Patronage.view.RefundCalculationWorksheet?showSearch=true' WHERE strMenuName = 'Process Refund' AND strModuleName = 'Patronage' AND intParentMenuID = @PatronageMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Stock Details' AND strModuleName = 'Patronage' AND intParentMenuID = @PatronageMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Stock Details', N'Patronage', @PatronageMaintenanceParentMenuId, N'Stock Details', N'Maintenance', N'Screen', N'Patronage.view.CustomerStock?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 6, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Patronage.view.CustomerStock?showSearch=true' WHERE strMenuName = 'Stock Details' AND strModuleName = 'Patronage' AND intParentMenuID = @PatronageMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Equity Details' AND strModuleName = 'Patronage' AND intParentMenuID = @PatronageMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Equity Details', N'Patronage', @PatronageMaintenanceParentMenuId, N'Equity Details', N'Maintenance', N'Screen', N'Patronage.view.EquityDetail', N'small-menu-maintenance', 0, 0, 0, 1, 7, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Patronage.view.EquityDetail' WHERE strMenuName = 'Equity Details' AND strModuleName = 'Patronage' AND intParentMenuID = @PatronageMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Volume Details' AND strModuleName = 'Patronage' AND intParentMenuID = @PatronageMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Volume Details', N'Patronage', @PatronageMaintenanceParentMenuId, N'Volume Details', N'Maintenance', N'Screen', N'Patronage.view.VolumeDetail', N'small-menu-maintenance', 0, 0, 0, 1, 8, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Patronage.view.VolumeDetail' WHERE strMenuName = 'Volume Details' AND strModuleName = 'Patronage' AND intParentMenuID = @PatronageMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Process Dividends' AND strModuleName = 'Patronage' AND intParentMenuID = @PatronageMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Process Dividends', N'Patronage', @PatronageMaintenanceParentMenuId, N'Process Dividends', N'Maintenance', N'Screen', N'Patronage.view.ProcessDividend?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 9, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Patronage.view.ProcessDividend?showSearch=true' WHERE strMenuName = 'Process Dividends' AND strModuleName = 'Patronage' AND intParentMenuID = @PatronageMaintenanceParentMenuId

DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Patronage Category' AND strModuleName = 'Patronage' AND intParentMenuID = @PatronageMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Stock Classification' AND strModuleName = 'Patronage' AND intParentMenuID = @PatronageMaintenanceParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Issue Stock' AND strModuleName = 'Patronage' AND intParentMenuID = @PatronageMaintenanceParentMenuId

/* ENERGY TRAC */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Energy Trac' AND strModuleName = 'Energy Trac' AND intParentMenuID = 0)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Energy Trac', N'Energy Trac', 0, N'Energy Trac', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 30, 0)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 30 WHERE strMenuName = 'Energy Trac' AND strModuleName = 'Energy Trac' AND intParentMenuID = 0

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
UPDATE tblSMMasterMenu SET intParentMenuID = @EnergyTracActivitiesParentMenuId WHERE intParentMenuID =  @EnergyTracParentMenuId AND strCategory = 'Activities'

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

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Fleet Tracking' AND strModuleName = 'Energy Trac' AND intParentMenuID = @EnergyTracParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId])
	VALUES (N'Fleet Tracking', N'Energy Trac', @EnergyTracParentMenuId, N'Fleet Tracking', N'Activity', N'Screen', N'EnergyTrac.view.FleetTracking', N'small-menu-activity', 0, 0, 0, 1, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = N'EnergyTrac.view.FleetTracking' WHERE strMenuName = 'Fleet Tracking' AND strModuleName = 'Energy Trac' AND intParentMenuID = @EnergyTracParentMenuId

/* INTEGRATION */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Integration' AND strModuleName = 'Integration' AND intParentMenuID = 0)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Integration', N'Integration', 0, N'Integration', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 31, 0)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 31 WHERE strMenuName = 'Integration' AND strModuleName = 'Integration' AND intParentMenuID = 0

DECLARE @IntegrationParentMenuId INT
SELECT @IntegrationParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Integration' AND strModuleName = 'Integration' AND intParentMenuID = 0

/* CATEGORY FOLDERS */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Activities' AND strModuleName = 'Integration' AND intParentMenuID = @IntegrationParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Activities', N'Integration', @IntegrationParentMenuId, N'Activities', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 0 WHERE strMenuName = 'Activities' AND strModuleName = 'Integration' AND intParentMenuID = @IntegrationParentMenuId

DECLARE @IntegrationMaintenanceParentMenuId INT
SELECT @IntegrationMaintenanceParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Activities' AND strModuleName = 'Integration' AND intParentMenuID = @IntegrationParentMenuId

/* ADD TO RESPECTIVE CATEGORY */ 
UPDATE tblSMMasterMenu SET intParentMenuID = @IntegrationMaintenanceParentMenuId WHERE intParentMenuID =  @IntegrationParentMenuId AND strCategory = 'Activities'

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Processes' AND strModuleName = 'Integration' AND intParentMenuID = @IntegrationMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Processes', N'Integration', @IntegrationMaintenanceParentMenuId, N'Processes', N'Activity', N'Screen', N'Integration.view.ProcessSetup?showSearch=true', N'small-menu-activity', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Integration.view.ProcessSetup?showSearch=true' WHERE strMenuName = 'Processes' AND strModuleName = 'Integration' AND intParentMenuID = @IntegrationMaintenanceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Connections' AND strModuleName = 'Integration' AND intParentMenuID = @IntegrationMaintenanceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Connections', N'Integration', @IntegrationMaintenanceParentMenuId, N'Connections', N'Maintenance', N'Screen', N'Integration.view.Connection?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 1, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Integration.view.Connection?showSearch=true' WHERE strMenuName = 'Connections' AND strModuleName = 'Integration' AND intParentMenuID = @IntegrationMaintenanceParentMenuId

/* Fixed Assets */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Fixed Assets' AND strModuleName = 'Fixed Assets' AND intParentMenuID = 0)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Fixed Assets', N'Fixed Assets', 0, N'Fixed Assets', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 32, 0)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 32 WHERE strMenuName = 'Fixed Assets' AND strModuleName = 'Fixed Assets' AND intParentMenuID = 0

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
UPDATE tblSMMasterMenu SET intParentMenuID = @FixedAssetsActivitiesParentMenuId WHERE intParentMenuID =  @FixedAssetsParentMenuId AND strCategory = 'Activities'

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Fixed Assets' AND strModuleName = 'Fixed Assets' AND intParentMenuID = @FixedAssetsActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Fixed Assets', N'Fixed Assets', @FixedAssetsActivitiesParentMenuId, N'Fixed Assets', N'Activity', N'Screen', N'FixedAssets.view.FixedAssets?showSearch=true', N'small-menu-activity', 1, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'FixedAssets.view.FixedAssets?showSearch=true' WHERE strMenuName = 'Fixed Assets' AND strModuleName = 'Fixed Assets' AND intParentMenuID = @FixedAssetsActivitiesParentMenuId
----------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------ CONTACT MENUS -------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------- ALL CONTACT MENUS ONLY MUST BE DELETED IN uspSMFixUserRoleMenus ----------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------
/* SYSTEM MANAGER */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @SystemManagerParentMenuId)
INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId]) VALUES (@SystemManagerParentMenuId)

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @SystemManagerMaintenanceParentMenuId)
INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId]) VALUES (@SystemManagerMaintenanceParentMenuId)

DECLARE @UserRolesMenuId INT
SELECT  @UserRolesMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = N'User Roles' AND strModuleName = N'System Manager' AND intParentMenuID = @SystemManagerMaintenanceParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'User Roles' AND strModuleName = N'System Manager' AND intParentMenuID = @SystemManagerMaintenanceParentMenuId)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @UserRolesMenuId)
	INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId]) VALUES (@UserRolesMenuId)
END

/* HELP DESK */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @HelpDeskParentMenuId)
INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId]) VALUES (@HelpDeskParentMenuId)

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @HelpDeskActivitiesParentMenuId)
INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId]) VALUES (@HelpDeskActivitiesParentMenuId)

DECLARE @TicketsMenuId INT
SELECT  @TicketsMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = N'Tickets' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskActivitiesParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Tickets' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskActivitiesParentMenuId)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @TicketsMenuId)
	INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId]) VALUES (@TicketsMenuId)
END

--/* SALES */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @AccountsReceivableParentMenuId)
INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId]) VALUES (@AccountsReceivableParentMenuId)

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @AccountsReceivableActivitiesParentMenuId)
INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId]) VALUES (@AccountsReceivableActivitiesParentMenuId)

DECLARE @InvoicesMenuId INT
SELECT  @InvoicesMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Invoices' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Invoices' AND strModuleName = N'Accounts Receivable' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @InvoicesMenuId)
	INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId]) VALUES (@InvoicesMenuId)
END

DECLARE @CustomerContactListMenuId INT
SELECT  @CustomerContactListMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = N'Customer Contact List' AND strModuleName = N'Accounts Receivable' AND intParentMenuID = @AccountsReceivableMaintenanceParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Customer Contact List' AND strModuleName = N'Accounts Receivable' AND intParentMenuID = @AccountsReceivableMaintenanceParentMenuId)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @CustomerContactListMenuId)
	INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId]) VALUES (@CustomerContactListMenuId)
END

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Customer' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Customer', N'Accounts Receivable', @AccountsReceivableActivitiesParentMenuId, N'Customer', N'Activity', N'Screen', N'AccountsReceivable.view.EntityCustomer', N'small-menu-activity', 1, 0, 0, 1, NULL, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'AccountsReceivable.view.EntityCustomer' WHERE strMenuName = 'Customer' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId

DECLARE @CustomerMenuId INT
SELECT  @CustomerMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Customer' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Customer' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableActivitiesParentMenuId)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @CustomerMenuId)
		INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId], [ysnContactOnly]) VALUES (@CustomerMenuId, 1)
	ELSE
		UPDATE tblSMContactMenu SET ysnContactOnly = 1 WHERE intMasterMenuId = @CustomerMenuId
END

/* PURCHASING */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @AccountsPayableParentMenuId)
INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId]) VALUES (@AccountsPayableParentMenuId)

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @AccountsPayableActivitiesParentMenuId)
INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId]) VALUES (@AccountsPayableActivitiesParentMenuId)

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Vendor' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Vendor', N'Accounts Payable', @AccountsPayableActivitiesParentMenuId, N'Vendor', N'Activity', N'Screen', N'AccountsPayable.view.EntityVendor', N'small-menu-activity', 1, 0, 0, 1, NULL, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'AccountsPayable.view.EntityVendor' WHERE strMenuName = 'Vendor' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableActivitiesParentMenuId

DECLARE @VendorMenuId INT
SELECT  @VendorMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = N'Vendor' AND strModuleName = N'Accounts Payable' AND intParentMenuID = @AccountsPayableActivitiesParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Vendor' AND strModuleName = N'Accounts Payable' AND intParentMenuID = @AccountsPayableActivitiesParentMenuId)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @VendorMenuId)
		INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId], [ysnContactOnly]) VALUES (@VendorMenuId, 1)
	ELSE
		UPDATE tblSMContactMenu SET ysnContactOnly = 1 WHERE intMasterMenuId = @VendorMenuId
END

DECLARE @VouchersMenuId INT
SELECT  @VouchersMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = N'Vouchers' AND strModuleName = N'Accounts Payable' AND intParentMenuID = @AccountsPayableActivitiesParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Vouchers' AND strModuleName = N'Accounts Payable' AND intParentMenuID = @AccountsPayableActivitiesParentMenuId)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @VouchersMenuId)
	INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId]) VALUES (@VouchersMenuId)
END

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Vendor Contact List' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableActivitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Vendor Contact List', N'Accounts Payable', @AccountsPayableActivitiesParentMenuId, N'Vendor Contact List', N'Activity', N'Screen', N'EntityManagement.controller.VendorContactList', N'small-menu-activity', 1, 0, 0, 1, NULL, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'EntityManagement.controller.VendorContactList' WHERE strMenuName = 'Vendor Contact List' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableActivitiesParentMenuId

DECLARE @VendorContactListMenuId INT
SELECT  @VendorContactListMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = N'Vendor Contact List' AND strModuleName = N'Accounts Payable' AND intParentMenuID = @AccountsPayableActivitiesParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Vendor Contact List' AND strModuleName = N'Accounts Payable' AND intParentMenuID = @AccountsPayableActivitiesParentMenuId)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @VendorContactListMenuId)
		INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId], [ysnContactOnly]) VALUES (@VendorContactListMenuId, 1)
	ELSE
		UPDATE tblSMContactMenu SET ysnContactOnly = 1 WHERE intMasterMenuId = @VendorContactListMenuId
END

DECLARE @PurchaseOrdersMenuId INT
SELECT  @PurchaseOrdersMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = N'Purchase Orders' AND strModuleName = N'Accounts Payable' AND intParentMenuID = @AccountsPayableActivitiesParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Purchase Orders' AND strModuleName = N'Accounts Payable' AND intParentMenuID = @AccountsPayableActivitiesParentMenuId)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @PurchaseOrdersMenuId)
	INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId]) VALUES (@PurchaseOrdersMenuId)
END

/* TICKET MANAGEMENT */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @TicketManagementParentMenuId)
INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId]) VALUES (@TicketManagementParentMenuId)

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @TicketManagementActivitiesParentMenuId)
INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId]) VALUES (@TicketManagementActivitiesParentMenuId)

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @TicketManagementMaintenanceParentMenuId)
INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId]) VALUES (@TicketManagementMaintenanceParentMenuId)

DECLARE @TicketMenuId INT
SELECT  @TicketMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Tickets' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementActivitiesParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Tickets' AND strModuleName = N'Ticket Management' AND intParentMenuID = @TicketManagementActivitiesParentMenuId)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @TicketMenuId)
	INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId]) VALUES (@TicketMenuId)
END

DECLARE @StorageMenuId INT
SELECT  @StorageMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Storage' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementMaintenanceParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Storage' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementMaintenanceParentMenuId)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @StorageMenuId)
		INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId], [ysnContactOnly]) VALUES (@StorageMenuId, 1)
	ELSE
		UPDATE tblSMContactMenu SET ysnContactOnly = 1 WHERE intMasterMenuId = @StorageMenuId
END

/* LOGISTIC */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @LogisticsParentMenuId)
INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId]) VALUES (@LogisticsParentMenuId)

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @LogisticsActivitiesParentMenuId)
INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId]) VALUES (@LogisticsActivitiesParentMenuId)

DECLARE @LoadSchedulesMenuId INT
SELECT  @LoadSchedulesMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Load / Shipment Schedules' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsActivitiesParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Load / Shipment Schedules' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsActivitiesParentMenuId)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @LoadSchedulesMenuId)
	INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId]) VALUES (@LoadSchedulesMenuId)
END

/* CRM */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @CRMParentMenuId)
INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId]) VALUES (@CRMParentMenuId)

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @CRMActivitiesParentMenuId)
INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId]) VALUES (@CRMActivitiesParentMenuId)

DECLARE @ActivitiesMenuId INT
SELECT  @ActivitiesMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Activities' AND strModuleName = 'CRM' AND intParentMenuID = @CRMActivitiesParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Activities' AND strModuleName = 'CRM' AND intParentMenuID = @CRMActivitiesParentMenuId)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @ActivitiesMenuId)
	INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId]) VALUES (@ActivitiesMenuId)
END

DECLARE @OpportunitiesMenuId INT
SELECT  @OpportunitiesMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Opportunities' AND strModuleName = 'CRM' AND intParentMenuID = @CRMActivitiesParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Opportunities' AND strModuleName = 'CRM' AND intParentMenuID = @CRMActivitiesParentMenuId)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @OpportunitiesMenuId)
	INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId]) VALUES (@OpportunitiesMenuId)
END

DECLARE @CampaignsMenuId INT
SELECT  @CampaignsMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Campaigns' AND strModuleName = 'CRM' AND intParentMenuID = @CRMActivitiesParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Campaigns' AND strModuleName = 'CRM' AND intParentMenuID = @CRMActivitiesParentMenuId)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @CampaignsMenuId)
	INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId]) VALUES (@CampaignsMenuId)
END

DECLARE @SalesPipeStatusesMenuId INT
SELECT  @SalesPipeStatusesMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Sales Pipe Statuses' AND strModuleName = 'CRM' AND intParentMenuID = @CRMActivitiesParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Sales Pipe Statuses' AND strModuleName = 'CRM' AND intParentMenuID = @CRMActivitiesParentMenuId)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @SalesPipeStatusesMenuId)
	INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId]) VALUES (@SalesPipeStatusesMenuId)
END

DECLARE @LinesOfBusinessMenuId INT
SELECT  @LinesOfBusinessMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Lines of Business' AND strModuleName = 'CRM' AND intParentMenuID = @CRMActivitiesParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Lines of Business' AND strModuleName = 'CRM' AND intParentMenuID = @CRMActivitiesParentMenuId)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @LinesOfBusinessMenuId)
	INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId]) VALUES (@LinesOfBusinessMenuId)
END

DECLARE @SourcesMenuId INT
SELECT  @SourcesMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Sources' AND strModuleName = 'CRM' AND intParentMenuID = @CRMActivitiesParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Sources' AND strModuleName = 'CRM' AND intParentMenuID = @CRMActivitiesParentMenuId)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @SourcesMenuId)
	INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId]) VALUES (@SourcesMenuId)
END

DECLARE @SalesEntitiesMenuId INT
SELECT  @SalesEntitiesMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Sales Entities' AND strModuleName = 'CRM' AND intParentMenuID = @CRMActivitiesParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Sales Entities' AND strModuleName = 'CRM' AND intParentMenuID = @CRMActivitiesParentMenuId)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @SalesEntitiesMenuId)
	INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId]) VALUES (@SalesEntitiesMenuId)
END

DECLARE @LeadMenuId INT
SELECT  @LeadMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Leads' AND strModuleName = 'CRM' AND intParentMenuID = @CRMActivitiesParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Leads' AND strModuleName = 'CRM' AND intParentMenuID = @CRMActivitiesParentMenuId)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @LeadMenuId)
	INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId]) VALUES (@LeadMenuId)
END

DECLARE @SalesEntityContactMenuId INT
SELECT  @SalesEntityContactMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Sales Entity Contact' AND strModuleName = 'CRM' AND intParentMenuID = @CRMActivitiesParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Sales Entity Contact' AND strModuleName = 'CRM' AND intParentMenuID = @CRMActivitiesParentMenuId)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @SalesEntityContactMenuId)
	INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId]) VALUES (@SalesEntityContactMenuId)
END

/* CONTRACT MANAGEMENT */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @ContractManagementParentMenuId)
INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId]) VALUES (@ContractManagementParentMenuId)

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @ContractManagementActivitiesParentMenuId)
INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId]) VALUES (@ContractManagementActivitiesParentMenuId)

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @CardFuelingMaintenanceParentMenuId)
INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId]) VALUES (@CardFuelingMaintenanceParentMenuId)

DECLARE @ContractsMenuId INT
SELECT  @ContractsMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Contracts' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementActivitiesParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Contracts' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementActivitiesParentMenuId)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @ContractsMenuId)
	INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId]) VALUES (@ContractsMenuId)
END

/* CARD FUELING */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @CardFuelingParentMenuId)
INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId]) VALUES (@CardFuelingParentMenuId)

DECLARE @TransactionMenuId INT
SELECT  @TransactionMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Transaction' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingActivitiesParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Transaction' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingActivitiesParentMenuId)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @TransactionMenuId)
	INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId]) VALUES (@TransactionMenuId)
END

DECLARE @CardAccountsMenuId INT
SELECT  @CardAccountsMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Card Accounts' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingMaintenanceParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Card Accounts' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingMaintenanceParentMenuId)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @CardAccountsMenuId)
	INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId]) VALUES (@CardAccountsMenuId)
END

/* MANUFACTURING */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @ManufacturingParentMenuId)
INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId]) VALUES (@ManufacturingParentMenuId)

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @ManufacturingActivitiesParentMenuId)
INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId]) VALUES (@ManufacturingActivitiesParentMenuId)

DECLARE @InventoryViewMenuId INT
SELECT  @InventoryViewMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Inventory View' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingActivitiesParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Inventory View' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingActivitiesParentMenuId)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @InventoryViewMenuId)
	INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId]) VALUES (@InventoryViewMenuId)
END

DECLARE @TransactionViewMenuId INT
SELECT  @TransactionViewMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Transaction View' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingActivitiesParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Transaction View' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingActivitiesParentMenuId)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @TransactionViewMenuId)
	INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId]) VALUES (@TransactionViewMenuId)
END

/* QUALITY */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @QualityParentMenuId)
INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId]) VALUES (@QualityParentMenuId)

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @QualityMaintenanceParentMenuId)
INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId]) VALUES (@QualityMaintenanceParentMenuId)

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @QualityActivitiesParentMenuId)
INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId]) VALUES (@QualityActivitiesParentMenuId)

DECLARE @SampleEntryMenuId INT
SELECT  @SampleEntryMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Sample Entry' AND strModuleName = 'Quality' AND intParentMenuID = @QualityMaintenanceParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Sample Entry' AND strModuleName = 'Quality' AND intParentMenuID = @QualityMaintenanceParentMenuId	)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @SampleEntryMenuId)
	INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId]) VALUES (@SampleEntryMenuId)
END

DECLARE @QualityViewMenuId INT
SELECT  @QualityViewMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Quality View' AND strModuleName = 'Quality' AND intParentMenuID = @QualityActivitiesParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Quality View' AND strModuleName = 'Quality' AND intParentMenuID = @QualityActivitiesParentMenuId)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @QualityViewMenuId)
	INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId]) VALUES (@QualityViewMenuId)
END

/* TANK MANAGEMENT */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @TankManagementParentMenuId)
INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId]) VALUES (@TankManagementParentMenuId)

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @TankManagementActivitiesParentMenuId)
INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId]) VALUES (@TankManagementActivitiesParentMenuId)

DECLARE @ConsumptionSitesMenuId INT
SELECT  @ConsumptionSitesMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Consumption Sites' AND strModuleName = 'Tank Management' AND intParentMenuID = @TankManagementActivitiesParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Consumption Sites' AND strModuleName = 'Tank Management' AND intParentMenuID = @TankManagementActivitiesParentMenuId)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @ConsumptionSitesMenuId)
	INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId]) VALUES (@ConsumptionSitesMenuId)
END

GO
----------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------- ADJUST uspSMSortOriginMenus' sorting -------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------