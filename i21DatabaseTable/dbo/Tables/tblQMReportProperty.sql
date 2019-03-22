CREATE TABLE dbo.tblQMReportProperty (
	intReportPropertyId INT NOT NULL identity(1, 1) CONSTRAINT PK_tblQMReportProperty_intReportPropertyId PRIMARY KEY
	,strReportName NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
	,intPropertyId INT NOT NULL
	,intSequenceNo INT NOT NULL
	,[intConcurrencyId] INT NULL CONSTRAINT [DF_tblQMReportProperty_intConcurrencyId] DEFAULT 0

	,[intCreatedUserId] [int] NULL
	,[dtmCreated] [datetime] NULL CONSTRAINT [DF_tblQMReportProperty_dtmCreated] DEFAULT GetDate()
	,[intLastModifiedUserId] [int] NULL
	,[dtmLastModified] [datetime] NULL CONSTRAINT [DF_tblQMReportProperty_dtmLastModified] DEFAULT GetDate()

	,CONSTRAINT PK_tblQMReportProperty_intPropertyId FOREIGN KEY (intPropertyId) REFERENCES tblQMProperty(intPropertyId)
	,CONSTRAINT UQ_tblQMReportProperty_strReportName_intPropertyId UNIQUE (
		strReportName
		,intPropertyId
		)
	)
