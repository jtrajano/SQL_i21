CREATE TABLE [dbo].[tblGLCOAImportCSV] (
    [intUploadCSV]    INT             IDENTITY (1, 1) NOT NULL,
    [strFilename]     NVARCHAR (150)  COLLATE Latin1_General_CI_AS NULL,
    [dtmUploaded]     DATETIME        CONSTRAINT [DF_tblGLUploadFile_dtmUploaded] DEFAULT (getdate()) NULL,
    [dtmLastImported] DATETIME        NULL,
    [dblSize]         DECIMAL (18, 6) CONSTRAINT [DF_tblGLUploadFile_intImported] DEFAULT ((0)) NULL,
    CONSTRAINT [PK_tblGLCOAImportCSV] PRIMARY KEY CLUSTERED ([intUploadCSV] ASC)
);

GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Table Primary Key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLCOAImportCSV', @level2type=N'COLUMN',@level2name=N'intUploadCSV' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Filename' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLCOAImportCSV', @level2type=N'COLUMN',@level2name=N'strFilename' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Uploaded' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLCOAImportCSV', @level2type=N'COLUMN',@level2name=N'dtmUploaded' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Last Imported' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLCOAImportCSV', @level2type=N'COLUMN',@level2name=N'dtmLastImported' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Size' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLCOAImportCSV', @level2type=N'COLUMN',@level2name=N'dblSize' 
GO