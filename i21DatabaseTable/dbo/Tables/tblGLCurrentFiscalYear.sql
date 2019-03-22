CREATE TABLE [dbo].[tblGLCurrentFiscalYear] (
    [cntId]             INT             IDENTITY (1, 1) NOT NULL,
    [intFiscalYearId]   INT             NULL,
    [dtmBeginDate]      DATETIME        DEFAULT (getdate()) NOT NULL,
    [dtmEndDate]        DATETIME        DEFAULT (getdate()) NOT NULL,
    [dblPeriods]        NUMERIC (18, 6) DEFAULT ((0)) NULL,
    [ysnShowAllPeriods] BIT             DEFAULT ((0)) NOT NULL,
    [ysnDuplicates]     BIT             NOT NULL,
    [intConcurrencyId]  INT             DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblGLFiscalYear] PRIMARY KEY CLUSTERED ([cntId] ASC),
	CONSTRAINT [FK_tblGLCurrentFiscal_tblGLFiscalYear] FOREIGN KEY ([intFiscalYearId]) REFERENCES [dbo].[tblGLFiscalYear] ([intFiscalYearId])
);

GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Table Primary Key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLCurrentFiscalYear', @level2type=N'COLUMN',@level2name=N'cntId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fiscal Year Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLCurrentFiscalYear', @level2type=N'COLUMN',@level2name=N'intFiscalYearId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Begin Date' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLCurrentFiscalYear', @level2type=N'COLUMN',@level2name=N'dtmBeginDate' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'End Date' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLCurrentFiscalYear', @level2type=N'COLUMN',@level2name=N'dtmEndDate' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Periods' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLCurrentFiscalYear', @level2type=N'COLUMN',@level2name=N'dblPeriods' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Show All Periods' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLCurrentFiscalYear', @level2type=N'COLUMN',@level2name=N'ysnShowAllPeriods' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Duplicates' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLCurrentFiscalYear', @level2type=N'COLUMN',@level2name=N'ysnDuplicates' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Concurrency Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLCurrentFiscalYear', @level2type=N'COLUMN',@level2name=N'intConcurrencyId' 
GO