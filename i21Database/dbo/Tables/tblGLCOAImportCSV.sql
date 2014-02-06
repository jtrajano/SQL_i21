CREATE TABLE [dbo].[tblGLCOAImportCSV] (
    [intUploadCSV]    INT             IDENTITY (1, 1) NOT NULL,
    [strFilename]     NVARCHAR (150)  COLLATE Latin1_General_CI_AS NULL,
    [dtmUploaded]     DATETIME        CONSTRAINT [DF_tblGLUploadFile_dtmUploaded] DEFAULT (getdate()) NULL,
    [dtmLastImported] DATETIME        NULL,
    [dblSize]         DECIMAL (18, 6) CONSTRAINT [DF_tblGLUploadFile_intImported] DEFAULT ((0)) NULL,
    CONSTRAINT [PK_tblGLCOAImportCSV] PRIMARY KEY CLUSTERED ([intUploadCSV] ASC)
);

