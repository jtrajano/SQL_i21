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
	UNION ALL
	SELECT	[intStartingNumberId]	= 30
			,[strTransactionType]	= N'Inventory Adjustment'
			,[strPrefix]			= N'ADJ-'
			,[intNumber]			= 1
			,[strModule]			= 'Inventory'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Inventory Adjustment')	
	UNION ALL
	SELECT	[intStartingNumberId]	= 31
			,[strTransactionType]	= N'Inventory Shipment'
			,[strPrefix]			= N'INVSHP-'
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
	SELECT	[intStartingNumberId]	= 35
			,[strTransactionType]	= N'Build Assembly'
			,[strPrefix]			= N'BUILD-'
			,[intNumber]			= 1
			,[strModule]			= 'Inventory'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Build Assembly')
	UNION ALL
	SELECT	[intStartingNumberId]	= 36
			 ,[strTransactionType]	= N'ContractAdjNo'
           ,[strPrefix]				= N'Adj - '
           ,[intNumber]				= 1
           ,[strModule]				= 'Contract Management'
           ,[ysnEnable]				= 1
           ,[intConcurrencyId]		= 1
    WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'ContractAdjNo')
	UNION ALL
	SELECT	[intStartingNumberId]	= 37
			,[strTransactionType]	= N'Shipping Instructions'
			,[strPrefix]			= N'SI-'
			,[intNumber]			= 1
			,[strModule]			= 'Logistics'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Shipping Instructions')
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
			,[strPrefix]			= N'INVTRN-'
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
			,[strTransactionType]	= N'FutOpt Transaction'
			,[strPrefix]			= N''
			,[intNumber]			= 1
			,[strModule]			= 'Risk Management'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'FutOpt Transaction')
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
	SELECT	[intStartingNumberId]	= 47
			,[strTransactionType]	= N'Inbound Shipments'
			,[strPrefix]			= N'IS-'
			,[intNumber]			= 1
			,[strModule]			= 'Logistics'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Inbound Shipments')
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
			,[strPrefix]			= N'PL'
			,[intNumber]			= 1
			,[strModule]			= 'Logistics'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Pick Lots')
	UNION ALL
	SELECT	[intStartingNumberId]	= 50
			,[strTransactionType]	= N'Delivery Orders'
			,[strPrefix]			= N'DO'
			,[intNumber]			= 1
			,[strModule]			= 'Logistics'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Delivery Orders')
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
	SET IDENTITY_INSERT [dbo].[tblSMStartingNumber] OFF
GO
	PRINT N'END INSERT DEFAULT STARTING NUMBERS'
GO
	-- Update the intNumber to update what really should be the current value
	UPDATE tblSMStartingNumber
	SET intNumber = x.intNumber,
	strPrefix = x.strPrefix
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


