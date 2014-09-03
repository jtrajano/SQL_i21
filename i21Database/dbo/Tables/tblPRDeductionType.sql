CREATE TABLE [dbo].[tblPRDeductionType](
	[intDeductionTypeId] [int] IDENTITY(1,1) NOT NULL,
	[strDeduction] [nvarchar](50) NOT NULL,
	[strDescription] [nvarchar](50) NULL,
	[strCheckLiteral] [nvarchar](50) NULL,
	[intAccountId] INT NULL,
	[strDeductFrom] [nvarchar](50) NULL,
	[strCalculationType] [nvarchar](50) NULL,
	[dblAmount] [numeric](18, 6) NULL DEFAULT ((0)),
	[dblPercent] [numeric](18, 6) NULL DEFAULT ((0)),
	[dblLimit] [numeric](18, 6) NULL DEFAULT ((0)),
	[strPaidBy] [nvarchar](50) NULL DEFAULT ('Employee'),
	[ysnCreatePayable] [bit] NULL DEFAULT ((0)),
	[intVendorId] [int] NULL,
	[intSort] [int] NULL,
	[intConcurrencyId] [int] NULL DEFAULT ((1)), 
    CONSTRAINT [PK_tblPRDeductionType] PRIMARY KEY ([intDeductionTypeId]), 
    CONSTRAINT [AK_tblPRDeductionType_strDeduction] UNIQUE ([strDeduction]) 
) ON [PRIMARY]
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRDeductionType',
    @level2type = N'COLUMN',
    @level2name = N'intDeductionTypeId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Deduction Type Name',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRDeductionType',
    @level2type = N'COLUMN',
    @level2name = N'strDeduction'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Description',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRDeductionType',
    @level2type = N'COLUMN',
    @level2name = N'strDescription'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Check Literal',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRDeductionType',
    @level2type = N'COLUMN',
    @level2name = N'strCheckLiteral'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Account Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRDeductionType',
    @level2type = N'COLUMN',
    @level2name = N'intAccountId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Deduct From',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRDeductionType',
    @level2type = N'COLUMN',
    @level2name = N'strDeductFrom'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Calculation Type',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRDeductionType',
    @level2type = N'COLUMN',
    @level2name = N'strCalculationType'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Amount',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRDeductionType',
    @level2type = N'COLUMN',
    @level2name = N'dblAmount'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Percent',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRDeductionType',
    @level2type = N'COLUMN',
    @level2name = N'dblPercent'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Limit',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRDeductionType',
    @level2type = N'COLUMN',
    @level2name = N'dblLimit'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Paid By',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRDeductionType',
    @level2type = N'COLUMN',
    @level2name = N'strPaidBy'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Create Payable',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRDeductionType',
    @level2type = N'COLUMN',
    @level2name = N'ysnCreatePayable'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Vendor Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRDeductionType',
    @level2type = N'COLUMN',
    @level2name = N'intVendorId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRDeductionType',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRDeductionType',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'