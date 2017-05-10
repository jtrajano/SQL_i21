CREATE TABLE [dbo].[tblSMDocumentConfiguration]
(
	intDocumentConfigurationId INT IDENTITY (1, 1) NOT NULL PRIMARY KEY, 
    [intScreenId] INT UNIQUE NULL,
	[intDocumentReportId] INT NULL,
	[intDocumentSourceFolderId] INT NULL,
	[intConcurrencyId] INT NOT NULL DEFAULT 0,
	CONSTRAINT [FK_tblSMDocumentConfiguration_tblSMDocumentSourceFolder] FOREIGN KEY ([intDocumentSourceFolderId]) REFERENCES [dbo].[tblSMDocumentSourceFolder] ([intDocumentSourceFolderId]),
	CONSTRAINT [FK_tblSMDocumentConfiguration_tblSMDocumentReport] FOREIGN KEY ([intDocumentReportId]) REFERENCES [dbo].[tblSMDocumentReport] ([intDocumentReportId]),
	CONSTRAINT [FK_tblSMDocumentConfiguration_tblSMScreen] FOREIGN KEY ([intScreenId]) REFERENCES [dbo].[tblSMScreen] ([intScreenId])
)
