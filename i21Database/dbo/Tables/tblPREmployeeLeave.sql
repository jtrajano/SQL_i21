CREATE TABLE [dbo].[tblPREmployeeLeave](
	[intEmployeeLeaveId] [int] NOT NULL IDENTITY,
	[intEmployeeId] INT NOT NULL,
	[intLeaveTypeId] INT NOT NULL,
	[intAccountId] INT NULL,
	[dtmEligible] [datetime] NULL DEFAULT (getdate()),
	[dblHoursPerYear] [numeric](18, 6) NULL DEFAULT ((0)),
	[dblHoursPerPeriod] [numeric](18, 6) NULL DEFAULT ((0)),
	[dblHoursAccrued] [numeric](18, 6) NULL DEFAULT ((0)),
	[dblHoursUsed] [numeric](18, 6) NULL DEFAULT ((0)),
	[dblCarryOver] [numeric](18, 6) NULL DEFAULT ((0)),
	[ysnActive] [bit] NULL DEFAULT ((1)),
	[intSort] [int] NULL,
	[intConcurrencyId] [int] NULL DEFAULT ((1)), 
    CONSTRAINT [PK_tblPREmployeeLeave] PRIMARY KEY ([intEmployeeLeaveId]), 
    CONSTRAINT [FK_tblPREmployeeLeave_tblPREmployee] FOREIGN KEY ([intEmployeeId]) REFERENCES [tblPREmployee]([intEmployeeId]), 
    --CONSTRAINT [FK_tblPREmployeeLeave_tblPRLeaveType] FOREIGN KEY ([intLeaveTypeId]) REFERENCES [tblPRLeaveType]([intLeaveTypeId]),
) ON [PRIMARY]
GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_tblPREmployeeLeave] ON [dbo].[tblPREmployeeLeave] ([intEmployeeId], [intLeaveTypeId]) WITH (IGNORE_DUP_KEY = OFF)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeLeave',
    @level2type = N'COLUMN',
    @level2name = N'intEmployeeLeaveId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Employee Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeLeave',
    @level2type = N'COLUMN',
    @level2name = N'intEmployeeId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Leave Type Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeLeave',
    @level2type = N'COLUMN',
    @level2name = N'intLeaveTypeId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Account Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeLeave',
    @level2type = N'COLUMN',
    @level2name = N'intAccountId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Date Eligible',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeLeave',
    @level2type = N'COLUMN',
    @level2name = N'dtmEligible'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Hours Per Year',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeLeave',
    @level2type = N'COLUMN',
    @level2name = N'dblHoursPerYear'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Hours Per Period',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeLeave',
    @level2type = N'COLUMN',
    @level2name = N'dblHoursPerPeriod'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Hours Accrued',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeLeave',
    @level2type = N'COLUMN',
    @level2name = N'dblHoursAccrued'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Hours Used',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeLeave',
    @level2type = N'COLUMN',
    @level2name = N'dblHoursUsed'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Hours Carried Over',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeLeave',
    @level2type = N'COLUMN',
    @level2name = N'dblCarryOver'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Active',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeLeave',
    @level2type = N'COLUMN',
    @level2name = N'ysnActive'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeLeave',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeLeave',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'