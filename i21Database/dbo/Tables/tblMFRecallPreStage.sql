CREATE TABLE tblMFRecallPreStage (
	intRecallPreStageId INT IDENTITY(1, 1) PRIMARY KEY
	,intWorkOrderId INT
	,intUserId INT
	,intStatusId INT
	,strRowState NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	,dtmFeedDate DATETIME CONSTRAINT DF_tblMFRecallPreStage_dtmFeedDate DEFAULT GETDATE()
	,strMessage NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	,ysnMailSent BIT
	)
