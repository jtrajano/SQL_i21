CREATE TABLE [dbo].[tblPRTypeTimeOff](
	[intTypeTimeOffId] INT NOT NULL,
	[strTimeOff] nvarchar(30) NOT NULL,
	[strDescription] NVARCHAR(50) NULL, 
	[dblAccrualRate] [numeric](18, 6) NULL DEFAULT ((0)),
	[dblPerPeriod] [numeric](18, 6) NULL DEFAULT ((0)),
	[strAccrualPeriod] NVARCHAR(30) NULL DEFAULT ((0)),
	[strAwardPeriod] NVARCHAR(30) NULL DEFAULT ((0)),
	[dblMaxCarryover] [numeric](18, 6) NULL DEFAULT ((0)),
	[intConcurrencyId] [int] NULL DEFAULT ((1)), 
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
    @value = N'Accrual Rate',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTypeTimeOff',
    @level2type = N'COLUMN',
    @level2name = 'dblAccrualRate'
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
    @value = N'Accrual Period',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTypeTimeOff',
    @level2type = N'COLUMN',
    @level2name = 'strAccrualPeriod'
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