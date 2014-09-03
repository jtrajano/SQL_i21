CREATE TABLE [dbo].[tblPREmployeeTax](
	[intEmployeeTaxId] [int] NOT NULL IDENTITY,
	[intEmployeeId] INT NOT NULL,
	[intTaxTypeId] INT NOT NULL,
	[strCalculationType] [nvarchar](50) NULL,
	[dblAmount] [numeric](18, 6) NULL DEFAULT ((0)),
	[dblPercent] [numeric](18, 6) NULL DEFAULT ((0)),
	[dblLimit] [numeric](18, 6) NULL DEFAULT ((0)),
	[intTaxTypeStateId] INT NULL,
	[intTaxTypeCountyId] INT NULL,
	[intAccountId] INT NULL,
	[dblExtraWithholding] [numeric](18, 6) NULL DEFAULT ((0)),
	[strFilingStatus] [nvarchar](25) NULL,
	[intAllowance] [int] NULL DEFAULT ((0)),
	[strVal1] [nvarchar](5) NULL,
	[strVal2] [nvarchar](5) NULL,
	[strVal3] [nvarchar](5) NULL,
	[strVal4] [nvarchar](5) NULL,
	[ysnActive] [bit] NULL DEFAULT ((1)),
	[strType] [nvarchar](10) NULL,
	[intExpenseAccountId] INT NULL,
	[strPaidBy] [nvarchar](10) NULL,
	[intSort] [int] NULL,
	[intConcurrencyId] [int] NULL DEFAULT ((1)), 
    CONSTRAINT [PK_tblPREmployeeTax] PRIMARY KEY ([intEmployeeTaxId]), 
    CONSTRAINT [FK_tblPREmployeeTax_tblPREmployee] FOREIGN KEY ([intEmployeeId]) REFERENCES [tblPREmployee]([intEmployeeId]), 
    CONSTRAINT [FK_tblPREmployeeTax_tblPRTaxType] FOREIGN KEY ([intTaxTypeId]) REFERENCES [tblPRTaxType]([intTaxTypeId]),
) ON [PRIMARY]
GO


CREATE UNIQUE NONCLUSTERED INDEX [IX_tblPREmployeeTax] ON [dbo].[tblPREmployeeTax] ([intEmployeeId], [intTaxTypeId]) WITH (IGNORE_DUP_KEY = OFF)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeTax',
    @level2type = N'COLUMN',
    @level2name = N'intEmployeeTaxId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Employee Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeTax',
    @level2type = N'COLUMN',
    @level2name = N'intEmployeeId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Tax Type Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeTax',
    @level2type = N'COLUMN',
    @level2name = N'intTaxTypeId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Calculation Type',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeTax',
    @level2type = N'COLUMN',
    @level2name = N'strCalculationType'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Amount',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeTax',
    @level2type = N'COLUMN',
    @level2name = N'dblAmount'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Percent',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeTax',
    @level2type = N'COLUMN',
    @level2name = N'dblPercent'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Limit',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeTax',
    @level2type = N'COLUMN',
    @level2name = N'dblLimit'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Tax Type State Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeTax',
    @level2type = N'COLUMN',
    @level2name = N'intTaxTypeStateId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Tax Type County Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeTax',
    @level2type = N'COLUMN',
    @level2name = N'intTaxTypeCountyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Account Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeTax',
    @level2type = N'COLUMN',
    @level2name = N'intAccountId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Extra Withholding',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeTax',
    @level2type = N'COLUMN',
    @level2name = N'dblExtraWithholding'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Filing Status',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeTax',
    @level2type = N'COLUMN',
    @level2name = N'strFilingStatus'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Allowance',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeTax',
    @level2type = N'COLUMN',
    @level2name = N'intAllowance'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Holder for extra value 1',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeTax',
    @level2type = N'COLUMN',
    @level2name = N'strVal1'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Holder for extra value 2',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeTax',
    @level2type = N'COLUMN',
    @level2name = N'strVal2'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Holder for extra value 3',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeTax',
    @level2type = N'COLUMN',
    @level2name = N'strVal3'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Holder for extra value 4',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeTax',
    @level2type = N'COLUMN',
    @level2name = N'strVal4'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Active',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeTax',
    @level2type = N'COLUMN',
    @level2name = N'ysnActive'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Type',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeTax',
    @level2type = N'COLUMN',
    @level2name = N'strType'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Expense Account Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeTax',
    @level2type = N'COLUMN',
    @level2name = N'intExpenseAccountId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Paid By',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeTax',
    @level2type = N'COLUMN',
    @level2name = N'strPaidBy'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeTax',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeTax',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'