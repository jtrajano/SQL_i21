CREATE TABLE tblRKFutureMarketStage
(
	intFutureMarketStageId		INT IDENTITY(1,1) PRIMARY KEY, 
	intFutureMarketId			INT,
	strFutMarketName			NVARCHAR(30) COLLATE Latin1_General_CI_AS,
	dblForecastPrice			NUMERIC(18, 6) CONSTRAINT DF_tblRKFutureMarketStage_dblForecastPrice DEFAULT 0,
	strHeaderXML				NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	strRowState					NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strUserName					NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strFeedStatus				NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	dtmFeedDate					DATETIME CONSTRAINT DF_tblRKFutureMarketStage_dtmFeedDate DEFAULT GETDATE(),
	strMessage					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	intMultiCompanyId			INT,
	intEntityId					INT,
	intCompanyLocationId		INT,
	strTransactionType			NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	intToBookId					INT,
	ysnMailSent					BIT CONSTRAINT DF_tblRKFutureMarketStage_ysnMailSent DEFAULT 0,
	intStatusId					INT
)