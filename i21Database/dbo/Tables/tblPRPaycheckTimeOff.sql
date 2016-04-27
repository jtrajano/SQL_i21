CREATE TABLE [dbo].[tblPRPaycheckTimeOff]
(
	[intPaycheckTimeOffId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [intPaycheckId] INT NOT NULL,
	[intEmployeeTimeOffId] INT NOT NULL, 
    [intTypeTimeOffId] INT NOT NULL, 
    [dblRate] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [dblPerPeriod] NUMERIC(18, 6) NULL DEFAULT ((0)), 
	[strPeriod] NVARCHAR(30) COLLATE Latin1_General_CI_AS NULL,
    [dblRateFactor] NUMERIC(18, 6) NULL DEFAULT ((1)), 
    [dblMaxEarned] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [dblMaxCarryover] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [dblHoursAccrued] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [dblHoursUsed] NUMERIC(18, 6) NULL DEFAULT ((0)), 
	[dblHoursYTD] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [intConcurrencyId] INT NULL DEFAULT ((1))
    
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPaycheckTimeOff',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPaycheckTimeOff',
    @level2type = N'COLUMN',
    @level2name = N'intPaycheckTimeOffId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Employee Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPaycheckTimeOff',
    @level2type = N'COLUMN',
    @level2name = N'intPaycheckId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Employee Time Off Type Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPaycheckTimeOff',
    @level2type = N'COLUMN',
    @level2name = N'intEmployeeTimeOffId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Time Off Type Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPaycheckTimeOff',
    @level2type = N'COLUMN',
    @level2name = N'intTypeTimeOffId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Rate',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPaycheckTimeOff',
    @level2type = N'COLUMN',
    @level2name = N'dblRate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Per Period',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPaycheckTimeOff',
    @level2type = N'COLUMN',
    @level2name = N'dblPerPeriod'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Period',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPaycheckTimeOff',
    @level2type = N'COLUMN',
    @level2name = N'strPeriod'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Rate Factor',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPaycheckTimeOff',
    @level2type = N'COLUMN',
    @level2name = N'dblRateFactor'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Max Carryover',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPaycheckTimeOff',
    @level2type = N'COLUMN',
    @level2name = N'dblMaxCarryover'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Max Earned',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPaycheckTimeOff',
    @level2type = N'COLUMN',
    @level2name = N'dblMaxEarned'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Hours Accrued',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPaycheckTimeOff',
    @level2type = N'COLUMN',
    @level2name = N'dblHoursAccrued'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Hours Used',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPaycheckTimeOff',
    @level2type = N'COLUMN',
    @level2name = N'dblHoursUsed'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Hours YTD',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPaycheckTimeOff',
    @level2type = N'COLUMN',
    @level2name = N'dblHoursYTD'