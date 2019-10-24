CREATE TABLE [dbo].[tblTRDtnImportSetupDetail]
(
	[intDtnImportSetupDetailId] INT NOT NULL IDENTITY,
	[intDtnImportSetupId] INT NOT NULL,
	[strType] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
	[intImportFileHeaderId] INT NOT NULL,
	[intConcurrencyId] INT NOT NULL DEFAULT ((1)),
	CONSTRAINT [PK_tblTRDtnImportSetupDetail] PRIMARY KEY ([intDtnImportSetupDetailId]),
	CONSTRAINT [FK_tblTRDtnImportSetupDetail_tblTRDtnImportSetup_intDtnImportSetupId] FOREIGN KEY ([intDtnImportSetupId]) REFERENCES [dbo].[tblTRDtnImportSetup] ([intDtnImportSetupId]) ON DELETE CASCADE,
	CONSTRAINT [UK_tblTRDtnImportSetupDetail_strType_intImportFileHeaderId] UNIQUE NONCLUSTERED ([strType] ASC, [intImportFileHeaderId] ASC),
	CONSTRAINT [FK_tblTRDtnImportSetupDetail_tblSMImportFileHeader] FOREIGN KEY ([intImportFileHeaderId]) REFERENCES [tblSMImportFileHeader]([intImportFileHeaderId])
)
