CREATE TABLE [dbo].[tblARImportLog]
(
	[intImportLogId]	INT NOT NULL  IDENTITY, 
    [strEventMessage]	NVARCHAR(255) COLLATE Latin1_General_CI_AS NULL,
    [strVersion]		NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[dtmDate]			DATETIME NULL,
    [intEntityId]		INT NULL,
	[intSuccessCount]   INT NULL,
	[intFailedCount]    INT NULL,
    [intConcurrencyId]	INT NOT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblARImportLog_intImportLogId] PRIMARY KEY CLUSTERED ([intImportLogId] ASC)
)
