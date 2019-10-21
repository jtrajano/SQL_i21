CREATE TABLE dbo.tblMFPatternCode (
	intPatternCode INT NOT NULL
	,strName NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
	,CONSTRAINT PK_tblMFPatternCode_intPatternCode PRIMARY KEY (intPatternCode)
	)
