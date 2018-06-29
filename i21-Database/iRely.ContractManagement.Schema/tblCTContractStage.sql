CREATE TABLE tblCTContractStage
(
	intContractStageId		INT IDENTITY(1,1) PRIMARY KEY, 
	intContractHeaderId		INT,
	strContractNumber		NVARCHAR(100)  COLLATE Latin1_General_CI_AS,
	strHeaderXML			NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	strDetailXML			NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	strCostXML				NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	strDocumentXML			NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	strConditionXML			NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	strCertificationXML		NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	strReference			NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	strRowState				NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strFeedStatus			NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	dtmFeedDate				DATETIME,
	strMessage				NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	intMultiCompanyId		INT,
	intEntityId				INT,
	intCompanyLocationId	INT,
	strTransactionType		NVARCHAR(100) COLLATE Latin1_General_CI_AS
)