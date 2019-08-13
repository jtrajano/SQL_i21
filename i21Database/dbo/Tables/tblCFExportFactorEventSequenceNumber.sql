
CREATE TABLE [dbo].[tblCFExportFactorEventSequenceNumber](
	[intExportFactorEventSequenceNumberId] INT IDENTITY(1,1) NOT NULL,
	[intEventSequenceId] INT NULL,
	[dtmExportDate] DATETIME NULL,
	[intConcurrencyId] INT NULL,
 CONSTRAINT [PK_tblCFExportFactorEventSequenceNumber] PRIMARY KEY CLUSTERED ([intExportFactorEventSequenceNumberId] ASC)
 )