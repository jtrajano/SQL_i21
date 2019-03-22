CREATE TABLE dbo.tblMFReportLabel
(
	intReportLabelId INT NOT NULL IDENTITY(1, 1) CONSTRAINT PK_tblMFReportLabel_intReportLabelId PRIMARY KEY,
	strReportName [NVARCHAR](100) COLLATE Latin1_General_CI_AS NOT NULL,
	ysnShow BIT NOT NULL DEFAULT 0,
	[intConcurrencyId] INT NOT NULL, 

	CONSTRAINT [UK_tblMFReportLabel_strReportName] UNIQUE (strReportName)
)
