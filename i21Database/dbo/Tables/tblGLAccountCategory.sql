CREATE TABLE [dbo].[tblGLAccountCategory]
(
	[intAccountCategoryId] [int] IDENTITY(1,1) NOT NULL,
	[strAccountCategory] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL ,
	[intConcurrencyId] [int] NOT NULL
    CONSTRAINT [PK_tblGLAccountCategory] PRIMARY KEY ([intAccountCategoryId]), 
    [strAccountGroupFilter] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL, 
	[intModuleId] INT NULL,
    [ysnRestricted] BIT NULL,
	[ysnGLRestricted] BIT NULL,
	[ysnAPRestricted] BIT NULL
)
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Account Category Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountCategory', @level2type=N'COLUMN',@level2name=N'intAccountCategoryId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Account Category (string)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountCategory', @level2type=N'COLUMN',@level2name=N'strAccountCategory' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Concurrency Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountCategory', @level2type=N'COLUMN',@level2name=N'intConcurrencyId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Account Group Filter' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountCategory', @level2type=N'COLUMN',@level2name=N'strAccountGroupFilter' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'If restricted' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountCategory', @level2type=N'COLUMN',@level2name=N'ysnRestricted' 
GO