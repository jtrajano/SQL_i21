CREATE TABLE tblMFBatchPreStage (
	intBatchPreStageId INT IDENTITY(1, 1) PRIMARY KEY
	,intBatchId INT
	,intOriginalItemId INT
	,intItemId INT
	,intUserId INT
	,intStatusId INT
	,dtmFeedDate DATETIME CONSTRAINT DF_tblMFBatchPreStage_dtmFeedDate DEFAULT GETDATE()
	,strMessage NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	,ysnMailSent BIT
	)