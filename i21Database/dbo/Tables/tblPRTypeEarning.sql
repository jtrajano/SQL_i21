CREATE TABLE [dbo].[tblPRTypeEarning](
	[intTypeEarningId] [int] IDENTITY(1,1) NOT NULL,
	[strEarning] [nvarchar](50) NOT NULL,
	[strDescription] [nvarchar](50) NULL,
	[strCheckLiteral] [nvarchar](50) NULL,
	[strCalculationType] [nvarchar](50) NULL,
	[dblAmount] [numeric](18, 6) NULL DEFAULT ((0)),
	[dblDefaultHours] [numeric](18, 6) NULL DEFAULT ((0)),
	[strW2Code] [nvarchar](50) NULL,
	[intAccountId] INT NULL,
	[intSort] [int] NULL,
	[intConcurrencyId] [int] NULL DEFAULT ((1)), 
    CONSTRAINT [PK_tblPRTypeEarning] PRIMARY KEY ([intTypeEarningId]), 
    CONSTRAINT [AK_tblPRTypeEarning_strEarning] UNIQUE ([strEarning])
) ON [PRIMARY]
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTypeEarning',
    @level2type = N'COLUMN',
    @level2name = N'intTypeEarningId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Earning Type Name',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTypeEarning',
    @level2type = N'COLUMN',
    @level2name = N'strEarning'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Description',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTypeEarning',
    @level2type = N'COLUMN',
    @level2name = N'strDescription'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Check Literal',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTypeEarning',
    @level2type = N'COLUMN',
    @level2name = N'strCheckLiteral'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Calculation Type',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTypeEarning',
    @level2type = N'COLUMN',
    @level2name = N'strCalculationType'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Amount',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTypeEarning',
    @level2type = N'COLUMN',
    @level2name = N'dblAmount'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Default Hours',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTypeEarning',
    @level2type = N'COLUMN',
    @level2name = N'dblDefaultHours'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'W2 Code',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTypeEarning',
    @level2type = N'COLUMN',
    @level2name = N'strW2Code'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Account Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTypeEarning',
    @level2type = N'COLUMN',
    @level2name = N'intAccountId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTypeEarning',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTypeEarning',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'