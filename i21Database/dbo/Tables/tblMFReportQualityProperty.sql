CREATE TABLE dbo.tblMFReportQualityProperty (
	intReportPropertyId INT NOT NULL identity(1, 1) CONSTRAINT PK_tblMFReportProperty_intReportPropertyId PRIMARY KEY
	,strReportName NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
	,intPropertyId INT NOT NULL
	,intSequenceNo INT NOT NULL
	,CONSTRAINT PK_tblMFReportProperty_intPropertyId FOREIGN KEY (intPropertyId) REFERENCES tblQMProperty(intPropertyId)
	,CONSTRAINT UQ_tblMFReportProperty_strReportName_intPropertyId UNIQUE (
		strReportName
		,intPropertyId
		)
	)
