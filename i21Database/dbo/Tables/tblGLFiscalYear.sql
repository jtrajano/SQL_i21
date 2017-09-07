CREATE TABLE [dbo].[tblGLFiscalYear] (
    [intFiscalYearId]  INT           IDENTITY (1, 1) NOT NULL,
    [strFiscalYear]    NVARCHAR (50) COLLATE Latin1_General_CI_AS NOT NULL,
    [intRetainAccount] INT           NULL,
    [dtmDateFrom]      DATETIME      NULL,
    [dtmDateTo]        DATETIME      NULL,
    [ysnStatus]        BIT           DEFAULT 1 NOT NULL,
    [intConcurrencyId] INT           DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblGLFiscalYearPeriod_1] PRIMARY KEY CLUSTERED ([intFiscalYearId] ASC)
);

GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Table Primary Key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLFiscalYear', @level2type=N'COLUMN',@level2name=N'intFiscalYearId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fiscal Year' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLFiscalYear', @level2type=N'COLUMN',@level2name=N'strFiscalYear' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Retain Account' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLFiscalYear', @level2type=N'COLUMN',@level2name=N'intRetainAccount' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date Date From' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLFiscalYear', @level2type=N'COLUMN',@level2name=N'dtmDateFrom' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date Date To' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLFiscalYear', @level2type=N'COLUMN',@level2name=N'dtmDateTo' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Status' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLFiscalYear', @level2type=N'COLUMN',@level2name=N'ysnStatus' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Concurrency Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLFiscalYear', @level2type=N'COLUMN',@level2name=N'intConcurrencyId' 
GO