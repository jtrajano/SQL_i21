CREATE TABLE [dbo].[tblSMCurrency] (
    [intCurrencyID]       INT             IDENTITY (1, 1) NOT NULL,
    [strCurrency]         NVARCHAR (40)   COLLATE Latin1_General_CI_AS NOT NULL,
    [strDescription]      NVARCHAR (100)  COLLATE Latin1_General_CI_AS NULL,
    [strCheckDescription] NVARCHAR (100)  COLLATE Latin1_General_CI_AS NULL,
    [dblDailyRate]        NUMERIC (18, 6) NULL,
    [dblMinRate]          NUMERIC (18, 6) NULL,
    [dblMaxRate]          NUMERIC (18, 6) NULL,
    [intSort]             INT             NULL,
    [intConcurrencyId]    INT             DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_SMCurrency_CurrencyID] PRIMARY KEY CLUSTERED ([intCurrencyID] ASC),
    CONSTRAINT [AK_tblSMCurrency_strCurrencyID] UNIQUE NONCLUSTERED ([strCurrency] ASC)
);


GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCurrency',
    @level2type = N'COLUMN',
    @level2name = N'intCurrencyID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Currency Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCurrency',
    @level2type = N'COLUMN',
    @level2name = N'strCurrency'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Description',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCurrency',
    @level2type = N'COLUMN',
    @level2name = N'strDescription'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Check Description',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCurrency',
    @level2type = N'COLUMN',
    @level2name = N'strCheckDescription'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Daily Rate',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCurrency',
    @level2type = N'COLUMN',
    @level2name = N'dblDailyRate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Minimum Rate',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCurrency',
    @level2type = N'COLUMN',
    @level2name = N'dblMinRate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Maximum Rate',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCurrency',
    @level2type = N'COLUMN',
    @level2name = N'dblMaxRate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCurrency',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCurrency',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'