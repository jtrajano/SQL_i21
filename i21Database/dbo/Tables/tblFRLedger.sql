CREATE TABLE [dbo].[tblFRLedger](
	[intFRLedgerId]				INT				IDENTITY (1, 1) NOT NULL,
	[intReportId]				INT				NULL,
	[intLedgerId]				INT				NULL,
	[strLedgerName]				NVARCHAR (255)	COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId]			INT,
	CONSTRAINT [PK_tblFRLedger] PRIMARY KEY (intFRLedgerId,intLedgerId),
	CONSTRAINT [FK_tblFRLedger] FOREIGN KEY (intReportId) REFERENCES tblFRReport(intReportId)
);