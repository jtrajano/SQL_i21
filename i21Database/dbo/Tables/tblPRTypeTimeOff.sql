CREATE TABLE [dbo].[tblPRTypeTimeOff](
	[intTypeTimeOffId] INT NOT NULL,
	[strTimeOff] nvarchar(30) NOT NULL,
	[strDescription] NVARCHAR(50) NULL, 
	[intAccountId] INT NULL,
	[dtmEligible] [datetime] NULL DEFAULT (getdate()),
	[dblHoursPerYear] [numeric](18, 6) NULL DEFAULT ((0)),
	[dblHoursPerPeriod] [numeric](18, 6) NULL DEFAULT ((0)),
	[dblHoursAccrued] [numeric](18, 6) NULL DEFAULT ((0)),
	[dblHoursUsed] [numeric](18, 6) NULL DEFAULT ((0)),
	[dblHoursCarriedOver] [numeric](18, 6) NULL DEFAULT ((0)),
	[intSort] [int] NULL,
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
    @value = N'Time-Off Type Name',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTypeTimeOff',
    @level2type = N'COLUMN',
    @level2name = 'strTimeOff'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Account Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTypeTimeOff',
    @level2type = N'COLUMN',
    @level2name = N'intAccountId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Date Eligible',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTypeTimeOff',
    @level2type = N'COLUMN',
    @level2name = N'dtmEligible'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Hours Per Year',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTypeTimeOff',
    @level2type = N'COLUMN',
    @level2name = N'dblHoursPerYear'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Hours Per Period',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTypeTimeOff',
    @level2type = N'COLUMN',
    @level2name = N'dblHoursPerPeriod'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Hours Accrued',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTypeTimeOff',
    @level2type = N'COLUMN',
    @level2name = N'dblHoursAccrued'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Hours Used',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTypeTimeOff',
    @level2type = N'COLUMN',
    @level2name = N'dblHoursUsed'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Hours Carried Over',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTypeTimeOff',
    @level2type = N'COLUMN',
    @level2name = 'dblHoursCarriedOver'
GO

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