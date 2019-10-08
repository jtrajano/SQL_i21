CREATE TABLE tblRKFuturesMonthAckStage
(
	intFutureMonthAckStageId		INT IDENTITY(1,1) PRIMARY KEY, 
	intFutureMonthId				INT,
	strAckHeaderXML					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	strRowState						NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strFeedStatus					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	dtmFeedDate						DATETIME CONSTRAINT DF_tblRKFuturesMonthAckStage_dtmFeedDate DEFAULT GETDATE(),
	strMessage						NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	intMultiCompanyId				INT,
	strTransactionType				NVARCHAR(100) COLLATE Latin1_General_CI_AS
)