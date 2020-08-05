CREATE TABLE tblRKCoverageEntryStage
(
	intCoverageEntryStageId	INT IDENTITY(1,1) PRIMARY KEY, 
	intCoverageEntryId		INT,
	strBatchName			NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	dtmDate					DATETIME,
	strHeaderXML			NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	strDetailXML			NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	strRowState				NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strUserName				NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strFeedStatus			NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	dtmFeedDate				DATETIME CONSTRAINT DF_tblRKCoverageEntryStage_dtmFeedDate DEFAULT GETDATE(),
	strMessage				NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	intMultiCompanyId		INT,
	intEntityId				INT,
	intCompanyLocationId	INT,
	strTransactionType		NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	intToBookId				INT,
	strFromCompanyName		NVARCHAR(150) COLLATE Latin1_General_CI_AS,
	ysnMailSent				BIT CONSTRAINT DF_tblRKCoverageEntryStage_ysnMailSent DEFAULT 0,
	intTransactionId		INT,
	intCompanyId			INT,
	intStatusId				INT
)