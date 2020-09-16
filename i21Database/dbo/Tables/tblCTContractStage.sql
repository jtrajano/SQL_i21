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
	strApproverXML			NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	strSubmittedByXML			NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	strReference			NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	strRowState				NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strFeedStatus			NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	dtmFeedDate				DATETIME CONSTRAINT DF_tblCTContractStage_dtmFeedDate DEFAULT GETDATE(),
	strMessage				NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	intMultiCompanyId		INT,
	intEntityId				INT,
	intCompanyLocationId	INT,
	strTransactionType		NVARCHAR(100) COLLATE Latin1_General_CI_AS, 
    intToBookId INT NULL,
	strAmendmentApprovalXML NVARCHAR(MAX)COLLATE Latin1_General_CI_AS
	,intTransactionId int
	,intCompanyId int, 
    ysnMailSent BIT NULL,
	intStatusId int
)