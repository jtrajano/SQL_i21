CREATE TABLE [dbo].[tblTMBudgetCalculationSite] (
    [intBudgetCalculationSiteId] INT             IDENTITY (1, 1) NOT NULL,
    [intConcurrencyId]     INT NOT NULL,
    [dblSeasonExpectedUsage] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
    [dblRequiredQuantity] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
    [dblPrice] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
    [dblEstimatedBudget] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
    [intSiteId] INT NOT NULL, 
    [intBudgetCalculationId] INT NOT NULL, 
    CONSTRAINT [PK_tblTMBudgetCalculationSite] PRIMARY KEY CLUSTERED ([intBudgetCalculationSiteId] ASC)
);


GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Season Expected Usage',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMBudgetCalculationSite',
    @level2type = N'COLUMN',
    @level2name = N'dblSeasonExpectedUsage'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMBudgetCalculationSite',
    @level2type = N'COLUMN',
    @level2name = 'intBudgetCalculationSiteId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Required Quantity',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMBudgetCalculationSite',
    @level2type = N'COLUMN',
    @level2name = N'dblRequiredQuantity'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Price',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMBudgetCalculationSite',
    @level2type = N'COLUMN',
    @level2name = 'dblPrice'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMBudgetCalculationSite',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Estimated Budget',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMBudgetCalculationSite',
    @level2type = N'COLUMN',
    @level2name = N'dblEstimatedBudget'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Site Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMBudgetCalculationSite',
    @level2type = N'COLUMN',
    @level2name = N'intSiteId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Budget Calculation Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMBudgetCalculationSite',
    @level2type = N'COLUMN',
    @level2name = N'intBudgetCalculationId'