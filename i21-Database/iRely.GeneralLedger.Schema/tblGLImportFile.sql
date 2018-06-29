CREATE TABLE [dbo].[tblGLImportFile] (
    [intUploadCSV]    INT             IDENTITY (1, 1) NOT NULL,
    [strFilename]     NVARCHAR (150)  COLLATE Latin1_General_CI_AS NULL,
    [dtmUploaded]     DATETIME        NULL,
    [dtmLastImported] DATETIME        NULL,
    [dblSize]         DECIMAL (18, 6) NULL,
    [strType]         NVARCHAR (20)   COLLATE Latin1_General_CI_AS NULL,
    CONSTRAINT [PK_tblGLImportFile] PRIMARY KEY CLUSTERED ([intUploadCSV] ASC)
);
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Table Primary Key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLImportFile', @level2type=N'COLUMN',@level2name=N'intUploadCSV' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Filename' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLImportFile', @level2type=N'COLUMN',@level2name=N'strFilename' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date Uploaded' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLImportFile', @level2type=N'COLUMN',@level2name=N'dtmUploaded' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date Last Imported' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLImportFile', @level2type=N'COLUMN',@level2name=N'dtmLastImported' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Size' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLImportFile', @level2type=N'COLUMN',@level2name=N'dblSize' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Type' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLImportFile', @level2type=N'COLUMN',@level2name=N'strType' 
GO
