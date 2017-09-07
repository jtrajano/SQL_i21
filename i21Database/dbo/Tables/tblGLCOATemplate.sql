CREATE TABLE [dbo].[tblGLCOATemplate] (
    [intAccountTemplateId]   INT           IDENTITY (1, 1) NOT NULL,
    [strAccountTemplateName] NVARCHAR (50) COLLATE Latin1_General_CI_AS NOT NULL,
    [strType]				 NVARCHAR (15) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId]       INT           DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblGLAccountTemplate] PRIMARY KEY CLUSTERED ([intAccountTemplateId] ASC)
);
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Account Template Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLCOATemplate', @level2type=N'COLUMN',@level2name=N'intAccountTemplateId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Account Template Name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLCOATemplate', @level2type=N'COLUMN',@level2name=N'strAccountTemplateName' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Type' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLCOATemplate', @level2type=N'COLUMN',@level2name=N'strType' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Concurrency Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLCOATemplate', @level2type=N'COLUMN',@level2name=N'intConcurrencyId' 
GO