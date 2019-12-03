CREATE TABLE dbo.tblMFInvPlngSummaryDetail (
	intInvPlngSummaryDetailId INT NOT NULL IDENTITY
	,intInvPlngSummaryId INT
	,intAttributeId INT NOT NULL
	,intItemId INT NOT NULL
	,strFieldName NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strValue NVARCHAR(100) COLLATE Latin1_General_CI_AS
	,intMainItemId INT NULL
	,CONSTRAINT PK_tblMFInvPlngSummaryDetail PRIMARY KEY (intInvPlngSummaryDetailId)
	,CONSTRAINT FK_tblMFInvPlngSummaryDetail_tblCTReportAttribute FOREIGN KEY (intAttributeId) REFERENCES tblCTReportAttribute(intReportAttributeID)
	,CONSTRAINT FK_tblMFInvPlngSummaryDetail_tblMFInvPlngSummary FOREIGN KEY (intInvPlngSummaryId) REFERENCES tblMFInvPlngSummary(intInvPlngSummaryId) ON DELETE CASCADE
	)
