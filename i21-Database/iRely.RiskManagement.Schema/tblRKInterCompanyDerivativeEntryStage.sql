CREATE TABLE tblRKInterCompanyDerivativeEntryStage
(
	intDerivativeEntryStageId		INT IDENTITY(1,1) PRIMARY KEY, 
	intFutOptTransactionHeaderId		INT,
	strInternalTradeNo		NVARCHAR(20) COLLATE Latin1_General_CI_AS,
	intContractHeaderId				INT,
	strHeaderXML			NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	strDetailXML			NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	strRowState				NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strFeedStatus			NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	dtmFeedDate				DATETIME,
	strMessage				NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	intMultiCompanyId		INT,
	intEntityId				INT,
	intCompanyLocationId	INT NULL,
	strTransactionType		NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	intHedgedLots			INT
)