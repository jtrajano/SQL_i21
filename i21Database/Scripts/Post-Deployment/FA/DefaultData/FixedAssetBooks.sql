GO

PRINT 'Start generating default fixed asset books'
GO

IF NOT EXISTS(SELECT TOP 1 1 FROM [dbo].[tblFABook] WHERE intBookId = 1)
BEGIN
	SET IDENTITY_INSERT [dbo].[tblFABook] ON
	
	INSERT INTO [dbo].[tblFABook] (intBookId, strBook, intConcurrencyId)
	VALUES (1, 'GAAP', 1)
	
	SET IDENTITY_INSERT [dbo].[tblFABook] OFF
END
GO

IF NOT EXISTS(SELECT TOP 1 1 FROM [dbo].[tblFABook] WHERE intBookId = 2)
BEGIN
	SET IDENTITY_INSERT [dbo].[tblFABook] ON
	
	INSERT INTO [dbo].[tblFABook] (intBookId, strBook, intConcurrencyId)
	VALUES (2, 'Tax', 1)
	
	SET IDENTITY_INSERT [dbo].[tblFABook] OFF
END
GO

PRINT 'Finished generating default fixed asset books'
GO
