CREATE TABLE [dbo].[tblGLAccountRange](
	[intAccountRangeId] [int] IDENTITY(1,1) NOT NULL,
	[strAccountType]  NVARCHAR(20) COLLATE Latin1_General_CI_AS NULL,
	[intMinRange] [int] NULL,
	[intMaxRange] [int] NULL,
 [intConcurrencyId] INT NOT NULL DEFAULT 1, 
    [intAccountGroupId] INT NULL, 
    CONSTRAINT [PK_tblGLAccountRange] PRIMARY KEY CLUSTERED 
(
	[intAccountRangeId] ASC
)WITH ( STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF)
)

GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Table Primary Key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountRange', @level2type=N'COLUMN',@level2name=N'intAccountRangeId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Account Type' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountRange', @level2type=N'COLUMN',@level2name=N'strAccountType' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Min Range' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountRange', @level2type=N'COLUMN',@level2name=N'intMinRange' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Max Range' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountRange', @level2type=N'COLUMN',@level2name=N'intMaxRange' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Concurrency Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountRange', @level2type=N'COLUMN',@level2name=N'intConcurrencyId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Account Group Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountRange', @level2type=N'COLUMN',@level2name=N'intAccountGroupId' 
GO