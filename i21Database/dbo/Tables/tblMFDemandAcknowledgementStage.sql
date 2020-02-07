CREATE TABLE tblMFDemandAcknowledgementStage (
	intDemandAcknowledgementStageId INT IDENTITY(1, 1) PRIMARY KEY
	,intInvPlngReportMasterId INT
	,strInvPlngReportName NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,intInvPlngReportMasterRefId INT
	,strFeedStatus NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,intTransactionId INT
	,intCompanyId INT
	,intTransactionRefId INT
	,intCompanyRefId INT
	,strMessage NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	,dtmFeedDate DATETIME DEFAULT GETDATE()
	)
