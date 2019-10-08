CREATE TABLE tblRKM2MBasisPreStage
(
	intM2MBasisPreStageId	INT IDENTITY(1,1) PRIMARY KEY, 
	intM2MBasisId			INT,
	strRowState				NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strFeedStatus			NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	dtmFeedDate				DATETIME CONSTRAINT DF_tblRKM2MBasisPreStage_dtmFeedDate DEFAULT GETDATE(),
	strMessage				NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
)