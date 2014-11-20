CREATE TABLE [dbo].[tblPRTypeTimeOff](
	[intTypeTimeOffId] INT NOT NULL,
	[strTimeOff] nvarchar(30) NOT NULL,
	[strDescription] NVARCHAR(50) NULL, 
	[intTypeEarningId] INT NULL,
	[dtmEligible] DATETIME NULL, 
	[dblRate] [numeric](18, 6) NULL DEFAULT ((0)),
	[dblPerPeriod] [numeric](18, 6) NULL DEFAULT ((0)),
	[strPeriod] NVARCHAR(30) NULL DEFAULT ((0)),
	[strAwardPeriod] NVARCHAR(30) NULL DEFAULT ((0)),
	[dblMaxEarned] [numeric](18, 6) NULL DEFAULT ((0)),
	[dblMaxCarryover] [numeric](18, 6) NULL DEFAULT ((0)),
	[intAccountId] [int] NULL,
	[intSort] INT NULL,
	[intConcurrencyId] [int] NULL DEFAULT ((1))
    CONSTRAINT [PK_tblPRTypeTimeOff] PRIMARY KEY ([intTypeTimeOffId])
	)
GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_tblPRTypeTimeOff] ON [dbo].[tblPRTypeTimeOff] ([intTypeTimeOffId], [strTimeOff]) WITH (IGNORE_DUP_KEY = OFF)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTypeTimeOff',
    @level2type = N'COLUMN',
    @level2name = N'intTypeTimeOffId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Time Off Type ID',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTypeTimeOff',
    @level2type = N'COLUMN',
    @level2name = 'strTimeOff'
GO

GO

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Rate',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTypeTimeOff',
    @level2type = N'COLUMN',
    @level2name = 'dblRate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Per Period',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTypeTimeOff',
    @level2type = N'COLUMN',
    @level2name = 'dblPerPeriod'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Period',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTypeTimeOff',
    @level2type = N'COLUMN',
    @level2name = 'strPeriod'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Award Period',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTypeTimeOff',
    @level2type = N'COLUMN',
    @level2name = 'strAwardPeriod'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Max Carryover',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTypeTimeOff',
    @level2type = N'COLUMN',
    @level2name = 'dblMaxCarryover'
GO

GO

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTypeTimeOff',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Description',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTypeTimeOff',
    @level2type = N'COLUMN',
    @level2name = N'strDescription'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Max Earned',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTypeTimeOff',
    @level2type = N'COLUMN',
    @level2name = N'dblMaxEarned'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Liability Account',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTypeTimeOff',
    @level2type = N'COLUMN',
    @level2name = N'intAccountId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTypeTimeOff',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Eligible Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTypeTimeOff',
    @level2type = N'COLUMN',
    @level2name = N'dtmEligible'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Earning Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTypeTimeOff',
    @level2type = N'COLUMN',
    @level2name = N'intTypeEarningId'