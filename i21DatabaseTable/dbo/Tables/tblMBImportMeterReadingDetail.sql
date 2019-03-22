CREATE TABLE [dbo].[tblMBImportMeterReadingDetail]
(
	[intImportMeterReadingDetailId] INT NOT NULL IDENTITY,
	[intImportMeterReadingId] INT NOT NULL,
	[intMeterCustomerId] INT NOT NULL,
    [intMeterNumber] INT NOT NULL,
	[dtmTransactionDate] DATETIME NOT NULL,
    [dblCurrentReading] NUMERIC(18, 6) NULL, 
    [dblCurrentAmount] NUMERIC(18, 6) NULL,
	[ysnValid] BIT NOT NULL,
	[strMessage] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	CONSTRAINT [PK_tblMBImportMeterReadingDetail] PRIMARY KEY ([intImportMeterReadingDetailId]),
	CONSTRAINT [FK_tblMBImportMeterReadingDetail_tblMBImportMeterReading] FOREIGN KEY([intImportMeterReadingId]) REFERENCES [tblMBImportMeterReading] ([intImportMeterReadingId]) ON DELETE CASCADE
)
GO

CREATE INDEX [IX_tblMBImportMeterReadingDetail_intImportMeterReadingId] ON [dbo].[tblMBImportMeterReadingDetail] ([intImportMeterReadingId])
GO