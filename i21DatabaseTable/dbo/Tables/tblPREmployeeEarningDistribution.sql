CREATE TABLE [dbo].[tblPREmployeeEarningDistribution] (
    [intEmployeeEarningDistributionId] INT NOT NULL IDENTITY,
    [intEmployeeEarningId]    INT NOT NULL,
	[intAccountId]			  INT NULL,
    [dblPercentage]           NUMERIC(18,6) NULL,
    [intConcurrencyId]        INT NULL,
    CONSTRAINT [PK_tblPREmployeeEarningDistribution] PRIMARY KEY CLUSTERED ([intEmployeeEarningDistributionId] ASC),
    CONSTRAINT [FK_tblPREmployeeEarningDistribution_tblPREmployeeEarning] FOREIGN KEY ([intEmployeeEarningId]) REFERENCES [dbo].[tblPREmployeeEarning] ([intEmployeeEarningId]) ON DELETE CASCADE, 
    CONSTRAINT [FK_tblPREmployeeEarningDistribution_tblGLAccount] FOREIGN KEY ([intAccountId]) REFERENCES [tblGLAccount]([intAccountId])
);
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeEarningDistribution',
    @level2type = N'COLUMN',
    @level2name = N'intEmployeeEarningDistributionId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Earning Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeEarningDistribution',
    @level2type = N'COLUMN',
    @level2name = N'intEmployeeEarningId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Percentage',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeEarningDistribution',
    @level2type = N'COLUMN',
    @level2name = N'dblPercentage'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeEarningDistribution',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Expense Account',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREmployeeEarningDistribution',
    @level2type = N'COLUMN',
    @level2name = N'intAccountId'