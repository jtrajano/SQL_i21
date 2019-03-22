CREATE TABLE [dbo].[tblARImportFile]
(
	[intImportFileId]	INT NOT NULL  IDENTITY, 
    [strFileName]		NVARCHAR(255) COLLATE Latin1_General_CI_AS NULL, 
	[strImportFormat]	NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [dtmDate]		    DATETIME NULL, 
    [dblFileSize]		NUMERIC(18, 6) NULL,
	[strOriginType]		NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[intEntityId]		INT NULL,
    [intConcurrencyId]	INT NOT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblARImportFile_intImportFileId] PRIMARY KEY CLUSTERED ([intImportFileId] ASC)
)
