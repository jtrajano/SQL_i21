CREATE TABLE tblMFCommitmentPricingStage
(
	intCommitmentPricingStageId		INT IDENTITY(1,1) PRIMARY KEY, 
	intCommitmentPricingId			INT,
	ysnPost							BIT,
	intUserId						INT,

	strRowState				NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strFeedStatus			NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	dtmFeedDate				DATETIME CONSTRAINT DF_tblMFCommitmentPricingStage_dtmFeedDate DEFAULT GETDATE(),
	strMessage				NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	ysnMailSent				BIT CONSTRAINT DF_tblMFCommitmentPricingStage_ysnMailSent DEFAULT 0,
	intStatusId				INT
)