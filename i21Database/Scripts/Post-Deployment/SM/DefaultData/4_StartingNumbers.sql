﻿GO
	PRINT N'BEGIN CLEAN UP AND INSERT DEFAULT DATA'
GO
	IF EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'tmpSMStartingNumber')
		DROP TABLE tmpSMStartingNumber
GO
	SELECT * INTO tmpSMStartingNumber FROM tblSMStartingNumber
GO
	TRUNCATE TABLE tblSMStartingNumber
GO
	PRINT N'BEGIN INSERT DEFAULT STARTING NUMBERS'
GO
	SET IDENTITY_INSERT [dbo].[tblSMStartingNumber] ON
		
	INSERT	[dbo].[tblSMStartingNumber] (
			[intStartingNumberId] 
			,[strTransactionType]
			,[strPrefix]
			,[intNumber]
			,[strModule]
			,[ysnEnable]
			,[intConcurrencyId]
	)
	SELECT	[intStartingNumberId]	= 1
			,[strTransactionType]	= N'Audit Adjustment'
			,[strPrefix]			=  N'AA-'
			,[intNumber]			= 1
			,[strModule]			= N'General Ledger'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Audit Adjustment')
	UNION ALL
	SELECT	[intStartingNumberId]	= 2
			,[strTransactionType]	= N'General Journal'
			,[strPrefix]			=  N'GJ-'
			,[intNumber]			= 1
			,[strModule]			= N'General Ledger'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'General Journal')
	UNION ALL
	SELECT	[intStartingNumberId]	= 3
			,[strTransactionType]	= N'Batch Post'
			,[strPrefix]			= N'BATCH-'
			,[intNumber]			= 1
			,[strModule]			= N'Posting'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Batch Post')
	UNION ALL
	SELECT	[intStartingNumberId]	= 4
			,[strTransactionType]	= N'Recurring Journal'
			,[strPrefix]			= N'REC-'
			,[intNumber]			= 1
			,[strModule]			= N'General Ledger'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Recurring Journal')
	UNION ALL
	SELECT	[intStartingNumberId]	= 5
			,[strTransactionType]	= N'General Journal Reversal'
			,[strPrefix]			= N'REV-'
			,[intNumber]			= 1
			,[strModule]			= N'General Ledger'
			,[ysnEnable]			= 1
			,[intConcurrencyId] = 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'General Journal Reversal')
	UNION ALL
	SELECT	[intStartingNumberId]	= 6
			,[strTransactionType]	= N'COA Adjustment'
			,[strPrefix]			= N'GLADJ-'
			,[intNumber]			= 1
			,[strModule]			= N'General Ledger'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'COA Adjustment')
	UNION ALL
	SELECT	[intStartingNumberId]	= 7
			,[strTransactionType]	= N'Bill Batch'
			,[strPrefix]			= N'BB-'
			,[intNumber]			= 1
			,[strModule]			= N'Accounts Payable'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Bill Batch')
	UNION ALL
	SELECT	[intStartingNumberId]	= 8
			,[strTransactionType]	= N'Payable'
			,[strPrefix]			= N'PAY-'
			,[intNumber]			= 1
			,[strModule]			= N'Accounts Payable'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Payable')
	UNION ALL
	SELECT	[intStartingNumberId]	= 9
			,[strTransactionType]	= N'Bill'
			,[strPrefix]			= N'BL-'
			,[intNumber]			= 1
			,[strModule]			= N'Accounts Payable'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Bill')
	UNION ALL
	SELECT	[intStartingNumberId]	= 10
			,[strTransactionType]	= N'Bank Deposit'
			,[strPrefix]			= N'BDEP-'
			,[intNumber]			= 1
			,[strModule]			= 'Cash Management'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Bank Deposit')
	UNION ALL
	SELECT	[intStartingNumberId]	= 11
			,[strTransactionType]	= N'Bank Withdrawal'
			,[strPrefix]			= N'BWD-'
			,[intNumber]			= 1
			,[strModule]			= 'Cash Management'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Bank Withdrawal')
	UNION ALL
	SELECT	[intStartingNumberId]	= 12
			,[strTransactionType]	= N'Bank Transfer'
			,[strPrefix]			= N'BTFR-'
			,[intNumber]			= 1
			,[strModule]			= 'Cash Management'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Bank Transfer')
	UNION ALL
	SELECT	[intStartingNumberId]	= 13
			,[strTransactionType]	= N'Bank Transaction'
			,[strPrefix]			= N'BTRN-'
			,[intNumber]			= 1
			,[strModule]			= 'Cash Management'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Bank Transaction')
	UNION ALL
	SELECT	[intStartingNumberId]	= 14
			,[strTransactionType]	= N'Misc Checks'
			,[strPrefix]			= N'MCHK-'
			,[intNumber]			= 1
			,[strModule]			= 'Cash Management'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Misc Checks')
	UNION ALL
	SELECT	[intStartingNumberId]	= 15
			,[strTransactionType]	= N'Bank Stmt Import'
			,[strPrefix]			= N'BSI-'
			,[intNumber]			= 1
			,[strModule]			= 'Cash Management'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Bank Stmt Import')
	UNION ALL
	SELECT	[intStartingNumberId]	= 16
			,[strTransactionType]	= N'Ticket Number'
			,[strPrefix]			= N'HDTN-'
			,[intNumber]			= 1
			,[strModule]			= 'Help Desk'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Ticket Number')
	UNION ALL
	SELECT	[intStartingNumberId]	= 17
			,[strTransactionType]	= N'Receive Payments'
			,[strPrefix]			= N'RCV-'
			,[intNumber]			= 1
			,[strModule]			= 'Accounts Receivable'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Receive Payments')
	UNION ALL
	SELECT	[intStartingNumberId]	= 18
			,[strTransactionType]	= N'Debit Memo'
			,[strPrefix]			= N'DM-'
			,[intNumber]			= 1
			,[strModule]			= 'Purchasing'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Debit Memo')
	UNION ALL
	SELECT	[intStartingNumberId]	= 19
			,[strTransactionType]	= N'Invoice'
			,[strPrefix]			= N'SI-'
			,[intNumber]			= 1
			,[strModule]			= 'Accounts Receivable'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Invoice')
    UNION ALL
	SELECT	[intStartingNumberId]	= 20
			,[strTransactionType]	= N'Vendor Prepayment'
			,[strPrefix]			= N'VPRE-'
			,[intNumber]			= 1
			,[strModule]			= 'Accounts Payable'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Vendor Prepayment')
	UNION ALL
	SELECT	[intStartingNumberId]	= 21
			,[strTransactionType]	= N'Lease'
			,[strPrefix]			= N'LEASE-'
			,[intNumber]			= 1
			,[strModule]			= 'Tank Management'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Lease')
	UNION ALL
	SELECT	[intStartingNumberId]	= 22
			,[strTransactionType]	= N'Purchase Order'
			,[strPrefix]			= N'PO-'
			,[intNumber]			= 1
			,[strModule]			= 'AccountsPayable'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Purchase Order')
	UNION ALL
	SELECT	[intStartingNumberId]	= 23
			,[strTransactionType]	= N'Inventory Receipt'
			,[strPrefix]			= N'INVRCT-'
			,[intNumber]			= 1
			,[strModule]			= 'Inventory'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Inventory Receipt')
	UNION ALL
	SELECT	[intStartingNumberId]	= 24
			,[strTransactionType]	= N'Lot Number'
			,[strPrefix]			= N'LOT-'
			,[intNumber]			= 1
			,[strModule]			= 'Inventory'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Lot Number')
	UNION ALL
	SELECT	[intStartingNumberId]	= 25
			,[strTransactionType]	= N'PurchaseContract'
			,[strPrefix]			= N''
			,[intNumber]			= 1
			,[strModule]			= 'Contract Management'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'PurchaseContract')
	UNION ALL
	SELECT	[intStartingNumberId]	= 26
			,[strTransactionType]	= N'SaleContract'
			,[strPrefix]			= N''
			,[intNumber]			= 1
			,[strModule]			= 'Contract Management'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'SaleContract')
	UNION ALL
	SELECT	[intStartingNumberId]	= 27
			,[strTransactionType]	= N'DPContract'
			,[strPrefix]			= N''
			,[intNumber]			= 1
			,[strModule]			= 'Contract Management'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'DPContract')
	UNION ALL
	SELECT	[intStartingNumberId]	= 28
			,[strTransactionType]	= N'Notes Receivable'
			,[strPrefix]			= N'NR-'
			,[intNumber]			= 1
			,[strModule]			= 'Notes Receivable'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Notes Receivable')
	UNION ALL
	SELECT	[intStartingNumberId]	= 29
			,[strTransactionType]	= N'Sales Order'
			,[strPrefix]			= N'SO-'
			,[intNumber]			= 1
			,[strModule]			= 'Accounts Receivable'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Sales Order')
	SET IDENTITY_INSERT [dbo].[tblSMStartingNumber] OFF
GO
	PRINT N'END INSERT DEFAULT STARTING NUMBERS'
GO
	-- Update the intNumber to update what really should be the current value
	UPDATE tblSMStartingNumber
	SET intNumber = x.intNumber
	FROM tmpSMStartingNumber x
	WHERE tblSMStartingNumber.strTransactionType = x.strTransactionType
GO
	-- all that starts with 0 should start with 1
	UPDATE tblSMStartingNumber SET intNumber = 1 WHERE intNumber =0

GO
	IF EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'tmpSMStartingNumber')
		DROP TABLE tmpSMStartingNumber
GO
	PRINT N'BEGIN CLEAN UP AND INSERT DEFAULT DATA'
GO

PRINT N'BEGIN CHECKING AND FIXING ANY CORRUPT STARTING NUMBERS FOR CASH MANAGEMENT'
GO

EXEC uspCMFixStartingNumbers

GO
PRINT N'END CHECKING AND FIXING ANY CORRUPT STARTING NUMBERS FOR CASH MANAGEMENT'

GO

PRINT N'BEGIN CHECKING AND FIXING ANY CORRUPT STARTING NUMBERS FOR ACCOUNTS PAYABLE'
GO

EXEC uspAPFixStartingNumbers

GO
PRINT N'END CHECKING AND FIXING ANY CORRUPT STARTING NUMBERS FOR ACCOUNTS PAYABLE'

GO

PRINT N'BEGIN CHECKING AND FIXING ANY CORRUPT STARTING NUMBERS FOR GENERAL LEDGER'
GO

EXEC uspGLFixStartingNumbers

GO
PRINT N'END CHECKING AND FIXING ANY CORRUPT STARTING NUMBERS FOR GENERAL LEDGER'


