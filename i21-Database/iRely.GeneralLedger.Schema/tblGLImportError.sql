/* used by Import Budget CSV as temporary table*/
CREATE TABLE [dbo].[tblGLImportError]
(
	[intId] [int] IDENTITY(1,1) NOT NULL,
	[guidSessionId] [uniqueidentifier] NOT NULL,
	[strTitle] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strDescription] [varchar](150) COLLATE Latin1_General_CI_AS NULL,
	[dteAdded] [datetime] NULL
) 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLImportError', @level2type=N'COLUMN',@level2name=N'intId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Session Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLImportError', @level2type=N'COLUMN',@level2name=N'guidSessionId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Title' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLImportError', @level2type=N'COLUMN',@level2name=N'strTitle' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Description' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLImportError', @level2type=N'COLUMN',@level2name=N'strDescription' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date Added' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLImportError', @level2type=N'COLUMN',@level2name=N'dteAdded' 
GO
