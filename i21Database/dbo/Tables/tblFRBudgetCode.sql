CREATE TABLE [dbo].[tblFRBudgetCode] (
    [intBudgetCode]               INT            IDENTITY (1, 1) NOT NULL,
    [ysnDefault]                  BIT            DEFAULT ((0)) NULL,
    [strBudgetCode]               NVARCHAR (40)  COLLATE Latin1_General_CI_AS NULL,
    [strBudgetEnglishDescription] NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId]            INT            DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblFRBudgetCode] PRIMARY KEY CLUSTERED ([intBudgetCode] ASC)
);

