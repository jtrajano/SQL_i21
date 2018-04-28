CREATE TABLE tblCTContractAcknowledgementStage
(
	intContractAcknowledgementStageId		INT IDENTITY(1,1) PRIMARY KEY, 
	intContractHeaderId						INT,
	strContractAckNumber					NVARCHAR(100)  COLLATE Latin1_General_CI_AS,
	strAckHeaderXML							NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	strAckDetailXML							NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	strAckCostXML							NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	strAckDocumentXML						NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	strReference							NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	strRowState								NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strFeedStatus							NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	dtmFeedDate								DATETIME,
	strMessage								NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	intMultiCompanyId						INT,
	strTransactionType						NVARCHAR(100) COLLATE Latin1_General_CI_AS
)