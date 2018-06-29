CREATE TABLE dbo.tblMFItemGroup (
	intItemGroupId INT IDENTITY(1, 1) NOT NULL
	,strItemGroupName NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
	,strDescription NVARCHAR(100) COLLATE Latin1_General_CI_AS
	,strShortName NVARCHAR(100) COLLATE Latin1_General_CI_AS
	,dtmCreated DATETIME NOT NULL
	,intCreatedUserId INT NOT NULL
	,dtmLastModified DATETIME NOT NULL
	,intLastModifiedUserId INT NOT NULL
	,intConcurrencyId INT
	,CONSTRAINT PK_tblMFItemGroup_intItemGroupId PRIMARY KEY (intItemGroupId)
	,CONSTRAINT UQ_tblMFItemGroup_strItemGroupName UNIQUE (strItemGroupName)
	)
