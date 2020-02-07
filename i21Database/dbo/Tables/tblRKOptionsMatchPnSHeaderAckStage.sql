CREATE TABLE tblRKOptionsMatchPnSHeaderAckStage
(
	intOptionsMatchPnSHeaderAckStageId		INT IDENTITY(1,1) PRIMARY KEY, 
	intOptionsMatchPnSHeaderId				INT,
	strAckHeaderXML							NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	strAckOptionsMatchPnSXML				NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	strAckOptionsPnSExpiredXML				NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	strRowState								NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strFeedStatus							NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	dtmFeedDate								DATETIME CONSTRAINT DF_tblRKOptionsMatchPnSHeaderAckStage_dtmFeedDate DEFAULT GETDATE(),
	strMessage								NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	intMultiCompanyId						INT,
	strTransactionType						NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	intTransactionId						INT,
    intCompanyId							INT,
    intTransactionRefId						INT,
    intCompanyRefId							INT
)