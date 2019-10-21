  CREATE TABLE  tblSMInterCompanyStageDelete
  (
	[intInterCompanyStageDeleteId] INT IDENTITY(1,1) NOT NULL,
	[intSourceId] INT NULL,
	[intDestinationId] INT NULL,
	[strDatabaseName] NVARCHAR(200) NULL,
	[dtmDate] DATETIME NULL,
	CONSTRAINT [PK_tblSMInterCompanyStageDelete] PRIMARY KEY CLUSTERED ([intInterCompanyStageDeleteId] ASC)
  )