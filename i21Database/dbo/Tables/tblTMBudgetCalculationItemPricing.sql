CREATE TABLE [dbo].[tblTMBudgetCalculationItemPricing]
(
	[intBudgetCalculationItemPricingId] INT  IDENTITY (1, 1) NOT NULL,
	[intConcurrencyId] INT NOT NULL, 
    [intItemId] INT NOT NULL, 
    [dblPrice] NUMERIC(18, 6) NOT NULL, 
    [intBudgetCalculationId] INT NOT NULL, 
    [strItemNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL , 
    CONSTRAINT [PK_tblTMBudgetCalculationItemPricing] PRIMARY KEY CLUSTERED ([intBudgetCalculationItemPricingId] ASC),
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMBudgetCalculationItemPricing',
    @level2type = N'COLUMN',
    @level2name = N'intBudgetCalculationItemPricingId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMBudgetCalculationItemPricing',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Item Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMBudgetCalculationItemPricing',
    @level2type = N'COLUMN',
    @level2name = N'intItemId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Price',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMBudgetCalculationItemPricing',
    @level2type = N'COLUMN',
    @level2name = N'dblPrice'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Budget Calculation Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMBudgetCalculationItemPricing',
    @level2type = N'COLUMN',
    @level2name = N'intBudgetCalculationId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Item Number',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMBudgetCalculationItemPricing',
    @level2type = N'COLUMN',
    @level2name = N'strItemNo'