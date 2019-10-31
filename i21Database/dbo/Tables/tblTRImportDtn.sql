CREATE TABLE [dbo].[tblTRImportDtn]
(
	[intImportDtnId] INT NOT NULL IDENTITY,
    [guidImportIdentifier] UNIQUEIDENTIFIER NOT NULL,
    [intDtnImportSetupId] INT NOT NULL,
	[intUserId] INT NOT NULL,
	[dtmImportDate] DATETIME NOT NULL,
	[intConcurrencyId] INT NOT NULL DEFAULT ((1)),
    CONSTRAINT [PK_tblTRImportDtn] PRIMARY KEY ([intImportDtnId]),
	CONSTRAINT [FK_tblTRImportDtn_tblTRDtnImportSetup_intDtnImportSetupId] FOREIGN KEY ([intDtnImportSetupId]) REFERENCES [tblTRDtnImportSetup]([intDtnImportSetupId])
)
GO

CREATE INDEX [IX_tblTRImportDtn_guidImportIdentifier] ON [dbo].[tblTRImportDtn] ([guidImportIdentifier])
GO
