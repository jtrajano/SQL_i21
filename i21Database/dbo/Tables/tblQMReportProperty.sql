CREATE TABLE dbo.tblQMReportProperty (
	intReportPropertyId INT NOT NULL identity(1, 1) CONSTRAINT PK_tblQMReportProperty_intReportPropertyId PRIMARY KEY
	,strReportName NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
	,intPropertyId INT NOT NULL
	,intSequenceNo INT NOT NULL
	,CONSTRAINT PK_tblQMReportProperty_intPropertyId FOREIGN KEY (intPropertyId) REFERENCES tblQMProperty(intPropertyId)
	,CONSTRAINT UQ_tblQMReportProperty_strReportName_intPropertyId UNIQUE (
		strReportName
		,intPropertyId
		)
	)
