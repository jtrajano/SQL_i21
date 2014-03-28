CREATE TABLE [dbo].[tblGLImportFile] (
    [intUploadCSV]    INT             IDENTITY (1, 1) NOT NULL,
    [strFilename]     NVARCHAR (150)  COLLATE Latin1_General_CI_AS NULL,
    [dtmUploaded]     DATETIME        NULL,
    [dtmLastImported] DATETIME        NULL,
    [dblSize]         DECIMAL (18, 6) NULL,
    [strType]         NVARCHAR (20)   COLLATE Latin1_General_CI_AS NULL,
    CONSTRAINT [PK_tblGLImportFile] PRIMARY KEY CLUSTERED ([intUploadCSV] ASC)
);

