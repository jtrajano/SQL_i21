CREATE TABLE [dbo].[tblFRLedger](
	[intFRLedgerId]				INT				IDENTITY (1, 1) NOT NULL,
	[intReportId]				INT				NOT NULL,
	[intLedgerId]				INT				NOT NULL Default 0,
	[strLedgerName]				NVARCHAR (255)	COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId]			INT,
	CONSTRAINT [PK_tblFRLedger] PRIMARY KEY (intFRLedgerId,intLedgerId),
	CONSTRAINT [FK_tblFRLedger] FOREIGN KEY (intReportId) REFERENCES tblFRReport(intReportId)
);