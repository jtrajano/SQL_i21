CREATE TABLE [dbo].[tblPRTemplateDeduction](
	[intTemplateDeductionId] [int] NOT NULL IDENTITY,
	[intTemplateId] [int] NOT NULL,
	[intTypeDeductionId] INT NOT NULL,
	[strDeductFrom] [nvarchar](50) NULL,
	[strCalculationType] [nvarchar](50) NULL,
	[dblAmount] [numeric](18, 6) NOT NULL DEFAULT ((0)),
	[dblLimit] [numeric](18, 6) NOT NULL DEFAULT ((0)),
	[dtmBeginDate] [datetime] NULL,
	[dtmEndDate] [datetime] NULL,
	[intAccountId] INT NULL,
	[strPaidBy] [nvarchar](15) NOT NULL DEFAULT ('Employee'),
	[ysnDefault] [bit] NOT NULL DEFAULT ((1)), 
	[intSort] [int] NULL,
	[intConcurrencyId] [int] NULL DEFAULT ((1)),
    CONSTRAINT [PK_tblPRTemplateDeduction] PRIMARY KEY ([intTemplateDeductionId]), 
    CONSTRAINT [FK_tblPRTemplateDeduction_tblPRTypeDeduction] FOREIGN KEY ([intTypeDeductionId]) REFERENCES [tblPRTypeDeduction]([intTypeDeductionId]),
) ON [PRIMARY]
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateDeduction',
    @level2type = N'COLUMN',
    @level2name = N'intTemplateDeductionId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Deduction Type Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateDeduction',
    @level2type = N'COLUMN',
    @level2name = 'intTypeDeductionId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Deduct From',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateDeduction',
    @level2type = N'COLUMN',
    @level2name = N'strDeductFrom'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Calculation Type',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateDeduction',
    @level2type = N'COLUMN',
    @level2name = N'strCalculationType'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Amount',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateDeduction',
    @level2type = N'COLUMN',
    @level2name = N'dblAmount'
GO

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Limit',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateDeduction',
    @level2type = N'COLUMN',
    @level2name = N'dblLimit'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Begin Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateDeduction',
    @level2type = N'COLUMN',
    @level2name = N'dtmBeginDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'End Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateDeduction',
    @level2type = N'COLUMN',
    @level2name = N'dtmEndDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Account Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateDeduction',
    @level2type = N'COLUMN',
    @level2name = N'intAccountId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Paid By',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateDeduction',
    @level2type = N'COLUMN',
    @level2name = N'strPaidBy'
GO

GO

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateDeduction',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Default',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateDeduction',
    @level2type = N'COLUMN',
    @level2name = 'ysnDefault'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateDeduction',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO
EXEC sp_addextendedproperty @name=N'MS_Description',
	@value = N'Deduction Type is used in Deduction Group s' ,
	@level0type = N'SCHEMA',
	@level0name = N'dbo', 
	@level1type = N'TABLE',
	@level1name = N'tblPRTypeDeduction', 
	@level2type = N'CONSTRAINT',
	@level2name = N'FK_tblPRTemplateDeduction_tblPRTypeDeduction'
GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_tblPRTemplateDeduction] ON [dbo].[tblPRTemplateDeduction] ([intTemplateDeductionId], [intTypeDeductionId]) WITH (IGNORE_DUP_KEY = OFF)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Employee Template Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateDeduction',
    @level2type = N'COLUMN',
    @level2name = N'intTemplateId'