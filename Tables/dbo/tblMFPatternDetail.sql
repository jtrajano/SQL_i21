CREATE TABLE dbo.tblMFPatternDetail (
	intPatternDetailId int IDENTITY(1, 1) NOT NULL
	,intPatternId INT NOT NULL
	,strSubPatternName NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
	,intSubPatternTypeId INT NOT NULL
	,intSubPatternSize INT NULL
	,strSubPatternTypeDetail NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	,strSubPatternFormat NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	,intOrdinalPosition INT NOT NULL
	,ysnPaddingZero bit
	,ysnMaxSize BIT
	,CONSTRAINT PK_tblMFPatternDetail_intPatternDetailId PRIMARY KEY (intPatternDetailId)
	,CONSTRAINT FK_tblMFPatternDetail_tblMFPattern_intPatternId FOREIGN KEY (intPatternId) REFERENCES dbo.tblMFPattern(intPatternId)
	,CONSTRAINT FK_tblMFPatternDetail_tblMFSubPatternType_intSubPatternTypeId FOREIGN KEY (intSubPatternTypeId) REFERENCES dbo.tblMFSubPatternType(intSubPatternTypeId)
	)
