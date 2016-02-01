CREATE TABLE dbo.tblMFSubPatternType (
	intSubPatternTypeId INT NOT NULL
	,strSubPatternTypeName NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
	,CONSTRAINT PK_tblMFSubPatternType_intSubPatternTypeId PRIMARY KEY (intSubPatternTypeId)
	)
