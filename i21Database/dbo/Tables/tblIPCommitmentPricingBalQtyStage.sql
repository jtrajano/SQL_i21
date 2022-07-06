CREATE TABLE tblIPCommitmentPricingBalQtyStage (
	intCommitmentPricingBalQtyStageId INT identity(1, 1)
	,intTrxSequenceNo BIGINT
	,strCompanyLocation NVARCHAR(6) COLLATE Latin1_General_CI_AS
	,dtmCreatedDate DATETIME
	,strCreatedBy NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,intLineTrxSequenceNo BIGINT
	,strPricingNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strERPRefNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
	,dblBalanceQty NUMERIC(18, 6)

	,strErrorMessage NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	,dtmTransactionDate DATETIME DEFAULT(GETDATE())
	,ysnMailSent BIT DEFAULT 0
	,intStatusId INT

	,CONSTRAINT PK_tblIPCommitmentPricingBalQtyStage PRIMARY KEY (intCommitmentPricingBalQtyStageId)
	)
