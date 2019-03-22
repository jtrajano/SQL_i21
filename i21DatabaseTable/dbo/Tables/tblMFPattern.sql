CREATE TABLE dbo.tblMFPattern (
	intPatternId INT IDENTITY(1, 1) NOT NULL
	,strPatternName NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
	,strDescription NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL
	,intPatternCode int not null
	,intLocationId INT NULL
	,CONSTRAINT PK_tblMFPattern_intPatternId PRIMARY KEY (intPatternId)
	,CONSTRAINT FK_tblMFPattern_tblSMCompanyLocation_intLocationId FOREIGN KEY (intLocationId) REFERENCES dbo.tblSMCompanyLocation(intCompanyLocationId)
	)
