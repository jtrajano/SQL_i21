CREATE TABLE tblQMSampleAcknowledgementStage
(
	intSampleAcknowledgementStageId			INT IDENTITY(1,1) PRIMARY KEY, 
	intSampleId								INT,
	strSampleAckNumber						NVARCHAR(100)  COLLATE Latin1_General_CI_AS,
	strAckHeaderXML							NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	strAckDetailXML							NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	strAckTestResultXML						NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	strReference							NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	strRowState								NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strFeedStatus							NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	dtmFeedDate								DATETIME,
	strMessage								NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	intMultiCompanyId						INT,
	strTransactionType						NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strBookStatus							NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	intTransactionId						INT,
    intCompanyId							INT,
    intTransactionRefId						INT,
    intCompanyRefId							INT
)