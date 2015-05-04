GO

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Bank File Formats'	AND strModuleName = 'Cash Management' AND (strCommand = 'CashManagement.controller.BankFileFormat' OR strCommand = 'CashManagement.view.BankFileFormat'))
	BEGIN
		DELETE FROM tblSMMasterMenu
		
		SET IDENTITY_INSERT [dbo].[tblSMMasterMenu] ON

		/* SYSTEM MANAGER */
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (1, N'System Manager', N'System Manager', 0, N'System Manager', NULL, N'Folder', N'i21', N'small-folder', 1, 0, 0, 0, 1, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (2, N'User Security', N'System Manager', 1, N'User Security', N'Maintenance', N'Screen', N'i21.view.UserSecurity', N'small-menu-maintenance', 0, 0, 0, 1, 1, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (3, N'User Roles', N'System Manager', 1, N'User Roles', N'Maintenance', N'Screen', N'i21.view.UserRole', N'small-menu-maintenance', 0, 0, 0, 1, 1, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (4, N'Report Manager', N'System Manager', 1, N'Report Manager', N'Maintenance', N'Screen', N'Reports.controller.ReportManager', N'small-menu-maintenance', 0, 0, 0, 1, 2, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (5, N'Motor Fuel Tax Cycle', N'System Manager', 1, N'Motor Fuel Tax Cycle', N'Maintenance', N'Screen', N'Reports.controller.RunTaxCycle', N'small-menu-maintenance', 0, 0, 0, 1, 3, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (6, N'Company Preferences', N'System Manager', 1, N'Company Preferences', N'Maintenance', N'Screen', N'i21.view.CompanyPreferences', N'small-menu-maintenance', 0, 0, 0, 1, 4, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (7, N'Starting Numbers', N'System Manager', 1, N'Starting Numbers', N'Maintenance', N'Screen', N'i21.view.StartingNumbers', N'small-menu-maintenance', 0, 0, 0, 1, 5, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (8, N'Custom Fields', N'System Manager', 1, N'Custom Fields', N'Maintenance', N'Screen', N'GlobalComponentEngine.view.CustomField', N'small-menu-maintenance', 0, 0, 0, 1, 6, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (10, N'Utilities', N'System Manager', 1, N'Utilities', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 8, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (11, N'Origin Conversions', N'System Manager', 10, N'Origin Conversions', N'Maintenance', N'Screen', N'i21.view.OriginConversions', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (12, N'Import Origin Users', N'System Manager', 10, N'Import Legacy Users', N'Maintenance', N'Screen', N'i21.view.ImportLegacyUsers', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (13, N'Common Info', N'System Manager', 0, N'Common Info', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 2, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (14, N'Country', N'System Manager', 13, N'Country', N'Maintenance', N'Screen', N'i21.view.Country', N'small-menu-maintenance', 0, 0, 0, 1, 0, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (15, N'Zip Code', N'System Manager', 13, N'Zip Code', N'Maintenance', N'Screen', N'i21.view.ZipCode', N'small-menu-maintenance', 0, 0, 0, 1, 1, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (16, N'Currency', N'System Manager', 13, N'Currency', N'Maintenance', N'Screen', N'i21.view.Currency', N'small-menu-maintenance', 0, 0, 0, 1, 2, 1)
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
		VALUES (22, N'Connections', N'Dashboard', 20, N'Connections', N'Maintenance', N'Screen', N'Reports.view.Connection', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
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
		VALUES (28, N'General Journal', N'General Ledger', 26, N'General Journal', N'Activity', N'Screen', N'GeneralLedger.view.GeneralJournal', N'small-menu-activity', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (29, N'GL Account Detail', N'General Ledger', 26, N'GL Account Detail', N'Activity', N'Screen', N'GeneralLedger.view.GLAccountDetail', N'small-menu-activity', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (30, N'Batch Posting', N'General Ledger', 26, N'Batch Posting', N'Activity', N'Screen', N'GeneralLedger.view.BatchPosting', N'small-menu-activity', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (31, N'Reminder List', N'General Ledger', 26, N'Reminder List', N'Activity', N'Screen', N'GeneralLedger.view.ReminderList', N'small-menu-activity', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (32, N'Import Budget from CSV', N'General Ledger', 26, N'Import Budget from CSV', N'Activity', N'Screen', N'GeneralLedger.view.ImportBudgetFromCSV', N'small-menu-activity', 0, 0, 0, 1, NULL, 1)
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
		VALUES (46, N'Reallocation', N'General Ledger', 26, N'Reallocation', N'Maintenance', N'Screen', N'GeneralLedger.view.Reallocation', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (47, N'Recurring Journal', N'General Ledger', 26, N'Recurring Journal', N'Maintenance', N'Screen', N'GeneralLedger.view.RecurringJournal', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (48, N'Recurring Journal History', N'General Ledger', 26, N'Recurring Journal History', N'Maintenance', N'Screen', N'GeneralLedger.view.RecurringJournalHistory', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)

		/* FINANCIAL REPORTS */
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (49, N'Financial Reports', N'Financial Reports', 0, N'Financial Reports', NULL, N'Folder', N'FinancialReportDesigner', N'small-folder', 1, 0, 0, 0, 5, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (50, N'Financial Report Viewer', N'Financial Reports', 49, N'Financial Report Viewer', N'Activity', N'Screen', N'FinancialReportDesigner.view.FinancialReports', N'small-menu-activity', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (52, N'Row Designer', N'Financial Reports', 49, N'Row Designer', N'Maintenance', N'Screen', N'FinancialReportDesigner.view.RowDesigner', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (53, N'Column Designer', N'Financial Reports', 49, N'Column Designer', N'Maintenance', N'Screen', N'FinancialReportDesigner.view.ColumnDesigner', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (54, N'Report Header and Footer', N'Financial Reports', 49, N'Report Header and Footer', N'Maintenance', N'Screen', N'FinancialReportDesigner.view.HeaderFooterDesigner', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (55, N'Financial Report Builder', N'Financial Reports', 49, N'Financial Report Builder', N'Maintenance', N'Screen', N'FinancialReportDesigner.view.ReportBuilder', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (56, N'Report Templates', N'Financial Reports', 49, N'Report Templates', N'Maintenance', N'Screen', N'FinancialReportDesigner.view.Templates', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)


		/* GENERAL LEDGER */
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (58, N'Reallocation', N'General Ledger', 26, N'Reallocation', N'Report', N'Report', N'Reallocation', N'small-menu-report', 0, 0, 0, 1, 4, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (59, N'Chart of Accounts', N'General Ledger', 26, N'Chart of Accounts', N'Report', N'Report', N'Chart of Accounts', N'small-menu-report', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (60, N'Chart of Accounts Adjustment', N'General Ledger', 26, N'Chart of Accounts Adjustment', N'Report', N'Report', N'Chart of Accounts Adjustment', N'small-menu-report', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (61, N'General Ledger by Account ID Detail', N'General Ledger', 26, N'General Ledger by Account ID Detail', N'Report', N'Report', N'General Ledger by Account ID Detail', N'small-menu-report', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (62, N'Balance Sheet Standard', N'General Ledger', 26, N'Balance Sheet Standard', N'Report', N'Report', N'Balance Sheet Standard', N'small-menu-report', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (63, N'Income Statement Standard', N'General Ledger', 26, N'Income Statement Standard', N'Report', N'Report', N'Income Statement Standard', N'small-menu-report', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (64, N'Trial Balance', N'General Ledger', 26, N'Trial Balance', N'Report', N'Report', N'Trial Balance', N'small-menu-report', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (65, N'Trial Balance Detail', N'General Ledger', 26, N'Trial Balance Detail', N'Report', N'Report', N'Trial Balance Detail', N'small-menu-report', 0, 0, 0, 1, NULL, 1)


		/* TANK MANAGEMENT */
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (66, N'Tank Management', N'Tank Management', 0, N'Tank Management', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 19, 1)
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
		VALUES (78, N'Event Type', N'Tank Management', 66, N'Event Type', N'Maintenance', N'Screen', N'TankManagement.view.EventType', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (79, N'Device Type', N'Tank Management', 66, N'Device Type', N'Maintenance', N'Screen', N'TankManagement.view.DeviceType', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (80, N'Lease Code', N'Tank Management', 66, N'Lease Code', N'Maintenance', N'Screen', N'TankManagement.view.LeaseCode', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (81, N'Event Automation Setup', N'Tank Management', 66, N'Event Automation Setup', N'Maintenance', N'Screen', N'TankManagement.view.EventAutomation', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (82, N'Meter Type', N'Tank Management', 66, N'Meter Type', N'Maintenance', N'Screen', N'TankManagement.view.MeterType', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (83, N'Renew Julian Deliveries', N'Tank Management', 66, N'Renew Julian Deliveries', N'Maintenance', N'Screen', N'TankManagement.view.RenewJulianDelivery', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (84, N'Resolve Sync Conflict', N'Tank Management', 66, N'Resolve Sync Conflict', N'Maintenance', N'Screen', N'TankManagement.view.ResolveSyncConflict', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (85, N'Lease Billing Incentive', N'Tank Management', 66, N'Lease Billing Incentive', N'Maintenance', N'Screen', N'TankManagement.view.LeaseBillingMinimum', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (87, N'Delivery Fill Report', N'Tank Management', 66, N'Delivery Fill Report', N'Report', N'Report', N'Delivery Fill Report', N'small-menu-report', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (88, N'Two-Part Delivery Fill Report', N'Tank Management', 66, N'Two-Part Delivery Fill Report', N'Report', N'Report', N'Two-Part Delivery Fill Report', N'small-menu-report', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (89, N'Lease Billing Report', N'Tank Management', 66, N'Lease Billing Report', N'Report', N'Report', N'Lease Billing Report', N'small-menu-report', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (90, N'Missed Julian Deliveries', N'Tank Management', 66, N'Missed Julian Deliveries', N'Report', N'Report', N'Missed Julian Deliveries', N'small-menu-report', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (91, N'Out of Range Burn Rates', N'Tank Management', 66, N'Out of Range Burn Rates', N'Report', N'Report', N'Out of Range Burn Rates', N'small-menu-report', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (92, N'Call Entry Printout', N'Tank Management', 66, N'Call Entry Printout', N'Report', N'Report', N'Call Entry Printout', N'small-menu-report', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (93, N'Fill Group', N'Tank Management', 66, N'Fill Group', N'Report', N'Report', N'Fill Group', N'small-menu-report', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (94, N'Tank Inventory', N'Tank Management', 66, N'Tank Inventory', N'Report', N'Report', N'Tank Inventory', N'small-menu-report', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (95, N'Customer List by Route', N'Tank Management', 66, N'Customer List by Route', N'Report', N'Report', N'Customer List by Route', N'small-menu-report', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (96, N'Device Actions', N'Tank Management', 66, N'Device Actions', N'Report', N'Report', N'Device Actions', N'small-menu-report', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (97, N'Open Call Entries', N'Tank Management', 66, N'Open Call Entries', N'Report', N'Report', N'Open Call Entries', N'small-menu-report', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (98, N'Work Order Status', N'Tank Management', 66, N'Work Order Status', N'Report', N'Report', N'Work Order Status', N'small-menu-report', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (99, N'Leak Check / Gas Check', N'Tank Management', 66, N'Leak Check / Gas Check', N'Report', N'Report', N'Leak Check / Gas Check', N'small-menu-report', 0, 0, 0, 1, NULL, 1)

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
		VALUES (112, N'Purchasing', N'Accounts Payable', 0, N'Purchasing', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 9, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (114, N'Pay Bill Detail', N'Accounts Payable', 112, N'Pay Bills', N'Activity', N'Screen', N'AccountsPayable.view.PayBillsDetail', N'small-menu-activity', 0, 0, 0, 1, 7, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (115, N'Pay Bills', N'Accounts Payable', 112, N'Pay Bills (Multi-Vendor)', N'Activity', N'Screen', N'AccountsPayable.view.PayBills', N'small-menu-activity', 0, 0, 0, 1, 6, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (116, N'Bill Batch Entry', N'Accounts Payable', 112, N'Bill Batch Entry', N'Activity', N'Screen', N'AccountsPayable.view.BillBatch', N'small-menu-activity', 0, 0, 0, 1, 1, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (117, N'Batch Posting', N'Accounts Payable', 112, N'Batch Posting', N'Activity', N'Screen', N'AccountsPayable.view.BatchPosting', N'small-menu-activity', 0, 0, 0, 1, 5, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (118, N'Print Checks', N'Accounts Payable', 112, N'Print Checks', N'Activity', N'Screen', N'AccountsPayable.controller.PrintChecks', N'small-menu-activity', 0, 0, 0, 1, 8, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (120, N'Import Bills from Origin', N'Accounts Payable', 112, N'Import Bills from Origin', N'Activity', N'Screen', N'AccountsPayable.view.ImportAPInvoice', N'small-menu-activity', 0, 0, 0, 1, 3, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (122, N'Vendors', N'Accounts Payable', 112, N'Vendors', N'Maintenance', N'Screen', N'EntityManagement.view.Entity:searchEntityVendor', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (125, N'Open Payables', N'Accounts Payable', 112, N'Open Payables', N'Report', N'Report', N'Open Payables', N'small-menu-report', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (126, N'Vendor History', N'Accounts Payable', 112, N'Vendor History', N'Report', N'Report', N'Vendor History', N'small-menu-report', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (127, N'Cash Requirements', N'Accounts Payable', 112, N'Cash Requirements', N'Report', N'Report', N'Cash Requirements', N'small-menu-report', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (129, N'Check Register', N'Accounts Payable', 112, N'Check Register', N'Report', N'Report', N'Check Register', N'small-menu-report', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (130, N'AP Transactions by GL Account', N'Accounts Payable', 112, N'Bill by General Ledger', N'Report', N'Report', N'AP Transactions by GL Account', N'small-menu-report', 0, 0, 0, 1, NULL, 1)

		/* ACCOUNTS RECEIVABLE */
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (131, N'Sales', N'Accounts Receivable', 0, N'Sales', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 10, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (134, N'Customers', N'Accounts Receivable', 131, N'Customers', N'Maintenance', N'Screen', N'EntityManagement.view.Entity:searchEntityCustomer', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (135, N'Customer Contact List', N'Accounts Receivable', 131, N'Customer Contact List', N'Maintenance', N'Screen', N'AccountsReceivable.view.CustomerContactList', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (136, N'Salesperson', N'Accounts Receivable', 131, N'Salesperson', N'Maintenance', N'Screen', N'EntityManagement.view.Entity:searchEntitySalesperson', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (137, N'Market Zone', N'Accounts Receivable', 131, N'Market Zone', N'Maintenance', N'Screen', N'AccountsReceivable.view.MarketZone', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (138, N'Statement Footer Message', N'Accounts Receivable', 131, N'Statement Footer Message', N'Maintenance', N'Screen', N'AccountsReceivable.view.StatementFooterMessage', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (139, N'Service Charge', N'Accounts Receivable', 131, N'Service Charge', N'Maintenance', N'Screen', N'AccountsReceivable.view.ServiceCharge', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (140, N'Customer Group', N'Accounts Receivable', 131, N'Customer Group', N'Maintenance', N'Screen', N'AccountsReceivable.view.CustomerGroup', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)

		/* HELP DESK */
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (141, N'Help Desk', N'Help Desk', 0, N'Help Desk', NULL, N'Folder', N'HelpDesk', N'small-folder', 1, 0, 0, 0, 22, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (143, N'Tickets', N'Help Desk', 141, N'Tickets', N'Activity', N'Screen', N'HelpDesk.controller.Ticket', N'small-menu-activity', 0, 0, 0, 1, 2, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (144, N'Open Tickets', N'Help Desk', 141, N'Open Tickets', N'Activity', N'Screen', N'HelpDesk.controller.OpenTicket', N'small-menu-activity', 0, 0, 0, 1, 3, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
		VALUES (145, N'Tickets Assigned to Me', N'Help Desk', 141, N'Tickets Assigned to Me', N'Activity', N'Screen', N'HelpDesk.controller.TicketAssigned', N'small-menu-activity', 0, 0, 0, 1, 4, 1)
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

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'User Security' AND strModuleName = N'System Manager' AND intParentMenuID = @SystemManagerParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'i21.view.UserSecurity' WHERE strMenuName = N'User Security' AND strModuleName = N'System Manager' AND intParentMenuID = @SystemManagerParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'User Roles' AND strModuleName = N'System Manager' AND intParentMenuID = @SystemManagerParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'i21.view.UserRole' WHERE strMenuName = N'User Roles' AND strModuleName = N'System Manager' AND intParentMenuID = @SystemManagerParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Report Manager' AND strModuleName = N'System Manager' AND intParentMenuID = @SystemManagerParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'Reports.controller.ReportManager' WHERE strMenuName = N'Report Manager' AND strModuleName = N'System Manager' AND intParentMenuID = @SystemManagerParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Motor Fuel Tax Cycle' AND strModuleName = N'System Manager' AND intParentMenuID = @SystemManagerParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'Reports.controller.RunTaxCycle' WHERE strMenuName = N'Motor Fuel Tax Cycle' AND strModuleName = N'System Manager' AND intParentMenuID = @SystemManagerParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Company Preferences' AND strModuleName = N'System Manager' AND intParentMenuID = @SystemManagerParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'i21.view.CompanyPreference' WHERE strMenuName = N'Company Preferences' AND strModuleName = N'System Manager' AND intParentMenuID = @SystemManagerParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Starting Numbers' AND strModuleName = N'System Manager' AND intParentMenuID = @SystemManagerParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'i21.view.StartingNumbers' WHERE strMenuName = N'Starting Numbers' AND strModuleName = N'System Manager' AND intParentMenuID = @SystemManagerParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Custom Fields' AND strModuleName = N'System Manager' AND intParentMenuID = @SystemManagerParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'GlobalComponentEngine.view.CustomField' WHERE strMenuName = N'Custom Fields' AND strModuleName = N'System Manager' AND intParentMenuID = @SystemManagerParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Utilities' AND strModuleName = N'System Manager' AND intParentMenuID = @SystemManagerParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'' WHERE strMenuName = N'Utilities' AND strModuleName = N'System Manager' AND intParentMenuID = @SystemManagerParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Origin Conversions' AND strModuleName = N'System Manager' AND intParentMenuID = @SystemManagerParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'i21.view.OriginConversions' WHERE strMenuName = N'Origin Conversions' AND strModuleName = N'System Manager' AND intParentMenuID = @SystemManagerParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Import Origin Users' AND strModuleName = N'System Manager' AND intParentMenuID = @SystemManagerParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'i21.view.ImportLegacyUsers' WHERE strMenuName = N'Import Origin Users' AND strModuleName = N'System Manager' AND intParentMenuID = @SystemManagerParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Company Setup' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Company Setup', N'System Manager', @SystemManagerParentMenuId, N'Company Setup', N'Maintenance', N'Screen', N'i21.view.CompanySetup', N'small-menu-maintenance', 0, 0, 0, 1, 1, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'i21.view.CompanySetup', intSort = 1 WHERE strMenuName = 'Company Setup' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerParentMenuId

DECLARE @UtilitiesParentMenuId INT
SELECT @UtilitiesParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Utilities' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Import Origin Menus' AND strModuleName = 'System Manager' AND intParentMenuID = @UtilitiesParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Import Origin Menus', N'System Manager', @UtilitiesParentMenuId, N'Import Origin Menus', N'Maintenance', N'Screen', N'i21.view.ImportLegacyMenus', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'i21.view.ImportLegacyMenus' WHERE strMenuName = 'Import Origin Menus' AND strModuleName = 'System Manager' AND intParentMenuID = @UtilitiesParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Announcements' AND strModuleName = 'Help Desk' AND intParentMenuID = @SystemManagerParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Announcements', N'Help Desk', @SystemManagerParentMenuId, N'Announcements', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 9, 2)

DECLARE @AnnouncementsParentMenuId INT
SELECT @AnnouncementsParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Announcements' AND strModuleName = 'Help Desk' AND intParentMenuID = @SystemManagerParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Announcement Types' AND strModuleName = 'Help Desk' AND intParentMenuID = @AnnouncementsParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Announcement Types', N'Help Desk', @AnnouncementsParentMenuId, N'Announcement Types', N'Maintenance', N'Screen', N'HelpDesk.view.AnnouncementType', N'small-menu-maintenance', 0, 0, 0, 1, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'HelpDesk.view.AnnouncementType' WHERE strMenuName = 'Announcement Types' AND strModuleName = 'Help Desk' AND intParentMenuID = @AnnouncementsParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'Help Desk' AND intParentMenuID = @AnnouncementsParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Maintenance', N'Help Desk', @AnnouncementsParentMenuId, N'Announcement Maintenance', N'Maintenance', N'Screen', N'HelpDesk.view.Announcement', N'small-menu-maintenance', 0, 0, 0, 1, 1, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'HelpDesk.view.Announcement' WHERE strMenuName = 'Maintenance' AND strModuleName = 'Help Desk' AND intParentMenuID = @AnnouncementsParentMenuId

/* COMMON INFO */
IF EXISTS (SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Common Info' AND strModuleName = 'System Manager')
UPDATE tblSMMasterMenu SET intSort = 2, intParentMenuID = 0 FROM tblSMMasterMenu WHERE strMenuName = 'Common Info' AND strModuleName = 'System Manager'

DECLARE @CommonInfoParentMenuId INT
SELECT @CommonInfoParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Common Info' AND strModuleName = 'System Manager' AND intParentMenuID = 0

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Country' AND strModuleName = N'System Manager' AND intParentMenuID = @CommonInfoParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'i21.view.Country' WHERE strMenuName = N'Country' AND strModuleName = N'System Manager' AND intParentMenuID = @CommonInfoParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Zip Code' AND strModuleName = N'System Manager' AND intParentMenuID = @CommonInfoParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'i21.view.ZipCode' WHERE strMenuName = N'Zip Code' AND strModuleName = N'System Manager' AND intParentMenuID = @CommonInfoParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Currency' AND strModuleName = N'System Manager' AND intParentMenuID = @CommonInfoParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'i21.view.Currency' WHERE strMenuName = N'Currency' AND strModuleName = N'System Manager' AND intParentMenuID = @CommonInfoParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Ship Via' AND strModuleName = N'System Manager' AND intParentMenuID = @CommonInfoParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'i21.view.ShipVia' WHERE strMenuName = N'Ship Via' AND strModuleName = N'System Manager' AND intParentMenuID = @CommonInfoParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Payment Methods' AND strModuleName = N'System Manager' AND intParentMenuID = @CommonInfoParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'i21.view.PaymentMethod' WHERE strMenuName = N'Payment Methods' AND strModuleName = N'System Manager' AND intParentMenuID = @CommonInfoParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Terms' AND strModuleName = N'System Manager' AND intParentMenuID = @CommonInfoParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'i21.view.Term' WHERE strMenuName = N'Terms' AND strModuleName = N'System Manager' AND intParentMenuID = @CommonInfoParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Company Location' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId])
	VALUES (N'Company Location', N'System Manager', @CommonInfoParentMenuId, N'Company Location', N'Maintenance', N'Screen', N'i21.view.CompanyLocation', N'small-menu-maintenance', 0, 0, 0, 1, 6, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'i21.view.CompanyLocation' WHERE strMenuName = 'Company Location' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Freight Terms' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Freight Terms', N'System Manager', @CommonInfoParentMenuId, N'Freight Terms', N'Maintenance', N'Screen', N'i21.view.FreightTerms', N'small-menu-maintenance', 0, 0, 0, 1, 7, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'i21.view.FreightTerms' WHERE strMenuName = 'Freight Terms' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Recurring Transactions' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Recurring Transactions', N'System Manager', @CommonInfoParentMenuId, N'Recurring Transactions', N'Maintenance', N'Screen', N'i21.view.RecurringTransaction', N'small-menu-maintenance', 0, 0, 0, 1, 8, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'i21.view.RecurringTransaction' WHERE strMenuName = 'Recurring Transactions' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Tax Group Master' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Tax Group Master', N'System Manager', @CommonInfoParentMenuId, N'Tax Group Master', N'Maintenance', N'Screen', N'i21.view.TaxGroupMaster', N'small-menu-maintenance', 0, 0, 0, 1, 9, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'i21.view.TaxGroupMaster' WHERE strMenuName = 'Tax Group Master' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Tax Group' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Tax Group', N'System Manager', @CommonInfoParentMenuId, N'Tax Group', N'Maintenance', N'Screen', N'i21.view.TaxGroup', N'small-menu-maintenance', 0, 0, 0, 1, 10, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'i21.view.TaxGroup' WHERE strMenuName = 'Tax Group' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Tax Code' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Tax Code', N'System Manager', @CommonInfoParentMenuId, N'Tax Code', N'Maintenance', N'Screen', N'i21.view.TaxCode', N'small-menu-maintenance', 0, 0, 0, 1, 11, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'i21.view.TaxCode' WHERE strMenuName = 'Tax Code' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId

IF EXISTS(SELECT 1 FROM dbo.tblSMMasterMenu WHERE strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId AND strMenuName = 'Tax Type')
DELETE FROM [dbo].[tblSMMasterMenu] WHERE strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId AND strMenuName = 'Tax Type'

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Tax Class' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Tax Class', N'System Manager', @CommonInfoParentMenuId, N'Tax Class', N'Maintenance', N'Screen', N'i21.view.TaxClass', N'small-menu-maintenance', 0, 0, 0, 1, 12, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'i21.view.TaxClass' WHERE strMenuName = 'Tax Class' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'City' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'City', N'System Manager', @CommonInfoParentMenuId, N'City', N'Maintenance', N'Screen', N'i21.view.City', N'small-menu-maintenance', 0, 0, 0, 1, 13, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'i21.view.City' WHERE strMenuName = 'City' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Currency Exchange Rate' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Currency Exchange Rate', N'System Manager', @CommonInfoParentMenuId, N'Currency Exchange Rate', N'Maintenance', N'Screen', N'i21.view.CurrencyExchangeRate', N'small-menu-maintenance', 0, 0, 0, 1, 14, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'i21.view.CurrencyExchangeRate' WHERE strMenuName = 'Currency Exchange Rate' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Currency Exchange Rate Type' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Currency Exchange Rate Type', N'System Manager', @CommonInfoParentMenuId, N'Currency Exchange Rate Type', N'Maintenance', N'Screen', N'i21.view.CurrencyExchangeRateType', N'small-menu-maintenance', 0, 0, 0, 1, 15, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'i21.view.CurrencyExchangeRateType' WHERE strMenuName = 'Currency Exchange Rate Type' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'User Preferences' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'User Preferences', N'System Manager', @CommonInfoParentMenuId, N'User Preferences', N'Maintenance', N'Screen', N'i21.view.UserPreferences', N'small-menu-maintenance', 0, 0, 0, 1, 16, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'i21.view.UserPreferences' WHERE strMenuName = 'User Preferences' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Reminder List' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Reminder List', N'System Manager', @CommonInfoParentMenuId, N'Reminder List', N'Maintenance', N'Screen', N'i21.view.ReminderList', N'small-menu-maintenance', 0, 0, 0, 1, 17, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'i21.view.ReminderList' WHERE strMenuName = 'Reminder List' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Batch Posting' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Batch Posting', N'System Manager', @CommonInfoParentMenuId, N'Batch Posting', N'Maintenance', N'Screen', N'i21.view.BatchPosting', N'small-menu-maintenance', 0, 0, 0, 1, 18, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'i21.view.BatchPosting' WHERE strMenuName = 'Batch Posting' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Approval List' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Approval List', N'System Manager', @CommonInfoParentMenuId, N'Approval List', N'Maintenance', N'Screen', N'i21.view.ApprovalList', N'small-menu-maintenance', 0, 0, 0, 1, 19, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'i21.view.ApprovalList' WHERE strMenuName = 'Approval List' AND strModuleName = 'System Manager' AND intParentMenuID = @CommonInfoParentMenuId

/* DASHBOARD */
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Dashboard' AND strModuleName = 'Dashboard' AND intParentMenuID = 0)
UPDATE tblSMMasterMenu SET intSort = 3 WHERE strMenuName = 'Dashboard' AND strModuleName = 'Dashboard' AND intParentMenuID = 0

DECLARE @DashboardParentMenuId INT
SELECT @DashboardParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Dashboard' AND strModuleName = 'Dashboard' AND intParentMenuID = 0

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Display Dashboard' AND strModuleName = 'Dashboard' AND intParentMenuID = @DashboardParentMenuId)
INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
VALUES (N'Display Dashboard', N'Dashboard', @DashboardParentMenuId, N'Display Dashboard', N'Maintenance', N'Home', N'', N'small-menu-maintenance', 0, 0, 0, 1, 0, 1)

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Add Panel' AND strModuleName = N'Dashboard' AND intParentMenuID = @DashboardParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 1, strCommand = N'Dashboard.view.PanelSettings' WHERE strMenuName = N'Add Panel' AND strModuleName = N'Dashboard' AND intParentMenuID = @DashboardParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Connections' AND strModuleName = N'Dashboard' AND intParentMenuID = @DashboardParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 2, strCommand = N'Reports.view.Connection' WHERE strMenuName = N'Connections' AND strModuleName = N'Dashboard' AND intParentMenuID = @DashboardParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Panels' AND strModuleName = N'Dashboard' AND intParentMenuID = @DashboardParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 3, strCommand = N'Dashboard.view.PanelList' WHERE strMenuName = N'Panels' AND strModuleName = N'Dashboard' AND intParentMenuID = @DashboardParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Panel Layout' AND strModuleName = N'Dashboard' AND intParentMenuID = @DashboardParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 4, strCommand = N'Dashboard.view.PanelLayout' WHERE strMenuName = N'Panel Layout' AND strModuleName = N'Dashboard' AND intParentMenuID = @DashboardParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Tabs' AND strModuleName = N'Dashboard' AND intParentMenuID = @DashboardParentMenuId)
UPDATE tblSMMasterMenu SET intSort = 5, strCommand = N'Dashboard.view.TabSetup' WHERE strMenuName = N'Tabs' AND strModuleName = N'Dashboard' AND intParentMenuID = @DashboardParentMenuId

/* GENERAL LEDGER */
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'General Ledger' AND strModuleName = 'General Ledger' AND intParentMenuID = 0)
UPDATE tblSMMasterMenu SET intSort = 4 WHERE strMenuName = 'General Ledger' AND strModuleName = 'General Ledger' AND intParentMenuID = 0

DECLARE @GeneralLedgerParentMenuId INT
SELECT @GeneralLedgerParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'General Ledger' AND strModuleName = 'General Ledger' AND intParentMenuID = 0

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'General Journal' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'GeneralLedger.view.GeneralJournal' WHERE strMenuName = N'General Journal' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'GL Account Detail' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'GeneralLedger.view.GLAccountDetail' WHERE strMenuName = N'GL Account Detail' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Batch Posting' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'i21.view.BatchPosting' WHERE strMenuName = N'Batch Posting' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Reminder List' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'GeneralLedger.view.ReminderList' WHERE strMenuName = N'Reminder List' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Import Budget from CSV' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'GeneralLedger.view.ImportBudgetFromCSV' WHERE strMenuName = N'Import Budget from CSV' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Import GL from Subledger' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'GeneralLedger.view.ImportFromSubledger' WHERE strMenuName = N'Import GL from Subledger' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Import GL from CSV' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'GeneralLedger.view.ImportFromCSV' WHERE strMenuName = N'Import GL from CSV' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'GL Import Logs' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'GeneralLedger.view.ImportLogs' WHERE strMenuName = N'GL Import Logs' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Chart of Accounts' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId AND strCategory = 'Maintenance')
UPDATE tblSMMasterMenu SET strCommand = N'GeneralLedger.view.ChartOfAccounts' WHERE strMenuName = N'Chart of Accounts' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId AND strCategory = 'Maintenance'

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Account Structure' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'GeneralLedger.view.AccountStructure' WHERE strMenuName = N'Account Structure' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Account Groups' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'GeneralLedger.view.AccountGroups' WHERE strMenuName = N'Account Groups' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Segment Accounts' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'GeneralLedger.view.SegmentAccounts' WHERE strMenuName = N'Segment Accounts' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Build Accounts' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'GeneralLedger.view.BuildAccounts' WHERE strMenuName = N'Build Accounts' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Clone Account' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'GeneralLedger.view.AccountClone' WHERE strMenuName = N'Clone Account' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Fiscal Year' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'GeneralLedger.view.FiscalYear' WHERE strMenuName = N'Fiscal Year' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Reallocation' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId and strCategory = 'Maintenance')
UPDATE tblSMMasterMenu SET strCommand = N'GeneralLedger.view.Reallocation' WHERE strMenuName = N'Reallocation' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId and strCategory = 'Maintenance'

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Recurring Journal' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'GeneralLedger.view.RecurringJournal' WHERE strMenuName = N'Recurring Journal' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Recurring Journal History' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'GeneralLedger.view.RecurringJournalHistory' WHERE strMenuName = N'Recurring Journal History' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Account Adjustment' AND strModuleName ='General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId)
	DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Account Adjustment' AND strModuleName ='General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Chart of Accounts' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId AND strCategory = 'Report')
    UPDATE tblSMMasterMenu SET strCommand = N'Chart of Accounts' WHERE strMenuName = N'Chart of Accounts' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId AND strCategory = 'Report'

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Reallocation' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId AND strCategory = 'Report')
    UPDATE tblSMMasterMenu SET strCommand = N'Reallocation' WHERE strMenuName = N'Reallocation' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId AND strCategory = 'Report'


/* FINANCIAL REPORTS */
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Financial Reports' AND strModuleName = N'General Ledger' AND intParentMenuID = @GeneralLedgerParentMenuId)
UPDATE tblSMMasterMenu SET intParentMenuID = 0, strModuleName = N'Financial Reports', strCommand = N'FinancialReportDesigner' WHERE strMenuName = N'Financial Reports' AND intParentMenuID = @GeneralLedgerParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Financial Reports' AND strModuleName = 'Financial Reports' AND intParentMenuID = 0)
UPDATE tblSMMasterMenu SET intSort = 5 WHERE strMenuName = 'Financial Reports' AND strModuleName = 'Financial Reports' AND intParentMenuID = 0

DECLARE @FinancialReportsParentMenuId INT
SELECT @FinancialReportsParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Financial Reports' AND strModuleName = 'Financial Reports' AND intParentMenuID = 0

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Financial Report Viewer' AND strModuleName = N'Financial Reports' AND intParentMenuID = @FinancialReportsParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'FinancialReportDesigner.view.FinancialReports' WHERE strMenuName = N'Financial Report Viewer' AND strModuleName = N'Financial Reports' AND intParentMenuID = @FinancialReportsParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Row Designer' AND strModuleName = N'Financial Reports' AND intParentMenuID = @FinancialReportsParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'FinancialReportDesigner.view.RowDesigner' WHERE strMenuName = N'Row Designer' AND strModuleName = N'Financial Reports' AND intParentMenuID = @FinancialReportsParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Column Designer' AND strModuleName = N'Financial Reports' AND intParentMenuID = @FinancialReportsParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'FinancialReportDesigner.view.ColumnDesigner' WHERE strMenuName = N'Column Designer' AND strModuleName = N'Financial Reports' AND intParentMenuID = @FinancialReportsParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Report Header and Footer' AND strModuleName = N'Financial Reports' AND intParentMenuID = @FinancialReportsParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'FinancialReportDesigner.view.HeaderFooterDesigner' WHERE strMenuName = N'Report Header and Footer' AND strModuleName = N'Financial Reports' AND intParentMenuID = @FinancialReportsParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Financial Report Builder' AND strModuleName = N'Financial Reports' AND intParentMenuID = @FinancialReportsParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'FinancialReportDesigner.view.ReportBuilder' WHERE strMenuName = N'Financial Report Builder' AND strModuleName = N'Financial Reports' AND intParentMenuID = @FinancialReportsParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Report Templates' AND strModuleName = N'Financial Reports' AND intParentMenuID = @FinancialReportsParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'FinancialReportDesigner.view.Templates' WHERE strMenuName = N'Report Templates' AND strModuleName = N'Financial Reports' AND intParentMenuID = @FinancialReportsParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Financial Report Group' AND strModuleName = 'Financial Report Designer' AND intParentMenuID = @FinancialReportsParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Financial Report Group', N'Financial Report Designer', @FinancialReportsParentMenuId, N'Financial Report Group', N'Maintenance', N'Screen', N'FinancialReportDesigner.view.FinancialReportGroup', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'FinancialReportDesigner.view.FinancialReportGroup' WHERE strMenuName = 'Financial Report Group' AND strModuleName = 'Financial Report Designer' AND intParentMenuID = @FinancialReportsParentMenuId

/* TANK MANAGEMENT */
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Tank Management' AND strModuleName = 'Tank Management' AND intParentMenuID = 0)
UPDATE tblSMMasterMenu SET intSort = 19 WHERE strMenuName = 'Tank Management' AND strModuleName = 'Tank Management' AND intParentMenuID = 0

DECLARE @TankManagementParentMenuId INT
SELECT @TankManagementParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Tank Management' AND strModuleName = 'Tank Management' AND intParentMenuID = 0

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Customer Inquiry' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'TankManagement.view.CustomerInquiry' WHERE strMenuName = N'Customer Inquiry' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Consumption Sites' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'TankManagement.view.ConsumptionSite' WHERE strMenuName = N'Consumption Sites' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Clock Reading' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'TankManagement.view.ClockReading' WHERE strMenuName = N'Clock Reading' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Synchronize Delivery History' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'TankManagement.view.SyncDeliveryHistory' WHERE strMenuName = N'Synchronize Delivery History' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Lease Billing' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'TankManagement.view.LeaseBilling' WHERE strMenuName = N'Lease Billing' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Dispatch Deliveries' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'TankManagement.view.DispatchDelivery' WHERE strMenuName = N'Dispatch Deliveries' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Degree Day Clock' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'TankManagement.view.DegreeDayClock' WHERE strMenuName = N'Degree Day Clock' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Devices' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'TankManagement.view.Device' WHERE strMenuName = N'Devices' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Events' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'TankManagement.view.Event' WHERE strMenuName = N'Events' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Event Type' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'TankManagement.view.EventType' WHERE strMenuName = N'Event Type' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Device Type' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'TankManagement.view.DeviceType' WHERE strMenuName = N'Device Type' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Lease Code' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'TankManagement.view.LeaseCode' WHERE strMenuName = N'Lease Code' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Event Automation Setup' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'TankManagement.view.EventAutomation' WHERE strMenuName = N'Event Automation Setup' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Meter Type' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'TankManagement.view.MeterType' WHERE strMenuName = N'Meter Type' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Renew Julian Deliveries' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'TankManagement.view.RenewJulianDelivery' WHERE strMenuName = N'Renew Julian Deliveries' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Resolve Sync Conflict' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'TankManagement.view.ResolveSyncConflict' WHERE strMenuName = N'Resolve Sync Conflict' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Lease Billing Incentive' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'TankManagement.view.LeaseBillingMinimum' WHERE strMenuName = N'Lease Billing Incentive' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Delivery Fill Report' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'Delivery Fill Report' WHERE strMenuName = N'Delivery Fill Report' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Two-Part Delivery Fill Report' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'Two-Part Delivery Fill Report' WHERE strMenuName = N'Two-Part Delivery Fill Report' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Lease Billing Report' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'Lease Billing Report' WHERE strMenuName = N'Lease Billing Report' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Missed Julian Deliveries' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'Missed Julian Deliveries' WHERE strMenuName = N'Missed Julian Deliveries' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Out of Range Burn Rates' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'Out of Range Burn Rates' WHERE strMenuName = N'Out of Range Burn Rates' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Call Entry Printout' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'Call Entry Printout' WHERE strMenuName = N'Call Entry Printout' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Fill Group' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'Fill Group' WHERE strMenuName = N'Fill Group' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Tank Inventory' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'Tank Inventory' WHERE strMenuName = N'Tank Inventory' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Customer List by Route' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'Customer List by Route' WHERE strMenuName = N'Customer List by Route' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Device Actions' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'Device Actions' WHERE strMenuName = N'Device Actions' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Open Call Entries' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'Open Call Entries' WHERE strMenuName = N'Open Call Entries' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Work Order Status' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'Work Order Status' WHERE strMenuName = N'Work Order Status' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Leak Check / Gas Check' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'Leak Check / Gas Check' WHERE strMenuName = N'Leak Check / Gas Check' AND strModuleName = N'Tank Management' AND intParentMenuID = @TankManagementParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Generate Orders' AND strModuleName = 'Tank Management' AND intParentMenuID = @TankManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Generate Orders', N'Tank Management', @TankManagementParentMenuId, N'Generate Orders', N'Activity', N'Screen', N'TankManagement.view.GenerateOrder', N'small-menu-activity', 0, 0, 0, 1, NULL, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'TankManagement.view.GenerateOrder' WHERE strMenuName = 'Generate Orders' AND strModuleName = 'Tank Management' AND intParentMenuID = @TankManagementParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Tank Monitor' AND strModuleName = 'Tank Management' AND intParentMenuID = @TankManagementParentMenuId)
INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
VALUES (N'Tank Monitor', N'Tank Management', @TankManagementParentMenuId, N'Tank Monitor', N'Activity', N'Screen', N'TankManagement.view.ImportWesroc', N'small-menu-activity', 0, 0, 0, 1, NULL, 1)

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Clock Reading History' AND strModuleName = 'Tank Management' AND intParentMenuID = @TankManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Clock Reading History', N'Tank Management', @TankManagementParentMenuId, N'Clock Reading History', N'Maintenance', N'Screen', N'TankManagement.view.ClockReadingHistory', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'TankManagement.view.ClockReadingHistory' WHERE strMenuName = 'Clock Reading History' AND strModuleName = 'Tank Management' AND intParentMenuID = @TankManagementParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'On Hold Detail' AND strModuleName = 'Tank Management' AND intParentMenuID = @TankManagementParentMenuId)
INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
VALUES (N'On Hold Detail', N'Tank Management', @TankManagementParentMenuId, N'On Hold Detail', N'Report', N'Report', N'On Hold Detail', N'small-menu-report', 0, 0, 0, 1, NULL, 1)

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Device Lease Detail' AND strModuleName = 'Tank Management' AND intParentMenuID = @TankManagementParentMenuId)
INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
VALUES (N'Device Lease Detail', N'Tank Management', @TankManagementParentMenuId, N'Device Lease Detail', N'Report', N'Report', N'Device Lease Detail', N'small-menu-report', 0, 0, 0, 1, 0, 1)

/* CASH MANAGEMENT */
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Cash Management' AND strModuleName = 'Cash Management' AND intParentMenuID = 0)
UPDATE tblSMMasterMenu SET intSort = 6 WHERE strMenuName = 'Cash Management' AND strModuleName = 'Cash Management' AND intParentMenuID = 0

DECLARE @CashManagementParentMenuId INT
SELECT @CashManagementParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Cash Management' AND strModuleName = 'Cash Management' AND intParentMenuID = 0

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Bank Deposits' AND strModuleName = N'Cash Management' AND intParentMenuID = @CashManagementParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'CashManagement.view.BankDeposit' WHERE strMenuName = N'Bank Deposits' AND strModuleName = N'Cash Management' AND intParentMenuID = @CashManagementParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Bank Transactions' AND strModuleName = N'Cash Management' AND intParentMenuID = @CashManagementParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'CashManagement.view.BankTransactions' WHERE strMenuName = N'Bank Transactions' AND strModuleName = N'Cash Management' AND intParentMenuID = @CashManagementParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Bank Transfers' AND strModuleName = N'Cash Management' AND intParentMenuID = @CashManagementParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'CashManagement.view.BankTransfer' WHERE strMenuName = N'Bank Transfers' AND strModuleName = N'Cash Management' AND intParentMenuID = @CashManagementParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Miscellaneous Checks' AND strModuleName = N'Cash Management' AND intParentMenuID = @CashManagementParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'CashManagement.view.MiscellaneousChecks' WHERE strMenuName = N'Miscellaneous Checks' AND strModuleName = N'Cash Management' AND intParentMenuID = @CashManagementParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Bank Account Register' AND strModuleName = N'Cash Management' AND intParentMenuID = @CashManagementParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'CashManagement.view.BankAccountRegister' WHERE strMenuName = N'Bank Account Register' AND strModuleName = N'Cash Management' AND intParentMenuID = @CashManagementParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Bank Reconciliation' AND strModuleName = N'Cash Management' AND intParentMenuID = @CashManagementParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'CashManagement.view.BankReconciliation' WHERE strMenuName = N'Bank Reconciliation' AND strModuleName = N'Cash Management' AND intParentMenuID = @CashManagementParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Banks' AND strModuleName = N'Cash Management' AND intParentMenuID = @CashManagementParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'CashManagement.view.Banks' WHERE strMenuName = N'Banks' AND strModuleName = N'Cash Management' AND intParentMenuID = @CashManagementParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Bank Accounts' AND strModuleName = N'Cash Management' AND intParentMenuID = @CashManagementParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'CashManagement.view.BankAccounts' WHERE strMenuName = N'Bank Accounts' AND strModuleName = N'Cash Management' AND intParentMenuID = @CashManagementParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Bank File Formats' AND strModuleName = N'Cash Management' AND intParentMenuID = @CashManagementParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'CashManagement.view.BankFileFormat' WHERE strMenuName = N'Bank File Formats' AND strModuleName = N'Cash Management' AND intParentMenuID = @CashManagementParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Check Register' AND strModuleName = 'Cash Management' AND intParentMenuID = @CashManagementParentMenuId)
INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
VALUES (N'Check Register', N'Cash Management', @CashManagementParentMenuId, N'Check Register', N'Report', N'Report', N'Check Register', N'small-menu-report', 0, 0, 0, 1, NULL, 1)

/* ACCOUNTS PAYABLE */
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Purchasing' AND strModuleName = 'Accounts Payable' AND intParentMenuID = 0)
UPDATE tblSMMasterMenu SET intSort = 9 WHERE strMenuName = 'Purchasing' AND strModuleName = 'Accounts Payable' AND intParentMenuID = 0

DECLARE @AccountsPayableParentMenuId INT
SELECT @AccountsPayableParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Purchasing' AND strModuleName = 'Accounts Payable' AND intParentMenuID = 0

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Pay Bill Detail' AND strModuleName = N'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'AccountsPayable.view.PayBillsDetail' WHERE strMenuName = N'Pay Bill Detail' AND strModuleName = N'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Pay Bills' AND strModuleName = N'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'AccountsPayable.view.PayBills' WHERE strMenuName = N'Pay Bills' AND strModuleName = N'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Bill Batch Entry' AND strModuleName = N'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'AccountsPayable.view.BillBatch' WHERE strMenuName = N'Bill Batch Entry' AND strModuleName = N'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Batch Posting' AND strModuleName = N'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'AccountsPayable.view.BatchPosting' WHERE strMenuName = N'Batch Posting' AND strModuleName = N'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Print Checks' AND strModuleName = N'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'AccountsPayable.controller.PrintChecks' WHERE strMenuName = N'Print Checks' AND strModuleName = N'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Import Bills from Origin' AND strModuleName = N'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'AccountsPayable.view.ImportAPInvoice' WHERE strMenuName = N'Import Bills from Origin' AND strModuleName = N'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Vendors' AND strModuleName = N'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'EntityManagement.view.Entity:searchEntityVendor' WHERE strMenuName = N'Vendors' AND strModuleName = N'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Open Payables' AND strModuleName = N'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'Open Payables' WHERE strMenuName = N'Open Payables' AND strModuleName = N'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Vendor History' AND strModuleName = N'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'Vendor History' WHERE strMenuName = N'Vendor History' AND strModuleName = N'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Cash Requirements' AND strModuleName = N'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'Cash Requirements' WHERE strMenuName = N'Cash Requirements' AND strModuleName = N'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Check Register' AND strModuleName = N'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'Check Register' WHERE strMenuName = N'Check Register' AND strModuleName = N'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'AP Transactions by GL Account' AND strModuleName = N'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'AP Transactions by GL Account' WHERE strMenuName = N'AP Transactions by GL Account' AND strModuleName = N'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId


IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Purchase Order' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Purchase Order', N'Accounts Payable', @AccountsPayableParentMenuId, N'', N'Activity', N'Screen', N'AccountsPayable.view.PurchaseOrder', N'small-menu-activity', 1, 0, 0, 1, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'AccountsPayable.view.PurchaseOrder', intSort = 0 WHERE strMenuName = 'Purchase Order' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Bill Batch Entry' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = 'AccountsPayable.view.BillBatch', intSort = 1 WHERE strMenuName = 'Bill Batch Entry' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId

--Rename Bill Entry to Bills
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Bill Entry' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId)	
UPDATE tblSMMasterMenu SET strMenuName = 'Bills', strDescription = 'Bills' WHERE strMenuName = 'Bill Entry' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Bills' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Bills', N'Accounts Payable', @AccountsPayableParentMenuId, N'Bills', N'Activity', N'Screen', N'AccountsPayable.view.Bill', N'small-menu-activity', 0, 0, 0, 1, 2, 1)
ELSE
	UPDATE tblSMMasterMenu SET strMenuName = 'Bills', strCommand = 'AccountsPayable.view.Bill', intSort = 2 WHERE strMenuName = 'Bills' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId
       
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Import Bills from Origin' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = 'AccountsPayable.view.ImportAPInvoice', intSort = 3 WHERE strMenuName = 'Import Bills from Origin' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Recurring Transactions' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Recurring Transactions', N'Accounts Payable', @AccountsPayableParentMenuId, N'', N'Activity', N'Screen', N'AccountsPayable.view.RecurringTransaction', N'small-menu-activity', 1, 0, 0, 1, 4, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'AccountsPayable.view.RecurringTransaction', intSort = 4 WHERE strMenuName = 'Recurring Transactions' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Batch Posting' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId) 
UPDATE tblSMMasterMenu SET strCommand = 'AccountsPayable.view.BatchPosting', intSort = 5 WHERE strMenuName = 'Batch Posting' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Pay Bills' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = 'AccountsPayable.view.PayBills', intSort = 6 WHERE strMenuName = 'Pay Bills' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Pay Bill Detail' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = 'AccountsPayable.view.PayBillsDetail', intSort = 7 WHERE strMenuName = 'Pay Bill Detail' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Print Checks' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = 'AccountsPayable.controller.PrintChecks', intSort = 8 WHERE strMenuName = 'Print Checks' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Paid Bills History' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Paid Bills History', N'Accounts Payable', @AccountsPayableParentMenuId, N'Shows all the payments', N'Activity', N'Screen', N'AccountsPayable.view.PaidBillsHistory', N'small-menu-activity', 1, 0, 0, 1, 9, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'AccountsPayable.view.PaidBillsHistory', intSort = 9 WHERE strMenuName = 'Paid Bills History' AND strModuleName = 'Accounts Payable' AND intParentMenuID = @AccountsPayableParentMenuId

/* ACCOUNTS RECEIVABLE */
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Sales' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = 0)
UPDATE tblSMMasterMenu SET intSort = 10 WHERE strMenuName = 'Sales' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = 0

DECLARE @AccountsReceivableParentMenuId INT
SELECT @AccountsReceivableParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Sales' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = 0

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Customers' AND strModuleName = N'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'EntityManagement.view.Entity:searchEntityCustomer' WHERE strMenuName = N'Customers' AND strModuleName = N'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Customer Contact List' AND strModuleName = N'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'AccountsReceivable.view.CustomerContactList' WHERE strMenuName = N'Customer Contact List' AND strModuleName = N'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Salesperson' AND strModuleName = N'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'EntityManagement.view.Entity:searchEntitySalesperson' WHERE strMenuName = N'Salesperson' AND strModuleName = N'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Market Zone' AND strModuleName = N'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'AccountsReceivable.view.MarketZone' WHERE strMenuName = N'Market Zone' AND strModuleName = N'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Statement Footer Message' AND strModuleName = N'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'AccountsReceivable.view.StatementFooterMessage' WHERE strMenuName = N'Statement Footer Message' AND strModuleName = N'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Service Charge' AND strModuleName = N'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'AccountsReceivable.view.ServiceCharge' WHERE strMenuName = N'Service Charge' AND strModuleName = N'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Customer Group' AND strModuleName = N'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'AccountsReceivable.view.CustomerGroup' WHERE strMenuName = N'Customer Group' AND strModuleName = N'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Sales Order' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Sales Order', N'Accounts Receivable', @AccountsReceivableParentMenuId, N'Sales Order', N'Activity', N'Screen', N'AccountsReceivable.view.SalesOrder', N'small-menu-activity', 1, 0, 0, 1, 1, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'AccountsReceivable.view.SalesOrder' WHERE strMenuName = 'Sales Order' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Invoice' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Invoice', N'Accounts Receivable', @AccountsReceivableParentMenuId, N'Invoice', N'Activity', N'Screen', N'AccountsReceivable.view.Invoice', N'small-menu-activity', 1, 0, 0, 1, 2, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = N'AccountsReceivable.view.Invoice' WHERE strMenuName = 'Invoice' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Import Invoices from Origin' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Import Invoices from Origin', N'Accounts Receivable', @AccountsReceivableParentMenuId, N'Import Invoices from Origin', N'Activity', N'Screen', N'AccountsReceivable.view.ImportInvoices', N'small-menu-activity', 1, 0, 0, 1, 3, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'AccountsReceivable.view.ImportInvoices' WHERE strMenuName = 'Import Invoices from Origin' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Import Billable from Help Desk' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Import Billable from Help Desk', N'Accounts Receivable', @AccountsReceivableParentMenuId, N'Import Billable from Help Desk', N'Activity', N'Screen', N'AccountsReceivable.view.ImportBillable', N'small-menu-activity', 1, 0, 0, 1, 4, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'AccountsReceivable.view.ImportBillable' WHERE strMenuName = 'Import Billable from Help Desk' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Credit Memo' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Credit Memo', N'Accounts Receivable', @AccountsReceivableParentMenuId, N'Credit Memo', N'Activity', N'Screen', N'AccountsReceivable.view.CreditMemo', N'small-menu-activity', 1, 0, 0, 1, 5, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'AccountsReceivable.view.CreditMemo' WHERE strMenuName = 'Credit Memo' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Receive Payments' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Receive Payments', N'Accounts Receivable', @AccountsReceivableParentMenuId, N'Receive Payments', N'Activity', N'Screen', N'AccountsReceivable.view.ReceivePayments', N'small-menu-activity', 1, 0, 0, 1, 6, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'AccountsReceivable.view.ReceivePayments' WHERE strMenuName = 'Receive Payments' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Receive Payment Detail' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Receive Payment Detail', N'Accounts Receivable', @AccountsReceivableParentMenuId, N'Receive Payment Detail', N'Activity', N'Screen', N'AccountsReceivable.view.ReceivePaymentsDetail', N'small-menu-activity', 1, 0, 0, 1, 7, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'AccountsReceivable.view.ReceivePaymentsDetail' WHERE strMenuName = 'Receive Payment Detail' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Batch Posting' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Batch Posting', N'Accounts Receivable', @AccountsReceivableParentMenuId, N'Batch Posting', N'Activity', N'Screen', N'AccountsReceivable.view.BatchPosting', N'small-menu-activity', 1, 0, 0, 1, 8, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'AccountsReceivable.view.BatchPosting' WHERE strMenuName = 'Batch Posting' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Account Status Codes' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Account Status Codes', N'Accounts Receivable', @AccountsReceivableParentMenuId, N'Account Status Codes', N'Maintenance', N'Screen', N'AccountsReceivable.view.AccountStatusCodes', N'small-menu-maintenance', 1, 0, 0, 1, NULL, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'AccountsReceivable.view.AccountStatusCodes' WHERE strMenuName = 'Account Status Codes' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Customer Contact List' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'EntityManagement.controller.CustomerContactList' WHERE strMenuName = 'Customer Contact List' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @AccountsReceivableParentMenuId

/* HELP DESK */
IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Help Desk' AND strModuleName = 'Help Desk' AND intParentMenuID = 0)
UPDATE tblSMMasterMenu SET intSort = 22 WHERE strMenuName = 'Help Desk' AND strModuleName = 'Help Desk' AND intParentMenuID = 0

DECLARE @HelpDeskParentMenuId INT
SELECT @HelpDeskParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Help Desk' AND strModuleName = 'Help Desk' AND intParentMenuID = 0

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Tickets' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'HelpDesk.controller.Ticket' WHERE strMenuName = N'Tickets' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Open Tickets' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'HelpDesk.controller.OpenTicket' WHERE strMenuName = N'Open Tickets' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Tickets Assigned to Me' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'HelpDesk.controller.TicketAssigned' WHERE strMenuName = N'Tickets Assigned to Me' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Create Ticket' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'HelpDesk.controller.CreateTicket' WHERE strMenuName = N'Create Ticket' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Ticket Groups' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'HelpDesk.view.TicketGroup' WHERE strMenuName = N'Ticket Groups' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Ticket Types' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'HelpDesk.view.TicketType' WHERE strMenuName = N'Ticket Types' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Ticket Statuses' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'HelpDesk.view.TicketStatus' WHERE strMenuName = N'Ticket Statuses' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Ticket Priorities' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'HelpDesk.view.TicketPriority' WHERE strMenuName = N'Ticket Priorities' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Ticket Job Codes' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'HelpDesk.view.TicketJobCode' WHERE strMenuName = N'Ticket Job Codes' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Products' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'HelpDesk.view.Product' WHERE strMenuName = N'Products' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Help Desk Settings' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'HelpDesk.view.HelpDeskSettings' WHERE strMenuName = N'Help Desk Settings' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskParentMenuId

IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = N'Email Setup' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskParentMenuId)
UPDATE tblSMMasterMenu SET strCommand = N'HelpDesk.view.HelpDeskEmailSetup' WHERE strMenuName = N'Email Setup' AND strModuleName = N'Help Desk' AND intParentMenuID = @HelpDeskParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Tickets Reported by Me' AND strModuleName = 'Help Desk' AND intParentMenuID = @HelpDeskParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Tickets Reported by Me', N'Help Desk', @HelpDeskParentMenuId, N'Tickets Reported by Me', N'Activity', N'Screen', N'HelpDesk.controller.TicketsReported', N'small-menu-activity', 0, 0, 0, 1, 5, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'HelpDesk.controller.TicketsReported' WHERE strMenuName = 'Tickets Reported by Me' AND strModuleName = 'Help Desk' AND intParentMenuID = @HelpDeskParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Export Hours Worked' AND strModuleName = 'Help Desk' AND intParentMenuID = @HelpDeskParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Export Hours Worked', N'Help Desk', @HelpDeskParentMenuId, N'Export Hours Worked', N'Activity', N'Screen', N'HelpDesk.view.ExportHoursWorked', N'small-menu-activity', 0, 0, 0, 1, 6, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'HelpDesk.view.ExportHoursWorked' WHERE strMenuName = 'Export Hours Worked' AND strModuleName = 'Help Desk' AND intParentMenuID = @HelpDeskParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Project Lists' AND strModuleName = 'Help Desk' AND intParentMenuID = @HelpDeskParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Project Lists', N'Help Desk', @HelpDeskParentMenuId, N'Project Lists', N'Activity', N'Screen', N'HelpDesk.view.ProjectList', N'small-menu-activity', 0, 0, 0, 1, 7, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'HelpDesk.view.ProjectList' WHERE strMenuName = 'Project Lists' AND strModuleName = 'Help Desk' AND intParentMenuID = @HelpDeskParentMenuId
	
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Projects' AND strModuleName = 'Help Desk' AND intParentMenuID = @HelpDeskParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Projects', N'Help Desk', @HelpDeskParentMenuId, N'Help Desk Projects', N'Maintenance', N'Screen', N'HelpDesk.view.Project', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'HelpDesk.view.Project' WHERE strMenuName = 'Projects' AND strModuleName = 'Help Desk' AND intParentMenuID = @HelpDeskParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Milestones' AND strModuleName = 'Help Desk' AND intParentMenuID = @HelpDeskParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Milestones', N'Help Desk', @HelpDeskParentMenuId, N'Milestones', N'Maintenance', N'Screen', N'HelpDesk.view.Milestone', N'small-menu-maintenance', 0, 0, 0, 1, NULL, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'HelpDesk.view.Milestone' WHERE strMenuName = 'Milestones' AND strModuleName = 'Help Desk' AND intParentMenuID = @HelpDeskParentMenuId

/* INVENTORY */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Inventory' AND strModuleName = 'Inventory' AND intParentMenuID = 0)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Inventory', N'Inventory', 0, N'Inventory', NULL, N'Folder', N'', N'small-folder', 1, 1, 0, 0, 8, 0)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 8 WHERE strMenuName = 'Inventory' AND strModuleName = 'Inventory' AND intParentMenuID = 0

DECLARE @InventoryParentMenuId INT
SELECT @InventoryParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Inventory' AND strModuleName = 'Inventory' AND intParentMenuID = 0

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Inventory Receipt' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Inventory Receipt', N'Inventory', @InventoryParentMenuId, N'Receipts', N'Activity', N'Screen', N'Inventory.view.InventoryReceipt', N'small-menu-activity', 1, 1, 0, 1, 1, 0)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Inventory.view.InventoryReceipt' WHERE strMenuName = 'Inventory Receipt' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Inventory Shipment' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Inventory Shipment', N'Inventory', @InventoryParentMenuId, N'Inventory Shipment', N'Activity', N'Screen', N'Inventory.view.InventoryShipment', N'small-menu-activity', 1, 1, 0, 1, 2, 0)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Inventory.view.InventoryShipment' WHERE strMenuName = 'Inventory Shipment' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Inventory Transfer' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Inventory Transfer', N'Inventory', @InventoryParentMenuId, N'Inventory Transfer', N'Activity', N'Screen', N'Inventory.view.InventoryTransfer', N'small-menu-activity', 1, 1, 0, 1, 3, 0)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Inventory.view.InventoryTransfer' WHERE strMenuName = 'Inventory Transfer' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Inventory Adjustment' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Inventory Adjustment', N'Inventory', @InventoryParentMenuId, N'Inventory Adjustment', N'Activity', N'Screen', N'Inventory.view.InventoryAdjustment', N'small-menu-activity', 1, 1, 0, 1, 4, 0)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Inventory.view.InventoryAdjustment' WHERE strMenuName = 'Inventory Adjustment' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Build Assembly' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Build Assembly', N'Inventory', @InventoryParentMenuId, N'Build Assembly', N'Activity', N'Screen', N'Inventory.view.BuildAssemblyBlend', N'small-menu-activity', 1, 1, 0, 1, 6, 0)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Inventory.view.BuildAssemblyBlend' WHERE strMenuName = 'Build Assembly' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Item' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Item', N'Inventory', @InventoryParentMenuId, N'Item', N'Maintenance', N'Screen', N'Inventory.view.Item', N'small-menu-maintenance', 1, 1, 0, 1, 1, 0)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Inventory.view.Item' WHERE strMenuName = 'Item' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Fuel Category' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Fuel Category', N'Inventory', @InventoryParentMenuId, N'Fuel Category', N'Maintenance', N'Screen', N'Inventory.view.FuelCategory', N'small-menu-maintenance', 1, 1, 0, 1, 1, 0)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Inventory.view.FuelCategory' WHERE strMenuName = 'Fuel Category' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Commodity' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Commodity', N'Inventory', @InventoryParentMenuId, N'Commodity', N'Maintenance', N'Screen', N'Inventory.view.Commodity', N'small-menu-maintenance', 1, 1, 0, 1, 2, 0)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Inventory.view.Commodity' WHERE strMenuName = 'Commodity' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Fuel Code' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Fuel Code', N'Inventory', @InventoryParentMenuId, N'Fuel Code', N'Maintenance', N'Screen', N'Inventory.view.FuelCode', N'small-menu-maintenance', 1, 1, 0, 1, 2, 0)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Inventory.view.FuelCode' WHERE strMenuName = 'Fuel Code' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Category' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Category', N'Inventory', @InventoryParentMenuId, N'Category', N'Maintenance', N'Screen', N'Inventory.view.Category', N'small-menu-maintenance', 1, 1, 0, 1, 3, 0)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Inventory.view.Category' WHERE strMenuName = 'Category' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Production Process' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Production Process', N'Inventory', @InventoryParentMenuId, N'Production Process', N'Maintenance', N'Screen', N'Inventory.view.ProcessCode', N'small-menu-maintenance', 1, 1, 0, 1, 3, 0)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Inventory.view.ProcessCode' WHERE strMenuName = 'Production Process' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Feed Stock' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Feed Stock', N'Inventory', @InventoryParentMenuId, N'Feed Stock', N'Maintenance', N'Screen', N'Inventory.view.FeedStockCode', N'small-menu-maintenance', 1, 1, 0, 1, 4, 0)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Inventory.view.FeedStockCode' WHERE strMenuName = 'Feed Stock' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Feed Stock UOM' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Feed Stock UOM', N'Inventory', @InventoryParentMenuId, N'Feed Stock UOM', N'Maintenance', N'Screen', N'Inventory.view.FeedStockUom', N'small-menu-maintenance', 1, 1, 0, 1, 5, 0)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Inventory.view.FeedStockUom' WHERE strMenuName = 'Feed Stock UOM' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Fuel Type' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Fuel Type', N'Inventory', @InventoryParentMenuId, N'Fuel Type', N'Maintenance', N'Screen', N'Inventory.view.FuelType', N'small-menu-maintenance', 1, 1, 0, 1, 6, 0)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Inventory.view.FuelType' WHERE strMenuName = 'Fuel Type' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Fuel Tax Class' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Fuel Tax Class', N'Inventory', @InventoryParentMenuId, N'Fuel Tax Class', N'Maintenance', N'Screen', N'Inventory.view.FuelTaxClass', N'small-menu-maintenance', 1, 1, 0, 1, 6, 0)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Inventory.view.FuelTaxClass' WHERE strMenuName = 'Fuel Tax Class' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Inventory Tag' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Inventory Tag', N'Inventory', @InventoryParentMenuId, N'Inventory Tag', N'Maintenance', N'Screen', N'Inventory.view.InventoryTag', N'small-menu-maintenance', 1, 1, 0, 1, 7, 0)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Inventory.view.InventoryTag' WHERE strMenuName = 'Inventory Tag' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Patronage Category' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Patronage Category', N'Inventory', @InventoryParentMenuId, N'Patronage Category', N'Maintenance', N'Screen', N'Inventory.view.PatronageCategory', N'small-menu-maintenance', 1, 1, 0, 1, 8, 0)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Inventory.view.PatronageCategory' WHERE strMenuName = 'Patronage Category' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Manufacturer' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Manufacturer', N'Inventory', @InventoryParentMenuId, N'Manufacturer', N'Maintenance', N'Screen', N'Inventory.view.Manufacturer', N'small-menu-maintenance', 1, 1, 0, 1, 9, 0)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Inventory.view.Manufacturer' WHERE strMenuName = 'Manufacturer' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Inventory UOM' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Inventory UOM', N'Inventory', @InventoryParentMenuId, N'Inventory UOM', N'Maintenance', N'Screen', N'Inventory.view.InventoryUOM', N'small-menu-maintenance', 1, 1, 0, 1, 10, 0)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Inventory.view.InventoryUOM' WHERE strMenuName = 'Inventory UOM' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Reasons' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Reasons', N'Inventory', @InventoryParentMenuId, N'Reasons', N'Maintenance', N'Screen', N'Inventory.view.ReasonCode', N'small-menu-maintenance', 1, 1, 0, 1, 12, 0)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Inventory.view.ReasonCode' WHERE strMenuName = 'Reasons' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Storage Unit Type' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Storage Unit Type', N'Inventory', @InventoryParentMenuId, N'Storage Unit Type', N'Maintenance', N'Screen', N'Inventory.view.FactoryUnitType', N'small-menu-maintenance', 1, 1, 0, 1, 13, 0)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Inventory.view.FactoryUnitType' WHERE strMenuName = 'Storage Unit Type' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Storage Location' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Storage Location', N'Inventory', @InventoryParentMenuId, N'Storage Location', N'Maintenance', N'Screen', N'Inventory.view.StorageUnit', N'small-menu-maintenance', 1, 1, 0, 1, 14, 0)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Inventory.view.StorageUnit' WHERE strMenuName = 'Storage Location' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Item Substitution' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Item Substitution', N'Inventory', @InventoryParentMenuId, N'Item Substitution', N'Maintenance', N'Screen', N'Inventory.view.ItemSubstitution', N'small-menu-maintenance', 1, 1, 0, 1, 15, 0)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Inventory.view.ItemSubstitution' WHERE strMenuName = 'Item Substitution' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Certification Programs' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Certification Programs', N'Inventory', @InventoryParentMenuId, N'Certification Programs', N'Maintenance', N'Screen', N'Inventory.view.CertificationProgram', N'small-menu-maintenance', 1, 1, 0, 1, 16, 0)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Inventory.view.CertificationProgram' WHERE strMenuName = 'Certification Programs' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Contract Document' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Contract Document', N'Inventory', @InventoryParentMenuId, N'Contract Document', N'Maintenance', N'Screen', N'Inventory.view.ContractDocument', N'small-menu-maintenance', 1, 1, 0, 1, 17, 0)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Inventory.view.ContractDocument' WHERE strMenuName = 'Contract Document' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Lot Status' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Lot Status', N'Inventory', @InventoryParentMenuId, N'Lot Status', N'Maintenance', N'Screen', N'Inventory.view.LotStatus', N'small-menu-maintenance', 1, 1, 0, 1, 18, 0)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Inventory.view.LotStatus' WHERE strMenuName = 'Lot Status' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Sample Type' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Sample Type', N'Inventory', @InventoryParentMenuId, N'Sample Type', N'Maintenance', N'Screen', N'Inventory.view.SampleType', N'small-menu-maintenance', 1, 1, 0, 1, 19, 0)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Inventory.view.SampleType' WHERE strMenuName = 'Sample Type' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Brand' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Brand', N'Inventory', @InventoryParentMenuId, N'Brand', N'Maintenance', N'Screen', N'Inventory.view.Brand', N'small-menu-maintenance', 1, 1, 0, 1, 20, 0)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Inventory.view.Brand' WHERE strMenuName = 'Brand' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Inventory Count Group' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Inventory Count Group', N'Inventory', @InventoryParentMenuId, N'Inventory Count Group', N'Maintenance', N'Screen', N'Inventory.view.CountGroup', N'small-menu-maintenance', 1, 1, 0, 1, 21, 0)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Inventory.view.CountGroup' WHERE strMenuName = 'Inventory Count Group' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Line of Business' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Line of Business', N'Inventory', @InventoryParentMenuId, N'Line of Business', N'Maintenance', N'Screen', N'Inventory.view.LineOfBusiness', N'small-menu-maintenance', 1, 1, 0, 1, 22, 0)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Inventory.view.LineOfBusiness' WHERE strMenuName = 'Line of Business' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Stock Report' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Stock Report', N'Inventory', @InventoryParentMenuId, N'Simple Stock Report', N'Report', N'Report', N'Stock Report', N'small-menu-report', 1, 1, 0, 1, 1, 0)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Stock Report' WHERE strMenuName = 'Stock Report' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryParentMenuId

/* PAYROLL */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Payroll' AND strModuleName = 'Payroll' AND intParentMenuID = 0)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Payroll', N'Payroll', 0, N'Payroll', NULL, N'Folder', N'', N'small-folder', 1, 1, 0, 0, 11, 0)
ELSE
	UPDATE tblSMMasterMenu SET  intSort = 11 WHERE strMenuName = 'Payroll' AND strModuleName = 'Payroll' AND intParentMenuID = 0

DECLARE @PayrollParentMenuId INT
SELECT @PayrollParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Payroll' AND strModuleName = 'Payroll' AND intParentMenuID = 0

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Timecard' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Timecard', N'Payroll', @PayrollParentMenuId, N'Timecard', N'Activity', N'Screen', N'Payroll.view.Timecard', N'small-menu-activity', 1, 1, 0, 1, 1, 0)
ELSE 
	UPDATE tblSMMasterMenu SET  intSort = 1, strCommand = N'Payroll.view.Timecard' WHERE strMenuName = 'Timecard' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Time Approval' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Time Approval', N'Payroll', @PayrollParentMenuId, N'Time Approval', N'Activity', N'Screen', N'Payroll.view.TimeApproval', N'small-menu-activity', 1, 1, 0, 1, 2, 0)
ELSE 
	UPDATE tblSMMasterMenu SET  intSort = 2, strCommand = N'Payroll.view.TimeApproval' WHERE strMenuName = 'Time Approval' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Paychecks' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Paychecks', N'Payroll', @PayrollParentMenuId, N'Paychecks', N'Activity', N'Screen', N'Payroll.view.Paycheck', N'small-menu-activity', 1, 1, 0, 1, 3, 0)
ELSE 
	UPDATE tblSMMasterMenu SET  intSort = 1, strCommand = N'Payroll.view.Paycheck' WHERE strMenuName = 'Paychecks' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Paycheck Calculator' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Paycheck Calculator', N'Payroll', @PayrollParentMenuId, N'Paycheck Calculator', N'Activity', N'Screen', N'Payroll.view.PaycheckCalculator', N'small-menu-activity', 1, 1, 0, 1, 4, 0)
ELSE 
	UPDATE tblSMMasterMenu SET  intSort = 2, strCommand = N'Payroll.view.PaycheckCalculator' WHERE strMenuName = 'Paycheck Calculator' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Tax Types' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Tax Types', N'Payroll', @PayrollParentMenuId, N'Tax Types', N'Maintenance', N'Screen', N'Payroll.view.TaxType', N'small-menu-maintenance', 1, 1, 0, 1, 1, 0)
ELSE 
	UPDATE tblSMMasterMenu SET  intSort = 1, strCommand = N'Payroll.view.TaxType' WHERE strMenuName = 'Tax Types' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Earning Types' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Earning Types', N'Payroll', @PayrollParentMenuId, N'Earning Types', N'Maintenance', N'Screen', N'Payroll.view.EarningType', N'small-menu-maintenance', 1, 1, 0, 1, 2, 0)
ELSE 
	UPDATE tblSMMasterMenu SET  intSort = 2, strCommand = N'Payroll.view.EarningType' WHERE strMenuName = 'Earning Types' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Deduction Types' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Deduction Types', N'Payroll', @PayrollParentMenuId, N'Deduction Types', N'Maintenance', N'Screen', N'Payroll.view.DeductionType', N'small-menu-maintenance', 1, 1, 0, 1, 3, 0)
ELSE 
	UPDATE tblSMMasterMenu SET  intSort = 3, strCommand = N'Payroll.view.DeductionType' WHERE strMenuName = 'Deduction Types' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Time Off Types' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Time Off Types', N'Payroll', @PayrollParentMenuId, N'Time Off Types', N'Maintenance', N'Screen', N'Payroll.view.TimeOffType', N'small-menu-maintenance', 1, 1, 0, 1, 4, 0)
ELSE 
	UPDATE tblSMMasterMenu SET  intSort = 4, strCommand = N'Payroll.view.TimeOffType' WHERE strMenuName = 'Time Off Types' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollParentMenuId
	
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Employees' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Employees', N'Payroll', @PayrollParentMenuId, N'Employees', N'Maintenance', N'Screen', N'Payroll.view.Employee', N'small-menu-maintenance', 1, 1, 0, 1, 5, 0)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 5, strCommand = N'Payroll.view.Employee' WHERE strMenuName = 'Employees' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Employee Templates' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Employee Templates', N'Payroll', @PayrollParentMenuId, N'Employee Templates', N'Maintenance', N'Screen', N'Payroll.view.EmployeeTemplate', N'small-menu-maintenance', 1, 1, 0, 1, 6, 0)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 6, strCommand = N'Payroll.view.EmployeeTemplate' WHERE strMenuName = 'Employee Templates' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Employee Pay Groups' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Employee Pay Groups', N'Payroll', @PayrollParentMenuId, N'Employee Pay Groups', N'Maintenance', N'Screen', N'Payroll.view.EmployeePayGroup', N'small-menu-maintenance', 1, 1, 0, 1, 7, 0)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 7, strCommand = N'Payroll.view.EmployeePayGroup' WHERE strMenuName = 'Employee Pay Groups' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Workers Compensation Codes' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Workers Compensation Codes', N'Payroll', @PayrollParentMenuId, N'Workers Compensation Codes', N'Maintenance', N'Screen', N'Payroll.view.WorkersCompensationCodes', N'small-menu-maintenance', 1, 1, 0, 1, 8, 0)
ELSE 
	UPDATE tblSMMasterMenu SET intSort = 8, strCommand = N'Payroll.view.WorkersCompensationCodes' WHERE strMenuName = 'Workers Compensation Codes' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollParentMenuId

/* CONTRACT MANAGEMENT */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Contract Management' AND strModuleName = 'Contract Management' AND intParentMenuID = 0)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Contract Management', N'Contract Management', 0, N'Contract Management', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 14, 0)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 14 WHERE strMenuName = 'Contract Management' AND strModuleName = 'Contract Management' AND intParentMenuID = 0

DECLARE @ContractManagementParentMenuId INT
SELECT @ContractManagementParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Contract Management' AND strModuleName = 'Contract Management' AND intParentMenuID = 0

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Contract' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Contract', N'Contract Management', @ContractManagementParentMenuId, N'Contract', N'Activity', N'Screen', N'ContractManagement.view.Contract', N'small-menu-activity', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'ContractManagement.view.Contract' WHERE strMenuName = 'Contract' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Price Contracts' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Price Contracts', N'Contract Management', @ContractManagementParentMenuId, N'Price Contracts', N'Activity', N'Screen', N'ContractManagement.view.PriceContracts', N'small-menu-activity', 0, 0, 0, 1, 1, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'ContractManagement.view.PriceContracts' WHERE strMenuName = 'Price Contracts' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Contract Adjustments' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Contract Adjustments', N'Contract Management', @ContractManagementParentMenuId, N'Contract Adjustments', N'Activity', N'Screen', N'ContractManagement.view.ContractAdjustment', N'small-menu-activity', 0, 0, 0, 1, 2, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'ContractManagement.view.ContractAdjustment' WHERE strMenuName = 'Contract Adjustments' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Roll Contracts' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Roll Contracts', N'Contract Management', @ContractManagementParentMenuId, N'Roll Contracts', N'Activity', N'Screen', N'ContractManagement.view.RollContracts', N'small-menu-activity', 0, 0, 0, 1, 3, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'ContractManagement.view.RollContracts' WHERE strMenuName = 'Roll Contracts' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Contract Options' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Contract Options', N'Contract Management', @ContractManagementParentMenuId, N'Contract Options', N'Maintenance', N'Screen', N'ContractManagement.view.ContractOptions', N'small-menu-maintenance', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'ContractManagement.view.ContractOptions' WHERE strMenuName = 'Contract Options' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Contract Text' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Contract Text', N'Contract Management', @ContractManagementParentMenuId, N'Contract Text', N'Maintenance', N'Screen', N'ContractManagement.view.ContractText', N'small-menu-maintenance', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'ContractManagement.view.ContractText' WHERE strMenuName = 'Contract Text' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Cost Type' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Cost Type', N'Contract Management', @ContractManagementParentMenuId, N'Cost Type', N'Maintenance', N'Screen', N'ContractManagement.view.CostTypeNew', N'small-menu-maintenance', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'ContractManagement.view.CostTypeNew' WHERE strMenuName = 'Cost Type' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Crop Year' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Crop Year', N'Contract Management', @ContractManagementParentMenuId, N'Crop Year', N'Maintenance', N'Screen', N'ContractManagement.view.CropYearNew', N'small-menu-maintenance', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'ContractManagement.view.CropYearNew' WHERE strMenuName = 'Crop Year' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Deferred Payment Rates' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Deferred Payment Rates', N'Contract Management', @ContractManagementParentMenuId, N'Deferred Payment Rates', N'Maintenance', N'Screen', N'ContractManagement.view.DeferredPaymentRates', N'small-menu-maintenance', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'ContractManagement.view.DeferredPaymentRates' WHERE strMenuName = 'Deferred Payment Rates' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Freight Rates' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Freight Rates', N'Contract Management', @ContractManagementParentMenuId, N'Freight Rates', N'Maintenance', N'Screen', N'ContractManagement.view.FreightRateNew', N'small-menu-maintenance', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'ContractManagement.view.FreightRateNew' WHERE strMenuName = 'Freight Rates' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Weight/Grades' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Weight/Grades', N'Contract Management', @ContractManagementParentMenuId, N'Weight/Grades', N'Maintenance', N'Screen', N'ContractManagement.view.WeightGradeNew', N'small-menu-maintenance', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'ContractManagement.view.WeightGradeNew' WHERE strMenuName = 'Weight/Grades' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Associations' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Associations', N'Contract Management', @ContractManagementParentMenuId, N'Associations', N'Maintenance', N'Screen', N'ContractManagement.view.Associations', N'small-menu-maintenance', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'ContractManagement.view.Associations' WHERE strMenuName = 'Associations' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Book' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Book', N'Contract Management', @ContractManagementParentMenuId, N'Book', N'Maintenance', N'Screen', N'ContractManagement.view.Book', N'small-menu-maintenance', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'ContractManagement.view.Book' WHERE strMenuName = 'Book' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementParentMenuId

/* NOTES RECEIVABLE */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Notes Receivable' AND strModuleName = 'Notes Receivable' AND intParentMenuID = 0)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Notes Receivable', N'Notes Receivable', 0, N'Notes Receivable', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 12, 0)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 12 WHERE strMenuName = 'Notes Receivable' AND strModuleName = 'Notes Receivable' AND intParentMenuID = 0

DECLARE @NotesReceivableParentMenuId INT
SELECT @NotesReceivableParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Notes Receivable' AND strModuleName = 'Notes Receivable' AND intParentMenuID = 0

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Note Maintenance' AND strModuleName = 'Notes Receivable' AND intParentMenuID = @NotesReceivableParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Note Maintenance ', N'Notes Receivable', @NotesReceivableParentMenuId, N'Note Maintenance', N'Activity', N'Screen', N'NotesReceivable.view.NotesReceivable', N'small-menu-activity', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'NotesReceivable.view.NotesReceivable' WHERE strMenuName = 'Note Maintenance' AND strModuleName = 'Notes Receivable' AND intParentMenuID = @NotesReceivableParentMenuId

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

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'UCC Tracking' AND strModuleName = 'Notes Receivable' AND intParentMenuID = @NotesReceivableParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'UCC Tracking', N'Notes Receivable', @NotesReceivableParentMenuId, N'UCC Tracking', N'Report', N'Report', N'UCC Tracking', N'small-menu-report', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'UCC Tracking' WHERE strMenuName = 'UCC Tracking' AND strModuleName = 'Notes Receivable' AND intParentMenuID = @NotesReceivableParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Aged Notes Receivable' AND strModuleName = 'Notes Receivable' AND intParentMenuID = @NotesReceivableParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Aged Notes Receivable', N'Notes Receivable', @NotesReceivableParentMenuId, N'Aged Notes Receivable', N'Report', N'Report', N'Aged Notes Receivable', N'small-menu-report', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Aged Notes Receivable' WHERE strMenuName = 'Aged Notes Receivable' AND strModuleName = 'Notes Receivable' AND intParentMenuID = @NotesReceivableParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = '1098' AND strModuleName = 'Notes Receivable' AND intParentMenuID = @NotesReceivableParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'1098', N'Notes Receivable', @NotesReceivableParentMenuId, N'1098', N'Report', N'Report', N'1098', N'small-menu-report', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'1098' WHERE strMenuName = '1098' AND strModuleName = 'Notes Receivable' AND intParentMenuID = @NotesReceivableParentMenuId

/* SCALE INTERFACE */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Scale Interface' AND strModuleName = 'Grain' AND intParentMenuID = 0)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Scale Interface', N'Grain', 0, N'Scale Interface', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 16, 0)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 16 WHERE strMenuName = 'Scale Interface' AND strModuleName = 'Grain' AND intParentMenuID = 0

DECLARE @ScaleInterfaceParentMenuId INT
SELECT @ScaleInterfaceParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Scale Interface' AND strModuleName = 'Grain' AND intParentMenuID = 0

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Scale Ticket' AND strModuleName = 'Grain' AND intParentMenuID = @ScaleInterfaceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Scale Ticket', N'Grain', @ScaleInterfaceParentMenuId, N'Scale', N'Activity', N'Screen', N'Grain.view.ScaleStationSelection', N'small-menu-activity', 0, 0, 0, 1, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'Grain.view.ScaleStationSelection', intSort = 0 WHERE strMenuName = 'Scale Ticket' AND strModuleName = 'Grain' AND intParentMenuID = @ScaleInterfaceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Ticket Pool Maintenance' AND strModuleName = 'Grain' AND intParentMenuID = @ScaleInterfaceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Ticket Pool Maintenance', N'Grain', @ScaleInterfaceParentMenuId, N'Ticket Pool', N'Maintenance', N'Screen', N'Grain.view.TicketPool', N'small-menu-maintenance', 0, 0, 0, 1, 4, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'Grain.view.TicketPool', intSort = 4 WHERE strMenuName = 'Ticket Pool Maintenance' AND strModuleName = 'Grain' AND intParentMenuID = @ScaleInterfaceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Scale Station Settings' AND strModuleName = 'Grain' AND intParentMenuID = @ScaleInterfaceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Scale Station Settings', N'Grain', @ScaleInterfaceParentMenuId, N'Scale Station Settings', N'Maintenance', N'Screen', N'Grain.view.ScaleStationSettings', N'small-menu-maintenance', 0, 0, 0, 1, 5, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'Grain.view.ScaleStationSettings', intSort = 5 WHERE strMenuName = 'Scale Station Settings' AND strModuleName = 'Grain' AND intParentMenuID = @ScaleInterfaceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Storage Types' AND strModuleName = 'Grain' AND intParentMenuID = @ScaleInterfaceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Storage Types', N'Grain', @ScaleInterfaceParentMenuId, N'Storage Type', N'Maintenance', N'Screen', N'Grain.view.StorageType', N'small-menu-maintenance', 0, 0, 0, 1, 0, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'Grain.view.StorageType', intSort = 0 WHERE strMenuName = 'Storage Types' AND strModuleName = 'Grain' AND intParentMenuID = @ScaleInterfaceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Ticket Formats' AND strModuleName = 'Grain' AND intParentMenuID = @ScaleInterfaceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Ticket Formats', N'Grain', @ScaleInterfaceParentMenuId, N'Ticket Format', N'Maintenance', N'Screen', N'Grain.view.TicketFormats', N'small-menu-maintenance', 0, 0, 0, 1, 1, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'Grain.view.TicketFormats', intSort = 1 WHERE strMenuName = 'Ticket Formats' AND strModuleName = 'Grain' AND intParentMenuID = @ScaleInterfaceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Physical Scale Maintenance' AND strModuleName = 'Grain' AND intParentMenuID = @ScaleInterfaceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Physical Scale Maintenance', N'Grain', @ScaleInterfaceParentMenuId, N'Physical Scale', N'Maintenance', N'Screen', N'Grain.view.PhysicalScale', N'small-menu-maintenance', 0, 0, 0, 1, 2, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'Grain.view.PhysicalScale',  intSort = 2 WHERE strMenuName = 'Physical Scale Maintenance' AND strModuleName = 'Grain' AND intParentMenuID = @ScaleInterfaceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Grading Equipment Maintenance' AND strModuleName = 'Grain' AND intParentMenuID = @ScaleInterfaceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Grading Equipment Maintenance', N'Grain', @ScaleInterfaceParentMenuId, N'Grading Equipment', N'Maintenance', N'Screen', N'Grain.view.GradingEquipment', N'small-menu-maintenance', 0, 0, 0, 1, 3, 1)
ELSE
	UPDATE tblSMMasterMenu SET strCommand = 'Grain.view.GradingEquipment', intSort = 3 WHERE strMenuName = 'Grading Equipment Maintenance' AND strModuleName = 'Grain' AND intParentMenuID = @ScaleInterfaceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Scale Activity' AND strModuleName = 'Grain' AND intParentMenuID = @ScaleInterfaceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Scale Activity', N'Grain', @ScaleInterfaceParentMenuId, N'Scale Activity', N'Report', N'Report', N'Scale Activity Report', N'small-menu-report', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Scale Activity Report' WHERE strMenuName = 'Scale Activity' AND strModuleName = 'Grain' AND intParentMenuID = @ScaleInterfaceParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Unsent Tickets' AND strModuleName = 'Grain' AND intParentMenuID = @ScaleInterfaceParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Unsent Tickets', N'Grain', @ScaleInterfaceParentMenuId, N'Unsent Tickets', N'Report', N'Report', N'Unsent Tickets Report', N'small-menu-report', 0, 0, 0, 1, 1, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Unsent Tickets Report' WHERE strMenuName = 'Unsent Tickets' AND strModuleName = 'Grain' AND intParentMenuID = @ScaleInterfaceParentMenuId

/* GRAINS */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Grain' AND strModuleName = 'Grain' AND intParentMenuID = 0)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Grain', N'Grain', 0, N'Grain', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 13, 0)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 13 WHERE strMenuName = 'Grain' AND strModuleName = 'Grain' AND intParentMenuID = 0

DECLARE @GrainParentMenuId INT
SELECT @GrainParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Grain' AND strModuleName = 'Grain' AND intParentMenuID = 0

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Discount Table' AND strModuleName = 'Grain' AND intParentMenuID = @GrainParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Discount Table', N'Grain', @GrainParentMenuId, N'Discount Table', N'Maintenance', N'Screen', N'Grain.view.DiscountTable', N'small-menu-maintenance', 0, 0, 0, 1, 1, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Grain.view.DiscountTable' WHERE strMenuName = 'Discount Table' AND strModuleName = 'Grain' AND intParentMenuID = @GrainParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Discount Schedule' AND strModuleName = 'Grain' AND intParentMenuID = @GrainParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Discount Schedule', N'Grain', @GrainParentMenuId, N'Discount Schedule', N'Maintenance', N'Screen', N'Grain.view.DiscountSchedule', N'small-menu-maintenance', 0, 0, 0, 1, 2, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Grain.view.DiscountSchedule' WHERE strMenuName = 'Discount Schedule' AND strModuleName = 'Grain' AND intParentMenuID = @GrainParentMenuId

/* MANUFACTURING */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Manufacturing' AND strModuleName = 'Manufacturing' AND intParentMenuID = 0)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Manufacturing', N'Manufacturing', 0, N'Manufacturing', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 18, 0)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 18 WHERE strMenuName = 'Manufacturing' AND strModuleName = 'Manufacturing' AND intParentMenuID = 0

DECLARE @ManufacturingParentMenuId INT
SELECT @ManufacturingParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Manufacturing' AND strModuleName = 'Manufacturing' AND intParentMenuID = 0

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Blend Requirement' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Blend Requirement', N'Manufacturing', @ManufacturingParentMenuId, N'Blend Requirement', N'Activity', N'Screen', N'Manufacturing.view.BlendRequirement', N'small-menu-activity', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Manufacturing.view.BlendRequirement' WHERE strMenuName = 'Blend Requirement' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Blend Management' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Blend Management', N'Manufacturing', @ManufacturingParentMenuId, N'Blend Management', N'Activity', N'Screen', N'Manufacturing.view.BlendManagement', N'small-menu-activity', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Manufacturing.view.BlendManagement' WHERE strMenuName = 'Blend Management' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Blend Production' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Blend Production', N'Manufacturing', @ManufacturingParentMenuId, N'Blend Production', N'Activity', N'Screen', N'Manufacturing.view.BlendProduction', N'small-menu-activity', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Manufacturing.view.BlendProduction' WHERE strMenuName = 'Blend Production' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Bag Off' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Bag Off', N'Manufacturing', @ManufacturingParentMenuId, N'Bag Off', N'Activity', N'Screen', N'Manufacturing.view.BagOff', N'small-menu-activity', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Manufacturing.view.BagOff' WHERE strMenuName = 'Bag Off' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Release To Warehouse' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Release To Warehouse', N'Manufacturing', @ManufacturingParentMenuId, N'Release To Warehouse', N'Activity', N'Screen', N'Manufacturing.view.ReleaseToWarehouse', N'small-menu-activity', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Manufacturing.view.ReleaseToWarehouse' WHERE strMenuName = 'Release To Warehouse' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Manufacturing Process' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Manufacturing Process', N'Manufacturing', @ManufacturingParentMenuId, N'Manufacturing Process', N'Maintenance', N'Screen', N'Manufacturing.view.ManufacturingProcess', N'small-menu-maintenance', 0, 0, 0, 1, 1, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Manufacturing.view.ManufacturingProcess' WHERE strMenuName = 'Manufacturing Process' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Recipe' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Recipe', N'Manufacturing', @ManufacturingParentMenuId, N'Recipe', N'Maintenance', N'Screen', N'Manufacturing.view.Recipe', N'small-menu-maintenance', 0, 0, 0, 1, 2, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Manufacturing.view.Recipe' WHERE strMenuName = 'Recipe' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Machine' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Machine', N'Manufacturing', @ManufacturingParentMenuId, N'Machine', N'Maintenance', N'Screen', N'Manufacturing.view.Machine', N'small-menu-maintenance', 0, 0, 0, 1, 2, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Manufacturing.view.Machine' WHERE strMenuName = 'Machine' AND strModuleName = 'Manufacturing' AND intParentMenuID = @ManufacturingParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Manufacturing Cell' AND strModuleName = 'Inventory' AND intParentMenuID = @ManufacturingParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Manufacturing Cell', N'Inventory', @ManufacturingParentMenuId, N'Manufacturing Cell', N'Maintenance', N'Screen', N'Inventory.view.ManufacturingCell', N'small-menu-maintenance', 1, 1, 0, 1, 3, 0)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Inventory.view.ManufacturingCell' WHERE strMenuName = 'Manufacturing Cell' AND strModuleName = 'Inventory' AND intParentMenuID = @ManufacturingParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Pack Type' AND strModuleName = 'Inventory' AND intParentMenuID = @ManufacturingParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Pack Type', N'Inventory', @ManufacturingParentMenuId, N'Pack Type', N'Maintenance', N'Screen', N'Inventory.view.PackType', N'small-menu-maintenance', 1, 1, 0, 1, 4, 0)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Inventory.view.PackType' WHERE strMenuName = 'Pack Type' AND strModuleName = 'Inventory' AND intParentMenuID = @ManufacturingParentMenuId

/* STORE */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Store' AND strModuleName = 'Store' AND intParentMenuID = 0)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Store', N'Store', 0, N'Store', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 21, 0)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 21 WHERE strMenuName = 'Store' AND strModuleName = 'Store' AND intParentMenuID = 0

DECLARE @StoreParentMenuId INT
SELECT @StoreParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Store' AND strModuleName = 'Store' AND intParentMenuID = 0

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Update Item Pricing' AND strModuleName = 'Store' AND intParentMenuID = @StoreParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Update Item Pricing', N'Store', @StoreParentMenuId, N'Update Item Pricing', N'Activity', N'Screen', N'Store.view.UpdateItemPricing', N'small-menu-activity', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Store.view.UpdateItemPricing' WHERE strMenuName = 'Update Item Pricing' AND strModuleName = 'Store' AND intParentMenuID = @StoreParentMenuId


IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Update Rebate/Discount' AND strModuleName = 'Store' AND intParentMenuID = @StoreParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Update Rebate/Discount', N'Store', @StoreParentMenuId, N'Update Rebate/Discount', N'Activity', N'Screen', N'Store.view.UpdateRebateDiscount', N'small-menu-activity', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Store.view.UpdateRebateDiscount' WHERE strMenuName = 'Update Rebate/Discount' AND strModuleName = 'Store' AND intParentMenuID = @StoreParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Update Item Data' AND strModuleName = 'Store' AND intParentMenuID = @StoreParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Update Item Data', N'Store', @StoreParentMenuId, N'Update Item Data', N'Activity', N'Screen', N'Store.view.UpdateItemData', N'small-menu-activity', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Store.view.UpdateItemData' WHERE strMenuName = 'Update Item Data' AND strModuleName = 'Store' AND intParentMenuID = @StoreParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Inventory Mass Maintenance' AND strModuleName = 'Store' AND intParentMenuID = @StoreParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Inventory Mass Maintenance', N'Store', @StoreParentMenuId, N'Inventory Mass Maintenance', N'Activity', N'Screen', N'Store.view.InventoryMassMaintenance', N'small-menu-activity', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Store.view.InventoryMassMaintenance' WHERE strMenuName = 'Inventory Mass Maintenance' AND strModuleName = 'Store' AND intParentMenuID = @StoreParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Copy Promotions' AND strModuleName = 'Store' AND intParentMenuID = @StoreParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Copy Promotions', N'Store', @StoreParentMenuId, N'Copy Promotions', N'Activity', N'Screen', N'Store.view.CopyPromotion', N'small-menu-activity', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Store.view.CopyPromotion' WHERE strMenuName = 'Copy Promotions' AND strModuleName = 'Store' AND intParentMenuID = @StoreParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Purge Promotions' AND strModuleName = 'Store' AND intParentMenuID = @StoreParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Purge Promotions', N'Store', @StoreParentMenuId, N'Purge Promotions', N'Activity', N'Screen', N'Store.view.PurgePromotion', N'small-menu-activity', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Store.view.PurgePromotion' WHERE strMenuName = 'Purge Promotions' AND strModuleName = 'Store' AND intParentMenuID = @StoreParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Store Maintenance' AND strModuleName = 'Store' AND intParentMenuID = @StoreParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Store Maintenance', N'Store', @StoreParentMenuId, N'Store Maintenance', N'Maintenance', N'Screen', N'Store.view.Store', N'small-menu-maintenance', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Store.view.Store' WHERE strMenuName = 'Store Maintenance' AND strModuleName = 'Store' AND intParentMenuID = @StoreParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Register Maintenance' AND strModuleName = 'Store' AND intParentMenuID = @StoreParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Register Maintenance', N'Store', @StoreParentMenuId, N'Register Maintenance', N'Maintenance', N'Screen', N'Store.view.Register', N'small-menu-maintenance', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Store.view.Register' WHERE strMenuName = 'Register Maintenance' AND strModuleName = 'Store' AND intParentMenuID = @StoreParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'SubCategory' AND strModuleName = 'Store' AND intParentMenuID = @StoreParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'SubCategory', N'Store', @StoreParentMenuId, N'SubCategory', N'Maintenance', N'Screen', N'Store.view.SubCategory', N'small-menu-maintenance', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Store.view.SubCategory' WHERE strMenuName = 'SubCategory' AND strModuleName = 'Store' AND intParentMenuID = @StoreParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Promotion ItemList Maintenance' AND strModuleName = 'Store' AND intParentMenuID = @StoreParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Promotion ItemList Maintenance', N'Store', @StoreParentMenuId, N'Promotion ItemList Maintenance', N'Maintenance', N'Screen', N'Store.view.PromotionItemList', N'small-menu-maintenance', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Store.view.PromotionItemList' WHERE strMenuName = 'Promotion ItemList Maintenance' AND strModuleName = 'Store' AND intParentMenuID = @StoreParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Promotion Sales Maintenance' AND strModuleName = 'Store' AND intParentMenuID = @StoreParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Promotion Sales Maintenance', N'Store', @StoreParentMenuId, N'Promotion Sales Maintenance', N'Maintenance', N'Screen', N'Store.view.PromotionSales', N'small-menu-maintenance', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Store.view.PromotionSales' WHERE strMenuName = 'Promotion Sales Maintenance' AND strModuleName = 'Store' AND intParentMenuID = @StoreParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Retail Price Adjustments' AND strModuleName = 'Store' AND intParentMenuID = @StoreParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Retail Price Adjustments', N'Store', @StoreParentMenuId, N'Retail Price Adjustments', N'Maintenance', N'Screen', N'Store.view.RetailPriceAdjustment', N'small-menu-maintenance', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Store.view.RetailPriceAdjustment' WHERE strMenuName = 'Retail Price Adjustments' AND strModuleName = 'Store' AND intParentMenuID = @StoreParentMenuId

/* RISK MANAGEMENT */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Risk Management' AND strModuleName = 'Risk Management' AND intParentMenuID = 0)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Risk Management', N'Risk Management', 0, N'Risk Management', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 15, 2)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 15 WHERE strMenuName = 'Risk Management' AND strModuleName = 'Risk Management' AND intParentMenuID = 0

DECLARE @RiskManagementParentMenuId INT
SELECT @RiskManagementParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Risk Management' AND strModuleName = 'Risk Management' AND intParentMenuID = 0

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Futures Settlement Price' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Futures Settlement Price', N'Risk Management', @RiskManagementParentMenuId, N'Futures Settlement Price', N'Activity', N'Screen', N'RiskManagement.view.FuturesOptionsSettlementPrices', N'small-menu-activity', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'RiskManagement.view.FuturesOptionsSettlementPrices' WHERE strMenuName = 'Futures Settlement Price' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Fut/Opt Transaction' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Fut/Opt Transaction', N'Risk Management', @RiskManagementParentMenuId, N'Fut/Opt Transaction', N'Activity', N'Screen', N'RiskManagement.view.FuturesOptionsTransactions', N'small-menu-activity', 0, 0, 0, 1, 1, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'RiskManagement.view.FuturesOptionsTransactions' WHERE strMenuName = 'Fut/Opt Transaction' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Match Futures Purchase & Sale' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Match Futures Purchase & Sale', N'Risk Management', @RiskManagementParentMenuId, N'Match Futures Purchase & Sale', N'Activity', N'Screen', N'RiskManagement.view.MatchFuturesPurchaseSale', N'small-menu-activity', 0, 0, 0, 1, 2, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'RiskManagement.view.MatchFuturesPurchaseSale' WHERE strMenuName = 'Match Futures Purchase & Sale' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Futures Market' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Futures Market', N'Risk Management', @RiskManagementParentMenuId, N'Futures Market', N'Maintenance', N'Screen', N'RiskManagement.view.FuturesMarket', N'small-menu-maintenance', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'RiskManagement.view.FuturesMarket' WHERE strMenuName = 'Futures Market' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Futures Month' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Futures Month', N'Risk Management', @RiskManagementParentMenuId, N'Futures Month', N'Maintenance', N'Screen', N'RiskManagement.view.FuturesMonth', N'small-menu-maintenance', 0, 0, 0, 1, 1, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'RiskManagement.view.FuturesMonth' WHERE strMenuName = 'Futures Month' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Options Month' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Options Month', N'Risk Management', @RiskManagementParentMenuId, N'Options Month', N'Maintenance', N'Screen', N'RiskManagement.view.OptionsMonth', N'small-menu-maintenance', 0, 0, 0, 1, 2, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'RiskManagement.view.OptionsMonth' WHERE strMenuName = 'Options Month' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Brokerage Account' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Brokerage Account', N'Risk Management', @RiskManagementParentMenuId, N'Brokerage Account', N'Maintenance', N'Screen', N'RiskManagement.view.BrokerageAccount', N'small-menu-maintenance', 0, 0, 0, 1, 3, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'RiskManagement.view.BrokerageAccount' WHERE strMenuName = 'Brokerage Account' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementParentMenuId

/* LOGISTICS */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Logistics' AND strModuleName = 'Logistics' AND intParentMenuID = 0)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Logistics', N'Logistics', 0, N'Logistics', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 17, 2)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 17 WHERE strMenuName = 'Logistics' AND strModuleName = 'Logistics' AND intParentMenuID = 0

DECLARE @LogisticsParentMenuId INT
SELECT @LogisticsParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Logistics' AND strModuleName = 'Logistics' AND intParentMenuID = 0

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Shipping Instructions' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Shipping Instructions', N'Logistics', @LogisticsParentMenuId, N'Shipping Instructions', N'Activity', N'Screen', N'Logistics.view.ShippingInstructions', N'small-menu-activity', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Logistics.view.ShippingInstructions' WHERE strMenuName = 'Shipping Instructions' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Allocations' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Allocations', N'Logistics', @LogisticsParentMenuId, N'Allocations', N'Activity', N'Screen', N'Logistics.view.Allocation', N'small-menu-activity', 0, 0, 0, 1, 1, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Logistics.view.Allocation' WHERE strMenuName = 'Allocations' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Load Schedule' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Load Schedule', N'Logistics', @LogisticsParentMenuId, N'Load Schedule', N'Activity', N'Screen', N'Logistics.view.LoadSchedule', N'small-menu-activity', 0, 0, 0, 1, 2, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Logistics.view.LoadSchedule' WHERE strMenuName = 'Load Schedule' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Generate Loads' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Generate Loads', N'Logistics', @LogisticsParentMenuId, N'Generate Loads', N'Activity', N'Screen', N'Logistics.view.GenerateLoad', N'small-menu-activity', 0, 0, 0, 1, 3, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Logistics.view.GenerateLoad' WHERE strMenuName = 'Generate Loads' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Inbound Shipments' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Inbound Shipments', N'Logistics', @LogisticsParentMenuId, N'Inbound Shipments', N'Activity', N'Screen', N'Logistics.view.InboundShipment', N'small-menu-activity', 0, 0, 0, 1, 4, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Logistics.view.InboundShipment' WHERE strMenuName = 'Inbound Shipments' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Container Type' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Container Type', N'Logistics', @LogisticsParentMenuId, N'Container Type', N'Maintenance', N'Screen', N'Logistics.view.ContainerType', N'small-menu-maintenance', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Logistics.view.ContainerType' WHERE strMenuName = 'Container Type' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Equipment Type' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Equipment Type', N'Logistics', @LogisticsParentMenuId, N'Equipment Type', N'Maintenance', N'Screen', N'Logistics.view.EquipmentType', N'small-menu-maintenance', 0, 0, 0, 1, 1, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Logistics.view.EquipmentType' WHERE strMenuName = 'Equipment Type' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Shipping Line' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Shipping Line', N'Logistics', @LogisticsParentMenuId, N'Shipping Line', N'Maintenance', N'Screen', N'Logistics.view.ShippingLine', N'small-menu-maintenance', 0, 0, 0, 1, 2, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Logistics.view.ShippingLine' WHERE strMenuName = 'Shipping Line' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Forwarding Agent' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Forwarding Agent', N'Logistics', @LogisticsParentMenuId, N'Forwarding Agent', N'Maintenance', N'Screen', N'Logistics.view.ForwardingAgent', N'small-menu-maintenance', 0, 0, 0, 1, 3, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Logistics.view.ForwardingAgent' WHERE strMenuName = 'Forwarding Agent' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Trucker' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Trucker', N'Logistics', @LogisticsParentMenuId, N'Trucker', N'Maintenance', N'Screen', N'Logistics.view.Trucker', N'small-menu-maintenance', 0, 0, 0, 1, 4, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Logistics.view.Trucker' WHERE strMenuName = 'Trucker' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Terminal' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Terminal', N'Logistics', @LogisticsParentMenuId, N'Terminal', N'Maintenance', N'Screen', N'Logistics.view.Terminal', N'small-menu-maintenance', 0, 0, 0, 1, 5, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'Logistics.view.Terminal' WHERE strMenuName = 'Terminal' AND strModuleName = 'Logistics' AND intParentMenuID = @LogisticsParentMenuId

/* CARD FUELING */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Card Fueling' AND strModuleName = 'Card Fueling' AND intParentMenuID = 0)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Card Fueling', N'Card Fueling', 0, N'Card Fueling', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 20, 1)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 20 WHERE strMenuName = 'Card Fueling' AND strModuleName = 'Card Fueling' AND intParentMenuID = 0

DECLARE @CardFuelingParentMenuId INT
SELECT @CardFuelingParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Card Fueling' AND strModuleName = 'Card Fueling' AND intParentMenuID = 0

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Accounts' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Accounts', N'Card Fueling', @CardFuelingParentMenuId, N'Accounts', N'Maintenance', N'Screen', N'CardFueling.view.Account', N'small-menu-maintenance', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'CardFueling.view.Account' WHERE strMenuName = 'Accounts' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Discount Schedule' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Discount Schedule', N'Card Fueling', @CardFuelingParentMenuId, N'Discount Schedule', N'Maintenance', N'Screen', N'CardFueling.view.DiscountSchedule', N'small-menu-maintenance', 0, 0, 0, 1, 1, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'CardFueling.view.DiscountSchedule' WHERE strMenuName = 'Discount Schedule' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Fee Profile' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Fee Profile', N'Card Fueling', @CardFuelingParentMenuId, N'Fee Profile', N'Maintenance', N'Screen', N'CardFueling.view.FeeProfile', N'small-menu-maintenance', 0, 0, 0, 1, 2, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'CardFueling.view.FeeProfile' WHERE strMenuName = 'Fee Profile' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Network' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId])
	VALUES (N'Network', N'Card Fueling', @CardFuelingParentMenuId, N'Network', N'Maintenance', N'Screen', N'CardFueling.view.Network', N'small-menu-maintenance', 0, 0, 0, 1, 3, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'CardFueling.view.Network' WHERE strMenuName = 'Network' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Price Profile' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Price Profile', N'Card Fueling', @CardFuelingParentMenuId, N'Price Profile', N'Maintenance', N'Screen', N'CardFueling.view.PriceProfile', N'small-menu-maintenance', 0, 0, 0, 1, 4, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'CardFueling.view.PriceProfile' WHERE strMenuName = 'Price Profile' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Sites' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Sites', N'Card Fueling', @CardFuelingParentMenuId, N'Sites', N'Maintenance', N'Screen', N'CardFueling.view.Site', N'small-menu-maintenance', 0, 0, 0, 1, 5, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'CardFueling.view.Site' WHERE strMenuName = 'Sites' AND strModuleName = 'Card Fueling' AND intParentMenuID = @CardFuelingParentMenuId

/* CREDIT CARD RECONCILIATION */
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Credit Card Reconciliation' AND strModuleName = 'Credit Card Recon' AND intParentMenuID = 0)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Credit Card Reconciliation', N'Credit Card Recon', 0, N'Credit Card Reconciliation', NULL, N'Folder', N'', N'small-folder', 1, 0, 0, 0, 7, 0)
ELSE
	UPDATE tblSMMasterMenu SET intSort = 7 WHERE strMenuName = 'Credit Card Reconciliation' AND strModuleName = 'Credit Card Recon' AND intParentMenuID = 0

DECLARE @CreditCardReconParentMenuId INT
SELECT @CreditCardReconParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Credit Card Reconciliation' AND strModuleName = 'Credit Card Recon' AND intParentMenuID = 0

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Import File Mapper' AND strModuleName = 'Credit Card Recon' AND intParentMenuID = @CreditCardReconParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Import File Mapper', N'Credit Card Recon', @CreditCardReconParentMenuId, N'Import File Mapper', N'Activity', N'Screen', N'CreditCardRecon.view.ImportFileMapper', N'small-menu-maintenance', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'CreditCardRecon.view.ImportFileMapper' WHERE strMenuName = 'Import File Mapper' AND strModuleName = 'Credit Card Recon' AND intParentMenuID = @CreditCardReconParentMenuId

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Credit Card Reconciliation Entry' AND strModuleName = 'Credit Card Recon' AND intParentMenuID = @CreditCardReconParentMenuId)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strCategory], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
	VALUES (N'Credit Card Reconciliation Entry', N'Credit Card Recon', @CreditCardReconParentMenuId, N'Credit Card Reconciliation Entry', N'Activity', N'Screen', N'CreditCardRecon.view.CreditCardReconciliation', N'small-menu-activity', 0, 0, 0, 1, 0, 1)
ELSE 
	UPDATE tblSMMasterMenu SET strCommand = N'CreditCardRecon.view.CreditCardReconciliation' WHERE strMenuName = 'Credit Card Reconciliation Entry' AND strModuleName = 'Credit Card Recon' AND intParentMenuID = @CreditCardReconParentMenuId

/* ENTITY MANAGEMENT */
UPDATE tblSMMasterMenu
SET strCommand = 'EntityManagement.view.Entity:searchEntityVendor'
WHERE strMenuName = 'Vendors' AND strModuleName = 'Accounts Payable' AND strCommand = 'AccountsPayable.view.Vendor'
    
UPDATE tblSMMasterMenu
SET strCommand = 'EntityManagement.view.Entity:searchEntityCustomer'
WHERE strMenuName = 'Customers' AND strModuleName = 'Accounts Receivable' AND strCommand = 'AccountsReceivable.view.Customer'

UPDATE tblSMMasterMenu
SET strCommand = 'EntityManagement.view.Entity:searchEntitySalesperson'
WHERE strMenuName = 'Salesperson' AND strModuleName = 'Accounts Receivable' AND strCommand = 'AccountsReceivable.view.Salesperson'

GO