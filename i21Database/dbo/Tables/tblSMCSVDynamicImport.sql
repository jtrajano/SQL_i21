CREATE TABLE [dbo].[tblSMCSVDynamicImport]
(
	intCSVDynamicImportId				INT	PRIMARY KEY IDENTITY(1,1) NOT NULL,
	strName								NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
	strCommand							NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NOT NULL,


	intConcurrencyId					INT DEFAULT(0) NOT NULL	
)
