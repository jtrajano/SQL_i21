CREATE TABLE dbo.tblMFInvPlngSummary (
	intInvPlngSummaryId INT NOT NULL IDENTITY
	,strPlanName NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
	,dtmDate DATETIME
	,intUnitMeasureId INT
	,intBookId INT
	,intSubBookId INT
	,strComment NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	,intCreatedUserId INT NULL
	,dtmCreated DATETIME NULL CONSTRAINT DF_tblMFInvPlngSummary_dtmCreated DEFAULT GetDate()
	,intLastModifiedUserId INT NULL
	,dtmLastModified DATETIME NULL CONSTRAINT DF_tblMFInvPlngSummary_dtmLastModified DEFAULT GetDate()
	,intConcurrencyId INT NULL CONSTRAINT DF_tblMFInvPlngSummary_intConcurrencyId DEFAULT 0
	,CONSTRAINT PK_tblMFInvPlngSummary PRIMARY KEY (intInvPlngSummaryId)
	,CONSTRAINT FK_tblMFInvPlngSummary_tblICUnitMeasure FOREIGN KEY (intUnitMeasureId) REFERENCES tblICUnitMeasure(intUnitMeasureId)
	,CONSTRAINT FK_tblMFInvPlngSummary_tblCTBook FOREIGN KEY (intBookId) REFERENCES tblCTBook(intBookId)
	,CONSTRAINT FK_tblMFInvPlngSummary_tblCTSubBook FOREIGN KEY (intSubBookId) REFERENCES tblCTSubBook(intSubBookId)
	)