CREATE TABLE [dbo].[tblGLAccountDefault] (
    [intAccountDefaultId]    INT IDENTITY (1, 1) NOT NULL,
    [intSecurityUserId]      INT NOT NULL,
    [intGLAccountTemplateId] INT NOT NULL,
    [intConcurrencyId]       INT DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblGLAccountDefault] PRIMARY KEY CLUSTERED ([intAccountDefaultId] ASC),
    CONSTRAINT [FK_tblGLAccountDefault_tblGLAccountTemplate] FOREIGN KEY ([intGLAccountTemplateId]) REFERENCES [dbo].[tblGLAccountTemplate] ([intGLAccountTemplateId])
);

GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Table Primary Key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountDefault', @level2type=N'COLUMN',@level2name=N'intAccountDefaultId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Security User Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountDefault', @level2type=N'COLUMN',@level2name=N'intSecurityUserId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'G L Account Template Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountDefault', @level2type=N'COLUMN',@level2name=N'intGLAccountTemplateId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Concurrency Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLAccountDefault', @level2type=N'COLUMN',@level2name=N'intConcurrencyId' 
GO