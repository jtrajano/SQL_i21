CREATE TABLE tblRKFutOptTransactionHeaderAckStage
(
	intFutOptTransactionHeaderAckStageId	INT IDENTITY(1,1) PRIMARY KEY, 
	intFutOptTransactionHeaderId			INT,
	dtmTransactionDate						DATETIME,
	strAckHeaderXML							NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	strAckFutOptTransactionXML				NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	strRowState								NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strFeedStatus							NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	dtmFeedDate								DATETIME CONSTRAINT DF_tblRKFutOptTransactionHeaderAckStage_dtmFeedDate DEFAULT GETDATE(),
	strMessage								NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	intMultiCompanyId						INT,
	strTransactionType						NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	intTransactionId						INT,
    intCompanyId							INT,
    intTransactionRefId						INT,
    intCompanyRefId							INT
)