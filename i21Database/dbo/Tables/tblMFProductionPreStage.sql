CREATE TABLE tblMFProductionPreStage (
	intProductionPreStageId INT IDENTITY(1, 1) PRIMARY KEY
	,intWorkOrderId INT
	,intProductionStatusId INT
	,intUserId INT
	,intStatusId INT
	,dtmFeedDate DATETIME CONSTRAINT DF_tblMFProductionPreStage_dtmFeedDate DEFAULT GETDATE()
	,strMessage NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	,ysnMailSent BIT
	)
