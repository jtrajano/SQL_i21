CREATE TABLE [dbo].[tblGRDiscountScheduleCode]
(
	[intDiscountScheduleCodeId] INT NOT NULL  IDENTITY, 
    [intDiscountScheduleId] INT NOT NULL, 
    [strDiscountCode] NVARCHAR(3) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strDiscountCodeDescription] NVARCHAR(20) COLLATE Latin1_General_CI_AS NULL, 
    [intDiscountCalculationOptionId] INT NOT NULL DEFAULT 1, 
    [intShrinkCalculationOptionId] INT NOT NULL DEFAULT 1, 
    [ysnZeroIsValid] BIT NOT NULL DEFAULT 1, 
    [dblMinimumValue] NUMERIC(5, 3) NOT NULL DEFAULT 0, 
    [dblMaximumValue] NUMERIC(5, 3) NOT NULL DEFAULT 99.999, 
    [dblDefaultValue] NUMERIC(5, 3) NOT NULL DEFAULT 0, 
	[intPurchaseAccountId] INT NOT NULL,
	[intSalesAccountId]INT NOT NULL,
	[ysnQualityDiscount] BIT NOT NULL DEFAULT 0,
	[ysnDryingDiscount] BIT NOT NULL DEFAULT 0,
	[dtmEffectiveDate] DATETIME NULL,
	[dtmTerminationDate] DATETIME NULL,
    [intConcurrencyId] INT NOT NULL DEFAULT 1, 
    CONSTRAINT [PK_tblGRDiscountScheduleCode_intDiscountScheduleCodeId] PRIMARY KEY ([intDiscountScheduleCodeId]), 
    CONSTRAINT [UK_tblGRDiscountScheduleCode_strDiscountCode] UNIQUE ([strDiscountCode], [intDiscountScheduleId]), 
    CONSTRAINT [FK_tblGRDiscountScheduleCode_tblGRDiscountSchedule_intDiscountScheduleId] FOREIGN KEY ([intDiscountScheduleId]) REFERENCES [tblGRDiscountSchedule]([intDiscountScheduleId]), 
    CONSTRAINT [FK_tblGRDiscountScheduleCode_tblGLAccount_intPurchaseAccountId] FOREIGN KEY ([intPurchaseAccountId]) REFERENCES [tblGLAccount]([intAccountId]), 
    CONSTRAINT [FK_tblGRDiscountScheduleCode_tblGLAccount_intSalesAccountId] FOREIGN KEY ([intSalesAccountId]) REFERENCES [tblGLAccount]([intAccountId]), 
    CONSTRAINT [FK_tblGRDiscountScheduleCode_tblGRDiscountCalculationOption_intValueFieldId_intDiscountCalculationOptionId] FOREIGN KEY ([intDiscountCalculationOptionId]) REFERENCES [tblGRDiscountCalculationOption]([intValueFieldId]),
	CONSTRAINT [FK_tblGRDiscountScheduleCode_tblGRShrinkCalculationOption_intValueFieldId_intShrinkCalculationOptionId] FOREIGN KEY ([intShrinkCalculationOptionId]) REFERENCES [tblGRShrinkCalculationOption]([intValueFieldId])
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Column',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblGRDiscountScheduleCode',
    @level2type = N'COLUMN',
    @level2name = N'intDiscountScheduleCodeId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Discount Schedule Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblGRDiscountScheduleCode',
    @level2type = N'COLUMN',
    @level2name = N'intDiscountScheduleId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Discount Code',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblGRDiscountScheduleCode',
    @level2type = N'COLUMN',
    @level2name = N'strDiscountCode'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Discount Code Description',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblGRDiscountScheduleCode',
    @level2type = N'COLUMN',
    @level2name = N'strDiscountCodeDescription'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Discount Calculation Option',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblGRDiscountScheduleCode',
    @level2type = N'COLUMN',
    @level2name = 'intDiscountCalculationOptionId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Shrink Calculation Option',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblGRDiscountScheduleCode',
    @level2type = N'COLUMN',
    @level2name = 'intShrinkCalculationOptionId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Zero Valid Indicator',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblGRDiscountScheduleCode',
    @level2type = N'COLUMN',
    @level2name = N'ysnZeroIsValid'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Minimum Value',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblGRDiscountScheduleCode',
    @level2type = N'COLUMN',
    @level2name = N'dblMinimumValue'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Maximum Value',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblGRDiscountScheduleCode',
    @level2type = N'COLUMN',
    @level2name = N'dblMaximumValue'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Default Value',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblGRDiscountScheduleCode',
    @level2type = N'COLUMN',
    @level2name = N'dblDefaultValue'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblGRDiscountScheduleCode',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Purchase Account Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblGRDiscountScheduleCode',
    @level2type = N'COLUMN',
    @level2name = 'intPurchaseAccountId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sales Account Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblGRDiscountScheduleCode',
    @level2type = N'COLUMN',
    @level2name = 'intSalesAccountId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Quality Discount Indicator',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblGRDiscountScheduleCode',
    @level2type = N'COLUMN',
    @level2name = N'ysnQualityDiscount'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Drying Discount Indicator',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblGRDiscountScheduleCode',
    @level2type = N'COLUMN',
    @level2name = N'ysnDryingDiscount'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Effective Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblGRDiscountScheduleCode',
    @level2type = N'COLUMN',
    @level2name = N'dtmEffectiveDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Termination Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblGRDiscountScheduleCode',
    @level2type = N'COLUMN',
    @level2name = N'dtmTerminationDate'