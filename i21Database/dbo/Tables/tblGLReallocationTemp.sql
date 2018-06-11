CREATE TABLE [dbo].[tblGLReallocationTemp](
[intAccountReallocationId] [int] NOT NULL,
intPrimary [int] NULL,
intSecondary [int] NULL,
decPercentage [decimal](9, 6) NULL,
[intAccountId] [int] NULL,
strAccountId [nvarchar](20) COLLATE Latin1_General_CI_AS NULL
)
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Account Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLReallocationTemp', @level2type=N'COLUMN',@level2name=N'strAccountId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Account Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLReallocationTemp', @level2type=N'COLUMN',@level2name=N'intAccountId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'dec Percentage' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLReallocationTemp', @level2type=N'COLUMN',@level2name=N'decPercentage' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Secondary' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLReallocationTemp', @level2type=N'COLUMN',@level2name=N'intSecondary' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Primary' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLReallocationTemp', @level2type=N'COLUMN',@level2name=N'intPrimary' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Account Reallocation Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLReallocationTemp', @level2type=N'COLUMN',@level2name=N'intAccountReallocationId' 
GO