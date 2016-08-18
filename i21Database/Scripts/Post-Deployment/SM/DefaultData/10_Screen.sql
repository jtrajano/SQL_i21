﻿GO
	PRINT N'BEGIN INSERT DEFAULT SCREEN'
GO
	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'GlobalComponentEngine.view.Activity') 
		BEGIN
			INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId]) 
			VALUES (N'Activity', N'Activity', N'GlobalComponentEngine.view.Activity', N'System Manager', N'tblSMActivity', 0)
		END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'GeneralLedger.view.GeneralJournal') 
		BEGIN
			INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [ysnApproval], [ysnCustomTab], [intConcurrencyId]) 
			VALUES (N'GeneralJournal', N'General Journal', N'GeneralLedger.view.GeneralJournal', N'General Ledger', N'tblGLJournal', 1, 1,  0)
		END
	ELSE
		BEGIN
			UPDATE tblSMScreen
			SET strTableName = N'tblGLJournal',
				ysnApproval = 1, 
				ysnCustomTab = 1
			WHERE strNamespace = 'GeneralLedger.view.GeneralJournal'
		END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'GeneralLedger.view.EditAccount') 
		BEGIN
			INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [ysnApproval], [ysnCustomTab], [intConcurrencyId]) 
			VALUES (N'EditAccount', N'Edit Account', N'GeneralLedger.view.EditAccount', N'General Ledger', N'tblGLAccount', NULL, 1,  0)
		END
	ELSE
		BEGIN
			UPDATE tblSMScreen
			SET strTableName = N'tblGLAccount',
				ysnCustomTab = 1
			WHERE strNamespace = 'GeneralLedger.view.EditAccount'
		END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'EntityManagement.view.Entity') 
		BEGIN
			INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [ysnApproval], [ysnCustomTab], [intConcurrencyId]) 
			VALUES (N'Entity', N'Entity', N'EntityManagement.view.Entity', N'Entity Management', N'tblEMEntity', NULL, 1, 0)
		END
	ELSE
		BEGIN
			UPDATE tblSMScreen
			SET strTableName = N'tblEntity', 
				ysnCustomTab = 1
			WHERE strNamespace = 'EntityManagement.view.Entity'
		END
		
	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'Logistics.view.LoadSchedule')
		BEGIN
			INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [ysnApproval], [ysnCustomTab], [intConcurrencyId])
			VALUES (N'LoadSchedule', N'Load Schedule', N'Logistics.view.LoadSchedule', N'Logistics', N'tblLGLoad', NULL, 1, 0)
		END
	ELSE
		BEGIN
			UPDATE tblSMScreen
			SET strTableName = N'tblLGLoad', 
				ysnCustomTab = 1
			WHERE strNamespace = 'Logistics.view.LoadSchedule'
		END

	
	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'EntityManagement.view.EntityContact') 
		BEGIN
			INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [ysnApproval], [ysnCustomTab], [intConcurrencyId]) 
			VALUES (N'Entity Contact', N'Entity Contact', N'EntityManagement.view.EntityContact', N'Entity Management', N'tblEMEntity', NULL, 1, 0)
		END
	ELSE
		BEGIN
			UPDATE tblSMScreen
			SET strTableName = N'tblEMEntity', 
				strScreenId = N'Entity Contact', 
				strScreenName = 'Entity Contact',
				ysnCustomTab = 1
			WHERE strNamespace = 'EntityManagement.view.EntityContact'
		END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'AccountsPayable.view.Voucher') 
		BEGIN
			INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [ysnApproval], [ysnCustomTab], [intConcurrencyId]) 
			VALUES (N'Voucher', N'Voucher', N'AccountsPayable.view.Voucher', N'Accounts Payable', N'tblAPBill',  1, NULL,  0)
		END
	ELSE
		BEGIN
			UPDATE tblSMScreen
			SET strTableName = 'tblAPBill',
				ysnApproval = 1
			WHERE strNamespace = 'AccountsPayable.view.Voucher'
		END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'AccountsPayable.view.PurchaseOrder') 
		BEGIN
			INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [ysnApproval], [ysnCustomTab], [intConcurrencyId]) 
			VALUES (N'Purchase Order', N'Purchase Order', N'AccountsPayable.view.PurchaseOrder', N'Accounts Payable', N'tblPOPurchase',  1, NULL,  0)
		END
	ELSE
		BEGIN
			UPDATE tblSMScreen
			SET strTableName = 'tblPOPurchase',
				ysnApproval = 1
			WHERE strNamespace = 'AccountsPayable.view.PurchaseOrder'
		END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'AccountsReceivable.view.Quote') 
		BEGIN
			INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [ysnApproval], [ysnCustomTab], [intConcurrencyId]) 
			VALUES (N'Quote', N'Quote', N'AccountsReceivable.view.Quote', N'Accounts Receivable', N'tblSOSalesOrder',  1,  NULL,  0)
		END
	ELSE
		BEGIN
			UPDATE tblSMScreen
			SET strTableName = 'tblSOSalesOrder',
				ysnApproval = 1
			WHERE strNamespace = 'AccountsReceivable.view.Quote'
		END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'AccountsReceivable.view.SalesOrder') 
		BEGIN
			INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [ysnApproval], [ysnCustomTab], [intConcurrencyId]) 
			VALUES (N'Sales Order', N'Sales Order', N'AccountsReceivable.view.SalesOrder', N'Accounts Receivable', N'tblSOSalesOrder', 1,  NULL,  0)
		END
	ELSE
		BEGIN
			UPDATE tblSMScreen
			SET strTableName = 'tblSOSalesOrder',
				ysnApproval = 1
			WHERE strNamespace = 'AccountsReceivable.view.SalesOrder'
		END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'ContractManagement.view.Contract') 
		BEGIN
			INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName],[ysnApproval], [ysnCustomTab], [intConcurrencyId]) 
			VALUES (N'Contract', N'Contract', N'ContractManagement.view.Contract', N'Contract Management', N'tblCTContractHeader',  1,  NULL,  0)
		END
	ELSE
		BEGIN
			UPDATE tblSMScreen
			SET strTableName = 'tblCTContractHeader',
				ysnApproval = 1
			WHERE strNamespace = 'ContractManagement.view.Contract'
		END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'RiskManagement.view.FuturesOptionsTransactions') 
		BEGIN
			INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [ysnApproval], [ysnCustomTab], [intConcurrencyId]) 
			VALUES (N'Futures Options Transactions', N'Futures Options Transactions', N'RiskManagement.view.FuturesOptionsTransactions', N'Risk Management', N'tblRKFutOptTransaction', 1,  NULL,  0)
		END
	ELSE
		BEGIN
			UPDATE tblSMScreen
			SET strTableName = 'tblRKFutOptTransaction',
				ysnApproval = 1
			WHERE strNamespace = 'RiskManagement.view.FuturesOptionsTransactions'
		END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'Payroll.view.TimeOffRequest') 
		BEGIN
			INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName],  [ysnApproval], [ysnCustomTab], [intConcurrencyId]) 
			VALUES (N'Time Off Requests', N'Time Off Requests', N'Payroll.view.TimeOffRequest', N'Payroll', N'tblPRTimeOffRequest',  1,  NULL,  0)
		END
	ELSE
		BEGIN
			UPDATE tblSMScreen
			SET strTableName = 'tblPRTimeOffRequest',
				ysnApproval = 1
			WHERE strNamespace = 'Payroll.view.TimeOffRequest'
		END
GO
	PRINT N'END INSERT DEFAULT SCREEN'
GO