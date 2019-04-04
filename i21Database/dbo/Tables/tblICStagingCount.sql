CREATE TABLE tblICStagingCount(
	  intStagingCountId INT IDENTITY(1, 1)
	, intCountId INT NULL -- Used when exporting
	, strCountNo NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL -- Used for grouping or when exporting
	, strLocation NVARCHAR(200) COLLATE Latin1_General_CI_AS NOT NULL
	, dtmDate DATETIME NOT NULL
	, ysnCountByLots BIT NOT NULL
	, strCountGroup NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
	, strDescription NVARCHAR(300) COLLATE Latin1_General_CI_AS NULL
	, CONSTRAINT PK_tblICStagingCount_intStagingCountId PRIMARY KEY(intStagingCountId)
)