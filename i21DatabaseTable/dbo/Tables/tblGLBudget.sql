CREATE TABLE [dbo].[tblGLBudget] (
    [intBudgetId]       INT             IDENTITY (1, 1) NOT NULL,
    [intBudgetCode]     INT             NOT NULL,
    [strPeriod]         NVARCHAR (50)   COLLATE Latin1_General_CI_AS NOT NULL,
    [dtmStartDate]      DATETIME        NULL,
    [intFiscalYearId]   INT             NOT NULL,
    [intAccountId]      INT             NOT NULL,
    [intAccountGroupId] INT             NULL,
    [curActual]         NUMERIC (18, 6) NULL,
    [intSort]           INT             NULL,
    [dtmEndDate]        DATETIME        NULL,
    [curThisYear]       NUMERIC (18, 6) NULL,
    [dtmDate]           DATETIME        NOT NULL,
    [curLastYear]       NUMERIC (18, 6) NULL,
    [curBudget]         NUMERIC (18, 6) NULL,
    [curOperPlan]       NUMERIC (18, 6) NULL,
    [intConcurrencyId]  INT             DEFAULT 1 NOT NULL,
    [ysnSelect]         BIT             NULL,
    CONSTRAINT [PK_tblGLBudget] PRIMARY KEY CLUSTERED ([intBudgetId] ASC),
    CONSTRAINT [FK_tblGLBudget_tblGLAccount] FOREIGN KEY ([intAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
    CONSTRAINT [FK_tblGLBudget_tblGLBudgetCode] FOREIGN KEY ([intBudgetCode]) REFERENCES [dbo].[tblGLBudgetCode] ([intBudgetCode]),
    CONSTRAINT [FK_tblGLBudget_tblGLFiscalYear] FOREIGN KEY ([intFiscalYearId]) REFERENCES [dbo].[tblGLFiscalYear] ([intFiscalYearId])
);
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Budget Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLBudget', @level2type=N'COLUMN',@level2name=N'intBudgetId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Budget Code' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLBudget', @level2type=N'COLUMN',@level2name=N'intBudgetCode' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Period' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLBudget', @level2type=N'COLUMN',@level2name=N'strPeriod' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date Start Date' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLBudget', @level2type=N'COLUMN',@level2name=N'dtmStartDate' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fiscal Year Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLBudget', @level2type=N'COLUMN',@level2name=N'intFiscalYearId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Account Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLBudget', @level2type=N'COLUMN',@level2name=N'intAccountId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Account Group Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLBudget', @level2type=N'COLUMN',@level2name=N'intAccountGroupId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Actual' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLBudget', @level2type=N'COLUMN',@level2name=N'curActual' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Sort' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLBudget', @level2type=N'COLUMN',@level2name=N'intSort' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date End Date' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLBudget', @level2type=N'COLUMN',@level2name=N'dtmEndDate' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'This Year' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLBudget', @level2type=N'COLUMN',@level2name=N'curThisYear' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date Date' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLBudget', @level2type=N'COLUMN',@level2name=N'dtmDate' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Last Year' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLBudget', @level2type=N'COLUMN',@level2name=N'curLastYear' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Budget' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLBudget', @level2type=N'COLUMN',@level2name=N'curBudget' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Oper Plan' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLBudget', @level2type=N'COLUMN',@level2name=N'curOperPlan' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Concurrency Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLBudget', @level2type=N'COLUMN',@level2name=N'intConcurrencyId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Select' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLBudget', @level2type=N'COLUMN',@level2name=N'ysnSelect' 
GO

