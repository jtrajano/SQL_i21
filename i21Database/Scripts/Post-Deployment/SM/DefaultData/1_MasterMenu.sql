GO
	PRINT N'BEGIN INSERT DEFAULT MASTER MENU'
GO
--	DELETE FROM tblSMMenu
--GO
--	SET IDENTITY_INSERT [dbo].[tblSMMenu] ON
--		INSERT [dbo].[tblSMMenu] ([intMenuID], [strName], [strTemplate], [intConcurrencyId]) VALUES (1, N'Default', N'{expanded : true,enable : false,visible : false,isLegacy : false,override : false,"children": [{moduleName : "Admin",module : "System Manager",expanded : false,type : "Folder",command : "i21",leaf : false,enable : false,visible : true,isLegacy : false,override : false,"children": [{moduleName : "User Security",module : "System Manager",expanded : false,iconCls : "small-screen",type : "Screen",command : "i21.controller.UserSecurity",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "User Roles",module : "System Manager",expanded : false,iconCls : "small-screen",type : "Screen",command : "i21.controller.UserRole",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Report Manager",module : "System Manager",expanded : false,iconCls : "small-screen",expandCls : "small-screen-legacy",collapsedCls : "small-folder",type : "Screen",command : "Reports.controller.ReportManager",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Motor Fuel Tax Cycle",module : "System Manager",expanded : false,iconCls : "small-screen",type : "Screen",command : "Reports.controller.RunTaxCycle",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Company Preferences",module : "System Manager",expanded : false,iconCls : "small-screen",type : "Screen",command : "i21.controller.CompanyPreferences",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Starting Numbers",module : "System Manager",expanded : false,iconCls : "small-screen",type : "Screen",command : "i21.controller.StartingNumbers",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Customer Portal User Configuration",module : "Customer Portal",expanded : false,iconCls : "small-screen",type : "Screen",command : "CustomerPortal.controller.CustomerPortalUserConfiguration",leaf : true,enable : false,visible : false,isLegacy : false,override : false},{moduleName : "Utilities",module : "System Manager",expanded : true,iconCls : "small-folder",type : "Folder",leaf : false,enable : false,visible : true,isLegacy : false,override : false,"children": [{moduleName : "Origin Conversions",module : "System Manager",expanded : false,iconCls : "small-screen",type : "Screen",command : "i21.controller.OriginUtility",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Import Origin Users",module : "System Manager",expanded : false,iconCls : "small-screen",type : "Screen",command : "i21.controller.ImportLegacyUsers",leaf : true,enable : false,visible : true,isLegacy : false,override : false}]},{moduleName : "Common Info",module : "System Manager",expanded : false,iconCls : "small-folder",type : "Folder",leaf : false,enable : false,visible : true,isLegacy : false,override : false,"children": [{moduleName : "Country",module : "System Manager",expanded : false,iconCls : "small-screen",type : "Screen",command : "i21.controller.Country",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Zip Code",module : "System Manager",expanded : false,iconCls : "small-screen",type : "Screen",command : "i21.controller.ZipCode",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Currency",module : "System Manager",expanded : false,iconCls : "small-screen",type : "Screen",command : "i21.controller.Currency",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Ship Via",module : "System Manager",expanded : false,iconCls : "small-screen",type : "Screen",command : "i21.controller.ShipVia",leaf : true,enable : false,visible : false,isLegacy : false,override : false},{moduleName : "Payment Methods",module : "System Manager",expanded : false,iconCls : "small-screen",type : "Screen",command : "i21.controller.PaymentMethod",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Terms",module : "System Manager",expanded : false,iconCls : "small-screen",type : "Screen",command : "i21.controller.Term",leaf : true,enable : false,visible : false,isLegacy : false,override : false}]}]},{moduleName : "Dashboard",module : "Dashboard",expanded : false,iconCls : "small-folder",expandCls : "small-screen-legacy",collapsedCls : "small-folder",type : "Folder",leaf : false,enable : false,visible : true,isLegacy : false,override : false,"children": [{moduleName : "Add Panel",module : "Dashboard",expanded : false,iconCls : "small-screen",type : "Screen",command : "Dashboard.Controller.PanelSettings",leaf : true,enable : false,visible : false,isLegacy : false,override : false},{moduleName : "Connections",module : "Dashboard",expanded : false,iconCls : "small-screen",type : "Screen",command : "Reports.Controller.Connection",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Panels",module : "Dashboard",expanded : false,iconCls : "small-screen",type : "Screen",command : "Dashboard.Controller.PanelList",leaf : true,enable : false,visible : false,isLegacy : false,override : false},{moduleName : "Panel Layout",module : "Dashboard",expanded : false,iconCls : "small-screen",type : "Screen",command : "Dashboard.Controller.PanelLayout",leaf : true,enable : false,visible : false,isLegacy : false,override : false},{moduleName : "Tabs",module : "Dashboard",expanded : false,iconCls : "small-screen",type : "Screen",command : "Dashboard.Controller.TabSetup",leaf : true,enable : false,visible : false,isLegacy : false,override : false}]},{moduleName : "General Ledger",module : "General Ledger",expanded : false,type : "Folder",command : "GeneralLedger",enable : false,visible : true,isLegacy : false,override : false,"children": [{moduleName : "Activities",module : "General Ledger",expanded : true,type : "Folder",command : "GeneralLedger",enable : false,visible : true,isLegacy : false,override : false,"children": [{moduleName : "General Journal",module : "General Ledger",expanded : false,iconCls : "small-screen",type : "Screen",command : "GeneralLedger.view.GeneralJournal",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "GL Account Detail",module : "General Ledger",expanded : false,iconCls : "small-screen",type : "Screen",command : "GeneralLedger.controller.GLAccountDetail",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Batch Posting",module : "General Ledger",expanded : false,iconCls : "small-screen",type : "Screen",command : "GeneralLedger.controller.GLBatchPosting",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Reminder List",module : "General Ledger",expanded : false,iconCls : "small-screen",type : "Screen",command : "GeneralLedger.controller.ReminderList",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Import Budget from CSV",module : "General Ledger",expanded : false,iconCls : "small-screen",type : "Screen",command : "GeneralLedger.controller.ImportBudgetFromCSV",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Import GL from Subledger",module : "General Ledger",expanded : false,iconCls : "small-screen",type : "Screen",command : "GeneralLedger.controller.ImportFromSubledger",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Import GL from CSV",module : "General Ledger",expanded : false,iconCls : "small-screen",type : "Screen",command : "GeneralLedger.controller.ImportFromCSV",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "GL Import Logs",module : "General Ledger",expanded : false,iconCls : "small-screen",type : "Screen",command : "GeneralLedger.controller.ImportLogs",leaf : true,enable : false,visible : true,isLegacy : false,override : false}]},{moduleName : "Maintenance",module : "General Ledger",expanded : false,type : "Folder",command : "GeneralLedger",leaf : false,enable : false,visible : true,isLegacy : false,override : false,"children": [{moduleName : "Chart of Accounts",module : "General Ledger",expanded : false,iconCls : "small-screen",type : "Screen",command : "GeneralLedger.controller.ChartOfAccounts",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Account Structure",module : "General Ledger",expanded : false,iconCls : "small-screen",type : "Screen",command : "GeneralLedger.view.AccountStructure",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Account Groups",module : "General Ledger",expanded : false,iconCls : "small-screen",type : "Screen",command : "GeneralLedger.controller.AccountGroups",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Segment Accounts",module : "General Ledger",expanded : false,iconCls : "small-screen",type : "Screen",command : "GeneralLedger.controller.SegmentAccounts",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Build Accounts",module : "General Ledger",expanded : false,iconCls : "small-screen",type : "Screen",command : "GeneralLedger.controller.BuildAccounts",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Clone Account",module : "General Ledger",expanded : false,iconCls : "small-screen",type : "Screen",command : "GeneralLedger.view.AccountClone",leaf : true,enable : false,visible : false,isLegacy : false,override : false},{moduleName : "Fiscal Year",module : "General Ledger",expanded : false,iconCls : "small-screen",type : "Screen",command : "GeneralLedger.controller.FiscalYear",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Account Adjustment",module : "General Ledger",expanded : false,iconCls : "small-screen",type : "Screen",command : "GeneralLedger.controller.GLAccountAdjustment",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Reallocation",module : "General Ledger",expanded : false,iconCls : "small-screen",type : "Screen",command : "GeneralLedger.controller.Reallocation",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Recurring Journal",module : "General Ledger",expanded : false,iconCls : "small-screen",type : "Screen",command : "GeneralLedger.controller.RecurringJournal",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Recurring Journal History",module : "General Ledger",expanded : false,iconCls : "small-screen",type : "Screen",command : "GeneralLedger.controller.RecurringJournalHistory",leaf : true,enable : false,visible : true,isLegacy : false,override : false}]},{moduleName : "Financial Reports",module : "General Ledger",expanded : false,iconCls : "small-folder",expandCls : "small-screen-legacy",collapsedCls : "small-folder",type : "Folder",command : "FinancialReportDesigner",enable : false,visible : true,isLegacy : false,override : false,"children": [{moduleName : "Financial Reports",module : "General Ledger",expanded : false,iconCls : "small-screen",type : "Screen",command : "FinancialReportDesigner.controller.FinancialReports",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Financial Report Designer",module : "General Ledger",expanded : true,iconCls : "small-folder",expandCls : "small-screen-legacy",collapsedCls : "small-folder",type : "Folder",command : "FinancialReportDesigners",enable : false,visible : true,isLegacy : false,override : false,"children": [{moduleName : "Row Designer",module : "General Ledger",expanded : false,iconCls : "small-screen",type : "Screen",command : "FinancialReportDesigner.controller.RowDesigner",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Column Designer",module : "General Ledger",expanded : false,iconCls : "small-screen",type : "Screen",command : "FinancialReportDesigner.controller.ColumnDesigner",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Report Header and Footer",module : "General Ledger",expanded : false,iconCls : "small-screen",type : "Screen",command : "FinancialReportDesigner.controller.HeaderDesigner",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Financial Report Builder",module : "General Ledger",expanded : false,iconCls : "small-screen",type : "Screen",command : "FinancialReportDesigner.controller.ReportBuilder",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Report Templates",module : "General Ledger",expanded : false,iconCls : "small-screen",type : "Screen",command : "FinancialReportDesigner.controller.Templates",leaf : true,enable : false,visible : true,isLegacy : false,override : false}]}]},{moduleName : "Reports",module : "General Ledger",expanded : false,iconCls : "small-folder",expandCls : "small-screen-legacy",collapsedCls : "small-folder",type : "Folder",enable : false,visible : true,isLegacy : false,override : false,"children": [{moduleName : "Reallocation",module : "General Ledger",expanded : false,iconCls : "small-report",type : "Report",command : "Reallocation",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Chart of Accounts",module : "General Ledger",expanded : false,iconCls : "small-report",type : "Report",command : "Chart of Accounts",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Chart of Accounts Adjustment",module : "General Ledger",expanded : false,iconCls : "small-report",type : "Report",command : "Chart of Accounts Adjustment",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "General Ledger by Account ID Detail",module : "General Ledger",expanded : false,iconCls : "small-report",type : "Report",command : "General Ledger by Account ID Detail",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Balance Sheet Standard",module : "General Ledger",expanded : false,iconCls : "small-report",type : "Report",command : "Balance Sheet Standard",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Income Statement Standard",module : "General Ledger",expanded : false,iconCls : "small-report",type : "Report",command : "Income Statement Standard",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Trial Balance",module : "General Ledger",expanded : false,iconCls : "small-report",type : "Report",command : "Trial Balance",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Trial Balance Detail",module : "General Ledger",expanded : false,iconCls : "small-report",type : "Report",command : "Trial Balance Detail",leaf : true,enable : false,visible : true,isLegacy : false,override : false}]}]},{moduleName : "Tank Management",module : "Tank Management",expanded : false,type : "Folder",command : "TankManagement",enable : false,visible : true,isLegacy : false,override : false,"children": [{moduleName : "Activities",module : "Tank Management",expanded : false,type : "Folder",command : "TankManagement",enable : false,visible : true,isLegacy : false,override : false,"children": [{moduleName : "Customer Inquiry",module : "Tank Management",expanded : false,iconCls : "small-screen",type : "Screen",command : "TankManagement.controller.CustomerInquiry",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Consumption Sites",module : "Tank Management",expanded : false,iconCls : "small-screen",type : "Screen",command : "TankManagement.controller.ConsumptionSite",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Clock Reading",module : "Tank Management",expanded : false,iconCls : "small-screen",type : "Screen",command : "TankManagement.controller.ClockReading",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Synchronize Delivery History",module : "Tank Management",expanded : false,iconCls : "small-screen",type : "Screen",command : "TankManagement.controller.SyncDeliveryHistory",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Lease Billing",module : "Tank Management",expanded : false,iconCls : "small-screen",type : "Screen",command : "TankManagement.controller.LeaseBilling",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Dispatch Deliveries",module : "Tank Management",expanded : false,iconCls : "small-screen",type : "Screen",command : "TankManagement.controller.DispatchDelivery",leaf : true,enable : false,visible : true,isLegacy : false,override : false}]},{moduleName : "Maintenance",module : "Tank Management",expanded : true,command : "TankManagement",enable : false,visible : true,isLegacy : false,override : false,"children": [{moduleName : "Degree Day Clock",module : "Tank Management",expanded : false,iconCls : "small-screen",type : "Screen",command : "TankManagement.controller.DegreeDayClock",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Devices",module : "Tank Management",expanded : false,iconCls : "small-screen",type : "Screen",command : "TankManagement.controller.Device",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Events",module : "Tank Management",expanded : false,iconCls : "small-screen",type : "Screen",command : "TankManagement.controller.Event",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Event Type",module : "Tank Management",expanded : false,iconCls : "small-screen",type : "Screen",command : "TankManagement.controller.EventType",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Device Type",module : "Tank Management",expanded : false,iconCls : "small-screen",type : "Screen",command : "TankManagement.controller.DeviceType",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Lease Code",module : "Tank Management",expanded : false,iconCls : "small-screen",type : "Screen",command : "TankManagement.controller.LeaseCode",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Event Automation Setup",module : "Tank Management",expanded : false,iconCls : "small-screen",type : "Screen",command : "TankManagement.controller.EventAutomation",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Meter Type",module : "Tank Management",expanded : false,iconCls : "small-screen",type : "Screen",command : "TankManagement.controller.MeterType",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Renew Julian Deliveries",module : "Tank Management",expanded : false,iconCls : "small-screen",type : "Screen",command : "TankManagement.controller.RenewJulianDelivery",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Resolve Sync Conflict",module : "Tank Management",expanded : false,iconCls : "small-screen",type : "Screen",command : "TankManagement.controller.ResolveSyncConflict",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Lease Billing Incentive",module : "Tank Management",expanded : false,iconCls : "small-screen",type : "Screen",command : "TankManagement.controller.LeaseBillingMinimum",leaf : true,enable : false,visible : true,isLegacy : false,override : false}]},{moduleName : "Reports",module : "Tank Management",expanded : false,iconCls : "small-folder",expandCls : "small-screen-legacy",collapsedCls : "small-folder",type : "Folder",enable : false,visible : true,isLegacy : false,override : false,"children": [{moduleName : "Delivery Fill Report",module : "Tank Management",expanded : false,iconCls : "small-report",type : "Report",command : "Delivery Fill Report",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Two-Part Delivery Fill Report",module : "Tank Management",expanded : false,iconCls : "small-report",type : "Report",command : "Two-Part Delivery Fill Report",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Lease Billing Report",module : "Tank Management",expanded : false,iconCls : "small-report",type : "Report",command : "Lease Billing Report",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Missed Julian Deliveries",module : "Tank Management",expanded : false,iconCls : "small-report",type : "Report",command : "Missed Julian Deliveries",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Out of Range Burn Rates",module : "Tank Management",expanded : false,iconCls : "small-report",type : "Report",command : "Out of Range Burn Rates",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Call Entry Printout",module : "Tank Management",expanded : false,iconCls : "small-report",type : "Report",command : "Call Entry Printout",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Fill Group",module : "Tank Management",expanded : false,iconCls : "small-report",type : "Report",command : "Fill Group",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Tank Inventory",module : "Tank Management",expanded : false,iconCls : "small-report",type : "Report",command : "Tank Inventory",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Customer List by Route",module : "Tank Management",expanded : false,iconCls : "small-report",type : "Report",command : "Customer List by Route",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Device Actions",module : "Tank Management",expanded : false,iconCls : "small-report",type : "Report",command : "Device Actions",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Open Call Entries",module : "Tank Management",expanded : false,iconCls : "small-report",type : "Report",command : "Open Call Entries",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Work Order Status",module : "Tank Management",expanded : false,iconCls : "small-report",type : "Report",command : "Work Order Status",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Leak Check / Gas Check",module : "Tank Management",expanded : false,iconCls : "small-report",type : "Report",command : "Leak Check / Gas Check",leaf : true,enable : false,visible : true,isLegacy : false,override : false}]}]},{moduleName : "Cash Management",module : "Cash Management",expanded : false,iconCls : "small-folder",expandCls : "small-screen-legacy",collapsedCls : "small-folder",type : "Folder",leaf : false,enable : false,visible : true,isLegacy : false,override : false,"children": [{moduleName : "Activities",module : "Cash Management",expanded : true,iconCls : "small-folder",expandCls : "small-screen-legacy",collapsedCls : "small-folder",type : "Folder",leaf : false,enable : false,visible : true,isLegacy : false,override : false,"children": [{moduleName : "Bank Deposits",module : "Cash Management",expanded : false,iconCls : "small-screen",type : "Screen",command : "CashManagement.controller.BankDeposit",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Bank Transactions",module : "Cash Management",expanded : false,iconCls : "small-screen",type : "Screen",command : "CashManagement.controller.BankTransactions",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Bank Transfers",module : "Cash Management",expanded : false,iconCls : "small-screen",type : "Screen",command : "CashManagement.controller.BankTransfer",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Miscellaneous Checks",module : "Cash Management",expanded : false,iconCls : "small-screen",type : "Screen",command : "CashManagement.controller.MiscellaneousChecks",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Bank Account Register",module : "Cash Management",expanded : false,iconCls : "small-screen",type : "Screen",command : "CashManagement.controller.BankAccountRegister",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Bank Reconciliation",module : "Cash Management",expanded : false,iconCls : "small-screen",type : "Screen",command : "CashManagement.controller.BankReconciliation",leaf : true,enable : false,visible : true,isLegacy : false,override : false}]},{moduleName : "Maintenance",module : "Cash Management",expanded : true,iconCls : "small-folder",expandCls : "small-screen-legacy",collapsedCls : "small-folder",type : "Folder",leaf : false,enable : false,visible : true,isLegacy : false,override : false,"children": [{moduleName : "Banks",module : "Cash Management",expanded : false,iconCls : "small-screen",type : "Screen",command : "CashManagement.controller.Banks",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Bank Accounts",module : "Cash Management",expanded : false,iconCls : "small-screen",type : "Screen",command : "CashManagement.controller.BankAccounts",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Bank File Formats",module : "Cash Management",expanded : false,iconCls : "small-screen",type : "Screen",command : "CashManagement.controller.BankFileFormat",leaf : true,enable : false,visible : true,isLegacy : false,override : false}]}]},{moduleName : "Accounts Payable",module : "Accounts Payable",expanded : false,iconCls : "small-folder",expandCls : "small-screen-legacy",collapsedCls : "small-folder",type : "Folder",leaf : false,enable : false,visible : true,isLegacy : false,override : false,"children": [{moduleName : "Activities",module : "Accounts Payable",expanded : true,iconCls : "small-folder",expandCls : "small-screen-legacy",collapsedCls : "small-folder",type : "Folder",leaf : false,enable : false,visible : true,isLegacy : false,override : false,"children": [{moduleName : "Pay Bills",module : "Accounts Payable",expanded : false,iconCls : "small-screen",type : "Screen",command : "AccountsPayable.controller.PayBillsDetail",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Pay Bills (Multi-Vendor)",module : "Accounts Payable",expanded : false,iconCls : "small-screen",type : "Screen",command : "AccountsPayable.controller.PayBill",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Bill Batch Entry",module : "Accounts Payable",expanded : false,iconCls : "small-screen",type : "Screen",command : "AccountsPayable.controller.BillBatch",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Batch Post",module : "Accounts Payable",expanded : false,iconCls : "small-screen",type : "Screen",command : "AccountsPayable.controller.BatchPosting",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Print Checks",module : "Accounts Payable",expanded : false,iconCls : "small-screen",type : "Screen",command : "AccountsPayable.controller.PrintChecks",leaf : true,enable : false,visible : false,isLegacy : false,override : false},{moduleName : "Paid Bills History",module : "Accounts Payable",expanded : false,iconCls : "small-screen",type : "Screen",leaf : true,enable : false,visible : false,isLegacy : false,override : false},{moduleName : "Import Bills from Origin",module : "Accounts Payable",expanded : false,iconCls : "small-screen",type : "Screen",command : "AccountsPayable.controller.ImportAPInvoice",leaf : true,enable : false,visible : true,isLegacy : false,override : false}]},{moduleName : "Maintenance",module : "Accounts Payable",expanded : false,iconCls : "small-folder",expandCls : "small-screen-legacy",collapsedCls : "small-folder",type : "Folder",leaf : false,enable : false,visible : true,isLegacy : false,override : false,"children": [{moduleName : "Vendors",module : "Accounts Payable",expanded : false,iconCls : "small-screen",type : "Screen",command : "AccountsPayable.controller.Vendor",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Posted Payables",module : "Accounts Payable",expanded : false,iconCls : "small-screen",type : "Screen",leaf : true,enable : false,visible : false,isLegacy : false,override : false}]},{moduleName : "Reports",module : "Accounts Payable",expanded : false,iconCls : "small-folder",expandCls : "small-screen-legacy",collapsedCls : "small-folder",type : "Folder",leaf : false,enable : false,visible : true,isLegacy : false,override : false,"children": [{moduleName : "Open Payables",module : "Accounts Payable",expanded : false,iconCls : "small-report",type : "Report",leaf : true,enable : false,visible : false,isLegacy : false,override : false},{moduleName : "Vendor History",module : "Accounts Payable",expanded : false,iconCls : "small-report",type : "Report",leaf : true,enable : false,visible : false,isLegacy : false,override : false},{moduleName : "Cash Requirements",module : "Accounts Payable",expanded : false,iconCls : "small-report",type : "Report",leaf : true,enable : false,visible : false,isLegacy : false,override : false},{moduleName : "Check History Payment Detail",module : "Accounts Payable",expanded : false,iconCls : "small-report",type : "Report",leaf : true,enable : false,visible : false,isLegacy : false,override : false},{moduleName : "Check Register",module : "Accounts Payable",expanded : false,iconCls : "small-report",type : "Report",leaf : true,enable : false,visible : false,isLegacy : false,override : false},{moduleName : "Bill by General Ledger",module : "Accounts Payable",expanded : false,iconCls : "small-report",type : "Report",leaf : true,enable : false,visible : false,isLegacy : false,override : false}]}]},{moduleName : "Customer Portal",module : "Customer Portal",expanded : false,iconCls : "small-folder",expandCls : "small-screen-legacy",collapsedCls : "small-folder",type : "Folder",leaf : false,enable : false,visible : true,isLegacy : false,override : false,"children": [{moduleName : "Billing Account",module : "Customer Portal",expanded : false,iconCls : "small-folder",expandCls : "small-screen-legacy",collapsedCls : "small-folder",type : "Folder",leaf : false,enable : false,visible : true,isLegacy : false,override : false,"children": [{moduleName : "Billing Account",module : "Customer Portal",expanded : false,iconCls : "small-screen",type : "Screen",command : "CustomerPortal.controller.BillingAccount",leaf : true,enable : false,visible : false,isLegacy : false,override : false},{moduleName : "Invoices Credits",module : "Customer Portal",expanded : false,iconCls : "small-screen",type : "Screen",command : "CustomerPortal.controller.InvoicesCredits",leaf : true,enable : false,visible : false,isLegacy : false,override : false},{moduleName : "Payments",module : "Customer Portal",expanded : false,iconCls : "small-screen",type : "Screen",command : "CustomerPortal.controller.Payments",leaf : true,enable : false,visible : false,isLegacy : false,override : false},{moduleName : "Purchases",module : "Customer Portal",expanded : false,iconCls : "small-screen",type : "Screen",command : "CustomerPortal.controller.Purchases",leaf : true,enable : false,visible : false,isLegacy : false,override : false},{moduleName : "Orders",module : "Customer Portal",expanded : false,iconCls : "small-screen",type : "Screen",command : "CustomerPortal.controller.Orders",leaf : true,enable : false,visible : false,isLegacy : false,override : false},{moduleName : "Contracts",module : "Customer Portal",expanded : false,iconCls : "small-screen",type : "Screen",command : "CustomerPortal.controller.Contracts",leaf : true,enable : false,visible : false,isLegacy : false,override : false},{moduleName : "Business Summary",module : "Customer Portal",expanded : false,iconCls : "small-screen",type : "Screen",command : "CustomerPortal.controller.BusinessSummary",leaf : true,enable : false,visible : false,isLegacy : false,override : false}]},{moduleName : "Grain Account",module : "Customer Portal",expanded : false,iconCls : "small-folder",expandCls : "small-screen-legacy",collapsedCls : "small-folder",type : "Folder",leaf : false,enable : false,visible : true,isLegacy : false,override : false,"children": [{moduleName : "Grain Account",module : "Customer Portal",expanded : false,iconCls : "small-screen",type : "Screen",command : "CustomerPortal.controller.GrainAccount",leaf : true,enable : false,visible : false,isLegacy : false,override : false},{moduleName : "Settlements",module : "Customer Portal",expanded : false,iconCls : "small-screen",type : "Screen",command : "CustomerPortal.controller.Settlements",leaf : true,enable : false,visible : false,isLegacy : false,override : false},{moduleName : "Storage",module : "Customer Portal",expanded : false,iconCls : "small-screen",type : "Screen",command : "CustomerPortal.controller.Storage",leaf : true,enable : false,visible : false,isLegacy : false,override : false},{moduleName : "Contracts",module : "Customer Portal",expanded : false,iconCls : "small-screen",type : "Screen",command : "CustomerPortal.controller.GAContracts",leaf : true,enable : false,visible : false,isLegacy : false,override : false},{moduleName : "Production History",module : "Customer Portal",expanded : false,iconCls : "small-screen",type : "Screen",command : "CustomerPortal.controller.ProductionHistory",leaf : true,enable : false,visible : false,isLegacy : false,override : false},{moduleName : "Options",module : "Customer Portal",expanded : false,iconCls : "small-screen",type : "Screen",command : "CustomerPortal.controller.Options",leaf : true,enable : false,visible : false,isLegacy : false,override : false},{moduleName : "Current Cash Bids",module : "Customer Portal",expanded : false,iconCls : "small-screen",type : "Screen",command : "CustomerPortal.controller.CurrentCashBids",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Business Summary",module : "Customer Portal",expanded : false,iconCls : "small-screen",type : "Screen",command : "CustomerPortal.controller.GABusinessSummary",leaf : true,enable : false,visible : false,isLegacy : false,override : false}]}]}]}', 6)
--		INSERT [dbo].[tblSMMenu] ([intMenuID], [strName], [strTemplate], [intConcurrencyId]) VALUES (2, N'DefaultBackup', N'{expanded : true,enable : false,visible : false,isLegacy : false,override : false,"children": [{moduleName : "Admin",module : "System Manager",expanded : false,type : "Folder",command : "i21",leaf : false,enable : false,visible : true,isLegacy : false,override : false,"children": [{moduleName : "User Security",module : "System Manager",expanded : false,iconCls : "small-screen",type : "Screen",command : "i21.controller.UserSecurity",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "User Roles",module : "System Manager",expanded : false,iconCls : "small-screen",type : "Screen",command : "i21.controller.UserRole",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Report Manager",module : "System Manager",expanded : false,iconCls : "small-screen",expandCls : "small-screen-legacy",collapsedCls : "small-folder",type : "Screen",command : "Reports.controller.ReportManager",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Motor Fuel Tax Cycle",module : "System Manager",expanded : false,iconCls : "small-screen",type : "Screen",command : "Reports.controller.RunTaxCycle",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Company Preferences",module : "System Manager",expanded : false,iconCls : "small-screen",type : "Screen",command : "i21.controller.CompanyPreferences",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Starting Numbers",module : "System Manager",expanded : false,iconCls : "small-screen",type : "Screen",command : "i21.controller.StartingNumbers",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Customer Portal User Configuration",module : "Customer Portal",expanded : false,iconCls : "small-screen",type : "Screen",command : "CustomerPortal.controller.CustomerPortalUserConfiguration",leaf : true,enable : false,visible : false,isLegacy : false,override : false},{moduleName : "Utilities",module : "System Manager",expanded : true,iconCls : "small-folder",type : "Folder",leaf : false,enable : false,visible : true,isLegacy : false,override : false,"children": [{moduleName : "Origin Conversions",module : "System Manager",expanded : false,iconCls : "small-screen",type : "Screen",command : "i21.controller.OriginUtility",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Import Origin Users",module : "System Manager",expanded : false,iconCls : "small-screen",type : "Screen",command : "i21.controller.ImportLegacyUsers",leaf : true,enable : false,visible : true,isLegacy : false,override : false}]},{moduleName : "Common Info",module : "System Manager",expanded : false,iconCls : "small-folder",type : "Folder",leaf : false,enable : false,visible : true,isLegacy : false,override : false,"children": [{moduleName : "Country",module : "System Manager",expanded : false,iconCls : "small-screen",type : "Screen",command : "i21.controller.Country",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Zip Code",module : "System Manager",expanded : false,iconCls : "small-screen",type : "Screen",command : "i21.controller.ZipCode",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Currency",module : "System Manager",expanded : false,iconCls : "small-screen",type : "Screen",command : "i21.controller.Currency",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Ship Via",module : "System Manager",expanded : false,iconCls : "small-screen",type : "Screen",command : "i21.controller.ShipVia",leaf : true,enable : false,visible : false,isLegacy : false,override : false},{moduleName : "Payment Methods",module : "System Manager",expanded : false,iconCls : "small-screen",type : "Screen",command : "i21.controller.PaymentMethod",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Terms",module : "System Manager",expanded : false,iconCls : "small-screen",type : "Screen",command : "i21.controller.Term",leaf : true,enable : false,visible : false,isLegacy : false,override : false}]}]},{moduleName : "Dashboard",module : "Dashboard",expanded : false,iconCls : "small-folder",expandCls : "small-screen-legacy",collapsedCls : "small-folder",type : "Folder",leaf : false,enable : false,visible : true,isLegacy : false,override : false,"children": [{moduleName : "Add Panel",module : "Dashboard",expanded : false,iconCls : "small-screen",type : "Screen",command : "Dashboard.Controller.PanelSettings",leaf : true,enable : false,visible : false,isLegacy : false,override : false},{moduleName : "Connections",module : "Dashboard",expanded : false,iconCls : "small-screen",type : "Screen",command : "Reports.Controller.Connection",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Panels",module : "Dashboard",expanded : false,iconCls : "small-screen",type : "Screen",command : "Dashboard.Controller.PanelList",leaf : true,enable : false,visible : false,isLegacy : false,override : false},{moduleName : "Panel Layout",module : "Dashboard",expanded : false,iconCls : "small-screen",type : "Screen",command : "Dashboard.Controller.PanelLayout",leaf : true,enable : false,visible : false,isLegacy : false,override : false},{moduleName : "Tabs",module : "Dashboard",expanded : false,iconCls : "small-screen",type : "Screen",command : "Dashboard.Controller.TabSetup",leaf : true,enable : false,visible : false,isLegacy : false,override : false}]},{moduleName : "General Ledger",module : "General Ledger",expanded : false,type : "Folder",command : "GeneralLedger",enable : false,visible : true,isLegacy : false,override : false,"children": [{moduleName : "Activities",module : "General Ledger",expanded : true,type : "Folder",command : "GeneralLedger",enable : false,visible : true,isLegacy : false,override : false,"children": [{moduleName : "General Journal",module : "General Ledger",expanded : false,iconCls : "small-screen",type : "Screen",command : "GeneralLedger.view.GeneralJournal",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "GL Account Detail",module : "General Ledger",expanded : false,iconCls : "small-screen",type : "Screen",command : "GeneralLedger.controller.GLAccountDetail",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Batch Posting",module : "General Ledger",expanded : false,iconCls : "small-screen",type : "Screen",command : "GeneralLedger.controller.GLBatchPosting",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Reminder List",module : "General Ledger",expanded : false,iconCls : "small-screen",type : "Screen",command : "GeneralLedger.controller.ReminderList",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Import Budget from CSV",module : "General Ledger",expanded : false,iconCls : "small-screen",type : "Screen",command : "GeneralLedger.controller.ImportBudgetFromCSV",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Import GL from Subledger",module : "General Ledger",expanded : false,iconCls : "small-screen",type : "Screen",command : "GeneralLedger.controller.ImportFromSubledger",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Import GL from CSV",module : "General Ledger",expanded : false,iconCls : "small-screen",type : "Screen",command : "GeneralLedger.controller.ImportFromCSV",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "GL Import Logs",module : "General Ledger",expanded : false,iconCls : "small-screen",type : "Screen",command : "GeneralLedger.controller.ImportLogs",leaf : true,enable : false,visible : true,isLegacy : false,override : false}]},{moduleName : "Maintenance",module : "General Ledger",expanded : false,type : "Folder",command : "GeneralLedger",leaf : false,enable : false,visible : true,isLegacy : false,override : false,"children": [{moduleName : "Chart of Accounts",module : "General Ledger",expanded : false,iconCls : "small-screen",type : "Screen",command : "GeneralLedger.controller.ChartOfAccounts",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Account Structure",module : "General Ledger",expanded : false,iconCls : "small-screen",type : "Screen",command : "GeneralLedger.view.AccountStructure",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Account Groups",module : "General Ledger",expanded : false,iconCls : "small-screen",type : "Screen",command : "GeneralLedger.controller.AccountGroups",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Segment Accounts",module : "General Ledger",expanded : false,iconCls : "small-screen",type : "Screen",command : "GeneralLedger.controller.SegmentAccounts",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Build Accounts",module : "General Ledger",expanded : false,iconCls : "small-screen",type : "Screen",command : "GeneralLedger.controller.BuildAccounts",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Clone Account",module : "General Ledger",expanded : false,iconCls : "small-screen",type : "Screen",command : "GeneralLedger.view.AccountClone",leaf : true,enable : false,visible : false,isLegacy : false,override : false},{moduleName : "Fiscal Year",module : "General Ledger",expanded : false,iconCls : "small-screen",type : "Screen",command : "GeneralLedger.controller.FiscalYear",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Account Adjustment",module : "General Ledger",expanded : false,iconCls : "small-screen",type : "Screen",command : "GeneralLedger.controller.GLAccountAdjustment",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Reallocation",module : "General Ledger",expanded : false,iconCls : "small-screen",type : "Screen",command : "GeneralLedger.controller.Reallocation",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Recurring Journal",module : "General Ledger",expanded : false,iconCls : "small-screen",type : "Screen",command : "GeneralLedger.controller.RecurringJournal",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Recurring Journal History",module : "General Ledger",expanded : false,iconCls : "small-screen",type : "Screen",command : "GeneralLedger.controller.RecurringJournalHistory",leaf : true,enable : false,visible : true,isLegacy : false,override : false}]},{moduleName : "Financial Reports",module : "General Ledger",expanded : false,iconCls : "small-folder",expandCls : "small-screen-legacy",collapsedCls : "small-folder",type : "Folder",command : "FinancialReportDesigner",enable : false,visible : true,isLegacy : false,override : false,"children": [{moduleName : "Financial Reports",module : "General Ledger",expanded : false,iconCls : "small-screen",type : "Screen",command : "FinancialReportDesigner.controller.FinancialReports",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Financial Report Designer",module : "General Ledger",expanded : true,iconCls : "small-folder",expandCls : "small-screen-legacy",collapsedCls : "small-folder",type : "Folder",command : "FinancialReportDesigners",enable : false,visible : true,isLegacy : false,override : false,"children": [{moduleName : "Row Designer",module : "General Ledger",expanded : false,iconCls : "small-screen",type : "Screen",command : "FinancialReportDesigner.controller.RowDesigner",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Column Designer",module : "General Ledger",expanded : false,iconCls : "small-screen",type : "Screen",command : "FinancialReportDesigner.controller.ColumnDesigner",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Report Header and Footer",module : "General Ledger",expanded : false,iconCls : "small-screen",type : "Screen",command : "FinancialReportDesigner.controller.HeaderDesigner",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Financial Report Builder",module : "General Ledger",expanded : false,iconCls : "small-screen",type : "Screen",command : "FinancialReportDesigner.controller.ReportBuilder",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Report Templates",module : "General Ledger",expanded : false,iconCls : "small-screen",type : "Screen",command : "FinancialReportDesigner.controller.Templates",leaf : true,enable : false,visible : true,isLegacy : false,override : false}]}]},{moduleName : "Reports",module : "General Ledger",expanded : false,iconCls : "small-folder",expandCls : "small-screen-legacy",collapsedCls : "small-folder",type : "Folder",enable : false,visible : true,isLegacy : false,override : false,"children": [{moduleName : "Reallocation",module : "General Ledger",expanded : false,iconCls : "small-report",type : "Report",command : "Reallocation",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Chart of Accounts",module : "General Ledger",expanded : false,iconCls : "small-report",type : "Report",command : "Chart of Accounts",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Chart of Accounts Adjustment",module : "General Ledger",expanded : false,iconCls : "small-report",type : "Report",command : "Chart of Accounts Adjustment",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "General Ledger by Account ID Detail",module : "General Ledger",expanded : false,iconCls : "small-report",type : "Report",command : "General Ledger by Account ID Detail",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Balance Sheet Standard",module : "General Ledger",expanded : false,iconCls : "small-report",type : "Report",command : "Balance Sheet Standard",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Income Statement Standard",module : "General Ledger",expanded : false,iconCls : "small-report",type : "Report",command : "Income Statement Standard",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Trial Balance",module : "General Ledger",expanded : false,iconCls : "small-report",type : "Report",command : "Trial Balance",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Trial Balance Detail",module : "General Ledger",expanded : false,iconCls : "small-report",type : "Report",command : "Trial Balance Detail",leaf : true,enable : false,visible : true,isLegacy : false,override : false}]}]},{moduleName : "Tank Management",module : "Tank Management",expanded : false,type : "Folder",command : "TankManagement",enable : false,visible : true,isLegacy : false,override : false,"children": [{moduleName : "Activities",module : "Tank Management",expanded : false,type : "Folder",command : "TankManagement",enable : false,visible : true,isLegacy : false,override : false,"children": [{moduleName : "Customer Inquiry",module : "Tank Management",expanded : false,iconCls : "small-screen",type : "Screen",command : "TankManagement.controller.CustomerInquiry",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Consumption Sites",module : "Tank Management",expanded : false,iconCls : "small-screen",type : "Screen",command : "TankManagement.controller.ConsumptionSite",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Clock Reading",module : "Tank Management",expanded : false,iconCls : "small-screen",type : "Screen",command : "TankManagement.controller.ClockReading",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Synchronize Delivery History",module : "Tank Management",expanded : false,iconCls : "small-screen",type : "Screen",command : "TankManagement.controller.SyncDeliveryHistory",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Lease Billing",module : "Tank Management",expanded : false,iconCls : "small-screen",type : "Screen",command : "TankManagement.controller.LeaseBilling",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Dispatch Deliveries",module : "Tank Management",expanded : false,iconCls : "small-screen",type : "Screen",command : "TankManagement.controller.DispatchDelivery",leaf : true,enable : false,visible : true,isLegacy : false,override : false}]},{moduleName : "Maintenance",module : "Tank Management",expanded : true,command : "TankManagement",enable : false,visible : true,isLegacy : false,override : false,"children": [{moduleName : "Degree Day Clock",module : "Tank Management",expanded : false,iconCls : "small-screen",type : "Screen",command : "TankManagement.controller.DegreeDayClock",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Devices",module : "Tank Management",expanded : false,iconCls : "small-screen",type : "Screen",command : "TankManagement.controller.Device",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Events",module : "Tank Management",expanded : false,iconCls : "small-screen",type : "Screen",command : "TankManagement.controller.Event",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Event Type",module : "Tank Management",expanded : false,iconCls : "small-screen",type : "Screen",command : "TankManagement.controller.EventType",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Device Type",module : "Tank Management",expanded : false,iconCls : "small-screen",type : "Screen",command : "TankManagement.controller.DeviceType",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Lease Code",module : "Tank Management",expanded : false,iconCls : "small-screen",type : "Screen",command : "TankManagement.controller.LeaseCode",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Event Automation Setup",module : "Tank Management",expanded : false,iconCls : "small-screen",type : "Screen",command : "TankManagement.controller.EventAutomation",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Meter Type",module : "Tank Management",expanded : false,iconCls : "small-screen",type : "Screen",command : "TankManagement.controller.MeterType",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Renew Julian Deliveries",module : "Tank Management",expanded : false,iconCls : "small-screen",type : "Screen",command : "TankManagement.controller.RenewJulianDelivery",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Resolve Sync Conflict",module : "Tank Management",expanded : false,iconCls : "small-screen",type : "Screen",command : "TankManagement.controller.ResolveSyncConflict",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Lease Billing Incentive",module : "Tank Management",expanded : false,iconCls : "small-screen",type : "Screen",command : "TankManagement.controller.LeaseBillingMinimum",leaf : true,enable : false,visible : true,isLegacy : false,override : false}]},{moduleName : "Reports",module : "Tank Management",expanded : false,iconCls : "small-folder",expandCls : "small-screen-legacy",collapsedCls : "small-folder",type : "Folder",enable : false,visible : true,isLegacy : false,override : false,"children": [{moduleName : "Delivery Fill Report",module : "Tank Management",expanded : false,iconCls : "small-report",type : "Report",command : "Delivery Fill Report",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Two-Part Delivery Fill Report",module : "Tank Management",expanded : false,iconCls : "small-report",type : "Report",command : "Two-Part Delivery Fill Report",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Lease Billing Report",module : "Tank Management",expanded : false,iconCls : "small-report",type : "Report",command : "Lease Billing Report",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Missed Julian Deliveries",module : "Tank Management",expanded : false,iconCls : "small-report",type : "Report",command : "Missed Julian Deliveries",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Out of Range Burn Rates",module : "Tank Management",expanded : false,iconCls : "small-report",type : "Report",command : "Out of Range Burn Rates",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Call Entry Printout",module : "Tank Management",expanded : false,iconCls : "small-report",type : "Report",command : "Call Entry Printout",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Fill Group",module : "Tank Management",expanded : false,iconCls : "small-report",type : "Report",command : "Fill Group",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Tank Inventory",module : "Tank Management",expanded : false,iconCls : "small-report",type : "Report",command : "Tank Inventory",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Customer List by Route",module : "Tank Management",expanded : false,iconCls : "small-report",type : "Report",command : "Customer List by Route",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Device Actions",module : "Tank Management",expanded : false,iconCls : "small-report",type : "Report",command : "Device Actions",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Open Call Entries",module : "Tank Management",expanded : false,iconCls : "small-report",type : "Report",command : "Open Call Entries",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Work Order Status",module : "Tank Management",expanded : false,iconCls : "small-report",type : "Report",command : "Work Order Status",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Leak Check / Gas Check",module : "Tank Management",expanded : false,iconCls : "small-report",type : "Report",command : "Leak Check / Gas Check",leaf : true,enable : false,visible : true,isLegacy : false,override : false}]}]},{moduleName : "Cash Management",module : "Cash Management",expanded : false,iconCls : "small-folder",expandCls : "small-screen-legacy",collapsedCls : "small-folder",type : "Folder",leaf : false,enable : false,visible : true,isLegacy : false,override : false,"children": [{moduleName : "Activities",module : "Cash Management",expanded : true,iconCls : "small-folder",expandCls : "small-screen-legacy",collapsedCls : "small-folder",type : "Folder",leaf : false,enable : false,visible : true,isLegacy : false,override : false,"children": [{moduleName : "Bank Deposits",module : "Cash Management",expanded : false,iconCls : "small-screen",type : "Screen",command : "CashManagement.controller.BankDeposit",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Bank Transactions",module : "Cash Management",expanded : false,iconCls : "small-screen",type : "Screen",command : "CashManagement.controller.BankTransactions",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Bank Transfers",module : "Cash Management",expanded : false,iconCls : "small-screen",type : "Screen",command : "CashManagement.controller.BankTransfer",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Miscellaneous Checks",module : "Cash Management",expanded : false,iconCls : "small-screen",type : "Screen",command : "CashManagement.controller.MiscellaneousChecks",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Bank Account Register",module : "Cash Management",expanded : false,iconCls : "small-screen",type : "Screen",command : "CashManagement.controller.BankAccountRegister",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Bank Reconciliation",module : "Cash Management",expanded : false,iconCls : "small-screen",type : "Screen",command : "CashManagement.controller.BankReconciliation",leaf : true,enable : false,visible : true,isLegacy : false,override : false}]},{moduleName : "Maintenance",module : "Cash Management",expanded : true,iconCls : "small-folder",expandCls : "small-screen-legacy",collapsedCls : "small-folder",type : "Folder",leaf : false,enable : false,visible : true,isLegacy : false,override : false,"children": [{moduleName : "Banks",module : "Cash Management",expanded : false,iconCls : "small-screen",type : "Screen",command : "CashManagement.controller.Banks",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Bank Accounts",module : "Cash Management",expanded : false,iconCls : "small-screen",type : "Screen",command : "CashManagement.controller.BankAccounts",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Bank File Formats",module : "Cash Management",expanded : false,iconCls : "small-screen",type : "Screen",command : "CashManagement.controller.BankFileFormat",leaf : true,enable : false,visible : true,isLegacy : false,override : false}]}]},{moduleName : "Accounts Payable",module : "Accounts Payable",expanded : false,iconCls : "small-folder",expandCls : "small-screen-legacy",collapsedCls : "small-folder",type : "Folder",leaf : false,enable : false,visible : true,isLegacy : false,override : false,"children": [{moduleName : "Activities",module : "Accounts Payable",expanded : true,iconCls : "small-folder",expandCls : "small-screen-legacy",collapsedCls : "small-folder",type : "Folder",leaf : false,enable : false,visible : true,isLegacy : false,override : false,"children": [{moduleName : "Pay Bills",module : "Accounts Payable",expanded : false,iconCls : "small-screen",type : "Screen",command : "AccountsPayable.controller.PayBillsDetail",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Pay Bills (Multi-Vendor)",module : "Accounts Payable",expanded : false,iconCls : "small-screen",type : "Screen",command : "AccountsPayable.controller.PayBill",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Bill Batch Entry",module : "Accounts Payable",expanded : false,iconCls : "small-screen",type : "Screen",command : "AccountsPayable.controller.BillBatch",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Batch Post",module : "Accounts Payable",expanded : false,iconCls : "small-screen",type : "Screen",command : "AccountsPayable.controller.BatchPosting",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Print Checks",module : "Accounts Payable",expanded : false,iconCls : "small-screen",type : "Screen",command : "AccountsPayable.controller.PrintChecks",leaf : true,enable : false,visible : false,isLegacy : false,override : false},{moduleName : "Paid Bills History",module : "Accounts Payable",expanded : false,iconCls : "small-screen",type : "Screen",leaf : true,enable : false,visible : false,isLegacy : false,override : false},{moduleName : "Import Bills from Origin",module : "Accounts Payable",expanded : false,iconCls : "small-screen",type : "Screen",command : "AccountsPayable.controller.ImportAPInvoice",leaf : true,enable : false,visible : true,isLegacy : false,override : false}]},{moduleName : "Maintenance",module : "Accounts Payable",expanded : false,iconCls : "small-folder",expandCls : "small-screen-legacy",collapsedCls : "small-folder",type : "Folder",leaf : false,enable : false,visible : true,isLegacy : false,override : false,"children": [{moduleName : "Vendors",module : "Accounts Payable",expanded : false,iconCls : "small-screen",type : "Screen",command : "AccountsPayable.controller.Vendor",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Posted Payables",module : "Accounts Payable",expanded : false,iconCls : "small-screen",type : "Screen",leaf : true,enable : false,visible : false,isLegacy : false,override : false}]},{moduleName : "Reports",module : "Accounts Payable",expanded : false,iconCls : "small-folder",expandCls : "small-screen-legacy",collapsedCls : "small-folder",type : "Folder",leaf : false,enable : false,visible : true,isLegacy : false,override : false,"children": [{moduleName : "Open Payables",module : "Accounts Payable",expanded : false,iconCls : "small-report",type : "Report",leaf : true,enable : false,visible : false,isLegacy : false,override : false},{moduleName : "Vendor History",module : "Accounts Payable",expanded : false,iconCls : "small-report",type : "Report",leaf : true,enable : false,visible : false,isLegacy : false,override : false},{moduleName : "Cash Requirements",module : "Accounts Payable",expanded : false,iconCls : "small-report",type : "Report",leaf : true,enable : false,visible : false,isLegacy : false,override : false},{moduleName : "Check History Payment Detail",module : "Accounts Payable",expanded : false,iconCls : "small-report",type : "Report",leaf : true,enable : false,visible : false,isLegacy : false,override : false},{moduleName : "Check Register",module : "Accounts Payable",expanded : false,iconCls : "small-report",type : "Report",leaf : true,enable : false,visible : false,isLegacy : false,override : false},{moduleName : "Bill by General Ledger",module : "Accounts Payable",expanded : false,iconCls : "small-report",type : "Report",leaf : true,enable : false,visible : false,isLegacy : false,override : false}]}]},{moduleName : "Customer Portal",module : "Customer Portal",expanded : false,iconCls : "small-folder",expandCls : "small-screen-legacy",collapsedCls : "small-folder",type : "Folder",leaf : false,enable : false,visible : true,isLegacy : false,override : false,"children": [{moduleName : "Billing Account",module : "Customer Portal",expanded : false,iconCls : "small-folder",expandCls : "small-screen-legacy",collapsedCls : "small-folder",type : "Folder",leaf : false,enable : false,visible : true,isLegacy : false,override : false,"children": [{moduleName : "Billing Account",module : "Customer Portal",expanded : false,iconCls : "small-screen",type : "Screen",command : "CustomerPortal.controller.BillingAccount",leaf : true,enable : false,visible : false,isLegacy : false,override : false},{moduleName : "Invoices Credits",module : "Customer Portal",expanded : false,iconCls : "small-screen",type : "Screen",command : "CustomerPortal.controller.InvoicesCredits",leaf : true,enable : false,visible : false,isLegacy : false,override : false},{moduleName : "Payments",module : "Customer Portal",expanded : false,iconCls : "small-screen",type : "Screen",command : "CustomerPortal.controller.Payments",leaf : true,enable : false,visible : false,isLegacy : false,override : false},{moduleName : "Purchases",module : "Customer Portal",expanded : false,iconCls : "small-screen",type : "Screen",command : "CustomerPortal.controller.Purchases",leaf : true,enable : false,visible : false,isLegacy : false,override : false},{moduleName : "Orders",module : "Customer Portal",expanded : false,iconCls : "small-screen",type : "Screen",command : "CustomerPortal.controller.Orders",leaf : true,enable : false,visible : false,isLegacy : false,override : false},{moduleName : "Contracts",module : "Customer Portal",expanded : false,iconCls : "small-screen",type : "Screen",command : "CustomerPortal.controller.Contracts",leaf : true,enable : false,visible : false,isLegacy : false,override : false},{moduleName : "Business Summary",module : "Customer Portal",expanded : false,iconCls : "small-screen",type : "Screen",command : "CustomerPortal.controller.BusinessSummary",leaf : true,enable : false,visible : false,isLegacy : false,override : false}]},{moduleName : "Grain Account",module : "Customer Portal",expanded : false,iconCls : "small-folder",expandCls : "small-screen-legacy",collapsedCls : "small-folder",type : "Folder",leaf : false,enable : false,visible : true,isLegacy : false,override : false,"children": [{moduleName : "Grain Account",module : "Customer Portal",expanded : false,iconCls : "small-screen",type : "Screen",command : "CustomerPortal.controller.GrainAccount",leaf : true,enable : false,visible : false,isLegacy : false,override : false},{moduleName : "Settlements",module : "Customer Portal",expanded : false,iconCls : "small-screen",type : "Screen",command : "CustomerPortal.controller.Settlements",leaf : true,enable : false,visible : false,isLegacy : false,override : false},{moduleName : "Storage",module : "Customer Portal",expanded : false,iconCls : "small-screen",type : "Screen",command : "CustomerPortal.controller.Storage",leaf : true,enable : false,visible : false,isLegacy : false,override : false},{moduleName : "Contracts",module : "Customer Portal",expanded : false,iconCls : "small-screen",type : "Screen",command : "CustomerPortal.controller.GAContracts",leaf : true,enable : false,visible : false,isLegacy : false,override : false},{moduleName : "Production History",module : "Customer Portal",expanded : false,iconCls : "small-screen",type : "Screen",command : "CustomerPortal.controller.ProductionHistory",leaf : true,enable : false,visible : false,isLegacy : false,override : false},{moduleName : "Options",module : "Customer Portal",expanded : false,iconCls : "small-screen",type : "Screen",command : "CustomerPortal.controller.Options",leaf : true,enable : false,visible : false,isLegacy : false,override : false},{moduleName : "Current Cash Bids",module : "Customer Portal",expanded : false,iconCls : "small-screen",type : "Screen",command : "CustomerPortal.controller.CurrentCashBids",leaf : true,enable : false,visible : true,isLegacy : false,override : false},{moduleName : "Business Summary",module : "Customer Portal",expanded : false,iconCls : "small-screen",type : "Screen",command : "CustomerPortal.controller.GABusinessSummary",leaf : true,enable : false,visible : false,isLegacy : false,override : false}]}]}]}', 6)
--	SET IDENTITY_INSERT [dbo].[tblSMMenu] OFF
--GO
	PRINT N'END INSERT DEFAULT MASTER MENU'
GO
	PRINT N'INSERT MASTER MENU FOR THE FIRST TIME ONLY'
GO
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Bank File Formats'	AND strModuleName = 'Cash Management' AND (strCommand = 'CashManagement.controller.BankFileFormat' OR strCommand = 'CashManagement.view.BankFileFormat'))
	BEGIN
		DELETE FROM tblSMMasterMenu

		SET IDENTITY_INSERT tblSMMasterMenu ON
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (1, N'Admin', N'System Manager', 0, N'Admin', N'Folder', N'i21', N'small-folder', 1, 0, 0, 0, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (2, N'User Security', N'System Manager', 1, N'User Security', N'Screen', N'i21.controller.UserSecurity', N'small-screen', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (3, N'User Roles', N'System Manager', 1, N'User Roles', N'Screen', N'i21.controller.UserRole', N'small-screen', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (4, N'Report Manager', N'System Manager', 1, N'Report Manager', N'Screen', N'Reports.controller.ReportManager', N'small-screen', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (5, N'Motor Fuel Tax Cycle', N'System Manager', 1, N'Motor Fuel Tax Cycle', N'Screen', N'Reports.controller.RunTaxCycle', N'small-screen', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (6, N'Company Preferences', N'System Manager', 1, N'Company Preferences', N'Screen', N'i21.controller.CompanyPreferences', N'small-screen', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (7, N'Starting Numbers', N'System Manager', 1, N'Starting Numbers', N'Screen', N'i21.controller.StartingNumbers', N'small-screen', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (8, N'Custom Fields', N'System Manager', 1, N'Custom Fields', N'Screen', N'GlobalComponentEngine.controller.CustomField', N'small-screen', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (9, N'Customer Portal User Configuration', N'Customer Portal', 1, N'Customer Portal User Configuration', N'Screen', N'CustomerPortal.controller.CustomerPortalUserConfiguration', N'small-screen', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (10, N'Utilities', N'System Manager', 1, N'Utilities', N'Folder', N'', N'small-folder', 1, 0, 0, 0, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (11, N'Origin Conversions', N'System Manager', 10, N'Origin Conversions', N'Screen', N'i21.controller.OriginUtility', N'small-screen', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (12, N'Import Legacy Users', N'System Manager', 10, N'Import Legacy Users', N'Screen', N'i21.controller.ImportLegacyUsers', N'small-screen', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (13, N'Common Info', N'System Manager', 0, N'Common Info', N'Folder', N'', N'small-folder', 1, 0, 0, 0, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (14, N'Country', N'System Manager', 13, N'Country', N'Screen', N'i21.controller.Country', N'small-screen', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (15, N'Zip Code', N'System Manager', 13, N'Zip Code', N'Screen', N'i21.controller.ZipCode', N'small-screen', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (16, N'Currency', N'System Manager', 13, N'Currency', N'Screen', N'i21.controller.Currency', N'small-screen', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (17, N'Ship Via', N'System Manager', 13, N'Ship Via', N'Screen', N'i21.controller.ShipVia', N'small-screen', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (18, N'Payment Methods', N'System Manager', 13, N'Payment Methods', N'Screen', N'i21.controller.PaymentMethod', N'small-screen', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (19, N'Terms', N'System Manager', 13, N'Terms', N'Screen', N'i21.controller.Term', N'small-screen', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (20, N'Dashboard', N'Dashboard', 0, N'Dashboard', N'Folder', N'', N'small-folder', 1, 0, 0, 0, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (21, N'Add Panel', N'Dashboard', 20, N'Add Panel', N'Screen', N'Dashboard.Controller.PanelSettings', N'small-screen', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (22, N'Connections', N'Dashboard', 20, N'Connections', N'Screen', N'Dashboard.Controller.DashboardConnection', N'small-screen', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (23, N'Panels', N'Dashboard', 20, N'Panels', N'Screen', N'Dashboard.Controller.PanelList', N'small-screen', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (24, N'Panel Layout', N'Dashboard', 20, N'Panel Layout', N'Screen', N'Dashboard.Controller.PanelLayout', N'small-screen', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (25, N'Tabs', N'Dashboard', 20, N'Tabs', N'Screen', N'Dashboard.Controller.TabSetup', N'small-screen', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (26, N'General Ledger', N'General Ledger', 0, N'General Ledger', N'Folder', N'', N'small-folder', 1, 0, 0, 0, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (27, N'Activities', N'General Ledger', 26, N'Activities', N'Folder', N'GeneralLedger', N'small-folder', 1, 0, 0, 0, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (28, N'General Journal', N'General Ledger', 27, N'General Journal', N'Screen', N'GeneralLedger.view.GeneralJournal', N'small-screen', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (29, N'GL Account Detail', N'General Ledger', 27, N'GL Account Detail', N'Screen', N'GeneralLedger.controller.GLAccountDetail', N'small-screen', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (30, N'Batch Posting', N'General Ledger', 27, N'Batch Posting', N'Screen', N'GeneralLedger.controller.GLBatchPosting', N'small-screen', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (31, N'Reminder List', N'General Ledger', 27, N'Reminder List', N'Screen', N'GeneralLedger.controller.ReminderList', N'small-screen', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (32, N'Import Budget from CSV', N'General Ledger', 27, N'Import Budget from CSV', N'Screen', N'GeneralLedger.controller.ImportBudgetFromCSV', N'small-screen', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (33, N'Import GL from Subledger', N'General Ledger', 27, N'Import GL from Subledger', N'Screen', N'GeneralLedger.controller.ImportFromSubledger', N'small-screen', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (34, N'Import GL from CSV', N'General Ledger', 27, N'Import GL from CSV', N'Screen', N'GeneralLedger.controller.ImportFromCSV', N'small-screen', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (35, N'GL Import Logs', N'General Ledger', 27, N'GL Import Logs', N'Screen', N'GeneralLedger.controller.ImportLogs', N'small-screen', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (36, N'Maintenance', N'General Ledger', 26, N'Maintenance', N'Folder', N'GeneralLedger', N'small-folder', 1, 0, 0, 0, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (37, N'Chart of Accounts', N'General Ledger', 36, N'Chart of Accounts', N'Screen', N'GeneralLedger.controller.ChartOfAccounts', N'small-screen', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (38, N'Account Structure', N'General Ledger', 36, N'Account Structure', N'Screen', N'GeneralLedger.view.AccountStructure', N'small-screen', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (39, N'Account Groups', N'General Ledger', 36, N'Account Groups', N'Screen', N'GeneralLedger.controller.AccountGroups', N'small-screen', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (40, N'Segment Accounts', N'General Ledger', 36, N'Segment Accounts', N'Screen', N'GeneralLedger.controller.SegmentAccounts', N'small-screen', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (41, N'Build Accounts', N'General Ledger', 36, N'Build Accounts', N'Screen', N'GeneralLedger.controller.BuildAccounts', N'small-screen', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (43, N'Clone Account', N'General Ledger', 36, N'Clone Account', N'Screen', N'GeneralLedger.view.AccountClone', N'small-screen', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (44, N'Fiscal Year', N'General Ledger', 36, N'Fiscal Year', N'Screen', N'GeneralLedger.controller.FiscalYear', N'small-screen', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (45, N'Account Adjustment', N'General Ledger', 36, N'Account Adjustment', N'Screen', N'GeneralLedger.controller.GLAccountAdjustment', N'small-screen', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (46, N'Reallocation', N'General Ledger', 36, N'Reallocation', N'Screen', N'GeneralLedger.controller.Reallocation', N'small-screen', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (47, N'Recurring Journal', N'General Ledger', 36, N'Recurring Journal', N'Screen', N'GeneralLedger.controller.RecurringJournal', N'small-screen', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (48, N'Recurring Journal History', N'General Ledger', 36, N'Recurring Journal History', N'Screen', N'GeneralLedger.controller.RecurringJournalHistory', N'small-screen', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (49, N'Financial Reports', N'General Ledger', 26, N'Financial Reports', N'Folder', N'FinancialReportDesigner', N'small-folder', 1, 0, 0, 0, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (50, N'Financial Reports', N'General Ledger', 49, N'Financial Reports', N'Screen', N'FinancialReportDesigner.controller.FinancialReports', N'small-screen', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (51, N'Financial Report Designer', N'General Ledger', 49, N'Financial Report Designer', N'Folder', N'FinancialReportDesigners', N'small-folder', 1, 0, 0, 0, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (52, N'Row Designer', N'General Ledger', 51, N'Row Designer', N'Screen', N'FinancialReportDesigner.controller.RowDesigner', N'small-screen', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (53, N'Column Designer', N'General Ledger', 51, N'Column Designer', N'Screen', N'FinancialReportDesigner.controller.ColumnDesigner', N'small-screen', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (54, N'Report Header and Footer', N'General Ledger', 51, N'Report Header and Footer', N'Screen', N'FinancialReportDesigner.controller.HeaderDesigner', N'small-screen', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (55, N'Financial Report Builder', N'General Ledger', 51, N'Financial Report Builder', N'Screen', N'FinancialReportDesigner.controller.ReportBuilder', N'small-screen', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (56, N'Report Templates', N'General Ledger', 51, N'Report Templates', N'Screen', N'FinancialReportDesigner.controller.Templates', N'small-screen', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (57, N'Reports', N'General Ledger', 26, N'Reports', N'Folder', N'', N'small-folder', 1, 0, 0, 0, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (58, N'Reallocation', N'General Ledger', 57, N'Reallocation', N'Report', N'Reallocation', N'small-report', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (59, N'Chart of Accounts', N'General Ledger', 57, N'Chart of Accounts', N'Report', N'Chart of Accounts', N'small-report', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (60, N'Chart of Accounts Adjustment', N'General Ledger', 57, N'Chart of Accounts Adjustment', N'Report', N'Chart of Accounts Adjustment', N'small-report', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (61, N'General Ledger by Account ID Detail', N'General Ledger', 57, N'General Ledger by Account ID Detail', N'Report', N'General Ledger by Account ID Detail', N'small-report', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (62, N'Balance Sheet Standard', N'General Ledger', 57, N'Balance Sheet Standard', N'Report', N'Balance Sheet Standard', N'small-report', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (63, N'Income Statement Standard', N'General Ledger', 57, N'Income Statement Standard', N'Report', N'Income Statement Standard', N'small-report', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (64, N'Trial Balance', N'General Ledger', 57, N'Trial Balance', N'Report', N'Trial Balance', N'small-report', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (65, N'Trial Balance Detail', N'General Ledger', 57, N'Trial Balance Detail', N'Report', N'Trial Balance Detail', N'small-report', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (66, N'Tank Management', N'Tank Management', 0, N'Tank Management', N'Folder', N'', N'small-folder', 1, 0, 0, 0, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (67, N'Activities', N'Tank Management', 66, N'Activities', N'Folder', N'TankManagement', N'small-folder', 1, 1, 0, 0, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (68, N'Customer Inquiry', N'Tank Management', 67, N'Customer Inquiry', N'Screen', N'TankManagement.controller.CustomerInquiry', N'small-screen', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (69, N'Consumption Sites', N'Tank Management', 67, N'Consumption Sites', N'Screen', N'TankManagement.controller.ConsumptionSite', N'small-screen', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (70, N'Clock Reading', N'Tank Management', 67, N'Clock Reading', N'Screen', N'TankManagement.controller.ClockReading', N'small-screen', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (71, N'Synchronize Delivery History', N'Tank Management', 67, N'Synchronize Delivery History', N'Screen', N'TankManagement.controller.SyncDeliveryHistory', N'small-screen', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (72, N'Lease Billing', N'Tank Management', 67, N'Lease Billing', N'Screen', N'TankManagement.controller.LeaseBilling', N'small-screen', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (73, N'Dispatch Deliveries', N'Tank Management', 67, N'Dispatch Deliveries', N'Screen', N'TankManagement.controller.DispatchDelivery', N'small-screen', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (74, N'Maintenance', N'Tank Management', 66, N'Maintenance', N'Folder', N'TankManagement', N'small-folder', 1, 0, 0, 0, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (75, N'Degree Day Clock', N'Tank Management', 74, N'Degree Day Clock', N'Screen', N'TankManagement.controller.DegreeDayClock', N'small-screen', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (76, N'Devices', N'Tank Management', 74, N'Devices', N'Screen', N'TankManagement.controller.Device', N'small-screen', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (77, N'Events', N'Tank Management', 74, N'Events', N'Screen', N'TankManagement.controller.Event', N'small-screen', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (78, N'Event Type', N'Tank Management', 74, N'Event Type', N'Screen', N'TankManagement.controller.EventType', N'small-screen', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (79, N'Device Type', N'Tank Management', 74, N'Device Type', N'Screen', N'TankManagement.controller.DeviceType', N'small-screen', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (80, N'Lease Code', N'Tank Management', 74, N'Lease Code', N'Screen', N'TankManagement.controller.LeaseCode', N'small-screen', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (81, N'Event Automation Setup', N'Tank Management', 74, N'Event Automation Setup', N'Screen', N'TankManagement.controller.EventAutomation', N'small-screen', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (82, N'Meter Type', N'Tank Management', 74, N'Meter Type', N'Screen', N'TankManagement.controller.MeterType', N'small-screen', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (83, N'Renew Julian Deliveries', N'Tank Management', 74, N'Renew Julian Deliveries', N'Screen', N'TankManagement.controller.RenewJulianDelivery', N'small-screen', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (84, N'Resolve Sync Conflict', N'Tank Management', 74, N'Resolve Sync Conflict', N'Screen', N'TankManagement.controller.ResolveSyncConflict', N'small-screen', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (85, N'Lease Billing Incentive', N'Tank Management', 74, N'Lease Billing Incentive', N'Screen', N'TankManagement.controller.LeaseBillingMinimum', N'small-screen', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (86, N'Reports', N'Tank Management', 66, N'Reports', N'Folder', N'', N'small-folder', 1, 0, 0, 0, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (87, N'Delivery Fill Report', N'Tank Management', 86, N'Delivery Fill Report', N'Report', N'Delivery Fill Report', N'small-report', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (88, N'Two-Part Delivery Fill Report', N'Tank Management', 86, N'Two-Part Delivery Fill Report', N'Report', N'Two-Part Delivery Fill Report', N'small-report', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (89, N'Lease Billing Report', N'Tank Management', 86, N'Lease Billing Report', N'Report', N'Lease Billing Report', N'small-report', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (90, N'Missed Julian Deliveries', N'Tank Management', 86, N'Missed Julian Deliveries', N'Report', N'Missed Julian Deliveries', N'small-report', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (91, N'Out of Range Burn Rates', N'Tank Management', 86, N'Out of Range Burn Rates', N'Report', N'Out of Range Burn Rates', N'small-report', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (92, N'Call Entry Printout', N'Tank Management', 86, N'Call Entry Printout', N'Report', N'Call Entry Printout', N'small-report', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (93, N'Fill Group', N'Tank Management', 86, N'Fill Group', N'Report', N'Fill Group', N'small-report', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (94, N'Tank Inventory', N'Tank Management', 86, N'Tank Inventory', N'Report', N'Tank Inventory', N'small-report', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (95, N'Customer List by Route', N'Tank Management', 86, N'Customer List by Route', N'Report', N'Customer List by Route', N'small-report', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (96, N'Device Actions', N'Tank Management', 86, N'Device Actions', N'Report', N'Device Actions', N'small-report', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (97, N'Open Call Entries', N'Tank Management', 86, N'Open Call Entries', N'Report', N'Open Call Entries', N'small-report', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (98, N'Work Order Status', N'Tank Management', 86, N'Work Order Status', N'Report', N'Work Order Status', N'small-report', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (99, N'Leak Check / Gas Check', N'Tank Management', 86, N'Leak Check / Gas Check', N'Report', N'Leak Check / Gas Check', N'small-report', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (100, N'Cash Management', N'Cash Management', 0, N'Cash Management', N'Folder', N'', N'small-folder', 1, 0, 0, 0, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (101, N'Activities', N'Cash Management', 100, N'Activities', N'Folder', N'', N'small-folder', 1, 0, 0, 0, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (102, N'Bank Deposits', N'Cash Management', 101, N'Bank Deposits', N'Screen', N'CashManagement.controller.BankDeposit', N'small-screen', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (103, N'Bank Transactions', N'Cash Management', 101, N'Bank Transactions', N'Screen', N'CashManagement.controller.BankTransactions', N'small-screen', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (104, N'Bank Transfers', N'Cash Management', 101, N'Bank Transfers', N'Screen', N'CashManagement.controller.BankTransfer', N'small-screen', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (105, N'Miscellaneous Checks', N'Cash Management', 101, N'Miscellaneous Checks', N'Screen', N'CashManagement.controller.MiscellaneousChecks', N'small-screen', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (106, N'Bank Account Register', N'Cash Management', 101, N'Bank Account Register', N'Screen', N'CashManagement.controller.BankAccountRegister', N'small-screen', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (107, N'Bank Reconciliation', N'Cash Management', 101, N'Bank Reconciliation', N'Screen', N'CashManagement.controller.BankReconciliation', N'small-screen', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (108, N'Maintenance', N'Cash Management', 100, N'Maintenance', N'Folder', N'', N'small-folder', 1, 0, 0, 0, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (109, N'Banks', N'Cash Management', 108, N'Banks', N'Screen', N'CashManagement.controller.Banks', N'small-screen', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (110, N'Bank Accounts', N'Cash Management', 108, N'Bank Accounts', N'Screen', N'CashManagement.controller.BankAccounts', N'small-screen', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (111, N'Bank File Formats', N'Cash Management', 108, N'Bank File Formats', N'Screen', N'CashManagement.controller.BankFileFormat', N'small-screen', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (112, N'Accounts Payable', N'Accounts Payable', 0, N'Accounts Payable', N'Folder', N'', N'small-folder', 1, 0, 0, 0, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (113, N'Activities', N'Accounts Payable', 112, N'Activities', N'Folder', N'', N'small-folder', 1, 0, 0, 0, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (114, N'Pay Bills', N'Accounts Payable', 113, N'Pay Bills', N'Screen', N'AccountsPayable.controller.PayBillsDetail', N'small-screen', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (115, N'Pay Bills (Multi-Vendor)', N'Accounts Payable', 113, N'Pay Bills (Multi-Vendor)', N'Screen', N'AccountsPayable.controller.PayBill', N'small-screen', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (116, N'Bill Batch Entry', N'Accounts Payable', 113, N'Bill Batch Entry', N'Screen', N'AccountsPayable.controller.BillBatch', N'small-screen', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (117, N'Batch Posting', N'Accounts Payable', 113, N'Batch Posting', N'Screen', N'AccountsPayable.controller.BatchPosting', N'small-screen', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (118, N'Print Checks', N'Accounts Payable', 113, N'Print Checks', N'Screen', N'', N'small-screen', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (119, N'Paid Bills History', N'Accounts Payable', 113, N'Shows all the payments', N'Screen', N'AccountsPayable.view.PaidBillsHistory', N'small-screen', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (120, N'Import Bills from Origin', N'Accounts Payable', 113, N'Import Bills from Origin', N'Screen', N'AccountsPayable.controller.ImportAPInvoice', N'small-screen', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (121, N'Maintenance', N'Accounts Payable', 112, N'Maintenance', N'Folder', N'', N'small-folder', 1, 0, 0, 0, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (122, N'Vendors', N'Accounts Payable', 121, N'Vendors', N'Screen', N'AccountsPayable.controller.Vendor', N'small-screen', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (123, N'Posted Payables', N'Accounts Payable', 121, N'Posted Payables', N'Screen', N'', N'small-screen', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (124, N'Reports', N'Accounts Payable', 112, N'Reports', N'Folder', N'', N'small-folder', 1, 0, 0, 0, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (125, N'Open Payables', N'Accounts Payable', 124, N'Open Payables', N'Report', N'', N'small-report', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (126, N'Vendor History', N'Accounts Payable', 124, N'Vendor History', N'Report', N'', N'small-report', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (127, N'Cash Requirements', N'Accounts Payable', 124, N'Cash Requirements', N'Report', N'', N'small-report', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (128, N'Check History Payment Detail', N'Accounts Payable', 124, N'Check History Payment Detail', N'Report', N'', N'small-report', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (129, N'Check Register', N'Accounts Payable', 124, N'Check Register', N'Report', N'', N'small-report', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (130, N'Bill by General Ledger', N'Accounts Payable', 124, N'Bill by General Ledger', N'Report', N'', N'small-report', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (131, N'Accounts Receivable', N'Accounts Receivable', 0, N'Accounts Receivable', N'Folder', N'', N'small-folder', 1, 0, 0, 0, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (132, N'Activities', N'Accounts Receivable', 131, N'Activities', N'Folder', N'', N'small-folder', 1, 0, 0, 0, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (133, N'Maintenance', N'Accounts Receivable', 131, N'Maintenance', N'Folder', N'', N'small-folder', 1, 0, 0, 0, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (134, N'Customers', N'Accounts Receivable', 133, N'Customers', N'Screen', N'AccountsReceivable.controller.Customer', N'small-screen', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (135, N'Customer Contact List', N'Accounts Receivable', 133, N'Customer Contact List', N'Screen', N'AccountsReceivable.controller.CustomerContactList', N'small-screen', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (136, N'Salesperson', N'Accounts Receivable', 133, N'Salesperson', N'Screen', N'AccountsReceivable.controller.Salesperson', N'small-screen', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (137, N'Market Zone', N'Accounts Receivable', 133, N'Market Zone', N'Screen', N'AccountsReceivable.controller.MarketZone', N'small-screen', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (138, N'Statement Footer Message', N'Accounts Receivable', 133, N'Statement Footer Message', N'Screen', N'AccountsReceivable.controller.StatementFooter', N'small-screen', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (139, N'Service Charge', N'Accounts Receivable', 133, N'Service Charge', N'Screen', N'AccountsReceivable.controller.ServiceCharge', N'small-screen', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (140, N'Customer Group', N'Accounts Receivable', 133, N'Customer Group', N'Screen', N'AccountsReceivable.controller.CustomerGroup', N'small-screen', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (141, N'Help Desk', N'Help Desk', 0, N'Help Desk', N'Folder', N'HelpDesk', N'small-folder', 1, 0, 0, 0, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (142, N'Activities', N'Help Desk', 141, N'Activities', N'Folder', N'HelpDesk', N'small-folder', 1, 0, 0, 0, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (143, N'Tickets', N'Help Desk', 142, N'Tickets', N'Screen', N'HelpDesk.controller.Ticket', N'small-screen', 0, 0, 0, 1, 2, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (144, N'Open Tickets', N'Help Desk', 142, N'Open Tickets', N'Screen', N'HelpDesk.controller.OpenTicket', N'small-screen', 0, 0, 0, 1, 3, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (145, N'Tickets Assigned to Me', N'Help Desk', 142, N'Tickets Assigned to Me', N'Screen', N'HelpDesk.controller.TicketAssigned', N'small-screen', 0, 0, 0, 1, 4, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (146, N'Create Ticket', N'Help Desk', 142, N'Create Ticket', N'Screen', N'HelpDesk.controller.CreateTicket', N'small-screen', 0, 0, 0, 1, 1, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (147, N'Maintenance', N'Help Desk', 141, N'Maintenance', N'Folder', N'HelpDesk', N'small-folder', 1, 0, 0, 0, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (148, N'Ticket Groups', N'Help Desk', 147, N'Ticket Groups', N'Screen', N'HelpDesk.controller.TicketGroup', N'small-screen', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (149, N'Ticket Types', N'Help Desk', 147, N'Ticket Types', N'Screen', N'HelpDesk.controller.TicketType', N'small-screen', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (150, N'Ticket Statuses', N'Help Desk', 147, N'Ticket Statuses', N'Screen', N'HelpDesk.controller.TicketStatus', N'small-screen', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (151, N'Ticket Priorities', N'Help Desk', 147, N'Ticket Priorities', N'Screen', N'HelpDesk.controller.TicketPriority', N'small-screen', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (152, N'Ticket Job Codes', N'Help Desk', 147, N'Ticket Job Codes', N'Screen', N'HelpDesk.controller.TicketJobCode', N'small-screen', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (153, N'Products', N'Help Desk', 147, N'Products', N'Screen', N'HelpDesk.controller.Product', N'small-screen', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (154, N'Help Desk Settings', N'Help Desk', 147, N'Help Desk Settings', N'Screen', N'HelpDesk.controller.HelpDeskSettings', N'small-screen', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (155, N'Email Setup', N'Help Desk', 147, N'Email Setup', N'Screen', N'HelpDesk.controller.EmailSetup', N'small-screen', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (156, N'Customer Portal', N'Customer Portal', 0, N'Customer Portal', N'Folder', N'', N'small-folder', 1, 0, 0, 0, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (157, N'Help Desk', N'Help Desk', 156, N'Help Desk', N'Folder', N'HelpDesk', N'small-folder', 1, 0, 0, 0, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (158, N'Tickets', N'Help Desk', 157, N'Tickets', N'Screen', N'HelpDesk.controller.Ticket', N'small-screen', 0, 0, 0, 1, 2, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (159, N'Open Tickets', N'Help Desk', 157, N'Open Tickets', N'Screen', N'HelpDesk.controller.OpenTicket', N'small-screen', 0, 0, 0, 1, 3, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (160, N'Tickets Assigned to Me', N'Help Desk', 157, N'Tickets Assigned to Me', N'Screen', N'HelpDesk.controller.TicketAssigned', N'small-screen', 0, 0, 0, 1, 4, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (161, N'Create Ticket', N'Help Desk', 157, N'Create Ticket', N'Screen', N'HelpDesk.controller.CreateTicket', N'small-screen', 0, 0, 0, 1, 1, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (162, N'Billing Account', N'Customer Portal', 156, N'Billing Account', N'Folder', N'', N'small-folder', 1, 0, 0, 0, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (163, N'Billing Account', N'Customer Portal', 162, N'Billing Account', N'Screen', N'CustomerPortal.controller.BillingAccount', N'small-screen', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (164, N'Invoices Credits', N'Customer Portal', 162, N'Invoices Credits', N'Screen', N'CustomerPortal.controller.InvoicesCredits', N'small-screen', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (165, N'Payments', N'Customer Portal', 162, N'Payments', N'Screen', N'CustomerPortal.controller.Payments', N'small-screen', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (166, N'Purchases', N'Customer Portal', 162, N'Purchases', N'Screen', N'CustomerPortal.controller.Purchases', N'small-screen', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (167, N'Orders', N'Customer Portal', 162, N'Orders', N'Screen', N'CustomerPortal.controller.Orders', N'small-screen', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (168, N'Contracts', N'Customer Portal', 162, N'Contracts', N'Screen', N'CustomerPortal.controller.Contracts', N'small-screen', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (169, N'Business Summary', N'Customer Portal', 162, N'Business Summary', N'Screen', N'CustomerPortal.controller.BusinessSummary', N'small-screen', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (170, N'Grain Account', N'Customer Portal', 156, N'Grain Account', N'Folder', N'', N'small-folder', 1, 0, 0, 0, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (171, N'Grain Account', N'Customer Portal', 170, N'Grain Account', N'Screen', N'CustomerPortal.controller.GrainAccount', N'small-screen', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (172, N'Settlements', N'Customer Portal', 170, N'Settlements', N'Screen', N'CustomerPortal.controller.Settlements', N'small-screen', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (173, N'Storage', N'Customer Portal', 170, N'Storage', N'Screen', N'CustomerPortal.controller.Storage', N'small-screen', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (174, N'Contracts', N'Customer Portal', 170, N'Contracts', N'Screen', N'CustomerPortal.controller.GAContracts', N'small-screen', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (175, N'Production History', N'Customer Portal', 170, N'Production History', N'Screen', N'CustomerPortal.controller.ProductionHistory', N'small-screen', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (176, N'Options', N'Customer Portal', 170, N'Options', N'Screen', N'CustomerPortal.controller.Options', N'small-screen', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (177, N'Current Cash Bids', N'Customer Portal', 170, N'Current Cash Bids', N'Screen', N'CustomerPortal.controller.CurrentCashBids', N'small-screen', 0, 0, 0, 1, NULL, 1)
		INSERT [dbo].[tblSMMasterMenu] ([intMenuID], [strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (178, N'Business Summary', N'Customer Portal', 170, N'Business Summary', N'Screen', N'CustomerPortal.controller.GABusinessSummary', N'small-screen', 0, 0, 0, 1, NULL, 1)
		SET IDENTITY_INSERT tblSMMasterMenu OFF
	END
GO
	PRINT N'END INSERT MASTER MENU FOR THE FIRST TIME ONLY'
GO
	IF EXISTS (SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Connections' AND strModuleName = 'Dashboard' AND strType = 'Screen' AND strCommand = 'Reports.Controller.Connection')
	UPDATE tblSMMasterMenu
	SET strCommand = 'Dashboard.Controller.DashboardConnection'
	WHERE strMenuName = 'Connections' AND strModuleName = 'Dashboard' AND strType = 'Screen'
GO
	IF EXISTS (SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Common Info' AND strModuleName = 'System Manager' AND strType = 'Folder' AND intParentMenuID = 1)
	UPDATE tblSMMasterMenu
	SET intParentMenuID = 0
	WHERE strMenuName = 'Common Info' AND strModuleName = 'System Manager' AND strType = 'Folder'
GO
	IF EXISTS (SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Bill by General Ledger' AND strType = 'Report' AND strModuleName = 'Accounts Payable')
	UPDATE tblSMMasterMenu
	SET strMenuName = 'AP Transactions by GL Account'
	WHERE strMenuName = 'Bill by General Ledger' AND strType = 'Report' AND strModuleName = 'Accounts Payable'
GO
	IF EXISTS (SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Check History Payment Detail' AND strType = 'Report' AND strModuleName = 'Accounts Payable')
	DELETE FROM tblSMMasterMenu
	WHERE strMenuName = 'Check History Payment Detail' AND strType = 'Report' AND strModuleName = 'Accounts Payable'
GO
	UPDATE tblSMMasterMenu
	SET strCommand = REPLACE(strCommand, 'Dashboard.Controller', 'Dashboard.controller')
	WHERE strModuleName = 'Dashboard'
GO
-- moved to 14.3
GO
	-- DELETE FROM tblSMMasterMenu where strMenuName = 'Paid Bills History' and strModuleName = 'Accounts Payable' and strType = 'Screen' 
	DELETE FROM tblSMMasterMenu where strMenuName = 'Posted Payables' and strModuleName = 'Accounts Payable' and strType = 'Screen' 

	UPDATE tblSMMasterMenu
	SET strMenuName = 'Batch Posting',
		strDescription = 'Batch Posting'
	WHERE strModuleName = 'Accounts Payable' AND strType = 'Screen'  AND strMenuName LIKE '%Batch Post%'

	IF NOT EXISTS(SELECT 1 FROM tblSMMasterMenu where strMenuName = 'Paid Bills History' and strModuleName = 'Accounts Payable' and strType = 'Screen')
	BEGIN
		INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (N'Paid Bills History', N'Accounts Payable', 113, N'Shows all the payments', N'Screen', N'AccountsPayable.view.PaidBillsHistory', N'small-screen', 1, 0, 0, 1, NULL, 1)
	END

	IF NOT EXISTS(SELECT 1 FROM tblSMMasterMenu where strMenuName = 'Recurring Transactions' and strModuleName = 'Accounts Payable' and strType = 'Screen')
	BEGIN
		INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (N'Recurring Transactions', N'Accounts Payable', 113, N'', N'Screen', N'AccountsPayable.view.RecurringTransaction', N'small-screen', 1, 0, 0, 1, NULL, 1)
	END

	IF NOT EXISTS(SELECT 1 FROM tblSMMasterMenu where strMenuName = 'Purchase Order' and strModuleName = 'Accounts Payable' and strType = 'Screen')
	BEGIN
		INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (N'Purchase Order', N'Accounts Payable', 113, N'', N'Screen', N'AccountsPayable.view.PurchaseOrder', N'small-screen', 1, 0, 0, 1, NULL, 1)
	END
GO
--update missing commands
	UPDATE tblSMMasterMenu
	SET strCommand = 'AccountsPayable.controller.PrintChecks'
	where strMenuName = 'Print Checks' and strModuleName = 'Accounts Payable' and strType = 'Screen' and strCommand = ''
GO
	UPDATE tblSMMasterMenu
	SET strCommand = strMenuName
	WHERE 
		strMenuName in ('Open Payables', 'Vendor History', 'Cash Requirements', 'Check Register', 'AP Transactions by GL Account')
		AND strType = 'Report'
		AND strCommand = ''
GO
	IF EXISTS(SELECT * FROM tblSMMasterMenu WHERE strMenuName = 'Import Legacy Users' AND strModuleName = 'System Manager' AND strType = 'Screen')
	UPDATE tblSMMasterMenu 
	SET strMenuName = 'Import Origin Users'
	WHERE strMenuName = 'Import Legacy Users' AND strModuleName = 'System Manager' AND strType = 'Screen'
GO
	IF NOT EXISTS(SELECT * FROM tblSMMasterMenu WHERE strMenuName = 'Company Location' AND strType = 'Screen' AND strModuleName = 'System Manager')
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (N'Company Location', N'System Manager', 13, N'Company Location', N'Screen', N'i21.controller.CompanyLocation', N'small-screen', 0, 0, 0, 1, NULL, 1)
GO
	UPDATE tblSMMasterMenu
	SET strCommand = 'HelpDesk.controller.CPTickets'
	WHERE strMenuName = 'Tickets'
	AND strCommand = 'HelpDesk.controller.Ticket'
	AND intParentMenuID = (SELECT intMenuID FROM tblSMMasterMenu
							WHERE strMenuName = 'Help Desk'
							AND intParentMenuID = (SELECT intMenuID FROM tblSMMasterMenu Main 
													WHERE strMenuName = 'Customer Portal'))
GO
	UPDATE tblSMMasterMenu
	SET strCommand = 'HelpDesk.controller.CPOpenTicket'
	WHERE strMenuName = 'Open Tickets'
	AND strCommand = 'HelpDesk.controller.OpenTicket'
	AND intParentMenuID = (SELECT intMenuID FROM tblSMMasterMenu
							WHERE strMenuName = 'Help Desk'
							AND intParentMenuID = (SELECT intMenuID FROM tblSMMasterMenu Main 
													WHERE strMenuName = 'Customer Portal'))
GO
	UPDATE tblSMMasterMenu
	SET strCommand = 'HelpDesk.controller.CPTicketAssigned'
	WHERE strMenuName = 'Tickets Assigned to Me'
	AND strCommand = 'HelpDesk.controller.TicketAssigned'
	AND intParentMenuID = (SELECT intMenuID FROM tblSMMasterMenu
							WHERE strMenuName = 'Help Desk'
							AND intParentMenuID = (SELECT intMenuID FROM tblSMMasterMenu Main 
													WHERE strMenuName = 'Customer Portal'))
GO
	IF NOT EXISTS(SELECT * FROM tblSMMasterMenu WHERE strMenuName = 'On Hold Detail' AND strType = 'Report' AND strModuleName = 'Tank Management')
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (N'On Hold Detail', N'Tank Management', 86, N'On Hold Detail', N'Report', N'On Hold Detail', N'small-report', 0, 0, 0, 1, NULL, 1)
GO
	IF NOT EXISTS(SELECT * FROM tblSMMasterMenu WHERE strMenuName = 'Import Origin Menus' AND strType = 'Screen' AND strModuleName = 'System Manager')
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (N'Import Origin Menus', N'System Manager', 10, N'Import Origin Menus', N'Screen', N'i21.controller.ImportLegacyMenus', N'small-screen', 0, 0, 0, 1, NULL, 1)
GO
	IF NOT EXISTS(SELECT * FROM tblSMMasterMenu WHERE strMenuName = 'Bill Entry' AND strType = 'Screen' AND strModuleName = 'Accounts Payable')
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (N'Bill Entry', N'Accounts Payable', 113, N'Bill Entry', N'Screen', N'AccountsPayable.controller.Bill', N'small-screen', 0, 0, 0, 1, NULL, 1)
GO
	DECLARE @intMenuId INT
	SELECT @intMenuId = intMenuID FROM dbo.tblSMMasterMenu
	WHERE strModuleName = 'General Ledger' AND strMenuName = 'Financial Reports' AND strType = 'Screen'

	UPDATE [dbo].[tblSMMasterMenu]
	SET
		strMenuName = 'Financial Report Viewer',
		strDescription = 'Financial Report Viewer'
	WHERE intMenuID = @intMenuId
GO
	DECLARE @intParent INT
	SELECT @intParent = intMenuID FROM tblSMMasterMenu
	WHERE strMenuName = 'Activities'
	AND strModuleName = 'Help Desk'

	IF NOT EXISTS(SELECT * FROM tblSMMasterMenu WHERE strMenuName = 'Export Hours Worked' AND strType = 'Screen' AND strModuleName = 'Help Desk' AND intParentMenuID = @intParent)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (N'Export Hours Worked', N'Help Desk', @intParent, N'Export Hours Worked', N'Screen', N'HelpDesk.controller.ExportHoursWorked', N'small-screen', 0, 0, 0, 1, NULL, 1)
GO	
	DECLARE @intModule INT, @intParent INT
	SELECT @intModule = intMenuID FROM tblSMMasterMenu Main 
							WHERE strMenuName = 'Cash Management' AND intParentMenuID = 0

	IF NOT EXISTS(SELECT * FROM tblSMMasterMenu WHERE strMenuName = 'Reports' AND strType = 'Folder' AND strModuleName = 'Cash Management')
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (N'Reports', N'Cash Management', @intModule, N'Reports', N'Folder', N'', N'small-folder', 0, 0, 0, 0, 3, 1)
	
	SELECT @intParent = intMenuID FROM tblSMMasterMenu
	WHERE strMenuName = 'Reports' AND strType = 'Folder' AND strModuleName = 'Cash Management'
	AND intParentMenuID = @intModule
	
	IF NOT EXISTS(SELECT * FROM tblSMMasterMenu WHERE strMenuName = 'Check Register' AND strType = 'Report' AND strModuleName = 'Cash Management')
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (N'Check Register', N'Cash Management', @intParent, N'Check Register', N'Report', N'Check Register', N'small-report', 0, 0, 0, 1, NULL, 1)
GO
	DECLARE @intParent INT
	SELECT @intParent = intMenuID FROM tblSMMasterMenu
	WHERE strMenuName = 'Help Desk'
	AND intParentMenuID = (SELECT intMenuID FROM tblSMMasterMenu Main 
							WHERE strMenuName = 'Customer Portal')
							
	IF EXISTS(SELECT * FROM tblSMMasterMenu WHERE strMenuName = 'Export Hours Worked' AND strType = 'Screen' AND strModuleName = 'Help Desk' AND intParentMenuID = @intParent)
	DELETE FROM tblSMMasterMenu WHERE strMenuName = 'Export Hours Worked' AND strType = 'Screen' AND strModuleName = 'Help Desk' AND intParentMenuID = @intParent
GO
	UPDATE tblSMMasterMenu
	SET strMenuName = 'Pay Bill Detail'
	WHERE strModuleName = 'Accounts Payable' AND strMenuName = 'Pay Bills' AND strType = 'Screen' AND strCommand = 'AccountsPayable.controller.PayBillsDetail'

	UPDATE tblSMMasterMenu
	SET strMenuName = 'Pay Bills'
	WHERE strModuleName = 'Accounts Payable' AND strMenuName = 'Pay Bills (Multi-Vendor)' AND strType = 'Screen' AND strCommand = 'AccountsPayable.controller.PayBill'
GO
	/* ---------------------------------------------- */
	/* -- Add Accounts Receivable Activities Menus -- */
	/* ---------------------------------------------- */
	
	DECLARE @rootParentId INT
	DECLARE @activitiesId INT
	DECLARE @maintenanceId INT
	SELECT @rootParentId = intMenuID FROM dbo.tblSMMasterMenu WHERE strModuleName = 'Accounts Receivable'  AND intParentMenuID = 0;
	
	IF NOT EXISTS (SELECT 1 FROM dbo.tblSMMasterMenu WHERE strModuleName = 'Accounts Receivable' AND strMenuName = 'Activities' and intParentMenuID = @rootParentId)
	BEGIN
		INSERT dbo.tblSMMasterMenu(strMenuName, strModuleName, intParentMenuID, strDescription, strType, strCommand, strIcon,ysnVisible, ysnExpanded,ysnIsLegacy,ysnLeaf,intSort,intConcurrencyId)
		VALUES ('Activities','Accounts Receivable',@rootParentId,'Activities','Folder','','small-folder',1,0,0,0,1,1)
	
		UPDATE dbo.tblSMMasterMenu 
		SET intSort = 2
		WHERE strModuleName = 'Accounts Receivable' AND strMenuName = 'Maintenance' and intParentMenuID = @rootParentId
	END

	SELECT @activitiesId = intMenuID FROM dbo.tblSMMasterMenu WHERE strModuleName = 'Accounts Receivable' AND strMenuName = 'Activities' AND intParentMenuID = @rootParentId

	IF NOT EXISTS (SELECT 1 FROM dbo.tblSMMasterMenu WHERE strModuleName = 'Accounts Receivable' AND strMenuName = 'Invoice' AND intParentMenuID = @activitiesId)
	BEGIN
		INSERT dbo.tblSMMasterMenu(strMenuName, strModuleName, intParentMenuID, strDescription, strType, strCommand, strIcon,ysnVisible, ysnExpanded,ysnIsLegacy,ysnLeaf,intSort,intConcurrencyId)
		VALUES ('Invoice','Accounts Receivable',@activitiesId,'Invoice','Screen','AccountsReceivable.view.Invoice','small-screen',1,0,0,1,1,1)
	END

	IF NOT EXISTS (SELECT 1 FROM dbo.tblSMMasterMenu WHERE strModuleName = 'Accounts Receivable' AND strMenuName = 'Import Invoices from Origin' AND intParentMenuID = @activitiesId)
	BEGIN
		INSERT dbo.tblSMMasterMenu(strMenuName, strModuleName, intParentMenuID, strDescription, strType, strCommand, strIcon,ysnVisible, ysnExpanded,ysnIsLegacy,ysnLeaf,intSort,intConcurrencyId)
		VALUES ('Import Invoices from Origin','Accounts Receivable',@activitiesId,'Import Invoices from Origin','Screen','AccountsReceivable.view.ImportInvoices','small-screen',1,0,0,1,2,1)
	END
	
	IF NOT EXISTS (SELECT 1 FROM dbo.tblSMMasterMenu WHERE strModuleName = 'Accounts Receivable' AND strMenuName = 'Credit Memo' AND intParentMenuID = @activitiesId)
	BEGIN
		INSERT dbo.tblSMMasterMenu(strMenuName, strModuleName, intParentMenuID, strDescription, strType, strCommand, strIcon,ysnVisible, ysnExpanded,ysnIsLegacy,ysnLeaf,intSort,intConcurrencyId)
		VALUES ('Credit Memo','Accounts Receivable',@activitiesId,'Credit Memo','Screen','AccountsReceivable.view.CreditMemo','small-screen',1,0,0,1,3,1)
	END	

	IF NOT EXISTS (SELECT 1 FROM dbo.tblSMMasterMenu WHERE strModuleName = 'Accounts Receivable' AND strMenuName = 'Receive Payments' AND intParentMenuID = @activitiesId)
		BEGIN
			INSERT dbo.tblSMMasterMenu(strMenuName, strModuleName, intParentMenuID, strDescription, strType, strCommand, strIcon,ysnVisible, ysnExpanded,ysnIsLegacy,ysnLeaf,intSort,intConcurrencyId)
			VALUES ('Receive Payments','Accounts Receivable',@activitiesId,'Receive Payments','Screen','AccountsReceivable.view.ReceivePayments','small-screen',1,0,0,1,4,1)
		END
	ELSE
		BEGIN
			UPDATE tblSMMasterMenu SET intSort = 4 WHERE strMenuName = 'Receive Payments' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @activitiesId
		END

	IF NOT EXISTS (SELECT 1 FROM dbo.tblSMMasterMenu WHERE strModuleName = 'Accounts Receivable' AND strMenuName = 'Receive Payment Detail' AND intParentMenuID = @activitiesId)
		BEGIN
			INSERT dbo.tblSMMasterMenu(strMenuName, strModuleName, intParentMenuID, strDescription, strType, strCommand, strIcon,ysnVisible, ysnExpanded,ysnIsLegacy,ysnLeaf,intSort,intConcurrencyId)
			VALUES ('Receive Payment Detail','Accounts Receivable',@activitiesId,'Receive Payment Detail','Screen','AccountsReceivable.view.ReceivePaymentsDetail','small-screen',1,0,0,1,5,1)
		END
	ELSE
		BEGIN
			UPDATE tblSMMasterMenu SET intSort = 5 WHERE strMenuName = 'Receive Payment Detail' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @activitiesId
		END

	IF NOT EXISTS (SELECT 1 FROM dbo.tblSMMasterMenu WHERE strModuleName = 'Accounts Receivable' AND strMenuName = 'Batch Posting' AND intParentMenuID = @activitiesId)
		BEGIN
			INSERT dbo.tblSMMasterMenu(strMenuName, strModuleName, intParentMenuID, strDescription, strType, strCommand, strIcon,ysnVisible, ysnExpanded,ysnIsLegacy,ysnLeaf,intSort,intConcurrencyId)
			VALUES ('Batch Posting','Accounts Receivable',@activitiesId,'Batch Posting','Screen','AccountsReceivable.controller.BatchPosting','small-screen',1,0,0,1,6,1)
		END
	ELSE
		BEGIN
			UPDATE tblSMMasterMenu SET intSort = 5 WHERE strMenuName = 'Batch Posting' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @activitiesId
		END

	/* -------------------------------------------------- */
	/* -- End Add Accounts Receivable Activities Menus -- */
	/* -------------------------------------------------- */

	/* ----------------------------------------------- */
	/* -- Add Accounts Receivable Maintenance Menus -- */
	/* ----------------------------------------------- */

	SELECT @maintenanceId = intMenuID FROM dbo.tblSMMasterMenu WHERE strModuleName = 'Accounts Receivable' AND strMenuName = 'Maintenance' AND intParentMenuID = @rootParentId

	IF NOT EXISTS (SELECT 1 FROM dbo.tblSMMasterMenu WHERE strModuleName = 'Accounts Receivable' AND strMenuName = 'Tax Authority' AND intParentMenuID = @maintenanceId)
	BEGIN
		INSERT dbo.tblSMMasterMenu(strMenuName, strModuleName, intParentMenuID, strDescription, strType, strCommand, strIcon,ysnVisible, ysnExpanded,ysnIsLegacy,ysnLeaf,intSort,intConcurrencyId)
		VALUES ('Tax Authority','Accounts Receivable',@maintenanceId,'Tax Authority','Screen','AccountsReceivable.view.TaxAuthority','small-screen',1,0,0,1,8,1)
	END

	IF NOT EXISTS (SELECT 1 FROM dbo.tblSMMasterMenu WHERE strModuleName = 'Accounts Receivable' AND strMenuName = 'Account Status Codes' AND intParentMenuID = @maintenanceId)
	BEGIN
		INSERT dbo.tblSMMasterMenu(strMenuName, strModuleName, intParentMenuID, strDescription, strType, strCommand, strIcon,ysnVisible, ysnExpanded,ysnIsLegacy,ysnLeaf,intSort,intConcurrencyId)
		VALUES ('Account Status Codes','Accounts Receivable',@maintenanceId,'Account Status Codes','Screen','AccountsReceivable.controller.AccountStatus','small-screen',1,0,0,1,null,1)
	END

	/* --------------------------------------------------- */
	/* -- End Add Accounts Receivable Maintenance Menus -- */
	/* --------------------------------------------------- */
GO
	DECLARE @intParent INT
	SELECT @intParent = intMenuID FROM tblSMMasterMenu
	WHERE strMenuName = 'Help Desk'
	AND intParentMenuID = (SELECT intMenuID FROM tblSMMasterMenu Main 
							WHERE strMenuName = 'Customer Portal')

	UPDATE tblSMMasterMenu
	SET strMenuName = 'Tickets Reported by Me',
		strCommand = 'HelpDesk.controller.CPTicketsReported'
	WHERE strMenuName = 'Tickets Assigned to Me' AND strCommand = 'HelpDesk.controller.CPTicketAssigned' AND strType = 'Screen' AND strModuleName = 'Help Desk' AND intParentMenuID = @intParent	
GO
	DECLARE @intParent INT
	SELECT @intParent = intMenuID FROM tblSMMasterMenu
	WHERE strMenuName = 'Activities'
	AND intParentMenuID = (SELECT intMenuID FROM tblSMMasterMenu Main 
							WHERE strMenuName = 'Help Desk' AND intParentMenuID = 0)

	IF NOT EXISTS(SELECT * FROM tblSMMasterMenu WHERE strMenuName = 'Tickets Reported by Me' AND strCommand = 'HelpDesk.controller.TicketsReported' AND strType = 'Screen' AND strModuleName = 'Help Desk' AND intParentMenuID = @intParent)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (N'Tickets Reported by Me', N'Help Desk', @intParent, N'Tickets Reported by Me', N'Screen', N'HelpDesk.controller.TicketsReported', N'small-screen', 0, 0, 0, 1, 4, 1)
	
	UPDATE tblSMMasterMenu
		SET intSort = (CASE WHEN strMenuName = 'Tickets' THEN 2
							WHEN strMenuName = 'Open Tickets' THEN 3
							WHEN strMenuName = 'Tickets Assigned to Me' THEN 4
							WHEN strMenuName = 'Tickets Reported by Me' THEN 5
							WHEN strMenuName = 'Create Ticket' THEN 1
							WHEN strMenuName = 'Export Hours Worked' THEN 6 END)
	WHERE intParentMenuID = @intParent
GO	
    DECLARE @intParent INT
	SELECT @intParent = intMenuID FROM tblSMMasterMenu
	WHERE strMenuName = 'Help Desk'
	AND intParentMenuID = (SELECT intMenuID FROM tblSMMasterMenu Main 
							WHERE strMenuName = 'Customer Portal' AND intParentMenuID = 0)
	
	UPDATE tblSMMasterMenu
		SET intSort = (CASE WHEN strMenuName = 'Tickets' THEN 2
							WHEN strMenuName = 'Open Tickets' THEN 3
							WHEN strMenuName = 'Tickets Reported by Me' THEN 4
							WHEN strMenuName = 'Create Ticket' THEN 1 END)
	WHERE intParentMenuID = @intParent
GO
	
	IF EXISTS (SELECT * FROM tblSMMasterMenu WHERE strMenuName = 'Customer Portal User Configuration' AND strModuleName = 'Customer Portal' AND strType = 'Screen')
	DELETE FROM tblSMMasterMenu
	WHERE strMenuName = 'Customer Portal User Configuration' AND strModuleName = 'Customer Portal' AND strType = 'Screen'
GO
	DECLARE @intParent INT
	SELECT @intParent = intMenuID FROM tblSMMasterMenu
	WHERE strMenuName = 'Reports'
	AND intParentMenuID = (SELECT intMenuID FROM tblSMMasterMenu Main 
							WHERE strMenuName = 'Tank Management' AND intParentMenuID = 0)
							
	IF NOT EXISTS(SELECT * FROM tblSMMasterMenu WHERE strMenuName = 'Device Lease Detail' AND strCommand = 'Device Lease Detail' AND strType = 'Report' AND strModuleName = 'Tank Management' AND intParentMenuID = @intParent)
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (N'Device Lease Detail', N'Tank Management', @intParent, N'Device Lease Detail', N'Report', N'Device Lease Detail', N'small-report', 0, 0, 0, 1, 0, 1)
GO
	DELETE FROM tblSMMasterMenu
	WHERE intParentMenuID NOT IN (SELECT intMenuID FROM tblSMMasterMenu)
	AND ISNULL(intParentMenuID, 0) <> 0
GO
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strModuleName = 'System Manager' AND intParentMenuID = 13 AND strDescription = 'Freight Terms')
	INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) VALUES (N'Freight Terms', N'System Manager', 13, N'Freight Terms', N'Screen', N'i21.controller.FreightTerms', N'small-screen', 0, 0, 0, 1, NULL, 1)
GO
	/* ---------------------------------- */
	/* -- Remove Ecommerce Module Menu -- */
	/* ---------------------------------- */
	--FRM-1606
	DELETE FROM tblSMMasterMenu WHERE strModuleName = 'Customer Portal'
GO
-- FRM-1587
	IF EXISTS(SELECT * FROM tblSMMasterMenu WHERE strModuleName = 'Help Desk' and intParentMenuID not in (SELECT intMenuID FROM tblSMMasterMenu) and not intParentMenuID = 0)
	BEGIN
		-- delete the menu under Help Desk folder under the deleted Customer Portal parent folder
		delete from tblSMMasterMenu 
		where intParentMenuID in (SELECT intMenuID FROM tblSMMasterMenu WHERE strModuleName = 'Help Desk' and intParentMenuID not in (SELECT intMenuID FROM tblSMMasterMenu) and not intParentMenuID = 0)
	
		--delete the Help Desk folder under the deleted Customer Portal parent folder
		delete FROM tblSMMasterMenu WHERE strModuleName = 'Help Desk' and intParentMenuID not in (SELECT intMenuID FROM tblSMMasterMenu) and not intParentMenuID = 0
	END
GO
	
	/* ---------------------------------- */
	/* -- Create Inventory Module Menu -- */
	/* ---------------------------------- */
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Inventory' AND strModuleName = 'Inventory' AND intParentMenuID = 0)
	INSERT INTO tblSMMasterMenu (strMenuName, strModuleName, intParentMenuID, strDescription, strType, strCommand, strIcon, ysnVisible, ysnExpanded, ysnIsLegacy, ysnLeaf, intSort, intConcurrencyId)
	VALUES ('Inventory', 'Inventory', 0, 'Inventory', 'Folder', '', 'small-folder', 1, 1, 0, 0, null, 0)

	DECLARE @InventoryModuleId INT
	SELECT @InventoryModuleId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Inventory' AND strModuleName = 'Inventory' AND intParentMenuID = 0

	/* -------------------------------------- */
	/* -- Create Inventory Activities Menu -- */
	/* -------------------------------------- */
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Activities' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryModuleId)
	INSERT INTO tblSMMasterMenu (strMenuName, strModuleName, intParentMenuID, strDescription, strType, strCommand, strIcon, ysnVisible, ysnExpanded, ysnIsLegacy, ysnLeaf, intSort, intConcurrencyId)
	VALUES ('Activities', 'Inventory', @InventoryModuleId, 'Inventory Activities Screens', 'Folder', '', 'small-folder', 1, 1, 0, 0, 1, 0)

	DECLARE @InventoryActivityId INT
	SELECT @InventoryActivityId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Activities' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryModuleId

	IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Receipts' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryActivityId)
		UPDATE tblSMMasterMenu
		SET strCommand = 'Inventory.view.InventoryReceipt', intSort = 1, strMenuName = 'Inventory Receipt'
		WHERE strMenuName = 'Receipts' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryActivityId
	ELSE IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Inventory Receipt' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryActivityId)
		INSERT INTO tblSMMasterMenu (strMenuName, strModuleName, intParentMenuID, strDescription, strType, strCommand, strIcon, ysnVisible, ysnExpanded, ysnIsLegacy, ysnLeaf, intSort, intConcurrencyId)
		VALUES ('Inventory Receipt', 'Inventory', @InventoryActivityId, 'Inventory Receipt', 'Screen', 'Inventory.view.InventoryReceipt', 'small-screen', 1, 1, 0, 1, 1, 0)
	ELSE
		UPDATE tblSMMasterMenu
		SET strCommand = 'Inventory.view.InventoryReceipt', intSort = 1
		WHERE strMenuName = 'Inventory Receipt' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryActivityId

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Inventory Shipment' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryActivityId)
		INSERT INTO tblSMMasterMenu (strMenuName, strModuleName, intParentMenuID, strDescription, strType, strCommand, strIcon, ysnVisible, ysnExpanded, ysnIsLegacy, ysnLeaf, intSort, intConcurrencyId)
		VALUES ('Inventory Shipment', 'Inventory', @InventoryActivityId, 'Inventory Shipment', 'Screen', 'Inventory.view.InventoryShipment', 'small-screen', 1, 1, 0, 1, 2, 0)
	ELSE
		UPDATE tblSMMasterMenu
		SET strCommand = 'Inventory.view.InventoryShipment', intSort = 2
		WHERE strMenuName = 'Inventory Shipment' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryActivityId

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Inventory Transfer' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryActivityId)
		INSERT INTO tblSMMasterMenu (strMenuName, strModuleName, intParentMenuID, strDescription, strType, strCommand, strIcon, ysnVisible, ysnExpanded, ysnIsLegacy, ysnLeaf, intSort, intConcurrencyId)
		VALUES ('Inventory Transfer', 'Inventory', @InventoryActivityId, 'Inventory Transfer', 'Screen', 'Inventory.view.InventoryTransfer', 'small-screen', 1, 1, 0, 1, 3, 0)
	ELSE
		UPDATE tblSMMasterMenu
		SET strCommand = 'Inventory.view.InventoryTransfer', intSort = 3
		WHERE strMenuName = 'Inventory Transfer' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryActivityId

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Inventory Adjustment' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryActivityId)
		INSERT INTO tblSMMasterMenu (strMenuName, strModuleName, intParentMenuID, strDescription, strType, strCommand, strIcon, ysnVisible, ysnExpanded, ysnIsLegacy, ysnLeaf, intSort, intConcurrencyId)
		VALUES ('Inventory Adjustment', 'Inventory', @InventoryActivityId, 'Inventory Adjustment', 'Screen', 'Inventory.view.InventoryAdjustment', 'small-screen', 1, 1, 0, 1, 4, 0)
	ELSE
		UPDATE tblSMMasterMenu
		SET strCommand = 'Inventory.view.InventoryAdjustment', intSort = 4
		WHERE strMenuName = 'Inventory Adjustment' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryActivityId

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Physical Count' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryActivityId)
		INSERT INTO tblSMMasterMenu (strMenuName, strModuleName, intParentMenuID, strDescription, strType, strCommand, strIcon, ysnVisible, ysnExpanded, ysnIsLegacy, ysnLeaf, intSort, intConcurrencyId)
		VALUES ('Physical Count', 'Inventory', @InventoryActivityId, 'Physical Count', 'Screen', 'Inventory.view.PhysicalCount', 'small-screen', 1, 1, 0, 1, 5, 0)
	ELSE
		UPDATE tblSMMasterMenu
		SET strCommand = 'Inventory.view.PhysicalCount', intSort = 5
		WHERE strMenuName = 'Physical Count' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryActivityId


	/* --------------------------------------- */
	/* -- Create Inventory Maintenance Menu -- */
	/* --------------------------------------- */
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryModuleId)
	INSERT INTO tblSMMasterMenu (strMenuName, strModuleName, intParentMenuID, strDescription, strType, strCommand, strIcon, ysnVisible, ysnExpanded, ysnIsLegacy, ysnLeaf, intSort, intConcurrencyId)
	VALUES ('Maintenance', 'Inventory', @InventoryModuleId, 'Inventory Maintenance Screens', 'Folder', '', 'small-folder', 1, 1, 0, 0, 2, 0)

	DECLARE @InventoryMaintenanceId INT
	SELECT @InventoryMaintenanceId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryModuleId

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Item' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceId)
		INSERT INTO tblSMMasterMenu (strMenuName, strModuleName, intParentMenuID, strDescription, strType, strCommand, strIcon, ysnVisible, ysnExpanded, ysnIsLegacy, ysnLeaf, intSort, intConcurrencyId)
		VALUES ('Item', 'Inventory', @InventoryMaintenanceId, 'Item', 'Screen', 'Inventory.view.Item', 'small-screen', 1, 1, 0, 1, 1, 0)
	ELSE
		UPDATE tblSMMasterMenu
		SET strCommand = 'Inventory.view.Item', intSort = 1
		WHERE strMenuName = 'Item' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceId

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Commodity' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceId)
		INSERT INTO tblSMMasterMenu (strMenuName, strModuleName, intParentMenuID, strDescription, strType, strCommand, strIcon, ysnVisible, ysnExpanded, ysnIsLegacy, ysnLeaf, intSort, intConcurrencyId)
		VALUES ('Commodity', 'Inventory', @InventoryMaintenanceId, 'Commodity', 'Screen', 'Inventory.view.Commodity', 'small-screen', 1, 1, 0, 1, 2, 0)
	ELSE
		UPDATE tblSMMasterMenu
		SET strCommand = 'Inventory.view.Commodity', intSort = 2
		WHERE strMenuName = 'Commodity' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceId

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Category' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceId)
		INSERT INTO tblSMMasterMenu (strMenuName, strModuleName, intParentMenuID, strDescription, strType, strCommand, strIcon, ysnVisible, ysnExpanded, ysnIsLegacy, ysnLeaf, intSort, intConcurrencyId)
		VALUES ('Category', 'Inventory', @InventoryMaintenanceId, 'Category', 'Screen', 'Inventory.view.Category', 'small-screen', 1, 1, 0, 1, 3, 0)
	ELSE
		UPDATE tblSMMasterMenu
		SET strCommand = 'Inventory.view.Category', intSort = 3
		WHERE strMenuName = 'Category' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceId

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Catalog Maintenance' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceId)
		INSERT INTO tblSMMasterMenu (strMenuName, strModuleName, intParentMenuID, strDescription, strType, strCommand, strIcon, ysnVisible, ysnExpanded, ysnIsLegacy, ysnLeaf, intSort, intConcurrencyId)
		VALUES ('Catalog Maintenance', 'Inventory', @InventoryMaintenanceId, 'Catalog Maintenance', 'Screen', 'Inventory.view.Catalog', 'small-screen', 1, 1, 0, 1, 4, 0)
	ELSE
		UPDATE tblSMMasterMenu
		SET strCommand = 'Inventory.view.Catalog', intSort = 4
		WHERE strMenuName = 'Catalog Maintenance' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceId

	/* -------------------------------- */
	/* -- Create Inventory RIN Menus -- */
	/* -------------------------------- */
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'RIN' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceId)
	INSERT INTO tblSMMasterMenu (strMenuName, strModuleName, intParentMenuID, strDescription, strType, strCommand, strIcon, ysnVisible, ysnExpanded, ysnIsLegacy, ysnLeaf, intSort, intConcurrencyId)
	VALUES ('RIN', 'Inventory', @InventoryMaintenanceId, 'RIN', 'Folder', '', 'small-folder', 1, 1, 0, 0, 5, 0)

	DECLARE @InventoryRINId INT
	SELECT @InventoryRINId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'RIN' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceId

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Fuel Category' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryRINId)
		INSERT INTO tblSMMasterMenu (strMenuName, strModuleName, intParentMenuID, strDescription, strType, strCommand, strIcon, ysnVisible, ysnExpanded, ysnIsLegacy, ysnLeaf, intSort, intConcurrencyId)
		VALUES ('Fuel Category', 'Inventory', @InventoryRINId, 'Fuel Category', 'Screen', 'Inventory.view.FuelCategory', 'small-screen', 1, 1, 0, 1, 1, 0)
	ELSE
		UPDATE tblSMMasterMenu
		SET strCommand = 'Inventory.view.FuelCategory', intSort = 1
		WHERE strMenuName = 'Fuel Category' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryRINId

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Fuel Code' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryRINId)
		INSERT INTO tblSMMasterMenu (strMenuName, strModuleName, intParentMenuID, strDescription, strType, strCommand, strIcon, ysnVisible, ysnExpanded, ysnIsLegacy, ysnLeaf, intSort, intConcurrencyId)
		VALUES ('Fuel Code', 'Inventory', @InventoryRINId, 'Fuel Code', 'Screen', 'Inventory.view.FuelCode', 'small-screen', 1, 1, 0, 1, 2, 0)
	ELSE
		UPDATE tblSMMasterMenu
		SET strCommand = 'Inventory.view.FuelCode', intSort = 2
		WHERE strMenuName = 'Fuel Code' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryRINId

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Production Process' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryRINId)
		INSERT INTO tblSMMasterMenu (strMenuName, strModuleName, intParentMenuID, strDescription, strType, strCommand, strIcon, ysnVisible, ysnExpanded, ysnIsLegacy, ysnLeaf, intSort, intConcurrencyId)
		VALUES ('Production Process', 'Inventory', @InventoryRINId, 'Production Process', 'Screen', 'Inventory.view.ProcessCode', 'small-screen', 1, 1, 0, 1, 3, 0)
	ELSE
		UPDATE tblSMMasterMenu
		SET strCommand = 'Inventory.view.ProcessCode', intSort = 3
		WHERE strMenuName = 'Production Process' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryRINId

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Feed Stock' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryRINId)
		INSERT INTO tblSMMasterMenu (strMenuName, strModuleName, intParentMenuID, strDescription, strType, strCommand, strIcon, ysnVisible, ysnExpanded, ysnIsLegacy, ysnLeaf, intSort, intConcurrencyId)
		VALUES ('Feed Stock', 'Inventory', @InventoryRINId, 'Feed Stock', 'Screen', 'Inventory.view.FeedStockCode', 'small-screen', 1, 1, 0, 1, 4, 0)
	ELSE
		UPDATE tblSMMasterMenu
		SET strCommand = 'Inventory.view.FeedStockCode', intSort = 4
		WHERE strMenuName = 'Feed Stock' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryRINId

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Feed Stock UOM' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryRINId)
		INSERT INTO tblSMMasterMenu (strMenuName, strModuleName, intParentMenuID, strDescription, strType, strCommand, strIcon, ysnVisible, ysnExpanded, ysnIsLegacy, ysnLeaf, intSort, intConcurrencyId)
		VALUES ('Feed Stock UOM', 'Inventory', @InventoryRINId, 'Feed Stock UOM', 'Screen', 'Inventory.view.FeedStockUom', 'small-screen', 1, 1, 0, 1, 5, 0)
	ELSE
		UPDATE tblSMMasterMenu
		SET strCommand = 'Inventory.view.FeedStockUom', intSort = 5
		WHERE strMenuName = 'Feed Stock UOM' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryRINId

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Fuel Type' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryRINId)
		INSERT INTO tblSMMasterMenu (strMenuName, strModuleName, intParentMenuID, strDescription, strType, strCommand, strIcon, ysnVisible, ysnExpanded, ysnIsLegacy, ysnLeaf, intSort, intConcurrencyId)
		VALUES ('Fuel Type', 'Inventory', @InventoryRINId, 'Fuel Type', 'Screen', 'Inventory.view.FuelType', 'small-screen', 1, 1, 0, 1, 6, 0)
	ELSE
		UPDATE tblSMMasterMenu
		SET strCommand = 'Inventory.view.FuelType', intSort = 6
		WHERE strMenuName = 'Fuel Type' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryRINId

	/* -------------------------------- */
	/* ---- End Inventory RIN Menus --- */
	/* -------------------------------- */

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Fuel Tax Class' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceId)
		INSERT INTO tblSMMasterMenu (strMenuName, strModuleName, intParentMenuID, strDescription, strType, strCommand, strIcon, ysnVisible, ysnExpanded, ysnIsLegacy, ysnLeaf, intSort, intConcurrencyId)
		VALUES ('Fuel Tax Class', 'Inventory', @InventoryMaintenanceId, 'Fuel Tax Class', 'Screen', 'Inventory.view.FuelTaxClass', 'small-screen', 1, 1, 0, 1, 6, 0)
	ELSE
		UPDATE tblSMMasterMenu
		SET strCommand = 'Inventory.view.FuelTaxClass', intSort = 6
		WHERE strMenuName = 'Fuel Tax Class' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceId

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Inventory Tag' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceId)
		INSERT INTO tblSMMasterMenu (strMenuName, strModuleName, intParentMenuID, strDescription, strType, strCommand, strIcon, ysnVisible, ysnExpanded, ysnIsLegacy, ysnLeaf, intSort, intConcurrencyId)
		VALUES ('Inventory Tag', 'Inventory', @InventoryMaintenanceId, 'Inventory Tag', 'Screen', 'Inventory.view.InventoryTag', 'small-screen', 1, 1, 0, 1, 7, 0)
	ELSE
		UPDATE tblSMMasterMenu
		SET strCommand = 'Inventory.view.InventoryTag', intSort = 7
		WHERE strMenuName = 'Inventory Tag' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceId

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Patronage Category' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceId)
		INSERT INTO tblSMMasterMenu (strMenuName, strModuleName, intParentMenuID, strDescription, strType, strCommand, strIcon, ysnVisible, ysnExpanded, ysnIsLegacy, ysnLeaf, intSort, intConcurrencyId)
		VALUES ('Patronage Category', 'Inventory', @InventoryMaintenanceId, 'Patronage Category', 'Screen', 'Inventory.view.PatronageCategory', 'small-screen', 1, 1, 0, 1, 8, 0)
	ELSE
		UPDATE tblSMMasterMenu
		SET strCommand = 'Inventory.view.PatronageCategory', intSort = 8
		WHERE strMenuName = 'Patronage Category' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceId

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Manufacturer' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceId)
		INSERT INTO tblSMMasterMenu (strMenuName, strModuleName, intParentMenuID, strDescription, strType, strCommand, strIcon, ysnVisible, ysnExpanded, ysnIsLegacy, ysnLeaf, intSort, intConcurrencyId)
		VALUES ('Manufacturer', 'Inventory', @InventoryMaintenanceId, 'Manufacturer', 'Screen', 'Inventory.view.Manufacturer', 'small-screen', 1, 1, 0, 1, 9, 0)
	ELSE
		UPDATE tblSMMasterMenu
		SET strCommand = 'Inventory.view.Manufacturer', intSort = 9
		WHERE strMenuName = 'Manufacturer' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceId

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Inventory UOM' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceId)
		INSERT INTO tblSMMasterMenu (strMenuName, strModuleName, intParentMenuID, strDescription, strType, strCommand, strIcon, ysnVisible, ysnExpanded, ysnIsLegacy, ysnLeaf, intSort, intConcurrencyId)
		VALUES ('Inventory UOM', 'Inventory', @InventoryMaintenanceId, 'Inventory UOM', 'Screen', 'Inventory.view.InventoryUOM', 'small-screen', 1, 1, 0, 1, 10, 0)
	ELSE
		UPDATE tblSMMasterMenu
		SET strCommand = 'Inventory.view.InventoryUOM', intSort = 10
		WHERE strMenuName = 'Inventory UOM' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceId

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Manufacturing Cell' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceId)
		INSERT INTO tblSMMasterMenu (strMenuName, strModuleName, intParentMenuID, strDescription, strType, strCommand, strIcon, ysnVisible, ysnExpanded, ysnIsLegacy, ysnLeaf, intSort, intConcurrencyId)
		VALUES ('Manufacturing Cell', 'Inventory', @InventoryMaintenanceId, 'Manufacturing Cell', 'Screen', 'Inventory.view.ManufacturingCell', 'small-screen', 1, 1, 0, 1, 11, 0)
	ELSE
		UPDATE tblSMMasterMenu
		SET strCommand = 'Inventory.view.ManufacturingCell', intSort = 11
		WHERE strMenuName = 'Manufacturing Cell' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceId

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Reasons' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceId)
		INSERT INTO tblSMMasterMenu (strMenuName, strModuleName, intParentMenuID, strDescription, strType, strCommand, strIcon, ysnVisible, ysnExpanded, ysnIsLegacy, ysnLeaf, intSort, intConcurrencyId)
		VALUES ('Reasons', 'Inventory', @InventoryMaintenanceId, 'Reasons', 'Screen', 'Inventory.view.ReasonCode', 'small-screen', 1, 1, 0, 1, 12, 0)
	ELSE
		UPDATE tblSMMasterMenu
		SET strCommand = 'Inventory.view.ReasonCode', intSort = 12
		WHERE strMenuName = 'Reasons' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceId

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Storage Unit Type' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceId)
		INSERT INTO tblSMMasterMenu (strMenuName, strModuleName, intParentMenuID, strDescription, strType, strCommand, strIcon, ysnVisible, ysnExpanded, ysnIsLegacy, ysnLeaf, intSort, intConcurrencyId)
		VALUES ('Storage Unit Type', 'Inventory', @InventoryMaintenanceId, 'Storage Unit Type', 'Screen', 'Inventory.view.FactoryUnitType', 'small-screen', 1, 1, 0, 1, 13, 0)
	ELSE
		UPDATE tblSMMasterMenu
		SET strCommand = 'Inventory.view.FactoryUnitType', intSort = 13
		WHERE strMenuName = 'Storage Unit Type' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceId

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Storage Location' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceId)
		INSERT INTO tblSMMasterMenu (strMenuName, strModuleName, intParentMenuID, strDescription, strType, strCommand, strIcon, ysnVisible, ysnExpanded, ysnIsLegacy, ysnLeaf, intSort, intConcurrencyId)
		VALUES ('Storage Location', 'Inventory', @InventoryMaintenanceId, 'Storage Location', 'Screen', 'Inventory.view.StorageUnit', 'small-screen', 1, 1, 0, 1, 14, 0)
	ELSE
		UPDATE tblSMMasterMenu
		SET strCommand = 'Inventory.view.StorageUnit', intSort = 14
		WHERE strMenuName = 'Storage Location' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceId

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Item Substitution' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceId)
		INSERT INTO tblSMMasterMenu (strMenuName, strModuleName, intParentMenuID, strDescription, strType, strCommand, strIcon, ysnVisible, ysnExpanded, ysnIsLegacy, ysnLeaf, intSort, intConcurrencyId)
		VALUES ('Item Substitution', 'Inventory', @InventoryMaintenanceId, 'Item Substitution', 'Screen', 'Inventory.view.ItemSubstitution', 'small-screen', 1, 1, 0, 1, 15, 0)
	ELSE
		UPDATE tblSMMasterMenu
		SET strCommand = 'Inventory.view.ItemSubstitution', intSort = 15
		WHERE strMenuName = 'Item Substitution' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceId

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Certification Programs' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceId)
		INSERT INTO tblSMMasterMenu (strMenuName, strModuleName, intParentMenuID, strDescription, strType, strCommand, strIcon, ysnVisible, ysnExpanded, ysnIsLegacy, ysnLeaf, intSort, intConcurrencyId)
		VALUES ('Certification Programs', 'Inventory', @InventoryMaintenanceId, 'Certification Programs', 'Screen', 'Inventory.view.CertificationProgram', 'small-screen', 1, 1, 0, 1, 16, 0)
	ELSE
		UPDATE tblSMMasterMenu
		SET strCommand = 'Inventory.view.CertificationProgram', intSort = 16
		WHERE strMenuName = 'Certification Programs' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceId

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Contract Document' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceId)
		INSERT INTO tblSMMasterMenu (strMenuName, strModuleName, intParentMenuID, strDescription, strType, strCommand, strIcon, ysnVisible, ysnExpanded, ysnIsLegacy, ysnLeaf, intSort, intConcurrencyId)
		VALUES ('Contract Document', 'Inventory', @InventoryMaintenanceId, 'Contract Document', 'Screen', 'Inventory.view.ContractDocument', 'small-screen', 1, 1, 0, 1, 17, 0)
	ELSE
		UPDATE tblSMMasterMenu
		SET strCommand = 'Inventory.view.ContractDocument', intSort = 17
		WHERE strMenuName = 'Contract Document' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceId

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Lot Status' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceId)
		INSERT INTO tblSMMasterMenu (strMenuName, strModuleName, intParentMenuID, strDescription, strType, strCommand, strIcon, ysnVisible, ysnExpanded, ysnIsLegacy, ysnLeaf, intSort, intConcurrencyId)
		VALUES ('Lot Status', 'Inventory', @InventoryMaintenanceId, 'Lot Status', 'Screen', 'Inventory.view.LotStatus', 'small-screen', 1, 1, 0, 1, 18, 0)
	ELSE
		UPDATE tblSMMasterMenu
		SET strCommand = 'Inventory.view.LotStatus', intSort = 18
		WHERE strMenuName = 'Lot Status' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceId

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Sample Type' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceId)
		INSERT INTO tblSMMasterMenu (strMenuName, strModuleName, intParentMenuID, strDescription, strType, strCommand, strIcon, ysnVisible, ysnExpanded, ysnIsLegacy, ysnLeaf, intSort, intConcurrencyId)
		VALUES ('Sample Type', 'Inventory', @InventoryMaintenanceId, 'Sample Type', 'Screen', 'Inventory.view.SampleType', 'small-screen', 1, 1, 0, 1, 19, 0)
	ELSE
		UPDATE tblSMMasterMenu
		SET strCommand = 'Inventory.view.SampleType', intSort = 19
		WHERE strMenuName = 'Sample Type' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceId

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Brand' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceId)
		INSERT INTO tblSMMasterMenu (strMenuName, strModuleName, intParentMenuID, strDescription, strType, strCommand, strIcon, ysnVisible, ysnExpanded, ysnIsLegacy, ysnLeaf, intSort, intConcurrencyId)
		VALUES ('Brand', 'Inventory', @InventoryMaintenanceId, 'Brand', 'Screen', 'Inventory.view.Brand', 'small-screen', 1, 1, 0, 1, 20, 0)
	ELSE
		UPDATE tblSMMasterMenu
		SET strCommand = 'Inventory.view.Brand', intSort = 20
		WHERE strMenuName = 'Brand' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceId

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Pack Type' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceId)
		INSERT INTO tblSMMasterMenu (strMenuName, strModuleName, intParentMenuID, strDescription, strType, strCommand, strIcon, ysnVisible, ysnExpanded, ysnIsLegacy, ysnLeaf, intSort, intConcurrencyId)
		VALUES ('Pack Type', 'Inventory', @InventoryMaintenanceId, 'Pack Type', 'Screen', 'Inventory.view.PackType', 'small-screen', 1, 1, 0, 1, 21, 0)
	ELSE
		UPDATE tblSMMasterMenu
		SET strCommand = 'Inventory.view.PackType', intSort = 21
		WHERE strMenuName = 'Pack Type' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceId

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Pack Type' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceId)
		INSERT INTO tblSMMasterMenu (strMenuName, strModuleName, intParentMenuID, strDescription, strType, strCommand, strIcon, ysnVisible, ysnExpanded, ysnIsLegacy, ysnLeaf, intSort, intConcurrencyId)
		VALUES ('Pack Type', 'Inventory', @InventoryMaintenanceId, 'Pack Type', 'Screen', 'Inventory.view.PackType', 'small-screen', 1, 1, 0, 1, 22, 0)
	ELSE
		UPDATE tblSMMasterMenu
		SET strCommand = 'Inventory.view.PackType', intSort = 22
		WHERE strMenuName = 'Pack Type' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceId

	--/* -------------------------------- */
	--/* -- Create Inventory QA Menus -- */
	--/* -------------------------------- */
	--IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Quality Assurance' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceId)
	--INSERT INTO tblSMMasterMenu (strMenuName, strModuleName, intParentMenuID, strDescription, strType, strCommand, strIcon, ysnVisible, ysnExpanded, ysnIsLegacy, ysnLeaf, intSort, intConcurrencyId)
	--VALUES ('Quality Assurance', 'Inventory', @InventoryMaintenanceId, 'Quality Assurance', 'Folder', '', 'small-folder', 1, 1, 0, 0, 23, 0)

	--DECLARE @InventoryQAId INT
	--SELECT @InventoryQAId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Quality Assurance' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceId

	--IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'QA List' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryQAId)
	--	INSERT INTO tblSMMasterMenu (strMenuName, strModuleName, intParentMenuID, strDescription, strType, strCommand, strIcon, ysnVisible, ysnExpanded, ysnIsLegacy, ysnLeaf, intSort, intConcurrencyId)
	--	VALUES ('QA List', 'Inventory', @InventoryQAId, 'QA List', 'Screen', 'Inventory.view.QAList', 'small-screen', 1, 1, 0, 1, 1, 0)
	--ELSE
	--	UPDATE tblSMMasterMenu
	--	SET strCommand = 'Inventory.view.QAList', intSort = 1
	--	WHERE strMenuName = 'QA List' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryQAId

	--IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'QA Properties' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryQAId)
	--	INSERT INTO tblSMMasterMenu (strMenuName, strModuleName, intParentMenuID, strDescription, strType, strCommand, strIcon, ysnVisible, ysnExpanded, ysnIsLegacy, ysnLeaf, intSort, intConcurrencyId)
	--	VALUES ('QA Properties', 'Inventory', @InventoryQAId, 'QA Properties', 'Screen', 'Inventory.view.QAProperty', 'small-screen', 1, 1, 0, 1, 2, 0)
	--ELSE
	--	UPDATE tblSMMasterMenu
	--	SET strCommand = 'Inventory.view.QAProperty', intSort = 2
	--	WHERE strMenuName = 'QA Properties' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryQAId

	--IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'QA Test' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryQAId)
	--	INSERT INTO tblSMMasterMenu (strMenuName, strModuleName, intParentMenuID, strDescription, strType, strCommand, strIcon, ysnVisible, ysnExpanded, ysnIsLegacy, ysnLeaf, intSort, intConcurrencyId)
	--	VALUES ('QA Test', 'Inventory', @InventoryQAId, 'QA Test', 'Screen', 'Inventory.view.QATest', 'small-screen', 1, 1, 0, 1, 3, 0)
	--ELSE
	--	UPDATE tblSMMasterMenu
	--	SET strCommand = 'Inventory.view.QATest', intSort = 3
	--	WHERE strMenuName = 'QA Test' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryQAId

	--IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Quality Template' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryQAId)
	--	INSERT INTO tblSMMasterMenu (strMenuName, strModuleName, intParentMenuID, strDescription, strType, strCommand, strIcon, ysnVisible, ysnExpanded, ysnIsLegacy, ysnLeaf, intSort, intConcurrencyId)
	--	VALUES ('Quality Template', 'Inventory', @InventoryQAId, 'Quality Template', 'Screen', 'Inventory.view.QualityTemplate', 'small-screen', 1, 1, 0, 1, 4, 0)
	--ELSE
	--	UPDATE tblSMMasterMenu
	--	SET strCommand = 'Inventory.view.QualityTemplate', intSort = 4
	--	WHERE strMenuName = 'Quality Template' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryQAId
	--/* ------------------------------- */
	--/* -- End of Inventory QA Menus -- */
	--/* ------------------------------- */

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Inventory Count Group' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceId)
		INSERT INTO tblSMMasterMenu (strMenuName, strModuleName, intParentMenuID, strDescription, strType, strCommand, strIcon, ysnVisible, ysnExpanded, ysnIsLegacy, ysnLeaf, intSort, intConcurrencyId)
		VALUES ('Inventory Count Group', 'Inventory', @InventoryMaintenanceId, 'Inventory Count Group', 'Screen', 'Inventory.view.CountGroup', 'small-screen', 1, 1, 0, 1, 24, 0)
	ELSE
		UPDATE tblSMMasterMenu
		SET strCommand = 'Inventory.view.CountGroup', intSort = 24
		WHERE strMenuName = 'Inventory Count Group' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceId

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Line of Business' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceId)
		INSERT INTO tblSMMasterMenu (strMenuName, strModuleName, intParentMenuID, strDescription, strType, strCommand, strIcon, ysnVisible, ysnExpanded, ysnIsLegacy, ysnLeaf, intSort, intConcurrencyId)
		VALUES ('Line of Business', 'Inventory', @InventoryMaintenanceId, 'Line of Business', 'Screen', 'Inventory.view.LineOfBusiness', 'small-screen', 1, 1, 0, 1, 25, 0)
	ELSE
		UPDATE tblSMMasterMenu
		SET strCommand = 'Inventory.view.LineOfBusiness', intSort = 25
		WHERE strMenuName = 'Line of Business' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryMaintenanceId

	
	/* ---------------------------------------- */
	/* -- End of Inventory Maintenance Menus -- */
	/* ---------------------------------------- */

	--/* ----------------------------------- */
	--/* -- Create Inventory Reports Menu -- */
	--/* ----------------------------------- */
	--IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Reports' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryModuleId)
	--INSERT INTO tblSMMasterMenu (strMenuName, strModuleName, intParentMenuID, strDescription, strType, strCommand, strIcon, ysnVisible, ysnExpanded, ysnIsLegacy, ysnLeaf, intSort, intConcurrencyId)
	--VALUES ('Reports', 'Inventory', @InventoryModuleId, 'Inventory Reports', 'Folder', '', 'small-folder', 1, 1, 0, 0, 3, 0)

	--DECLARE @InventoryReportId INT
	--SELECT @InventoryReportId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Reports' AND strModuleName = 'Inventory' AND intParentMenuID = @InventoryModuleId


	--/* -------------------------------- */
	--/* -- End Inventory Reports Menu -- */
	--/* -------------------------------- */

	DELETE FROM tblSMMasterMenu 
	WHERE strMenuName = 'Quality Assurance' 
		AND strModuleName = 'Inventory' 
		AND intParentMenuID = @InventoryMaintenanceId

GO
	/* --- Payroll Module Menu --- */
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Payroll' AND strModuleName = 'Payroll' AND intParentMenuID = 0)
	INSERT INTO tblSMMasterMenu (strMenuName, strModuleName, intParentMenuID, strDescription, strType, strCommand, strIcon, ysnVisible, ysnExpanded, ysnIsLegacy, ysnLeaf, intSort, intConcurrencyId) SELECT 'Payroll', 'Payroll', 0, 'Payroll', 'Folder', '', 'small-folder', 1, 1, 0, 0, null, 0

	GO

	DECLARE @PayrollModuleId INT
	SELECT @PayrollModuleId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Payroll' AND strModuleName = 'Payroll' AND intParentMenuID = 0

		-- Payroll / Activities
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Activities' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollModuleId)
		INSERT INTO tblSMMasterMenu (strMenuName, strModuleName, intParentMenuID, strDescription, strType, strCommand, strIcon, ysnVisible, ysnExpanded, ysnIsLegacy, ysnLeaf, intSort, intConcurrencyId) SELECT 'Activities', 'Payroll', @PayrollModuleId, 'Payroll Activities Screens', 'Folder', '', 'small-folder', 1, 1, 0, 0, 1, 0

		-- Payroll / Maintenance
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollModuleId)
		INSERT INTO tblSMMasterMenu (strMenuName, strModuleName, intParentMenuID, strDescription, strType, strCommand, strIcon, ysnVisible, ysnExpanded, ysnIsLegacy, ysnLeaf, intSort, intConcurrencyId) SELECT 'Maintenance', 'Payroll', @PayrollModuleId, 'Payroll Maintenance Screens', 'Folder', '', 'small-folder', 1, 1, 0, 0, 2, 0

		-- Payroll Reports
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Reports' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollModuleId)
		INSERT INTO tblSMMasterMenu (strMenuName, strModuleName, intParentMenuID, strDescription, strType, strCommand, strIcon, ysnVisible, ysnExpanded, ysnIsLegacy, ysnLeaf, intSort, intConcurrencyId) SELECT 'Reports', 'Payroll', @PayrollModuleId, 'Payroll Reports', 'Folder', '', 'small-folder', 1, 1, 0, 0, 3, 0

		GO

		DECLARE @PayrollModuleId INT
		DECLARE @PayrollActivityId INT
		DECLARE @PayrollMaintenanceId INT

		SELECT @PayrollModuleId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Payroll' AND strModuleName = 'Payroll' AND intParentMenuID = 0
		SELECT @PayrollActivityId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Activities' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollModuleId
		SELECT @PayrollMaintenanceId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollModuleId

			/*
			-- Payroll / Activities / Paychecks
			IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Paychecks' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollActivityId)
			INSERT INTO tblSMMasterMenu (strMenuName, strModuleName, intParentMenuID, strDescription, strType, strCommand, strIcon, ysnVisible, ysnExpanded, ysnIsLegacy, ysnLeaf, intSort, intConcurrencyId) SELECT 'Paychecks', 'Payroll', @PayrollActivityId, 'Paychecks', 'Screen', 'pr/paycheck', 'small-screen', 1, 1, 0, 1, 1, 0

			-- Payroll / Activities / Process Pay Groups
			IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Process Pay Groups' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollActivityId)
			INSERT INTO tblSMMasterMenu (strMenuName, strModuleName, intParentMenuID, strDescription, strType, strCommand, strIcon, ysnVisible, ysnExpanded, ysnIsLegacy, ysnLeaf, intSort, intConcurrencyId) SELECT 'Process Pay Groups', 'Payroll', @PayrollActivityId, 'Process Pay Groups', 'Screen', '', 'small-screen', 1, 1, 0, 1, 2, 0		
			*/

			-- Payroll / Maintenance / Payroll Types
			IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Payroll Types' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollMaintenanceId)
			INSERT INTO tblSMMasterMenu (strMenuName, strModuleName, intParentMenuID, strDescription, strType, strCommand, strIcon, ysnVisible, ysnExpanded, ysnIsLegacy, ysnLeaf, intSort, intConcurrencyId) SELECT 'Payroll Types', 'Payroll', @PayrollMaintenanceId, 'Payroll Types', 'Folder', '', 'small-folder', 1, 1, 0, 0, 1, 0

			-- Payroll / Maintenance / Employees
			IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Employees' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollMaintenanceId)
			INSERT INTO tblSMMasterMenu (strMenuName, strModuleName, intParentMenuID, strDescription, strType, strCommand, strIcon, ysnVisible, ysnExpanded, ysnIsLegacy, ysnLeaf, intSort, intConcurrencyId) SELECT 'Employees', 'Payroll', @PayrollMaintenanceId, 'Employees', 'Screen', 'Payroll.view.Employee', 'small-screen', 1, 1, 0, 1, 2, 0

			/*
			-- Payroll / Maintenance / Employee Templates
			IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Employee Templates' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollMaintenanceId)
			INSERT INTO tblSMMasterMenu (strMenuName, strModuleName, intParentMenuID, strDescription, strType, strCommand, strIcon, ysnVisible, ysnExpanded, ysnIsLegacy, ysnLeaf, intSort, intConcurrencyId) SELECT 'Employee Templates', 'Payroll', @PayrollMaintenanceId, 'Employee Templates', 'Screen', '', 'small-screen', 1, 1, 0, 1, 3, 0

			-- Payroll / Maintenance / Employee Pay Groups
			IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Employee Pay Groups' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollMaintenanceId)
			INSERT INTO tblSMMasterMenu (strMenuName, strModuleName, intParentMenuID, strDescription, strType, strCommand, strIcon, ysnVisible, ysnExpanded, ysnIsLegacy, ysnLeaf, intSort, intConcurrencyId) SELECT 'Employee Pay Groups', 'Payroll', @PayrollMaintenanceId, 'Employee Pay Groups', 'Screen', '', 'small-screen', 1, 1, 0, 1, 4, 0
			*/

			GO

			DECLARE @PayrollModuleId INT
			DECLARE @PayrollMaintenanceId INT
			DECLARE @PayrollTypesId INT
	
			SELECT @PayrollModuleId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Payroll' AND strModuleName = 'Payroll' AND intParentMenuID = 0
			SELECT @PayrollMaintenanceId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollModuleId
			SELECT @PayrollTypesId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Payroll Types' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollMaintenanceId

				-- Payroll / Maintenance / Payroll Types / Tax Types
				IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Tax Types' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollTypesId)
				INSERT INTO tblSMMasterMenu (strMenuName, strModuleName, intParentMenuID, strDescription, strType, strCommand, strIcon, ysnVisible, ysnExpanded, ysnIsLegacy, ysnLeaf, intSort, intConcurrencyId) SELECT 'Tax Types', 'Payroll', @PayrollTypesId, 'Tax Types', 'Screen', 'Payroll.view.TaxType', 'small-screen', 1, 1, 0, 1, 1, 0

				-- Payroll / Maintenance / Payroll Types / Earning Types
				IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Earning Types' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollTypesId)
				INSERT INTO tblSMMasterMenu (strMenuName, strModuleName, intParentMenuID, strDescription, strType, strCommand, strIcon, ysnVisible, ysnExpanded, ysnIsLegacy, ysnLeaf, intSort, intConcurrencyId) SELECT 'Earning Types', 'Payroll', @PayrollTypesId, 'Earning Types', 'Screen', 'Payroll.view.EarningType', 'small-screen', 1, 1, 0, 1, 2, 0

				-- Payroll / Maintenance / Payroll Types / Deduction Types
				IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Deduction Types' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollTypesId)
				INSERT INTO tblSMMasterMenu (strMenuName, strModuleName, intParentMenuID, strDescription, strType, strCommand, strIcon, ysnVisible, ysnExpanded, ysnIsLegacy, ysnLeaf, intSort, intConcurrencyId) SELECT 'Deduction Types', 'Payroll', @PayrollTypesId, 'Deduction Types', 'Screen', 'Payroll.view.DeductionType', 'small-screen', 1, 1, 0, 1, 3, 0

				-- Payroll / Maintenance / Payroll Types / Time Off Types
				IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Time Off Types' AND strModuleName = 'Payroll' AND intParentMenuID = @PayrollTypesId)
				INSERT INTO tblSMMasterMenu (strMenuName, strModuleName, intParentMenuID, strDescription, strType, strCommand, strIcon, ysnVisible, ysnExpanded, ysnIsLegacy, ysnLeaf, intSort, intConcurrencyId) SELECT 'Time Off Types', 'Payroll', @PayrollTypesId, 'Time Off Types', 'Screen', 'Payroll.view.TimeOffType', 'small-screen', 1, 1, 0, 1, 4, 0

GO
	/* ------------------------------------------------------ */	
	/* --   Add Common Info Recurring Transactions Menus   -- */
	/* ------------------------------------------------------ */	
		IF NOT EXISTS(SELECT 1 FROM dbo.tblSMMasterMenu WHERE strModuleName = 'System Manager' AND intParentMenuID = 13 AND strMenuName = 'Recurring Transactions')
		BEGIN
			INSERT [dbo].[tblSMMasterMenu] ([strMenuName], [strModuleName], [intParentMenuID], [strDescription], [strType], [strCommand], [strIcon], [ysnVisible], [ysnExpanded], [ysnIsLegacy], [ysnLeaf], [intSort], [intConcurrencyId]) 
			VALUES (N'Recurring Transactions', N'System Manager', 13, N'Recurring Transactions', N'Screen', N'i21.view.RecurringTransaction', N'small-screen', 0, 0, 0, 1, NULL, 1) 
		END
	/* ------------------------------------------------------ */
	/* -- End Add Common Info Recurring Transactions Menus -- */
	/* ------------------------------------------------------ */
GO

	/* --------------------------------------------------- */
	/* --    Create Contract Management Module Menu     -- */
	/* --------------------------------------------------- */
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Contract Management' AND strModuleName = 'Contract Management' AND intParentMenuID = 0)
	INSERT INTO tblSMMasterMenu (strMenuName, strModuleName, intParentMenuID, strDescription, strType, strCommand, strIcon, ysnVisible, ysnExpanded, ysnIsLegacy, ysnLeaf, intSort, intConcurrencyId)
	VALUES ('Contract Management', 'Contract Management', 0, 'Contract Management', 'Folder', '', 'small-folder', 1, 0, 0, 0, null, 0)

	DECLARE @ContractManagementModuleId INT
	SELECT @ContractManagementModuleId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Contract Management' AND strModuleName = 'Contract Management' AND intParentMenuID = 0

		/* ------------------------------------------------ */
		/* -- Create Contract Management Activities Menu -- */
		/* ------------------------------------------------ */
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Activities' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementModuleId)
		INSERT INTO tblSMMasterMenu (strMenuName, strModuleName, intParentMenuID, strDescription, strType, strCommand, strIcon, ysnVisible, ysnExpanded, ysnIsLegacy, ysnLeaf, intSort, intConcurrencyId)
		VALUES ('Activities', 'Contract Management', @ContractManagementModuleId, 'Activities', 'Folder', '', 'small-folder', 1, 0, 0, 0, 0, 1)

		DECLARE @ContractManagementActivityId INT
		SELECT @ContractManagementActivityId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Activities' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementModuleId

		IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Contract' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementActivityId)
			INSERT INTO tblSMMasterMenu (strMenuName, strModuleName, intParentMenuID, strDescription, strType, strCommand, strIcon, ysnVisible, ysnExpanded, ysnIsLegacy, ysnLeaf, intSort, intConcurrencyId)
			VALUES ('Contract', 'Contract Management', @ContractManagementActivityId, 'Contract', 'Screen', 'ContractManagement.view.Contract', 'small-screen', 0, 0, 0, 1, 0, 1)
		ELSE
			UPDATE tblSMMasterMenu
			SET strCommand = 'ContractManagement.view.Contract', intSort = 0
			WHERE strMenuName = 'Contract' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementActivityId
		

	/* ------------------------------------------------- */
	/* -- Create Contract Management Maintenance Menu -- */
	/* ------------------------------------------------- */
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementModuleId)
	INSERT INTO tblSMMasterMenu (strMenuName, strModuleName, intParentMenuID, strDescription, strType, strCommand, strIcon, ysnVisible, ysnExpanded, ysnIsLegacy, ysnLeaf, intSort, intConcurrencyId)
	VALUES ('Maintenance', 'Contract Management', @ContractManagementModuleId, 'Maintenance', 'Folder', '', 'small-folder', 1, 0, 0, 0, 0, 1)

	DECLARE @ContractManagementMaintenanceId INT
	SELECT @ContractManagementMaintenanceId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementModuleId

		IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Contract Options' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceId)
			INSERT INTO tblSMMasterMenu (strMenuName, strModuleName, intParentMenuID, strDescription, strType, strCommand, strIcon, ysnVisible, ysnExpanded, ysnIsLegacy, ysnLeaf, intSort, intConcurrencyId)
			VALUES ('Contract Options', 'Contract Management', @ContractManagementMaintenanceId, 'Contract Options', 'Screen', 'ContractManagement.view.ContractOptions', 'small-screen', 0, 0, 0, 1, 0, 1)
		ELSE
			UPDATE tblSMMasterMenu
			SET strCommand = 'ContractManagement.view.ContractOptions', intSort = 0
			WHERE strMenuName = 'Contract Options' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceId
			
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Contract Text' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceId)
			INSERT INTO tblSMMasterMenu (strMenuName, strModuleName, intParentMenuID, strDescription, strType, strCommand, strIcon, ysnVisible, ysnExpanded, ysnIsLegacy, ysnLeaf, intSort, intConcurrencyId)
			VALUES ('Contract Text', 'Contract Management', @ContractManagementMaintenanceId, 'Contract Text', 'Screen', 'ContractManagement.view.ContractText', 'small-screen', 0, 0, 0, 1, 0, 1)
		ELSE
			UPDATE tblSMMasterMenu
			SET strCommand = 'ContractManagement.view.ContractText', intSort = 0
			WHERE strMenuName = 'Contract Text' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceId
			
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Cost Type' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceId)
			INSERT INTO tblSMMasterMenu (strMenuName, strModuleName, intParentMenuID, strDescription, strType, strCommand, strIcon, ysnVisible, ysnExpanded, ysnIsLegacy, ysnLeaf, intSort, intConcurrencyId)
			VALUES ('Cost Type', 'Contract Management', @ContractManagementMaintenanceId, 'Cost Type', 'Screen', 'ContractManagement.view.CostTypeNew', 'small-screen', 0, 0, 0, 1, 0, 1)
		ELSE
			UPDATE tblSMMasterMenu
			SET strCommand = 'ContractManagement.view.CostTypeNew', intSort = 0
			WHERE strMenuName = 'Cost Type' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceId
				
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Crop Year' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceId)
			INSERT INTO tblSMMasterMenu (strMenuName, strModuleName, intParentMenuID, strDescription, strType, strCommand, strIcon, ysnVisible, ysnExpanded, ysnIsLegacy, ysnLeaf, intSort, intConcurrencyId)
			VALUES ('Crop Year', 'Contract Management', @ContractManagementMaintenanceId, 'Crop Year', 'Screen', 'ContractManagement.view.CropYearNew', 'small-screen', 0, 0, 0, 1, 0, 1)
		ELSE
			UPDATE tblSMMasterMenu
			SET strCommand = 'ContractManagement.view.CropYearNew', intSort = 0
			WHERE strMenuName = 'Crop Year' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceId
			
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Deferred Payment Rates' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceId)
			INSERT INTO tblSMMasterMenu (strMenuName, strModuleName, intParentMenuID, strDescription, strType, strCommand, strIcon, ysnVisible, ysnExpanded, ysnIsLegacy, ysnLeaf, intSort, intConcurrencyId)
			VALUES ('Deferred Payment Rates', 'Contract Management', @ContractManagementMaintenanceId, 'Deferred Payment Rates', 'Screen', 'ContractManagement.view.DeferredPaymentRates', 'small-screen', 0, 0, 0, 1, 0, 1)
		ELSE
			UPDATE tblSMMasterMenu
			SET strCommand = 'ContractManagement.view.DeferredPaymentRates', intSort = 0
			WHERE strMenuName = 'Deferred Payment Rates' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceId
			
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Freight Rates' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceId)
			INSERT INTO tblSMMasterMenu (strMenuName, strModuleName, intParentMenuID, strDescription, strType, strCommand, strIcon, ysnVisible, ysnExpanded, ysnIsLegacy, ysnLeaf, intSort, intConcurrencyId)
			VALUES ('Freight Rates', 'Contract Management', @ContractManagementMaintenanceId, 'Freight Rates', 'Screen', 'ContractManagement.view.FreightRateNew', 'small-screen', 0, 0, 0, 1, 0, 1)
		ELSE
			UPDATE tblSMMasterMenu
			SET strCommand = 'ContractManagement.view.FreightRateNew', intSort = 0
			WHERE strMenuName = 'Freight Rates' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceId
			
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Weight/Grades' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceId)
			INSERT INTO tblSMMasterMenu (strMenuName, strModuleName, intParentMenuID, strDescription, strType, strCommand, strIcon, ysnVisible, ysnExpanded, ysnIsLegacy, ysnLeaf, intSort, intConcurrencyId)
			VALUES ('Weight/Grades', 'Contract Management', @ContractManagementMaintenanceId, 'Weight/Grades', 'Screen', 'ContractManagement.view.WeightGradeNew', 'small-screen', 0, 0, 0, 1, 0, 1)
		ELSE
			UPDATE tblSMMasterMenu
			SET strCommand = 'ContractManagement.view.WeightGradeNew', intSort = 0
			WHERE strMenuName = 'Weight/Grades' AND strModuleName = 'Contract Management' AND intParentMenuID = @ContractManagementMaintenanceId

	/* --------------------------------------------------- */
	/* -- End of Create Contract Management Module Menu -- */
	/* --------------------------------------------------- */
	
GO
	/* --------------------------------------------------- */
	/* --     Create Notes Receivable Module Menu       -- */
	/* --------------------------------------------------- */
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Notes Receivable' AND strModuleName = 'Notes Receivable' AND intParentMenuID = 0)
	INSERT INTO tblSMMasterMenu (strMenuName, strModuleName, intParentMenuID, strDescription, strType, strCommand, strIcon, ysnVisible, ysnExpanded, ysnIsLegacy, ysnLeaf, intSort, intConcurrencyId)
	VALUES ('Notes Receivable', 'Notes Receivable', 0, 'Notes Receivable', 'Folder', '', 'small-folder', 1, 0, 0, 0, null, 0)

	DECLARE @NotesReceivableModuleId INT
	SELECT @NotesReceivableModuleId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Notes Receivable' AND strModuleName = 'Notes Receivable' AND intParentMenuID = 0

	/* ------------------------------------------------- */
	/* --  Create Notes Receivable Maintenance Menu   -- */
	/* ------------------------------------------------- */
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'Notes Receivable' AND intParentMenuID = @NotesReceivableModuleId)
		INSERT INTO tblSMMasterMenu (strMenuName, strModuleName, intParentMenuID, strDescription, strType, strCommand, strIcon, ysnVisible, ysnExpanded, ysnIsLegacy, ysnLeaf, intSort, intConcurrencyId)
		VALUES ('Maintenance', 'Notes Receivable', @NotesReceivableModuleId, 'Maintenance', 'Folder', '', 'small-folder', 1, 0, 0, 0, 2, 1)
	ELSE
		UPDATE tblSMMasterMenu
		SET intSort = 2
		WHERE strMenuName = 'Maintenance' AND strModuleName = 'Notes Receivable' AND intParentMenuID = @NotesReceivableModuleId

	DECLARE @NotesReceivableMaintenanceId INT
	SELECT @NotesReceivableMaintenanceId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'Notes Receivable' AND intParentMenuID = @NotesReceivableModuleId

		IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Note Description' AND strModuleName = 'Notes Receivable' AND intParentMenuID = @NotesReceivableMaintenanceId)
			INSERT INTO tblSMMasterMenu (strMenuName, strModuleName, intParentMenuID, strDescription, strType, strCommand, strIcon, ysnVisible, ysnExpanded, ysnIsLegacy, ysnLeaf, intSort, intConcurrencyId)
			VALUES ('Note Description', 'Notes Receivable', @NotesReceivableMaintenanceId, 'Note Description', 'Screen', 'NotesReceivable.view.NoteDescription', 'small-screen', 0, 0, 0, 1, 0, 1)
		ELSE
			UPDATE tblSMMasterMenu
			SET strCommand = 'NotesReceivable.view.NoteDescription', intSort = 0
			WHERE strMenuName = 'Note Description' AND strModuleName = 'Notes Receivable' AND intParentMenuID = @NotesReceivableMaintenanceId
			
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Show Adjustment As' AND strModuleName = 'Notes Receivable' AND intParentMenuID = @NotesReceivableMaintenanceId)
			INSERT INTO tblSMMasterMenu (strMenuName, strModuleName, intParentMenuID, strDescription, strType, strCommand, strIcon, ysnVisible, ysnExpanded, ysnIsLegacy, ysnLeaf, intSort, intConcurrencyId)
			VALUES ('Show Adjustment As', 'Notes Receivable', @NotesReceivableMaintenanceId, 'Show Adjustment As', 'Screen', 'NotesReceivable.view.ShowAdjustmentAs', 'small-screen', 0, 0, 0, 1, 0, 1)
		ELSE
			UPDATE tblSMMasterMenu
			SET strCommand = 'NotesReceivable.view.ShowAdjustmentAs', intSort = 0
			WHERE strMenuName = 'Show Adjustment As' AND strModuleName = 'Notes Receivable' AND intParentMenuID = @NotesReceivableMaintenanceId

		/* ------------------------------------------------ */
		/* --  Create Notes Receivable Activities Menu   -- */
		/* ------------------------------------------------ */
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Activities' AND strModuleName = 'Notes Receivable' AND intParentMenuID = @NotesReceivableModuleId)
			INSERT INTO tblSMMasterMenu (strMenuName, strModuleName, intParentMenuID, strDescription, strType, strCommand, strIcon, ysnVisible, ysnExpanded, ysnIsLegacy, ysnLeaf, intSort, intConcurrencyId)
			VALUES ('Activities', 'Notes Receivable', @NotesReceivableModuleId, 'Activities', 'Folder', '', 'small-folder', 1, 0, 0, 0, 1, 1)
		ELSE
			UPDATE tblSMMasterMenu
			SET intSort = 1
			WHERE strMenuName = 'Activities' AND strModuleName = 'Notes Receivable' AND intParentMenuID = @NotesReceivableModuleId

		DECLARE @NotesReceivableActivityId INT
		SELECT @NotesReceivableActivityId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Activities' AND strModuleName = 'Notes Receivable' AND intParentMenuID = @NotesReceivableModuleId

		IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Note Maintenance' AND strModuleName = 'Notes Receivable' AND intParentMenuID = @NotesReceivableActivityId)
			INSERT INTO tblSMMasterMenu (strMenuName, strModuleName, intParentMenuID, strDescription, strType, strCommand, strIcon, ysnVisible, ysnExpanded, ysnIsLegacy, ysnLeaf, intSort, intConcurrencyId)
			VALUES ('Note Maintenance ', 'Notes Receivable', @NotesReceivableActivityId, 'Note Maintenance', 'Screen', 'NotesReceivable.view.NotesReceivable', 'small-screen', 0, 0, 0, 1, 0, 1)
		ELSE
			UPDATE tblSMMasterMenu
			SET strCommand = 'NotesReceivable.view.NotesReceivable', intSort = 0
			WHERE strMenuName = 'Note Maintenance' AND strModuleName = 'Notes Receivable' AND intParentMenuID = @NotesReceivableActivityId
			
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Calculate Monthly Interest' AND strModuleName = 'Notes Receivable' AND intParentMenuID = @NotesReceivableActivityId)
			INSERT INTO tblSMMasterMenu (strMenuName, strModuleName, intParentMenuID, strDescription, strType, strCommand, strIcon, ysnVisible, ysnExpanded, ysnIsLegacy, ysnLeaf, intSort, intConcurrencyId)
			VALUES ('Calculate Monthly Interest', 'Notes Receivable', @NotesReceivableActivityId, 'Calculate Monthly Interest', 'Screen', 'NotesReceivable.view.CalculateMonthlyInterest', 'small-screen', 0, 0, 0, 1, 0, 1)
		ELSE
			UPDATE tblSMMasterMenu
			SET strCommand = 'NotesReceivable.view.CalculateMonthlyInterest', intSort = 0
			WHERE strMenuName = 'Calculate Monthly Interest' AND strModuleName = 'Notes Receivable' AND intParentMenuID = @NotesReceivableActivityId

		/* ------------------------------------------------ */
		/* --   Create Notes Receivable Reports Menu     -- */
		/* ------------------------------------------------ */
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Reports' AND strModuleName = 'Notes Receivable' AND intParentMenuID = @NotesReceivableModuleId)
			INSERT INTO tblSMMasterMenu (strMenuName, strModuleName, intParentMenuID, strDescription, strType, strCommand, strIcon, ysnVisible, ysnExpanded, ysnIsLegacy, ysnLeaf, intSort, intConcurrencyId)
			VALUES ('Reports', 'Notes Receivable', @NotesReceivableModuleId, 'Reports', 'Folder', '', 'small-folder', 1, 0, 0, 0, 3, 1)
		ELSE
			UPDATE tblSMMasterMenu
			SET intSort = 3
			WHERE strMenuName = 'Reports' AND strModuleName = 'Notes Receivable' AND intParentMenuID = @NotesReceivableModuleId
		
		DECLARE @NotesReceivableReportsId INT
		SELECT @NotesReceivableReportsId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Reports' AND strModuleName = 'Notes Receivable' AND intParentMenuID = @NotesReceivableModuleId
		
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Notes Receivable Statement' AND strModuleName = 'Notes Receivable' AND intParentMenuID = @NotesReceivableReportsId)
			INSERT INTO tblSMMasterMenu (strMenuName, strModuleName, intParentMenuID, strDescription, strType, strCommand, strIcon, ysnVisible, ysnExpanded, ysnIsLegacy, ysnLeaf, intSort, intConcurrencyId)
			VALUES ('Notes Receivable Statement', 'Notes Receivable', @NotesReceivableReportsId, 'Notes Receivable Statement', 'Report', 'Notes Receivable Statement', 'small-report', 0, 0, 0, 1, 0, 1)
		ELSE
			UPDATE tblSMMasterMenu
			SET strCommand = 'Notes Receivable Statement', intSort = 0
			WHERE strMenuName = 'Notes Receivable Statement' AND strModuleName = 'Notes Receivable' AND intParentMenuID = @NotesReceivableReportsId

		IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Notes Detail' AND strModuleName = 'Notes Receivable' AND intParentMenuID = @NotesReceivableReportsId)
			INSERT INTO tblSMMasterMenu (strMenuName, strModuleName, intParentMenuID, strDescription, strType, strCommand, strIcon, ysnVisible, ysnExpanded, ysnIsLegacy, ysnLeaf, intSort, intConcurrencyId)
			VALUES ('Notes Detail', 'Notes Receivable', @NotesReceivableReportsId, 'Notes Detail', 'Report', 'Notes Detail', 'small-report', 0, 0, 0, 1, 0, 1)
		ELSE
			UPDATE tblSMMasterMenu
			SET strCommand = 'Notes Detail', intSort = 0
			WHERE strMenuName = 'Notes Detail' AND strModuleName = 'Notes Receivable' AND intParentMenuID = @NotesReceivableReportsId

		IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Notes GL Balancing' AND strModuleName = 'Notes Receivable' AND intParentMenuID = @NotesReceivableReportsId)
			INSERT INTO tblSMMasterMenu (strMenuName, strModuleName, intParentMenuID, strDescription, strType, strCommand, strIcon, ysnVisible, ysnExpanded, ysnIsLegacy, ysnLeaf, intSort, intConcurrencyId)
			VALUES ('Notes GL Balancing', 'Notes Receivable', @NotesReceivableReportsId, 'Notes GL Balancing', 'Report', 'Notes GL Balancing', 'small-report', 0, 0, 0, 1, 0, 1)
		ELSE
			UPDATE tblSMMasterMenu
			SET strCommand = 'Notes GL Balancing', intSort = 0
			WHERE strMenuName = 'Notes GL Balancing' AND strModuleName = 'Notes Receivable' AND intParentMenuID = @NotesReceivableReportsId

		IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Notes Payment by Date' AND strModuleName = 'Notes Receivable' AND intParentMenuID = @NotesReceivableReportsId)
			INSERT INTO tblSMMasterMenu (strMenuName, strModuleName, intParentMenuID, strDescription, strType, strCommand, strIcon, ysnVisible, ysnExpanded, ysnIsLegacy, ysnLeaf, intSort, intConcurrencyId)
			VALUES ('Notes Payment by Date', 'Notes Receivable', @NotesReceivableReportsId, 'Notes Payment by Date', 'Report', 'Notes Payment by Date', 'small-report', 0, 0, 0, 1, 0, 1)
		ELSE
			UPDATE tblSMMasterMenu
			SET strCommand = 'Notes Payment by Date', intSort = 0
			WHERE strMenuName = 'Notes Payment by Date' AND strModuleName = 'Notes Receivable' AND intParentMenuID = @NotesReceivableReportsId

		IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Open Notes on AS OF Date' AND strModuleName = 'Notes Receivable' AND intParentMenuID = @NotesReceivableReportsId)
			INSERT INTO tblSMMasterMenu (strMenuName, strModuleName, intParentMenuID, strDescription, strType, strCommand, strIcon, ysnVisible, ysnExpanded, ysnIsLegacy, ysnLeaf, intSort, intConcurrencyId)
			VALUES ('Open Notes on AS OF Date', 'Notes Receivable', @NotesReceivableReportsId, 'Open Notes on AS OF Date', 'Report', 'Open Notes on AS OF Date', 'small-report', 0, 0, 0, 1, 0, 1)
		ELSE
			UPDATE tblSMMasterMenu
			SET strCommand = 'Open Notes on AS OF Date', intSort = 0
			WHERE strMenuName = 'Open Notes on AS OF Date' AND strModuleName = 'Notes Receivable' AND intParentMenuID = @NotesReceivableReportsId

		IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'UCC Tracking' AND strModuleName = 'Notes Receivable' AND intParentMenuID = @NotesReceivableReportsId)
			INSERT INTO tblSMMasterMenu (strMenuName, strModuleName, intParentMenuID, strDescription, strType, strCommand, strIcon, ysnVisible, ysnExpanded, ysnIsLegacy, ysnLeaf, intSort, intConcurrencyId)
			VALUES ('UCC Tracking', 'Notes Receivable', @NotesReceivableReportsId, 'UCC Tracking', 'Report', 'UCC Tracking', 'small-report', 0, 0, 0, 1, 0, 1)
		ELSE
			UPDATE tblSMMasterMenu
			SET strCommand = 'UCC Tracking', intSort = 0
			WHERE strMenuName = 'UCC Tracking' AND strModuleName = 'Notes Receivable' AND intParentMenuID = @NotesReceivableReportsId

		IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Aged Notes Receivable' AND strModuleName = 'Notes Receivable' AND intParentMenuID = @NotesReceivableReportsId)
			INSERT INTO tblSMMasterMenu (strMenuName, strModuleName, intParentMenuID, strDescription, strType, strCommand, strIcon, ysnVisible, ysnExpanded, ysnIsLegacy, ysnLeaf, intSort, intConcurrencyId)
			VALUES ('Aged Notes Receivable', 'Notes Receivable', @NotesReceivableReportsId, 'Aged Notes Receivable', 'Report', 'Aged Notes Receivable', 'small-report', 0, 0, 0, 1, 0, 1)
		ELSE
			UPDATE tblSMMasterMenu
			SET strCommand = 'Aged Notes Receivable', intSort = 0
			WHERE strMenuName = 'Aged Notes Receivable' AND strModuleName = 'Notes Receivable' AND intParentMenuID = @NotesReceivableReportsId

		IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = '1098' AND strModuleName = 'Notes Receivable' AND intParentMenuID = @NotesReceivableReportsId)
			INSERT INTO tblSMMasterMenu (strMenuName, strModuleName, intParentMenuID, strDescription, strType, strCommand, strIcon, ysnVisible, ysnExpanded, ysnIsLegacy, ysnLeaf, intSort, intConcurrencyId)
			VALUES ('1098', 'Notes Receivable', @NotesReceivableReportsId, '1098', 'Report', '1098', 'small-report', 0, 0, 0, 1, 0, 1)
		ELSE
			UPDATE tblSMMasterMenu
			SET strCommand = '1098', intSort = 0
			WHERE strMenuName = '1098' AND strModuleName = 'Notes Receivable' AND intParentMenuID = @NotesReceivableReportsId

	/* --------------------------------------------------- */
	/* --  End of Create Notes Receivable Module Menu   -- */
	/* --------------------------------------------------- */

	    DELETE FROM tblSMMasterMenu  Where strMenuName = 'New Account Wizard' and intMenuID = 42 and strModuleName = 'General Ledger' and intParentMenuID = 36
GO

	/* ----------------------------------------------- */
	/* --    Create Risk Management Module Menu     -- */
	/* ----------------------------------------------- */
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Risk Management' AND strModuleName = 'Risk Management' AND intParentMenuID = 0)
	INSERT INTO tblSMMasterMenu (strMenuName, strModuleName, intParentMenuID, strDescription, strType, strCommand, strIcon, ysnVisible, ysnExpanded, ysnIsLegacy, ysnLeaf, intSort, intConcurrencyId)
	VALUES ('Risk Management', 'Risk Management', 0, 'Risk Management', 'Folder', '', 'small-folder', 1, 0, 0, 0, 0, 2)
	
	DECLARE @RiskManagementModuleId INT
	SELECT @RiskManagementModuleId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Risk Management' AND strModuleName = 'Risk Management' AND intParentMenuID = 0
	
	/* --------------------------------------------- */
	/* -- Create Risk Management Maintenance Menu -- */
	/* --------------------------------------------- */
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementModuleId)
	INSERT INTO tblSMMasterMenu (strMenuName, strModuleName, intParentMenuID, strDescription, strType, strCommand, strIcon, ysnVisible, ysnExpanded, ysnIsLegacy, ysnLeaf, intSort, intConcurrencyId)
	VALUES ('Maintenance', 'Risk Management', @RiskManagementModuleId, 'Maintenance', 'Folder', '', 'small-folder', 1, 0, 0, 0, 0, 2)

	DECLARE @RiskManagementMaintenanceId INT
	SELECT @RiskManagementMaintenanceId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementModuleId

		IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Futures Market' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementMaintenanceId)
			INSERT INTO tblSMMasterMenu (strMenuName, strModuleName, intParentMenuID, strDescription, strType, strCommand, strIcon, ysnVisible, ysnExpanded, ysnIsLegacy, ysnLeaf, intSort, intConcurrencyId)
			VALUES ('Futures Market', 'Risk Management', @RiskManagementMaintenanceId, 'Futures Market', 'Screen', 'RiskManagement.view.FuturesMarket', 'small-screen', 0, 0, 0, 1, 0, 1)
		ELSE
			UPDATE tblSMMasterMenu
			SET strCommand = 'RiskManagement.view.FuturesMarket', intSort = 0
			WHERE strMenuName = 'Futures Market' AND strModuleName = 'Risk Management' AND intParentMenuID = @RiskManagementMaintenanceId

GO

	/* ----------------------------------------------- */
	/* --   Update Financial Reports Module Menu    -- */
	/* ----------------------------------------------- */

	DECLARE @GeneralLedgerModuleId INT
	SELECT @GeneralLedgerModuleId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'General Ledger' AND strModuleName = 'General Ledger' AND intParentMenuID = 0

	IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Financial Reports' AND strModuleName = 'General Ledger' AND intParentMenuID = @GeneralLedgerModuleId)
	UPDATE tblSMMasterMenu
	SET strModuleName = 'Financial Reports', intParentMenuID = 0
	WHERE strMenuName = 'Financial Reports' AND strModuleName = 'General Ledger' AND intParentMenuID = @GeneralLedgerModuleId

	DECLARE @FinancialReportsModuleId INT
	SELECT @FinancialReportsModuleId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Financial Reports' AND strModuleName = 'Financial Reports' AND intParentMenuID = 0

		/* ---------------------------------------------- */
		/* -- Create Financial Reports Activities Menu -- */
		/* ---------------------------------------------- */

		IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Activities' AND strModuleName = 'Financial Reports' AND intParentMenuID = @FinancialReportsModuleId)
		INSERT INTO tblSMMasterMenu (strMenuName, strModuleName, intParentMenuID, strDescription, strType, strCommand, strIcon, ysnVisible, ysnExpanded, ysnIsLegacy, ysnLeaf, intSort, intConcurrencyId)
		VALUES ('Activities', 'Financial Reports', @FinancialReportsModuleId, 'Activities', 'Folder', '', 'small-folder', 1, 0, 0, 0, 1, 1)
	
		DECLARE @FinancialReportsActivitiesId INT
		SELECT @FinancialReportsActivitiesId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Activities' AND strModuleName = 'Financial Reports' AND intParentMenuID = @FinancialReportsModuleId
	
		IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Financial Report Viewer' AND strModuleName = 'General Ledger' AND intParentMenuID = @FinancialReportsModuleId)
		UPDATE tblSMMasterMenu
		SET strModuleName = 'Financial Reports', intParentMenuID = @FinancialReportsActivitiesId
		WHERE strMenuName = 'Financial Report Viewer' AND strModuleName = 'General Ledger' AND intParentMenuID = @FinancialReportsModuleId
	
		/* -------------------------------------------- */
		/* -- Update Financial Report Designer Menu  -- */
		/* -------------------------------------------- */
		IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Financial Report Designer' AND strModuleName = 'General Ledger' AND intParentMenuID = @FinancialReportsModuleId)
		UPDATE tblSMMasterMenu
		SET strModuleName = 'Financial Reports', strMenuName = 'Maintenance', strDescription = 'Maintenance', intSort = 2
		WHERE strMenuName = 'Financial Report Designer' AND strModuleName = 'General Ledger' AND intParentMenuID = @FinancialReportsModuleId
	
		DECLARE @FinancialReportsMaintenanceId INT
		SELECT @FinancialReportsMaintenanceId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'Financial Reports' AND intParentMenuID = @FinancialReportsModuleId
	
		IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Row Designer' AND strModuleName = 'General Ledger' AND intParentMenuID = @FinancialReportsMaintenanceId)
		UPDATE tblSMMasterMenu
		SET strModuleName = 'Financial Reports'
		WHERE strMenuName = 'Row Designer' AND strModuleName = 'General Ledger' AND intParentMenuID = @FinancialReportsMaintenanceId
	
		IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Column Designer' AND strModuleName = 'General Ledger' AND intParentMenuID = @FinancialReportsMaintenanceId)
		UPDATE tblSMMasterMenu
		SET strModuleName = 'Financial Reports'
		WHERE strMenuName = 'Column Designer' AND strModuleName = 'General Ledger' AND intParentMenuID = @FinancialReportsMaintenanceId
	
		IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Report Header and Footer' AND strModuleName = 'General Ledger' AND intParentMenuID = @FinancialReportsMaintenanceId)
		UPDATE tblSMMasterMenu
		SET strModuleName = 'Financial Reports'
		WHERE strMenuName = 'Report Header and Footer' AND strModuleName = 'General Ledger' AND intParentMenuID = @FinancialReportsMaintenanceId
	
		IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Financial Report Builder' AND strModuleName = 'General Ledger' AND intParentMenuID = @FinancialReportsMaintenanceId)
		UPDATE tblSMMasterMenu
		SET strModuleName = 'Financial Reports'
		WHERE strMenuName = 'Financial Report Builder' AND strModuleName = 'General Ledger' AND intParentMenuID = @FinancialReportsMaintenanceId
	
		IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Report Templates' AND strModuleName = 'General Ledger' AND intParentMenuID = @FinancialReportsMaintenanceId)
		UPDATE tblSMMasterMenu
		SET strModuleName = 'Financial Reports'
		WHERE strMenuName = 'Report Templates' AND strModuleName = 'General Ledger' AND intParentMenuID = @FinancialReportsMaintenanceId

	/* ----------------------------------------------- */
	/* --   End of Financial Reports Module Menu    -- */
	/* ----------------------------------------------- */

GO

	/* ------------------------------------------------- */
	/* - Update Cash Management Menu Commands for MVVM - */
	/* ------------------------------------------------- */

	UPDATE tblSMMasterMenu SET strCommand = 'CashManagement.view.BankDeposit' WHERE strCommand = 'CashManagement.controller.BankDeposit'
	UPDATE tblSMMasterMenu SET strCommand = 'CashManagement.view.BankTransactions' WHERE strCommand = 'CashManagement.controller.BankTransactions'
	UPDATE tblSMMasterMenu SET strCommand = 'CashManagement.view.BankTransfer' WHERE strCommand = 'CashManagement.controller.BankTransfer'
	UPDATE tblSMMasterMenu SET strCommand = 'CashManagement.view.MiscellaneousChecks' WHERE strCommand = 'CashManagement.controller.MiscellaneousChecks'
	UPDATE tblSMMasterMenu SET strCommand = 'CashManagement.view.BankAccountRegister' WHERE strCommand = 'CashManagement.controller.BankAccountRegister'
	UPDATE tblSMMasterMenu SET strCommand = 'CashManagement.view.BankReconciliation' WHERE strCommand = 'CashManagement.controller.BankReconciliation'
	UPDATE tblSMMasterMenu SET strCommand = 'CashManagement.view.Banks' WHERE strCommand = 'CashManagement.controller.Banks'
	UPDATE tblSMMasterMenu SET strCommand = 'CashManagement.view.BankAccounts' WHERE strCommand = 'CashManagement.controller.BankAccounts'
	UPDATE tblSMMasterMenu SET strCommand = 'CashManagement.view.BankFileFormat' WHERE strCommand = 'CashManagement.controller.BankFileFormat'

	/* ------------------------------------------------- */
	/* End Update Cash Management Menu Commands for MVVM */
	/* ------------------------------------------------- */

GO

	/* ------------------------------------------------- */
	/* --- Update Help Desk Menu Commands for MVVM ----- */
	/* ------------------------------------------------- */

	UPDATE tblSMMasterMenu SET strCommand = 'HelpDesk.view.TicketJobCode' WHERE strCommand = 'HelpDesk.controller.TicketJobCode'
	UPDATE tblSMMasterMenu SET strCommand = 'HelpDesk.view.TicketPriority' WHERE strCommand = 'HelpDesk.controller.TicketPriority'
	UPDATE tblSMMasterMenu SET strCommand = 'HelpDesk.view.TicketStatus' WHERE strCommand = 'HelpDesk.controller.TicketStatus'
	UPDATE tblSMMasterMenu SET strCommand = 'HelpDesk.view.TicketType' WHERE strCommand = 'HelpDesk.controller.TicketType'
	UPDATE tblSMMasterMenu SET strCommand = 'HelpDesk.view.HelpDeskSettings' WHERE strCommand = 'HelpDesk.controller.HelpDeskSettings'
	UPDATE tblSMMasterMenu SET strCommand = 'HelpDesk.view.HelpDeskEmailSetup' WHERE strCommand = 'HelpDesk.controller.EmailSetup'
	UPDATE tblSMMasterMenu SET strCommand = 'HelpDesk.view.TicketGroup' WHERE strCommand = 'HelpDesk.controller.TicketGroup'
	UPDATE tblSMMasterMenu SET strCommand = 'HelpDesk.view.Product' WHERE strCommand = 'HelpDesk.controller.Product'

	/* ------------------------------------------------- */
	/* -- End Update Help Desk Menu Commands for MVVM -- */
	/* ------------------------------------------------- */

	/* ------------------------------------------------- */
	/* --- Update AP Menu Commands for MVVM ----- */
	/* ------------------------------------------------- */

	UPDATE tblSMMasterMenu SET strCommand = 'AccountsPayable.view.Bill' WHERE strCommand = 'AccountsPayable.controller.Bill'
	UPDATE tblSMMasterMenu SET strCommand = 'AccountsPayable.view.PayBillsDetail' WHERE strCommand = 'AccountsPayable.controller.PayBillsDetail'
	UPDATE tblSMMasterMenu SET strCommand = 'AccountsPayable.view.BillBatch' WHERE strCommand = 'AccountsPayable.controller.BillBatch'
	UPDATE tblSMMasterMenu SET strCommand = 'AccountsPayable.view.PayBills' WHERE strCommand = 'AccountsPayable.controller.PayBill'
	UPDATE tblSMMasterMenu SET strCommand = 'AccountsPayable.view.BatchPosting' WHERE strCommand = 'AccountsPayable.controller.BatchPosting'

	/* ------------------------------------------------- */
	/* -- End Update AP Menu Commands for MVVM -- */
	/* ------------------------------------------------- */

GO
	/* -------------------------------------------- */
	/* --   Update General Ledger Module Menu    -- */
	/* -------------------------------------------- */

	DECLARE @GeneralLedgerModuleId INT
	SELECT @GeneralLedgerModuleId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'General Ledger' AND strModuleName = 'General Ledger' AND intParentMenuID = 0

	DECLARE @GeneralLedgerMaintenanceId INT
	SELECT @GeneralLedgerMaintenanceId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Maintenance' AND strModuleName = 'General Ledger' AND intParentMenuID = @GeneralLedgerModuleId

		/* ------------------------------ */
		/* -- Update Maintenance Menu  -- */
		/* ------------------------------ */
		IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Account Category' AND strModuleName = 'General Ledger' AND intParentMenuID = @GeneralLedgerMaintenanceId)
		DELETE FROM tblSMMasterMenu where strMenuName = 'Account Category' AND strModuleName = 'General Ledger' AND intParentMenuID = @GeneralLedgerMaintenanceId
		
		UPDATE tblSMMasterMenu SET strCommand = REPLACE (strCommand,'controller','view') WHERE strMenuName = 'General Journal' AND strModuleName = 'General Ledger' AND strCommand = 'GeneralLedger.controller.GeneralJournal'
		UPDATE tblSMMasterMenu SET strCommand = REPLACE (strCommand,'controller','view') WHERE strMenuName = 'Account Structure' AND strModuleName = 'General Ledger' AND strCommand = 'GeneralLedger.controller.AccountStructure'
		UPDATE tblSMMasterMenu SET strCommand = REPLACE (strCommand,'controller','view') WHERE strMenuName = 'Clone Account' AND strModuleName = 'General Ledger' AND strCommand = 'GeneralLedger.controller.AccountClone'

	/* ---------------------------------------- */
	/* --   End General Ledger Module Menu   -- */
	/* ---------------------------------------- */


	/* ------------------------------------------------- */
	/* --- Update GCE Menu Commands for MVVM ----- */
	/* ------------------------------------------------- */

	UPDATE tblSMMasterMenu SET strCommand = 'GlobalComponentEngine.view.CustomField' WHERE strCommand = 'GlobalComponentEngine.controller.CustomField'

	/* ------------------------------------------------- */
	/* -- End Update GCE Menu Commands for MVVM -- */
	/* ------------------------------------------------- */


GO

	/* ------------------------------------------------- */
	/* --- START Update TM Menu Commands for MVVM ----- */
	/* ------------------------------------------------- */

	DECLARE @tmModuleId int
	DECLARE @tmActivitiesId int
	DECLARE @tmMaintenanceId int
	DECLARE @tmMenuName NVARCHAR(150)
	DECLARE @tmCommand NVARCHAR(150)
	
	
	SET @tmModuleId = (SELECT TOP 1 intMenuID FROM [tblSMMasterMenu] WHERE strMenuName = 'Tank Management' AND strModuleName = 'Tank Management' AND intParentMenuID = 0)
	SET @tmActivitiesId = (SELECT TOP 1 intMenuID FROM [tblSMMasterMenu] WHERE strMenuName = 'Activities' AND strModuleName = 'Tank Management' AND intParentMenuID = @tmModuleId)
	SET @tmMaintenanceId = (SELECT TOP 1 intMenuID FROM [tblSMMasterMenu] WHERE strMenuName = 'Maintenance' AND strModuleName = 'Tank Management' AND intParentMenuID = @tmModuleId)

	/*---------------------------------  */
	/*-- START Update TM Maintenance Menu */
	/*---------------------------------  */
		SET @tmMenuName = 'Degree Day Clock'
		SET @tmCommand ='TankManagement.view.DegreeDayClock'
		IF EXISTS (SELECT TOP 1 1 FROM [tblSMMasterMenu] WHERE strMenuName = @tmMenuName AND strModuleName = 'Tank Management' AND intParentMenuID = @tmMaintenanceId)
		BEGIN 
			UPDATE tblSMMasterMenu SET strCommand = @tmCommand WHERE strMenuName = @tmMenuName AND strModuleName = 'Tank Management' AND intParentMenuID = @tmMaintenanceId
		END
	
		SET @tmMenuName = 'Devices'
		SET @tmCommand ='TankManagement.view.Device'
		IF EXISTS (SELECT TOP 1 1 FROM [tblSMMasterMenu] WHERE strMenuName = @tmMenuName AND strModuleName = 'Tank Management' AND intParentMenuID = @tmMaintenanceId)
		BEGIN 
			UPDATE tblSMMasterMenu SET strCommand = @tmCommand WHERE strMenuName = @tmMenuName AND strModuleName = 'Tank Management' AND intParentMenuID = @tmMaintenanceId
		END
	
		SET @tmMenuName = 'Event Type'
		SET @tmCommand ='TankManagement.view.EventType'
		IF EXISTS (SELECT TOP 1 1 FROM [tblSMMasterMenu] WHERE strMenuName = @tmMenuName AND strModuleName = 'Tank Management' AND intParentMenuID = @tmMaintenanceId)
		BEGIN 
			UPDATE tblSMMasterMenu SET strCommand = @tmCommand WHERE strMenuName = @tmMenuName AND strModuleName = 'Tank Management' AND intParentMenuID = @tmMaintenanceId
		END
	
		SET @tmMenuName = 'Device Type'
		SET @tmCommand ='TankManagement.view.DeviceType'
		IF EXISTS (SELECT TOP 1 1 FROM [tblSMMasterMenu] WHERE strMenuName = @tmMenuName AND strModuleName = 'Tank Management' AND intParentMenuID = @tmMaintenanceId)
		BEGIN 
			UPDATE tblSMMasterMenu SET strCommand = @tmCommand WHERE strMenuName = @tmMenuName AND strModuleName = 'Tank Management' AND intParentMenuID = @tmMaintenanceId
		END
	
		SET @tmMenuName = 'Lease Code'
		SET @tmCommand ='TankManagement.view.LeaseCode'
		IF EXISTS (SELECT TOP 1 1 FROM [tblSMMasterMenu] WHERE strMenuName = @tmMenuName AND strModuleName = 'Tank Management' AND intParentMenuID = @tmMaintenanceId)
		BEGIN 
			UPDATE tblSMMasterMenu SET strCommand = @tmCommand WHERE strMenuName = @tmMenuName AND strModuleName = 'Tank Management' AND intParentMenuID = @tmMaintenanceId
		END
	
		SET @tmMenuName = 'Event Automation Setup'
		SET @tmCommand ='TankManagement.view.EventAutomation'
		IF EXISTS (SELECT TOP 1 1 FROM [tblSMMasterMenu] WHERE strMenuName = @tmMenuName AND strModuleName = 'Tank Management' AND intParentMenuID = @tmMaintenanceId)
		BEGIN 
			UPDATE tblSMMasterMenu SET strCommand = @tmCommand WHERE strMenuName = @tmMenuName AND strModuleName = 'Tank Management' AND intParentMenuID = @tmMaintenanceId
		END

		SET @tmMenuName = 'Events'
		SET @tmCommand ='TankManagement.view.Event'
		IF EXISTS (SELECT TOP 1 1 FROM [tblSMMasterMenu] WHERE strMenuName = @tmMenuName AND strModuleName = 'Tank Management' AND intParentMenuID = @tmMaintenanceId)
		BEGIN 
			UPDATE tblSMMasterMenu SET strCommand = @tmCommand WHERE strMenuName = @tmMenuName AND strModuleName = 'Tank Management' AND intParentMenuID = @tmMaintenanceId
		END
	
		SET @tmMenuName = 'Meter Type'
		SET @tmCommand ='TankManagement.view.MeterType'
		IF EXISTS (SELECT TOP 1 1 FROM [tblSMMasterMenu] WHERE strMenuName = @tmMenuName AND strModuleName = 'Tank Management' AND intParentMenuID = @tmMaintenanceId)
		BEGIN 
			UPDATE tblSMMasterMenu SET strCommand = @tmCommand WHERE strMenuName = @tmMenuName AND strModuleName = 'Tank Management' AND intParentMenuID = @tmMaintenanceId
		END
	
	/*---------------------------------*/
	/*-- END Update TM Maintenance Menu */
	/*---------------------------------*/
	
	/*---------------------------------  */
	/*-- START Update TM Activities Menu */
	/*---------------------------------  */
		SET @tmMenuName = 'Customer Inquiry'
		SET @tmCommand ='TankManagement.view.CustomerInquiry'
		IF EXISTS (SELECT TOP 1 1 FROM [tblSMMasterMenu] WHERE strMenuName = @tmMenuName AND strModuleName = 'Tank Management' AND intParentMenuID = @tmActivitiesId)
		BEGIN 
			UPDATE tblSMMasterMenu SET strCommand = @tmCommand WHERE strMenuName = @tmMenuName AND strModuleName = 'Tank Management' AND intParentMenuID = @tmActivitiesId
		END
	
		SET @tmMenuName = 'Consumption Sites'
		SET @tmCommand ='TankManagement.view.ConsumptionSite'
		IF EXISTS (SELECT TOP 1 1 FROM [tblSMMasterMenu] WHERE strMenuName = @tmMenuName AND strModuleName = 'Tank Management' AND intParentMenuID = @tmActivitiesId)
		BEGIN 
			UPDATE tblSMMasterMenu SET strCommand = @tmCommand WHERE strMenuName = @tmMenuName AND strModuleName = 'Tank Management' AND intParentMenuID = @tmActivitiesId
		END
	
		SET @tmMenuName = 'Clock Reading'
		SET @tmCommand ='TankManagement.view.ClockReading'
		IF EXISTS (SELECT TOP 1 1 FROM [tblSMMasterMenu] WHERE strMenuName = @tmMenuName AND strModuleName = 'Tank Management' AND intParentMenuID = @tmActivitiesId)
		BEGIN 
			UPDATE tblSMMasterMenu SET strCommand = @tmCommand WHERE strMenuName = @tmMenuName AND strModuleName = 'Tank Management' AND intParentMenuID = @tmActivitiesId
		END
	/*---------------------------------*/
	/*-- END Update TM Activities Menu */
	/*---------------------------------*/

	/* ------------------------------------------------- */
	/* -- End Update TM Menu Commands for MVVM -- */
	/* ------------------------------------------------- */

GO
	/*----------------------------------  */
	/*-- Start Update System Manager Menu */
	/*----------------------------------  */

	DECLARE @SystemManagerAdminMenuId INT
	SELECT @SystemManagerAdminMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Admin' AND strModuleName = 'System Manager' AND intParentMenuID = 0

		/* ---------------------------------- */
		/* -- Update Admin Utilities Menu  -- */
		/* ---------------------------------- */
		IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'User Security' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerAdminMenuId)
		UPDATE tblSMMasterMenu SET strCommand = REPLACE (strCommand,'controller','view') 
		WHERE strMenuName = 'User Security' AND strModuleName = 'System Manager' AND strCommand = 'i21.controller.UserSecurity'

	
	DECLARE @SystemManagerAdminUtilitiesMenuId INT
	SELECT @SystemManagerAdminUtilitiesMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Utilities' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerAdminMenuId
		
		/* ---------------------------------- */
		/* -- Update Admin Utilities Menu  -- */
		/* ---------------------------------- */
		IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Import Origin Users' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerAdminUtilitiesMenuId)
		UPDATE tblSMMasterMenu SET strCommand = REPLACE (strCommand,'controller','view') 
		WHERE strMenuName = 'Import Origin Users' AND strModuleName = 'System Manager' AND strCommand = 'i21.controller.ImportLegacyUsers'

		IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Import Origin Menus' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerAdminUtilitiesMenuId)
        UPDATE tblSMMasterMenu SET strCommand = REPLACE (strCommand,'controller','view') 
        WHERE strMenuName = 'Import Origin Menus' AND strModuleName = 'System Manager' AND strCommand = 'i21.controller.ImportLegacyMenus'


	DECLARE @SystemManagerModuleId INT
	SELECT @SystemManagerModuleId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Common Info' AND strModuleName = 'System Manager' AND intParentMenuID = 0
		
		/* ------------------------------ */
		/* -- Update Common Info Menu  -- */
		/* ------------------------------ */
		IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Country' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerModuleId)
		UPDATE tblSMMasterMenu SET strCommand = REPLACE (strCommand,'controller','view') 
		WHERE strMenuName = 'Country' AND strModuleName = 'System Manager' AND strCommand = 'i21.controller.Country'

		IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Currency' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerModuleId)
		UPDATE tblSMMasterMenu SET strCommand = REPLACE (strCommand,'controller','view') 
		WHERE strMenuName = 'Currency' AND strModuleName = 'System Manager' AND strCommand = 'i21.controller.Currency'

		IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Ship Via' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerModuleId)
		UPDATE tblSMMasterMenu SET strCommand = REPLACE (strCommand,'controller','view') 
		WHERE strMenuName = 'Ship Via' AND strModuleName = 'System Manager' AND strCommand = 'i21.controller.ShipVia'

		IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Payment Methods' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerModuleId)
		UPDATE tblSMMasterMenu SET strCommand = REPLACE (strCommand,'controller','view') 
		WHERE strMenuName = 'Payment Methods' AND strModuleName = 'System Manager' AND strCommand = 'i21.controller.PaymentMethod'

		IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Freight Terms' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerModuleId)
		UPDATE tblSMMasterMenu SET strCommand = REPLACE (strCommand,'controller','view') 
		WHERE strMenuName = 'Freight Terms' AND strModuleName = 'System Manager' AND strCommand = 'i21.controller.FreightTerms'

		IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Terms' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerModuleId)
		UPDATE tblSMMasterMenu SET strCommand = REPLACE (strCommand,'controller','view') 
		WHERE strMenuName = 'Terms' AND strModuleName = 'System Manager' AND strCommand = 'i21.controller.Term'

		IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Company Location' AND strModuleName = 'System Manager' AND intParentMenuID = @SystemManagerModuleId)
		UPDATE tblSMMasterMenu SET strCommand = REPLACE (strCommand,'controller','view') 
		WHERE strMenuName = 'Company Location' AND strModuleName = 'System Manager' AND strCommand = 'i21.controller.CompanyLocation'

	/*-------------------------------  */
	/*-- End Update System Manager Menu */
	/*-------------------------------  */
	
GO

	/* ------------------------------------------------- */
	/* --- Update Dashboard Menu Commands for MVVM ----- */
	/* ------------------------------------------------- */

	UPDATE tblSMMasterMenu SET strCommand = 'Dashboard.view.TabSetup' WHERE strCommand = 'Dashboard.controller.TabSetup'
	UPDATE tblSMMasterMenu SET strCommand = 'Dashboard.view.PanelSettings' WHERE strCommand = 'Dashboard.controller.PanelSettings'
	UPDATE tblSMMasterMenu SET strCommand = 'Reports.view.Connection' WHERE strCommand = 'Dashboard.controller.DashboardConnection'

	/* ------------------------------------------------- */
	/* -- End Update Dashboard Menu Commands for MVVM -- */
	/* ------------------------------------------------- */
	
GO

	/* ------------------------------------------------- */
	/* ------ Update FRD Menu Commands for MVVM -------- */
	/* ------------------------------------------------- */

	UPDATE tblSMMasterMenu SET strCommand = REPLACE(strCommand,'FinancialReportDesigner.controller.','FinancialReportDesigner.view.') WHERE strCommand like 'FinancialReportDesigner.controller.%'
	UPDATE tblSMMasterMenu SET strCommand = 'FinancialReportDesigner.view.HeaderFooterDesigner' WHERE strCommand = 'FinancialReportDesigner.view.HeaderDesigner'
	
	/* ------------------------------------------------- */
	/* ---- End Update FRD Menu Commands for MVVM ------ */
	/* ------------------------------------------------- */

	/* ------------------------------------------------- */
	/* --- START Update AR Menu Commands for MVVM ----- */
	/* ------------------------------------------------- */

	DECLARE @ARModuleId int
	DECLARE @ARActivitiesId int
	DECLARE @ARMaintenanceId int
	DECLARE @ARMenuName NVARCHAR(150)
	DECLARE @ARCommand NVARCHAR(150)
	
	
	SET @ARModuleId = (SELECT TOP 1 intMenuID FROM [tblSMMasterMenu] WHERE strMenuName = 'Accounts Receivable' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = 0)
	SET @ARActivitiesId = (SELECT TOP 1 intMenuID FROM [tblSMMasterMenu] WHERE strMenuName = 'Activities' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @ARModuleId)
	SET @ARMaintenanceId = (SELECT TOP 1 intMenuID FROM [tblSMMasterMenu] WHERE strMenuName = 'Maintenance' AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @ARModuleId)

	/*---------------------------------  */
	/*-- START Update AR Maintenance Menu */
	/*---------------------------------  */
		SET @ARMenuName = 'Market Zone'
		SET @ARCommand ='AccountsReceivable.view.MarketZone'
		IF EXISTS (SELECT TOP 1 1 FROM [tblSMMasterMenu] WHERE strMenuName = @ARMenuName AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @ARMaintenanceId)
		BEGIN 
			UPDATE tblSMMasterMenu SET strCommand = @ARCommand WHERE strMenuName = @ARMenuName AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @ARMaintenanceId
		END

		SET @ARMenuName = 'Account Status Codes'
		SET @ARCommand ='AccountsReceivable.view.AccountStatusCodes'
		IF EXISTS (SELECT TOP 1 1 FROM [tblSMMasterMenu] WHERE strMenuName = @ARMenuName AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @ARMaintenanceId)
		BEGIN 
			UPDATE tblSMMasterMenu SET strCommand = @ARCommand WHERE strMenuName = @ARMenuName AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @ARMaintenanceId
		END

		SET @ARMenuName = 'Service Charge'
		SET @ARCommand ='AccountsReceivable.view.ServiceCharge'
		IF EXISTS (SELECT TOP 1 1 FROM [tblSMMasterMenu] WHERE strMenuName = @ARMenuName AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @ARMaintenanceId)
		BEGIN 
			UPDATE tblSMMasterMenu SET strCommand = @ARCommand WHERE strMenuName = @ARMenuName AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @ARMaintenanceId
		END

		SET @ARMenuName = 'Statement Footer Message'
		SET @ARCommand ='AccountsReceivable.view.StatementFooterMessage'
		IF EXISTS (SELECT TOP 1 1 FROM [tblSMMasterMenu] WHERE strMenuName = @ARMenuName AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @ARMaintenanceId)
		BEGIN 
			UPDATE tblSMMasterMenu SET strCommand = @ARCommand WHERE strMenuName = @ARMenuName AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @ARMaintenanceId
		END	

		SET @ARMenuName = 'Customer Group'
		SET @ARCommand ='AccountsReceivable.view.CustomerGroup'
		IF EXISTS (SELECT TOP 1 1 FROM [tblSMMasterMenu] WHERE strMenuName = @ARMenuName AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @ARMaintenanceId)
		BEGIN 
			UPDATE tblSMMasterMenu SET strCommand = @ARCommand WHERE strMenuName = @ARMenuName AND strModuleName = 'Accounts Receivable' AND intParentMenuID = @ARMaintenanceId
		END		

	/*---------------------------------  */
	/*-- END Update AR Maintenance Menu */
	/*---------------------------------  */	
		
	/* ------------------------------------------------- */
	/* -- End Update AR Menu Commands for MVVM -- */
	/* ------------------------------------------------- */
	
GO