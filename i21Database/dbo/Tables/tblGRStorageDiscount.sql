CREATE TABLE [dbo].[tblGRStorageDiscount]
(
	[intStorageDiscountId] INT NOT NULL IDENTITY, 
    [intConcurrencyId] INT NOT NULL, 
    [intCustomerStorageId] INT NOT NULL, 
    [strDiscountCode] NVARCHAR(3) COLLATE Latin1_General_CI_AS NOT NULL,
	[dblGradeReading] DECIMAL(7, 3) NOT NULL, 
    [strCalcMethod] NVARCHAR COLLATE Latin1_General_CI_AS NULL, 
    [dblDiscountAmount] DECIMAL(9, 6) NOT NULL, 
    [strShrinkWhat] NVARCHAR COLLATE Latin1_General_CI_AS NULL, 
    [dblShrinkPercent] DECIMAL(7, 3) NOT NULL,
	[dblDiscountDue] DECIMAL(9, 6) NULL,
	[dblDiscountPaid] DECIMAL(9, 6) NULL, 
    [dtmDiscountPaidDate] DATETIME NULL, 
    CONSTRAINT [PK_tblGRStorageDiscount_intStorageDiscountId] PRIMARY KEY ([intStorageDiscountId]),
	CONSTRAINT [FK_tblGRStorageDiscount_tblGRCustomerStorage_intCustomerStorageId] FOREIGN KEY ([intCustomerStorageId]) REFERENCES [dbo].[tblGRCustomerStorage] ([intCustomerStorageId]) ON DELETE CASCADE, 
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Column',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblGRStorageDiscount',
    @level2type = N'COLUMN',
    @level2name = N'intStorageDiscountId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Column',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblGRStorageDiscount',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Customer Storage Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblGRStorageDiscount',
    @level2type = N'COLUMN',
    @level2name = N'intCustomerStorageId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Discount Paid Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblGRStorageDiscount',
    @level2type = N'COLUMN',
    @level2name = N'dtmDiscountPaidDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Discount Paid',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblGRStorageDiscount',
    @level2type = N'COLUMN',
    @level2name = N'dblDiscountPaid'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Discount Due',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblGRStorageDiscount',
    @level2type = N'COLUMN',
    @level2name = N'dblDiscountDue'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Shrink Percentage',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblGRStorageDiscount',
    @level2type = N'COLUMN',
    @level2name = N'dblShrinkPercent'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Shrink What',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblGRStorageDiscount',
    @level2type = N'COLUMN',
    @level2name = N'strShrinkWhat'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Discount Amount',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblGRStorageDiscount',
    @level2type = N'COLUMN',
    @level2name = N'dblDiscountAmount'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Calc Method',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblGRStorageDiscount',
    @level2type = N'COLUMN',
    @level2name = N'strCalcMethod'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Grade Reading',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblGRStorageDiscount',
    @level2type = N'COLUMN',
    @level2name = N'dblGradeReading'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Discount Code',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblGRStorageDiscount',
    @level2type = N'COLUMN',
    @level2name = N'strDiscountCode'