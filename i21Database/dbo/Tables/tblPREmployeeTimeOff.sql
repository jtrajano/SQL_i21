CREATE TABLE [dbo].[tblPREmployeeTimeOff](
	[intEmployeeTimeOffId] [int] NOT NULL IDENTITY,
	[intEmployeeId] INT NOT NULL,
	[intTypeTimeOffId] INT NOT NULL,
	[dblAccrualRate] [numeric](18, 6) NULL DEFAULT ((0)),
	[dblPerPeriod] [numeric](18, 6) NULL DEFAULT ((0)),
	[strAccrualPeriod] NVARCHAR(30) NULL DEFAULT ((0)),
	[strAwardPeriod] NVARCHAR(30) NULL DEFAULT ((0)),
	[dblMaxCarryover] [numeric](18, 6) NULL DEFAULT ((0)),
	[dtmLastAward] DATETIME NULL, 
    [dblHoursAccrued] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [dblHoursEarned] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [dblHoursUsed] NUMERIC(18, 6) NULL DEFAULT ((0)), 
	[dtmEligible] [datetime] NULL DEFAULT (getdate()),
	[intSort] [int] NULL,
	[intConcurrencyId] [int] NULL DEFAULT ((1)), 
    CONSTRAINT [PK_tblPREmployeeTimeOff] PRIMARY KEY ([intEmployeeTimeOffId]), 
    CONSTRAINT [FK_tblPREmployeeTimeOff_tblPREmployee] FOREIGN KEY ([intEmployeeId]) REFERENCES [tblPREmployee]([intEmployeeId]), 
    CONSTRAINT [FK_tblPREmployeeTimeOff_tblPRTypeTimeOff] FOREIGN KEY ([intTypeTimeOffId]) REFERENCES [tblPRTypeTimeOff]([intTypeTimeOffId]),
) ON [PRIMARY]
GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_tblPREmployeeTimeOff] ON [dbo].[tblPREmployeeTimeOff] ([intEmployeeId], [intTypeTimeOffId]) WITH (IGNORE_DUP_KEY = OFF)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeTimeOff',
    @level2type = N'COLUMN',
    @level2name = N'intEmployeeTimeOffId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Employee Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeTimeOff',
    @level2type = N'COLUMN',
    @level2name = N'intEmployeeId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Time Off Type Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeTimeOff',
    @level2type = N'COLUMN',
    @level2name = N'intTypeTimeOffId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Date Eligible',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeTimeOff',
    @level2type = N'COLUMN',
    @level2name = N'dtmEligible'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeTimeOff',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeTimeOff',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Accrual Rate',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeTimeOff',
    @level2type = N'COLUMN',
    @level2name = N'dblAccrualRate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Per Period',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeTimeOff',
    @level2type = N'COLUMN',
    @level2name = N'dblPerPeriod'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Accrual Period',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeTimeOff',
    @level2type = N'COLUMN',
    @level2name = N'strAccrualPeriod'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Award Period',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeTimeOff',
    @level2type = N'COLUMN',
    @level2name = N'strAwardPeriod'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Max Carryover',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeTimeOff',
    @level2type = N'COLUMN',
    @level2name = N'dblMaxCarryover'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Last Award Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeTimeOff',
    @level2type = N'COLUMN',
    @level2name = N'dtmLastAward'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Hours Accrued',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeTimeOff',
    @level2type = N'COLUMN',
    @level2name = N'dblHoursAccrued'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Hours Earned',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeTimeOff',
    @level2type = N'COLUMN',
    @level2name = N'dblHoursEarned'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Hours Used',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeTimeOff',
    @level2type = N'COLUMN',
    @level2name = N'dblHoursUsed'