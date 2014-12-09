CREATE TABLE [dbo].[tblPRTemplateTax](
	[intTemplateTaxId] [int] IDENTITY(1,1) NOT NULL,
	[intTemplateId] [int] NOT NULL,
	[intTypeTaxId] INT NOT NULL,
	[strCalculationType] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strFilingStatus] [nvarchar](25) COLLATE Latin1_General_CI_AS NULL,
	[intTypeTaxStateId] INT NULL,
	[intTypeTaxLocalId] INT NULL,
	[dblAmount] [numeric](18, 6) NULL DEFAULT ((0)),
	[dblExtraWithholding] [numeric](18, 6) NULL DEFAULT ((0)),
	[dblLimit] [numeric](18, 6) NULL DEFAULT ((0)),
	[intAccountId] INT NULL,
	[intExpenseAccountId] INT NULL,
	[intAllowance] [int] NULL DEFAULT ((0)),
	[strPaidBy] [nvarchar](10) COLLATE Latin1_General_CI_AS NULL,
	[strVal1] [nvarchar](5) COLLATE Latin1_General_CI_AS NULL,
	[strVal2] [nvarchar](5) COLLATE Latin1_General_CI_AS NULL,
	[strVal3] [nvarchar](5) COLLATE Latin1_General_CI_AS NULL,
	[strVal4] [nvarchar](5) COLLATE Latin1_General_CI_AS NULL,
	[strVal5] [nvarchar](5) COLLATE Latin1_General_CI_AS NULL,
	[strVal6] [nvarchar](5) COLLATE Latin1_General_CI_AS NULL,
	[ysnDefault] [bit] NULL DEFAULT ((1)),
	[intSort] [int] NULL,
	[intConcurrencyId] [int] NULL DEFAULT ((1)), 
    CONSTRAINT [PK_tblPRTemplateTax] PRIMARY KEY ([intTemplateTaxId]), 
    CONSTRAINT [FK_tblPRTemplateTax_tblPREmployee] FOREIGN KEY ([intTemplateId]) REFERENCES [tblPRTemplate]([intTemplateId]), 
    CONSTRAINT [FK_tblPRTemplateTax_tblPRTypeTax] FOREIGN KEY ([intTypeTaxId]) REFERENCES [tblPRTypeTax]([intTypeTaxId]),
) ON [PRIMARY]
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateTax',
    @level2type = N'COLUMN',
    @level2name = N'intTemplateTaxId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Template Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateTax',
    @level2type = N'COLUMN',
    @level2name = N'intTemplateId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Tax Type Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateTax',
    @level2type = N'COLUMN',
    @level2name = N'intTypeTaxId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Calculation Type',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateTax',
    @level2type = N'COLUMN',
    @level2name = N'strCalculationType'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Filing Status',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateTax',
    @level2type = N'COLUMN',
    @level2name = N'strFilingStatus'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Tax Type State Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateTax',
    @level2type = N'COLUMN',
    @level2name = N'intTypeTaxStateId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Tax Type Locality Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateTax',
    @level2type = N'COLUMN',
    @level2name = N'intTypeTaxLocalId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Amount',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateTax',
    @level2type = N'COLUMN',
    @level2name = N'dblAmount'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Extra Withholding',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateTax',
    @level2type = N'COLUMN',
    @level2name = N'dblExtraWithholding'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Limit',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateTax',
    @level2type = N'COLUMN',
    @level2name = N'dblLimit'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Liability Account',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateTax',
    @level2type = N'COLUMN',
    @level2name = N'intAccountId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Expense Account',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateTax',
    @level2type = N'COLUMN',
    @level2name = N'intExpenseAccountId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Federal Allowances',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateTax',
    @level2type = N'COLUMN',
    @level2name = N'intAllowance'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Paid By',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateTax',
    @level2type = N'COLUMN',
    @level2name = N'strPaidBy'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Holder for extra value 1',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateTax',
    @level2type = N'COLUMN',
    @level2name = N'strVal1'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Holder for extra value 2',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateTax',
    @level2type = N'COLUMN',
    @level2name = N'strVal2'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Holder for extra value 3',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateTax',
    @level2type = N'COLUMN',
    @level2name = N'strVal3'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Holder for extra value 4',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateTax',
    @level2type = N'COLUMN',
    @level2name = N'strVal4'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Holder for extra value 5',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateTax',
    @level2type = N'COLUMN',
    @level2name = N'strVal5'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Holder for extra value 6',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateTax',
    @level2type = N'COLUMN',
    @level2name = N'strVal6'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Default',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateTax',
    @level2type = N'COLUMN',
    @level2name = N'ysnDefault'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateTax',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateTax',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'