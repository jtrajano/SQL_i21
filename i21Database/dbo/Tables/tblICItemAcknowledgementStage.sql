CREATE TABLE tblICItemAcknowledgementStage (
	intItemAcknowledgementStageId INT IDENTITY(1, 1) PRIMARY KEY
	,intItemId INT
	,strItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,intItemRefId INT
	,strFeedStatus NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,intTransactionId INT
	,intCompanyId INT
	,intTransactionRefId INT
	,intCompanyRefId INT
	,strMessage NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	)
