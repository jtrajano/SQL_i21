CREATE TABLE dbo.tblMFBuyingGroup (
	intBuyingGroupId INT IDENTITY(1, 1) NOT NULL
	,strBuyingGroup NVARCHAR(50) NULL
	,dtmCreated DATETIME NOT NULL
	,intCreatedUserId INT NOT NULL
	,dtmLastModified DATETIME NOT NULL
	,intLastModifiedUserId INT NOT NULL
	,intConcurrencyId INT
	,CONSTRAINT PK_tblMFBuyingGroup_intBuyingGroupId PRIMARY KEY CLUSTERED (intBuyingGroupId ASC)
	,CONSTRAINT UQ_tblMFBuyingGroup_strBuyingGroup UNIQUE NONCLUSTERED (strBuyingGroup ASC)
	)
