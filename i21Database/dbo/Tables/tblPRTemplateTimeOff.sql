CREATE TABLE [dbo].[tblPRTemplateTimeOff](
	[intTemplateTimeOffId] INT NOT NULL,
	[intTemplateId] [int] NOT NULL,
	[intTypeTimeOffId] INT NOT NULL, 
	[dblAccrualRate] [numeric](18, 6) NULL DEFAULT ((0)),
	[dblPerPeriod] [numeric](18, 6) NULL DEFAULT ((0)),
	[strAccrualPeriod] NVARCHAR(30) NULL DEFAULT ((0)),
	[strAwardPeriod] NVARCHAR(30) NULL DEFAULT ((0)),
	[dblMaxCarryover] [numeric](18, 6) NULL DEFAULT ((0)),
	[dtmEligible] [datetime] NULL DEFAULT (getdate()),
	[intSort] [int] NULL,
	[intConcurrencyId] [int] NULL DEFAULT ((1))
    CONSTRAINT [PK_tblPRTemplateTimeOff] PRIMARY KEY ([intTemplateTimeOffId])
	)
GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_tblPRTemplateTimeOff] ON [dbo].[tblPRTemplateTimeOff] ([intTemplateTimeOffId], [intTypeTimeOffId]) WITH (IGNORE_DUP_KEY = OFF)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateTimeOff',
    @level2type = N'COLUMN',
    @level2name = N'intTemplateTimeOffId'
GO

GO

GO

GO

GO

GO

GO

GO

GO

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateTimeOff',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateTimeOff',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Employee Template Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateTimeOff',
    @level2type = N'COLUMN',
    @level2name = N'intTemplateId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Time-Off Type Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateTimeOff',
    @level2type = N'COLUMN',
    @level2name = N'intTypeTimeOffId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Accrual Rate',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateTimeOff',
    @level2type = N'COLUMN',
    @level2name = N'dblAccrualRate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Per Period',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateTimeOff',
    @level2type = N'COLUMN',
    @level2name = N'dblPerPeriod'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Accrual Period',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateTimeOff',
    @level2type = N'COLUMN',
    @level2name = N'strAccrualPeriod'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Award Period',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateTimeOff',
    @level2type = N'COLUMN',
    @level2name = N'strAwardPeriod'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Max Carryover',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateTimeOff',
    @level2type = N'COLUMN',
    @level2name = N'dblMaxCarryover'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Date Eligible',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateTimeOff',
    @level2type = N'COLUMN',
    @level2name = N'dtmEligible'