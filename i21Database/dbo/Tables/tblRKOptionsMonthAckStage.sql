CREATE TABLE tblRKOptionsMonthAckStage
(
	intOptionMonthAckStageId		INT IDENTITY(1,1) PRIMARY KEY, 
	intOptionMonthId				INT,
	strAckHeaderXML					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	strRowState						NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strFeedStatus					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	dtmFeedDate						DATETIME CONSTRAINT DF_tblRKOptionsMonthAckStage_dtmFeedDate DEFAULT GETDATE(),
	strMessage						NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	intMultiCompanyId				INT,
	strTransactionType				NVARCHAR(100) COLLATE Latin1_General_CI_AS
)