CREATE TABLE [dbo].[tblGLBudgetCode] (
    [intBudgetCode]               INT            IDENTITY (1, 1) NOT NULL,
    [ysnDefault]                  BIT            CONSTRAINT [DF__tblGLBudg__ysnDe__76818E95] DEFAULT ((0)) NULL,
    [strBudgetCode]               NVARCHAR (40)  COLLATE Latin1_General_CI_AS NULL,
    [strBudgetEnglishDescription] NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId]            INT            NOT NULL DEFAULT 1,
    CONSTRAINT [PK_tblGLBudgetCode] PRIMARY KEY CLUSTERED ([intBudgetCode] ASC)
);

