CREATE TABLE [dbo].[tblTRImportLoad]
(
    [intImportLoadId] INT NOT NULL IDENTITY,
    [guidImportIdentifier] UNIQUEIDENTIFIER NOT NULL,
    [intImportFileHeaderId] INT NOT NULL,
	[intUserId] INT NOT NULL,
	[dtmImportDate] DATETIME NOT NULL,
	[intConcurrencyId] INT NOT NULL DEFAULT ((1)),
    CONSTRAINT [PK_tblTRImportLoad] PRIMARY KEY ([intImportLoadId]),
	CONSTRAINT [FK_tblTRImportLoad_tblSMImportFileHeader] FOREIGN KEY ([intImportFileHeaderId]) REFERENCES [tblSMImportFileHeader]([intImportFileHeaderId])
)
GO

CREATE INDEX [IX_tblTRImportLoad_guidImportIdentifier] ON [dbo].[tblTRImportLoad] ([guidImportIdentifier])
GO