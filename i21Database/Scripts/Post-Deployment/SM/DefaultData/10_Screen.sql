GO
	PRINT N'BEGIN INSERT DEFAULT SCREEN'
GO
	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'GeneralLedger.view.GeneralJournal') 
		BEGIN
			INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [ysnApproval], [intConcurrencyId]) 
			VALUES (N'GeneralJournal', N'General Journal', N'GeneralLedger.view.GeneralJournal', N'General Ledger', N'tblGLJournal', 1,  0)
		END
	ELSE
		BEGIN
			UPDATE tblSMScreen
			SET strTableName = N'tblGLJournal', ysnApproval = 1
			WHERE strNamespace = 'GeneralLedger.view.GeneralJournal'
		END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'GeneralLedger.view.EditAccount') 
		BEGIN
			INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId]) 
			VALUES (N'EditAccount', N'Edit Account', N'GeneralLedger.view.EditAccount', N'General Ledger', N'tblGLAccount', 0)
		END
	ELSE
		BEGIN
			UPDATE tblSMScreen
			SET strTableName = N'tblGLAccount'
			WHERE strNamespace = 'GeneralLedger.view.EditAccount'
		END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'EntityManagement.view.Entity') 
		BEGIN
			INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [ysnCustomGrid], [intConcurrencyId]) 
			VALUES (N'Entity', N'Entity', N'EntityManagement.view.Entity', N'Entity Management', N'tblEMEntity', 1, 0)
		END
	ELSE
		BEGIN
			UPDATE tblSMScreen
			SET strTableName = N'tblEntity', ysnCustomGrid = 1
			WHERE strNamespace = 'EntityManagement.view.Entity'
		END
		
	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'Logistics.view.LoadSchedule')
		BEGIN
			INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId])
			VALUES (N'LoadSchedule', N'Load Schedule', N'Logistics.view.LoadSchedule', N'Logistics', N'tblLGLoad', 0)
		END
	ELSE
		BEGIN
			UPDATE tblSMScreen
			SET strTableName = N'tblLGLoad'
			WHERE strNamespace = 'Logistics.view.LoadSchedule'
		END

	
	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'EntityManagement.view.EntityContact') 
		BEGIN
			INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [intConcurrencyId]) 
			VALUES (N'Entity Contact', N'Entity Contact', N'EntityManagement.view.EntityContact', N'Entity Management', N'tblEMEntity', 0)
		END
	ELSE
		BEGIN
			UPDATE tblSMScreen
			SET strTableName = N'tblEntityContact', strScreenId = N'Entity Contact', strScreenName = 'Entity Contact'
			WHERE strNamespace = 'EntityManagement.view.EntityContact'
		END

	-- Approvals
	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'AccountsPayable.view.Voucher') 
		BEGIN
			INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [ysnApproval], [intConcurrencyId]) 
			VALUES (N'Voucher', N'Voucher', N'AccountsPayable.view.Voucher', N'Accounts Payable', N'', 1,  0)
		END
	ELSE
		BEGIN
			UPDATE tblSMScreen
			SET  ysnApproval = 1
			WHERE strNamespace = 'AccountsPayable.view.Voucher'
		END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'AccountsPayable.view.PurchaseOrder') 
		BEGIN
			INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [ysnApproval], [intConcurrencyId]) 
			VALUES (N'Purchase Order', N'Purchase Order', N'AccountsPayable.view.PurchaseOrder', N'Accounts Payable', N'', 1,  0)
		END
	ELSE
		BEGIN
			UPDATE tblSMScreen
			SET  ysnApproval = 1
			WHERE strNamespace = 'AccountsPayable.view.PurchaseOrder'
		END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'AccountsReceivable.view.Quote') 
		BEGIN
			INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [ysnApproval], [intConcurrencyId]) 
			VALUES (N'Quote', N'Quote', N'AccountsReceivable.view.Quote', N'Accounts Receivable', N'', 1,  0)
		END
	ELSE
		BEGIN
			UPDATE tblSMScreen
			SET  ysnApproval = 1
			WHERE strNamespace = 'AccountsReceivable.view.Quote'
		END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'AccountsReceivable.view.SalesOrder') 
		BEGIN
			INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [ysnApproval], [intConcurrencyId]) 
			VALUES (N'Sales Order', N'Sales Order', N'AccountsReceivable.view.SalesOrder', N'Accounts Receivable', N'', 1,  0)
		END
	ELSE
		BEGIN
			UPDATE tblSMScreen
			SET  ysnApproval = 1
			WHERE strNamespace = 'AccountsReceivable.view.SalesOrder'
		END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'ContractManagement.view.Contract') 
		BEGIN
			INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [ysnApproval], [intConcurrencyId]) 
			VALUES (N'Contract', N'Contract', N'ContractManagement.view.Contract', N'Contract Management', N'', 1,  0)
		END
	ELSE
		BEGIN
			UPDATE tblSMScreen
			SET  ysnApproval = 1
			WHERE strNamespace = 'ContractManagement.view.Contract'
		END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMScreen WHERE strNamespace = 'RiskManagement.view.FuturesOptionsTransactions') 
		BEGIN
			INSERT [dbo].[tblSMScreen] ([strScreenId], [strScreenName], [strNamespace], [strModule], [strTableName], [ysnApproval], [intConcurrencyId]) 
			VALUES (N'Futures Options Transactions', N'Futures Options Transactions', N'RiskManagement.view.FuturesOptionsTransactions', N'Risk Management', N'', 1,  0)
		END
	ELSE
		BEGIN
			UPDATE tblSMScreen
			SET  ysnApproval = 1
			WHERE strNamespace = 'RiskManagement.view.FuturesOptionsTransactions'
		END

GO
	PRINT N'END INSERT DEFAULT SCREEN'
GO