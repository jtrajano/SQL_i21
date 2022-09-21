CREATE TABLE [dbo].[tblFRSubLedger](
	[intFRSubLedgerId]			INT				IDENTITY (1, 1) NOT NULL,
	[intReportId]				INT				NOT NULL,
	[intLedgerDetailId]			INT				NOT NULL Default 0,
	[intConcurrencyId]			INT,
	CONSTRAINT [PK_tblFRSubLedger] PRIMARY KEY (intReportId,intLedgerDetailId),
	CONSTRAINT [FK_tblFRSubLedger] FOREIGN KEY (intReportId) REFERENCES tblFRReport(intReportId)
);
