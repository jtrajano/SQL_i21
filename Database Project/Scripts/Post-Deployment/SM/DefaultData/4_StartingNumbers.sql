GO
	PRINT N'BEGIN INSERT DEFAULT STARTING NUMBERS'
GO
	SET IDENTITY_INSERT [dbo].[tblSMStartingNumber] ON
		
	INSERT	[dbo].[tblSMStartingNumber] (
			[cntID] 
			,[strTransactionType]
			,[strPrefix]
			,[intNumber]
			,[intTransactionTypeID]
			,[strModule]
			,[ysnEnable]
			,[intConcurrencyId]
	)
	SELECT	[cntID]					= 1
			,[strTransactionType]	= N'Audit Adjustment'
			,[strPrefix]			=  N'AA-'
			,[intNumber]			= 1
			,[intTransactionTypeID] = 1
			,[strModule]			= N'Accounting'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Audit Adjustment')
	UNION ALL
	SELECT	[cntID]					= 2
			,[strTransactionType]	= N'General Journal'
			,[strPrefix]			=  N'GJ-'
			,[intNumber]			= 1
			,[intTransactionTypeID] = 2
			,[strModule]			= N'Accounting'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'General Journal')
	UNION ALL
	SELECT	[cntID]					= 3
			,[strTransactionType]	= N'Batch Post'
			,[strPrefix]			= N'BATCH-'
			,[intNumber]			= 1
			,[intTransactionTypeID] = 3
			,[strModule]			= N'Posting'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Batch Post')
	UNION ALL
	SELECT	[cntID]					= 4
			,[strTransactionType]	= N'Recurring Journal'
			,[strPrefix]			= N'REC-'
			,[intNumber]			= 1
			,[intTransactionTypeID] = 4
			,[strModule]			= N'Accounting'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Recurring Journal')
	UNION ALL
	SELECT	[cntID]					= 5
			,[strTransactionType]	= N'General Journal Reversal'
			,[strPrefix]			= N'REV-'
			,[intNumber]			= 1
			,[intTransactionTypeID] = 5
			,[strModule]			= N'Accounting'
			,[ysnEnable]			= 1
			,[intConcurrencyId] = 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'General Journal Reversal')
	UNION ALL
	SELECT	[cntID]					= 6
			,[strTransactionType]	= N'COA Adjustment'
			,[strPrefix]			= N'GLADJ-'
			,[intNumber]			= 1
			,[intTransactionTypeID] = 6
			,[strModule]			= N'Accounting'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'COA Adjustment')
	UNION ALL
	SELECT	[cntID] = 7
			,[strTransactionType]	= N'Bill Batch'
			,[strPrefix]			= N'BB-'
			,[intNumber]			= 1
			,[intTransactionTypeID] = 7
			,[strModule]			= N'Accounts Payable'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Bill Batch')
	UNION ALL
	SELECT	[cntID]					= 8
			,[strTransactionType]	= N'Payable'
			,[strPrefix]			= N'PAY-'
			,[intNumber]			= 1
			,[intTransactionTypeID] = 8
			,[strModule]			= N'Accounts Payable'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Payable')
	UNION ALL
	SELECT	[cntID]					= 9
			,[strTransactionType]	= N'Bill'
			,[strPrefix]			= N'BL-'
			,[intNumber]			= 1
			,[intTransactionTypeID] = 9
			,[strModule]			= N'Accounts Payable'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Bill')
	UNION ALL
	SELECT	[cntID]					= 10
			,[strTransactionType]	= N'Bank Deposit'
			,[strPrefix]			= N'BDEP-'
			,[intNumber]			= 1
			,[intTransactionTypeID] = 10
			,[strModule]			= 'Cash Management'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Bank Deposit')
	UNION ALL
	SELECT	[cntID]					= 11
			,[strTransactionType]	= N'Bank Withdrawal'
			,[strPrefix]			= N'BWD-'
			,[intNumber]			= 1
			,[intTransactionTypeID] = 11
			,[strModule]			= 'Cash Management'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Bank Withdrawal')
	UNION ALL
	SELECT	[cntID]					= 12
			,[strTransactionType]	= N'Bank Transfer'
			,[strPrefix]			= N'BTFR-'
			,[intNumber]			= 1
			,[intTransactionTypeID] = 12
			,[strModule]			= 'Cash Management'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Bank Transfer')
	UNION ALL
	SELECT	[cntID]					= 13
			,[strTransactionType]	= N'Bank Transaction'
			,[strPrefix]			= N'BTRN-'
			,[intNumber]			= 1
			,[intTransactionTypeID] = 13
			,[strModule]			= 'Cash Management'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Bank Transaction')
	UNION ALL
	SELECT	[cntID]					= 14
			,[strTransactionType]	= N'Misc Checks'
			,[strPrefix]			= N'MCHK-'
			,[intNumber]			= 1
			,[intTransactionTypeID] = 14
			,[strModule]			= 'Cash Management'
			,[ysnEnable]			= 1
			,[intConcurrencyId]		= 1
	WHERE NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Misc Checks')

	SET IDENTITY_INSERT [dbo].[tblSMStartingNumber] OFF
GO
	PRINT N'END INSERT DEFAULT STARTING NUMBERS'
GO