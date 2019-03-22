CREATE TABLE [dbo].[tblPRTimeEntry]
(
	[intTimeEntryId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [intEmployeeId] INT NOT NULL, 
    [dtmDateFrom] DATETIME NOT NULL, 
    [dtmDateTo] DATETIME NOT NULL, 
    [dblHours] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [dblRegularHours] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [dblOvertimeHours] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [intPaycheckId] INT NULL, 
    [ysnApproved] BIT NULL DEFAULT ((0)), 
    [intConcurrencyId] INT NULL DEFAULT ((1))
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Key',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTimeEntry',
    @level2type = N'COLUMN',
    @level2name = N'intTimeEntryId'
GO

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Employee Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTimeEntry',
    @level2type = N'COLUMN',
    @level2name = N'intEmployeeId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Date From',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTimeEntry',
    @level2type = N'COLUMN',
    @level2name = N'dtmDateFrom'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Date To',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTimeEntry',
    @level2type = N'COLUMN',
    @level2name = N'dtmDateTo'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Hours',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTimeEntry',
    @level2type = N'COLUMN',
    @level2name = N'dblHours'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Regular Hours',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTimeEntry',
    @level2type = N'COLUMN',
    @level2name = N'dblRegularHours'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Overtime Hours',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTimeEntry',
    @level2type = N'COLUMN',
    @level2name = N'dblOvertimeHours'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Paycheck Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTimeEntry',
    @level2type = N'COLUMN',
    @level2name = N'intPaycheckId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'is Approved',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTimeEntry',
    @level2type = N'COLUMN',
    @level2name = N'ysnApproved'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTimeEntry',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'