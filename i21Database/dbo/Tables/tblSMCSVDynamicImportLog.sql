CREATE TABLE [dbo].[tblSMCSVDynamicImportLog]
(
	intCSVDynamicImportLogId			INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
	intCSVDynamicImportId				INT NOT NULL,
	strUniqueId							NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
	intEntityUserId						INT NOT NULL,


	intConcurrencyId					INT DEFAULT(0) NOT NULL	
	--ADD FK FOR THE HEADER
	CONSTRAINT [FK_tblSMCSVDynamicImportLog_tblSMCSVDynamicImport] FOREIGN KEY (intCSVDynamicImportId) REFERENCES [dbo].[tblSMCSVDynamicImport] (intCSVDynamicImportId),

)