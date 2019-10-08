CREATE TABLE tblRKFuturesSettlementPricePreStage
(
	intFutureSettlementPricePreStageId	INT IDENTITY(1,1) PRIMARY KEY, 
	intFutureSettlementPriceId			INT,
	strRowState							NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strFeedStatus						NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	dtmFeedDate							DATETIME CONSTRAINT DF_tblRKFuturesSettlementPricePreStage_dtmFeedDate DEFAULT GETDATE(),
	strMessage							NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
)