CREATE TABLE [dbo].[tblFRImportFile] (
    [intFileId]			INT             IDENTITY (1, 1) NOT NULL,
    [strFilename]		NVARCHAR (150)  COLLATE Latin1_General_CI_AS NULL,
    [dtmUploaded]		DATETIME        NULL,
    [dtmLastImported]	DATETIME        NULL,
    [dblSize]			DECIMAL (18, 6) NULL,
    [strType]			NVARCHAR (20)   COLLATE Latin1_General_CI_AS NULL,
	intConcurrencyId	INT				DEFAULT 1 NULL
    CONSTRAINT [PK_tblFRImportFile] PRIMARY KEY CLUSTERED ([intFileId] ASC)
);

