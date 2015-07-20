CREATE TABLE [dbo].[tblPRTimecard]
(
	[intTimecardId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [dtmDate] DATETIME NOT NULL, 
    [intEmployeeId] INT NOT NULL, 
	[dtmDateIn] DATETIME NULL, 
    [dtmTimeIn] DATETIME NULL, 
	[dtmDateOut] DATETIME NULL,
    [dtmTimeOut] DATETIME NULL, 
	[dblHours] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [dblRegularHours] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [dblOvertimeHours] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [intEmployeeEarningId] INT NULL, 
	[intEmployeeDepartmentId] INT NULL, 
    [intTimeEntryId] INT NULL, 
	[intPaycheckId] INT NULL, 
    [strNotes] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, 
    [ysnApproved] BIT NULL DEFAULT ((0)), 
    [intConcurrencyId] INT NULL DEFAULT ((1))
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Key',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTimecard',
    @level2type = N'COLUMN',
    @level2name = N'intTimecardId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Entry Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTimecard',
    @level2type = N'COLUMN',
    @level2name = N'dtmDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Employee Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTimecard',
    @level2type = N'COLUMN',
    @level2name = N'intEmployeeId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Time In',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTimecard',
    @level2type = N'COLUMN',
    @level2name = N'dtmTimeIn'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Time Out',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTimecard',
    @level2type = N'COLUMN',
    @level2name = N'dtmTimeOut'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Employee Earning Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTimecard',
    @level2type = N'COLUMN',
    @level2name = N'intEmployeeEarningId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Time Entry Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTimecard',
    @level2type = N'COLUMN',
    @level2name = N'intTimeEntryId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Notes',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTimecard',
    @level2type = N'COLUMN',
    @level2name = N'strNotes'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'is Approved',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTimecard',
    @level2type = N'COLUMN',
    @level2name = N'ysnApproved'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTimecard',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Employee Department Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTimecard',
    @level2type = N'COLUMN',
    @level2name = N'intEmployeeDepartmentId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Hours',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTimecard',
    @level2type = N'COLUMN',
    @level2name = N'dblHours'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Regular Hours',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTimecard',
    @level2type = N'COLUMN',
    @level2name = N'dblRegularHours'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Overtime Hours',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTimecard',
    @level2type = N'COLUMN',
    @level2name = N'dblOvertimeHours'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Date In',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTimecard',
    @level2type = N'COLUMN',
    @level2name = N'dtmDateIn'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Date Out',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTimecard',
    @level2type = N'COLUMN',
    @level2name = N'dtmDateOut'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Paycheck Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTimecard',
    @level2type = N'COLUMN',
    @level2name = N'intPaycheckId'