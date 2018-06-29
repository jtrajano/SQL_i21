CREATE TABLE [dbo].[tblTMBudgetCalculationProjection]
(
	[intBudgetCalculationProjectionId] INT  IDENTITY (1, 1) NOT NULL,
	[intConcurrencyId] INT NOT NULL, 
    [intClockId] INT NOT NULL, 
    [intProjectedDegreeDay] INT NOT NULL DEFAULT 0, 
    [intBudgetCalculationId] INT NOT NULL, 
    CONSTRAINT [PK_tblTMBudgetCalculationProjection] PRIMARY KEY CLUSTERED ([intBudgetCalculationProjectionId] ASC),
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMBudgetCalculationProjection',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMBudgetCalculationProjection',
    @level2type = N'COLUMN',
    @level2name = N'intBudgetCalculationProjectionId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Clock Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMBudgetCalculationProjection',
    @level2type = N'COLUMN',
    @level2name = N'intClockId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Projected Degree Day',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMBudgetCalculationProjection',
    @level2type = N'COLUMN',
    @level2name = N'intProjectedDegreeDay'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Budget Calculation Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMBudgetCalculationProjection',
    @level2type = N'COLUMN',
    @level2name = N'intBudgetCalculationId'