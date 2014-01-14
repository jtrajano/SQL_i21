CREATE TABLE [dbo].[tblSMCurrency] (
    [intCurrencyID]       INT             IDENTITY (1, 1) NOT NULL,
    [strCurrency]         NVARCHAR (40)   COLLATE Latin1_General_CI_AS NOT NULL,
    [strDescription]      NVARCHAR (100)  COLLATE Latin1_General_CI_AS NULL,
    [strCheckDescription] NVARCHAR (100)  COLLATE Latin1_General_CI_AS NULL,
    [dblDailyRate]        NUMERIC (18, 6) NULL,
    [dblMinRate]          NUMERIC (18, 6) NULL,
    [dblMaxRate]          NUMERIC (18, 6) NULL,
    [intSort]             INT             NULL,
    [intConcurrencyID]    INT             NULL,
    CONSTRAINT [PK_SMCurrency_CurrencyID] PRIMARY KEY CLUSTERED ([intCurrencyID] ASC), 
    CONSTRAINT [AK_tblSMCurrency_strCurrencyID] UNIQUE ([strCurrency]) 
);

