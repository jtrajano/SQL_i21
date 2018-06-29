CREATE TABLE [dbo].[tblGLAccountDefaultDetail] (
    [intAccountDefaultDetailId] INT            IDENTITY (1, 1) NOT NULL,
    [intAccountDefaultId]       INT            NOT NULL,
    [strModuleName]             NVARCHAR (25)  COLLATE Latin1_General_CI_AS NOT NULL,
    [strDefaultName]            NVARCHAR (50)  COLLATE Latin1_General_CI_AS NOT NULL,
    [strDescription]            NVARCHAR (255) COLLATE Latin1_General_CI_AS NULL,
    [strRowFilter]              NVARCHAR (255) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId]          INT            DEFAULT 1 NOT NULL,
    [intAccountId]              INT            NULL,
    CONSTRAINT [PK_GLAccountDefault_AccountDefaultId] PRIMARY KEY CLUSTERED ([intAccountDefaultDetailId] ASC),
    CONSTRAINT [FK_tblGLAccountDefault_tblGLAccount] FOREIGN KEY ([intAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
    CONSTRAINT [FK_tblGLAccountDefaultDetail_tblGLAccountDefault] FOREIGN KEY ([intAccountDefaultId]) REFERENCES [dbo].[tblGLAccountDefault] ([intAccountDefaultId])
);

GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Table Primary Key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountDefaultDetail', @level2type=N'COLUMN',@level2name=N'intAccountDefaultDetailId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Foreign Key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountDefaultDetail', @level2type=N'COLUMN',@level2name=N'intAccountDefaultId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Module Name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountDefaultDetail', @level2type=N'COLUMN',@level2name=N'strModuleName' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Default Name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountDefaultDetail', @level2type=N'COLUMN',@level2name=N'strDefaultName' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Description' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountDefaultDetail', @level2type=N'COLUMN',@level2name=N'strDescription' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Row Filter' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountDefaultDetail', @level2type=N'COLUMN',@level2name=N'strRowFilter' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Concurrency Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountDefaultDetail', @level2type=N'COLUMN',@level2name=N'intConcurrencyId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Account Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountDefaultDetail', @level2type=N'COLUMN',@level2name=N'intAccountId' 
GO