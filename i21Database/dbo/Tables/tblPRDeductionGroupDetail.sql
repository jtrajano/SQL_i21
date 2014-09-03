CREATE TABLE [dbo].[tblPRDeductionGroupDetail](
	[intDeductionGroupDetailId] [int] NOT NULL IDENTITY,
	[intDeductionGroupId] [int] NOT NULL,
	[intDeductionTypeId] INT NOT NULL,
	[strDeductFrom] [nvarchar](50) NULL,
	[strCalculationType] [nvarchar](50) NULL,
	[dblAmount] [numeric](18, 6) NOT NULL DEFAULT ((0)),
	[dblPercent] [numeric](18, 6) NOT NULL DEFAULT ((0)),
	[dblLimit] [numeric](18, 6) NOT NULL DEFAULT ((0)),
	[dtmBeginDate] [datetime] NULL,
	[dtmEndDate] [datetime] NULL,
	[intAccountId] INT NULL,
	[strPaidBy] [nvarchar](50) NOT NULL DEFAULT ('Employee'),
	[ysnCreatePayable] [bit] NULL DEFAULT ((0)),
	[intVendorId] [int] NULL,
	[intSort] [int] NULL,
	[ysnActive] [bit] NOT NULL DEFAULT ((1)), 
	[intConcurrencyId] [int] NULL DEFAULT ((1)),
    CONSTRAINT [PK_tblPRDeductionGroupDetail] PRIMARY KEY ([intDeductionGroupDetailId]), 
    CONSTRAINT [FK_tblPRDeductionGroupDetail_tblPRDeductionGroup] FOREIGN KEY ([intDeductionGroupId]) REFERENCES [tblPRDeductionGroup]([intDeductionGroupId]) ON DELETE CASCADE, 
    CONSTRAINT [FK_tblPRDeductionGroupDetail_tblPRDeductionType] FOREIGN KEY ([intDeductionTypeId]) REFERENCES [tblPRDeductionType]([intDeductionTypeId]),
) ON [PRIMARY]
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRDeductionGroupDetail',
    @level2type = N'COLUMN',
    @level2name = N'intDeductionGroupDetailId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Deduction Group Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRDeductionGroupDetail',
    @level2type = N'COLUMN',
    @level2name = N'intDeductionGroupId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Deduction Type Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRDeductionGroupDetail',
    @level2type = N'COLUMN',
    @level2name = 'intDeductionTypeId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Deduct From',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRDeductionGroupDetail',
    @level2type = N'COLUMN',
    @level2name = N'strDeductFrom'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Calculation Type',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRDeductionGroupDetail',
    @level2type = N'COLUMN',
    @level2name = N'strCalculationType'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Amount',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRDeductionGroupDetail',
    @level2type = N'COLUMN',
    @level2name = N'dblAmount'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Percent',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRDeductionGroupDetail',
    @level2type = N'COLUMN',
    @level2name = N'dblPercent'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Limit',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRDeductionGroupDetail',
    @level2type = N'COLUMN',
    @level2name = N'dblLimit'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Begin Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRDeductionGroupDetail',
    @level2type = N'COLUMN',
    @level2name = N'dtmBeginDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'End Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRDeductionGroupDetail',
    @level2type = N'COLUMN',
    @level2name = N'dtmEndDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Account Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRDeductionGroupDetail',
    @level2type = N'COLUMN',
    @level2name = N'intAccountId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Paid By',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRDeductionGroupDetail',
    @level2type = N'COLUMN',
    @level2name = N'strPaidBy'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Create Payable',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRDeductionGroupDetail',
    @level2type = N'COLUMN',
    @level2name = N'ysnCreatePayable'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Vendor Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRDeductionGroupDetail',
    @level2type = N'COLUMN',
    @level2name = N'intVendorId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRDeductionGroupDetail',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Active',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRDeductionGroupDetail',
    @level2type = N'COLUMN',
    @level2name = N'ysnActive'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRDeductionGroupDetail',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO
EXEC sp_addextendedproperty @name=N'MS_Description',
	@value = N'Deduction Group is used in Deduction Group Details' ,
	@level0type = N'SCHEMA',
	@level0name = N'dbo', 
	@level1type = N'TABLE',
	@level1name = N'tblPRDeductionGroup', 
	@level2type = N'CONSTRAINT',
	@level2name = N'FK_tblPRDeductionGroupDetail_tblPRDeductionGroup'
GO
EXEC sp_addextendedproperty @name=N'MS_Description',
	@value = N'Deduction Type is used in Deduction Group Details' ,
	@level0type = N'SCHEMA',
	@level0name = N'dbo', 
	@level1type = N'TABLE',
	@level1name = N'tblPRDeductionType', 
	@level2type = N'CONSTRAINT',
	@level2name = N'FK_tblPRDeductionGroupDetail_tblPRDeductionType'
GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_tblPRDeductionGroupDetail] ON [dbo].[tblPRDeductionGroupDetail] ([intDeductionGroupId], [intDeductionTypeId]) WITH (IGNORE_DUP_KEY = OFF)
