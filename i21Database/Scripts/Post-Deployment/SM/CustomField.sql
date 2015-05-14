print('/*******************  BEGIN Creating Custom Field Tables *******************/')
GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE object_id = object_id('cstEntity'))
BEGIN
	print('/*******************  BEGIN Creating Entity Custom Table *******************/')
	EXEC('
		CREATE TABLE [dbo].[cstEntity]
		(
			[intId] INT NOT NULL,
			CONSTRAINT [PK_cstEntity] PRIMARY KEY CLUSTERED ([intId] ASC),
			CONSTRAINT [FK_cstEntity_tblEntity] FOREIGN KEY ([intId]) REFERENCES [dbo].[tblEntity] ([intEntityId]) ON DELETE CASCADE
		);
	')
	print('/*******************  END Creating Entity Custom Table *******************/')
END

IF NOT EXISTS (SELECT * FROM sys.tables WHERE object_id = object_id('cstGLJournal'))
BEGIN
	print('/*******************  BEGIN Creating Journal Custom Table *******************/')
	EXEC('
		CREATE TABLE [dbo].[cstGLJournal] (
			[intId] INT NOT NULL,
			CONSTRAINT [PK_cstGLJournal] PRIMARY KEY CLUSTERED ([intId] ASC),
			CONSTRAINT [FK_cstGLJournal_cstGLJournal] FOREIGN KEY ([intId]) REFERENCES [dbo].[tblGLJournal] ([intJournalId]) ON DELETE CASCADE
		);
	')
	print('/*******************  END Creating Journal Custom Table *******************/')
END

IF NOT EXISTS (SELECT * FROM sys.tables WHERE object_id = object_id('cstGLAccount'))
BEGIN
	print('/*******************  BEGIN Creating Account Custom Table *******************/')
	EXEC('
		CREATE TABLE [dbo].[cstGLAccount] (
			[intId] INT NOT NULL,
			CONSTRAINT [PK_cstGLAccount] PRIMARY KEY CLUSTERED ([intId] ASC),
			CONSTRAINT [FK_cstGLAccount.tblGLAccount_intAccountId] FOREIGN KEY ([intId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]) ON DELETE CASCADE
		);
	')
	print('/*******************  END Creating Account Custom Table *******************/')
END

GO
print('/*******************  END Creating Custom Field Tables *******************/')