CREATE TABLE [dbo].[tblPREarningGroupDetail](
	[intEarningGroupDetailId] [int] IDENTITY(1,1) NOT NULL,
	[intEarningGroupId] INT NOT NULL,
	[intEarningTypeId] INT NOT NULL,
	[strCalculationType] [nvarchar](50) NOT NULL,
	[dblAmount] [numeric](18, 6) NULL DEFAULT ((0)),
	[dblDefaultHours] [numeric](18, 6) NULL DEFAULT ((0)),
	[intAccountId] INT NULL,
	[strW2Code] [nvarchar](50) NULL,
	[ysnCreatePayable] [bit] NULL DEFAULT ((0)),
	[intVendorId] [int] NULL,
	[intSort] [int] NULL,
	[ysnActive] [bit] NOT NULL DEFAULT ((1)),
	[intConcurrencyId] [int] NULL DEFAULT ((1)), 
    CONSTRAINT [PK_tblPREarningGroupDetail] PRIMARY KEY ([intEarningGroupDetailId]), 
    CONSTRAINT [FK_tblPREarningGroupDetail_tblPREarningGroup] FOREIGN KEY ([intEarningGroupId]) REFERENCES [tblPREarningGroup]([intEarningGroupId]) ON DELETE CASCADE, 
    CONSTRAINT [FK_tblPREarningGroupDetail_tblPREarningType] FOREIGN KEY ([intEarningTypeId]) REFERENCES [tblPREarningType]([intEarningTypeId]),
) ON [PRIMARY]
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREarningGroupDetail',
    @level2type = N'COLUMN',
    @level2name = N'intEarningGroupDetailId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Earning Group Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREarningGroupDetail',
    @level2type = N'COLUMN',
    @level2name = N'intEarningGroupId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Earning Type Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREarningGroupDetail',
    @level2type = N'COLUMN',
    @level2name = 'intEarningTypeId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Calculation Type',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREarningGroupDetail',
    @level2type = N'COLUMN',
    @level2name = N'strCalculationType'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Amount',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREarningGroupDetail',
    @level2type = N'COLUMN',
    @level2name = N'dblAmount'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Default Hours',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREarningGroupDetail',
    @level2type = N'COLUMN',
    @level2name = N'dblDefaultHours'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Account Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREarningGroupDetail',
    @level2type = N'COLUMN',
    @level2name = N'intAccountId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'W2 Code',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREarningGroupDetail',
    @level2type = N'COLUMN',
    @level2name = N'strW2Code'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Create Payable',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREarningGroupDetail',
    @level2type = N'COLUMN',
    @level2name = N'ysnCreatePayable'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Vendor Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREarningGroupDetail',
    @level2type = N'COLUMN',
    @level2name = N'intVendorId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREarningGroupDetail',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Active',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREarningGroupDetail',
    @level2type = N'COLUMN',
    @level2name = N'ysnActive'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREarningGroupDetail',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_tblPREarningGroupDetail] ON [dbo].[tblPREarningGroupDetail] ([intEarningGroupId], [intEarningTypeId]) WITH (IGNORE_DUP_KEY = OFF)
