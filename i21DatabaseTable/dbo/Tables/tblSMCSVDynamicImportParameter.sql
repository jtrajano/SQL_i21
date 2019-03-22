CREATE TABLE [dbo].[tblSMCSVDynamicImportParameter]
(
	intCSVDynamicImportParameterId		INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
	intCSVDynamicImportId				INT NOT NULL,
	strColumnName						NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
	strDisplayName						NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
	ysnRequired							BIT NOT NULL DEFAULT(0),


	intConcurrencyId					INT DEFAULT(0) NOT NULL,
	--ADD FK FOR THE HEADER
	CONSTRAINT [FK_tblSMCSVDynamicImportParameter_tblSMCSVDynamicImport] FOREIGN KEY (intCSVDynamicImportId) REFERENCES [dbo].[tblSMCSVDynamicImport] (intCSVDynamicImportId),
)