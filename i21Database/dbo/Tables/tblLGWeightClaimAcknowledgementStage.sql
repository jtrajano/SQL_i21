CREATE TABLE [dbo].[tblLGWeightClaimAcknowledgementStage]
(
	intWeightClaimAcknowledgementStageId int not null Constraint PK_tblMFWeightClaimAcknowledgementStage Primary key
	,intWeightClaimId int
	,intWeightClaimRefId int
	,strMessage nvarchar(MAX)COLLATE Latin1_General_CI_AS
	,intTransactionId int
	,intCompanyId int
	,intTransactionRefId int
	,intCompanyRefId int
)
