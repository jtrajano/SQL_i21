CREATE TABLE dbo.tblMFInvPlngSummaryBatch (
	intInvPlngSummaryBatchId INT NOT NULL IDENTITY
	,intInvPlngSummaryId INT
	,strBatch NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
	,intInvPlngReportMasterID int
	,CONSTRAINT PK_tblMFInvPlngSummaryBatch PRIMARY KEY (intInvPlngSummaryBatchId)
	,CONSTRAINT FK_tblMFInvPlngSummaryBatch_tblMFInvPlngSummary FOREIGN KEY (intInvPlngSummaryId) REFERENCES tblMFInvPlngSummary(intInvPlngSummaryId) ON DELETE CASCADE
	,CONSTRAINT FK_tblMFInvPlngSummaryBatch_tblCTInvPlngReportMaster FOREIGN KEY (intInvPlngReportMasterID) REFERENCES tblCTInvPlngReportMaster(intInvPlngReportMasterID) 
	)