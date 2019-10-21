CREATE TABLE [dbo].[tblSMTaxReportType]
(	
	[intTaxReportTypeId]	INT NOT NULL PRIMARY KEY IDENTITY(1, 100), 
    [strType]				NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL, 
    [ysnSystemDefault]		BIT DEFAULT(0) NOT NULL,
	[intSort]				SMALLINT NOT NULL DEFAULT(0),
    [intConcurrencyId] INT NOT NULL DEFAULT 1
)