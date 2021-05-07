CREATE TABLE tblMFCommitmentPricingDetailStage
(
	intCommitmentPricingDetailStageId	INT IDENTITY(1,1) PRIMARY KEY,
	intCommitmentPricingStageId			INT,
	intCommitmentPricingId				INT,
	intActionId							INT,
	intLineType							INT,
	strContractNo						NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strCommodityOrderNo					NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	intSequenceNo						INT,
	strActualBlend						NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strERPRecipeNo						NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	dblTotalCostPR						NUMERIC(18, 6),
	strRowState							NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strFeedStatus						NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,

	CONSTRAINT [FK_tblMFCommitmentPricingDetailStage_tblMFCommitmentPricingStage] FOREIGN KEY (intCommitmentPricingStageId) REFERENCES [tblMFCommitmentPricingStage](intCommitmentPricingStageId) ON DELETE CASCADE
)