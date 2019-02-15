CREATE TABLE [dbo].[tblMBImportMeterReading]
(
	[intImportMeterReadingId] INT NOT NULL IDENTITY,
	[guidImportIdentifier] UNIQUEIDENTIFIER NOT NULL,
	[intMeterCustomerId] INT NOT NULL,
    [intMeterNumber] INT NOT NULL,
	[dtmTransactionDate] DATETIME NOT NULL,
    [dblCurrentReading] NUMERIC(18, 6) NULL, 
    [dblCurrentAmount] NUMERIC(18, 6) NULL,
	[intUserId] INT NOT NULL,
	[dtmDate] DATETIME NOT NULL,
	CONSTRAINT [PK_tblMBImportMeterReading] PRIMARY KEY ([intImportMeterReadingId])
)
GO

CREATE INDEX [IX_tblMBImportMeterReading_guidImportIdentifier] ON [dbo].[tblMBImportMeterReading] ([guidImportIdentifier])
GO

