CREATE TABLE [dbo].[tblTRImportLoad]
(
    [intImportLoadId] INT NOT NULL IDENTITY,
    [guidImportIdentifier] UNIQUEIDENTIFIER NOT NULL,
    [intImportFileHeaderId] INT NULL,
	[intUserId] INT NOT NULL,
	[dtmImportDate] DATETIME2 NOT NULL,
	[intConcurrencyId] INT NOT NULL DEFAULT ((1)),
    [strSource] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    [strFileName] NVARCHAR(300) COLLATE Latin1_General_CI_AS NULL,
    [strFileExtension]  NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    [strMessage] NVARCHAR(500) COLLATE Latin1_General_CI_AS NULL,
    [strStatus] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    CONSTRAINT [PK_tblTRImportLoad] PRIMARY KEY ([intImportLoadId]),
	CONSTRAINT [FK_tblTRImportLoad_tblSMImportFileHeader] FOREIGN KEY ([intImportFileHeaderId]) REFERENCES [tblSMImportFileHeader]([intImportFileHeaderId])
)
GO

CREATE INDEX [IX_tblTRImportLoad_guidImportIdentifier] ON [dbo].[tblTRImportLoad] ([guidImportIdentifier])
GO