PRINT N'***** BEGIN INSERT STATIC TRANSFER TYPES (PATRONAGE) *****'
GO
IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS where [TABLE_NAME] = 'tblPATTransferType')
BEGIN
	EXEC('
		IF NOT EXISTS(SELECT TOP 1 1 FROM [dbo].[tblPATTransferType] WHERE strTransferType=N''Transfer Stock between Customers'')
			INSERT INTO [dbo].[tblPATTransferType] VALUES(1,''Transfer Stock between Customers'')
		ELSE
			UPDATE [dbo].[tblPATTransferType] SET intTransferType = 1 WHERE strTransferType = N''Transfer Stock between Customers''

		IF NOT EXISTS(SELECT TOP 1 1 FROM [dbo].[tblPATTransferType] WHERE strTransferType=N''Transfer Stock to Equity'')
			INSERT INTO [dbo].[tblPATTransferType] VALUES(2,''Transfer Stock to Equity'')
		ELSE
			UPDATE [dbo].[tblPATTransferType] SET intTransferType = 2 WHERE strTransferType = N''Transfer Stock to Equity''

		IF NOT EXISTS(SELECT TOP 1 1 FROM [dbo].[tblPATTransferType] WHERE strTransferType=N''Transfer Equity between Customer'')
			INSERT INTO [dbo].[tblPATTransferType] VALUES(3,''Transfer Equity between Customer'')
		ELSE
			UPDATE [dbo].[tblPATTransferType] SET intTransferType = 3 WHERE strTransferType = N''Transfer Equity between Customer''

		IF NOT EXISTS(SELECT TOP 1 1 FROM [dbo].[tblPATTransferType] WHERE strTransferType=N''Transfer Equity to Stock'')
			INSERT INTO [dbo].[tblPATTransferType] VALUES(4,''Transfer Equity to Stock'')
		ELSE
			UPDATE [dbo].[tblPATTransferType] SET intTransferType = 4 WHERE strTransferType = N''Transfer Equity to Stock''

		IF NOT EXISTS(SELECT TOP 1 1 FROM [dbo].[tblPATTransferType] WHERE strTransferType=N''Transfer Equity to Equity Reserve'')
			INSERT INTO [dbo].[tblPATTransferType] VALUES(5,''Transfer Equity to Equity Reserve'')
		ELSE
			UPDATE [dbo].[tblPATTransferType] SET intTransferType = 5 WHERE strTransferType = N''Transfer Equity to Equity Reserve''

		IF NOT EXISTS(SELECT TOP 1 1 FROM [dbo].[tblPATTransferType] WHERE strTransferType=N''Transfer Equity Reserve to Equity'')
			INSERT INTO [dbo].[tblPATTransferType] VALUES(6,''Transfer Equity Reserve to Equity'')
		ELSE
			UPDATE [dbo].[tblPATTransferType] SET intTransferType = 6 WHERE strTransferType = N''Transfer Equity Reserve to Equity''

		IF NOT EXISTS(SELECT TOP 1 1 FROM [dbo].[tblPATTransferType] WHERE strTransferType=N''Transfer Volume between Customers'')
			INSERT INTO [dbo].[tblPATTransferType] VALUES(7,''Transfer Volume between Customers'')
		ELSE
			UPDATE [dbo].[tblPATTransferType] SET intTransferType = 7 WHERE strTransferType = N''Transfer Volume between Customers''
	')
END
GO
PRINT N'***** END INSERT STATIC TRANSFER TYPES (PATRONAGE) *****'