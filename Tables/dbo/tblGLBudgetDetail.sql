CREATE TABLE [dbo].[tblGLBudgetDetail] (
    [cntId]            INT             IDENTITY (1, 1) NOT NULL,
    [strAccountId]     NVARCHAR (40)   COLLATE Latin1_General_CI_AS NOT NULL,
    [dtmYear]          DATETIME        NOT NULL,
    [curLastYear01]    NUMERIC (18, 6) NULL,
    [curLastYear02]    NUMERIC (18, 6) NULL,
    [curLastYear03]    NUMERIC (18, 6) NULL,
    [curLastYear04]    NUMERIC (18, 6) NULL,
    [curLastYear05]    NUMERIC (18, 6) NULL,
    [curLastYear06]    NUMERIC (18, 6) NULL,
    [curLastYear07]    NUMERIC (18, 6) NULL,
    [curLastYear08]    NUMERIC (18, 6) NULL,
    [curLastYear09]    NUMERIC (18, 6) NULL,
    [curLastYear10]    NUMERIC (18, 6) NULL,
    [curLastYear11]    NUMERIC (18, 6) NULL,
    [curLastYear12]    NUMERIC (18, 6) NULL,
    [curThisYear01]    NUMERIC (18, 6) NULL,
    [curThisYear02]    NUMERIC (18, 6) NULL,
    [curThisYear03]    NUMERIC (18, 6) NULL,
    [curThisYear04]    NUMERIC (18, 6) NULL,
    [curThisYear05]    NUMERIC (18, 6) NULL,
    [curThisYear06]    NUMERIC (18, 6) NULL,
    [curThisYear07]    NUMERIC (18, 6) NULL,
    [curThisYear08]    NUMERIC (18, 6) NULL,
    [curThisYear09]    NUMERIC (18, 6) NULL,
    [curThisYear10]    NUMERIC (18, 6) NULL,
    [curThisYear11]    NUMERIC (18, 6) NULL,
    [curThisYear12]    NUMERIC (18, 6) NULL,
    [curBudget01]      NUMERIC (18, 6) NULL,
    [curBudget02]      NUMERIC (18, 6) NULL,
    [curBudget03]      NUMERIC (18, 6) NULL,
    [curBudget04]      NUMERIC (18, 6) NULL,
    [curBudget05]      NUMERIC (18, 6) NULL,
    [curBudget06]      NUMERIC (18, 6) NULL,
    [curBudget07]      NUMERIC (18, 6) NULL,
    [curBudget08]      NUMERIC (18, 6) NULL,
    [curBudget09]      NUMERIC (18, 6) NULL,
    [curBudget10]      NUMERIC (18, 6) NULL,
    [curBudget11]      NUMERIC (18, 6) NULL,
    [curBudget12]      NUMERIC (18, 6) NULL,
    [curOperPlan01]    NUMERIC (18, 6) NULL,
    [curOperPlan02]    NUMERIC (18, 6) NULL,
    [curOperPlan03]    NUMERIC (18, 6) NULL,
    [curOperPlan04]    NUMERIC (18, 6) NULL,
    [curOperPlan05]    NUMERIC (18, 6) NULL,
    [curOperPlan06]    NUMERIC (18, 6) NULL,
    [curOperPlan07]    NUMERIC (18, 6) NULL,
    [curOperPlan08]    NUMERIC (18, 6) NULL,
    [curOperPlan09]    NUMERIC (18, 6) NULL,
    [curOperPlan10]    NUMERIC (18, 6) NULL,
    [curOperPlan11]    NUMERIC (18, 6) NULL,
    [curOperPlan12]    NUMERIC (18, 6) NULL,
    [intConcurrencyId] INT             DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblGLBudgetDetail] PRIMARY KEY CLUSTERED ([strAccountId] ASC, [dtmYear] ASC)
);

GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'cnt Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLBudgetDetail', @level2type=N'COLUMN',@level2name=N'cntId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Account Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLBudgetDetail', @level2type=N'COLUMN',@level2name=N'strAccountId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Year' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLBudgetDetail', @level2type=N'COLUMN',@level2name=N'dtmYear' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Last Year01' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLBudgetDetail', @level2type=N'COLUMN',@level2name=N'curLastYear01' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Last Year02' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLBudgetDetail', @level2type=N'COLUMN',@level2name=N'curLastYear02' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Last Year03' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLBudgetDetail', @level2type=N'COLUMN',@level2name=N'curLastYear03' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Last Year04' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLBudgetDetail', @level2type=N'COLUMN',@level2name=N'curLastYear04' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Last Year05' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLBudgetDetail', @level2type=N'COLUMN',@level2name=N'curLastYear05' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Last Year06' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLBudgetDetail', @level2type=N'COLUMN',@level2name=N'curLastYear06' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Last Year07' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLBudgetDetail', @level2type=N'COLUMN',@level2name=N'curLastYear07' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Last Year08' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLBudgetDetail', @level2type=N'COLUMN',@level2name=N'curLastYear08' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Last Year09' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLBudgetDetail', @level2type=N'COLUMN',@level2name=N'curLastYear09' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Last Year10' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLBudgetDetail', @level2type=N'COLUMN',@level2name=N'curLastYear10' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Last Year11' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLBudgetDetail', @level2type=N'COLUMN',@level2name=N'curLastYear11' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Last Year12' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLBudgetDetail', @level2type=N'COLUMN',@level2name=N'curLastYear12' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'This Year01' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLBudgetDetail', @level2type=N'COLUMN',@level2name=N'curThisYear01' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'This Year02' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLBudgetDetail', @level2type=N'COLUMN',@level2name=N'curThisYear02' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'This Year03' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLBudgetDetail', @level2type=N'COLUMN',@level2name=N'curThisYear03' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'This Year04' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLBudgetDetail', @level2type=N'COLUMN',@level2name=N'curThisYear04' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'This Year05' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLBudgetDetail', @level2type=N'COLUMN',@level2name=N'curThisYear05' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'This Year06' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLBudgetDetail', @level2type=N'COLUMN',@level2name=N'curThisYear06' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'This Year07' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLBudgetDetail', @level2type=N'COLUMN',@level2name=N'curThisYear07' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'This Year08' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLBudgetDetail', @level2type=N'COLUMN',@level2name=N'curThisYear08' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'This Year09' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLBudgetDetail', @level2type=N'COLUMN',@level2name=N'curThisYear09' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'This Year10' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLBudgetDetail', @level2type=N'COLUMN',@level2name=N'curThisYear10' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'This Year11' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLBudgetDetail', @level2type=N'COLUMN',@level2name=N'curThisYear11' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'This Year12' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLBudgetDetail', @level2type=N'COLUMN',@level2name=N'curThisYear12' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Budget01' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLBudgetDetail', @level2type=N'COLUMN',@level2name=N'curBudget01' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Budget02' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLBudgetDetail', @level2type=N'COLUMN',@level2name=N'curBudget02' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Budget03' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLBudgetDetail', @level2type=N'COLUMN',@level2name=N'curBudget03' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Budget04' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLBudgetDetail', @level2type=N'COLUMN',@level2name=N'curBudget04' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Budget05' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLBudgetDetail', @level2type=N'COLUMN',@level2name=N'curBudget05' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Budget06' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLBudgetDetail', @level2type=N'COLUMN',@level2name=N'curBudget06' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Budget07' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLBudgetDetail', @level2type=N'COLUMN',@level2name=N'curBudget07' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Budget08' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLBudgetDetail', @level2type=N'COLUMN',@level2name=N'curBudget08' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Budget09' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLBudgetDetail', @level2type=N'COLUMN',@level2name=N'curBudget09' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Budget10' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLBudgetDetail', @level2type=N'COLUMN',@level2name=N'curBudget10' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Budget11' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLBudgetDetail', @level2type=N'COLUMN',@level2name=N'curBudget11' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Budget12' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLBudgetDetail', @level2type=N'COLUMN',@level2name=N'curBudget12' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Oper Plan01' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLBudgetDetail', @level2type=N'COLUMN',@level2name=N'curOperPlan01' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Oper Plan02' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLBudgetDetail', @level2type=N'COLUMN',@level2name=N'curOperPlan02' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Oper Plan03' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLBudgetDetail', @level2type=N'COLUMN',@level2name=N'curOperPlan03' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Oper Plan04' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLBudgetDetail', @level2type=N'COLUMN',@level2name=N'curOperPlan04' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Oper Plan05' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLBudgetDetail', @level2type=N'COLUMN',@level2name=N'curOperPlan05' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Oper Plan06' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLBudgetDetail', @level2type=N'COLUMN',@level2name=N'curOperPlan06' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Oper Plan07' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLBudgetDetail', @level2type=N'COLUMN',@level2name=N'curOperPlan07' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Oper Plan08' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLBudgetDetail', @level2type=N'COLUMN',@level2name=N'curOperPlan08' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Oper Plan09' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLBudgetDetail', @level2type=N'COLUMN',@level2name=N'curOperPlan09' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Oper Plan10' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLBudgetDetail', @level2type=N'COLUMN',@level2name=N'curOperPlan10' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Oper Plan11' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLBudgetDetail', @level2type=N'COLUMN',@level2name=N'curOperPlan11' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Oper Plan12' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLBudgetDetail', @level2type=N'COLUMN',@level2name=N'curOperPlan12' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Concurrency Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLBudgetDetail', @level2type=N'COLUMN',@level2name=N'intConcurrencyId' 
GO