CREATE TABLE [dbo].[tblGLModuleList] (
    [cntId]            INT           IDENTITY (1, 1) NOT NULL,
    [strModule]        NVARCHAR (20) COLLATE Latin1_General_CI_AS NOT NULL,
    [ysnOpen]          BIT           NOT NULL,
    [intConcurrencyId] INT           DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblGLModuleList] PRIMARY KEY CLUSTERED ([cntId] ASC, [strModule] ASC)
);
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Table Primary Key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLModuleList', @level2type=N'COLUMN',@level2name=N'cntId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Module' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLModuleList', @level2type=N'COLUMN',@level2name=N'strModule' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Open' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLModuleList', @level2type=N'COLUMN',@level2name=N'ysnOpen' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Concurrency Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLModuleList', @level2type=N'COLUMN',@level2name=N'intConcurrencyId' 
GO