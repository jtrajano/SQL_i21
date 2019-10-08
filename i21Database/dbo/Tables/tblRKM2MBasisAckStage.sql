CREATE TABLE tblRKM2MBasisAckStage
(
	intM2MBasisAckStageId		INT IDENTITY(1,1) PRIMARY KEY, 
	intM2MBasisId				INT,
	strAckHeaderXML				NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	strAckBasisDetailXML		NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	strAckBasisTransactionXML	NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	strAckGrainBasisXML			NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	strRowState					NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strFeedStatus				NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	dtmFeedDate					DATETIME CONSTRAINT DF_tblRKM2MBasisAckStage_dtmFeedDate DEFAULT GETDATE(),
	strMessage					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	intMultiCompanyId			INT,
	strTransactionType			NVARCHAR(100) COLLATE Latin1_General_CI_AS
)