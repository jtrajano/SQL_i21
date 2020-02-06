CREATE TABLE tblMFRecipePreStage (
	intRecipePreStageId INT IDENTITY(1, 1) PRIMARY KEY
	,intRecipeId INT
	,intRecipeItemId INT
	,strRecipeRowState NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strRecipeItemRowState NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,intUserId INT
	,strFeedStatus NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,dtmFeedDate DATETIME CONSTRAINT DF_tblMFRecipePreStage_dtmFeedDate DEFAULT GETDATE()
	,strMessage NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	)
