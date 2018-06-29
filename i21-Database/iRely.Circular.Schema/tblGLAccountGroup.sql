CREATE TABLE [dbo].[tblGLAccountGroup] (
    [intAccountGroupId]        INT             IDENTITY (1, 1) NOT NULL,
    [strAccountGroup]          NVARCHAR (50)   COLLATE Latin1_General_CI_AS NOT NULL,
    [strAccountType]           NVARCHAR (20)   COLLATE Latin1_General_CI_AS NULL,
    [intParentGroupId]         INT             NULL,
    [intGroup]                 INT             NULL,
    [intSort]                  INT             NULL,
    [intConcurrencyId]         INT             DEFAULT 1 NOT NULL,
    [intAccountBegin]          INT             NULL,
    [intAccountEnd]            INT             NULL,
    [strAccountGroupNamespace] NVARCHAR (1000) COLLATE Latin1_General_CI_AS NULL,
    [intEntityIdLastModified] INT NULL, 
    [intAccountCategoryId] INT NULL, 
	[intAccountRangeId] [int] NULL,
    CONSTRAINT [PK_GLAccountGroup_AccountGroupId] PRIMARY KEY CLUSTERED ([intAccountGroupId] ASC), 
    CONSTRAINT [FK_tblGLAccountGroup_tblGLAccountCategory] FOREIGN KEY([intAccountCategoryId])	REFERENCES [dbo].[tblGLAccountCategory] ([intAccountCategoryId]),
	CONSTRAINT [FK_tblGLAccountGroup_tblGLAccountRange] FOREIGN KEY([intAccountRangeId]) REFERENCES [dbo].[tblGLAccountRange] ([intAccountRangeId])
);
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Table Primary Key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountGroup', @level2type=N'COLUMN',@level2name=N'intAccountGroupId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Account Group Description' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountGroup', @level2type=N'COLUMN',@level2name=N'strAccountGroup' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Account Type' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountGroup', @level2type=N'COLUMN',@level2name=N'strAccountType' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Parent Group Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountGroup', @level2type=N'COLUMN',@level2name=N'intParentGroupId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Group' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountGroup', @level2type=N'COLUMN',@level2name=N'intGroup' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Sort' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountGroup', @level2type=N'COLUMN',@level2name=N'intSort' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Concurrency Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountGroup', @level2type=N'COLUMN',@level2name=N'intConcurrencyId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Account Begin' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountGroup', @level2type=N'COLUMN',@level2name=N'intAccountBegin' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Account End' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountGroup', @level2type=N'COLUMN',@level2name=N'intAccountEnd' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Account Group Namespace' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountGroup', @level2type=N'COLUMN',@level2name=N'strAccountGroupNamespace' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Entity Last Modified' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountGroup', @level2type=N'COLUMN',@level2name=N'intEntityIdLastModified' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Account Category Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountGroup', @level2type=N'COLUMN',@level2name=N'intAccountCategoryId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Account Range Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountGroup', @level2type=N'COLUMN',@level2name=N'intAccountRangeId' 
GO

