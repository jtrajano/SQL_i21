CREATE TABLE dbo.tblApiCompletedWorkOrderStocked (
	 intId INT NOT NULL IDENTITY(1, 1) PRIMARY KEY
	,guiApiUniqueId UNIQUEIDENTIFIER NULL
	,intBatchId INT
	
	-- Output / Input items
	,intItemId INT
	,dblQuantity NUMERIC(18, 6)
	,intItemUOMId INT
	,intStorageLocationId INT
	,intStorageUnitId INT
	,strLotNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS
	
	-- Common fields
	,intTransactionTypeId INT -- 8 (Input) / 9 (Output)
	,strUserName NVARCHAR(100) COLLATE Latin1_General_CI_AS
	,dtmDate DATETIME
	,intLocationId INT
	
	-- Output fields
	,ysnProcessed BIT DEFAULT(0)
	,strWorkOrderNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strMessage NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	,strFeedStatus NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,ysnCompleted BIT DEFAULT (0)
	)