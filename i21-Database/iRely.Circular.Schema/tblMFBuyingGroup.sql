CREATE TABLE dbo.tblMFBuyingGroup (
	intBuyingGroupId INT IDENTITY(1, 1) NOT NULL
	,strBuyingGroup NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
	,dtmCreated DATETIME 
	,intCreatedUserId INT 
	,dtmLastModified DATETIME 
	,intLastModifiedUserId INT 
	,intConcurrencyId INT
	,CONSTRAINT PK_tblMFBuyingGroup_intBuyingGroupId PRIMARY KEY CLUSTERED (intBuyingGroupId ASC)
	,CONSTRAINT UQ_tblMFBuyingGroup_strBuyingGroup UNIQUE NONCLUSTERED (strBuyingGroup ASC)
	)
