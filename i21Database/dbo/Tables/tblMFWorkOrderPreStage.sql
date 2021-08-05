CREATE TABLE tblMFWorkOrderPreStage (
	intWorkOrderPreStageId INT IDENTITY(1, 1) PRIMARY KEY
	,intWorkOrderId INT
	,intWorkOrderStatusId INT
	,strERPOrderNo nvarchar(50) COLLATE Latin1_General_CI_AS NULL
	,strWorkOrderNo nvarchar(50) COLLATE Latin1_General_CI_AS NULL
	,strUserName nvarchar(50) COLLATE Latin1_General_CI_AS NULL
	,strCompanyLocation nvarchar(50) COLLATE Latin1_General_CI_AS NULL
	,strSubLocationName nvarchar(50) COLLATE Latin1_General_CI_AS NULL
	,strWorkOrderType nvarchar(50) COLLATE Latin1_General_CI_AS NULL
	,intUserId INT
	,intStatusId INT
	,strRowState NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	,dtmFeedDate DATETIME CONSTRAINT DF_tblMFWorkOrderPreStage_dtmFeedDate DEFAULT GETDATE()
	,strMessage NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	,ysnMailSent BIT
	,intServiceOrderStatusId INT
	)
