CREATE TABLE dbo.tblLGWeightClaimPreStage
(
	intWeightClaimPreStageId	INT IDENTITY(1,1) CONSTRAINT PK_tblLGWeightClaimPreStage_intItemPreStageId PRIMARY KEY, 
	intWeightClaimId			INT NOT NULL,
	strFeedStatus				NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	dtmFeedDate					DATETIME CONSTRAINT DF_tblLGWeightClaimPreStage_dtmFeedDate DEFAULT GETDATE(),
	strMessage					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
)
