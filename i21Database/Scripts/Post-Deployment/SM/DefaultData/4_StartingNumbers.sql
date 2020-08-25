GO
	PRINT N'BEGIN RENAME OF TRANSACTION'

	UPDATE tblSMStartingNumber SET strTransactionType = 'Delivery Notice'
	WHERE strModule = 'Logistics' AND strTransactionType = 'Weight Claims' AND intStartingNumberId = 86

	UPDATE tblSMStartingNumber SET strTransactionType = 'Document Maintenance'
	WHERE strModule = 'Accounts Receivable' AND strTransactionType = 'Comment Maintenance'

	UPDATE tblSMStartingNumber SET strTransactionType = 'Report Messages', strModule = 'System Manager'
	WHERE strModule = 'Accounts Receivable' AND strTransactionType = 'Document Maintenance'

	UPDATE tblSMStartingNumber SET strTransactionType = 'Derivative Entry'
	WHERE strTransactionType = N'FutOpt Transaction'

GO
	PRINT N'BEGIN RENAME OF TRANSACTION'

	UPDATE tblSMStartingNumber SET strPrefix = 'PCE-'
	WHERE strPrefix = 'CE-' AND strTransactionType = N'Cancel Equity' AND strModule = 'Patronage'
	
	UPDATE tblSMStartingNumber SET strPrefix = 'PATR-'
	WHERE strPrefix = 'PR-' AND strTransactionType = N'Process Refund' AND strModule = 'Patronage'

	UPDATE tblSMStartingNumber SET strPrefix = 'PSS-'
	WHERE strPrefix = 'SS-' AND strTransactionType = N'Change Stock Status Number' AND strModule = 'Patronage'	

	UPDATE tblSMStartingNumber SET strPrefix = 'PADJ-'
	WHERE strPrefix = 'ADJ-' AND strTransactionType = N'Adjustment Number' AND strModule = 'Patronage'	

	UPDATE tblSMStartingNumber SET strPrefix = 'PCRT-'
	WHERE strPrefix = 'CRT-' AND strTransactionType = N'Certificate Number' AND strModule = 'Patronage'	

	UPDATE tblSMStartingNumber
	SET [strPrefix] = 'PDIV-'
	WHERE strTransactionType = N'Dividend Number' AND strModule = 'Patronage'

	UPDATE tblSMStartingNumber SET strPrefix = 'PTR-'
	WHERE strPrefix = 'TRF-' AND strTransactionType = N'Transfer' AND strModule = 'Patronage'	

	UPDATE tblSMStartingNumber SET strPrefix = N''
	WHERE strPrefix = N' ' AND strTransactionType = N'CPE Receipt' AND strModule = 'Ticket Management'	

	UPDATE tblSMStartingNumber SET strPrefix = N''
	WHERE strPrefix = N' ' AND strTransactionType = N'Delivery Sheet' AND strModule = 'Ticket Management'

	UPDATE tblSMStartingNumber SET strModule = 'Accounts Payable'
	WHERE strModule = 'Purchasing'	
GO
	PRINT N'BEGIN DELETE OF TRANSACTION'

	DELETE FROM tblSMStartingNumber
	WHERE strModule = 'Logistics' AND strTransactionType = 'Shipping Instructions'

	DELETE FROM tblSMStartingNumber
	WHERE strModule = 'Logistics' AND strTransactionType = 'Inbound Shipments'

	DELETE FROM tblSMStartingNumber
	WHERE strModule = 'Logistics' AND strTransactionType = 'Delivery Orders'

	DELETE FROM tblSMStartingNumber
	WHERE strModule = 'Accounts Receivable' AND strTransactionType = 'Credit Note'

GO
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
			,[strModule]			= 'Accounts Payable'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Purchase Order')
	UNION ALL
	SELECT	[intStartingNumberId]	= 23
			,[strTransactionType]	= N'Inventory Receipt'
			,[strPrefix]			= N'IR-'
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
	UNION ALL
	SELECT	[intStartingNumberId]	= 30
			,[strTransactionType]	= N'Inventory Adjustment'
			,[strPrefix]			= N'IA-'
			,[intNumber]			= 1
			,[strModule]			= 'Inventory'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Inventory Adjustment')	
	UNION ALL
	SELECT	[intStartingNumberId]	= 31
			,[strTransactionType]	= N'Inventory Shipment'
			,[strPrefix]			= N'IS-'
			,[intNumber]			= 1
			,[strModule]			= 'Inventory'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Inventory Shipment')
	UNION ALL
	SELECT	[intStartingNumberId]	= 32
			,[strTransactionType]	= N'Paycheck'
			,[strPrefix]			= N'PCHK-'
			,[intNumber]			= 1
			,[strModule]			= 'Payroll'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Paycheck')
	UNION ALL
	SELECT	[intStartingNumberId]	= 33
			,[strTransactionType]	= N'Batch Production'
			,[strPrefix]			= N''
			,[intNumber]			= 1
			,[strModule]			= 'Manufacturing'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Batch Production')
	UNION ALL
	SELECT	[intStartingNumberId]	= 34
			,[strTransactionType]	= N'Work Order'
			,[strPrefix]			= N'WO-'
			,[intNumber]			= 1
			,[strModule]			= 'Manufacturing'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Work Order')
	UNION ALL
	SELECT	[intStartingNumberId]	= 36
			,[strTransactionType]	= N'ContractAdjNo'
			,[strPrefix]			= N'Adj - '
			,[intNumber]			= 1
			,[strModule]			= 'Contract Management'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
    WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'ContractAdjNo')
	UNION ALL
	SELECT	[intStartingNumberId]	= 38
			,[strTransactionType]	= N'Allocations'
			,[strPrefix]			= N'AL-'
			,[intNumber]			= 1
			,[strModule]			= 'Logistics'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Allocations')
	UNION ALL
	SELECT	[intStartingNumberId]	= 39
			,[strTransactionType]	= N'Load Schedule'
			,[strPrefix]			= N'LS-'
			,[intNumber]			= 1
			,[strModule]			= 'Logistics'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Load Schedule')
	UNION ALL
	SELECT	[intStartingNumberId]	= 40
			,[strTransactionType]	= N'Generate Loads'
			,[strPrefix]			= N'GL-'
			,[intNumber]			= 1
			,[strModule]			= 'Logistics'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Generate Loads')
	UNION ALL
	SELECT	[intStartingNumberId]	= 41
			,[strTransactionType]	= N'Inventory Transfer'
			,[strPrefix]			= N'IT-'
			,[intNumber]			= 1
			,[strModule]			= 'Inventory'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Inventory Transfer')
	UNION ALL
	SELECT	[intStartingNumberId]	= 42
			,[strTransactionType]	= N'Will Call'
			,[strPrefix]			= N'TMO-'
			,[intNumber]			= 1
			,[strModule]			= 'Tank Management'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Will Call')
	UNION ALL
	SELECT	[intStartingNumberId]	= 43
			,[strTransactionType]	= N'Entity Number'
			,[strPrefix]			= N''
			,[intNumber]			= 1005001
			,[strModule]			= 'Entity Management'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Entity Number')
	UNION ALL
	SELECT	[intStartingNumberId]	= 44
			,[strTransactionType]	= N'Match No'
			,[strPrefix]			= N'S-'
			,[intNumber]			= 1
			,[strModule]			= 'Risk Management'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Match No')
	UNION ALL
	SELECT	[intStartingNumberId]	= 45
			,[strTransactionType]	= N'Derivative Entry'
			,[strPrefix]			= N'DER-'
			,[intNumber]			= 1
			,[strModule]			= 'Risk Management'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Derivative Entry')
	UNION ALL
	SELECT	[intStartingNumberId]	= 46
			,[strTransactionType]	= N'Demand Number'
			,[strPrefix]			= N'DN-'
			,[intNumber]			= 1
			,[strModule]			= 'Manufacturing'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Demand Number')
	UNION ALL
	SELECT	[intStartingNumberId]	= 48
			,[strTransactionType]	= N'Site Number'
			,[strPrefix]			= N''
			,[intNumber]			= 99
			,[strModule]			= 'Entity Management'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Site Number')
	UNION ALL
	SELECT	[intStartingNumberId]	= 49
			,[strTransactionType]	= N'Pick Lots'
			,[strPrefix]			= N'PL-'
			,[intNumber]			= 1
			,[strModule]			= 'Logistics'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Pick Lots')
	UNION ALL
	SELECT	[intStartingNumberId]	= 51
			,[strTransactionType]	= N'Quote'
			,[strPrefix]			= N'QU-'
			,[intNumber]			= 1
			,[strModule]			= 'Accounts Receivable'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Quote')
	UNION ALL
	SELECT	[intStartingNumberId]	= 52
			,[strTransactionType]	= N'Detailed Transaction'
			,[strPrefix]			= N'CFDT-'
			,[intNumber]			= 1
			,[strModule]			= 'Card Fueling'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Detailed Transaction')
	UNION ALL
	SELECT	[intStartingNumberId]	= 53
			,[strTransactionType]	= N'Summarized Invoice'
			,[strPrefix]			= N'CFSI-'
			,[intNumber]			= 1
			,[strModule]			= 'Card Fueling'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Summarized Invoice')
	UNION ALL
	SELECT	[intStartingNumberId]	= 54
			,[strTransactionType]	= N'Transport Load'
			,[strPrefix]			= N'TR-'
			,[intNumber]			= 1
			,[strModule]			= 'Transports'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Transport Load')
	UNION ALL
	SELECT	[intStartingNumberId]	= 55
			,[strTransactionType]	= N'Stage Lot Number'
			,[strPrefix]			= N'STG-'
			,[intNumber]			= 1
			,[strModule]			= 'Manufacturing'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Stage Lot Number')
	UNION ALL
	SELECT	[intStartingNumberId]	= 56
			,[strTransactionType]	= N'Transport Quote'
			,[strPrefix]			= N'TRQ-'
			,[intNumber]			= 1
			,[strModule]			= 'Transports'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Transport Quote')
	UNION ALL
	SELECT	[intStartingNumberId]	= 57
			,[strTransactionType]	= N'Collateral'
			,[strPrefix]			= N'M-'
			,[intNumber]			= 1
			,[strModule]			= 'Risk Management'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Collateral')
	UNION ALL
	SELECT	[intStartingNumberId]	= 58
			,[strTransactionType]	= N'Collateral Header'
			,[strPrefix]			= N''
			,[intNumber]			= 1
			,[strModule]			= 'Risk Management'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Collateral Header')
	UNION ALL
	SELECT	[intStartingNumberId]	= 59
			,[strTransactionType]	= N'Bag Off Order'
			,[strPrefix]			= N'BO-'
			,[intNumber]			= 1
			,[strModule]			= 'Manufacturing'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Bag Off Order')
	UNION ALL
	SELECT	[intStartingNumberId]	= 60
			,[strTransactionType]	= N'Price Fixation Trade No'
			,[strPrefix]			= N''
			,[intNumber]			= 1
			,[strModule]			= 'Contract Management'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Price Fixation Trade No')
	UNION ALL
	SELECT	[intStartingNumberId]	= 61
			,[strTransactionType]	= N'Stock Sales'
			,[strPrefix]			= N'SS-'
			,[intNumber]			= 1
			,[strModule]			= 'Logistics'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Stock Sales')
	UNION ALL
	SELECT	[intStartingNumberId]	= 62
			,[strTransactionType]	= N'Sample Number'
			,[strPrefix]			= N'QS-'
			,[intNumber]			= 1
			,[strModule]			= 'Quality'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Sample Number')
	UNION ALL
	SELECT	[intStartingNumberId]	= 63
			,[strTransactionType]	= N'Schedule Number'
			,[strPrefix]			= N'WS-'
			,[intNumber]			= 1
			,[strModule]			= 'Manufacturing'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Schedule Number')
	UNION ALL
	SELECT	[intStartingNumberId]	= 64
			,[strTransactionType]	= N'Customer Prepayment'
			,[strPrefix]			= N'CPP-'
			,[intNumber]			= 1
			,[strModule]			= 'Accounts Receivable'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Customer Prepayment')
	UNION ALL
	SELECT	[intStartingNumberId]	= 65
			,[strTransactionType]	= N'Customer Overpayment'
			,[strPrefix]			= N'COP-'
			,[intNumber]			= 1
			,[strModule]			= 'Accounts Receivable'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Customer Overpayment')
	UNION ALL
	SELECT	[intStartingNumberId]	= 66
			,[strTransactionType]	= N'Vendor Overpayment'
			,[strPrefix]			= N'VOP-'
			,[intNumber]			= 1
			,[strModule]			= 'Accounts Payable'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Vendor Overpayment')
	UNION ALL
	SELECT	[intStartingNumberId]	= 67
			,[strTransactionType]	= N'Report Messages'
			,[strPrefix]			= N'REP-'
			,[intNumber]			= 1
			,[strModule]			= 'System Manager'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Report Messages')
	UNION ALL
	SELECT	[intStartingNumberId]	= 68
			,[strTransactionType]	= N'Pick List Number'
			,[strPrefix]			= N'PK-'
			,[intNumber]			= 1
			,[strModule]			= 'Manufacturing'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Pick List Number')
	UNION ALL
	SELECT	[intStartingNumberId]	= 69
			,[strTransactionType]	= N'Storage Measurement Reading'
			,[strPrefix]			= N'SMR-'
			,[intNumber]			= 1
			,[strModule]			= 'Inventory'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Storage Measurement Reading')
	UNION ALL
	SELECT	[intStartingNumberId]	= 70
			,[strTransactionType]	= N'Sanitization Order Number'
			,[strPrefix]			= N'S-'
			,[intNumber]			= 1
			,[strModule]			= 'Manufacturing'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Sanitization Order Number')

	UNION ALL
	SELECT	[intStartingNumberId]	= 71
			,[strTransactionType]	= N'StorageTicketNumber'
			,[strPrefix]			= N'STR-'
			,[intNumber]			= 1
			,[strModule]			= 'Ticket Management'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'StorageTicketNumber')

	UNION ALL
	SELECT	[intStartingNumberId]	= 72
			,[strTransactionType]	= N'TransferTicketNumber'
			,[strPrefix]			= N'TRA-'
			,[intNumber]			= 1
			,[strModule]			= 'Ticket Management'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'TransferTicketNumber')

	UNION ALL
	SELECT	[intStartingNumberId]	= 73
			,[strTransactionType]	= N'WarehouseSKUNumber'
			,[strPrefix]			= N'SKU-'
			,[intNumber]			= 1
			,[strModule]			= 'Warehouse'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'WarehouseSKUNumber')

	UNION ALL
	SELECT	[intStartingNumberId]	= 74
			,[strTransactionType]	= N'WarehouseContainerNumber'
			,[strPrefix]			= N'CON-'
			,[intNumber]			= 1
			,[strModule]			= 'Warehouse'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'WarehouseContainerNumber')

	UNION ALL
	SELECT	[intStartingNumberId]	= 75
			,[strTransactionType]	= N'WarehouseBOLNo'
			,[strPrefix]			= N'PK-'
			,[intNumber]			= 1
			,[strModule]			= 'Warehouse'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'WarehouseBOLNo')

	UNION ALL
	SELECT	[intStartingNumberId]	= 76
			,[strTransactionType]	= N'Inventory Count'
			,[strPrefix]			= N'IC-'
			,[intNumber]			= 1
			,[strModule]			= 'Inventory'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Inventory Count')


	UNION ALL
	SELECT	[intStartingNumberId]	= 77
			,[strTransactionType]	= N'Adjustment1099'
			,[strPrefix]			= N'ADJ1099-'
			,[intNumber]			= 1
			,[strModule]			= 'Accounts Payable'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Adjustment1099')

	UNION ALL
	SELECT	[intStartingNumberId]	= 78
			,[strTransactionType]	= N'Parent Lot Number'
			,[strPrefix]			= N'PLOT-'
			,[intNumber]			= 1
			,[strModule]			= 'Manufacturing'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Parent Lot Number')

	UNION ALL
    SELECT  [intStartingNumberId]   = 79
            ,[strTransactionType]   = N'ScaleTicket'
            ,[strPrefix]			= N'SCT-'
            ,[intNumber]            = 1
            ,[strModule]			= 'Ticket Management'
            ,[ysnEnable]			= 1
            ,[intConcurrencyId]		= 1
    WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'ScaleTicket')

	UNION ALL
    SELECT  [intStartingNumberId]   = 80
            ,[strTransactionType]   = N'Transfer'
            ,[strPrefix]			= N'PTR-'
            ,[intNumber]            = 1
            ,[strModule]			= 'Patronage'
            ,[ysnEnable]			= 1
            ,[intConcurrencyId]		= 1
    WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Transfer')

	UNION ALL
	SELECT	[intStartingNumberId]	= 81
			,[strTransactionType]	= N'Provisional'
			,[strPrefix]			= N'PI-'
			,[intNumber]			= 1
			,[strModule]			= 'Accounts Receivable'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Provisional')

	UNION ALL
	SELECT	[intStartingNumberId]	= 82
			,[strTransactionType]	= N'Dividend Number'
			,[strPrefix]			= N'PDIV-'
			,[intNumber]			= 1
			,[strModule]			= 'Patronage'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Dividend Number')

	UNION ALL
	SELECT	[intStartingNumberId]	= 83
			,[strTransactionType]	= N'Certificate Number'
			,[strPrefix]			= N'PCRT-'
			,[intNumber]			= 1
			,[strModule]			= 'Patronage'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Certificate Number')

	UNION ALL
	SELECT	[intStartingNumberId]	= 84
			,[strTransactionType]	= N'Service Charge'
			,[strPrefix]			= N'SC-'
			,[intNumber]			= 1
			,[strModule]			= 'Accounts Receivable'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Service Charge')

	UNION ALL
	SELECT	[intStartingNumberId]	= 85
			,[strTransactionType]	= N'Adjustment Number'
			,[strPrefix]			= N'PADJ-'
			,[intNumber]			= 1
			,[strModule]			= 'Patronage'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Adjustment Number')

	UNION ALL
	SELECT	[intStartingNumberId]	= 86
			,[strTransactionType]	= N'Delivery Notice'
			,[strPrefix]			= N'WC-'
			,[intNumber]			= 1
			,[strModule]			= 'Logistics'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Delivery Notice')

	UNION ALL
	SELECT	[intStartingNumberId]	= 87
			,[strTransactionType]	= N'Change Stock Status Number'
			,[strPrefix]			= N'PSS-'
			,[intNumber]			= 1
			,[strModule]			= 'Patronage'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Change Stock Status Number')

	UNION ALL
	SELECT	[intStartingNumberId]	= 88
			,[strTransactionType]	= N'Currency Contract'
			,[strPrefix]			= N''
			,[intNumber]			= 1
			,[strModule]			= 'Risk Management'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Currency Contract')

	UNION ALL
	SELECT	[intStartingNumberId]	= 89
			,[strTransactionType]	= N'Cancel Equity'
			,[strPrefix]			= N'PCE-'
			,[intNumber]			= 1
			,[strModule]			= 'Patronage'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Cancel Equity')

	UNION ALL
	SELECT	[intStartingNumberId]	= 90
			,[strTransactionType]	= N'Bag Mark'
			,[strPrefix]			= N''
			,[intNumber]			= 1
			,[strModule]			= 'Contract Management'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Bag Mark')
	
	UNION ALL
	SELECT	[intStartingNumberId]	= 91
			,[strTransactionType]	= N'CRM Number'
			,[strPrefix]			= N'CRMN-'
			,[intNumber]			= 1
			,[strModule]			= 'Help Desk'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'CRM Number')

	UNION ALL
	SELECT	[intStartingNumberId]	= 92
			,[strTransactionType]	= N'OffSiteTicketNumber'
			,[strPrefix]			= N'OFF-'
			,[intNumber]			= 1
			,[strModule]			= 'Ticket Management'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'OffSiteTicketNumber')

	UNION ALL
	SELECT	[intStartingNumberId]	= 93
			,[strTransactionType]	= N'Blend Sheet Number'
			,[strPrefix]			= N'BS-'
			,[intNumber]			= 1
			,[strModule]			= 'Manufacturing'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Blend Sheet Number')

	UNION ALL
	SELECT	[intStartingNumberId]	= 94
			,[strTransactionType]	= N'Shipment Integration'
			,[strPrefix]			= N''
			,[intNumber]			= 1
			,[strModule]			= 'Logistics'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Shipment Integration')

	UNION ALL
	SELECT	[intStartingNumberId]	= 95
			,[strTransactionType]	= N'Meter Readings'
			,[strPrefix]			= N'MR-'
			,[intNumber]			= 1
			,[strModule]			= 'Meter Billing'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Meter Readings')
	
	UNION ALL
	SELECT	[intStartingNumberId]	= 96
			,[strTransactionType]	= N'Least Cost Routing'
			,[strPrefix]			= N'LCR-'
			,[intNumber]			= 1
			,[strModule]			= 'Logistics'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Least Cost Routing')

	UNION ALL
	SELECT	[intStartingNumberId]	= 97
			,[strTransactionType]	= N'Clean Cost'
			,[strPrefix]			= N'CC-'
			,[intNumber]			= 1
			,[strModule]			= 'Contract Management'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Clean Cost')

	UNION ALL
	SELECT	[intStartingNumberId]	= 98
			,[strTransactionType]	= N'Dealer Credit Cards'
			,[strPrefix]			= N'DDC-'
			,[intNumber]			= 1
			,[strModule]			= 'Credit Card Recon'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Dealer Credit Cards')

	UNION ALL
	SELECT	[intStartingNumberId]	= 99
			,[strTransactionType]	= N'Sales Receipt'
			,[strPrefix]			= N'SR-'
			,[intNumber]			= 1
			,[strModule]			= 'Accounts Receivable'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Sales Receipt')

	UNION ALL
	SELECT	[intStartingNumberId]	= 100
			,[strTransactionType]	= N'Time Off Request'
			,[strPrefix]			= N'TOR-'
			,[intNumber]			= 1
			,[strModule]			= 'Payroll'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Time Off Request')
	UNION ALL
	SELECT	[intStartingNumberId]	= 101
			,[strTransactionType]	= N'Claim'
			,[strPrefix]			= N'CL-'
			,[intNumber]			= 1
			,[strModule]			= 'Accounts Payable'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Claim')
	UNION ALL
	SELECT	[intStartingNumberId]	= 102
			,[strTransactionType]	= N'Shift Activity Number'
			,[strPrefix]			= N'SA-'
			,[intNumber]			= 1
			,[strModule]			= 'Manufacturing'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Shift Activity Number')

	UNION ALL
	SELECT	[intStartingNumberId]	= 103
			,[strTransactionType]	= N'Activity'
			,[strPrefix]			= N'ACT-'
			,[intNumber]			= 1
			,[strModule]			= 'System Manager'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Activity')

	UNION ALL
	SELECT	[intStartingNumberId]	= 104
			,[strTransactionType]	= N'Truck Billing'
			,[strPrefix]			= N'TB-'
			,[intNumber]			= 1
			,[strModule]			= 'Energy Trac'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Truck Billing')

	UNION ALL
    SELECT  [intStartingNumberId]   = 105
            ,[strTransactionType]   = N'Ticket Management'
            ,[strPrefix]			= N'TKT-'
            ,[intNumber]            = 1
            ,[strModule]			= 'Ticket Management'
            ,[ysnEnable]			= 1
            ,[intConcurrencyId]		= 1
    WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Ticket Management')
	
	UNION ALL
	SELECT	[intStartingNumberId]	= 106
			,[strTransactionType]	= N'Load Shipping Instruction'
			,[strPrefix]			= N'LSI-'
			,[intNumber]			= 1
			,[strModule]			= 'Logistics'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Load Shipping Instruction')

	UNION ALL
	SELECT	[intStartingNumberId]	= 107
			,[strTransactionType]	= N'Inventory Return'
			,[strPrefix]			= N'RTN-'
			,[intNumber]			= 1
			,[strModule]			= 'Inventory'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Inventory Return')

	UNION ALL
	SELECT	[intStartingNumberId]	= 108
			,[strTransactionType]	= N'Process Refund'
			,[strPrefix]			= N'PATR-'
			,[intNumber]			= 1
			,[strModule]			= 'Patronage'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Process Refund')

	UNION ALL
	SELECT	[intStartingNumberId]	= 109
			,[strTransactionType]	= N'Equity Payment'
			,[strPrefix]			= N'EP-'
			,[intNumber]			= 1
			,[strModule]			= 'Patronage'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Equity Payment')
	
	UNION ALL
	SELECT	[intStartingNumberId]	= 110
			,[strTransactionType]	= N'Asset'
			,[strPrefix]			= N'AM-'
			,[intNumber]			= 1
			,[strModule]			= 'Fixed Assets'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Asset')

	UNION ALL
	SELECT	[intStartingNumberId]	= 111
			,[strTransactionType]	= N'Disposition'
			,[strPrefix]			= N'AMDIS-'
			,[intNumber]			= 1
			,[strModule]			= 'Fixed Assets'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Disposition')

	UNION ALL
	SELECT	[intStartingNumberId]	= 112
			,[strTransactionType]	= N'Purchase'
			,[strPrefix]			= N'AMPUR-'
			,[intNumber]			= 1
			,[strModule]			= 'Fixed Assets'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Purchase')

	UNION ALL
	SELECT	[intStartingNumberId]	= 113
			,[strTransactionType]	= N'Depreciation'
			,[strPrefix]			= N'AMDPR-'
			,[intNumber]			= 1
			,[strModule]			= 'Fixed Assets'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Depreciation')

	UNION ALL
	SELECT	[intStartingNumberId]	= 114
			,[strTransactionType]	= N'Weight Claims'
			,[strPrefix]			= N'WC-'
			,[intNumber]			= 1
			,[strModule]			= 'Logistics'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Weight Claims')
	
	UNION ALL
	SELECT	[intStartingNumberId]	= 115
			,[strTransactionType]	= N'Price Contract'
			,[strPrefix]			= N''
			,[intNumber]			= 1
			,[strModule]			= 'Contract Management'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Price Contract')

	UNION ALL
	SELECT	[intStartingNumberId]	= 116
			,[strTransactionType]	= N'Revalue Transaction'
			,[strPrefix]			= N'REVAL-'
			,[intNumber]			= 1
			,[strModule]			= 'General Ledger'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Revalue Transaction')

	UNION ALL
	SELECT	[intStartingNumberId]	= 117
			,[strTransactionType]	= N'Truck Billing Payment'
			,[strPrefix]			= N'TBP-'
			,[intNumber]			= 1
			,[strModule]			= 'Energy Trac'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Truck Billing Payment')

	UNION ALL
	SELECT	 [intStartingNumberId]	= 118
			,[strTransactionType]	= N'Storage Statement FormNo'
			,[strPrefix]			= N'L '
			,[intNumber]			= 1
			,[strModule]			= 'Ticket Management'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Storage Statement FormNo')

	UNION ALL
	SELECT	[intStartingNumberId]	= 119
			,[strTransactionType]	= N'SSCC Label Serial No'
			,[strPrefix]			= N''
			,[intNumber]			= 1
			,[strModule]			= 'Manufacturing'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'SSCC Label Serial No')

	UNION ALL
	SELECT	 [intStartingNumberId]	= 120
			,[strTransactionType]	= N'CPE Receipt'
			,[strPrefix]			= N''
			,[intNumber]			= 1
			,[strModule]			= 'Ticket Management'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'CPE Receipt')

	UNION ALL
	SELECT	 [intStartingNumberId]	= 121
			,[strTransactionType]	= N'Delivery Sheet'
			,[strPrefix]			= N''
			,[intNumber]			= 1
			,[strModule]			= 'Ticket Management'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Delivery Sheet')
	
	UNION ALL
	SELECT	 [intStartingNumberId]	= 122
			,[strTransactionType]	= N'Prepayment Reversal'
			,[strPrefix]			= N''
			,[intNumber]			= 1
			,[strModule]			= 'Accounts Payable'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Prepayment Reversal')

	--UNION ALL
	--SELECT	 [intStartingNumberId]	= 123
	--		,[strTransactionType]	= N'Credit Note'
	--		,[strPrefix]			= N'CN-'
	--		,[intNumber]			= 1
	--		,[strModule]			= 'Accounts Receivable'
	--		,[ysnEnable]			= 1
	--		,[intConcurrencyId]		= 1
	--WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Credit Note')

	UNION ALL
	SELECT	 [intStartingNumberId]	= 124
			,[strTransactionType]	= N'Basis Advance'
			,[strPrefix]			= N'BA-'
			,[intNumber]			= 1
			,[strModule]			= 'Accounts Payable'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Basis Advance')

	UNION ALL
	SELECT	 [intStartingNumberId]	= 125
			,[strTransactionType]	= N'Vendor Rebate Program'
			,[strPrefix]			= N'VRP-'
			,[intNumber]			= 1
			,[strModule]			= 'Vendor Rebates'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Vendor Rebate Program')

	UNION ALL
	SELECT	 [intStartingNumberId]	= 126
			,[strTransactionType]	= N'Issue Stock'
			,[strPrefix]			= N'ISTK-'
			,[intNumber]			= 1
			,[strModule]			= 'Patronage'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Issue Stock')

	UNION ALL
	SELECT	 [intStartingNumberId]	= 127
			,[strTransactionType]	= N'Retire Stock'
			,[strPrefix]			= N'RSTK-'
			,[intNumber]			= 1
			,[strModule]			= 'Patronage'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Retire Stock')

	UNION ALL
	SELECT	[intStartingNumberId]	= 128
			,[strTransactionType]	= N'ZeroPriceTicket'
			,[strPrefix]			= N'ZPT-'
			,[intNumber]			= 1
			,[strModule]			= 'Ticket Management'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'ZeroPriceTicket')

	UNION ALL
	SELECT	 [intStartingNumberId]	= 129
			,[strTransactionType]	= N'Buybacks Program'
			,[strPrefix]			= N'BBP-'
			,[intNumber]			= 1
			,[strModule]			= 'Buybacks'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Buybacks Program')

	UNION ALL
	SELECT	 [intStartingNumberId]	= 130
			,[strTransactionType]	= N'Buybacks Reimbursement'
			,[strPrefix]			= N'BBR-'
			,[intNumber]			= 1
			,[strModule]			= 'Buybacks'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Buybacks Program')

	UNION ALL
	SELECT	[intStartingNumberId]	= 131
			,[strTransactionType]	= N'Amendment Number'
			,[strPrefix]			= N'AMD-'
			,[intNumber]			= 1
			,[strModule]			= 'Contract Management'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Amendment Number')

	UNION ALL
	SELECT	[intStartingNumberId]	= 132
			,[strTransactionType]	= N'Deferred Interest'
			,[strPrefix]			= N'DI-'
			,[intNumber]			= 1
			,[strModule]			= 'Accounts Payable'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Deferred Interest')	
	
	UNION ALL
	SELECT	[intStartingNumberId]	= 133
			,[strTransactionType]	= N'Mark To Market'
			,[strPrefix]			= N'M2M-'
			,[intNumber]			= 1
			,[strModule]			= 'Risk Management'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Mark To Market')

	UNION ALL
	SELECT	[intStartingNumberId]	= 134
			,[strTransactionType]	= N'Allocation Detail'
			,[strPrefix]			= N'ALD-'
			,[intNumber]			= 1
			,[strModule]			= 'Logistics'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Mark To Market')

	UNION ALL
	SELECT	[intStartingNumberId]	= 135
			,[strTransactionType]	= N'Commission'
			,[strPrefix]			= N'COMM-'
			,[intNumber]			= 1
			,[strModule]			= 'Accounts Receivable'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Commission')

	UNION ALL
	SELECT	[intStartingNumberId]	= 136
			,[strTransactionType]	= N'Mark Up/Down'
			,[strPrefix]			= N'MUD-'
			,[intNumber]			= 1
			,[strModule]			= 'Store'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Mark Up/Down')
	
	UNION ALL
	SELECT	[intStartingNumberId]	= 137
			,[strTransactionType]	= N'POS End Of Day'
			,[strPrefix]			= N'EOD-'
			,[intNumber]			= 1
			,[strModule]			= 'Accounts Receivable'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'POS End Of Day')

	UNION ALL
	SELECT	[intStartingNumberId]	= 138
			,[strTransactionType]	= N'Shift Number'
			,[strPrefix]			= N'SN-'
			,[intNumber]			= 1
			,[strModule]			= 'Mobile Billing'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Shift Number')

	UNION ALL
	SELECT	[intStartingNumberId]	= 139
			,[strTransactionType]	= N'Bank Interest'
			,[strPrefix]			= N'BINT-'
			,[intNumber]			= 1
			,[strModule]			= 'Cash Management'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Bank Interest')

	UNION ALL
	SELECT	[intStartingNumberId]	= 140
			,[strTransactionType]	= N'Bank Loan'
			,[strPrefix]			= N'LN-'
			,[intNumber]			= 1
			,[strModule]			= 'Cash Management'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Bank Loan')

	UNION ALL
	SELECT	[intStartingNumberId]	= 141
			,[strTransactionType]	= N'Not Sufficient Fund'
			,[strPrefix]			= N'NSF-'
			,[intNumber]			= 1
			,[strModule]			= 'Cash Management'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Not Sufficient Fund')
	

	UNION ALL
	SELECT	[intStartingNumberId]	= 142
			,[strTransactionType]	= N'Currency Exposure'
			,[strPrefix]			= N''
			,[intNumber]			= 1
			,[strModule]			= 'Risk Management'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Currency Exposure' and strModule = 'Risk Management')

	UNION ALL
	SELECT	[intStartingNumberId]	= 143
			,[strTransactionType]	= N'Daily Average Price'
			,[strPrefix]			= N'DAP-'
			,[intNumber]			= 1
			,[strModule]			= 'Risk Management'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Daily Average Price' and strModule = 'Risk Management')

	UNION ALL
	SELECT	[intStartingNumberId]	= 144
			,[strTransactionType]	= N'Item Contract'
			,[strPrefix]			= N'ITM-'
			,[intNumber]			= 1
			,[strModule]			= 'Contract Management'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Item Contract' and strModule = 'Contract Management')

	UNION ALL
	SELECT	[intStartingNumberId]	= 145
			,[strTransactionType]	= N'Demand'
			,[strPrefix]			= N'DN-'
			,[intNumber]			= 1
			,[strModule]			= 'Manufacturing'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Demand' and strModule = 'Manufacturing')

	UNION ALL 
	SELECT	[intStartingNumberId]	= 146
			,[strTransactionType]	= N'Retail Price Adjustment'
			,[strPrefix]			= N'RPA-'
			,[intNumber]			= 1
			,[strModule]			= 'Store'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Retail Price Adjustment' and strModule = 'Store')

	UNION ALL
	SELECT	[intStartingNumberId]	= 147
			,[strTransactionType]	= N'Demand Plan'
			,[strPrefix]			= N'DP-'
			,[intNumber]			= 1
			,[strModule]			= 'Manufacturing'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Demand Plan' and strModule = 'Manufacturing')

	UNION ALL
	SELECT	[intStartingNumberId]	= 148
			,[strTransactionType]	= N'Summary Log Batch'
			,[strPrefix]			= N'BATCH-'
			,[intNumber]			= 1
			,[strModule]			= 'Risk Management'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Summary Log Batch' and strModule = 'Risk Management')
	UNION ALL
	SELECT	[intStartingNumberId]	= 149
			,[strTransactionType]	= N'PO Export'
			,[strPrefix]			= N'PO-'
			,[intNumber]			= 1
			,[strModule]			= 'Manufacturing'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'PO Export' and strModule = 'Manufacturing')
	UNION ALL
	SELECT	[intStartingNumberId]	= 150
			,[strTransactionType]	= N'PO-Sequence-Cancel'
			,[strPrefix]			= N'PO-'
			,[intNumber]			= 1
			,[strModule]			= 'Manufacturing'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'PO-Sequence-Cancel' and strModule = 'Manufacturing')
	UNION ALL
	SELECT	[intStartingNumberId]	= 151
			,[strTransactionType]	= N'LSI and LS Acknowledgement'
			,[strPrefix]			= N'LS-'
			,[intNumber]			= 1
			,[strModule]			= 'Manufacturing'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'LSI and LS Acknowledgement' and strModule = 'Manufacturing')
	UNION ALL
	SELECT	[intStartingNumberId]	= 155
			,[strTransactionType]	= N'Receipt Item and Charge Update'
			,[strPrefix]			= N'RIDetail-'
			,[intNumber]			= 1
			,[strModule]			= 'Inventory'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Receipt Item and Charge Update' and strModule = 'Inventory')

	--Make sure to check with 19.1 and lower version. 142 is the last number


	SET IDENTITY_INSERT [dbo].[tblSMStartingNumber] OFF
GO
	PRINT N'END INSERT DEFAULT STARTING NUMBERS'
GO
	-- Update the intNumber to update what really should be the current value
	UPDATE tblSMStartingNumber
	SET intNumber = x.intNumber,
	strPrefix = x.strPrefix,
	intDigits = x.intDigits,
	ysnUseLocation = x.ysnUseLocation,
	ysnResetNumber = x.ysnResetNumber,
	dtmResetDate = x.dtmResetDate,
	ysnEnable = x.ysnEnable
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
	PRINT N'BEGIN RENAME PICK LOTS AND DELIVERY ORDER'
	IF EXISTS(SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Pick Lots')
	BEGIN
		UPDATE tblSMStartingNumber
		SET [strPrefix] = 'PL-'
		WHERE strTransactionType = N'Pick Lots'
	END  

	IF EXISTS(SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Delivery Orders')
	BEGIN
		UPDATE tblSMStartingNumber
		SET [strPrefix] = 'DO-'
		WHERE strTransactionType = N'Delivery Orders'
	END

	IF EXISTS(SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Delivery Notice')
	BEGIN
		UPDATE tblSMStartingNumber
		SET [strPrefix] = 'DN-'
		WHERE strTransactionType = N'Delivery Notice'
	END

	IF EXISTS(SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Document Maintenance')
	BEGIN
		UPDATE tblSMStartingNumber
		SET [strPrefix] = 'DOC-'
		WHERE strTransactionType = N'Document Maintenance'
	END  

	IF EXISTS(SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Report Messages')
	BEGIN
		UPDATE tblSMStartingNumber
		SET [strPrefix] = 'REP-'
		WHERE strTransactionType = N'Report Messages'
	END  

	IF EXISTS(SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'WarehouseBOLNo' and [strPrefix]='BOL-')
	BEGIN
		UPDATE tblSMStartingNumber
		SET [strPrefix] = 'PK-'
		WHERE strTransactionType = N'WarehouseBOLNo' and [strPrefix]='BOL-'
	END

	IF EXISTS(SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Derivative Entry')
	BEGIN
	IF NOT EXISTS(select top 1 * from tblRKFutOptTransaction)
		BEGIN
			UPDATE tblSMStartingNumber
			SET [strPrefix] = 'DER-'
			WHERE strTransactionType = N'Derivative Entry'
		END
	END 

GO
	PRINT N'BEGIN RENAME S'

	PRINT N'BEGIN CHECKING AND FIXING ANY CORRUPT STARTING NUMBERS FOR CASH MANAGEMENT'
GO
	EXEC uspCMFixStartingNumbers
GO
	PRINT N'END CHECKING AND FIXING ANY CORRUPT STARTING NUMBERS FOR CASH MANAGEMENT'
GO
	PRINT N'BEGIN CHECKING AND FIXING ANY CORRUPT STARTING NUMBERS FOR ACCOUNTS PAYABLE'
GO
	--EXEC uspAPFixStartingNumbers
GO
	PRINT N'END CHECKING AND FIXING ANY CORRUPT STARTING NUMBERS FOR ACCOUNTS PAYABLE'
GO
	PRINT N'BEGIN CHECKING AND FIXING ANY CORRUPT STARTING NUMBERS FOR GENERAL LEDGER'
GO
	EXEC uspGLFixStartingNumbers
GO
	PRINT N'END CHECKING AND FIXING ANY CORRUPT STARTING NUMBERS FOR GENERAL LEDGER'
GO
