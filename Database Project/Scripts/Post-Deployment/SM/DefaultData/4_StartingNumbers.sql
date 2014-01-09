GO
	PRINT N'BEGIN INSERT DEFAULT STARTING NUMBERS'
GO
	SET IDENTITY_INSERT [dbo].[tblSMStartingNumber] ON
	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Audit Adjustment')
	BEGIN 
		INSERT [dbo].[tblSMStartingNumber] ([cntID], [strTransactionType], [strPrefix], [intNumber], [intTransactionTypeID], [strModule], [ysnEnable], [intConcurrencyID]) VALUES (1, N'Audit Adjustment', N'AA-', 0, 1, N'Accounting', 1, 1)
	END
	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'General Journal')
	BEGIN 
		INSERT [dbo].[tblSMStartingNumber] ([cntID], [strTransactionType], [strPrefix], [intNumber], [intTransactionTypeID], [strModule], [ysnEnable], [intConcurrencyID]) VALUES (2, N'General Journal', N'GJ-', 0, 2, N'Accounting', 1, 1)
	END
	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Batch Post')
	BEGIN 
		INSERT [dbo].[tblSMStartingNumber] ([cntID], [strTransactionType], [strPrefix], [intNumber], [intTransactionTypeID], [strModule], [ysnEnable], [intConcurrencyID]) VALUES (3, N'Batch Post', N'BATCH-', 0, 3, N'Posting', 1, 1)
	END
	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Recurring Journal')
	BEGIN 
		INSERT [dbo].[tblSMStartingNumber] ([cntID], [strTransactionType], [strPrefix], [intNumber], [intTransactionTypeID], [strModule], [ysnEnable], [intConcurrencyID]) VALUES (4, N'Recurring Journal', N'REC-', 0, 4, N'Accounting', 1, 1)
	END
	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'General Journal Reversal')
	BEGIN 
		INSERT [dbo].[tblSMStartingNumber] ([cntID], [strTransactionType], [strPrefix], [intNumber], [intTransactionTypeID], [strModule], [ysnEnable], [intConcurrencyID]) VALUES (5, N'General Journal Reversal', N'REV-', 0, 5, N'Accounting', 1, 1)
	END
	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'COA Adjustment')
	BEGIN 
		INSERT [dbo].[tblSMStartingNumber] ([cntID], [strTransactionType], [strPrefix], [intNumber], [intTransactionTypeID], [strModule], [ysnEnable], [intConcurrencyID]) VALUES (6, N'COA Adjustment', N'GLADJ-', 0, 6, N'Accounting', 1, 1)
	END
	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Bill Batch')
	BEGIN 
		INSERT [dbo].[tblSMStartingNumber] ([cntID], [strTransactionType], [strPrefix], [intNumber], [intTransactionTypeID], [strModule], [ysnEnable], [intConcurrencyID]) VALUES (6, N'Bill Batch', N'BB-', 0, 6, N'Accounts Payable', 1, 1)
	END
	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Payable')
	BEGIN 
		INSERT [dbo].[tblSMStartingNumber] ([cntID], [strTransactionType], [strPrefix], [intNumber], [intTransactionTypeID], [strModule], [ysnEnable], [intConcurrencyID]) VALUES (6, N'Payable', N'PAY-', 0, 6, N'Accounts Payable', 1, 1)
	END
	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMStartingNumber WHERE strTransactionType = N'Bill')
	BEGIN 
		INSERT [dbo].[tblSMStartingNumber] ([cntID], [strTransactionType], [strPrefix], [intNumber], [intTransactionTypeID], [strModule], [ysnEnable], [intConcurrencyID]) VALUES (6, N'Bill', N'BL-', 0, 6, N'Accounts Payable', 1, 1)
	END
	SET IDENTITY_INSERT [dbo].[tblSMStartingNumber] OFF
GO
	PRINT N'END INSERT DEFAULT STARTING NUMBERS'
GO