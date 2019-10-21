CREATE TABLE [dbo].[tblGLAccountTemplateDetail] (
    [intGLAccountTempalteDetailId] INT            IDENTITY (1, 1) NOT NULL,
    [intGLAccountTemplateId]       INT            NULL,
    [strTemplate]                  NVARCHAR (30)  COLLATE Latin1_General_CI_AS NOT NULL,
    [strModuleName]                NVARCHAR (25)  COLLATE Latin1_General_CI_AS NOT NULL,
    [strDefaultName]               NVARCHAR (50)  COLLATE Latin1_General_CI_AS NOT NULL,
    [strDescription]               NVARCHAR (255) COLLATE Latin1_General_CI_AS NULL,
    [strRowFilter]                 NVARCHAR (255) COLLATE Latin1_General_CI_AS NULL,
    [ysnSelected]                  BIT            NULL,
    [intAccountId]                 INT            NULL,
    [intConcurrencyId]             INT            DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblGLAccountTemplateDetail_1] PRIMARY KEY CLUSTERED ([intGLAccountTempalteDetailId] ASC),
    CONSTRAINT [FK_tblGLAccountTemplateDetail_tblGLAccount] FOREIGN KEY ([intAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
    CONSTRAINT [FK_tblGLAccountTemplateDetail_tblGLAccountTemplate1] FOREIGN KEY ([intGLAccountTemplateId]) REFERENCES [dbo].[tblGLAccountTemplate] ([intGLAccountTemplateId])
);
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Table Primary Key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountTemplateDetail', @level2type=N'COLUMN',@level2name=N'intGLAccountTempalteDetailId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Foreign Key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountTemplateDetail', @level2type=N'COLUMN',@level2name=N'intGLAccountTemplateId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Template' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountTemplateDetail', @level2type=N'COLUMN',@level2name=N'strTemplate' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Module Name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountTemplateDetail', @level2type=N'COLUMN',@level2name=N'strModuleName' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Default Name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountTemplateDetail', @level2type=N'COLUMN',@level2name=N'strDefaultName' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Description' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountTemplateDetail', @level2type=N'COLUMN',@level2name=N'strDescription' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Row Filter' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountTemplateDetail', @level2type=N'COLUMN',@level2name=N'strRowFilter' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Selected' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountTemplateDetail', @level2type=N'COLUMN',@level2name=N'ysnSelected' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Account Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountTemplateDetail', @level2type=N'COLUMN',@level2name=N'intAccountId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Concurrency Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountTemplateDetail', @level2type=N'COLUMN',@level2name=N'intConcurrencyId' 
GO