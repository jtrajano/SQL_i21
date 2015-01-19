CREATE TABLE [dbo].[tblGRDiscountId]
(
	[intDiscountId] INT NOT NULL IDENTITY, 
    [intCurrencyId] INT NOT NULL, 
    [strDiscountId] NVARCHAR(3) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strDiscountDescription] NVARCHAR(30) COLLATE Latin1_General_CI_AS NOT NULL, 
    [ysnDiscountIdActive] BIT NOT NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT 1, 
    CONSTRAINT [PK_tblGRDiscountId_intDiscountId] PRIMARY KEY ([intDiscountId]), 
    CONSTRAINT [FK_tblGRDiscountId_tblSMCurrency_intCurrencyId] FOREIGN KEY ([intCurrencyId]) REFERENCES [tblSMCurrency]([intCurrencyID]), 
    CONSTRAINT [UK_tblGRDiscountId_strDiscountId_intCurrencyId] UNIQUE ([strDiscountId], [intCurrencyId]) 
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Currency Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblGRDiscountId',
    @level2type = N'COLUMN',
    @level2name = N'intCurrencyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblGRDiscountId',
    @level2type = N'COLUMN',
    @level2name = N'intDiscountId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Discount Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblGRDiscountId',
    @level2type = N'COLUMN',
    @level2name = 'strDiscountId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Discount Description',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblGRDiscountId',
    @level2type = N'COLUMN',
    @level2name = N'strDiscountDescription'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Discount Active Indicator',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblGRDiscountId',
    @level2type = N'COLUMN',
    @level2name = N'ysnDiscountIdActive'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblGRDiscountId',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'