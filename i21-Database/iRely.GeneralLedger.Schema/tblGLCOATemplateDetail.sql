CREATE TABLE [dbo].[tblGLCOATemplateDetail] (
    [intAccountTemplateDetailId] INT           IDENTITY (1, 1) NOT NULL,
    [intAccountTemplateId]       INT           NOT NULL,
    [strCode]                    NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
    [strDescription]             NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
    [intAccountGroupId]          INT           NULL,
    [intAccountStructureId]      INT           NULL,
    [intConcurrencyId]           INT           DEFAULT 1 NOT NULL,
    [intAccountCategoryId]       INT           NULL, 
    CONSTRAINT [PK_tblGLAccountTemplateDetail] PRIMARY KEY CLUSTERED ([intAccountTemplateDetailId] ASC),
    CONSTRAINT [FK_tblGLAccountTemplateDetail_tblGLAccountGroup] FOREIGN KEY ([intAccountGroupId]) REFERENCES [dbo].[tblGLAccountGroup] ([intAccountGroupId]),
    CONSTRAINT [FK_tblGLAccountTemplateDetail_tblGLAccountStructure] FOREIGN KEY ([intAccountStructureId]) REFERENCES [dbo].[tblGLAccountStructure] ([intAccountStructureId]),
	CONSTRAINT [FK_tblGLCOATemplateDetail_tblGLAccountCategory] FOREIGN KEY([intAccountCategoryId])REFERENCES [dbo].[tblGLAccountCategory] ([intAccountCategoryId]),
    CONSTRAINT [FK_tblGLAccountTemplateDetail_tblGLAccountTemplate] FOREIGN KEY ([intAccountTemplateId]) REFERENCES [dbo].[tblGLCOATemplate] ([intAccountTemplateId]) ON DELETE CASCADE
);
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Table Primary Key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLCOATemplateDetail', @level2type=N'COLUMN',@level2name=N'intAccountTemplateDetailId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Foreign Key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLCOATemplateDetail', @level2type=N'COLUMN',@level2name=N'intAccountTemplateId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Code' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLCOATemplateDetail', @level2type=N'COLUMN',@level2name=N'strCode' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Description' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLCOATemplateDetail', @level2type=N'COLUMN',@level2name=N'strDescription' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Account Group Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLCOATemplateDetail', @level2type=N'COLUMN',@level2name=N'intAccountGroupId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Account Structure Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLCOATemplateDetail', @level2type=N'COLUMN',@level2name=N'intAccountStructureId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Concurrency Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLCOATemplateDetail', @level2type=N'COLUMN',@level2name=N'intConcurrencyId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Account Category Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLCOATemplateDetail', @level2type=N'COLUMN',@level2name=N'intAccountCategoryId' 
GO