CREATE TABLE [dbo].[tblQMSampleLabel]
(
	intSampleLabelId INT NOT NULL IDENTITY(1,1),
	strSampleLabelName NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
	strReportName NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
	intControlPointId INT NOT NULL,
	intConcurrencyId INT NULL CONSTRAINT [DF_tblQMSampleLabel_intConcurrencyId] DEFAULT 1,

	CONSTRAINT [PK_tblQMSampleLabel] PRIMARY KEY (intSampleLabelId),
	CONSTRAINT [AK_tblQMSampleLabel_strSampleLabelName] UNIQUE (strSampleLabelName)
)