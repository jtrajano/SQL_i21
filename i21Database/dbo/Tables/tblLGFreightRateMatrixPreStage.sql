CREATE TABLE tblLGFreightRateMatrixPreStage
(
	intFreightRateMatrixPreStageId	INT IDENTITY(1,1) CONSTRAINT PK_tblLGFreightRateMatrixPreStage_intFreightRateMatrixPreStageId PRIMARY KEY, 
	intFreightRateMatrixId			INT NOT NULL,
	strRowState					NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strFeedStatus				NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	dtmFeedDate					DATETIME CONSTRAINT DF_tblLGFreightRateMatrixPreStage_dtmFeedDate DEFAULT GETDATE(),
	strMessage					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	intUserId int
)
