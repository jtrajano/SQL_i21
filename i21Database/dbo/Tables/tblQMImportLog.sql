CREATE TABLE [dbo].[tblQMImportLog]
(
	[intImportLogId]		INT NOT NULL  IDENTITY, 
	[strImportType]		    NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    [strFileName]		    NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[dtmImportDate]			DATETIME NULL,
    [intEntityId]			INT NULL,
	[intSuccessCount]		INT NULL,
	[intFailedCount]		INT NULL,
    [intConcurrencyId]		INT NOT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblQMImportLog_intImportLogId] PRIMARY KEY CLUSTERED ([intImportLogId] ASC)
);