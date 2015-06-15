CREATE TABLE [dbo].[tblFRBudgetCode] (
    [intBudgetCode]               INT            IDENTITY (1, 1) NOT NULL,
	[strBudgetCode]               NVARCHAR (150) COLLATE Latin1_General_CI_AS NULL,
	[intFiscalYearId]             INT            NULL,    
    [strBudgetEnglishDescription] NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
	[ysnDefault]                  BIT            DEFAULT ((0)) NULL,    
    [intConcurrencyId]            INT            DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblFRBudgetCode] PRIMARY KEY CLUSTERED ([intBudgetCode] ASC),
	CONSTRAINT [FK_tblFRBudgetCode_tblGLFiscalYear] FOREIGN KEY ([intFiscalYearId]) REFERENCES [dbo].[tblGLFiscalYear] ([intFiscalYearId])
);