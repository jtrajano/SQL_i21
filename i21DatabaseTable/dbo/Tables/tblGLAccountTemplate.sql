CREATE TABLE [dbo].[tblGLAccountTemplate] (
    [intGLAccountTemplateId] INT           IDENTITY (1, 1) NOT NULL,
    [strTemplate]            NVARCHAR (30) COLLATE Latin1_General_CI_AS NOT NULL,
    [strDescription]         NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId]       INT           DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblGLCOATemplate] PRIMARY KEY CLUSTERED ([intGLAccountTemplateId] ASC)
);
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Table Primary Key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountTemplate', @level2type=N'COLUMN',@level2name=N'intGLAccountTemplateId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Template' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountTemplate', @level2type=N'COLUMN',@level2name=N'strTemplate' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Description' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountTemplate', @level2type=N'COLUMN',@level2name=N'strDescription' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Concurrency Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountTemplate', @level2type=N'COLUMN',@level2name=N'intConcurrencyId' 
GO

