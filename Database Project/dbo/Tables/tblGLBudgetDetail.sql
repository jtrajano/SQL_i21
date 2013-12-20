﻿CREATE TABLE [dbo].[tblGLBudgetDetail] (
    [cntID]            INT             IDENTITY (1, 1) NOT NULL,
    [strAccountID]     NVARCHAR (40)   COLLATE Latin1_General_CI_AS NOT NULL,
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
    [intConcurrencyID] INT             NULL,
    CONSTRAINT [PK_tblGLBudgetDetail] PRIMARY KEY CLUSTERED ([strAccountID] ASC, [dtmYear] ASC)
);

