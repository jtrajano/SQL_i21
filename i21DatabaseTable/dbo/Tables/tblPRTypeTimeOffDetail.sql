CREATE TABLE [dbo].[tblPRTypeTimeOffDetail]
(
	[intTypeTimeOffDetailId] INT NOT NULL PRIMARY KEY IDENTITY,
	[intTypeTimeOffId] INT NOT NULL,
	[dblYearsOfService] NUMERIC (18, 6)  DEFAULT ((0)) NULL,
	[strDescription]   NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
	[dblRate]          NUMERIC (18, 6)  DEFAULT ((0)) NULL,
    [dblPerPeriod]     NUMERIC (18, 6) DEFAULT ((0)) NULL,
    [strPeriod]        NVARCHAR (30) COLLATE Latin1_General_CI_AS   NULL,
    [dblMaxEarned]     NUMERIC (18, 6) DEFAULT ((0)) NULL,
    [dblMaxCarryover]  NUMERIC (18, 6)  DEFAULT ((0)) NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((1)),
	CONSTRAINT [FK_tblPRTypeTimeOffDetail_tblPRTypeTimeOff] FOREIGN KEY ([intTypeTimeOffId]) REFERENCES [dbo].[tblPRTypeTimeOff] ([intTypeTimeOffId]) ON DELETE CASCADE
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Key',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTypeTimeOffDetail',
    @level2type = N'COLUMN',
    @level2name = N'intTypeTimeOffDetailId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Rate',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTypeTimeOffDetail',
    @level2type = N'COLUMN',
    @level2name = N'dblRate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Per Period',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTypeTimeOffDetail',
    @level2type = N'COLUMN',
    @level2name = N'dblPerPeriod'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Period',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTypeTimeOffDetail',
    @level2type = N'COLUMN',
    @level2name = N'strPeriod'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Max Earned',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTypeTimeOffDetail',
    @level2type = N'COLUMN',
    @level2name = N'dblMaxEarned'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Max Carryover',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTypeTimeOffDetail',
    @level2type = N'COLUMN',
    @level2name = N'dblMaxCarryover'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTypeTimeOffDetail',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Time Off Type Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTypeTimeOffDetail',
    @level2type = N'COLUMN',
    @level2name = N'intTypeTimeOffId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Years of Service',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTypeTimeOffDetail',
    @level2type = N'COLUMN',
    @level2name = N'dblYearsOfService'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Description',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTypeTimeOffDetail',
    @level2type = N'COLUMN',
    @level2name = N'strDescription'