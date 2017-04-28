GO

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Bank File Formats'	AND strModuleName = 'Cash Management' AND (strCommand = 'CashManagement.controller.BankFileFormat' OR strCommand = 'CashManagement.view.BankFileFormat'))
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
		VALUES (21, N'Add Panel', N'Dashboard', 20, N'Add Panel', N'Maintenance', N'Screen', N'Dashboard.view.PanelSettings', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
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
		VALUES (55, N'Financial Report Builder', N'Financial Report Designer', 49, N'Financial Report Builder', N'Maintenance', N'Screen', N'FinancialReportDesigner.view.ReportBuilder', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
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
		VALUES (68, N'Customer Inquiry', N'Tank Management', 66, N'Customer Inquiry', N'Activity', N'Screen', N'TankManagement.view.CustomerInquiry', N'small-menu-activity', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (69, N'Consumption Sites', N'Tank Management', 66, N'Consumption Sites', N'Activity', N'Screen', N'TankManagement.view.ConsumptionSite', N'small-menu-activity', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (70, N'Clock Reading', N'Tank Management', 66, N'Clock Reading', N'Activity', N'Screen', N'TankManagement.view.ClockReading', N'small-menu-activity', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (71, N'Synchronize Delivery History', N'Tank Management', 66, N'Synchronize Delivery History', N'Activity', N'Screen', N'TankManagement.view.SyncDeliveryHistory', N'small-menu-activity', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (72, N'Lease Billing', N'Tank Management', 66, N'Lease Billing', N'Activity', N'Screen', N'TankManagement.view.LeaseBilling', N'small-menu-activity', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (73, N'Dispatch Deliveries', N'Tank Management', 66, N'Dispatch Deliveries', N'Activity', N'Screen', N'TankManagement.view.DispatchDelivery', N'small-menu-activity', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (75, N'Degree Day Clock', N'Tank Management', 66, N'Degree Day Clock', N'Maintenance', N'Screen', N'TankManagement.view.DegreeDayClock', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (76, N'Devices', N'Tank Management', 66, N'Devices', N'Maintenance', N'Screen', N'TankManagement.view.Device', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (77, N'Events', N'Tank Management', 66, N'Events', N'Maintenance', N'Screen', N'TankManagement.view.Event', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
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
		VALUES (102, N'Bank Deposits', N'Cash Management', 100, N'Bank Deposits', N'Activity', N'Screen', N'CashManagement.view.BankDeposit', N'small-menu-activity', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (103, N'Bank Transactions', N'Cash Management', 100, N'Bank Transactions', N'Activity', N'Screen', N'CashManagement.view.BankTransactions', N'small-menu-activity', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (104, N'Bank Transfers', N'Cash Management', 100, N'Bank Transfers', N'Activity', N'Screen', N'CashManagement.view.BankTransfer', N'small-menu-activity', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (105, N'Miscellaneous Checks', N'Cash Management', 100, N'Miscellaneous Checks', N'Activity', N'Screen', N'CashManagement.view.MiscellaneousChecks', N'small-menu-activity', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (106, N'Bank Account Register', N'Cash Management', 100, N'Bank Account Register', N'Activity', N'Screen', N'CashManagement.view.BankAccountRegister', N'small-menu-activity', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (107, N'Bank Reconciliation', N'Cash Management', 100, N'Bank Reconciliation', N'Activity', N'Screen', N'CashManagement.view.BankReconciliation', N'small-menu-activity', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (109, N'Banks', N'Cash Management', 100, N'Banks', N'Maintenance', N'Screen', N'CashManagement.view.Banks', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (110, N'Bank Accounts', N'Cash Management', 100, N'Bank Accounts', N'Maintenance', N'Screen', N'CashManagement.view.BankAccounts', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (111, N'Bank File Formats', N'Cash Management', 100, N'Bank File Formats', N'Maintenance', N'Screen', N'CashManagement.view.BankFileFormat', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)

		/* ACCOUNTS PAYABLE */
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (112, N'Purchasing (Accounts Payable)', N'Accounts Payable', 0, N'Purchasing (Accounts Payable)', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 9, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (114, N'Pay Voucher Details', N'Accounts Payable', 112, N'Pay Voucher Details', N'Activity', N'Screen', N'AccountsPayable.view.PayVouchersDetail', N'small-menu-activity', 0, 0, 0, 1, 7, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (115, N'Pay Vouchers', N'Accounts Payable', 112, N'Pay Vouchers (Multi-Vendor)', N'Activity', N'Screen', N'AccountsPayable.view.PayVouchers', N'small-menu-activity', 0, 0, 0, 1, 6, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (116, N'Voucher Batch Entry', N'Accounts Payable', 112, N'Voucher Batch Entry', N'Activity', N'Screen', N'AccountsPayable.view.VoucherBatch', N'small-menu-activity', 0, 0, 0, 1, 1, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (117, N'Batch Posting', N'Accounts Payable', 112, N'Batch Posting', N'Activity', N'Screen', N'i21.view.BatchPosting?module=Purchasing', N'small-menu-activity', 0, 0, 0, 1, 5, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (118, N'Process Payments', N'Accounts Payable', 112, N'Process Payments', N'Activity', N'Screen', N'AccountsPayable.controller.PrintChecks', N'small-menu-activity', 0, 0, 0, 1, 8, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (120, N'Import Bills from Origin', N'Accounts Payable', 112, N'Import Bills from Origin', N'Activity', N'Screen', N'AccountsPayable.view.ImportAPInvoice', N'small-menu-activity', 0, 0, 0, 1, 3, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (122, N'Vendors', N'Accounts Payable', 112, N'Vendors', N'Maintenance', N'Screen', N'EntityManagement.view.Entity?showSearch=true&searchCommand=searchEntityVendor', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
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
		VALUES (139, N'Service Charges', N'Accounts Receivable', 131, N'Service Charges', N'Maintenance', N'Screen', N'AccountsReceivable.view.ServiceCharge', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (140, N'Customer Groups', N'Accounts Receivable', 131, N'Customer Groups', N'Maintenance', N'Screen', N'EntityManagement.view.CustomerGroup', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)

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
		VALUES (148, N'Ticket Groups', N'Help Desk', 141, N'Ticket Groups', N'Maintenance', N'Screen', N'HelpDesk.view.TicketGroup', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (149, N'Ticket Types', N'Help Desk', 141, N'Ticket Types', N'Maintenance', N'Screen', N'HelpDesk.view.TicketType', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (150, N'Ticket Statuses', N'Help Desk', 141, N'Ticket Statuses', N'Maintenance', N'Screen', N'HelpDesk.view.TicketStatus', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (151, N'Ticket Priorities', N'Help Desk', 141, N'Ticket Priorities', N'Maintenance', N'Screen', N'HelpDesk.view.TicketPriority', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (152, N'Ticket Job Codes', N'Help Desk', 141, N'Ticket Job Codes', N'Maintenance', N'Screen', N'HelpDesk.view.TicketJobCode', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (153, N'Products', N'Help Desk', 141, N'Products', N'Maintenance', N'Screen', N'HelpDesk.view.Product', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
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

/* START OF RENAMING  */
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'User Security' AND strModuleName = N'System Manager' AND intParentMenuID = @SystemManagerParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = N'Users', strDescription = N'Users' WHERE strMenuName = N'User Security' AND strModuleName = N'System Manager' AND intParentMenuID = @SystemManagerParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Company Preferences' AND strModuleName = N'System Manager' AND intParentMenuID = @SystemManagerParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = N'Company Configuration', intSort = 5 WHERE strMenuName = N'Company Preferences' AND strModuleName = N'System Manager' AND intParentMenuID = @SystemManagerParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Screen Designer' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = N'Custom Tab Designer', intSort = 16 WHERE strMenuName = 'Screen Designer' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Emails' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = N'Email History' WHERE strMenuName = 'Emails' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerParentMenuId


/* END OF RENAMING  */

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Users' AND strModuleName = N'System Manager' AND intParentMenuID = @SystemManagerParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'i21.view.EntityUser?showSearch=true', intSort = 0 WHERE strMenuName = N'Users' AND strModuleName = N'System Manager' AND intParentMenuID = @SystemManagerParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'User Roles' AND strModuleName = N'System Manager' AND intParentMenuID = @SystemManagerParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'i21.view.UserRole?showSearch=true', intSort = 1 WHERE strMenuName = N'User Roles' AND strModuleName = N'System Manager' AND intParentMenuID = @SystemManagerParentMenuId

--IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Company Setup' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerParentMenuId)
--	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
--	VALUES (N'Company Setup', N'System Manager', @SystemManagerParentMenuId, N'Company Setup', N'Maintenance', N'Screen', N'i21.view.CompanySetup', N'small-menu-maintenance', 0, 0, 0, 1, 2, 1)
--ELSE
--	UPDATE tblSMMasterMenu SET strCommand = 'i21.view.CompanySetup', intSort = 2 WHERE strMenuName = 'Company Setup' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerParentMenuId

--IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Report Manager' AND strModuleName = N'System Manager' AND intParentMenuID = @SystemManagerParentMenuId)
--UPDATE tblSMMasterMenu SET strCommand = N'Reports.controller.ReportManager', intSort = 3 WHERE strMenuName = N'Report Manager' AND strModuleName = N'System Manager' AND intParentMenuID = @SystemManagerParentMenuId

--IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Motor Fuel Tax Cycle' AND strModuleName = N'System Manager' AND intParentMenuID = @SystemManagerParentMenuId)
--UPDATE tblSMMasterMenu SET strCommand = N'Reports.controller.RunTaxCycle', intSort = 4 WHERE strMenuName = N'Motor Fuel Tax Cycle' AND strModuleName = N'System Manager' AND intParentMenuID = @SystemManagerParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Company Configuration' AND strModuleName = N'System Manager' AND intParentMenuID = @SystemManagerParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'i21.view.CompanyPreference', intSort = 2 WHERE strMenuName = N'Company Configuration' AND strModuleName = N'System Manager' AND intParentMenuID = @SystemManagerParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Security Policies' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Security Policies', N'System Manager', @SystemManagerParentMenuId, N'Security Policies', N'Maintenance', N'Screen', N'i21.view.SecurityPolicy?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 3, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'i21.view.SecurityPolicy?showSearch=true', intSort = 3 WHERE strMenuName = 'Security Policies' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Starting Numbers' AND strModuleName = N'System Manager' AND intParentMenuID = @SystemManagerParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'i21.view.StartingNumbers', intSort = 4 WHERE strMenuName = N'Starting Numbers' AND strModuleName = N'System Manager' AND intParentMenuID = @SystemManagerParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Locked Records' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Locked Records', N'System Manager', @SystemManagerParentMenuId, N'Locked Records', N'Maintenance', N'Screen', N'GlobalComponentEngine.view.LockedRecord', N'small-menu-maintenance', 0, 0, 0, 1, 5, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'GlobalComponentEngine.view.LockedRecord', intSort = 5 WHERE strMenuName = 'Locked Records' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Screen Labels' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Screen Labels', N'System Manager', @SystemManagerParentMenuId, N'Screen Labels', N'Maintenance', N'Screen', N'GlobalComponentEngine.view.ScreenLabel', N'small-menu-maintenance', 0, 0, 0, 1, 6, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'GlobalComponentEngine.view.ScreenLabel', intSort = 6 WHERE strMenuName = 'Screen Labels' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerParentMenuId

--IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Custom Fields' AND strModuleName = N'System Manager' AND intParentMenuID = @SystemManagerParentMenuId)
--UPDATE tblSMMasterMenu SET strCommand = N'GlobalComponentEngine.view.CustomField', intSort = 7 WHERE strMenuName = N'Custom Fields' AND strModuleName = N'System Manager' AND intParentMenuID = @SystemManagerParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Email History' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Email History', N'System Manager', @SystemManagerParentMenuId, N'Email History', N'Maintenance', N'Screen', N'GlobalComponentEngine.view.ActivityEmail', N'small-menu-maintenance', 0, 0, 0, 1, 7, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'GlobalComponentEngine.view.ActivityEmail', intSort = 7 WHERE strMenuName = 'Email History' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Letters' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Letters', N'System Manager', @SystemManagerParentMenuId, N'Letters', N'Maintenance', N'Screen', N'i21.view.Letters?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 8, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'i21.view.Letters?showSearch=true', intSort = 8 WHERE strMenuName = 'Letters' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Modules' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Modules', N'System Manager', @SystemManagerParentMenuId, N'Modules', N'Maintenance', N'Screen', N'i21.view.Module', N'small-menu-maintenance', 0, 0, 0, 1, 9, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'i21.view.Module', intSort = 9 WHERE strMenuName = 'Modules' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Custom Tab Designer' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Custom Tab Designer', N'System Manager', @SystemManagerParentMenuId, N'Custom Tab Designer', N'Maintenance', N'Screen', N'GlobalComponentEngine.view.ScreenDesigner?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 10, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'GlobalComponentEngine.view.ScreenDesigner?showSearch=true', intSort = 10 WHERE strMenuName = 'Custom Tab Designer' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Company Registration' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Company Registration', N'System Manager', @SystemManagerParentMenuId, N'Company Registration', N'Maintenance', N'Screen', N'GlobalComponentEngine.view.CompanyRegistration', N'small-menu-maintenance', 0, 0, 0, 1, 11, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'GlobalComponentEngine.view.CompanyRegistration', intSort = 11 WHERE strMenuName = 'Company Registration' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'File Field Mapping' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'File Field Mapping', N'System Manager', @SystemManagerParentMenuId, N'File Field Mapping', N'Maintenance', N'Screen', N'i21.view.FileFieldMapping?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 12, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'i21.view.FileFieldMapping?showSearch=true', intSort = 12 WHERE strMenuName = 'File Field Mapping' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'License Generator' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'License Generator', N'System Manager', @SystemManagerParentMenuId, N'License Generator', N'Maintenance', N'Screen', N'GlobalComponentEngine.view.License?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 13, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'GlobalComponentEngine.view.License?showSearch=true', intSort = 13 WHERE strMenuName = 'License Generator' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'License Types' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'License Types', N'System Manager', @SystemManagerParentMenuId, N'License Types', N'Maintenance', N'Screen', N'GlobalComponentEngine.view.LicenseType', N'small-menu-maintenance', 0, 0, 0, 1, 14, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'GlobalComponentEngine.view.LicenseType', intSort = 14 WHERE strMenuName = 'License Types' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerParentMenuId

--IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Custom Grid' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerParentMenuId)
--	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
--	VALUES (N'Custom Grid', N'System Manager', @SystemManagerParentMenuId, N'Custom Grid', N'Maintenance', N'Screen', N'GlobalComponentEngine.view.CustomGrid', N'small-menu-maintenance', 0, 0, 0, 1, 14, 1)
--ELSE 
--	UPDATE tblSMMasterMenu SET strCommand = N'GlobalComponentEngine.view.CustomGrid', intSort = 14 WHERE strMenuName = 'Custom Grid' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Utilities' AND strModuleName = N'System Manager' AND intParentMenuID = @SystemManagerParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'', intSort = 16 WHERE strMenuName = N'Utilities' AND strModuleName = N'System Manager' AND intParentMenuID = @SystemManagerParentMenuId

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

--IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Import Origin Users' AND strModuleName = N'System Manager' AND intParentMenuID = @UtilitiesParentMenuId)
--UPDATE tblSMMasterMenu SET strCommand = N'i21.view.ImportLegacyUsers' WHERE strMenuName = N'Import Origin Users' AND strModuleName = N'System Manager' AND intParentMenuID = @UtilitiesParentMenuId

--IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Import Origin Menus' AND strModuleName = 'System Manager' AND intParentMenuID = @UtilitiesParentMenuId)
--	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
--	VALUES (N'Import Origin Menus', N'System Manager', @UtilitiesParentMenuId, N'Import Origin Menus', N'Maintenance', N'Screen', N'i21.view.ImportLegacyMenus', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
--ELSE 
--	UPDATE tblSMMasterMenu SET strCommand = N'i21.view.ImportLegacyMenus' WHERE strMenuName = 'Import Origin Menus' AND strModuleName = 'System Manager' AND intParentMenuID = @UtilitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'i21 Updates' AND strModuleName = 'System Manager' AND intParentMenuID = @UtilitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId])
	VALUES (N'i21 Updates', N'System Manager', @UtilitiesParentMenuId, N'i21 Updates', N'Maintenance', N'Screen', N'ServicePack.view.Patch', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = N'ServicePack.view.Patch' WHERE strMenuName = 'i21 Updates' AND strModuleName = 'System Manager' AND intParentMenuID = @UtilitiesParentMenuId

-- START OF ANNOUNCEMENT
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Announcements' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Announcements', N'System Manager', @SystemManagerParentMenuId, N'Announcements', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 15, 2)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = 15 WHERE strMenuName = 'Announcements' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerParentMenuId

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
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Company Setup' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerParentMenuId)
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Company Setup' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Import Origin Users' AND strModuleName = N'System Manager' AND intParentMenuID = @UtilitiesParentMenuId)
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Import Origin Users' AND strModuleName = N'System Manager' AND intParentMenuID = @UtilitiesParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Import Origin Menus' AND strModuleName = 'System Manager' AND intParentMenuID = @UtilitiesParentMenuId)
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Import Origin Menus' AND strModuleName = 'System Manager' AND intParentMenuID = @UtilitiesParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Custom Fields' AND strModuleName = N'System Manager' AND intParentMenuID = @SystemManagerParentMenuId)
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Custom Fields' AND strModuleName = N'System Manager' AND intParentMenuID = @SystemManagerParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Custom Grid' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerParentMenuId)
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Custom Grid' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Report Manager' AND strModuleName = N'System Manager' AND intParentMenuID = @SystemManagerParentMenuId
/* End Delete */


/* COMMON INFO */
IF EXISTS (SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Common Info' AND strModuleName = 'System Manager')
UPDATE tblSMMasterMenu SET intSort = 2, intParentMenuID = 0 FROM tblSMMasterMenu WHERE strMenuName = 'Common Info' AND strModuleName = 'System Manager'

DECLARE @CommonInfoParentMenuId INT
SELECT @CommonInfoParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Common Info' AND strModuleName = 'System Manager' AND intParentMenuID = 0

/* START OF PLURALIZING */
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Country' AND strModuleName = N'System Manager' AND intParentMenuID = @CommonInfoParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Countries', strDescription = 'Countries' WHERE strMenuName = N'Country' AND strModuleName = N'System Manager' AND intParentMenuID = @CommonInfoParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Zip Code' AND strModuleName = N'System Manager' AND intParentMenuID = @CommonInfoParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Zip Codes', strDescription = 'Zip Codes' WHERE strMenuName = N'Zip Code' AND strModuleName = N'System Manager' AND intParentMenuID = @CommonInfoParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Currency' AND strModuleName = N'System Manager' AND intParentMenuID = @CommonInfoParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Currencies', strDescription = 'Currencies' WHERE strMenuName = N'Currency' AND strModuleName = N'System Manager' AND intParentMenuID = @CommonInfoParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Company Location' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Company Locations', strDescription = 'Company Locations' WHERE strMenuName = 'Company Location' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Tax Group Master' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Tax Group Masters', strDescription = 'Tax Group Masters' WHERE strMenuName = 'Tax Group Master' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Tax Group' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Tax Groups', strDescription = 'Tax Groups' WHERE strMenuName = 'Tax Group' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Tax Code' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Tax Codes', strDescription = 'Tax Codes' WHERE strMenuName = 'Tax Code' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'City' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Cities', strDescription = 'Cities' WHERE strMenuName = 'City' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Currency Exchange Rate' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Currency Exchange Rates', strDescription = 'Currency Exchange Rates' WHERE strMenuName = 'Currency Exchange Rate' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Currency Exchange Rate Type' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Currency Exchange Rate Types', strDescription = 'Currency Exchange Rate Types' WHERE strMenuName = 'Currency Exchange Rate Type' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId
/* END OF PLURALIZING */

/* START OF RENAMING  */
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Document Maintenance' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = N'Document Messages', strDescription = N'Document Messages' WHERE strMenuName = 'Document Maintenance' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Document Messages' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = N'Report Messages', strDescription = N'Report Messages' WHERE strMenuName = 'Document Messages' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId
/* END OF RENAMING  */

/* Start Move */
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Motor Fuel Tax Cycle' AND strModuleName = N'System Manager' AND intParentMenuID = @SystemManagerParentMenuId)
UPDATE tblSMMasterMenu SET intParentMenuID = @CommonInfoParentMenuId, intSort = 20 WHERE strMenuName = N'Motor Fuel Tax Cycle' AND strModuleName = N'System Manager' AND intParentMenuID = @SystemManagerParentMenuId
/* End Move */

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Company Locations' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId])
	VALUES (N'Company Locations', N'System Manager', @CommonInfoParentMenuId, N'Company Locations', N'Maintenance', N'Screen', N'i21.view.CompanyLocation?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 1, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'i21.view.CompanyLocation?showSearch=true', intSort = 1 WHERE strMenuName = 'Company Locations' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Recurring Transactions' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Recurring Transactions', N'System Manager', @CommonInfoParentMenuId, N'Recurring Transactions', N'Maintenance', N'Screen', N'i21.view.RecurringTransaction', N'small-menu-maintenance', 0, 0, 0, 1, 2, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'i21.view.RecurringTransaction', intSort = 2 WHERE strMenuName = 'Recurring Transactions' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Batch Posting' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Batch Posting', N'System Manager', @CommonInfoParentMenuId, N'Batch Posting', N'Maintenance', N'Screen', N'i21.view.BatchPosting', N'small-menu-maintenance', 0, 0, 0, 1, 3, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'i21.view.BatchPosting', intSort = 3 WHERE strMenuName = 'Batch Posting' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Approvals' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Approvals', N'System Manager', @CommonInfoParentMenuId, N'Approvals', N'Maintenance', N'Screen', N'i21.view.Approval', N'small-menu-maintenance', 0, 0, 0, 1, 4, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = N'i21.view.Approval', intSort = 4 WHERE strMenuName = 'Approvals' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Approval List' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Approval List', N'System Manager', @CommonInfoParentMenuId, N'Approval List', N'Maintenance', N'Screen', N'i21.view.ApprovalList?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 5, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'i21.view.ApprovalList?showSearch=true', intSort = 5 WHERE strMenuName = 'Approval List' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Approver Configuration' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Approver Configuration', N'System Manager', @CommonInfoParentMenuId, N'Approver Configuration', N'Maintenance', N'Screen', N'i21.view.ApproverConfiguration?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 6, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'i21.view.ApproverConfiguration?showSearch=true', intSort = 6 WHERE strMenuName = 'Approver Configuration' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Approver Groups' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Approver Groups', N'System Manager', @CommonInfoParentMenuId, N'Approver Groups', N'Maintenance', N'Screen', N'i21.view.ApproverGroup?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 7, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = N'i21.view.ApproverGroup?showSearch=true', intSort = 7 WHERE strMenuName = 'Approver Groups' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Entity Group' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Entity Group', N'System Manager', @CommonInfoParentMenuId, N'Entity Group', N'Maintenance', N'Screen', N'EntityManagement.view.EntityGroup', N'small-menu-maintenance', 0, 0, 0, 1, 8, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = N'EntityManagement.view.EntityGroup', intSort = 8 WHERE strMenuName = 'Entity Group' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Lines of Business' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Lines of Business', N'System Manager', @CommonInfoParentMenuId, N'Lines of Business', N'Maintenance', N'Screen', N'i21.view.LineOfBusiness', N'small-menu-maintenance', 0, 0, 0, 1, 9, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = N'i21.view.LineOfBusiness', intSort = 9 WHERE strMenuName = 'Lines of Business' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Terms' AND strModuleName = N'System Manager' AND intParentMenuID = @CommonInfoParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'i21.view.Term', intSort = 10 WHERE strMenuName = N'Terms' AND strModuleName = N'System Manager' AND intParentMenuID = @CommonInfoParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Freight Terms' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Freight Terms', N'System Manager', @CommonInfoParentMenuId, N'Freight Terms', N'Maintenance', N'Screen', N'i21.view.FreightTerms', N'small-menu-maintenance', 0, 0, 0, 1, 11, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'i21.view.FreightTerms', intSort = 11 WHERE strMenuName = 'Freight Terms' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Ship Via' AND strModuleName = N'System Manager' AND intParentMenuID = @CommonInfoParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'i21.view.EntityShipVia?showSearch=true', intSort = 12 WHERE strMenuName = N'Ship Via' AND strModuleName = N'System Manager' AND intParentMenuID = @CommonInfoParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Payment Methods' AND strModuleName = N'System Manager' AND intParentMenuID = @CommonInfoParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'i21.view.PaymentMethod', intSort = 13 WHERE strMenuName = N'Payment Methods' AND strModuleName = N'System Manager' AND intParentMenuID = @CommonInfoParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Cities' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Cities', N'System Manager', @CommonInfoParentMenuId, N'Cities', N'Maintenance', N'Screen', N'i21.view.City', N'small-menu-maintenance', 0, 0, 0, 1, 14, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'i21.view.City', intSort = 14 WHERE strMenuName = 'Cities' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Zip Codes' AND strModuleName = N'System Manager' AND intParentMenuID = @CommonInfoParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'i21.view.ZipCode', intSort = 15 WHERE strMenuName = N'Zip Codes' AND strModuleName = N'System Manager' AND intParentMenuID = @CommonInfoParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Countries' AND strModuleName = N'System Manager' AND intParentMenuID = @CommonInfoParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'i21.view.Country', intSort = 16 WHERE strMenuName = N'Countries' AND strModuleName = N'System Manager' AND intParentMenuID = @CommonInfoParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Tax Class' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Tax Class', N'System Manager', @CommonInfoParentMenuId, N'Tax Class', N'Maintenance', N'Screen', N'i21.view.TaxClass', N'small-menu-maintenance', 0, 0, 0, 1, 17, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'i21.view.TaxClass', intSort = 17 WHERE strMenuName = 'Tax Class' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Tax Codes' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Tax Codes', N'System Manager', @CommonInfoParentMenuId, N'Tax Codes', N'Maintenance', N'Screen', N'i21.view.TaxCode?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 18, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'i21.view.TaxCode?showSearch=true', intSort = 18 WHERE strMenuName = 'Tax Codes' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Tax Groups' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Tax Groups', N'System Manager', @CommonInfoParentMenuId, N'Tax Groups', N'Maintenance', N'Screen', N'i21.view.TaxGroup?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 19, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'i21.view.TaxGroup?showSearch=true', intSort = 19 WHERE strMenuName = 'Tax Groups' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Purchasing Groups' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Purchasing Groups', N'System Manager', @CommonInfoParentMenuId, N'Purchasing Groups', N'Maintenance', N'Screen', N'i21.view.PurchasingGroup', N'small-menu-maintenance', 0, 0, 0, 1, 20, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = N'i21.view.PurchasingGroup', intSort = 20 WHERE strMenuName = 'Purchasing Groups' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Calendar' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Calendar', N'System Manager', @CommonInfoParentMenuId, N'Calendar', N'Maintenance', N'Screen', N'#calendar', N'small-menu-maintenance', 0, 0, 0, 1, 21, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = '#calendar', intSort = 21 WHERE strMenuName = 'Calendar' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Motor Fuel Tax Cycle' AND strModuleName = N'System Manager' AND intParentMenuID = @CommonInfoParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = 'Reports.controller.RunTaxCycle', intSort = 22 WHERE strMenuName = N'Motor Fuel Tax Cycle' AND strModuleName = N'System Manager' AND intParentMenuID = @CommonInfoParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Currencies' AND strModuleName = N'System Manager' AND intParentMenuID = @CommonInfoParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'i21.view.Currency', intSort = 23 WHERE strMenuName = N'Currencies' AND strModuleName = N'System Manager' AND intParentMenuID = @CommonInfoParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Currency Exchange Rates' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Currency Exchange Rates', N'System Manager', @CommonInfoParentMenuId, N'Currency Exchange Rates', N'Maintenance', N'Screen', N'i21.view.CurrencyExchangeRate', N'small-menu-maintenance', 0, 0, 0, 1, 24, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'i21.view.CurrencyExchangeRate', intSort = 24 WHERE strMenuName = 'Currency Exchange Rates' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Currency Exchange Rate Types' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Currency Exchange Rate Types', N'System Manager', @CommonInfoParentMenuId, N'Currency Exchange Rate Types', N'Maintenance', N'Screen', N'i21.view.CurrencyExchangeRateType', N'small-menu-maintenance', 0, 0, 0, 1, 25, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'i21.view.CurrencyExchangeRateType', intSort = 25 WHERE strMenuName = 'Currency Exchange Rate Types' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Veterinary' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Veterinary', N'System Manager', @CommonInfoParentMenuId, N'Veterinary', N'Maintenance', N'Screen', N'EntityManagement.view.Entity?showSearch=true&searchCommand=searchEntityVeterinary', N'small-menu-maintenance', 0, 0, 0, 1, 26, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = N'EntityManagement.view.Entity?showSearch=true&searchCommand=searchEntityVeterinary', intSort = 26 WHERE strMenuName = 'Veterinary' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Report Messages' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Report Messages', N'System Manager', @CommonInfoParentMenuId, N'Report Messages?showSearch=true', N'Maintenance', N'Screen', N'i21.view.DocumentMaintenance', N'small-menu-maintenance', 0, 0, 0, 1, 27, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = N'i21.view.DocumentMaintenance?showSearch=true', intSort = 27 WHERE strMenuName = 'Report Messages' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId
	
--IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Tax Group Masters' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId)
--	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
--	VALUES (N'Tax Group Masters', N'System Manager', @CommonInfoParentMenuId, N'Tax Group Masters', N'Maintenance', N'Screen', N'i21.view.TaxGroupMaster', N'small-menu-maintenance', 0, 0, 0, 1, 12, 1)
--ELSE
--	UPDATE tblSMMasterMenu SET strCommand = 'i21.view.TaxGroupMaster', intSort = 12 WHERE strMenuName = 'Tax Group Masters' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId

--IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'User Preferences' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId)
--	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
--	VALUES (N'User Preferences', N'System Manager', @CommonInfoParentMenuId, N'User Preferences', N'Maintenance', N'Screen', N'i21.view.UserPreference', N'small-menu-maintenance', 0, 0, 0, 1, 16, 1)
--ELSE
--	UPDATE tblSMMasterMenu SET strCommand = 'i21.view.UserPreference' WHERE strMenuName = 'User Preferences' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId

--IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Reminder List' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId)
--	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
--	VALUES (N'Reminder List', N'System Manager', @CommonInfoParentMenuId, N'Reminder List', N'Maintenance', N'Screen', N'i21.view.ReminderList', N'small-menu-maintenance', 0, 0, 0, 1, 17, 1)
--ELSE
--	UPDATE tblSMMasterMenu SET strCommand = 'i21.view.ReminderList' WHERE strMenuName = 'Reminder List' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId

/* Start Delete */
--DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Freight Terms' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Reminder List' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Tax Group Masters' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'User Preferences' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Zip Codes' AND strModuleName = N'System Manager' AND intParentMenuID = @CommonInfoParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Tax Type' AND strModuleName = N'System Manager' AND intParentMenuID = @CommonInfoParentMenuId 
/* END OF DELETING */

/* DASHBOARD */
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Dashboard' AND strModuleName = 'Dashboard' AND intParentMenuID = 0)
UPDATE tblSMMasterMenu SET intSort = 3 WHERE strMenuName = 'Dashboard' AND strModuleName = 'Dashboard' AND intParentMenuID = 0

DECLARE @DashboardParentMenuId INT
SELECT @DashboardParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Dashboard' AND strModuleName = 'Dashboard' AND intParentMenuID = 0

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Display Dashboard' AND strModuleName = 'Dashboard' AND intParentMenuID = @DashboardParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Display Dashboard', N'Dashboard', @DashboardParentMenuId, N'Display Dashboard', N'Maintenance', N'Home', N'', N'small-menu-maintenance', 0, 0, 0, 1, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET strIcon = 'small-menu-dashboard' WHERE strMenuName = 'Display Dashboard' AND strModuleName = 'Dashboard' AND intParentMenuID = @DashboardParentMenuId

--IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Add Panel' AND strModuleName = N'Dashboard' AND intParentMenuID = @DashboardParentMenuId)
--UPDATE tblSMMasterMenu SET intSort = 1, strCommand = N'Dashboard.view.PanelSettings' WHERE strMenuName = N'Add Panel' AND strModuleName = N'Dashboard' AND intParentMenuID = @DashboardParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Connections' AND strModuleName = N'Dashboard' AND intParentMenuID = @DashboardParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 2, strCommand = N'Dashboard.view.Connection' WHERE strMenuName = N'Connections' AND strModuleName = N'Dashboard' AND intParentMenuID = @DashboardParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Panels' AND strModuleName = N'Dashboard' AND intParentMenuID = @DashboardParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 3, strCommand = N'Dashboard.view.PanelSettings' WHERE strMenuName = N'Panels' AND strModuleName = N'Dashboard' AND intParentMenuID = @DashboardParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Panel Layout' AND strModuleName = N'Dashboard' AND intParentMenuID = @DashboardParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 4, strCommand = N'Dashboard.view.PanelLayout' WHERE strMenuName = N'Panel Layout' AND strModuleName = N'Dashboard' AND intParentMenuID = @DashboardParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Tabs' AND strModuleName = N'Dashboard' AND intParentMenuID = @DashboardParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 5, strCommand = N'Dashboard.view.TabSetup' WHERE strMenuName = N'Tabs' AND strModuleName = N'Dashboard' AND intParentMenuID = @DashboardParentMenuId

/* START OF DELETING */
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Add Panel' AND strModuleName = N'Dashboard' AND intParentMenuID = @DashboardParentMenuId
/* END OF DELETING */

/* GENERAL LEDGER */
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'General Ledger' AND strModuleName = 'General Ledger' AND intParentMenuID = 0)
UPDATE tblSMMasterMenu SET intSort = 4 WHERE strMenuName = 'General Ledger' AND strModuleName = 'General Ledger' AND intParentMenuID = 0

DECLARE @GeneralLedgerParentMenuId INT
SELECT @GeneralLedgerParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'General Ledger' AND strModuleName = 'General Ledger' AND intParentMenuID = 0

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Reports' AND strModuleName = 'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Reports', N'General Ledger', @GeneralLedgerParentMenuId, N'Reports', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, NULL, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = NULL WHERE strMenuName = 'Reports' AND strModuleName = 'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId

DECLARE @GeneralLedgerReportParentMenuId INT
SELECT @GeneralLedgerReportParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Reports' AND strModuleName = 'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId

/* START OF PLURALIZING */
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'General Journal' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'General Journals', strDescription = 'General Journals' WHERE strMenuName = N'General Journal' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Import Budget from CSV' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Import Budgets from CSV', strDescription = 'Import Budgets from CSV' WHERE strMenuName = N'Import Budget from CSV' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Reallocation' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId and strCategory = 'Maintenance')
UPDATE tblSMMasterMenu SET strMenuName = 'Reallocations', strDescription = 'Reallocations' WHERE strMenuName = N'Reallocation' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId and strCategory = 'Maintenance'

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Recurring Journal' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Recurring Journals', strDescription = 'Recurring Journals' WHERE strMenuName = N'Recurring Journal' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId
/* END OF PLURALIZING */

/* Start of moving report */
UPDATE tblSMMasterMenu SET intParentMenuID = @GeneralLedgerReportParentMenuId WHERE strMenuName = 'Reallocation' AND strModuleName = 'General Ledger' AND strType = 'Report' AND intParentMenuID = @GeneralLedgerParentMenuId
UPDATE tblSMMasterMenu SET intParentMenuID = @GeneralLedgerReportParentMenuId WHERE strMenuName = 'General Ledger By Account ID Detail' AND strModuleName = 'General Ledger' AND strType IN ('Report', 'Screen') AND intParentMenuID = @GeneralLedgerParentMenuId
UPDATE tblSMMasterMenu SET intParentMenuID = @GeneralLedgerReportParentMenuId WHERE strMenuName = 'Trial Balance Detail' AND strModuleName = 'General Ledger' AND strType IN ('Report', 'Screen') AND intParentMenuID = @GeneralLedgerParentMenuId
/* End of moving report */

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'General Journals' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 1, strCommand = N'GeneralLedger.view.GeneralJournal?showSearch=true' WHERE strMenuName = N'General Journals' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'GL Account Detail' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 2, strCommand = N'GeneralLedger.view.GLAccountDetail?showSearch=true' WHERE strMenuName = N'GL Account Detail' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Batch Posting' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 3, strCommand = N'i21.view.BatchPosting?module=General Ledger' WHERE strMenuName = N'Batch Posting' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Import GL from Subledger' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 4, strCommand = N'GeneralLedger.view.ImportFromSubledger' WHERE strMenuName = N'Import GL from Subledger' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Import GL from CSV' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 5, strCommand = N'GeneralLedger.view.ImportFromCSV' WHERE strMenuName = N'Import GL from CSV' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'GL Import Logs' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 6, strCommand = N'GeneralLedger.view.ImportLogs?showSearch=true' WHERE strMenuName = N'GL Import Logs' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Origin Audit Log' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Origin Audit Log', N'General Ledger', @GeneralLedgerParentMenuId, N'Origin Audit Log', N'Activity', N'Screen', N'GeneralLedger.view.OriginAuditLog', N'small-menu-activity', 0, 0, 0, 1, 7, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 7, strCommand = N'GeneralLedger.view.OriginAuditLog' WHERE strMenuName = N'Origin Audit Log' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Fiscal Year' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 8, strCommand = N'GeneralLedger.view.FiscalYear?showSearch=true' WHERE strMenuName = N'Fiscal Year' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Reallocations' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId and strCategory = 'Maintenance')
UPDATE tblSMMasterMenu SET intSort = 9, strCommand = N'GeneralLedger.view.Reallocation?showSearch=true' WHERE strMenuName = N'Reallocations' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId and strCategory = 'Maintenance'

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Revalue Currency' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Revalue Currency', N'General Ledger', @GeneralLedgerParentMenuId, N'Revalue Currency', N'Activity', N'Screen', N'GeneralLedger.view.RevalueCurrency', N'small-menu-activity', 0, 0, 0, 1, 10, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 10, strCommand = N'GeneralLedger.view.RevalueCurrency?showSearch=true' WHERE strMenuName = N'Revalue Currency' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'General Ledger By Account ID Detail' AND strModuleName ='General Ledger' AND intParentMenuID = @GeneralLedgerReportParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 1, strCommand = N'Reporting.view.ReportManager?group=General Ledger&report=GeneralLedgerByAccountDetail&direct=true&showCriteria=true', strType = 'Screen' WHERE strMenuName = 'General Ledger By Account ID Detail' AND strModuleName ='General Ledger' AND intParentMenuID = @GeneralLedgerReportParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Trial Balance Detail' AND strModuleName ='General Ledger' AND intParentMenuID = @GeneralLedgerReportParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 2, strCommand = N'Reporting.view.ReportManager?group=General Ledger&report=TrialBalanceDetail&direct=true&showCriteria=true', strType = 'Screen' WHERE strMenuName = 'Trial Balance Detail' AND strModuleName ='General Ledger' AND intParentMenuID = @GeneralLedgerReportParentMenuId

/* START OF DELETING */
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Account Structure' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Account Groups' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Segment Accounts' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Build Accounts' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Import Budgets from CSV' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Recurring Journals' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Recurring Journal History' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Balance Sheet Standard' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Income Statement Standard' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Trial Balance' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Reminder List' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Chart of Accounts' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId AND strCategory = 'Report'
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Chart of Accounts' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId AND strCategory = 'Maintenance'
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Clone Account' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Chart of Accounts Adjustment' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId AND strCategory = 'Report'
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Reallocation' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerReportParentMenuId AND strCategory = 'Report'
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Trial Balance Detail New' AND strModuleName = 'General Ledger'
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'General Ledger By Account ID Detail New' AND strModuleName = 'General Ledger'
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Account Adjustment' AND strModuleName ='General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId
/* END OF DELETING */

/* FINANCIAL REPORT DESIGNER */
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Financial Reports' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId)
UPDATE tblSMMasterMenu SET intParentMenuID = 0, strModuleName = N'Financial Report Designer', strCommand = N'FinancialReportDesigner' WHERE strMenuName = N'Financial Reports' AND intParentMenuID = @GeneralLedgerParentMenuId

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

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Financial Report Viewer' AND strModuleName = N'Financial Report Designer' AND intParentMenuID = @FinancialReportsParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'FinancialReportDesigner.view.FinancialReports' WHERE strMenuName = N'Financial Report Viewer' AND strModuleName = N'Financial Report Designer' AND intParentMenuID = @FinancialReportsParentMenuId

/* START OF RENAMING  */
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Budget Maintenance' AND strModuleName = 'Financial Report Designer' AND intParentMenuID = @FinancialReportsParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Budget', strDescription = 'Budget' WHERE strMenuName = 'Budget Maintenance' AND strModuleName = 'Financial Report Designer' AND intParentMenuID = @FinancialReportsParentMenuId
/* END OF RENAMING  */


--IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Row Designer' AND strModuleName = N'Financial Report Designer' AND intParentMenuID = @FinancialReportsParentMenuId)
--UPDATE tblSMMasterMenu SET strCommand = N'FinancialReportDesigner.view.RowDesigner' WHERE strMenuName = N'Row Designer' AND strModuleName = N'Financial Report Designer' AND intParentMenuID = @FinancialReportsParentMenuId

--IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Column Designer' AND strModuleName = N'Financial Report Designer' AND intParentMenuID = @FinancialReportsParentMenuId)
--UPDATE tblSMMasterMenu SET strCommand = N'FinancialReportDesigner.view.ColumnDesigner' WHERE strMenuName = N'Column Designer' AND strModuleName = N'Financial Report Designer' AND intParentMenuID = @FinancialReportsParentMenuId

--IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Report Header and Footer' AND strModuleName = N'Financial Report Designer' AND intParentMenuID = @FinancialReportsParentMenuId)
--UPDATE tblSMMasterMenu SET strCommand = N'FinancialReportDesigner.view.HeaderFooterDesigner' WHERE strMenuName = N'Report Header and Footer' AND strModuleName = N'Financial Report Designer' AND intParentMenuID = @FinancialReportsParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Financial Report Builder' AND strModuleName = N'Financial Report Designer' AND intParentMenuID = @FinancialReportsParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'FinancialReportDesigner.view.ReportBuilder' WHERE strMenuName = N'Financial Report Builder' AND strModuleName = N'Financial Report Designer' AND intParentMenuID = @FinancialReportsParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Report Templates' AND strModuleName = N'Financial Report Designer' AND intParentMenuID = @FinancialReportsParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'FinancialReportDesigner.view.Templates' WHERE strMenuName = N'Report Templates' AND strModuleName = N'Financial Report Designer' AND intParentMenuID = @FinancialReportsParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Financial Report Group' AND strModuleName = 'Financial Report Designer' AND intParentMenuID = @FinancialReportsParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Financial Report Group', N'Financial Report Designer', @FinancialReportsParentMenuId, N'Financial Report Group', N'Maintenance', N'Screen', N'FinancialReportDesigner.view.FinancialReportGroup', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'FinancialReportDesigner.view.FinancialReportGroup' WHERE strMenuName = 'Financial Report Group' AND strModuleName = 'Financial Report Designer' AND intParentMenuID = @FinancialReportsParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Budget' AND strModuleName = 'Financial Report Designer' AND intParentMenuID = @FinancialReportsParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Budget', N'Financial Report Designer', @FinancialReportsParentMenuId, N'Budget', N'Maintenance', N'Screen', N'FinancialReportDesigner.view.Budget', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = N'FinancialReportDesigner.view.Budget' WHERE strMenuName = 'Budget' AND strModuleName = 'Financial Report Designer' AND intParentMenuID = @FinancialReportsParentMenuId

/* START OF DELETING */
DELETE FROM tblSMMasterMenu WHERE strMenuName IN ('Financial Report Group', 'Budget Maintenance') AND strModuleName = 'Financial Report Designer' AND intParentMenuID IS NULL
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Row Designer' AND strModuleName = N'Financial Report Designer' AND intParentMenuID = @FinancialReportsParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Column Designer' AND strModuleName = N'Financial Report Designer' AND intParentMenuID = @FinancialReportsParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Report Header and Footer' AND strModuleName = N'Financial Report Designer' AND intParentMenuID = @FinancialReportsParentMenuId
/* END OF DELETING */

/* TANK MANAGEMENT */
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Tank Management' AND strModuleName = 'Tank Management' AND intParentMenuID = 0)
UPDATE tblSMMasterMenu SET intSort = 18 WHERE strMenuName = 'Tank Management' AND strModuleName = 'Tank Management' AND intParentMenuID = 0

DECLARE @TankManagementParentMenuId INT
SELECT @TankManagementParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Tank Management' AND strModuleName = 'Tank Management' AND intParentMenuID = 0

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Reports' AND strModuleName = 'Tank Management' AND intParentMenuID = @TankManagementParentMenuId)
    INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
    VALUES (N'Reports', N'Tank Management', @TankManagementParentMenuId, N'Reports', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, NULL, 1)
ELSE
    UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = NULL WHERE strMenuName = 'Reports' AND strModuleName = 'Tank Management' AND intParentMenuID = @TankManagementParentMenuId

DECLARE @TankManagementReportParentMenuId INT
SELECT @TankManagementReportParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Reports' AND strModuleName = 'Tank Management' AND intParentMenuID = @TankManagementParentMenuId

/* START OF PLURALIZING */
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Event Type' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Event Types', strDescription = 'Event Types' WHERE strMenuName = N'Event Type' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Device Type' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Device Types', strDescription = 'Device Types' WHERE strMenuName = N'Device Type' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Lease Code' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Lease Codes', strDescription = 'Lease Codes' WHERE strMenuName = N'Lease Code' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Event Automation Setup' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Event Automation', strDescription = 'Event Automation' WHERE strMenuName = N'Event Automation Setup' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Meter Type' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Meter Types', strDescription = 'Meter Types' WHERE strMenuName = N'Meter Type' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementParentMenuId
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

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Customer Inquiry' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 0, strCommand = N'TankManagement.view.CustomerInquiry' WHERE strMenuName = N'Customer Inquiry' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Consumption Sites' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 1, strCommand = N'TankManagement.view.ConsumptionSite' WHERE strMenuName = N'Consumption Sites' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Clock Reading' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 2, strCommand = N'TankManagement.view.ClockReading' WHERE strMenuName = N'Clock Reading' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Synchronize Delivery History' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 3, strCommand = N'TankManagement.view.SyncDeliveryHistory' WHERE strMenuName = N'Synchronize Delivery History' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Generate Orders' AND strModuleName = 'Tank Management' AND intParentMenuID = @TankManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Generate Orders', N'Tank Management', @TankManagementParentMenuId, N'Generate Orders', N'Activity', N'Screen', N'TankManagement.view.GenerateOrder', N'small-menu-activity', 0, 0, 0, 1, 4, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 4, strCommand = N'TankManagement.view.GenerateOrder' WHERE strMenuName = 'Generate Orders' AND strModuleName = 'Tank Management' AND intParentMenuID = @TankManagementParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Tank Monitor' AND strModuleName = 'Tank Management' AND intParentMenuID = @TankManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Tank Monitor', N'Tank Management', @TankManagementParentMenuId, N'Tank Monitor', N'Activity', N'Screen', N'TankManagement.view.ImportWesroc', N'small-menu-activity', 0, 0, 0, 1, 5, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 5, strCommand = N'TankManagement.view.ImportWesroc' WHERE strMenuName = 'Tank Monitor' AND strModuleName = 'Tank Management' AND intParentMenuID = @TankManagementParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Budget Calculation' AND strModuleName = 'Tank Management' AND strType = 'Screen' AND intParentMenuID = @TankManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Budget Calculation', N'Tank Management', @TankManagementParentMenuId, N'Budget Calculation', N'Activity', N'Screen', N'TankManagement.view.BudgetCalculations', N'small-menu-activity', 0, 0, 0, 1, 6, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 6, strCommand = N'TankManagement.view.BudgetCalculations' WHERE strMenuName = 'Budget Calculation' AND strModuleName = 'Tank Management' AND strType = 'Screen' AND intParentMenuID = @TankManagementParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Virtual Meter Billing' AND strModuleName = 'Tank Management' AND strType = 'Screen' AND intParentMenuID = @TankManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Virtual Meter Billing', N'Tank Management', @TankManagementParentMenuId, N'Virtual Meter Billing', N'Activity', N'Screen', N'TankManagement.view.VirtualMeterBilling', N'small-menu-activity', 0, 0, 0, 1, 7, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 7, strCommand = N'TankManagement.view.VirtualMeterBilling' WHERE strMenuName = 'Virtual Meter Billing' AND strModuleName = 'Tank Management' AND strType = 'Screen' AND intParentMenuID = @TankManagementParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Lease' AND strModuleName = 'Tank Management' AND intParentMenuID = @TankManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Lease', N'Tank Management', @TankManagementParentMenuId, N'Lease', N'Activity', N'Screen', N'TankManagement.view.Lease', N'small-menu-activity', 0, 0, 0, 1, 8, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 8, strCategory = N'Activity', strIcon = N'small-menu-activity', strCommand = N'TankManagement.view.Lease' WHERE strMenuName = 'Lease' AND strModuleName = 'Tank Management' AND intParentMenuID = @TankManagementParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Deliveries' AND strModuleName = 'Tank Management' AND strType = 'Screen' AND intParentMenuID = @TankManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Deliveries', N'Tank Management', @TankManagementParentMenuId, N'Deliveries', N'Maintenance', N'Screen', N'TankManagement.view.Deliveries', N'small-menu-maintenance', 0, 0, 0, 1, 9, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 9, strCommand = N'TankManagement.view.Deliveries' WHERE strMenuName = 'Deliveries' AND strModuleName = 'Tank Management' AND strType = 'Screen' AND intParentMenuID = @TankManagementParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Generate Work Orders' AND strModuleName = 'Tank Management' AND strType = 'Screen' AND intParentMenuID = @TankManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Generate Work Orders', N'Tank Management', @TankManagementParentMenuId, N'Generate Work Orders', N'Maintenance', N'Screen', N'TankManagement.view.GenerateWorkOrder', N'small-menu-maintenance', 0, 0, 0, 1, 10, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 10, strCommand = N'TankManagement.view.GenerateWorkOrder' WHERE strMenuName = 'Generate Work Orders' AND strModuleName = 'Tank Management' AND strType = 'Screen' AND intParentMenuID = @TankManagementParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Devices' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 11, strCommand = N'TankManagement.view.Device' WHERE strMenuName = N'Devices' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Events' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 12, strCommand = N'TankManagement.view.Event' WHERE strMenuName = N'Events' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementParentMenuId

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
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Open Call Entries' AND strModuleName = N'Tank Management' AND strType = 'Report' AND intParentMenuID = @TankManagementParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Work Order Status' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Lease Billing Report' AND strModuleName = N'Tank Management' AND strType = 'Report' AND intParentMenuID = @TankManagementParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Open Call Entries' AND strModuleName = 'Tank Management' AND strType = 'Screen' AND intParentMenuID = @TankManagementParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Work Orders' AND strModuleName = 'Tank Management' AND strType = 'Screen' AND intParentMenuID = @TankManagementParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Resolve Sync Conflict' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Dispatch Deliveries' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Degree Day Clock' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Event Types' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Device Types' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Lease Codes' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Meter Types' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Clock Reading History' AND strModuleName = 'Tank Management' AND intParentMenuID = @TankManagementParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Lease Billing Incentive' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Event Automation' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Lease Billing' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Renew Julian Deliveries' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Missed Julian Deliveries' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementReportParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Device Actions' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementReportParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Device Lease Detail' AND strModuleName = 'Tank Management' AND intParentMenuID = @TankManagementReportParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Fill Group' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementReportParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Out of Range Burn Rates' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementReportParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Leak Check / Gas Check' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementReportParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'On Hold Detail' AND strModuleName = 'Tank Management' AND intParentMenuID = @TankManagementReportParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Customer List by Route' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementReportParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Two-Part Delivery Fill Report' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementReportParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Tank Inventory' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementReportParentMenuId
/* END OF DELETING */


/* CASH MANAGEMENT */
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Cash Management' AND strModuleName = 'Cash Management' AND intParentMenuID = 0)
UPDATE tblSMMasterMenu SET intSort = 6 WHERE strMenuName = 'Cash Management' AND strModuleName = 'Cash Management' AND intParentMenuID = 0

DECLARE @CashManagementParentMenuId INT
SELECT @CashManagementParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Cash Management' AND strModuleName = 'Cash Management' AND intParentMenuID = 0

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Bank Deposits' AND strModuleName = N'Cash Management' AND intParentMenuID = @CashManagementParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 0, strCommand = N'CashManagement.view.BankDeposit' WHERE strMenuName = N'Bank Deposits' AND strModuleName = N'Cash Management' AND intParentMenuID = @CashManagementParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Bank Deposit Batch Entry' AND strModuleName = 'Cash Management' AND intParentMenuID = @CashManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Bank Deposit Batch Entry', N'Cash Management', @CashManagementParentMenuId, N'Bank Deposit Batch Entry', N'Activity', N'Screen', N'CashManagement.view.BankTransactionsBatchEntry', N'small-menu-activity', 0, 0, 0, 1, 1, 1)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 1, strCommand = N'CashManagement.view.BankTransactionsBatchEntry' WHERE strMenuName = 'Bank Deposit Batch Entry' AND strModuleName = 'Cash Management' AND intParentMenuID = @CashManagementParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Bank Transactions' AND strModuleName = N'Cash Management' AND intParentMenuID = @CashManagementParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 2, strCommand = N'CashManagement.view.BankTransactions' WHERE strMenuName = N'Bank Transactions' AND strModuleName = N'Cash Management' AND intParentMenuID = @CashManagementParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Bank Transfers' AND strModuleName = N'Cash Management' AND intParentMenuID = @CashManagementParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 3, strCommand = N'CashManagement.view.BankTransfer' WHERE strMenuName = N'Bank Transfers' AND strModuleName = N'Cash Management' AND intParentMenuID = @CashManagementParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Miscellaneous Checks' AND strModuleName = N'Cash Management' AND intParentMenuID = @CashManagementParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 4, strCommand = N'CashManagement.view.MiscellaneousChecks' WHERE strMenuName = N'Miscellaneous Checks' AND strModuleName = N'Cash Management' AND intParentMenuID = @CashManagementParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Batch Posting' AND strModuleName = 'Cash Management' AND intParentMenuID = @CashManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Batch Posting', N'Cash Management', @CashManagementParentMenuId, N'Batch Posting', N'Activity', N'Screen', N'i21.view.BatchPosting?module=Cash Management', N'small-menu-activity', 0, 0, 0, 1, 5, 1)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 5, strCommand = N'i21.view.BatchPosting?module=Cash Management' WHERE strMenuName = 'Batch Posting' AND strModuleName = 'Cash Management' AND intParentMenuID = @CashManagementParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Bank Account Register' AND strModuleName = N'Cash Management' AND intParentMenuID = @CashManagementParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 6, strCommand = N'CashManagement.view.BankAccountRegister' WHERE strMenuName = N'Bank Account Register' AND strModuleName = N'Cash Management' AND intParentMenuID = @CashManagementParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Bank Reconciliation' AND strModuleName = N'Cash Management' AND intParentMenuID = @CashManagementParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 7, strCommand = N'CashManagement.view.BankReconciliation' WHERE strMenuName = N'Bank Reconciliation' AND strModuleName = N'Cash Management' AND intParentMenuID = @CashManagementParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Banks' AND strModuleName = N'Cash Management' AND intParentMenuID = @CashManagementParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 8, strCommand = N'CashManagement.view.Banks' WHERE strMenuName = N'Banks' AND strModuleName = N'Cash Management' AND intParentMenuID = @CashManagementParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Bank Accounts' AND strModuleName = N'Cash Management' AND intParentMenuID = @CashManagementParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 9, strCommand = N'CashManagement.view.BankAccounts' WHERE strMenuName = N'Bank Accounts' AND strModuleName = N'Cash Management' AND intParentMenuID = @CashManagementParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Bank File Formats' AND strModuleName = N'Cash Management' AND intParentMenuID = @CashManagementParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 10, strCommand = N'CashManagement.view.BankFileFormat' WHERE strMenuName = N'Bank File Formats' AND strModuleName = N'Cash Management' AND intParentMenuID = @CashManagementParentMenuId

/* START OF DELETING */
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Positive Pay Export' AND strModuleName = 'Cash Management' AND intParentMenuID = @CashManagementParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Bank File Export' AND strModuleName = 'Cash Management' AND intParentMenuID = @CashManagementParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Reports' AND strModuleName = 'Cash Management' AND intParentMenuID = @CashManagementParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Check Register' AND strModuleName = 'Cash Management'
/* END OF DELETING */

/* ACCOUNTS PAYABLE */

/* Rename from Purchasing to Purchasing (Accounts Payable) */
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Purchasing' AND strModuleName = 'Accounts Payable' AND intParentMenuID = 0)
UPDATE tblSMMasterMenu SET strMenuName = 'Purchasing (Accounts Payable)', strDescription = 'Purchasing (Accounts Payable)' WHERE strMenuName = 'Purchasing' AND strModuleName = 'Accounts Payable' AND intParentMenuID = 0


IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Purchasing (Accounts Payable)' AND strModuleName = 'Accounts Payable' AND intParentMenuID = 0)
UPDATE tblSMMasterMenu SET intSort = 9 WHERE strMenuName = 'Purchasing (Accounts Payable)' AND strModuleName = 'Accounts Payable' AND intParentMenuID = 0

DECLARE @AccountsPayableParentMenuId INT
SELECT @AccountsPayableParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Purchasing (Accounts Payable)' AND strModuleName = 'Accounts Payable' AND intParentMenuID = 0

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Reports' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId)
    INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
    VALUES (N'Reports', N'Accounts Payable', @AccountsPayableParentMenuId, N'Reports', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, NULL, 1)
ELSE
    UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = NULL WHERE strMenuName = 'Reports' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId

DECLARE @AccountsPayableReportParentMenuId INT
SELECT @AccountsPayableReportParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Reports' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId

/* START OF PLURALIZING */
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Purchase Order' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Purchase Orders', strDescription = 'Purchase Orders' WHERE strMenuName = 'Purchase Order' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Pay Bill Detail' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Pay Bill Details', strDescription = 'Pay Bill Details' WHERE strMenuName = 'Pay Bill Detail' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId
/* END OF PLURALIZING */

/* START OF RENAMING  */
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Bill Entry' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId)	
UPDATE tblSMMasterMenu SET strMenuName = 'Bills', strDescription = 'Bills' WHERE strMenuName = 'Bill Entry' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Bill Batch Entry' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = N'Voucher Batch Entry', strDescription = N'Voucher Batch Entry' WHERE strMenuName = 'Bill Batch Entry' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Bills' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Vouchers', strDescription = 'Vouchers' WHERE strMenuName = 'Bills' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Pay Bill Details' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Pay Voucher Details', strDescription = 'Pay Voucher Details' WHERE strMenuName = 'Pay Bill Details' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Pay Bills' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Pay Vouchers', strDescription = 'Pay Vouchers (Multi-Vendor)' WHERE strMenuName = 'Pay Bills' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Import Bills from Origin' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Import Vouchers from Origin', strDescription = 'Import Vouchers from Origin' WHERE strMenuName = 'Import Bills from Origin' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Print Checks' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Process Payments', strDescription = 'Process Payments' WHERE strMenuName = 'Print Checks' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId
/* END OF RENAMING  */

/* Start of Moving */
UPDATE tblSMMasterMenu SET intParentMenuID = @AccountsPayableReportParentMenuId WHERE strMenuName = 'Open Payables' AND strModuleName = 'Accounts Payable' AND strType IN ('Screen', 'Report') AND intParentMenuID = @AccountsPayableParentMenuId
UPDATE tblSMMasterMenu SET intParentMenuID = @AccountsPayableReportParentMenuId WHERE strMenuName = 'Open Payable Details' AND strModuleName = 'Accounts Payable' AND strType IN ('Report', 'Screen') AND intParentMenuID = @AccountsPayableParentMenuId
UPDATE tblSMMasterMenu SET intParentMenuID = @AccountsPayableReportParentMenuId WHERE strMenuName = 'Vendor History' AND strModuleName = 'Accounts Payable' AND strType = 'Report' AND intParentMenuID = @AccountsPayableParentMenuId
UPDATE tblSMMasterMenu SET intParentMenuID = @AccountsPayableReportParentMenuId WHERE strMenuName = 'Cash Requirements' AND strModuleName = 'Accounts Payable' AND strType = 'Report' AND intParentMenuID = @AccountsPayableParentMenuId
UPDATE tblSMMasterMenu SET intParentMenuID = @AccountsPayableReportParentMenuId WHERE strMenuName = 'Check Register' AND strModuleName = 'Accounts Payable' AND strType = 'Report' AND intParentMenuID = @AccountsPayableParentMenuId
UPDATE tblSMMasterMenu SET intParentMenuID = @AccountsPayableReportParentMenuId WHERE strMenuName = 'AP Transactions by GL Account' AND strModuleName = 'Accounts Payable' AND strType IN ('Report', 'Screen') AND intParentMenuID = @AccountsPayableParentMenuId
/* End of Moving */

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Purchase Orders' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Purchase Orders', N'Accounts Payable', @AccountsPayableParentMenuId, N'', N'Activity', N'Screen', N'AccountsPayable.view.PurchaseOrder', N'small-menu-activity', 1, 0, 0, 1, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'AccountsPayable.view.PurchaseOrder', intSort = 0 WHERE strMenuName = 'Purchase Orders' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Voucher Batch Entry' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = 'AccountsPayable.view.VoucherBatch', intSort = 1 WHERE strMenuName = 'Voucher Batch Entry' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Vouchers' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Vouchers', N'Accounts Payable', @AccountsPayableParentMenuId, N'Vouchers', N'Activity', N'Screen', N'AccountsPayable.view.Voucher', N'small-menu-activity', 0, 0, 0, 1, 2, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'AccountsPayable.view.Voucher', intSort = 2 WHERE strMenuName = 'Vouchers' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Batch Posting' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId) 
UPDATE tblSMMasterMenu SET strCommand = 'i21.view.BatchPosting?module=Purchasing', intSort = 4 WHERE strMenuName = 'Batch Posting' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Pay Vouchers' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = 'AccountsPayable.view.PayVouchers', intSort = 5 WHERE strMenuName = 'Pay Vouchers' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Pay Voucher Details' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = 'AccountsPayable.view.PayVouchersDetail', intSort = 6 WHERE strMenuName = 'Pay Voucher Details' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Process Payments' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = 'AccountsPayable.controller.PrintChecks', intSort = 7 WHERE strMenuName = 'Process Payments' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Paid Bills History' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Paid Bills History', N'Accounts Payable', @AccountsPayableParentMenuId, N'Shows all the payments', N'Activity', N'Screen', N'AccountsPayable.view.PaidBillsHistory', N'small-menu-activity', 1, 0, 0, 1, 8, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'AccountsPayable.view.PaidBillsHistory', intSort = 8 WHERE strMenuName = 'Paid Bills History' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Import Vouchers from Origin' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = 'AccountsPayable.view.ImportAPInvoice', intSort = 9 WHERE strMenuName = 'Import Vouchers from Origin' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = '1099' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'1099', N'Accounts Payable', @AccountsPayableParentMenuId, N'1099', N'Activity', N'Screen', N'AccountsPayable.view.Thresholds1099', N'small-menu-activity', 1, 0, 0, 1, 10, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'AccountsPayable.view.Thresholds1099', intSort = 10 WHERE strMenuName = '1099' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Buyers' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Buyers', N'Accounts Payable', @AccountsPayableParentMenuId, N'Buyers', N'Activity', N'Screen', N'EntityManagement.view.Entity?showSearch=true&searchCommand=searchEntityBuyer', N'small-menu-activity', 1, 0, 0, 1, 11, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'EntityManagement.view.Entity?showSearch=true&searchCommand=searchEntityBuyer', intSort = 11 WHERE strMenuName = 'Buyers' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Liens' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Liens', N'Accounts Payable', @AccountsPayableParentMenuId, N'Liens', N'Activity', N'Screen', N'EntityManagement.view.Entity?showSearch=true&searchCommand=searchEntityLien', N'small-menu-activity', 1, 0, 0, 1, 12, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'EntityManagement.view.Entity?showSearch=true&searchCommand=searchEntityLien', intSort = 12 WHERE strMenuName = 'Liens' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Vendors' AND strModuleName = N'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'EntityManagement.view.Entity?showSearch=true&searchCommand=searchEntityVendor', intSort = 13 WHERE strMenuName = N'Vendors' AND strModuleName = N'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId

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
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Paid Bills History' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Open Payable Details' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'AP Transaction By GLAccount' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Recurring Transactions' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Open Clearing' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Open Clearing Detail' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Vendor Expense Approval' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Vendor History' AND strModuleName = N'Accounts Payable' AND intParentMenuID = @AccountsPayableReportParentMenuId
/* END OF DELETING */

/* RENAME COMMAND - ACCOUNTS PAYABLE */


/* ACCOUNTS RECEIVABLE */
/* Rename Sales to Sales (Account Receivables) */
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Sales' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = 0)
UPDATE tblSMMasterMenu SET strMenuName = 'Sales (Accounts Receivable)', strDescription = 'Sales (Accounts Receivable)' WHERE strMenuName = 'Sales' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = 0


IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Sales (Accounts Receivable)' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = 0)
UPDATE tblSMMasterMenu SET intSort = 10 WHERE strMenuName = 'Sales (Accounts Receivable)' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = 0

DECLARE @AccountsReceivableParentMenuId INT
SELECT @AccountsReceivableParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Sales (Accounts Receivable)' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = 0

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Reports' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId)
    INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
    VALUES (N'Reports', N'Accounts Receivable', @AccountsReceivableParentMenuId, N'Reports', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, NULL, 1)
ELSE
    UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = NULL WHERE strMenuName = 'Reports' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId

DECLARE @AccountsReceivableReportParentMenuId INT
SELECT @AccountsReceivableReportParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Reports' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId

/* START OF PLURALIZING */
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Quote' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Quotes', strDescription = 'Quotes' WHERE strMenuName = 'Quote' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Sales Order' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Sales Orders', strDescription = 'Sales Orders' WHERE strMenuName = 'Sales Order' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Invoice' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Invoices', strDescription = 'Invoices' WHERE strMenuName = 'Invoice' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Credit Memo' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Credit Memos', strDescription = 'Credit Memos' WHERE strMenuName = 'Credit Memo' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Statement Footer Message' AND strModuleName = N'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Statement Footer Messages', strDescription = 'Statement Footer Messages' WHERE strMenuName = N'Statement Footer Message' AND strModuleName = N'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Service Charge' AND strModuleName = N'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Service Charges', strDescription = 'Service Charges' WHERE strMenuName = N'Service Charge' AND strModuleName = N'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Customer Group' AND strModuleName = N'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Customer Groups', strDescription = 'Customer Groups' WHERE strMenuName = N'Customer Group' AND strModuleName = N'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Receive Payment Detail' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Receive Payment Details', strDescription = 'Receive Payment Details' WHERE strMenuName = 'Receive Payment Detail' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Quote Template' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Quote Templates', strDescription = 'Quote Templates' WHERE strMenuName = 'Quote Template' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Sales Analysis Report' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId)
UPDATE [dbo].[tblSMMasterMenu] SET [strMenuName] = 'Sales Analysis Reports', [strDescription] = 'Sales Analysis Reports', [strType] = 'Screen' ,[strCommand] = 'AccountsReceivable.view.SalesAnalysisReport' WHERE strMenuName = 'Sales Analysis Report' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId
/* END OF PLURALIZING */

/* Re-name Salesperson to Sales Reps*/
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Salesperson' AND strModuleName = N'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Sales Reps', strDescription = 'Sales Reps' WHERE strMenuName = N'Salesperson' AND strModuleName = N'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId
/* Rename Statement Footer Messages to Comment Maintenance */
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Statement Footer Messages' AND strModuleName = N'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = N'Comment Maintenance', strDescription = N'Comment Maintenance', strCommand = N'AccountsReceivable.view.CommentMaintenance' WHERE strMenuName = N'Statement Footer Messages' AND strModuleName = N'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Import Invoices from CSV' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = N'Import Transactions from CSV', strDescription = N'Import Transactions from CSV', strCommand = N'AccountsReceivable.view.ImportTransactionsCSV' WHERE strMenuName = 'Import Invoices from CSV' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Tax Report' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId)	
UPDATE tblSMMasterMenu SET strMenuName = N'Tax Report Grid', strDescription = N'Tax Report Grid' WHERE strMenuName = 'Tax Report' AND strModuleName = 'Accounts Receivable' AND strCategory = N'Maintenance' AND intParentMenuID = @AccountsReceivableParentMenuId
/*
	Rename Menu Name from Sales Analysis Report  to Sales Analysis Reports
	Rename Command to AccountsReceivable.view.SalesAnalysisReport
	Rename Type from Report to Screen
*/

/* Start of moving report */
UPDATE tblSMMasterMenu SET intParentMenuID = @AccountsReceivableReportParentMenuId WHERE strMenuName = 'Customer Aging Report' AND strModuleName = 'Accounts Receivable' AND strCategory = 'Report' AND intParentMenuID = @AccountsReceivableParentMenuId
UPDATE tblSMMasterMenu SET intParentMenuID = @AccountsReceivableReportParentMenuId WHERE strMenuName = 'Customer Inquiry Report' AND strModuleName = 'Accounts Receivable' AND strCategory = 'Report' AND intParentMenuID = @AccountsReceivableParentMenuId
UPDATE tblSMMasterMenu SET intParentMenuID = @AccountsReceivableReportParentMenuId WHERE strMenuName = 'Customer Statements Report' AND strModuleName = 'Accounts Receivable' AND strCategory = 'Report' AND intParentMenuID = @AccountsReceivableParentMenuId
UPDATE tblSMMasterMenu SET intParentMenuID = @AccountsReceivableReportParentMenuId WHERE strMenuName = 'Payment History Report' AND strModuleName = 'Accounts Receivable' AND strCategory = 'Report' AND intParentMenuID = @AccountsReceivableParentMenuId
UPDATE tblSMMasterMenu SET intParentMenuID = @AccountsReceivableReportParentMenuId WHERE strMenuName = 'Unapplied Credits Register Report' AND strModuleName = 'Accounts Receivable' AND strCategory = 'Report' AND intParentMenuID = @AccountsReceivableParentMenuId
UPDATE tblSMMasterMenu SET intParentMenuID = @AccountsReceivableReportParentMenuId WHERE strMenuName = 'Customer Statements Detail Report' AND strModuleName = 'Accounts Receivable' AND strCategory = 'Report' AND intParentMenuID = @AccountsReceivableParentMenuId
UPDATE tblSMMasterMenu SET intParentMenuID = @AccountsReceivableReportParentMenuId WHERE strMenuName = 'Invoice History Report' AND strModuleName = 'Accounts Receivable' AND strCategory = 'Report' AND intParentMenuID = @AccountsReceivableParentMenuId
/* End of moving report */

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Sales Orders' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Sales Orders', N'Accounts Receivable', @AccountsReceivableParentMenuId, N'Sales Orders', N'Activity', N'Screen', N'AccountsReceivable.view.SalesOrder', N'small-menu-activity', 1, 0, 0, 1, 1, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 1, strCommand = N'AccountsReceivable.view.SalesOrder' WHERE strMenuName = 'Sales Orders' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Invoices' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Invoices', N'Accounts Receivable', @AccountsReceivableParentMenuId, N'Invoices', N'Activity', N'Screen', N'AccountsReceivable.view.Invoice', N'small-menu-activity', 1, 0, 0, 1, 2, 1)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 2, strCommand = N'AccountsReceivable.view.Invoice' WHERE strMenuName = 'Invoices' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Receive Payments' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Receive Payments', N'Accounts Receivable', @AccountsReceivableParentMenuId, N'Receive Payments', N'Activity', N'Screen', N'AccountsReceivable.view.ReceivePayments', N'small-menu-activity', 1, 0, 0, 1, 3, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 3, strCommand = N'AccountsReceivable.view.ReceivePayments' WHERE strMenuName = 'Receive Payments' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Receive Payment Details' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Receive Payment Details', N'Accounts Receivable', @AccountsReceivableParentMenuId, N'Receive Payment Details', N'Activity', N'Screen', N'AccountsReceivable.view.ReceivePaymentsDetail', N'small-menu-activity', 1, 0, 0, 1, 4, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 4, strCommand = N'AccountsReceivable.view.ReceivePaymentsDetail' WHERE strMenuName = 'Receive Payment Details' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'POS Login' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'POS Login', N'Accounts Receivable', @AccountsReceivableParentMenuId, N'POS Login', N'Activity', N'Screen', N'AccountsReceivable.view.PointOfSaleLogin', N'small-menu-activity', 1, 0, 0, 1, 5, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 5, strCommand = N'AccountsReceivable.view.PointOfSaleLogin' WHERE strMenuName = 'POS Login' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Batch Posting' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Batch Posting', N'Accounts Receivable', @AccountsReceivableParentMenuId, N'Batch Posting', N'Activity', N'Screen', N'AccountsReceivable.view.BatchPostingSearch', N'small-menu-activity', 1, 0, 0, 1, 6, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 6, strCommand = N'AccountsReceivable.view.BatchPostingSearch' WHERE strMenuName = 'Batch Posting' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Batch Printing' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Batch Printing', N'Accounts Receivable', @AccountsReceivableParentMenuId, N'Batch Printing', N'Activity', N'Screen', N'AccountsReceivable.view.BatchPrinting', N'small-menu-activity', 1, 0, 0, 1, 7, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 7, strCommand = N'AccountsReceivable.view.BatchPrinting' WHERE strMenuName = 'Batch Printing' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Import Invoices from Origin' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Import Invoices from Origin', N'Accounts Receivable', @AccountsReceivableParentMenuId, N'Import Invoices from Origin', N'Activity', N'Screen', N'AccountsReceivable.view.ImportInvoices', N'small-menu-activity', 1, 0, 0, 1, 8, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 8, strCommand = N'AccountsReceivable.view.ImportInvoices' WHERE strMenuName = 'Import Invoices from Origin' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Import Billable from Help Desk' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Import Billable from Help Desk', N'Accounts Receivable', @AccountsReceivableParentMenuId, N'Import Billable from Help Desk', N'Activity', N'Screen', N'AccountsReceivable.view.ImportBillable', N'small-menu-activity', 1, 0, 0, 1, 9, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 9, strCommand = N'AccountsReceivable.view.ImportBillable' WHERE strMenuName = 'Import Billable from Help Desk' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Calculate Service Charge' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Calculate Service Charge', N'Accounts Receivable', @AccountsReceivableParentMenuId, N'Calculate Service Charge', N'Activity', N'Screen', N'AccountsReceivable.view.CalculateServiceCharge', N'small-menu-activity', 1, 0, 0, 1, 10, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 10, strCommand = N'AccountsReceivable.view.CalculateServiceCharge' WHERE strMenuName = 'Calculate Service Charge' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Service Charge Invoice' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Service Charge Invoice', N'Accounts Receivable', @AccountsReceivableParentMenuId, N'Service Charge Invoice', N'Activity', N'Screen', N'AccountsReceivable.view.ServiceChargeInvoice', N'small-menu-activity', 1, 0, 0, 1, 11, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 11, strCommand = N'AccountsReceivable.view.ServiceChargeInvoice' WHERE strMenuName = 'Service Charge Invoice' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Import Transactions from CSV' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Import Transactions from CSV', N'Accounts Receivable', @AccountsReceivableParentMenuId, N'Import Transactions from CSV', N'Activity', N'Screen', N'AccountsReceivable.view.ImportTransactionsCSV', N'small-menu-activity', 1, 0, 0, 1, 12, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 12, strCommand = N'AccountsReceivable.view.ImportTransactionsCSV' WHERE strMenuName = 'Import Transactions from CSV' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Import Logs' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Import Logs', N'Accounts Receivable', @AccountsReceivableParentMenuId, N'Import Logs', N'Activity', N'Screen', N'AccountsReceivable.view.ImportLog', N'small-menu-activity', 1, 0, 0, 1, 13, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 13, strCommand = N'AccountsReceivable.view.ImportLog' WHERE strMenuName = 'Import Logs' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Quote Page Builder' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Quote Page Builder', N'Accounts Receivable', @AccountsReceivableParentMenuId, N'Quote Page Builder', N'Activity', N'Screen', N'AccountsReceivable.view.QuotePageBuilder', N'small-menu-activity', 1, 0, 0, 1, 14, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 14, strCommand = N'AccountsReceivable.view.QuotePageBuilder' WHERE strMenuName = 'Quote Page Builder' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Calculate Commission' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Calculate Commission', N'Accounts Receivable', @AccountsReceivableParentMenuId, N'Calculate Commission', N'Activity', N'Screen', N'AccountsReceivable.view.CalculateCommission', N'small-menu-activity', 1, 0, 0, 1, 15, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 15, strCommand = N'AccountsReceivable.view.CalculateCommission' WHERE strMenuName = 'Calculate Commission' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Commission Approval' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Commission Approval', N'Accounts Receivable', @AccountsReceivableParentMenuId, N'Commission Approval', N'Activity', N'Screen', N'AccountsReceivable.view.CommissionApproval', N'small-menu-activity', 1, 0, 0, 1, 16, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 16, strCommand = N'AccountsReceivable.view.CommissionApproval' WHERE strMenuName = 'Commission Approval' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Customers' AND strModuleName = N'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 17, strCommand = N'AccountsReceivable.view.EntityCustomer?showSearch=true' WHERE strMenuName = N'Customers' AND strModuleName = N'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Customer Contact List' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 18, strCommand = N'EntityManagement.controller.CustomerContactList' WHERE strMenuName = 'Customer Contact List' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Sales Reps' AND strModuleName = N'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 19	, strCommand = N'AccountsReceivable.view.EntitySalesperson?showSearch=true' WHERE strMenuName = N'Sales Reps' AND strModuleName = N'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Market Zone' AND strModuleName = N'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 20, strCommand = N'AccountsReceivable.view.MarketZone' WHERE strMenuName = N'Market Zone' AND strModuleName = N'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Service Charges' AND strModuleName = N'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 21, strCommand = N'AccountsReceivable.view.ServiceCharge' WHERE strMenuName = N'Service Charges' AND strModuleName = N'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Customer Groups' AND strModuleName = N'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 22, strCommand = N'EntityManagement.view.CustomerGroup' WHERE strMenuName = N'Customer Groups' AND strModuleName = N'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Account Status Codes' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Account Status Codes', N'Accounts Receivable', @AccountsReceivableParentMenuId, N'Account Status Codes', N'Maintenance', N'Screen', N'AccountsReceivable.view.AccountStatusCodes', N'small-menu-maintenance', 1, 0, 0, 1, 22, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 22, strCommand = N'AccountsReceivable.view.AccountStatusCodes' WHERE strMenuName = 'Account Status Codes' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Quote Templates' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Quote Templates', N'Accounts Receivable', @AccountsReceivableParentMenuId, N'Quote Templates', N'Maintenance', N'Screen', N'AccountsReceivable.view.QuoteTemplate', N'small-menu-maintenance', 1, 0, 0, 1, 23, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 23, strCommand = N'AccountsReceivable.view.QuoteTemplate' WHERE strMenuName = 'Quote Templates' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Product Types' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Product Types', N'Accounts Receivable', @AccountsReceivableParentMenuId, N'Product Types', N'Maintenance', N'Screen', N'AccountsReceivable.view.ProductType', N'small-menu-maintenance', 1, 0, 0, 1, 24, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 24, strCommand = N'AccountsReceivable.view.ProductType' WHERE strMenuName = 'Product Types' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Commission Plans' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Commission Plans', N'Accounts Receivable', @AccountsReceivableParentMenuId, N'Commission Plans', N'Maintenance', N'Screen', N'AccountsReceivable.view.CommissionPlan', N'small-menu-maintenance', 1, 0, 0, 1, 25, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 25, strCommand = N'AccountsReceivable.view.CommissionPlan' WHERE strMenuName = 'Commission Plans' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Commission Schedules' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Commission Schedules', N'Accounts Receivable', @AccountsReceivableParentMenuId, N'Commission Schedules', N'Maintenance', N'Screen', N'AccountsReceivable.view.CommissionSchedule', N'small-menu-maintenance', 1, 0, 0, 1, 26, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 26, strCommand = N'AccountsReceivable.view.CommissionSchedule' WHERE strMenuName = 'Commission Schedules' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Tax Report Grid' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId)	
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES ( N'Tax Report Grid', N'Accounts Receivable', @AccountsReceivableParentMenuId, N'Tax Report Grid', N'Maintenance', N'Screen', N'AccountsReceivable.view.TaxReport', N'small-menu-maintenance', 0, 0, 0, 1, 27, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 27, strType = N'Screen', strCommand = N'AccountsReceivable.view.TaxReport', strCategory = N'Maintenance', strIcon = 'small-menu-maintenance' WHERE strMenuName = 'Tax Report Grid' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId	

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Sales Analysis Reports' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId])
	VALUES ( N'Sales Analysis Reports', N'Accounts Receivable', @AccountsReceivableParentMenuId, N'Sales Analysis Reports', N'Maintenance', N'Screen', N'AccountsReceivable.view.SalesAnalysisReport', N'small-menu-maintenance', 0, 0, 0, 1, 28, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 28, strType = N'Screen', strCommand = N'AccountsReceivable.view.SalesAnalysisReport', strCategory = N'Maintenance', strIcon = 'small-menu-maintenance' WHERE strMenuName = 'Sales Analysis Reports' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId

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
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Credit Memos' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId)
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Credit Memos' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Bundles' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Customer Aging Report' AND strModuleName = 'Accounts Receivable' AND strCategory = 'Report' AND intParentMenuID = @AccountsReceivableParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Customer Inquiry Report' AND strModuleName = 'Accounts Receivable' AND strCategory = 'Report' AND intParentMenuID = @AccountsReceivableParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Customer Statements Report' AND strModuleName = 'Accounts Receivable' AND strCategory = 'Report' AND intParentMenuID = @AccountsReceivableParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Payment History Report' AND strModuleName = 'Accounts Receivable' AND strCategory = 'Report' AND intParentMenuID = @AccountsReceivableParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Unapplied Credits Register Report' AND strModuleName = 'Accounts Receivable' AND strCategory = 'Report' AND intParentMenuID = @AccountsReceivableParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Customer Statements Detail Report' AND strModuleName = 'Accounts Receivable' AND strCategory = 'Report' AND intParentMenuID = @AccountsReceivableParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Invoice History Report' AND strModuleName = 'Accounts Receivable' AND strCategory = 'Report' AND intParentMenuID = @AccountsReceivableParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Tax Report' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Quotes' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Customer Aging Detail Report' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Comment Maintenance' AND strModuleName = N'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId
/* END OF DELETING */


/* CRM - Customer Relation Management */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'CRM' AND strModuleName = 'CRM' AND intParentMenuID = 0)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'CRM', N'CRM', 0, N'Customer Relation Management', NULL, N'Folder', N'', N'small-folder', 1, 1, 0, 0, 21, 0)
ELSE
	UPDATE tblSMMasterMenu SET  intSort = 21 WHERE strMenuName = 'CRM' AND strModuleName = 'CRM' AND intParentMenuID = 0

DECLARE @CRMParentMenuId INT
SELECT @CRMParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'CRM' AND strModuleName = 'CRM' AND intParentMenuID = 0

/* START OF RENAMING  */
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Opportunity' AND strModuleName = 'CRM' AND intParentMenuID = @CRMParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Opportunities' WHERE strMenuName = 'Opportunity' AND strModuleName = 'CRM' AND intParentMenuID = @CRMParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName IN ('Prospects', 'Prospects and Customers') AND strModuleName = 'CRM' AND intParentMenuID = @CRMParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Sales Entities', strDescription = 'Sales Entities' WHERE strMenuName IN ('Prospects', 'Prospects and Customers') AND strModuleName = 'CRM' AND intParentMenuID = @CRMParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Competitor Search' AND strModuleName = 'CRM' AND intParentMenuID = @CRMParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Competitors', strDescription = 'Competitors' WHERE strMenuName = 'Competitor Search' AND strModuleName = 'CRM' AND intParentMenuID = @CRMParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Lead' AND strModuleName = 'CRM' AND intParentMenuID = @CRMParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Leads', strDescription = 'Leads' WHERE strMenuName = 'Lead' AND strModuleName = 'CRM' AND intParentMenuID = @CRMParentMenuId
/* END OF RENAMING  */

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Activities' AND strModuleName = 'CRM' AND intParentMenuID = @CRMParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Activities', N'CRM', @CRMParentMenuId, N'CRM Opportunity Activities', N'Activity', N'Screen', N'CRM.view.Opportunity?searchCommand=searchConfigAllActivities', N'small-menu-activity', 0, 0, 0, 1, 1, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'CRM.view.Opportunity?searchCommand=searchConfigAllActivities', strDescription = N'CRM Opportunity Activities' WHERE strMenuName = 'Activities' AND strModuleName = 'CRM' AND intParentMenuID = @CRMParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Opportunities' AND strModuleName = 'CRM' AND intParentMenuID = @CRMParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Opportunities', N'CRM', @CRMParentMenuId, N'CRM Opportunity', N'Activity', N'Screen', N'CRM.view.Opportunity?searchCommand=searchConfigAllOpportunity', N'small-menu-activity', 0, 0, 0, 1, 2, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'CRM.view.Opportunity?searchCommand=searchConfigAllOpportunity' WHERE strMenuName = 'Opportunities' AND strModuleName = 'CRM' AND intParentMenuID = @CRMParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Campaigns' AND strModuleName = 'CRM' AND intParentMenuID = @CRMParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Campaigns', N'CRM', @CRMParentMenuId, N'CRM Campaigns', N'Activity', N'Screen', N'CRM.view.Campaign', N'small-menu-activity', 0, 0, 0, 1, 3, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'CRM.view.Campaign' WHERE strMenuName = 'Campaigns' AND strModuleName = 'CRM' AND intParentMenuID = @CRMParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Sales Pipe Statuses' AND strModuleName = 'CRM' AND intParentMenuID = @CRMParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Sales Pipe Statuses', N'CRM', @CRMParentMenuId, N'CRM Sales Pipe Statuses', N'Activity', N'Screen', N'CRM.view.SalesPipeStatus?searchCommand=searchConfig', N'small-menu-activity', 0, 0, 0, 1, 4, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 4, strCommand = N'CRM.view.SalesPipeStatus?searchCommand=searchConfig' WHERE strMenuName = 'Sales Pipe Statuses' AND strModuleName = 'CRM' AND intParentMenuID = @CRMParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Lost Revenues' AND strModuleName = 'CRM' AND intParentMenuID = @CRMParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Lost Revenues', N'CRM', @CRMParentMenuId, N'CRM Lost Revenue', N'Activity', N'Screen', N'CRM.view.LostRevenue', N'small-menu-activity', 0, 0, 0, 1, 5, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 5, strCommand = N'CRM.view.LostRevenue', strDescription = N'CRM Lost Revenue' WHERE strMenuName = 'Lost Revenues' AND strModuleName = 'CRM' AND intParentMenuID = @CRMParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Sources' AND strModuleName = 'CRM' AND intParentMenuID = @CRMParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Sources', N'CRM', @CRMParentMenuId, N'CRM Source', N'Activity', N'Screen', N'CRM.view.Source', N'small-menu-activity', 0, 0, 0, 1, 7, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 7, strCommand = N'CRM.view.Source', strDescription = N'CRM Source' WHERE strMenuName = 'Sources' AND strModuleName = 'CRM' AND intParentMenuID = @CRMParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Types' AND strModuleName = 'CRM' AND intParentMenuID = @CRMParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Types', N'CRM', @CRMParentMenuId, N'CRM Type', N'Activity', N'Screen', N'CRM.view.Type', N'small-menu-activity', 0, 0, 0, 1, 8, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 8, strCommand = N'CRM.view.Type' WHERE strMenuName = 'Types' AND strModuleName = 'CRM' AND intParentMenuID = @CRMParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Statuses' AND strModuleName = 'CRM' AND intParentMenuID = @CRMParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Statuses', N'CRM', @CRMParentMenuId, N'CRM Status', N'Activity', N'Screen', N'CRM.view.Status', N'small-menu-activity', 0, 0, 0, 1, 9, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 9, strCommand = N'CRM.view.Status' WHERE strMenuName = 'Statuses' AND strModuleName = 'CRM' AND intParentMenuID = @CRMParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Milestones' AND strModuleName = 'CRM' AND intParentMenuID = @CRMParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Milestones', N'CRM', @CRMParentMenuId, N'CRM Milestones', N'Activity', N'Screen', N'CRM.view.Milestone', N'small-menu-activity', 0, 0, 0, 1, 10, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 10, strCommand = N'CRM.view.Milestone' WHERE strMenuName = 'Milestones' AND strModuleName = 'CRM' AND intParentMenuID = @CRMParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Sales Entities' AND strModuleName = 'CRM' AND intParentMenuID = @CRMParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId])
	VALUES (N'Sales Entities', N'CRM', @CRMParentMenuId, N'Sales Entities', N'Activity', N'Screen', N'EntityManagement.view.Entity?showSearch=true&searchCommand=searchEntityProspect', N'small-menu-activity', 0, 0, 0, 1, 11, 1)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 11, strCommand = N'EntityManagement.view.Entity?showSearch=true&searchCommand=searchEntityProspect' WHERE strMenuName = 'Sales Entities' AND strModuleName = 'CRM' AND intParentMenuID = @CRMParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Leads' AND strModuleName = 'CRM' AND intParentMenuID = @CRMParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId])
	VALUES (N'Leads', N'CRM', @CRMParentMenuId, N'Leads', N'Activity', N'Screen', N'EntityManagement.view.Entity?showSearch=true&searchCommand=searchEntityLead', N'small-menu-activity', 0, 0, 0, 1, 13, 1)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 13, strCommand = N'EntityManagement.view.Entity?showSearch=true&searchCommand=searchEntityLead' WHERE strMenuName = 'Leads' AND strModuleName = 'CRM' AND intParentMenuID = @CRMParentMenuId

/* START OF DELETING */
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Create Activity' AND strModuleName = 'CRM' AND intParentMenuID = @CRMParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Sales Entity Contacts' AND strModuleName = 'CRM' AND intParentMenuID = @CRMParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Lines of Business' AND strModuleName = 'CRM' AND intParentMenuID = @CRMParentMenuId
/* END OF DELETING */

/* HELP DESK */
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Help Desk' AND strModuleName = 'Help Desk' AND intParentMenuID = 0)
UPDATE tblSMMasterMenu SET intSort = 22 WHERE strMenuName = 'Help Desk' AND strModuleName = 'Help Desk' AND intParentMenuID = 0

DECLARE @HelpDeskParentMenuId INT
SELECT @HelpDeskParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Help Desk' AND strModuleName = 'Help Desk' AND intParentMenuID = 0

/* Start of Re-insert */
--IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Open Tickets' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskParentMenuId)
--BEGIN
--	SET IDENTITY_INSERT [dbo].[tblSMMasterMenu] ON

--	INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
--	VALUES (144, N'Open Tickets', N'Help Desk', 141, N'Open Tickets', N'Activity', N'Screen', N'HelpDesk.view.TicketList', N'small-menu-activity', 0, 0, 0, 1, 3, 1)

--	SET IDENTITY_INSERT [dbo].[tblSMMasterMenu] OFF
--END
/* End of Re-insert */
		
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Tickets' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 1, strCommand = N'HelpDesk.view.Ticket:searchConfigAll' WHERE strMenuName = N'Tickets' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Export Hours Worked' AND strModuleName = 'Help Desk' AND intParentMenuID = @HelpDeskParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Export Hours Worked', N'Help Desk', @HelpDeskParentMenuId, N'Export Hours Worked', N'Activity', N'Screen', N'HelpDesk.view.ExportHoursWorked', N'small-menu-activity', 0, 0, 0, 1, 2, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 2, strCommand = N'HelpDesk.view.ExportHoursWorked' WHERE strMenuName = 'Export Hours Worked' AND strModuleName = 'Help Desk' AND intParentMenuID = @HelpDeskParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Ticket Groups' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 3, strCommand = N'HelpDesk.view.TicketGroup' WHERE strMenuName = N'Ticket Groups' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Ticket Types' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 4, strCommand = N'HelpDesk.view.TicketType' WHERE strMenuName = N'Ticket Types' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Ticket Statuses' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 5, strCommand = N'HelpDesk.view.TicketStatus' WHERE strMenuName = N'Ticket Statuses' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Ticket Priorities' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 6, strCommand = N'HelpDesk.view.TicketPriority' WHERE strMenuName = N'Ticket Priorities' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Ticket Job Codes' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 7, strCommand = N'HelpDesk.view.TicketJobCode' WHERE strMenuName = N'Ticket Job Codes' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Products' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 8, strCommand = N'HelpDesk.view.Product' WHERE strMenuName = N'Products' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Projects' AND strModuleName = 'Help Desk' AND intParentMenuID = @HelpDeskParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Projects', N'Help Desk', @HelpDeskParentMenuId, N'Help Desk Projects', N'Maintenance', N'Screen', N'HelpDesk.view.Project', N'small-menu-maintenance', 0, 0, 0, 1, 9, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 9, strCommand = N'HelpDesk.view.Project' WHERE strMenuName = 'Projects' AND strModuleName = 'Help Desk' AND intParentMenuID = @HelpDeskParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Milestones' AND strModuleName = 'Help Desk' AND intParentMenuID = @HelpDeskParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Milestones', N'Help Desk', @HelpDeskParentMenuId, N'Milestones', N'Maintenance', N'Screen', N'HelpDesk.view.Milestone', N'small-menu-maintenance', 0, 0, 0, 1, 10, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 10, strCommand = N'HelpDesk.view.Milestone' WHERE strMenuName = 'Milestones' AND strModuleName = 'Help Desk' AND intParentMenuID = @HelpDeskParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Out of Office Replies' AND strModuleName = 'Help Desk' AND intParentMenuID = @HelpDeskParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Out of Office Replies', N'Help Desk', @HelpDeskParentMenuId, N'Out of Office Replies', N'Maintenance', N'Screen', N'HelpDesk.view.OutOfOfficeReply', N'small-menu-maintenance', 0, 0, 0, 1, 11, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 11, strCommand = N'HelpDesk.view.OutOfOfficeReply' WHERE strMenuName = 'Out of Office Replies' AND strModuleName = 'Help Desk' AND intParentMenuID = @HelpDeskParentMenuId

/* START OF DELETING */
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Help Desk Settings' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Open Tickets' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskParentMenuId
DELETE FROM tblSMMasterMenu  WHERE strMenuName = N'Tickets Assigned to Me' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Tickets Reported by Me' AND strModuleName = 'Help Desk' AND intParentMenuID = @HelpDeskParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Create Ticket' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Project Lists' AND strModuleName = 'Help Desk' AND intParentMenuID = @HelpDeskParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = N'Email Setup' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Reminder Lists' AND strModuleName = 'Help Desk' AND intParentMenuID = @HelpDeskParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Competitors' AND strModuleName = 'Help Desk' AND intParentMenuID = @CRMParentMenuId
/* END OF DELETING */

/* INVENTORY */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Inventory' AND strModuleName = 'Inventory' AND intParentMenuID = 0)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Inventory', N'Inventory', 0, N'Inventory', NULL, N'Folder', N'', N'small-folder', 1, 1, 0, 0, 8, 0)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 8 WHERE strMenuName = 'Inventory' AND strModuleName = 'Inventory' AND intParentMenuID = 0

DECLARE @InventoryParentMenuId INT
SELECT @InventoryParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Inventory' AND strModuleName = 'Inventory' AND intParentMenuID = 0

/* START OF PLURALIZING */
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Inventory Receipt' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Inventory Receipts', strDescription = 'Inventory Receipts' WHERE strMenuName = 'Inventory Receipt' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Inventory Shipment' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Inventory Shipments', strDescription = 'Inventory Shipments' WHERE strMenuName = 'Inventory Shipment' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Inventory Transfer' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Inventory Transfers', strDescription = 'Inventory Transfers' WHERE strMenuName = 'Inventory Transfer' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Inventory Adjustment' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Inventory Adjustments', strDescription = 'Inventory Adjustments' WHERE strMenuName = 'Inventory Adjustment' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Item' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Items', strDescription = 'Items' WHERE strMenuName = 'Item' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Fuel Category' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Fuel Categories', strDescription = 'Fuel Categories' WHERE strMenuName = 'Fuel Category' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Commodity' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Commodities', strDescription = 'Commodities' WHERE strMenuName = 'Commodity' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Fuel Code' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Fuel Codes', strDescription = 'Fuel Codes' WHERE strMenuName = 'Fuel Code' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Category' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Categories', strDescription = 'Categories' WHERE strMenuName = 'Category' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Fuel Type' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Fuel Types', strDescription = 'Fuel Types' WHERE strMenuName = 'Fuel Type' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Inventory Tag' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Inventory Tags', strDescription = 'Inventory Tags' WHERE strMenuName = 'Inventory Tag' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Storage Unit Type' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Storage Unit Types', strDescription = 'Storage Unit Types' WHERE strMenuName = 'Storage Unit Type' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Storage Location' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Storage Locations', strDescription = 'Storage Locations' WHERE strMenuName = 'Storage Location' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Contract Document' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Contract Documents', strDescription = 'Contract Documents' WHERE strMenuName = 'Contract Document' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId
/* END OF PLURALIZING */

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Inventory Receipts' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Inventory Receipts', N'Inventory', @InventoryParentMenuId, N'Inventory Receipts', N'Activity', N'Screen', N'Inventory.view.InventoryReceipt', N'small-menu-activity', 1, 1, 0, 1, 1, 0)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Inventory.view.InventoryReceipt', intSort = 1 WHERE strMenuName = 'Inventory Receipts' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Inventory Shipments' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Inventory Shipments', N'Inventory', @InventoryParentMenuId, N'Inventory Shipments', N'Activity', N'Screen', N'Inventory.view.InventoryShipment', N'small-menu-activity', 1, 1, 0, 1, 2, 0)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Inventory.view.InventoryShipment', intSort = 2 WHERE strMenuName = 'Inventory Shipments' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Inventory Transfers' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Inventory Transfers', N'Inventory', @InventoryParentMenuId, N'Inventory Transfers', N'Activity', N'Screen', N'Inventory.view.InventoryTransfer', N'small-menu-activity', 1, 1, 0, 1, 3, 0)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Inventory.view.InventoryTransfer', intSort = 3 WHERE strMenuName = 'Inventory Transfers' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Inventory Adjustments' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId])
	VALUES (N'Inventory Adjustments', N'Inventory', @InventoryParentMenuId, N'Inventory Adjustments', N'Activity', N'Screen', N'Inventory.view.InventoryAdjustment', N'small-menu-activity', 1, 1, 0, 1, 4, 0)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = N'Inventory.view.InventoryAdjustment', intSort = 4 WHERE strMenuName = 'Inventory Adjustments' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Inventory Count' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId])
	VALUES (N'Inventory Count', N'Inventory', @InventoryParentMenuId, N'Inventory Count', N'Activity', N'Screen', N'Inventory.view.InventoryCount', N'small-menu-activity', 1, 1, 0, 1, 5, 0)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = N'Inventory.view.InventoryCount', intSort = 5 WHERE strMenuName = 'Inventory Count' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Storage Measurement Reading' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId])
	VALUES (N'Storage Measurement Reading', N'Inventory', @InventoryParentMenuId, N'Storage Measurement Reading', N'Activity', N'Screen', N'Inventory.view.StorageMeasurementReading', N'small-menu-activity', 1, 1, 0, 1, 6, 0)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = N'Inventory.view.StorageMeasurementReading', intSort = 6 WHERE strMenuName = 'Storage Measurement Reading' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Items' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Items', N'Inventory', @InventoryParentMenuId, N'Items', N'Maintenance', N'Screen', N'Inventory.view.Item', N'small-menu-maintenance', 1, 1, 0, 1, 7, 0)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Inventory.view.Item', intSort = 7 WHERE strMenuName = 'Items' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Commodities' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Commodities', N'Inventory', @InventoryParentMenuId, N'Commodities', N'Maintenance', N'Screen', N'Inventory.view.Commodity', N'small-menu-maintenance', 1, 1, 0, 1, 8, 0)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Inventory.view.Commodity', intSort = 8 WHERE strMenuName = 'Commodities' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Categories' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Categories', N'Inventory', @InventoryParentMenuId, N'Categories', N'Maintenance', N'Screen', N'Inventory.view.Category', N'small-menu-maintenance', 1, 1, 0, 1, 9, 0)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Inventory.view.Category', intSort = 9 WHERE strMenuName = 'Categories' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Fuel Types' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Fuel Types', N'Inventory', @InventoryParentMenuId, N'Fuel Types', N'Maintenance', N'Screen', N'Inventory.view.FuelType', N'small-menu-maintenance', 1, 1, 0, 1, 10, 0)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Inventory.view.FuelType', intSort = 9 WHERE strMenuName = 'Fuel Types' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Inventory UOM' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Inventory UOM', N'Inventory', @InventoryParentMenuId, N'Inventory UOM', N'Maintenance', N'Screen', N'Inventory.view.InventoryUOM', N'small-menu-maintenance', 1, 1, 0, 1, 11, 0)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Inventory.view.InventoryUOM', intSort = 11 WHERE strMenuName = 'Inventory UOM' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId
	
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Storage Locations' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Storage Locations', N'Inventory', @InventoryParentMenuId, N'Storage Locations', N'Maintenance', N'Screen', N'Inventory.view.StorageUnit', N'small-menu-maintenance', 1, 1, 0, 1, 12, 0)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Inventory.view.StorageUnit', intSort = 13 WHERE strMenuName = 'Storage Locations' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Stock Details' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Stock Details', N'Inventory', @InventoryParentMenuId, N'Stock Details', N'Maintenance', N'Screen', N'Inventory.view.StockDetail', N'small-menu-report', 1, 1, 0, 1, 14, 0)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Inventory.view.StockDetail', intSort = 14, strIcon = 'small-menu-report' WHERE strMenuName = 'Stock Details' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Lot Details' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Lot Details', N'Inventory', @InventoryParentMenuId, N'Lot Details', N'Maintenance', N'Screen', N'Inventory.view.LotDetail', N'small-menu-report', 1, 1, 0, 1, 15, 0)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Inventory.view.LotDetail', intSort = 15, strIcon = 'small-menu-report' WHERE strMenuName = 'Lot Details' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Inventory Valuation' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Inventory Valuation', N'Inventory', @InventoryParentMenuId, N'Inventory Valuation', N'Maintenance', N'Screen', N'Inventory.view.InventoryValuation', N'small-menu-report', 1, 1, 0, 1, 17, 0)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Inventory.view.InventoryValuation', intSort = 17, strIcon = 'small-menu-report' WHERE strMenuName = 'Inventory Valuation' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Inventory Valuation Summary' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Inventory Valuation Summary', N'Inventory', @InventoryParentMenuId, N'Inventory Valuation Summary', N'Maintenance', N'Screen', N'Inventory.view.InventoryValuationSummary', N'small-menu-report', 1, 1, 0, 1, 18, 0)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Inventory.view.InventoryValuationSummary', intSort = 18, strIcon = 'small-menu-report' WHERE strMenuName = 'Inventory Valuation Summary' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId

/* START OF DELETING */
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Build Assemblies' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Fuel Categories' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Fuel Codes' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Production Process' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Feed Stock' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Feed Stock UOM' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Fuel Tax Class' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Inventory Tags' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Patronage Category' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Manufacturer' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Reasons' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Storage Unit Types' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Item Substitution' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Certification Programs' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Contract Documents' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Lot Status' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Sample Type' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Brand' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Inventory Count Group' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Line of Business' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Inventory Count Name' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Stock Report' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName IN ('View Stock Details', 'View Lot Details') AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId
/* END OF DELETING */

/* PAYROLL */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Payroll' AND strModuleName = 'Payroll' AND intParentMenuID = 0)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Payroll', N'Payroll', 0, N'Payroll', NULL, N'Folder', N'', N'small-folder', 1, 1, 0, 0, 11, 0)
ELSE
	UPDATE tblSMMasterMenu SET  intSort = 11 WHERE strMenuName = 'Payroll' AND strModuleName = 'Payroll' AND intParentMenuID = 0

DECLARE @PayrollParentMenuId INT
SELECT @PayrollParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Payroll' AND strModuleName = 'Payroll' AND intParentMenuID = 0

/* START OF PLURALIZING */
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Timecard' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollParentMenuId)
UPDATE tblSMMasterMenu SET  strMenuName = 'Timecards', strDescription = 'Timecards' WHERE strMenuName = 'Timecard' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollParentMenuId
/* END OF PLURALIZING */

/* START OF RENAMING  */
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Print Checks' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollParentMenuId)
UPDATE tblSMMasterMenu SET  strMenuName = 'Process Paychecks', strDescription = 'Process Paychecks' WHERE strMenuName = 'Print Checks' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollParentMenuId
/* END OF RENAMING  */

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Time Off Requests' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Time Off Requests', N'Payroll', @PayrollParentMenuId, N'Time Off Requests', N'Activity', N'Screen', N'Payroll.view.TimeOffRequest?showSearch=true&searchCommand=TimeOffRequest', N'small-menu-activity', 1, 1, 0, 1, 1, 0)
ELSE 
	UPDATE tblSMMasterMenu SET  intSort = 1, strCommand = N'Payroll.view.TimeOffRequest?showSearch=true&searchCommand=TimeOffRequest' WHERE strMenuName = 'Time Off Requests' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Timecards' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Timecards', N'Payroll', @PayrollParentMenuId, N'Timecards', N'Activity', N'Screen', N'Payroll.view.Timecard', N'small-menu-activity', 1, 1, 0, 1, 2, 0)
ELSE 
	UPDATE tblSMMasterMenu SET  intSort = 2, strCommand = N'Payroll.view.Timecard' WHERE strMenuName = 'Timecards' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Time Approval' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Time Approval', N'Payroll', @PayrollParentMenuId, N'Time Approval', N'Activity', N'Screen', N'Payroll.view.TimeApproval', N'small-menu-activity', 1, 1, 0, 1, 3, 0)
ELSE 
	UPDATE tblSMMasterMenu SET  intSort = 3, strCommand = N'Payroll.view.TimeApproval' WHERE strMenuName = 'Time Approval' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Time History' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Time History', N'Payroll', @PayrollParentMenuId, N'Time History', N'Activity', N'Screen', N'Payroll.view.TimeHistory?showSearch=true&searchCommand=TimeHistory', N'small-menu-activity', 1, 1, 0, 1, 4, 0)
ELSE 
	UPDATE tblSMMasterMenu SET  intSort = 4, strCommand = N'Payroll.view.TimeHistory?showSearch=true&searchCommand=TimeHistory' WHERE strMenuName = 'Time History' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Process Pay Groups' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Process Pay Groups', N'Payroll', @PayrollParentMenuId, N'Process Pay Groups', N'Activity', N'Screen', N'Payroll.view.ProcessPayGroup', N'small-menu-activity', 1, 1, 0, 1, 5, 0)
ELSE 
	UPDATE tblSMMasterMenu SET  intSort = 5, strCommand = N'Payroll.view.ProcessPayGroup' WHERE strMenuName = 'Process Pay Groups' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Paychecks' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Paychecks', N'Payroll', @PayrollParentMenuId, N'Paychecks', N'Activity', N'Screen', N'Payroll.view.Paycheck?showSearch=true&searchCommand=Paycheck', N'small-menu-activity', 1, 1, 0, 1, 6, 0)
ELSE 
	UPDATE tblSMMasterMenu SET  intSort = 6, strCommand = N'Payroll.view.Paycheck?showSearch=true&searchCommand=Paycheck' WHERE strMenuName = 'Paychecks' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Batch Posting' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Batch Posting', N'Payroll', @PayrollParentMenuId, N'Batch Posting', N'Activity', N'Screen', N'Payroll.view.BatchPosting', N'small-menu-activity', 1, 1, 0, 1, 7, 0)
ELSE 
	UPDATE tblSMMasterMenu SET  intSort = 7, strCommand = N'Payroll.view.BatchPosting' WHERE strMenuName = 'Batch Posting' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Process Paychecks' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Process Paychecks', N'Payroll', @PayrollParentMenuId, N'Process Paychecks', N'Activity', N'Screen', N'Payroll.controller.PrintChecks', N'small-menu-activity', 1, 1, 0, 1, 8, 0)
ELSE 
	UPDATE tblSMMasterMenu SET  intSort = 8, strCommand = N'Payroll.controller.PrintChecks' WHERE strMenuName = 'Process Paychecks' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Create Payables' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Create Payables', N'Payroll', @PayrollParentMenuId, N'Create Payables', N'Activity', N'Screen', N'Payroll.view.CreatePayable', N'small-menu-activity', 1, 1, 0, 1, 9, 0)
ELSE 
	UPDATE tblSMMasterMenu SET  intSort = 9, strCommand = N'Payroll.view.CreatePayable' WHERE strMenuName = 'Create Payables' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Employees' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Employees', N'Payroll', @PayrollParentMenuId, N'Employees', N'Maintenance', N'Screen', N'EntityManagement.view.Entity?showSearch=true&searchCommand=searchEntityEmployee', N'small-menu-maintenance', 1, 1, 0, 1, 10, 0)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 10, strCommand = N'EntityManagement.view.Entity?showSearch=true&searchCommand=searchEntityEmployee' WHERE strMenuName = 'Employees' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Paycheck Calculator' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Paycheck Calculator', N'Payroll', @PayrollParentMenuId, N'Paycheck Calculator', N'Maintenance', N'Screen', N'Payroll.view.PaycheckCalculator', N'small-menu-maintenance', 1, 1, 0, 1, 11, 0)
ELSE 
	UPDATE tblSMMasterMenu SET  intSort = 11, strCategory = 'Maintenance', strIcon = N'small-menu-maintenance', strCommand = N'Payroll.view.PaycheckCalculator' WHERE strMenuName = 'Paycheck Calculator' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollParentMenuId
	
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Employee Templates' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Employee Templates', N'Payroll', @PayrollParentMenuId, N'Employee Templates', N'Maintenance', N'Screen', N'Payroll.view.EmployeeTemplate?showSearch=true&searchCommand=EmployeeTemplate', N'small-menu-maintenance', 1, 1, 0, 1, 12, 0)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 12, strCommand = N'Payroll.view.EmployeeTemplate?showSearch=true&searchCommand=EmployeeTemplate' WHERE strMenuName = 'Employee Templates' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Tax Types' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Tax Types', N'Payroll', @PayrollParentMenuId, N'Tax Types', N'Maintenance', N'Screen', N'Payroll.view.TaxType?showSearch=true&searchCommand=TaxType', N'small-menu-maintenance', 1, 1, 0, 1, 13, 0)
ELSE 
	UPDATE tblSMMasterMenu SET  intSort = 13, strCommand = N'Payroll.view.TaxType?showSearch=true&searchCommand=TaxType' WHERE strMenuName = 'Tax Types' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Earning Types' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Earning Types', N'Payroll', @PayrollParentMenuId, N'Earning Types', N'Maintenance', N'Screen', N'Payroll.view.EarningType?showSearch=true&searchCommand=EarningType', N'small-menu-maintenance', 1, 1, 0, 1, 14, 0)
ELSE 
	UPDATE tblSMMasterMenu SET  intSort = 14, strCommand = N'Payroll.view.EarningType?showSearch=true&searchCommand=EarningType' WHERE strMenuName = 'Earning Types' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Employee Pay Groups' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Employee Pay Groups', N'Payroll', @PayrollParentMenuId, N'Employee Pay Groups', N'Maintenance', N'Screen', N'Payroll.view.EmployeePayGroup', N'small-menu-maintenance', 1, 1, 0, 1, 15, 0)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 15, strCommand = N'Payroll.view.EmployeePayGroup' WHERE strMenuName = 'Employee Pay Groups' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Deduction Types' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Deduction Types', N'Payroll', @PayrollParentMenuId, N'Deduction Types', N'Maintenance', N'Screen', N'Payroll.view.DeductionType?showSearch=true&searchCommand=DeductionType', N'small-menu-maintenance', 1, 1, 0, 1, 16, 0)
ELSE 
	UPDATE tblSMMasterMenu SET  intSort = 16, strCommand = N'Payroll.view.DeductionType?showSearch=true&searchCommand=DeductionType' WHERE strMenuName = 'Deduction Types' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Time Off Types' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Time Off Types', N'Payroll', @PayrollParentMenuId, N'Time Off Types', N'Maintenance', N'Screen', N'Payroll.view.TimeOffType?showSearch=true&searchCommand=TimeOffType', N'small-menu-maintenance', 1, 1, 0, 1, 17, 0)
ELSE 
	UPDATE tblSMMasterMenu SET  intSort = 17, strCommand = N'Payroll.view.TimeOffType?showSearch=true&searchCommand=TimeOffType' WHERE strMenuName = 'Time Off Types' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Employee Departments' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Employee Departments', N'Payroll', @PayrollParentMenuId, N'Employee Departments', N'Maintenance', N'Screen', N'Payroll.view.EmployeeDepartment?showSearch=true&searchCommand=EmployeeDepartment', N'small-menu-maintenance', 1, 1, 0, 1, 18, 0)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 18, strCommand = N'Payroll.view.EmployeeDepartment?showSearch=true&searchCommand=EmployeeDepartment' WHERE strMenuName = 'Employee Departments' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Workers Compensation Codes' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Workers Compensation Codes', N'Payroll', @PayrollParentMenuId, N'Workers Compensation Codes', N'Maintenance', N'Screen', N'Payroll.view.WorkersCompensationCodes', N'small-menu-maintenance', 1, 1, 0, 1, 19, 0)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 19, strCommand = N'Payroll.view.WorkersCompensationCodes' WHERE strMenuName = 'Workers Compensation Codes' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Reports' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollParentMenuId)
    INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
    VALUES (N'Reports', N'Payroll', @PayrollParentMenuId, N'Reports', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, NULL, 1)
ELSE
    UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = NULL WHERE strMenuName = 'Reports' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollParentMenuId

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
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Quarterly FUI' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Quarterly SUI' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Quarterly State Tax' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Earnings History' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Earnings History By Department' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Employee Earnings History' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Form 941' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Process W-2' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Workers Compensation' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollParentMenuId
/* END OF DELETING */

/* CONTRACT MANAGEMENT */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Contract Management' AND strModuleName = 'Contract Management' AND intParentMenuID = 0)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Contract Management', N'Contract Management', 0, N'Contract Management', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 13, 0)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 13 WHERE strMenuName = 'Contract Management' AND strModuleName = 'Contract Management' AND intParentMenuID = 0

DECLARE @ContractManagementParentMenuId INT
SELECT @ContractManagementParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Contract Management' AND strModuleName = 'Contract Management' AND intParentMenuID = 0

/* START OF PLURALIZING */
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Contract' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Contracts', strDescription = 'Contracts' WHERE strMenuName = 'Contract' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Contract Text' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Contract Texts', strDescription = 'Contract Texts' WHERE strMenuName = 'Contract Text' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Cost Type' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Cost Types', strDescription = 'Cost Types' WHERE strMenuName = 'Cost Type' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Book' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Books', strDescription = 'Books' WHERE strMenuName = 'Book' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId
/* END OF PLURALIZING */

/* Start of Re-name */
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Approval Basis' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Approval Term', strDescription = 'Approval Term' WHERE strMenuName = 'Approval Basis' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Contract Basis' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'INCO Term', strDescription = 'INCO Term' WHERE strMenuName = 'Contract Basis' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'INCO Term' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'INCO/Ship Term', strDescription = 'INCO/Ship Term' WHERE strMenuName = 'INCO Term' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Position' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Contract Positions', strDescription = 'Contract Positions' WHERE strMenuName = 'Position' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Contract Plans' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'ContractManagement.view.ContractTemplate', strMenuName = 'Contract Templates', strDescription = 'Contract Templates' WHERE strMenuName = 'Contract Plans' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId
/* End of Re-name */

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Contracts' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Contracts', N'Contract Management', @ContractManagementParentMenuId, N'Contracts', N'Activity', N'Screen', N'ContractManagement.view.Contract?showSearch=true', N'small-menu-activity', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 0, strCommand = N'ContractManagement.view.Contract?showSearch=true' WHERE strMenuName = 'Contracts' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Price Contracts' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Price Contracts', N'Contract Management', @ContractManagementParentMenuId, N'Price Contracts', N'Activity', N'Screen', N'ContractManagement.view.PriceContractsNew?showSearch=true', N'small-menu-activity', 0, 0, 0, 1, 1, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 1, strCommand = N'ContractManagement.view.PriceContractsNew?showSearch=true' WHERE strMenuName = 'Price Contracts' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Contract Adjustments' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Contract Adjustments', N'Contract Management', @ContractManagementParentMenuId, N'Contract Adjustments', N'Activity', N'Screen', N'ContractManagement.view.ContractAdjustment?showSearch=true', N'small-menu-activity', 0, 0, 0, 1, 2, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 2, strCommand = N'ContractManagement.view.ContractAdjustment?showSearch=true' WHERE strMenuName = 'Contract Adjustments' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Roll Contracts' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Roll Contracts', N'Contract Management', @ContractManagementParentMenuId, N'Roll Contracts', N'Activity', N'Screen', N'ContractManagement.view.RollContracts', N'small-menu-activity', 0, 0, 0, 1, 3, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 3, strCommand = N'ContractManagement.view.RollContracts' WHERE strMenuName = 'Roll Contracts' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Clean Costs & Weights' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Clean Costs & Weights', N'Contract Management', @ContractManagementParentMenuId, N'Clean Costs & Weights', N'Activity', N'Screen', N'ContractManagement.view.CleanCostsAndWeights?showSearch=true', N'small-menu-activity', 0, 0, 0, 1, 4, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 4, strCommand = N'ContractManagement.view.CleanCostsAndWeights?showSearch=true' WHERE strMenuName = 'Clean Costs & Weights' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Contract Inquiry' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Contract Inquiry', N'Contract Management', @ContractManagementParentMenuId, N'Contract Inquiry', N'Activity', N'Screen', N'ContractManagement.view.ContractInquiry', N'small-menu-activity', 0, 0, 0, 1, 5, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 5, strCommand = N'ContractManagement.view.ContractInquiry' WHERE strMenuName = 'Contract Inquiry' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Contract Status' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Contract Status', N'Contract Management', @ContractManagementParentMenuId, N'Contract Status', N'Activity', N'Screen', N'ContractManagement.view.ContractStatus', N'small-menu-activity', 0, 0, 0, 1, 6, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 6, strCommand = N'ContractManagement.view.ContractStatus' WHERE strMenuName = 'Contract Status' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Contract Texts' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Contract Texts', N'Contract Management', @ContractManagementParentMenuId, N'Contract Texts', N'Maintenance', N'Screen', N'ContractManagement.view.ContractText?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 7, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 7, strCommand = N'ContractManagement.view.ContractText?showSearch=true' WHERE strMenuName = 'Contract Texts' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Crop Year' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Crop Year', N'Contract Management', @ContractManagementParentMenuId, N'Crop Year', N'Maintenance', N'Screen', N'ContractManagement.view.CropYearNew', N'small-menu-maintenance', 0, 0, 0, 1, 8, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 8, strCommand = N'ContractManagement.view.CropYearNew' WHERE strMenuName = 'Crop Year' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Weight/Grades' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Weight/Grades', N'Contract Management', @ContractManagementParentMenuId, N'Weight/Grades', N'Maintenance', N'Screen', N'ContractManagement.view.WeightGradeNew', N'small-menu-maintenance', 0, 0, 0, 1, 9, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 9, strCommand = N'ContractManagement.view.WeightGradeNew' WHERE strMenuName = 'Weight/Grades' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Associations' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Associations', N'Contract Management', @ContractManagementParentMenuId, N'Associations', N'Maintenance', N'Screen', N'ContractManagement.view.Associations', N'small-menu-maintenance', 0, 0, 0, 1, 10, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 10, strCommand = N'ContractManagement.view.Associations' WHERE strMenuName = 'Associations' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Books' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Books', N'Contract Management', @ContractManagementParentMenuId, N'Books', N'Maintenance', N'Screen', N'ContractManagement.view.Book?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 11, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 11, strCommand = N'ContractManagement.view.Book?showSearch=true' WHERE strMenuName = 'Books' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'INCO/Ship Term' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'INCO/Ship Term', N'Contract Management', @ContractManagementParentMenuId, N'INCO/Ship Term', N'Maintenance', N'Screen', N'ContractManagement.view.ContractBasis', N'small-menu-maintenance', 0, 0, 0, 1, 12, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 12, strCommand = N'ContractManagement.view.ContractBasis' WHERE strMenuName = 'INCO/Ship Term' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Contract Positions' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Contract Positions', N'Contract Management', @ContractManagementParentMenuId, N'Contract Positions', N'Maintenance', N'Screen', N'ContractManagement.view.Position', N'small-menu-maintenance', 0, 0, 0, 1, 13, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 13, strCommand = N'ContractManagement.view.Position' WHERE strMenuName = 'Contract Positions' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Contract Templates' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Contract Templates', N'Contract Management', @ContractManagementParentMenuId, N'Contract Templates', N'Maintenance', N'Screen', N'ContractManagement.view.ContractTemplate?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 14, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 14, strCommand = N'ContractManagement.view.ContractTemplate?showSearch=true' WHERE strMenuName = 'Contract Templates' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Indexes' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Indexes', N'Contract Management', @ContractManagementParentMenuId, N'Indexes', N'Maintenance', N'Screen', N'ContractManagement.view.Index', N'small-menu-maintenance', 0, 0, 0, 1, 15, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 15, strCommand = N'ContractManagement.view.Position' WHERE strMenuName = 'Indexes' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Event Configuration' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Event Configuration', N'Contract Management', @ContractManagementParentMenuId, N'Event Configuration', N'Maintenance', N'Screen', N'ContractManagement.view.EventConfiguration?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 16, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 16, strCommand = N'ContractManagement.view.EventConfiguration?showSearch=true' WHERE strMenuName = 'Event Configuration' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Event Matrix' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Event Matrix', N'Contract Management', @ContractManagementParentMenuId, N'Event Matrix', N'Maintenance', N'Screen', N'ContractManagement.view.EventMatrix?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 17, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 17, strCommand = N'ContractManagement.view.EventMatrix?showSearch=true' WHERE strMenuName = 'Event Matrix' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Condition' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Condition', N'Contract Management', @ContractManagementParentMenuId, N'Condition', N'Maintenance', N'Screen', N'ContractManagement.view.Condition', N'small-menu-maintenance', 0, 0, 0, 1, 18, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 18, strCommand = N'ContractManagement.view.Condition' WHERE strMenuName = 'Condition' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Documents' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Documents', N'Contract Management', @ContractManagementParentMenuId, N'Documents', N'Maintenance', N'Screen', N'Inventory.view.ContractDocument?showSearch=true', N'small-menu-maintenance', 1, 1, 0, 1, 19, 0)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 19, strCommand = N'Inventory.view.ContractDocument?showSearch=true' WHERE strMenuName = 'Documents' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Producers' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Producers', N'Contract Management', @ContractManagementParentMenuId, N'Producers', N'Maintenance', N'Screen', N'EntityManagement.view.Entity?showSearch=true&searchCommand=searchEntityProducer', N'small-menu-maintenance', 1, 1, 0, 1, 20, 0)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 20, strCommand = N'EntityManagement.view.Entity?showSearch=true&searchCommand=searchEntityProducer' WHERE strMenuName = 'Producers' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Annual Operation Planning' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Annual Operation Planning', N'Contract Management', @ContractManagementParentMenuId, N'Annual Operation Planning', N'Maintenance', N'Screen', N'ContractManagement.view.AnnualOperatingPlanning?showSearch=true', N'small-menu-maintenance', 0, 0, 0, 1, 21, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 21, strCommand = N'ContractManagement.view.AnnualOperatingPlanning?showSearch=true' WHERE strMenuName = 'Annual Operation Planning' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Brokers' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Brokers', N'Contract Management', @ContractManagementParentMenuId, N'Brokers', N'Maintenance', N'Screen', N'EntityManagement.view.Entity?showSearch=true&searchCommand=searchEntityBroker', N'small-menu-maintenance', 0, 0, 0, 1, 22, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 22, strCommand = N'EntityManagement.view.Entity?showSearch=true&searchCommand=searchEntityBroker' WHERE strMenuName = 'Brokers' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Amendment' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Amendment', N'Contract Management', @ContractManagementParentMenuId, N'Amendment', N'Maintenance', N'Screen', N'ContractManagement.view.Amendments', N'small-menu-maintenance', 0, 0, 0, 1, 23, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 23, strCommand = N'ContractManagement.view.Amendments' WHERE strMenuName = 'Amendment' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Need Plan' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Need Plan', N'Contract Management', @ContractManagementParentMenuId, N'Need Plan', N'Maintenance', N'Screen', N'ContractManagement.view.NeedPlan', N'small-menu-maintenance', 0, 0, 0, 1, 24, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 24, strCommand = N'ContractManagement.view.NeedPlan' WHERE strMenuName = 'Need Plan' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Certification Programs' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Certification Programs', N'Contract Management', @ContractManagementParentMenuId, N'Certification Programs', N'Maintenance', N'Screen', N'Inventory.view.CertificationProgram?showSearch=true', N'small-menu-maintenance', 1, 1, 0, 1, 16, 0)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Inventory.view.CertificationProgram?showSearch=true' WHERE strMenuName = 'Certification Programs' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Basis Component' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Basis Component', N'Contract Management', @ContractManagementParentMenuId, N'Basis Component', N'Maintenance', N'Screen', N'Reporting.view.ReportManager?group=Contract Management&report=BasisComponent&direct=true&showCriteria=true', N'small-menu-maintenance', 1, 1, 0, 1, 17, 0)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Reporting.view.ReportManager?group=Contract Management&report=BasisComponent&direct=true&showCriteria=true' WHERE strMenuName = 'Basis Component' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId

/* Start of Delete */
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Contract Options' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Cost Types' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Freight Rates' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Annual Operating Planning' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Deferred Payment Rates' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Approval Term' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId
/* End of Delete */


/* NOTES RECEIVABLE */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Notes Receivable' AND strModuleName = 'Notes Receivable' AND intParentMenuID = 0)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Notes Receivable', N'Notes Receivable', 0, N'Notes Receivable', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 12, 0)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 12 WHERE strMenuName = 'Notes Receivable' AND strModuleName = 'Notes Receivable' AND intParentMenuID = 0

DECLARE @NotesReceivableParentMenuId INT
SELECT @NotesReceivableParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Notes Receivable' AND strModuleName = 'Notes Receivable' AND intParentMenuID = 0

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Reports' AND strModuleName = 'Notes Receivable' AND intParentMenuID = @NotesReceivableParentMenuId)
    INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
    VALUES (N'Reports', N'Notes Receivable', @NotesReceivableParentMenuId, N'Reports', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, NULL, 1)
ELSE
    UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = NULL WHERE strMenuName = 'Reports' AND strModuleName = 'Notes Receivable' AND intParentMenuID = @NotesReceivableParentMenuId

DECLARE @NotesReceivableReportParentMenuId INT
SELECT @NotesReceivableReportParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Reports' AND strModuleName = 'Notes Receivable' AND intParentMenuID = @NotesReceivableParentMenuId

/* Rename Note Maintenance to Note Receivables */
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Note Maintenance' AND strModuleName = 'Notes Receivable' AND intParentMenuID = @NotesReceivableParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Notes Receivables', strDescription = 'Notes Receivables' WHERE strMenuName = 'Note Maintenance' AND strModuleName = 'Notes Receivable' AND intParentMenuID = @NotesReceivableParentMenuId

/* Start of moving report */
UPDATE tblSMMasterMenu SET intParentMenuID = @NotesReceivableReportParentMenuId WHERE strMenuName = 'UCC Tracking' AND strModuleName = 'Notes Receivable' AND strType = 'Report' AND intParentMenuID = @NotesReceivableParentMenuId
UPDATE tblSMMasterMenu SET intParentMenuID = @NotesReceivableReportParentMenuId WHERE strMenuName = 'Aged Notes Receivable' AND strModuleName = 'Notes Receivable' AND strType = 'Report' AND intParentMenuID = @NotesReceivableParentMenuId
UPDATE tblSMMasterMenu SET intParentMenuID = @NotesReceivableReportParentMenuId WHERE strMenuName = '1098' AND strModuleName = 'Notes Receivable' AND strType = 'Report' AND intParentMenuID = @NotesReceivableParentMenuId
/* End of moving report */

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Notes Receivables' AND strModuleName = 'Notes Receivable' AND intParentMenuID = @NotesReceivableParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId])
	VALUES (N'Notes Receivables', N'Notes Receivable', @NotesReceivableParentMenuId, N'Notes Receivables', N'Activity', N'Screen', N'NotesReceivable.view.NotesReceivable', N'small-menu-activity', 0, 0, 0, 1, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = N'NotesReceivable.view.NotesReceivable' WHERE strMenuName = 'Notes Receivables' AND strModuleName = 'Notes Receivable' AND intParentMenuID = @NotesReceivableParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Calculate Monthly Interest' AND strModuleName = 'Notes Receivable' AND intParentMenuID = @NotesReceivableParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Calculate Monthly Interest', N'Notes Receivable', @NotesReceivableParentMenuId, N'Calculate Monthly Interest', N'Activity', N'Screen', N'NotesReceivable.view.CalculateMonthlyInterest', N'small-menu-activity', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'NotesReceivable.view.CalculateMonthlyInterest' WHERE strMenuName = 'Calculate Monthly Interest' AND strModuleName = 'Notes Receivable' AND intParentMenuID = @NotesReceivableParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Note Description' AND strModuleName = 'Notes Receivable' AND intParentMenuID = @NotesReceivableParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Note Description', N'Notes Receivable', @NotesReceivableParentMenuId, N'Note Description', N'Maintenance', N'Screen', N'NotesReceivable.view.NoteDescription', N'small-menu-maintenance', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'NotesReceivable.view.NoteDescription' WHERE strMenuName = 'Note Description' AND strModuleName = 'Notes Receivable' AND intParentMenuID = @NotesReceivableParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Show Adjustment As' AND strModuleName = 'Notes Receivable' AND intParentMenuID = @NotesReceivableParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Show Adjustment As', N'Notes Receivable', @NotesReceivableParentMenuId, N'Show Adjustment As', N'Maintenance', N'Screen', N'NotesReceivable.view.ShowAdjustmentAs', N'small-menu-maintenance', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'NotesReceivable.view.ShowAdjustmentAs' WHERE strMenuName = 'Show Adjustment As' AND strModuleName = 'Notes Receivable' AND intParentMenuID = @NotesReceivableParentMenuId

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

/* TICKET MANAGEMENT */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Ticket Management' AND strModuleName = 'Ticket Management' AND intParentMenuID = 0)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Ticket Management', N'Ticket Management', 0, N'Ticket Management', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 15, 0)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 15 WHERE strMenuName = 'Ticket Management' AND strModuleName = 'Ticket Management' AND intParentMenuID = 0

DECLARE @TicketManagementParentMenuId INT
SELECT @TicketManagementParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Ticket Management' AND strModuleName = 'Ticket Management' AND intParentMenuID = 0

-- START OF RENAMING
UPDATE tblSMMasterMenu SET strMenuName = N'Tickets' WHERE strMenuName = 'Enter Tickets' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementParentMenuId
-- END OF RENAMING

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Tickets' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Tickets', N'Ticket Management', @TicketManagementParentMenuId, N'Tickets', N'Activity', N'Screen', N'Grain.view.ScaleStationSelection', N'small-menu-activity', 0, 0, 0, 1, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'Grain.view.ScaleStationSelection', intSort = 0 WHERE strMenuName = 'Tickets' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Ticket Formats' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Ticket Formats', N'Ticket Management', @TicketManagementParentMenuId, N'Ticket Format', N'Maintenance', N'Screen', N'Grain.view.TicketFormats', N'small-menu-maintenance', 0, 0, 0, 1, 1, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'Grain.view.TicketFormats', intSort = 1 WHERE strMenuName = 'Ticket Formats' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Physical Scales' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Physical Scales', N'Ticket Management', @TicketManagementParentMenuId, N'Physical Scales', N'Maintenance', N'Screen', N'Grain.view.PhysicalScale', N'small-menu-maintenance', 0, 0, 0, 1, 2, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'Grain.view.PhysicalScale',  intSort = 2 WHERE strMenuName = 'Physical Scales' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Grading Equipment' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Grading Equipment', N'Ticket Management', @TicketManagementParentMenuId, N'Grading Equipment', N'Maintenance', N'Screen', N'Grain.view.GradingEquipment', N'small-menu-maintenance', 0, 0, 0, 1, 3, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'Grain.view.GradingEquipment', intSort = 3 WHERE strMenuName = 'Grading Equipment' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Ticket Pools' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Ticket Pools', N'Ticket Management', @TicketManagementParentMenuId, N'Ticket Pools', N'Maintenance', N'Screen', N'Grain.view.TicketPool', N'small-menu-maintenance', 0, 0, 0, 1, 4, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'Grain.view.TicketPool', intSort = 4 WHERE strMenuName = 'Ticket Pools' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Scale Station Settings' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Scale Station Settings', N'Ticket Management', @TicketManagementParentMenuId, N'Scale Station Settings', N'Maintenance', N'Screen', N'Grain.view.ScaleStationSettings', N'small-menu-maintenance', 0, 0, 0, 1, 5, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'Grain.view.ScaleStationSettings', intSort = 5 WHERE strMenuName = 'Scale Station Settings' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Storage' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Storage', N'Ticket Management', @TicketManagementParentMenuId, N'Storage', N'Maintenance', N'Screen', N'Grain.view.Storage', N'small-menu-maintenance', 0, 0, 0, 1, 6, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Grain.view.Storage', intSort = 6, strCategory = N'Maintenance' WHERE strMenuName = 'Storage' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'OffSite' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'OffSite', N'Ticket Management', @TicketManagementParentMenuId, N'OffSite', N'Maintenance', N'Screen', N'Grain.view.OffSite', N'small-menu-maintenance', 0, 0, 0, 1, 7, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Grain.view.OffSite', intSort = 7, strCategory = N'Maintenance' WHERE strMenuName = 'OffSite' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementParentMenuId

--IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Discount Tables' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementParentMenuId)
--	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
--	VALUES (N'Discount Tables', N'Ticket Management', @TicketManagementParentMenuId, N'Discount Tables', N'Maintenance', N'Screen', N'Grain.view.DiscountTable', N'small-menu-maintenance', 0, 0, 0, 1, 8, 1)
--ELSE 
--	UPDATE tblSMMasterMenu SET strCommand = N'Grain.view.DiscountTable', intSort = 8 WHERE strMenuName = 'Discount Tables' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementParentMenuId

--IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Discount Schedules' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementParentMenuId)
--	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
--	VALUES (N'Discount Schedules', N'Ticket Management', @TicketManagementParentMenuId, N'Discount Schedules', N'Maintenance', N'Screen', N'Grain.view.DiscountSchedule', N'small-menu-maintenance', 0, 0, 0, 1, 9, 1)
--ELSE 
--	UPDATE tblSMMasterMenu SET strCommand = N'Grain.view.DiscountSchedule', intSort = 9 WHERE strMenuName = 'Discount Schedules' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementParentMenuId

	DELETE FROM tblSMMasterMenu WHERE strMenuName IN('Discount Tables','Discount Schedules')

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Discounts' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Discounts', N'Ticket Management', @TicketManagementParentMenuId, N'Discounts', N'Maintenance', N'Screen', N'Grain.view.DiscountTable', N'small-menu-maintenance', 0, 0, 0, 1, 8, 1)
ELSE 
    UPDATE tblSMMasterMenu SET strCommand = N'Grain.view.DiscountTable', intSort = 8 WHERE strMenuName = 'Discounts' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Storage Types' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Storage Types', N'Ticket Management', @TicketManagementParentMenuId, N'Storage Types', N'Maintenance', N'Screen', N'Grain.view.GrainStorageType', N'small-menu-maintenance', 0, 0, 0, 1, 10, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Grain.view.GrainStorageType', intSort = 10 WHERE strMenuName = 'Storage Types' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Storage Schedule' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Storage Schedule', N'Ticket Management', @TicketManagementParentMenuId, N'Storage Schedule', N'Maintenance', N'Screen', N'Grain.view.StorageSchedule', N'small-menu-maintenance', 0, 0, 0, 11, 4, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Grain.view.StorageSchedule', intSort = 11 WHERE strMenuName = 'Storage Schedule' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Reports' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Reports', N'Ticket Management', @TicketManagementParentMenuId, N'Reports', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, NULL, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCategory = NULL, strIcon = 'small-folder', strCommand = N'', intSort = NULL WHERE strMenuName = 'Reports' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementParentMenuId

DECLARE @TicketManagementReportParentMenuId INT
SELECT @TicketManagementReportParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Reports' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementParentMenuId

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

/* MANUFACTURING */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Manufacturing' AND strModuleName = 'Manufacturing' AND intParentMenuID = 0)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Manufacturing', N'Manufacturing', 0, N'Manufacturing', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 17, 0)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 17 WHERE strMenuName = 'Manufacturing' AND strModuleName = 'Manufacturing' AND intParentMenuID = 0

DECLARE @ManufacturingParentMenuId INT
SELECT @ManufacturingParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Manufacturing' AND strModuleName = 'Manufacturing' AND intParentMenuID = 0

/* START OF PLURALIZING */
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Blend Requirement' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Blend Requirements', strDescription = 'Blend Requirements' WHERE strMenuName = 'Blend Requirement' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Bag Off' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Bag Offs', strDescription = 'Bag Offs' WHERE strMenuName = 'Bag Off' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Recipe' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Recipes', strDescription = 'Recipes' WHERE strMenuName = 'Recipe' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingParentMenuId
--IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Machine' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingParentMenuId)
--UPDATE tblSMMasterMenu SET strMenuName = 'Machines', strDescription = 'Machines' WHERE strMenuName = 'Machine' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Manufacturing Cell' AND strModuleName = 'Inventory' AND intParentMenuID = @ManufacturingParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Manufacturing Cells', strDescription = 'Manufacturing Cells' WHERE strMenuName = 'Manufacturing Cell' AND strModuleName = 'Inventory' AND intParentMenuID = @ManufacturingParentMenuId
--IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Pack Type' AND strModuleName = 'Inventory' AND intParentMenuID = @ManufacturingParentMenuId)
--UPDATE tblSMMasterMenu SET strMenuName = 'Pack Types', strDescription = 'Pack Types' WHERE strMenuName = 'Pack Type' AND strModuleName = 'Inventory' AND intParentMenuID = @ManufacturingParentMenuId
/* END OF PLURALIZING */

/* Start of Rename and Remodule */
UPDATE tblSMMasterMenu SET strMenuName = N'Production Runs View' WHERE strMenuName = 'Process Production Runs View' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingParentMenuId
UPDATE tblSMMasterMenu SET strModuleName = 'Manufacturing', intParentMenuID = @ManufacturingParentMenuId WHERE strMenuName IN ('Demand Analysis View','Blend Demand') AND strModuleName = 'Contract Management'
UPDATE tblSMMasterMenu SET strCommand = N'Manufacturing.view.ManufacturingCell', strModuleName = 'Manufacturing' WHERE strMenuName = 'Manufacturing Cells' AND strModuleName = 'Inventory' AND intParentMenuID = @ManufacturingParentMenuId
/* End of Rename and Remodule */

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Blend Requirements' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Blend Requirements', N'Manufacturing', @ManufacturingParentMenuId, N'Blend Requirements', N'Activity', N'Screen', N'Manufacturing.view.BlendRequirementManager', N'small-menu-activity', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Manufacturing.view.BlendRequirementManager' WHERE strMenuName = 'Blend Requirements' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Blend Management' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Blend Management', N'Manufacturing', @ManufacturingParentMenuId, N'Blend Management', N'Activity', N'Screen', N'Manufacturing.view.BlendManagement', N'small-menu-activity', 0, 0, 0, 1, 1, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 1, strCommand = N'Manufacturing.view.BlendManagement' WHERE strMenuName = 'Blend Management' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Blend Production' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Blend Production', N'Manufacturing', @ManufacturingParentMenuId, N'Blend Production', N'Activity', N'Screen', N'Manufacturing.view.BlendProduction', N'small-menu-activity', 0, 0, 0, 1, 2, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 2, strCommand = N'Manufacturing.view.BlendProduction' WHERE strMenuName = 'Blend Production' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Bag Offs' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Bag Offs', N'Manufacturing', @ManufacturingParentMenuId, N'Bag Offs', N'Activity', N'Screen', N'Manufacturing.view.BagOff', N'small-menu-activity', 0, 0, 0, 1, 3, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 3, strCommand = N'Manufacturing.view.BagOff' WHERE strMenuName = 'Bag Offs' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Release To Warehouse' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Release To Warehouse', N'Manufacturing', @ManufacturingParentMenuId, N'Release To Warehouse', N'Activity', N'Screen', N'Manufacturing.view.ReleaseToWarehouse', N'small-menu-activity', 0, 0, 0, 1, 4, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 4, strCommand = N'Manufacturing.view.ReleaseToWarehouse' WHERE strMenuName = 'Release To Warehouse' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Kit Manager' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Kit Manager', N'Manufacturing', @ManufacturingParentMenuId, N'Kit Manager', N'Activity', N'Screen', N'Manufacturing.view.KitManager', N'small-menu-activity', 0, 0, 0, 1, 5, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 5, strCommand = N'Manufacturing.view.KitManager' WHERE strMenuName = 'Kit Manager' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Blend Sheet Approval' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Blend Sheet Approval', N'Manufacturing', @ManufacturingParentMenuId, N'Blend Sheet Approval', N'Activity', N'Screen', N'Manufacturing.view.BlendSheetApproval', N'small-menu-activity', 0, 0, 0, 1, 6, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 6, strCommand = N'Manufacturing.view.BlendSheetApproval' WHERE strMenuName = 'Blend Sheet Approval' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Traceability' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Traceability', N'Manufacturing', @ManufacturingParentMenuId, N'Traceability', N'Activity', N'Screen', N'Manufacturing.view.TraceabilityDiagram', N'small-menu-activity', 0, 0, 0, 1, 7, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 7, strCommand = N'Manufacturing.view.TraceabilityDiagram' WHERE strMenuName = 'Traceability' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Work Order Planning' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Work Order Planning', N'Manufacturing', @ManufacturingParentMenuId, N'Work Order Planning', N'Activity', N'Screen', N'Manufacturing.view.WorkOrderCreation', N'small-menu-activity', 0, 0, 0, 1, 8, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 8, strCommand = N'Manufacturing.view.WorkOrderCreation' WHERE strMenuName = 'Work Order Planning' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Work Order Management' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Work Order Management', N'Manufacturing', @ManufacturingParentMenuId, N'Work Order Management', N'Activity', N'Screen', N'Manufacturing.view.WorkOrder', N'small-menu-activity', 0, 0, 0, 1, 9, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 9, strCommand = N'Manufacturing.view.WorkOrder' WHERE strMenuName = 'Work Order Management' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Work Order Schedule' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Work Order Schedule', N'Manufacturing', @ManufacturingParentMenuId, N'Work Order Schedule', N'Activity', N'Screen', N'Manufacturing.view.Schedule', N'small-menu-activity', 0, 0, 0, 1, 10, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 10, strCommand = N'Manufacturing.view.Schedule' WHERE strMenuName = 'Work Order Schedule' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Finished Goods Production' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Finished Goods Production', N'Manufacturing', @ManufacturingParentMenuId, N'Finished Goods Production', N'Activity', N'Screen', N'Manufacturing.view.FinishedGoodsProduction', N'small-menu-activity', 0, 0, 0, 1, 11, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 11, strCommand = N'Manufacturing.view.FinishedGoodsProduction' WHERE strMenuName = 'Finished Goods Production' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingParentMenuId
	
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Transaction View' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Transaction View', N'Manufacturing', @ManufacturingParentMenuId, N'Transaction View', N'Activity', N'Screen', N'Manufacturing.view.TransactionView', N'small-menu-activity', 0, 0, 0, 1, 12, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 12, strCommand = N'Manufacturing.view.TransactionView' WHERE strMenuName = 'Transaction View' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Production Runs View' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Production Runs View', N'Manufacturing', @ManufacturingParentMenuId, N'Production Runs View', N'Activity', N'Screen', N'Manufacturing.view.ProcessProductionRunsView', N'small-menu-activity', 0, 0, 0, 1, 13, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 13, strCommand = N'Manufacturing.view.ProcessProductionRunsView' WHERE strMenuName = 'Production Runs View' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Traceability By Parent Lot' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Traceability By Parent Lot', N'Manufacturing', @ManufacturingParentMenuId, N'Traceability By Parent Lot', N'Activity', N'Screen', N'Manufacturing.view.TraceabilityDiagram?ysnParentLot=true', N'small-menu-activity', 0, 0, 0, 1, 14, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 14, strCommand = N'Manufacturing.view.TraceabilityDiagram?ysnParentLot=true' WHERE strMenuName = 'Traceability By Parent Lot' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Blend Consolidation View' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Blend Consolidation View', N'Manufacturing', @ManufacturingParentMenuId, N'Blend Consolidation View', N'Activity', N'Screen', N'Manufacturing.view.GenericTransactionView?searchCommand=searchConfigBlendConsolidationView', N'small-menu-activity', 0, 0, 0, 1, 15, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 15, strCommand = N'Manufacturing.view.GenericTransactionView?searchCommand=searchConfigBlendConsolidationView' WHERE strMenuName = 'Blend Consolidation View' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Yield View' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Yield View', N'Manufacturing', @ManufacturingParentMenuId, N'Yield View', N'Activity', N'Screen', N'Manufacturing.view.YieldView', N'small-menu-activity', 0, 0, 0, 1, 16, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 16, strCommand = N'Manufacturing.view.YieldView' WHERE strMenuName = 'Yield View' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Efficiency Views' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Efficiency Views', N'Manufacturing', @ManufacturingParentMenuId, N'Efficiency Views', N'Activity', N'Screen', N'Manufacturing.view.ShiftActivityView', N'small-menu-activity', 1, 0, 0, 1, 17, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 17, strCommand = N'Manufacturing.view.ShiftActivityView' WHERE strMenuName = 'Efficiency Views' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Inventory View' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Inventory View', N'Manufacturing', @ManufacturingParentMenuId, N'Inventory View', N'Activity', N'Screen', N'Manufacturing.view.InventoryView', N'small-menu-activity', 1, 0, 0, 1, 18, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 18, strCommand = N'Manufacturing.view.InventoryView', strType = N'Screen' WHERE strMenuName = 'Inventory View' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Shift Activity' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Shift Activity', N'Manufacturing', @ManufacturingParentMenuId, N'Shift Activity', N'Activity', N'Screen', N'Manufacturing.view.EfficiencyShiftActivity', N'small-menu-activity', 1, 0, 0, 1, 19, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 19, strCommand = N'Manufacturing.view.EfficiencyShiftActivity', strType = N'Screen' WHERE strMenuName = 'Shift Activity' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Finished Goods Forecast' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Finished Goods Forecast', N'Manufacturing', @ManufacturingParentMenuId, N'Finished Goods Forecast', N'Activity', N'Screen', N'Manufacturing.view.FinishedGoodsForecast', N'small-menu-activity', 0, 0, 0, 1, 20, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 20, strCommand = N'Manufacturing.view.FinishedGoodsForecast' WHERE strMenuName = 'Finished Goods Forecast' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Demand Analysis View' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Demand Analysis View', N'Manufacturing', @ManufacturingParentMenuId, N'Demand Analysis View', N'Maintenance', N'Screen', N'Manufacturing.view.DemandAnalysisView', N'small-menu-maintenance', 0, 0, 0, 1, 21, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 21, strCommand = N'Manufacturing.view.DemandAnalysisView' WHERE strMenuName = 'Demand Analysis View' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Manufacturing Process' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Manufacturing Process', N'Manufacturing', @ManufacturingParentMenuId, N'Manufacturing Process', N'Maintenance', N'Screen', N'Manufacturing.view.ManufacturingProcess', N'small-menu-maintenance', 0, 0, 0, 1, 22, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 22, strCommand = N'Manufacturing.view.ManufacturingProcess' WHERE strMenuName = 'Manufacturing Process' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Recipes' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Recipes', N'Manufacturing', @ManufacturingParentMenuId, N'Recipes', N'Maintenance', N'Screen', N'Manufacturing.view.Recipe', N'small-menu-maintenance', 0, 0, 0, 1, 23, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 23, strCommand = N'Manufacturing.view.Recipe' WHERE strMenuName = 'Recipes' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Manufacturing Cells / Machines' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Manufacturing Cells / Machines', N'Manufacturing', @ManufacturingParentMenuId, N'Manufacturing Cells / Machines', N'Maintenance', N'Screen', N'Manufacturing.view.ManufacturingCell', N'small-menu-maintenance', 1, 1, 0, 1, 24, 0)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 24, strCommand = N'Manufacturing.view.ManufacturingCell' WHERE strMenuName = 'Manufacturing Cells / Machines' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Shifts' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Shifts', N'Manufacturing', @ManufacturingParentMenuId, N'Shifts', N'Maintenance', N'Screen', N'Manufacturing.view.Shift', N'small-menu-maintenance', 0, 0, 0, 1, 25, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 25, strCommand = N'Manufacturing.view.Shift' WHERE strMenuName = 'Shifts' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Production Calendar' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Production Calendar', N'Manufacturing', @ManufacturingParentMenuId, N'Production Calendar', N'Maintenance', N'Screen', N'Manufacturing.view.ProductionCalendar', N'small-menu-maintenance', 0, 0, 0, 1, 26, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 26, strCommand = N'Manufacturing.view.ProductionCalendar' WHERE strMenuName = 'Production Calendar' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingParentMenuId
	
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Production Schedule Rules' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Production Schedule Rules', N'Manufacturing', @ManufacturingParentMenuId, N'Production Schedule Rules', N'Maintenance', N'Screen', N'Manufacturing.view.ProductionScheduleRules', N'small-menu-maintenance', 0, 0, 0, 1, 27, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 27, strCommand = N'Manufacturing.view.ProductionScheduleRules' WHERE strMenuName = 'Production Schedule Rules' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Reason' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Reason', N'Manufacturing', @ManufacturingParentMenuId, N'Reason', N'Maintenance', N'Screen', N'Manufacturing.view.Reason', N'small-menu-maintenance', 0, 0, 0, 1, 28, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 28, strCommand = N'Manufacturing.view.Reason' WHERE strMenuName = 'Reason' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Scheduled Maintenance' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Scheduled Maintenance', N'Manufacturing', @ManufacturingParentMenuId, N'Scheduled Maintenance', N'Maintenance', N'Screen', N'Manufacturing.view.ScheduledMaintenance', N'small-menu-maintenance', 0, 0, 0, 1, 29, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 29, strCommand = N'Manufacturing.view.ScheduledMaintenance' WHERE strMenuName = 'Scheduled Maintenance' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingParentMenuId

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


/* STORE */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Store' AND strModuleName = 'Store' AND intParentMenuID = 0)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Store', N'Store', 0, N'Store', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 20, 0)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 20 WHERE strMenuName = 'Store' AND strModuleName = 'Store' AND intParentMenuID = 0

DECLARE @StoreParentMenuId INT
SELECT @StoreParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Store' AND strModuleName = 'Store' AND intParentMenuID = 0

/* Start of Re-name */
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Inventory Mass Maintenance' AND strModuleName = 'Store' AND intParentMenuID = @StoreParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Inventory Mass', strDescription = 'Inventory Mass' WHERE strMenuName = 'Inventory Mass Maintenance' AND strModuleName = 'Store' AND intParentMenuID = @StoreParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Store Maintenance' AND strModuleName = 'Store' AND intParentMenuID = @StoreParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Stores', strDescription = 'Stores' WHERE strMenuName = 'Store Maintenance' AND strModuleName = 'Store' AND intParentMenuID = @StoreParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Register Maintenance' AND strModuleName = 'Store' AND intParentMenuID = @StoreParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Registers', strDescription = 'Registers' WHERE strMenuName = 'Register Maintenance' AND strModuleName = 'Store' AND intParentMenuID = @StoreParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'SubCategory' AND strModuleName = 'Store' AND intParentMenuID = @StoreParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Subcategories', strDescription = 'Subcategories' WHERE strMenuName = 'SubCategory' AND strModuleName = 'Store' AND intParentMenuID = @StoreParentMenuId

/* End of Re-name */

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Update Item Pricing' AND strModuleName = 'Store' AND intParentMenuID = @StoreParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Update Item Pricing', N'Store', @StoreParentMenuId, N'Update Item Pricing', N'Activity', N'Screen', N'Store.view.UpdateItemPricing', N'small-menu-activity', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 0, strCommand = N'Store.view.UpdateItemPricing' WHERE strMenuName = 'Update Item Pricing' AND strModuleName = 'Store' AND intParentMenuID = @StoreParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Update Rebate/Discount' AND strModuleName = 'Store' AND intParentMenuID = @StoreParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Update Rebate/Discount', N'Store', @StoreParentMenuId, N'Update Rebate/Discount', N'Activity', N'Screen', N'Store.view.UpdateRebateDiscount', N'small-menu-activity', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 1, strCommand = N'Store.view.UpdateRebateDiscount' WHERE strMenuName = 'Update Rebate/Discount' AND strModuleName = 'Store' AND intParentMenuID = @StoreParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Update Item Data' AND strModuleName = 'Store' AND intParentMenuID = @StoreParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Update Item Data', N'Store', @StoreParentMenuId, N'Update Item Data', N'Activity', N'Screen', N'Store.view.UpdateItemData', N'small-menu-activity', 0, 0, 0, 1, 2, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 2, strCommand = N'Store.view.UpdateItemData' WHERE strMenuName = 'Update Item Data' AND strModuleName = 'Store' AND intParentMenuID = @StoreParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Inventory Mass' AND strModuleName = 'Store' AND intParentMenuID = @StoreParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Inventory Mass', N'Store', @StoreParentMenuId, N'Inventory Mass', N'Activity', N'Screen', N'Store.view.InventoryMassMaintenance', N'small-menu-activity', 0, 0, 0, 1, 3, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 3, strCommand = N'Store.view.InventoryMassMaintenance' WHERE strMenuName = 'Inventory Mass' AND strModuleName = 'Store' AND intParentMenuID = @StoreParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Update Register' AND strModuleName = 'Store' AND intParentMenuID = @StoreParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Update Register', N'Store', @StoreParentMenuId, N'Update Register', N'Activity', N'Screen', N'Store.view.UpdateRegister', N'small-menu-activity', 1, 0, 0, 1, 4, 1)
ELSE 
	UPDATE tblSMMasterMenu SET  intSort = 4, strCommand = N'Store.view.UpdateRegister' , ysnVisible = 1 WHERE strMenuName = 'Update Register' AND strModuleName = 'Store' AND intParentMenuID = @StoreParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Mark Up/Down' AND strModuleName = 'Store' AND intParentMenuID = @StoreParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Mark Up/Down', N'Store', @StoreParentMenuId, N'Mark Up/Down', N'Activity', N'Screen', N'Store.view.MarkUpDown', N'small-menu-activity', 1, 0, 0, 1, 5, 1)
ELSE 
	UPDATE tblSMMasterMenu SET  intSort = 5, strCommand = N'Store.view.MarkUpDown' , ysnVisible = 1 WHERE strMenuName = 'Mark Up/Down' AND strModuleName = 'Store' AND intParentMenuID = @StoreParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Checkout' AND strModuleName = 'Store' AND intParentMenuID = @StoreParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Checkout', N'Store', @StoreParentMenuId, N'Checkout', N'Activity', N'Screen', N'Store.view.CheckoutHeader', N'small-menu-activity', 1, 0, 0, 1, 6, 1)
ELSE 
	UPDATE tblSMMasterMenu SET  intSort = 6, strCommand = N'Store.view.CheckoutHeader', ysnVisible = 1 WHERE strMenuName = 'Checkout' AND strModuleName = 'Store' AND intParentMenuID = @StoreParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Stores' AND strModuleName = 'Store' AND intParentMenuID = @StoreParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Stores', N'Store', @StoreParentMenuId, N'Stores', N'Maintenance', N'Screen', N'Store.view.Store', N'small-menu-maintenance', 0, 0, 0, 1, 7, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 7, strCommand = N'Store.view.Store' WHERE strMenuName = 'Stores' AND strModuleName = 'Store' AND intParentMenuID = @StoreParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Registers' AND strModuleName = 'Store' AND intParentMenuID = @StoreParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Registers', N'Store', @StoreParentMenuId, N'Registers', N'Maintenance', N'Screen', N'Store.view.Register', N'small-menu-maintenance', 0, 0, 0, 1, 8, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 8, strCommand = N'Store.view.Register' WHERE strMenuName = 'Registers' AND strModuleName = 'Store' AND intParentMenuID = @StoreParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Subcategories' AND strModuleName = 'Store' AND intParentMenuID = @StoreParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Subcategories', N'Store', @StoreParentMenuId, N'Subcategories', N'Maintenance', N'Screen', N'Store.view.SubCategory', N'small-menu-maintenance', 0, 0, 0, 1, 9, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 9, strCommand = N'Store.view.SubCategory' WHERE strMenuName = 'Subcategories' AND strModuleName = 'Store' AND intParentMenuID = @StoreParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Retail Price Adjustments' AND strModuleName = 'Store' AND intParentMenuID = @StoreParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Retail Price Adjustments', N'Store', @StoreParentMenuId, N'Retail Price Adjustments', N'Maintenance', N'Screen', N'Store.view.RetailPriceAdjustment', N'small-menu-maintenance', 0, 0, 0, 1, 10, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 10, strCommand = N'Store.view.RetailPriceAdjustment' WHERE strMenuName = 'Retail Price Adjustments' AND strModuleName = 'Store' AND intParentMenuID = @StoreParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Promotions' AND strModuleName = 'Store' AND intParentMenuID = @StoreParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Promotions', N'Store', @StoreParentMenuId, N'Promotions', N'Maintenance', N'Screen', N'Store.view.Promotions', N'small-menu-maintenance', 0, 0, 0, 1, 11, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 11, strCommand = N'Store.view.Promotions' WHERE strMenuName = 'Promotions' AND strModuleName = 'Store' AND intParentMenuID = @StoreParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Generate Vendor Rebate File' AND strModuleName = 'Store' AND intParentMenuID = @StoreParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Generate Vendor Rebate File', N'Store', @StoreParentMenuId, N'Generate Vendor Rebate File', N'Maintenance', N'Screen', N'Store.view.GenerateVendorRebateFile', N'small-menu-maintenance', 0, 0, 0, 1, 12, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 12, strCommand = N'Store.view.GenerateVendorRebateFile' WHERE strMenuName = 'Generate Vendor Rebate File' AND strModuleName = 'Store' AND intParentMenuID = @StoreParentMenuId

/* START DELETE */
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Promotion Sales' AND strModuleName = 'Store' AND intParentMenuID = @StoreParentMenuId)
   DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Promotion Sales ' AND strModuleName = 'Store' AND intParentMenuID = @StoreParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Promotion Item List' AND strModuleName = 'Store' AND intParentMenuID = @StoreParentMenuId)
   DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Promotion Item List' AND strModuleName = 'Store' AND intParentMenuID = @StoreParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Copy Promotions' AND strModuleName = 'Store' AND intParentMenuID = @StoreParentMenuId)
   DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Copy Promotions' AND strModuleName = 'Store' AND intParentMenuID = @StoreParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Purge Promotions' AND strModuleName = 'Store' AND intParentMenuID = @StoreParentMenuId)
   DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Purge Promotions' AND strModuleName = 'Store' AND intParentMenuID = @StoreParentMenuId

/* STOP DELETE */

/* RISK MANAGEMENT */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Risk Management' AND strModuleName = 'Risk Management' AND intParentMenuID = 0)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Risk Management', N'Risk Management', 0, N'Risk Management', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 14, 2)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 14 WHERE strMenuName = 'Risk Management' AND strModuleName = 'Risk Management' AND intParentMenuID = 0

DECLARE @RiskManagementParentMenuId INT
SELECT @RiskManagementParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Risk Management' AND strModuleName = 'Risk Management' AND intParentMenuID = 0

/* START OF PLURALIZING */
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Match Futures Purchase & Sale' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Match Futures Purchase & Sales', strDescription = 'Match Futures Purchase & Sales' WHERE strMenuName = 'Match Futures Purchase & Sale' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Futures Market' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Futures Markets', strDescription = 'Futures Markets' WHERE strMenuName = 'Futures Market' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Brokerage Account' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Brokerage Accounts', strDescription = 'Brokerage Accounts' WHERE strMenuName = 'Brokerage Account' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementParentMenuId
/* END OF PLURALIZING */

/* START OF RENAMING  */
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Futures Settlement Price' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Futures/Options Settlement Prices', strDescription = 'Futures/Options Settlement Prices' WHERE strMenuName = 'Futures Settlement Price' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Fut/Opt Transaction' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Futures Options Transactions', strDescription = 'Futures Options Transactions' WHERE strMenuName = 'Fut/Opt Transaction' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Futures Month' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Futures Trading Months', strDescription = 'Futures Trading Months' WHERE strMenuName = 'Futures Month' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Options Month' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Options Trading Months', strDescription = 'Options Trading Months' WHERE strMenuName = 'Options Month' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Daily Position Report' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Live DPR', strDescription = 'Live DPR' WHERE strMenuName = 'Daily Position Report' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Live DPR' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Position Report', strDescription = 'Position Report' WHERE strMenuName = 'Live DPR' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Coverage Report' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = N'Coverage/Risk Inquiry', strDescription = N'Coverage/Risk Inquiry' WHERE strMenuName = 'Coverage Report' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementParentMenuId

/* END OF RENAMING  */

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Position Report' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Position Report', N'Risk Management', @RiskManagementParentMenuId, N'Position Report', N'Activity', N'Screen', N'RiskManagement.view.LiveDPR', N'small-menu-activity', 0, 0, 0, 1, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 0, strCommand = N'RiskManagement.view.LiveDPR' WHERE strMenuName = 'Position Report' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Collateral' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Collateral', N'Risk Management', @RiskManagementParentMenuId, N'Collateral', N'Activity', N'Screen', N'RiskManagement.view.Collateral', N'small-menu-activity', 0, 0, 0, 1, 2, 1)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 2, strCommand = N'RiskManagement.view.Collateral' WHERE strMenuName = 'Collateral' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Coverage/Risk Inquiry' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Coverage/Risk Inquiry', N'Risk Management', @RiskManagementParentMenuId, N'Coverage/Risk Inquiry', N'Activity', N'Screen', N'RiskManagement.view.RiskPositionInquiry', N'small-menu-activity', 0, 0, 0, 1, 3, 1)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 3, strCommand = N'RiskManagement.view.RiskPositionInquiry' WHERE strMenuName = 'Coverage/Risk Inquiry' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'M2M Configuration' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'M2M Configuration', N'Risk Management', @RiskManagementParentMenuId, N'M2M Configuration', N'Activity', N'Screen', N'RiskManagement.view.MToMConfiguration', N'small-menu-activity', 0, 0, 0, 1, 4, 1)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 4, strCommand = N'RiskManagement.view.MToMConfiguration' WHERE strMenuName = 'M2M Configuration' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Customer Position Inquiry' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Customer Position Inquiry', N'Risk Management', @RiskManagementParentMenuId, N'Customer Position Inquiry', N'Activity', N'Screen', N'RiskManagement.view.CustomerPositionInquiry', N'small-menu-activity', 0, 0, 0, 1, 5, 1)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 5, strCommand = N'RiskManagement.view.CustomerPositionInquiry' WHERE strMenuName = 'Customer Position Inquiry' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Position by Period Selection' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Position by Period Selection', N'Risk Management', @RiskManagementParentMenuId, N'Position by Period Selection', N'Activity', N'Screen', N'RiskManagement.view.PositionByPeriodSelection', N'small-menu-activity', 0, 0, 0, 1, 6, 1)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 6, strCommand = N'RiskManagement.view.PositionByPeriodSelection' WHERE strMenuName = 'Position by Period Selection' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Daily Position Inquiry' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Daily Position Inquiry', N'Risk Management', @RiskManagementParentMenuId, N'Daily Position Inquiry', N'Activity', N'Screen', N'RiskManagement.view.DailyPositionDetail', N'small-menu-activity', 0, 0, 0, 1, 7, 1)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 7, strCommand = N'RiskManagement.view.DailyPositionDetail' WHERE strMenuName = 'Daily Position Inquiry' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Reconciliation Broker Statement' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Reconciliation Broker Statement', N'Risk Management', @RiskManagementParentMenuId, N'Reconciliation Broker Statement', N'Activity', N'Screen', N'RiskManagement.view.ReconciliationBrokerStatement', N'small-menu-activity', 0, 0, 0, 1, 8, 1)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 8, strCommand = N'RiskManagement.view.ReconciliationBrokerStatement' WHERE strMenuName = 'Reconciliation Broker Statement' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Risk Rating Matrix' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Risk Rating Matrix', N'Risk Management', @RiskManagementParentMenuId, N'Risk Rating Matrix', N'Activity', N'Screen', N'RiskManagement.view.VendorPriceFixationLimit', N'small-menu-activity', 0, 0, 0, 1, 9, 1)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 9, strCommand = N'RiskManagement.view.VendorPriceFixationLimit' WHERE strMenuName = 'Risk Rating Matrix' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Sourcing Report' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Sourcing Report', N'Risk Management', @RiskManagementParentMenuId, N'Sourcing Report', N'Activity', N'Screen', N'RiskManagement.view.SourcingReport', N'small-menu-activity', 0, 0, 0, 1, 10, 1)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 10, strCommand = N'RiskManagement.view.SourcingReport' WHERE strMenuName = 'Sourcing Report' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Derivative Screen' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Derivative Screen', N'Risk Management', @RiskManagementParentMenuId, N'Derivative Screen', N'Activity', N'Screen', N'RiskManagement.view.DerivativeScreen', N'small-menu-activity', 0, 0, 0, 1, 11, 1)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 11, strCommand = N'RiskManagement.view.SourciDerivativeScreenngReport' WHERE strMenuName = 'Derivative Screen' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Futures Markets' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Futures Markets', N'Risk Management', @RiskManagementParentMenuId, N'Futures Markets', N'Maintenance', N'Screen', N'RiskManagement.view.FuturesMarket', N'small-menu-maintenance', 0, 0, 0, 1, 12, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 12, strCommand = N'RiskManagement.view.FuturesMarket' WHERE strMenuName = 'Futures Markets' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Futures Trading Months' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Futures Trading Months', N'Risk Management', @RiskManagementParentMenuId, N'Futures Trading Months', N'Maintenance', N'Screen', N'RiskManagement.view.FuturesMonth', N'small-menu-maintenance', 0, 0, 0, 1, 13, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 13, strCommand = N'RiskManagement.view.FuturesMonth' WHERE strMenuName = 'Futures Trading Months' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Options Trading Months' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Options Trading Months', N'Risk Management', @RiskManagementParentMenuId, N'Options Trading Months', N'Maintenance', N'Screen', N'RiskManagement.view.OptionsMonth', N'small-menu-maintenance', 0, 0, 0, 1, 14, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 14, strCommand = N'RiskManagement.view.OptionsMonth' WHERE strMenuName = 'Options Trading Months' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Brokerage Accounts' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Brokerage Accounts', N'Risk Management', @RiskManagementParentMenuId, N'Brokerage Accounts', N'Maintenance', N'Screen', N'RiskManagement.view.BrokerageAccount', N'small-menu-maintenance', 0, 0, 0, 1, 15, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 15, strCommand = N'RiskManagement.view.BrokerageAccount' WHERE strMenuName = 'Brokerage Accounts' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Futures Broker' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId])
	VALUES (N'Futures Broker', N'Risk Management', @RiskManagementParentMenuId, N'Futures Broker', N'Maintenance', N'Screen', N'EntityManagement.view.Entity?showSearch=true&searchCommand=searchEntityFuturesBroker', N'small-menu-maintenance', 0, 0, 0, 1, 24, 1)
ELSE	
	UPDATE tblSMMasterMenu SET intSort = 16, strCommand = N'EntityManagement.view.Entity?showSearch=true&searchCommand=searchEntityFuturesBroker' WHERE strMenuName = 'Futures Broker' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Market Exchange' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId])
	VALUES (N'Market Exchange', N'Risk Management', @RiskManagementParentMenuId, N'Market Exchange', N'Maintenance', N'Screen', N'RiskManagement.view.MarketExchange', N'small-menu-maintenance', 0, 0, 0, 1, 17, 1)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 17, strCommand = N'RiskManagement.view.MarketExchange' WHERE strMenuName = 'Market Exchange' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Futures Price' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId])
	VALUES (N'Futures Price', N'Risk Management', @RiskManagementParentMenuId, N'Futures Price', N'Maintenance', N'Screen', N'RiskManagement.view.RollCost', N'small-menu-maintenance', 0, 0, 0, 1, 18, 1)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 18, strCommand = N'RiskManagement.view.RollCost' WHERE strMenuName = 'Futures Price' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementParentMenuId

/* START OF DELETE */
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Futures/Options Settlement Prices' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementParentMenuId)
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Futures/Options Settlement Prices' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Futures Options Transactions' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementParentMenuId)
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Futures Options Transactions' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Match Futures Purchase & Sales' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementParentMenuId)
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Match Futures Purchase & Sales' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Option Lifecycle' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementParentMenuId)
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Option Lifecycle' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Futures360' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementParentMenuId)
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Futures360' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementParentMenuId
	
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'M2M Entry' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementParentMenuId)
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'M2M Entry' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'M2M Inquiry' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementParentMenuId)
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'M2M Inquiry' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Assign Futures To Contracts' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementParentMenuId)
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Assign Futures To Contracts' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Currency Contract' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementParentMenuId)
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Currency Contract' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementParentMenuId

/* LOGISTICS */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Logistics' AND strModuleName = 'Logistics' AND intParentMenuID = 0)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Logistics', N'Logistics', 0, N'Logistics', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 16, 2)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 16 WHERE strMenuName = 'Logistics' AND strModuleName = 'Logistics' AND intParentMenuID = 0

DECLARE @LogisticsParentMenuId INT
SELECT @LogisticsParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Logistics' AND strModuleName = 'Logistics' AND intParentMenuID = 0

/* START OF PLURALIZING */
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Load Schedule' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Load Schedules', strDescription = 'Load Schedules' WHERE strMenuName = 'Load Schedule' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Container Type' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Container Types', strDescription = 'Container Types' WHERE strMenuName = 'Container Type' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Shipping Line' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Shipping Lines', strDescription = 'Shipping Lines' WHERE strMenuName = 'Shipping Line' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Forwarding Agent' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Forwarding Agents', strDescription = 'Forwarding Agents' WHERE strMenuName = 'Forwarding Agent' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Trucker' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Truckers', strDescription = 'Truckers' WHERE strMenuName = 'Trucker' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Terminal' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Terminals', strDescription = 'Terminals' WHERE strMenuName = 'Terminal' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsParentMenuId
/* END OF PLURALIZING */

/* START OF RENAMING  */
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Dispatch Loads' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Mass Dispatch Loads' WHERE strMenuName = 'Dispatch Loads' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Load Schedules' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Load / Shipment Schedules', strDescription = 'Load / Shipment Schedules' WHERE strMenuName = 'Load Schedules' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsParentMenuId
/* END OF RENAMING  */

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Allocations' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Allocations', N'Logistics', @LogisticsParentMenuId, N'Allocations', N'Activity', N'Screen', N'Logistics.view.Allocation', N'small-menu-activity', 0, 0, 0, 1, 1, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 1, strCommand = N'Logistics.view.Allocation' WHERE strMenuName = 'Allocations' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Load / Shipment Schedules' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Load / Shipment Schedules', N'Logistics', @LogisticsParentMenuId, N'Load / Shipment Schedules', N'Activity', N'Screen', N'Logistics.view.ShipmentSchedule', N'small-menu-activity', 0, 0, 0, 1, 2, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 2, strCommand = N'Logistics.view.ShipmentSchedule' WHERE strMenuName = 'Load / Shipment Schedules' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Pick Lots' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Pick Lots', N'Logistics', @LogisticsParentMenuId, N'Pick Lots', N'Activity', N'Screen', N'Logistics.view.PickLot', N'small-menu-activity', 0, 0, 0, 1, 3, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 3, strCommand = N'Logistics.view.PickLot' WHERE strMenuName = 'Pick Lots' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Stock Sales' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Stock Sales', N'Logistics', @LogisticsParentMenuId, N'Stock Sales', N'Activity', N'Screen', N'Logistics.view.StockSales', N'small-menu-activity', 0, 0, 0, 1, 4, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 4, strCommand = N'Logistics.view.StockSales' WHERE strMenuName = 'Stock Sales' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Least Cost Routing' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Least Cost Routing', N'Logistics', @LogisticsParentMenuId, N'Least Cost Routing', N'Activity', N'Screen', N'Logistics.view.LeastCostRouting', N'small-menu-activity', 0, 0, 0, 1, 4, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 4, strCommand = N'Logistics.view.LeastCostRouting' WHERE strMenuName = 'Least Cost Routing' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Weight Claims' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Weight Claims', N'Logistics', @LogisticsParentMenuId, N'Weight Claims', N'Activity', N'Screen', N'Logistics.view.WeightClaims', N'small-menu-activity', 0, 0, 0, 1, 4, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 4, strCommand = N'Logistics.view.WeightClaims' WHERE strMenuName = 'Weight Claims' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Container Types' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Container Types', N'Logistics', @LogisticsParentMenuId, N'Container Types', N'Maintenance', N'Screen', N'Logistics.view.ContainerType', N'small-menu-maintenance', 0, 0, 0, 1, 5, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 5, strCommand = N'Logistics.view.ContainerType' WHERE strMenuName = 'Container Types' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Equipment Type' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Equipment Type', N'Logistics', @LogisticsParentMenuId, N'Equipment Type', N'Maintenance', N'Screen', N'Logistics.view.EquipmentType', N'small-menu-maintenance', 0, 0, 0, 1, 6, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 6, strCommand = N'Logistics.view.EquipmentType' WHERE strMenuName = 'Equipment Type' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Shipping Lines' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Shipping Lines', N'Logistics', @LogisticsParentMenuId, N'Shipping Lines', N'Maintenance', N'Screen', N'EntityManagement.view.Entity?showSearch=true&searchCommand=searchEntityShippingLine', N'small-menu-maintenance', 0, 0, 0, 1, 7, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 7, strCommand = N'EntityManagement.view.Entity?showSearch=true&searchCommand=searchEntityShippingLine' WHERE strMenuName = 'Shipping Lines' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Forwarding Agents' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Forwarding Agents', N'Logistics', @LogisticsParentMenuId, N'Forwarding Agents', N'Maintenance', N'Screen', N'EntityManagement.view.Entity?showSearch=true&searchCommand=searchEntityForwardingAgent', N'small-menu-maintenance', 0, 0, 0, 1, 8, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 8, strCommand = N'EntityManagement.view.Entity?showSearch=true&searchCommand=searchEntityForwardingAgent' WHERE strMenuName = 'Forwarding Agents' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Terminals' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Terminals', N'Logistics', @LogisticsParentMenuId, N'Terminals', N'Maintenance', N'Screen', N'EntityManagement.view.Entity?showSearch=true&searchCommand=searchEntityTerminal', N'small-menu-maintenance', 0, 0, 0, 1, 9, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 9, strCommand = N'EntityManagement.view.Entity?showSearch=true&searchCommand=searchEntityTerminal' WHERE strMenuName = 'Terminals' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Warehouse Rate Matrix' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Warehouse Rate Matrix', N'Logistics', @LogisticsParentMenuId, N'Warehouse Rate Matrix', N'Maintenance', N'Screen', N'Logistics.view.WarehouseRateMatrix', N'small-menu-maintenance', 0, 0, 0, 1, 10, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 10, strCommand = N'Logistics.view.WarehouseRateMatrix' WHERE strMenuName = 'Warehouse Rate Matrix' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Insurer' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Insurer', N'Logistics', @LogisticsParentMenuId, N'Insurer', N'Maintenance', N'Screen', N'EntityManagement.view.Entity?showSearch=true&searchCommand=searchEntityInsurer', N'small-menu-maintenance', 0, 0, 0, 1, 11, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 11, strCommand = N'EntityManagement.view.Entity?showSearch=true&searchCommand=searchEntityInsurer' WHERE strMenuName = 'Insurer' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Shipping Mode' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Shipping Mode', N'Logistics', @LogisticsParentMenuId, N'Shipping Mode', N'Maintenance', N'Screen', N'Logistics.view.ShippingMode', N'small-menu-maintenance', 0, 0, 0, 1, 12, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 12, strCommand = N'Logistics.view.ShippingMode' WHERE strMenuName = 'Shipping Mode' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Reason Code' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Reason Code', N'Logistics', @LogisticsParentMenuId, N'Reason Code', N'Maintenance', N'Screen', N'Logistics.view.ReasonCode', N'small-menu-maintenance', 0, 0, 0, 1, 13, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 13, strCommand = N'Logistics.view.ReasonCode' WHERE strMenuName = 'Reason Code' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsParentMenuId

/* START OF DELETING */
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Allocated Contracts List' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Unallocated Contracts List' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Shipments List' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Generate Loads' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Delivery Orders' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Mass Dispatch Loads' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsParentMenuId
--DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Weight Claims' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Shipping Instructions' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Inbound Shipments' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Truckers' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsParentMenuId
/* END OF DELETING */

/* CARD FUELING */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Card Fueling' AND strModuleName = 'Card Fueling' AND intParentMenuID = 0)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Card Fueling', N'Card Fueling', 0, N'Card Fueling', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 19, 1)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 19 WHERE strMenuName = 'Card Fueling' AND strModuleName = 'Card Fueling' AND intParentMenuID = 0

DECLARE @CardFuelingParentMenuId INT
SELECT @CardFuelingParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Card Fueling' AND strModuleName = 'Card Fueling' AND intParentMenuID = 0

/* START OF PLURALIZING */
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Index Pricing By Site Group' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Index Pricing by Site Groups', strDescription = 'Index Pricing by Site Groups' WHERE strMenuName = 'Index Pricing By Site Group' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Discount Schedule' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Discount Schedules', strDescription = 'Discount Schedules' WHERE strMenuName = 'Discount Schedule' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Fee Profile' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Fee Profiles', strDescription = 'Fee Profiles' WHERE strMenuName = 'Fee Profile' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Network' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Networks', strDescription = 'Networks' WHERE strMenuName = 'Network' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Price Profile' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Price Profiles', strDescription = 'Price Profiles' WHERE strMenuName = 'Price Profile' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Card Type' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Card Types', strDescription = 'Card Types' WHERE strMenuName = 'Card Type' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Fee' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Fees', strDescription = 'Fees' WHERE strMenuName = 'Fee' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName LIKE 'Invoice Cycle%' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Invoice Cycles', strDescription = 'Invoice Cycles' WHERE strMenuName LIKE 'Invoice Cycle%' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName LIKE 'Price Index%' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Price Indexes', strDescription = 'Price Indexes' WHERE strMenuName LIKE 'Price Index%' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName LIKE 'Price Rule Group%' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Price Rule Groups', strDescription = 'Price Rule Groups' WHERE strMenuName LIKE 'Price Rule Group%' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName LIKE 'Site Group%' AND strMenuName NOT LIKE 'Site Group Price Adjustment%' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Site Groups', strDescription = 'Site Groups' WHERE strMenuName LIKE 'Site Group%' AND strMenuName NOT LIKE 'Site Group Price Adjustment%' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName LIKE 'Site Group Price Adjustment%' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Site Group Price Adjustments', strDescription = 'Site Group Price Adjustments' WHERE strMenuName LIKE 'Site Group Price Adjustment%' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingParentMenuId
/* END OF PLURALIZING */

/* START OF RENAMING  */
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Accounts' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Card Accounts', strDescription = 'Card Accounts' WHERE strMenuName = 'Accounts' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Site Group Price Adjustments' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Remote Price Adjustments', strDescription = 'Remote Price Adjustments' WHERE strMenuName = 'Site Group Price Adjustments' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingParentMenuId
/* END OF RENAMING  */

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Transaction' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Transaction', N'Card Fueling', @CardFuelingParentMenuId, N'Transaction', N'Activity', N'Screen', N'CardFueling.view.Transaction', N'small-menu-activity', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'CardFueling.view.Transaction', intSort = 0 WHERE strMenuName = 'Transaction' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Index Pricing By Site Groups' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Index Pricing By Site Groups', N'Card Fueling', @CardFuelingParentMenuId, N'Index Pricing By Site Groups', N'Activity', N'Screen', N'CardFueling.view.IndexPricingBySiteGroup', N'small-menu-activity', 0, 0, 0, 1, 1, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'CardFueling.view.IndexPricingBySiteGroup', intSort = 1 WHERE strMenuName = 'Index Pricing By Site Groups' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Card Accounts' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Card Accounts', N'Card Fueling', @CardFuelingParentMenuId, N'Card Accounts', N'Maintenance', N'Screen', N'CardFueling.view.Account', N'small-menu-maintenance', 0, 0, 0, 1, 2, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'CardFueling.view.Account', intSort = 2 WHERE strMenuName = 'Card Accounts' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Remote Price Adjustments' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Remote Price Adjustments', N'Card Fueling', @CardFuelingParentMenuId, N'Remote Price Adjustments', N'Maintenance', N'Screen', N'CardFueling.view.SiteGroupPriceAdjustment', N'small-menu-maintenance', 0, 0, 0, 1, 3, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = N'CardFueling.view.SiteGroupPriceAdjustment', intSort = 3 WHERE strMenuName = 'Remote Price Adjustments' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Invoice' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Invoice', N'Card Fueling', @CardFuelingParentMenuId, N'Invoice', N'Maintenance', N'Screen', N'CardFueling.view.Invoice', N'small-menu-maintenance', 0, 0, 0, 1, 4, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = N'CardFueling.view.Invoice', intSort = 4 WHERE strMenuName = 'Invoice' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Setup' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Setup', N'Card Fueling', @CardFuelingParentMenuId, N'Setup', N'Maintenance', N'Screen', N'CardFueling.view.Maintenance', N'small-menu-maintenance', 0, 0, 0, 1, 5, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = N'CardFueling.view.Maintenance', intSort = 5 WHERE strMenuName = 'Setup' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingParentMenuId

/* START OF DELETION */
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Batch Posting' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Discount Schedules' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Fee Profiles' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Fees' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Networks' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Price Profiles' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Card Types' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Invoice Cycles' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Sites' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Price Indexes' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Price Rule Groups' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Site Groups' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingParentMenuId
/* END OF DELETION */

/* CREDIT CARD RECONCILIATION */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Credit Card Reconciliation' AND strModuleName = 'Credit Card Recon' AND intParentMenuID = 0)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Credit Card Reconciliation', N'Credit Card Recon', 0, N'Credit Card Reconciliation', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 7, 0)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 7 WHERE strMenuName = 'Credit Card Reconciliation' AND strModuleName = 'Credit Card Recon' AND intParentMenuID = 0

DECLARE @CreditCardReconParentMenuId INT
SELECT @CreditCardReconParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Credit Card Reconciliation' AND strModuleName = 'Credit Card Recon' AND intParentMenuID = 0

/* Rename from Credit Card Reconciliation Entry to Credit Card Reconciliation */
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE (strMenuName = 'Credit Card Reconciliation Entry' OR strMenuName = 'Credit Card Reconciliations') AND strModuleName = 'Credit Card Recon' AND intParentMenuID = @CreditCardReconParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Dealer Credit Cards', strDescription = 'Dealer Credit Cards' WHERE (strMenuName = 'Credit Card Reconciliation Entry' OR strMenuName = 'Credit Card Reconciliations') AND strModuleName = 'Credit Card Recon' AND intParentMenuID = @CreditCardReconParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Dealer Credit Cards' AND strModuleName = 'Credit Card Recon' AND intParentMenuID = @CreditCardReconParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Dealer Credit Cards', N'Credit Card Recon', @CreditCardReconParentMenuId, N'Dealer Credit Cards', N'Activity', N'Screen', N'CreditCardRecon.view.CreditCardReconciliation', N'small-menu-activity', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'CreditCardRecon.view.CreditCardReconciliation' WHERE strMenuName = 'Dealer Credit Cards' AND strModuleName = 'Credit Card Recon' AND intParentMenuID = @CreditCardReconParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Import File Mapper' AND strModuleName = 'Credit Card Recon' AND intParentMenuID = @CreditCardReconParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'File Field Mapping', strDescription = 'File Field Mapping', strCommand = 'CreditCardRecon.view.FileFieldMapping' WHERE strMenuName = 'Import File Mapper' AND strModuleName = 'Credit Card Recon' AND intParentMenuID = @CreditCardReconParentMenuId

--IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'File Field Mapping' AND strModuleName = 'Credit Card Recon' AND intParentMenuID = @CreditCardReconParentMenuId)
--	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
--	VALUES (N'File Field Mapping', N'Credit Card Recon', @CreditCardReconParentMenuId, N'File Field Mapping', N'Maintenance', N'Screen', N'CreditCardRecon.view.FileFieldMapping', N'small-menu-maintenance', 0, 0, 0, 1, 0, 1)
--ELSE 
--	UPDATE tblSMMasterMenu SET strCategory = 'Maintenance', strCommand = N'CreditCardRecon.view.FileFieldMapping' WHERE strMenuName = 'File Field Mapping' AND strModuleName = 'Credit Card Recon' AND intParentMenuID = @CreditCardReconParentMenuId

DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Import Transaction' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'File Field Mapping' AND strModuleName = 'Credit Card Recon' AND intParentMenuID = @CreditCardReconParentMenuId

UPDATE tblSMMasterMenu
SET strCommand = 'EntityManagement.view.CustomerGroup'
WHERE strMenuName = 'Customer Groups' AND strModuleName = 'Accounts Receivable' AND strCommand = 'AccountsReceivable.view.CustomerGroup'

/* PATCH UPDATE */
--IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Patch Update' AND strModuleName = 'Patch Update' AND intParentMenuID = 0)
--INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
--VALUES (N'Patch Update', N'Patch Update', 0, N'Patch Update', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 23, 0)

--DECLARE @PatchUpdateParentMenuId INT
--SELECT @PatchUpdateParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Patch Update' AND strModuleName = 'Patch Update' AND intParentMenuID = 0

--IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Patch' AND strModuleName = 'Patch Update' AND intParentMenuID = @PatchUpdateParentMenuId)
--INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
--VALUES (N'Patch', N'Patch Update', @PatchUpdateParentMenuId, N'Patch', N'Maintenance', N'Screen', N'PatchUpdate.view.Patch', N'small-menu-maintenance', 0, 0, 0, 1, 0, 1)

/*
	start of rename
	From Patch Update to Service Pack
*/
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Patch Update' AND strModuleName = 'Patch Update' AND intParentMenuID = 0)
BEGIN
	DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Patch Update' AND strModuleName = 'Patch Update' AND intParentMenuID = 0
END

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Patch' AND strModuleName = 'Patch Update') --AND intParentMenuID = @PatchUpdateParentMenuId)
BEGIN
	DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Patch' AND strModuleName = 'Patch Update' --AND intParentMenuID = @PatchUpdateParentMenuId
END

--IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Service Pack' AND strModuleName = 'Service Pack' AND intParentMenuID = 0)
--INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
--VALUES (N'Service Pack', N'Service Pack', 0, N'Service Pack', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 23, 0)

--DECLARE @ServicePackParentMenuId INT
--SELECT @ServicePackParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Service Pack' AND strModuleName = 'Service Pack' AND intParentMenuID = 0

--IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Patch' AND strModuleName = 'Service Pack' AND intParentMenuID = @ServicePackParentMenuId)
--INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
--VALUES (N'Patch', N'Service Pack', @ServicePackParentMenuId, N'Patch', N'Maintenance', N'Screen', N'ServicePack.view.Patch', N'small-menu-maintenance', 0, 0, 0, 1, 0, 1)

/*end of rename*/

/* Delete */
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Service Pack' AND strModuleName = 'Service Pack' AND intParentMenuID = 0)
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Service Pack' AND strModuleName = 'Service Pack' AND intParentMenuID = 0

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Patch' AND strModuleName = 'Service Pack')
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Patch' AND strModuleName = 'Service Pack'

/* DOCUMENT MANAGEMENT */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Document Management' AND strModuleName = 'Document Management' AND intParentMenuID = 0)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Document Management', N'Document Management', 0, N'Document Management', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 23, 0)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 23 WHERE strMenuName = 'Document Management' AND strModuleName = 'Document Management' AND intParentMenuID = 0

DECLARE @DocumentManagementParentMenuId INT
SELECT @DocumentManagementParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Document Management' AND strModuleName = 'Document Management' AND intParentMenuID = 0

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Document Manager' AND strModuleName = 'System Manager' AND intParentMenuID = @DocumentManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Document Manager', N'System Manager', @DocumentManagementParentMenuId, N'Document Manager', N'Maintenance', N'Screen', N'GlobalComponentEngine.view.DocumentManager', N'small-menu-maintenance', 0, 0, 0, 1, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = N'GlobalComponentEngine.view.DocumentManager', intSort = 0 WHERE strMenuName = 'Document Manager' AND strModuleName = 'System Manager' AND intParentMenuID = @DocumentManagementParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Add Documents' AND strModuleName = 'System Manager' AND intParentMenuID = @DocumentManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Add Documents', N'System Manager', @DocumentManagementParentMenuId, N'Add Documents', N'Maintenance', N'Screen', N'GlobalComponentEngine.view.DocumentPending?activeTab=Add', N'small-menu-maintenance', 0, 0, 0, 1, 1, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = N'GlobalComponentEngine.view.DocumentPending?activeTab=Add', intSort = 1 WHERE strMenuName = 'Add Documents' AND strModuleName = 'System Manager' AND intParentMenuID = @DocumentManagementParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Pending Documents' AND strModuleName = 'System Manager' AND intParentMenuID = @DocumentManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Pending Documents', N'System Manager', @DocumentManagementParentMenuId, N'Pending Documents', N'Maintenance', N'Screen', N'GlobalComponentEngine.view.DocumentPending?activeTab=Pending', N'small-menu-maintenance', 0, 0, 0, 1, 2, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = N'GlobalComponentEngine.view.DocumentPending?activeTab=Pending', intSort = 2 WHERE strMenuName = 'Pending Documents' AND strModuleName = 'System Manager' AND intParentMenuID = @DocumentManagementParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Document Source' AND strModuleName = 'System Manager' AND intParentMenuID = @DocumentManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Document Source', N'System Manager', @DocumentManagementParentMenuId, N'Document Source', N'Maintenance', N'Screen', N'GlobalComponentEngine.view.DocumentSource', N'small-menu-maintenance', 0, 0, 0, 1, 3, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = N'GlobalComponentEngine.view.DocumentSource', intSort = 3 WHERE strMenuName = 'Document Source' AND strModuleName = 'System Manager' AND intParentMenuID = @DocumentManagementParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Document Type' AND strModuleName = 'System Manager' AND intParentMenuID = @DocumentManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Document Type', N'System Manager', @DocumentManagementParentMenuId, N'Document Type', N'Maintenance', N'Screen', N'GlobalComponentEngine.view.DocumentType', N'small-menu-maintenance', 0, 0, 0, 1, 4, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = N'GlobalComponentEngine.view.DocumentType', intSort = 4 WHERE strMenuName = 'Document Type' AND strModuleName = 'System Manager' AND intParentMenuID = @DocumentManagementParentMenuId

/* TRANSPORTS */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Transports' AND strModuleName = 'Transports' AND intParentMenuID = 0)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Transports', N'Transports', 0, N'Transports', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 24, 0)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 24 WHERE strMenuName = 'Transports' AND strModuleName = 'Transports' AND intParentMenuID = 0

DECLARE @TransportsParentMenuId INT
SELECT @TransportsParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Transports' AND strModuleName = 'Transports' AND intParentMenuID = 0

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Transport Load' AND strModuleName = 'Transports' AND intParentMenuID = @TransportsParentMenuId)
   BEGIN
    IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Transport Loads' AND strModuleName = 'Transports' AND intParentMenuID = @TransportsParentMenuId)
	 BEGIN
	   INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	   VALUES (N'Transport Loads', N'Transports', @TransportsParentMenuId, N'Transport Loads', N'Activity', N'Screen', N'Transports.view.TransportLoads', N'small-menu-activity', 0, 0, 0, 1, 1, 1)
     END  
    ELSE
	   UPDATE tblSMMasterMenu SET strCommand = N'Transports.view.TransportLoads', intSort = 1 WHERE strMenuName = 'Transport Loads' AND strModuleName = 'Transports' AND intParentMenuID = @TransportsParentMenuId
   END
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Transports.view.TransportLoads',strMenuName = 'Transport Loads', intSort = 1 WHERE strMenuName = 'Transport Load' AND strModuleName = 'Transports' AND intParentMenuID = @TransportsParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Quote' AND strModuleName = 'Transports' AND intParentMenuID = @TransportsParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Quote', N'Transports', @TransportsParentMenuId, N'Quote', N'Activity', N'Screen', N'Transports.view.Quote', N'small-menu-activity', 0, 0, 0, 1, 2, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Transports.view.Quote', intSort = 2 WHERE strMenuName = 'Quote' AND strModuleName = 'Transports' AND intParentMenuID = @TransportsParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Rack Price' AND strModuleName = 'Transports' AND intParentMenuID = @TransportsParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Rack Price', N'Transports', @TransportsParentMenuId, N'Rack Price', N'Activity', N'Screen', N'Transports.view.RackPrice', N'small-menu-activity', 0, 0, 0, 1, 3, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Transports.view.RackPrice', intSort = 3 WHERE strMenuName = 'Rack Price' AND strModuleName = 'Transports' AND intParentMenuID = @TransportsParentMenuId

DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Supply Point' AND strModuleName = 'Transports'

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Quote Price Adjustment' AND strModuleName = 'Transports' AND intParentMenuID = @TransportsParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Quote Price Adjustment', N'Transports', @TransportsParentMenuId, N'Quote Price Adjustment', N'Maintenance', N'Screen', N'Transports.view.QuotePriceAdjustment', N'small-menu-maintenance', 0, 0, 0, 1, 5, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Transports.view.QuotePriceAdjustment', intSort = 5 WHERE strMenuName = 'Quote Price Adjustment' AND strModuleName = 'Transports' AND intParentMenuID = @TransportsParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Bulk Plant Freight' AND strModuleName = 'Transports' AND intParentMenuID = @TransportsParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Bulk Plant Freight', N'Transports', @TransportsParentMenuId, N'Bulk Plant Freight', N'Maintenance', N'Screen', N'Transports.view.BulkPlantFreight', N'small-menu-maintenance', 0, 0, 0, 1, 6, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Transports.view.BulkPlantFreight', intSort = 6 WHERE strMenuName = 'Bulk Plant Freight' AND strModuleName = 'Transports' AND intParentMenuID = @TransportsParentMenuId

/* Meter Billing */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Meter Billing' AND strModuleName = 'Meter Billing' AND intParentMenuID = 0)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Meter Billing', N'Meter Billing', 0, N'Meter Billing', NULL, N'Folder', N'', N'small-folder', 1, 1, 0, 0, 25, 0)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 25 WHERE strMenuName = 'Meter Billing' AND strModuleName = 'Meter Billing' AND intParentMenuID = 0

DECLARE @MeterBillingParentMenuId INT
SELECT @MeterBillingParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Meter Billing' AND strModuleName = 'Meter Billing' AND intParentMenuID = 0

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Meter Readings' AND strModuleName = 'Meter Billing' AND intParentMenuID = @MeterBillingParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Meter Readings', N'Meter Billing', @MeterBillingParentMenuId, N'Meter Readings', N'Activity', N'Screen', N'MeterBilling.view.MeterReadings', N'small-menu-activity', 1, 1, 0, 1, 1, 0)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'MeterBilling.view.MeterReadings', intSort = 1 WHERE strMenuName = 'Meter Readings' AND strModuleName = 'Meter Billing' AND intParentMenuID = @MeterBillingParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Batch Posting' AND strModuleName = 'Meter Billing' AND intParentMenuID = @MeterBillingParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Batch Posting', N'Meter Billing', @MeterBillingParentMenuId, N'Batch Posting', N'Activity', N'Screen', N'i21.view.BatchPosting?module=Meter Billing', N'small-menu-activity', 1, 1, 0, 1, 2, 0)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'i21.view.BatchPosting?module=Meter Billing', intSort = 2 WHERE strMenuName = 'Batch Posting' AND strModuleName = 'Meter Billing' AND intParentMenuID = @MeterBillingParentMenuId
	

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Consignment Rate' AND strModuleName = 'Meter Billing' AND intParentMenuID = @MeterBillingParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Consignment Rate', N'Meter Billing', @MeterBillingParentMenuId, N'Consignment Rate', N'Maintenance', N'Screen', N'MeterBilling.view.ConsignmentRate', N'small-menu-activity', 1, 1, 0, 1, 3, 0)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'MeterBilling.view.ConsignmentRate', intSort = 3 WHERE strMenuName = 'Consignment Rate' AND strModuleName = 'Meter Billing' AND intParentMenuID = @MeterBillingParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Fueling Point Price Change' AND strModuleName = 'Meter Billing' AND intParentMenuID = @MeterBillingParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Fueling Point Price Change', N'Meter Billing', @MeterBillingParentMenuId, N'Fueling Point Price Change', N'Maintenance', N'Screen', N'MeterBilling.view.FuelingPointPriceChange', N'small-menu-activity', 1, 1, 0, 1, 4, 0)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'MeterBilling.view.FuelingPointPriceChange', intSort = 4 WHERE strMenuName = 'Fueling Point Price Change' AND strModuleName = 'Meter Billing' AND intParentMenuID = @MeterBillingParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Fueling Point Reading' AND strModuleName = 'Meter Billing' AND intParentMenuID = @MeterBillingParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Fueling Point Reading', N'Meter Billing', @MeterBillingParentMenuId, N'Fueling Point Reading', N'Maintenance', N'Screen', N'MeterBilling.view.FuelingPointReading', N'small-menu-activity', 1, 1, 0, 1, 5, 0)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'MeterBilling.view.FuelingPointReading', intSort = 5 WHERE strMenuName = 'Fueling Point Reading' AND strModuleName = 'Meter Billing' AND intParentMenuID = @MeterBillingParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Meter Account' AND strModuleName = 'Meter Billing' AND intParentMenuID = @MeterBillingParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Meter Account', N'Meter Billing', @MeterBillingParentMenuId, N'Meter Account', N'Maintenance', N'Screen', N'MeterBilling.view.MeterAccount', N'small-menu-activity', 1, 1, 0, 1, 6, 0)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'MeterBilling.view.MeterAccount', intSort = 6 WHERE strMenuName = 'Meter Account' AND strModuleName = 'Meter Billing' AND intParentMenuID = @MeterBillingParentMenuId

/* END of Meter Billing */

/* QUALITY */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Quality' AND strModuleName = 'Quality' AND intParentMenuID = 0)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Quality', N'Quality', 0, N'Quality', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 26, 0)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 26 WHERE strMenuName = 'Quality' AND strModuleName = 'Quality' AND intParentMenuID = 0

DECLARE @QualityParentMenuId INT
SELECT @QualityParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Quality' AND strModuleName = 'Quality' AND intParentMenuID = 0

--IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Attribute' AND strModuleName = 'Quality' AND intParentMenuID = @QualityParentMenuId)
--	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
--	VALUES (N'Attribute', N'Quality', @QualityParentMenuId, N'Attribute', N'Activity', N'Screen', N'Quality.view.Attribute', N'small-menu-maintenance', 0, 0, 0, 1, 0, 1)
--ELSE 
--	UPDATE tblSMMasterMenu SET strCommand = N'Quality.view.Attribute' WHERE strMenuName = 'Attribute' AND strModuleName = 'Quality' AND intParentMenuID = @QualityParentMenuId

--IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Sample Type' AND strModuleName = 'Quality' AND intParentMenuID = @QualityParentMenuId)
--	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
--	VALUES (N'Sample Type', N'Quality', @QualityParentMenuId, N'Sample Type', N'Activity', N'Screen', N'Quality.view.SampleType', N'small-menu-maintenance', 0, 0, 0, 1, 0, 1)
--ELSE 
--	UPDATE tblSMMasterMenu SET strCommand = N'Quality.view.SampleType' WHERE strMenuName = 'Sample Type' AND strModuleName = 'Quality' AND intParentMenuID = @QualityParentMenuId

--IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'List' AND strModuleName = 'Quality' AND intParentMenuID = @QualityParentMenuId)
--	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
--	VALUES (N'List', N'Quality', @QualityParentMenuId, N'List', N'Activity', N'Screen', N'Quality.view.List', N'small-menu-maintenance', 0, 0, 0, 1, 0, 1)
--ELSE 
--	UPDATE tblSMMasterMenu SET strCommand = N'Quality.view.List' WHERE strMenuName = 'List' AND strModuleName = 'Quality' AND intParentMenuID = @QualityParentMenuId

--IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Property' AND strModuleName = 'Quality' AND intParentMenuID = @QualityParentMenuId)
--	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
--	VALUES (N'Property', N'Quality', @QualityParentMenuId, N'Property', N'Activity', N'Screen', N'Quality.view.Property', N'small-menu-maintenance', 0, 0, 0, 1, 0, 1)
--ELSE 
--	UPDATE tblSMMasterMenu SET strCommand = N'Quality.view.Property' WHERE strMenuName = 'Property' AND strModuleName = 'Quality' AND intParentMenuID = @QualityParentMenuId

--IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Test' AND strModuleName = 'Quality' AND intParentMenuID = @QualityParentMenuId)
--	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
--	VALUES (N'Test', N'Quality', @QualityParentMenuId, N'Test', N'Activity', N'Screen', N'Quality.view.Test', N'small-menu-maintenance', 0, 0, 0, 1, 0, 1)
--ELSE 
--	UPDATE tblSMMasterMenu SET strCommand = N'Quality.view.Test' WHERE strMenuName = 'Test' AND strModuleName = 'Quality' AND intParentMenuID = @QualityParentMenuId

--IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Quality Template' AND strModuleName = 'Quality' AND intParentMenuID = @QualityParentMenuId)
--	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
--	VALUES (N'Quality Template', N'Quality', @QualityParentMenuId, N'Quality Template', N'Activity', N'Screen', N'Quality.view.QualityTemplate', N'small-menu-maintenance', 0, 0, 0, 1, 0, 1)
--ELSE 
--	UPDATE tblSMMasterMenu SET strCommand = N'Quality.view.QualityTemplate' WHERE strMenuName = 'Quality Template' AND strModuleName = 'Quality' AND intParentMenuID = @QualityParentMenuId

--IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Quality Sample' AND strModuleName = 'Quality' AND intParentMenuID = @QualityParentMenuId)
--	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
--	VALUES (N'Quality Sample', N'Quality', @QualityParentMenuId, N'Quality Sample', N'Maintenance', N'Screen', N'Quality.view.QualitySample', N'small-menu-activity', 0, 0, 0, 1, 0, 1)
--ELSE 
--	UPDATE tblSMMasterMenu SET strCommand = N'Quality.view.QualitySample' WHERE strMenuName = 'Quality Sample' AND strModuleName = 'Quality' AND intParentMenuID = @QualityParentMenuId

--IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Contract Quality View' AND strModuleName = 'Quality' AND intParentMenuID = @QualityParentMenuId)
--	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
--	VALUES (N'Contract Quality View', N'Quality', @QualityParentMenuId, N'Contract Quality View', N'Activity', N'Screen', N'Quality.view.ContractQuality', N'small-menu-activity', 0, 0, 0, 1, 0, 1)
--ELSE 
--	UPDATE tblSMMasterMenu SET strCommand = N'Quality.view.ContractQuality' WHERE strMenuName = 'Contract Quality View' AND strModuleName = 'Quality' AND intParentMenuID = @QualityParentMenuId

--IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Lot Quality View' AND strModuleName = 'Quality' AND intParentMenuID = @QualityParentMenuId)
--	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
--	VALUES (N'Lot Quality View', N'Quality', @QualityParentMenuId, N'Lot Quality View', N'Activity', N'Screen', N'Quality.view.LotQuality', N'small-menu-activity', 0, 0, 0, 1, 0, 1)
--ELSE 
--	UPDATE tblSMMasterMenu SET strCommand = N'Quality.view.LotQuality' WHERE strMenuName = 'Lot Quality View' AND strModuleName = 'Quality' AND intParentMenuID = @QualityParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Quality View' AND strModuleName = 'Quality' AND intParentMenuID = @QualityParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Quality View', N'Quality', @QualityParentMenuId, N'Quality View', N'Activity', N'Screen', N'Quality.view.QualityException', N'small-menu-activity', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Quality.view.QualityException' WHERE strMenuName = 'Quality View' AND strModuleName = 'Quality' AND intParentMenuID = @QualityParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Quality Exception View' AND strModuleName = 'Quality' AND intParentMenuID = @QualityParentMenuId)
	DELETE tblSMMasterMenu WHERE strMenuName = 'Quality Exception View' AND strModuleName = 'Quality' AND intParentMenuID = @QualityParentMenuId

--IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Report Property' AND strModuleName = 'Quality' AND intParentMenuID = @QualityParentMenuId)
--	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
--	VALUES (N'Report Property', N'Quality', @QualityParentMenuId, N'Report Property', N'Activity', N'Screen', N'Quality.view.ReportProperty', N'small-menu-maintenance', 0, 0, 0, 1, 0, 1)
--ELSE 
--	UPDATE tblSMMasterMenu SET strCommand = N'Quality.view.ReportProperty' WHERE strMenuName = 'Report Property' AND strModuleName = 'Quality' AND intParentMenuID = @QualityParentMenuId

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

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Quality Parameters' AND strModuleName = 'Quality' AND intParentMenuID = @QualityParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Quality Parameters', N'Quality', @QualityParentMenuId, N'Quality Parameters', N'Activity', N'Screen', N'Quality.view.QualityParameters', N'small-menu-maintenance', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Quality.view.QualityParameters' WHERE strMenuName = 'Quality Parameters' AND strModuleName = 'Quality' AND intParentMenuID = @QualityParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Sample Entry' AND strModuleName = 'Quality' AND intParentMenuID = @QualityParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Sample Entry', N'Quality', @QualityParentMenuId, N'Sample Entry', N'Maintenance', N'Screen', N'Quality.view.QualitySample', N'small-menu-activity', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Quality.view.QualitySample' WHERE strMenuName = 'Sample Entry' AND strModuleName = 'Quality' AND intParentMenuID = @QualityParentMenuId


/* WAREHOUSE */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Warehouse' AND strModuleName = 'Warehouse' AND intParentMenuID = 0)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Warehouse', N'Warehouse', 0, N'Warehouse', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 27, 0)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 27 WHERE strMenuName = 'Warehouse' AND strModuleName = 'Warehouse' AND intParentMenuID = 0

DECLARE @WarehouseParentMenuId INT
SELECT @WarehouseParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Warehouse' AND strModuleName = 'Warehouse' AND intParentMenuID = 0

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Truck' AND strModuleName = 'Warehouse' AND intParentMenuID = @WarehouseParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Truck', N'Warehouse', @WarehouseParentMenuId, N'Truck', N'Activity', N'Screen', N'Warehouse.view.Truck', N'small-menu-activity', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 0, strCommand = N'Warehouse.view.Truck' WHERE strMenuName = 'Truck' AND strModuleName = 'Warehouse' AND intParentMenuID = @WarehouseParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Task' AND strModuleName = 'Warehouse' AND intParentMenuID = @WarehouseParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Task', N'Warehouse', @WarehouseParentMenuId, N'Task', N'Activity', N'Screen', N'Warehouse.view.Task', N'small-menu-activity', 0, 0, 0, 1, 1, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 1, strCommand = N'Warehouse.view.Task' WHERE strMenuName = 'Task' AND strModuleName = 'Warehouse' AND intParentMenuID = @WarehouseParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Traffic' AND strModuleName = 'Warehouse' AND intParentMenuID = @WarehouseParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Traffic', N'Warehouse', @WarehouseParentMenuId, N'Traffic', N'Activity', N'Screen', N'Warehouse.view.Traffic', N'small-menu-activity', 0, 0, 0, 1, 2, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 2, strCommand = N'Warehouse.view.Traffic' WHERE strMenuName = 'Traffic' AND strModuleName = 'Warehouse' AND intParentMenuID = @WarehouseParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Inbound Order' AND strModuleName = 'Warehouse' AND intParentMenuID = @WarehouseParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Inbound Order', N'Warehouse', @WarehouseParentMenuId, N'Inbound Order', N'Activity', N'Screen', N'Warehouse.view.InboundOrder', N'small-menu-activity', 0, 0, 0, 1, 3, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 3, strCommand = N'Warehouse.view.InboundOrder' WHERE strMenuName = 'Inbound Order' AND strModuleName = 'Warehouse' AND intParentMenuID = @WarehouseParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Outbound Order' AND strModuleName = 'Warehouse' AND intParentMenuID = @WarehouseParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Outbound Order', N'Warehouse', @WarehouseParentMenuId, N'Outbound Order', N'Activity', N'Screen', N'Warehouse.view.OutboundOrder', N'small-menu-activity', 0, 0, 0, 1, 4, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 4, strCommand = N'Warehouse.view.OutboundOrder' WHERE strMenuName = 'Outbound Order' AND strModuleName = 'Warehouse' AND intParentMenuID = @WarehouseParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Cycle Count' AND strModuleName = 'Warehouse' AND intParentMenuID = @WarehouseParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Cycle Count', N'Warehouse', @WarehouseParentMenuId, N'Cycle Count', N'Activity', N'Screen', N'Warehouse.view.CycleCount', N'small-menu-activity', 0, 0, 0, 1, 5, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 5, strCommand = N'Warehouse.view.CycleCount' WHERE strMenuName = 'Cycle Count' AND strModuleName = 'Warehouse' AND intParentMenuID = @WarehouseParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Container' AND strModuleName = 'Warehouse' AND intParentMenuID = @WarehouseParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Container', N'Warehouse', @WarehouseParentMenuId, N'Container', N'Maintenance', N'Screen', N'Warehouse.view.Container', N'small-menu-maintenance', 0, 0, 0, 1, 6, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 6, strCommand = N'Warehouse.view.Container' WHERE strMenuName = 'Container' AND strModuleName = 'Warehouse' AND intParentMenuID = @WarehouseParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Container Type' AND strModuleName = 'Warehouse' AND intParentMenuID = @WarehouseParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Container Type', N'Warehouse', @WarehouseParentMenuId, N'Container Type', N'Maintenance', N'Screen', N'Warehouse.view.ContainerType', N'small-menu-maintenance', 0, 0, 0, 1, 7, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 7, strCommand = N'Warehouse.view.ContainerType' WHERE strMenuName = 'Container Type' AND strModuleName = 'Warehouse' AND intParentMenuID = @WarehouseParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'SKU' AND strModuleName = 'Warehouse' AND intParentMenuID = @WarehouseParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'SKU', N'Warehouse', @WarehouseParentMenuId, N'SKU', N'Maintenance', N'Screen', N'Warehouse.view.SKU', N'small-menu-maintenance', 0, 0, 0, 1, 8, 1)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 8, strCommand = N'Warehouse.view.SKU' WHERE strMenuName = 'SKU' AND strModuleName = 'Warehouse' AND intParentMenuID = @WarehouseParentMenuId

/* TAX FORM */
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Tax Form' AND strModuleName = 'Tax Form' AND intParentMenuID = 0)
UPDATE tblSMMasterMenu SET strMenuName = 'Motor Fuel Tax Forms', strDescription = 'Motor Fuel Tax Forms' WHERE strMenuName = 'Tax Form' AND strModuleName = 'Tax Form' AND intParentMenuID = 0

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Motor Fuel Tax Forms' AND strModuleName = 'Tax Form' AND intParentMenuID = 0)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Motor Fuel Tax Forms', N'Tax Form', 0, N'Motor Fuel Tax Forms', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 28, 0)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 28 WHERE strMenuName = 'Motor Fuel Tax Forms' AND strModuleName = 'Tax Form' AND intParentMenuID = 0

DECLARE @TaxParentMenuId INT
SELECT @TaxParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Motor Fuel Tax Forms' AND strModuleName = 'Tax Form' AND intParentMenuID = 0

/* START OF RENAMING  */
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Tax Authority' AND strModuleName = 'Tax Form' AND intParentMenuID = @TaxParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Tax Authorities' WHERE strMenuName = 'Tax Authority' AND strModuleName = 'Tax Form' AND intParentMenuID = @TaxParentMenuId
/* END OF RENAMING  */

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Tax Authorities' AND strModuleName = 'Tax Form' AND intParentMenuID = @TaxParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId])
	VALUES (N'Tax Authorities', N'Tax Form', @TaxParentMenuId, N'Tax Authorities', N'Maintenance', N'Screen', N'TaxForm.view.TaxAuthority', N'small-menu-maintenance', 0, 0, 0, 1, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = N'TaxForm.view.TaxAuthority' WHERE strMenuName = 'Tax Authorities' AND strModuleName = 'Tax Form' AND intParentMenuID = @TaxParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Integration' AND strModuleName = 'Tax Form' AND intParentMenuID = @TaxParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId])
	VALUES (N'Integration', N'Tax Form', @TaxParentMenuId, N'Integration', N'Maintenance', N'Screen', N'TaxForm.view.Integration', N'small-menu-maintenance', 0, 0, 0, 1, 1, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = N'TaxForm.view.Integration' WHERE strMenuName = 'Integration' AND strModuleName = 'Tax Form' AND intParentMenuID = @TaxParentMenuId

/* PATRONAGE */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Patronage' AND strModuleName = 'Patronage' AND intParentMenuID = 0)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Patronage', N'Patronage', 0, N'Patronage', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 29, 0)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 29 WHERE strMenuName = 'Patronage' AND strModuleName = 'Patronage' AND intParentMenuID = 0

DECLARE @PatronageParentMenuId INT
SELECT @PatronageParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Patronage' AND strModuleName = 'Patronage' AND intParentMenuID = 0

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Refund Calculation Worksheet' AND strModuleName = 'Patronage' AND intParentMenuID = @PatronageParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = 'Process Refund', strDescription = 'Process Refund' WHERE strMenuName = 'Refund Calculation Worksheet' AND strModuleName = 'Patronage' AND intParentMenuID = @PatronageParentMenuId

--IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Patronage Category' AND strModuleName = 'Patronage' AND intParentMenuID = @PatronageParentMenuId)
--	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
--	VALUES (N'Patronage Category', N'Patronage', @PatronageParentMenuId, N'Patronage Category', N'Maintenance', N'Screen', N'Patronage.view.PatronageCategory', N'small-menu-maintenance', 0, 0, 0, 1, 0, 1)
--ELSE 
--	UPDATE tblSMMasterMenu SET strCommand = N'Patronage.view.PatronageCategory' WHERE strMenuName = 'Patronage Category' AND strModuleName = 'Patronage' AND intParentMenuID = @PatronageParentMenuId

--IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Stock Classification' AND strModuleName = 'Patronage' AND intParentMenuID = @PatronageParentMenuId)
--	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
--	VALUES (N'Stock Classification', N'Patronage', @PatronageParentMenuId, N'Stock Classification', N'Maintenance', N'Screen', N'Patronage.view.StockClassification', N'small-menu-maintenance', 0, 0, 0, 1, 1, 1)
--ELSE 
--	UPDATE tblSMMasterMenu SET strCommand = N'Patronage.view.StockClassification' WHERE strMenuName = 'Stock Classification' AND strModuleName = 'Patronage' AND intParentMenuID = @PatronageParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Refund Rate' AND strModuleName = 'Patronage' AND intParentMenuID = @PatronageParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Refund Rate', N'Patronage', @PatronageParentMenuId, N'Refund Rate', N'Maintenance', N'Screen', N'Patronage.view.RefundRate', N'small-menu-maintenance', 0, 0, 0, 1, 2, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Patronage.view.RefundRate' WHERE strMenuName = 'Refund Rate' AND strModuleName = 'Patronage' AND intParentMenuID = @PatronageParentMenuId

--IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Issue Stock' AND strModuleName = 'Patronage' AND intParentMenuID = @PatronageParentMenuId)
--	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
--	VALUES (N'Issue Stock', N'Patronage', @PatronageParentMenuId, N'Issue Stock', N'Maintenance', N'Screen', N'Patronage.view.IssueStock', N'small-menu-maintenance', 0, 0, 0, 1, 3, 1)
--ELSE 
--	UPDATE tblSMMasterMenu SET strCommand = N'Patronage.view.IssueStock' WHERE strMenuName = 'Issue Stock' AND strModuleName = 'Patronage' AND intParentMenuID = @PatronageParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Estate/Corporation' AND strModuleName = 'Patronage' AND intParentMenuID = @PatronageParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Estate/Corporation', N'Patronage', @PatronageParentMenuId, N'Estate/Corporation', N'Maintenance', N'Screen', N'Patronage.view.EstateCorporation', N'small-menu-maintenance', 0, 0, 0, 1, 4, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Patronage.view.EstateCorporation' WHERE strMenuName = 'Estate/Corporation' AND strModuleName = 'Patronage' AND intParentMenuID = @PatronageParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Process Refund' AND strModuleName = 'Patronage' AND intParentMenuID = @PatronageParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Process Refund', N'Patronage', @PatronageParentMenuId, N'Process Refund', N'Maintenance', N'Screen', N'Patronage.view.RefundCalculationWorksheet', N'small-menu-maintenance', 0, 0, 0, 1, 5, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Patronage.view.RefundCalculationWorksheet' WHERE strMenuName = 'Process Refund' AND strModuleName = 'Patronage' AND intParentMenuID = @PatronageParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Stock Details' AND strModuleName = 'Patronage' AND intParentMenuID = @PatronageParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Stock Details', N'Patronage', @PatronageParentMenuId, N'Stock Details', N'Maintenance', N'Screen', N'Patronage.view.CustomerStock', N'small-menu-maintenance', 0, 0, 0, 1, 6, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Patronage.view.CustomerStock' WHERE strMenuName = 'Stock Details' AND strModuleName = 'Patronage' AND intParentMenuID = @PatronageParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Equity Details' AND strModuleName = 'Patronage' AND intParentMenuID = @PatronageParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Equity Details', N'Patronage', @PatronageParentMenuId, N'Equity Details', N'Maintenance', N'Screen', N'Patronage.view.EquityDetail', N'small-menu-maintenance', 0, 0, 0, 1, 7, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Patronage.view.EquityDetail' WHERE strMenuName = 'Equity Details' AND strModuleName = 'Patronage' AND intParentMenuID = @PatronageParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Volume Details' AND strModuleName = 'Patronage' AND intParentMenuID = @PatronageParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Volume Details', N'Patronage', @PatronageParentMenuId, N'Volume Details', N'Maintenance', N'Screen', N'Patronage.view.VolumeDetail', N'small-menu-maintenance', 0, 0, 0, 1, 8, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Patronage.view.VolumeDetail' WHERE strMenuName = 'Volume Details' AND strModuleName = 'Patronage' AND intParentMenuID = @PatronageParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Process Dividends' AND strModuleName = 'Patronage' AND intParentMenuID = @PatronageParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Process Dividends', N'Patronage', @PatronageParentMenuId, N'Process Dividends', N'Maintenance', N'Screen', N'Patronage.view.ProcessDividend', N'small-menu-maintenance', 0, 0, 0, 1, 9, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Patronage.view.ProcessDividend' WHERE strMenuName = 'Process Dividends' AND strModuleName = 'Patronage' AND intParentMenuID = @PatronageParentMenuId

DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Patronage Category' AND strModuleName = 'Patronage' AND intParentMenuID = @PatronageParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Stock Classification' AND strModuleName = 'Patronage' AND intParentMenuID = @PatronageParentMenuId
DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Issue Stock' AND strModuleName = 'Patronage' AND intParentMenuID = @PatronageParentMenuId

/* Energy Trac */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Energy Trac' AND strModuleName = 'Energy Trac' AND intParentMenuID = 0)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Energy Trac', N'Energy Trac', 0, N'Energy Trac', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 30, 0)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 30 WHERE strMenuName = 'Energy Trac' AND strModuleName = 'Energy Trac' AND intParentMenuID = 0

DECLARE @EnergyTracParentMenuId INT
SELECT @EnergyTracParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Energy Trac' AND strModuleName = 'Energy Trac' AND intParentMenuID = 0

/* START OF RENAMING  */
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Export Filter' AND strModuleName = 'Energy Trac' AND intParentMenuID = @EnergyTracParentMenuId)
UPDATE tblSMMasterMenu SET strMenuName = N'Export Setup' WHERE strMenuName = 'Export Filter' AND strModuleName = 'Energy Trac' AND intParentMenuID = @EnergyTracParentMenuId
/* END OF RENAMING  */

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Export Xml' AND strModuleName = 'Energy Trac' AND intParentMenuID = @EnergyTracParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Export Xml', N'Energy Trac', @EnergyTracParentMenuId, N'Export Xml', N'Activity', N'Screen', N'EnergyTrac.view.ExportAll', N'small-menu-activity', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'EnergyTrac.view.ExportAll' WHERE strMenuName = 'Export Xml' AND strModuleName = 'Energy Trac' AND intParentMenuID = @EnergyTracParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Export Setup' AND strModuleName = 'Energy Trac' AND intParentMenuID = @EnergyTracParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Export Setup', N'Energy Trac', @EnergyTracParentMenuId, N'Export Setup', N'Activity', N'Screen', N'EnergyTrac.view.ExportFilter', N'small-menu-activity', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'EnergyTrac.view.ExportFilter' WHERE strMenuName = 'Export Setup' AND strModuleName = 'Energy Trac' AND intParentMenuID = @EnergyTracParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Import' AND strModuleName = 'Energy Trac' AND intParentMenuID = @EnergyTracParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Import', N'Energy Trac', @EnergyTracParentMenuId, N'Import', N'Activity', N'Screen', N'EnergyTrac.view.Import', N'small-menu-activity', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'EnergyTrac.view.Import' WHERE strMenuName = 'Import' AND strModuleName = 'Energy Trac' AND intParentMenuID = @EnergyTracParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Delivery Metrics' AND strModuleName = 'Energy Trac' AND intParentMenuID = @EnergyTracParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Delivery Metrics', N'Energy Trac', @EnergyTracParentMenuId, N'Delivery Metrics', N'Activity', N'Screen', N'EnergyTrac.view.Report', N'small-menu-activity', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'EnergyTrac.view.Report' WHERE strMenuName = 'Delivery Metrics' AND strModuleName = 'Energy Trac' AND intParentMenuID = @EnergyTracParentMenuId

/* INTEGRATION */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Integration' AND strModuleName = 'Integration' AND intParentMenuID = 0)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Integration', N'Integration', 0, N'Integration', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 31, 0)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 31 WHERE strMenuName = 'Integration' AND strModuleName = 'Integration' AND intParentMenuID = 0

DECLARE @IntegrationParentMenuId INT
SELECT @IntegrationParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Integration' AND strModuleName = 'Integration' AND intParentMenuID = 0

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Processes' AND strModuleName = 'Integration' AND intParentMenuID = @IntegrationParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Processes', N'Integration', @IntegrationParentMenuId, N'Processes', N'Activity', N'Screen', N'Integration.view.ProcessSetup', N'small-menu-activity', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Integration.view.ProcessSetup' WHERE strMenuName = 'Processes' AND strModuleName = 'Integration' AND intParentMenuID = @IntegrationParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Connections' AND strModuleName = 'Integration' AND intParentMenuID = @IntegrationParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Connections', N'Integration', @IntegrationParentMenuId, N'Connections', N'Maintenance', N'Screen', N'Integration.view.Connection', N'small-menu-maintenance', 0, 0, 0, 1, 1, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Integration.view.Connection' WHERE strMenuName = 'Connections' AND strModuleName = 'Integration' AND intParentMenuID = @IntegrationParentMenuId

/* Fixed Assets */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Fixed Assets' AND strModuleName = 'Fixed Assets' AND intParentMenuID = 0)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Fixed Assets', N'Fixed Assets', 0, N'Fixed Assets', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 32, 0)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 32 WHERE strMenuName = 'Fixed Assets' AND strModuleName = 'Fixed Assets' AND intParentMenuID = 0

DECLARE @FixedAssetsParentMenuId INT
SELECT @FixedAssetsParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Fixed Assets' AND strModuleName = 'Fixed Assets' AND intParentMenuID = 0

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Fixed Assets' AND strModuleName = 'Fixed Assets' AND intParentMenuID = @FixedAssetsParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Fixed Assets', N'Fixed Assets', @FixedAssetsParentMenuId, N'Fixed Assets', N'Activity', N'Screen', N'FixedAssets.view.FixedAssets', N'small-menu-activity', 1, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'FixedAssets.view.FixedAssets' WHERE strMenuName = 'Fixed Assets' AND strModuleName = 'Fixed Assets' AND intParentMenuID = @FixedAssetsParentMenuId
	
----------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------ CONTACT MENUS -------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------- ALL CONTACT MENUS ONLY MUST BE DELETED IN uspSMFixUserRoleMenus ----------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------
/* System Manager */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @SystemManagerParentMenuId)
INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId]) VALUES (@SystemManagerParentMenuId)

DECLARE @UserRolesMenuId INT
SELECT  @UserRolesMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = N'User Roles' AND strModuleName = N'System Manager' AND intParentMenuID = @SystemManagerParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'User Roles' AND strModuleName = N'System Manager' AND intParentMenuID = @SystemManagerParentMenuId)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @UserRolesMenuId)
	INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId]) VALUES (@UserRolesMenuId)
END

/* Help Desk */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @HelpDeskParentMenuId)
INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId]) VALUES (@HelpDeskParentMenuId)

--DECLARE @CreateTicketMenuId INT
--SELECT  @CreateTicketMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = N'Create Ticket' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskParentMenuId
--IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Create Ticket' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskParentMenuId)
--BEGIN
--	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @CreateTicketMenuId)
--	INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId]) VALUES (@CreateTicketMenuId)
--END

DECLARE @TicketsMenuId INT
SELECT  @TicketsMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = N'Tickets' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Tickets' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskParentMenuId)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @TicketsMenuId)
	INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId]) VALUES (@TicketsMenuId)
END

--DECLARE @OpenTicketsMenuId INT
--SELECT  @OpenTicketsMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = N'Open Tickets' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskParentMenuId
--IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Open Tickets' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskParentMenuId)
--BEGIN
--	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @OpenTicketsMenuId)
--	INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId]) VALUES (@OpenTicketsMenuId)
--END

--DECLARE @TicketsReportedByMeMenuId INT
--SELECT  @TicketsReportedByMeMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = N'Tickets Reported by Me' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskParentMenuId
--IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Tickets Reported by Me' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskParentMenuId)
--BEGIN
--	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @TicketsReportedByMeMenuId)
--	INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId]) VALUES (@TicketsReportedByMeMenuId)
--END

--DECLARE @ProjectListsMenuId INT
--SELECT  @ProjectListsMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = N'Project Lists' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskParentMenuId
--IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Project Lists' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskParentMenuId)
--BEGIN
--	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @ProjectListsMenuId)
--	INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId]) VALUES (@ProjectListsMenuId)
--END

DECLARE @ReminderListsMenuId INT
SELECT  @ReminderListsMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = N'Reminder Lists' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Reminder Lists' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskParentMenuId)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @ReminderListsMenuId)
	INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId]) VALUES (@ReminderListsMenuId)
END

/* Sales */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @AccountsReceivableParentMenuId)
INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId]) VALUES (@AccountsReceivableParentMenuId)

DECLARE @InvoicesMenuId INT
SELECT  @InvoicesMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Invoices' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Invoices' AND strModuleName = N'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @InvoicesMenuId)
	INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId]) VALUES (@InvoicesMenuId)
END

DECLARE @CustomerContactListMenuId INT
SELECT  @CustomerContactListMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = N'Customer Contact List' AND strModuleName = N'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Customer Contact List' AND strModuleName = N'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @CustomerContactListMenuId)
	INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId]) VALUES (@CustomerContactListMenuId)
END

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Customer' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Customer', N'Accounts Receivable', @AccountsReceivableParentMenuId, N'Customer', N'Activity', N'Screen', N'EntityManagement.view.Entity', N'small-menu-activity', 1, 0, 0, 1, NULL, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'EntityManagement.view.Entity' WHERE strMenuName = 'Customer' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId

DECLARE @CustomerMenuId INT
SELECT  @CustomerMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Customer' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Customer' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @CustomerMenuId)
		INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId], [ysnContactOnly]) VALUES (@CustomerMenuId, 1)
	ELSE
		UPDATE tblSMContactMenu SET ysnContactOnly = 1 WHERE intMasterMenuId = @CustomerMenuId
END

/* Purchasing */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @AccountsPayableParentMenuId)
INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId]) VALUES (@AccountsPayableParentMenuId)

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Vendor' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Vendor', N'Accounts Payable', @AccountsPayableParentMenuId, N'Vendor', N'Activity', N'Screen', N'EntityManagement.view.Entity', N'small-menu-activity', 1, 0, 0, 1, NULL, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'EntityManagement.view.Entity' WHERE strMenuName = 'Vendor' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId

DECLARE @VendorMenuId INT
SELECT  @VendorMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = N'Vendor' AND strModuleName = N'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Vendor' AND strModuleName = N'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @VendorMenuId)
		INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId], [ysnContactOnly]) VALUES (@VendorMenuId, 1)
	ELSE
		UPDATE tblSMContactMenu SET ysnContactOnly = 1 WHERE intMasterMenuId = @VendorMenuId
END

DECLARE @VouchersMenuId INT
SELECT  @VouchersMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = N'Vouchers' AND strModuleName = N'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Vouchers' AND strModuleName = N'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @VouchersMenuId)
	INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId]) VALUES (@VouchersMenuId)
END

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Vendor Contact List' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Vendor Contact List', N'Accounts Payable', @AccountsPayableParentMenuId, N'Vendor Contact List', N'Activity', N'Screen', N'EntityManagement.controller.VendorContactList', N'small-menu-activity', 1, 0, 0, 1, NULL, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'EntityManagement.controller.VendorContactList' WHERE strMenuName = 'Vendor Contact List' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId

DECLARE @VendorContactListMenuId INT
SELECT  @VendorContactListMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = N'Vendor Contact List' AND strModuleName = N'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Vendor Contact List' AND strModuleName = N'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @VendorContactListMenuId)
		INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId], [ysnContactOnly]) VALUES (@VendorContactListMenuId, 1)
	ELSE
		UPDATE tblSMContactMenu SET ysnContactOnly = 1 WHERE intMasterMenuId = @VendorContactListMenuId
END

DECLARE @PurchaseOrdersMenuId INT
SELECT  @PurchaseOrdersMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = N'Purchase Orders' AND strModuleName = N'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Purchase Orders' AND strModuleName = N'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @PurchaseOrdersMenuId)
	INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId]) VALUES (@PurchaseOrdersMenuId)
END

/* Ticket Management */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @TicketManagementParentMenuId)
INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId]) VALUES (@TicketManagementParentMenuId)

DECLARE @TicketMenuId INT
SELECT  @TicketMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Tickets' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Tickets' AND strModuleName = N'Ticket Management' AND intParentMenuID = @TicketManagementParentMenuId)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @TicketMenuId)
	INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId]) VALUES (@TicketMenuId)
END

DECLARE @StorageMenuId INT
SELECT  @StorageMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Storage' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Storage' AND strModuleName = 'Ticket Management' AND intParentMenuID = @TicketManagementParentMenuId)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @StorageMenuId)
		INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId], [ysnContactOnly]) VALUES (@StorageMenuId, 1)
	ELSE
		UPDATE tblSMContactMenu SET ysnContactOnly = 1 WHERE intMasterMenuId = @StorageMenuId
END

/* Logistic */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @LogisticsParentMenuId)
INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId]) VALUES (@LogisticsParentMenuId)

DECLARE @LoadSchedulesMenuId INT
SELECT  @LoadSchedulesMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Load / Shipment Schedules' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Load / Shipment Schedules' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsParentMenuId)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @LoadSchedulesMenuId)
	INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId]) VALUES (@LoadSchedulesMenuId)
END

/* CRM */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @CRMParentMenuId)
INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId]) VALUES (@CRMParentMenuId)

DECLARE @ActivitiesMenuId INT
SELECT  @ActivitiesMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Activities' AND strModuleName = 'Help Desk' AND intParentMenuID = @CRMParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Activities' AND strModuleName = 'Help Desk' AND intParentMenuID = @CRMParentMenuId)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @ActivitiesMenuId)
	INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId]) VALUES (@ActivitiesMenuId)
END

DECLARE @OpportunitiesMenuId INT
SELECT  @OpportunitiesMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Opportunities' AND strModuleName = 'Help Desk' AND intParentMenuID = @CRMParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Opportunities' AND strModuleName = 'Help Desk' AND intParentMenuID = @CRMParentMenuId)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @OpportunitiesMenuId)
	INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId]) VALUES (@OpportunitiesMenuId)
END

DECLARE @CampaignsMenuId INT
SELECT  @CampaignsMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Campaigns' AND strModuleName = 'Help Desk' AND intParentMenuID = @CRMParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Campaigns' AND strModuleName = 'Help Desk' AND intParentMenuID = @CRMParentMenuId)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @CampaignsMenuId)
	INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId]) VALUES (@CampaignsMenuId)
END

DECLARE @SalesPipeStatusesMenuId INT
SELECT  @SalesPipeStatusesMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Sales Pipe Statuses' AND strModuleName = 'Help Desk' AND intParentMenuID = @CRMParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Sales Pipe Statuses' AND strModuleName = 'Help Desk' AND intParentMenuID = @CRMParentMenuId)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @SalesPipeStatusesMenuId)
	INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId]) VALUES (@SalesPipeStatusesMenuId)
END

DECLARE @LinesOfBusinessMenuId INT
SELECT  @LinesOfBusinessMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Lines of Business' AND strModuleName = 'Help Desk' AND intParentMenuID = @CRMParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Lines of Business' AND strModuleName = 'Help Desk' AND intParentMenuID = @CRMParentMenuId)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @LinesOfBusinessMenuId)
	INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId]) VALUES (@LinesOfBusinessMenuId)
END

DECLARE @SourcesMenuId INT
SELECT  @SourcesMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Sources' AND strModuleName = 'Help Desk' AND intParentMenuID = @CRMParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Sources' AND strModuleName = 'Help Desk' AND intParentMenuID = @CRMParentMenuId)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @SourcesMenuId)
	INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId]) VALUES (@SourcesMenuId)
END

DECLARE @SalesEntitiesMenuId INT
SELECT  @SalesEntitiesMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Sales Entities' AND strModuleName = 'Help Desk' AND intParentMenuID = @CRMParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Sales Entities' AND strModuleName = 'Help Desk' AND intParentMenuID = @CRMParentMenuId)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @SalesEntitiesMenuId)
	INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId]) VALUES (@SalesEntitiesMenuId)
END

DECLARE @LeadMenuId INT
SELECT  @LeadMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Leads' AND strModuleName = 'Help Desk' AND intParentMenuID = @CRMParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Leads' AND strModuleName = 'Help Desk' AND intParentMenuID = @CRMParentMenuId)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @LeadMenuId)
	INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId]) VALUES (@LeadMenuId)
END

--DECLARE @CompetitorsMenuId INT
--SELECT  @CompetitorsMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Competitors' AND strModuleName = 'Help Desk' AND intParentMenuID = @CRMParentMenuId
--IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Competitors' AND strModuleName = 'Help Desk' AND intParentMenuID = @CRMParentMenuId)
--BEGIN
--	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @CompetitorsMenuId)
--	INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId]) VALUES (@CompetitorsMenuId)
--END

DECLARE @SalesEntityContactMenuId INT
SELECT  @SalesEntityContactMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Sales Entity Contact' AND strModuleName = 'Help Desk' AND intParentMenuID = @CRMParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Sales Entity Contact' AND strModuleName = 'Help Desk' AND intParentMenuID = @CRMParentMenuId)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @SalesEntityContactMenuId)
	INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId]) VALUES (@SalesEntityContactMenuId)
END

/* CONTRACT MANAGEMENT */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @ContractManagementParentMenuId)
INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId]) VALUES (@ContractManagementParentMenuId)

DECLARE @ContractsMenuId INT
SELECT  @ContractsMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Contracts' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Contracts' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @ContractsMenuId)
	INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId]) VALUES (@ContractsMenuId)
END

/* CARD FUELING */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @CardFuelingParentMenuId)
INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId]) VALUES (@CardFuelingParentMenuId)

DECLARE @TransactionMenuId INT
SELECT  @TransactionMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Transaction' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Transaction' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingParentMenuId)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @TransactionMenuId)
	INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId]) VALUES (@TransactionMenuId)
END

DECLARE @CardAccountsMenuId INT
SELECT  @CardAccountsMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Card Accounts' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Card Accounts' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingParentMenuId)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @CardAccountsMenuId)
	INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId]) VALUES (@CardAccountsMenuId)
END

/* MANUFACTURING */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @ManufacturingParentMenuId)
INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId]) VALUES (@ManufacturingParentMenuId)

DECLARE @InventoryViewMenuId INT
SELECT  @InventoryViewMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Inventory View' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Inventory View' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingParentMenuId)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @InventoryViewMenuId)
	INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId]) VALUES (@InventoryViewMenuId)
END

DECLARE @TransactionViewMenuId INT
SELECT  @TransactionViewMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Transaction View' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Transaction View' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingParentMenuId)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @TransactionViewMenuId)
	INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId]) VALUES (@TransactionViewMenuId)
END

/* QUALITY */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @QualityParentMenuId)
INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId]) VALUES (@QualityParentMenuId)

DECLARE @SampleEntryMenuId INT
SELECT  @SampleEntryMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Sample Entry' AND strModuleName = 'Quality' AND intParentMenuID = @QualityParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Sample Entry' AND strModuleName = 'Quality' AND intParentMenuID = @QualityParentMenuId)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @SampleEntryMenuId)
	INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId]) VALUES (@SampleEntryMenuId)
END

DECLARE @QualityViewMenuId INT
SELECT  @QualityViewMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Quality View' AND strModuleName = 'Quality' AND intParentMenuID = @QualityParentMenuId
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Quality View' AND strModuleName = 'Quality' AND intParentMenuID = @QualityParentMenuId)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMContactMenu WHERE intMasterMenuId = @QualityViewMenuId)
	INSERT [dbo].[tblSMContactMenu] ([intMasterMenuId]) VALUES (@QualityViewMenuId)
END

GO
----------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------- ADJUST uspSMSortOriginMenus' sorting -------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------