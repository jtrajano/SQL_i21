CREATE TABLE [dbo].[tblTMBudgetCalculation] (
    [intBudgetCalculationId] INT IDENTITY (1, 1) NOT NULL,
    [intConcurrencyId]       INT NOT NULL, 
    CONSTRAINT [PK_tblTMBudgetCalculation] PRIMARY KEY ([intBudgetCalculationId])
);


GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMBudgetCalculation',
    @level2type = N'COLUMN',
    @level2name = N'intBudgetCalculationId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMBudgetCalculation',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'