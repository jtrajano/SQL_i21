CREATE TABLE dbo.tblQMReportNameMapping (
	intReportNameMappingId INT NOT NULL IDENTITY
	,strReportName NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
	,intControlPointId INT NOT NULL
	,intConcurrencyId INT NULL CONSTRAINT DF_tblQMReportNameMapping_intConcurrencyId DEFAULT 0

	,[intCreatedUserId] [int] NULL
	,[dtmCreated] [datetime] NULL CONSTRAINT [DF_tblQMReportNameMapping_dtmCreated] DEFAULT GetDate()
	,[intLastModifiedUserId] [int] NULL
	,[dtmLastModified] [datetime] NULL CONSTRAINT [DF_tblQMReportNameMapping_dtmLastModified] DEFAULT GetDate()

	,CONSTRAINT [PK_tblQMReportNameMapping] PRIMARY KEY ([intReportNameMappingId])
	,CONSTRAINT FK_tblQMReportNameMapping_tblQMControlPoint FOREIGN KEY ([intControlPointId]) REFERENCES [tblQMControlPoint]([intControlPointId])
	)
