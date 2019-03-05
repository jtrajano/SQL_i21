CREATE TABLE [dbo].[tblMBImportMeterReading]
(
	[intImportMeterReadingId] INT NOT NULL IDENTITY,
	[guidImportIdentifier] UNIQUEIDENTIFIER NOT NULL,
	[intImportFileHeaderId] INT NOT NULL,
	[intUserId] INT NOT NULL,
	[dtmImportDate] DATETIME NOT NULL,
	CONSTRAINT [PK_tblMBImportMeterReading] PRIMARY KEY ([intImportMeterReadingId])
	--CONSTRAINT [FK_tblMBImportMeterReading_tblSMImportFileHeader] FOREIGN KEY ([intImportFileHeaderId]) REFERENCES [tblSMImportFileHeader]([intImportFileHeaderId])
)
GO

CREATE INDEX [IX_tblMBImportMeterReading_guidImportIdentifier] ON [dbo].[tblMBImportMeterReading] ([guidImportIdentifier])
GO

