CREATE TABLE [dbo].[tblSMReportLabels]
(
	[intReportLabelsId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [strName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT 1
)
