CREATE TABLE [dbo].[tblSMCSVDynamicImportLogDetail]
(
	intCSVDynamicImportLogDetailId		INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
	intCSVDynamicImportLogId			INT NOT NULL,
	strData								NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NOT NULL,
	intSort								INT NOT NULL,
	strResult							NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NOT NULL DEFAULT(''),

	intConcurrencyId					INT DEFAULT(0) NOT NULL	
	--ADD FK FOR THE HEADER
	CONSTRAINT [FK_tblSMCSVDynamicImportLogDetail_tblSMCSVDynamicImportLog] FOREIGN KEY (intCSVDynamicImportLogId) REFERENCES [dbo].tblSMCSVDynamicImportLog (intCSVDynamicImportLogId) ON DELETE CASCADE
)
