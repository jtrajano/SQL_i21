﻿CREATE TABLE tblRKFuturesSettlementPriceStage
(
	intFutureSettlementPriceStageId	INT IDENTITY(1,1) PRIMARY KEY, 
	intFutureSettlementPriceId		INT,
	strHeaderXML					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	strFutSettlementPriceXML		NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	strOptSettlementPriceXML		NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	strRowState						NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strFeedStatus					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	dtmFeedDate						DATETIME CONSTRAINT DF_tblRKFuturesSettlementPriceStage_dtmFeedDate DEFAULT GETDATE(),
	strMessage						NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	intMultiCompanyId				INT,
	intEntityId						INT,
	intCompanyLocationId			INT,
	strTransactionType				NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	intToBookId						INT
)