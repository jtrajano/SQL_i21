CREATE TABLE [dbo].[tblPRPayGroup]
(
	[intPayGroupId] INT NOT NULL IDENTITY, 
    [strPayGroup] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strDescription] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [strPayPeriod] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[intBankAccountId] INT NULL, 
	[dtmBeginDate] [datetime] NULL,
	[dtmEndDate] [datetime] NULL,
	[dtmPayDate] [datetime] NULL,
	[dblHolidayHours] [numeric](18, 6) NULL,
	[ysnStandardHours] [bit] NOT NULL DEFAULT ((1)),
	[ysnExcludeDeductions] [bit] NOT NULL DEFAULT ((0)),
    [intSort] INT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((1)), 
    CONSTRAINT [PK_tblPRPayGroup] PRIMARY KEY ([intPayGroupId]), 
    CONSTRAINT [AK_tblPRPayGroup_strPayGroup] UNIQUE ([strPayGroup]) 
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPayGroup',
    @level2type = N'COLUMN',
    @level2name = N'intPayGroupId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Pay Group',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPayGroup',
    @level2type = N'COLUMN',
    @level2name = N'strPayGroup'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Description',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPayGroup',
    @level2type = N'COLUMN',
    @level2name = N'strDescription'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Pay Period',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPayGroup',
    @level2type = N'COLUMN',
    @level2name = N'strPayPeriod'
GO

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPayGroup',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPayGroup',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Bank Account',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPayGroup',
    @level2type = N'COLUMN',
    @level2name = N'intBankAccountId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Begin Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPayGroup',
    @level2type = N'COLUMN',
    @level2name = N'dtmBeginDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'End Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPayGroup',
    @level2type = N'COLUMN',
    @level2name = N'dtmEndDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Pay Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPayGroup',
    @level2type = N'COLUMN',
    @level2name = N'dtmPayDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Holiday Hours',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPayGroup',
    @level2type = N'COLUMN',
    @level2name = N'dblHolidayHours'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Standard Hours',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPayGroup',
    @level2type = N'COLUMN',
    @level2name = N'ysnStandardHours'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Exclude Deductions',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPayGroup',
    @level2type = N'COLUMN',
    @level2name = N'ysnExcludeDeductions'