CREATE TABLE tblRKDailyAveragePriceAckStage
(
	intDailyAveragePriceAckStageId		INT IDENTITY(1,1) PRIMARY KEY, 
	intDailyAveragePriceId				INT,
	strAckAverageNo						NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strAckHeaderXML						NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	strAckDetailXML						NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	strRowState							NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strFeedStatus						NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	dtmFeedDate							DATETIME CONSTRAINT DF_tblRKDailyAveragePriceAckStage_dtmFeedDate DEFAULT GETDATE(),
	strMessage							NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	intMultiCompanyId					INT,
	strTransactionType					NVARCHAR(100) COLLATE Latin1_General_CI_AS
)