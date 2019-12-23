CREATE TABLE tblLGWeightClaimStage (
	intWeightClaimStageId INT IDENTITY(1, 1) CONSTRAINT [PK_tblLGWeightClaimStage_intWeightClaimStageId] PRIMARY KEY
	,intWeightClaimId INT
	,strWeightClaimXML NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	,strWeightClaimDetailXML NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	,strFeedStatus NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,dtmFeedDate DATETIME CONSTRAINT DF_tblLGWeightClaimStage_dtmFeedDate DEFAULT GETDATE()
	,strRowState NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,intTransactionId int
	,intCompanyId int
	,strMessage NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	)
