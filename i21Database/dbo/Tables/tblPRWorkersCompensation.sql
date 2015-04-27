CREATE TABLE [dbo].[tblPRWorkersCompensation]
(
	[intWorkersCompensationId] INT NOT NULL PRIMARY KEY, 
    [strWCCode] NVARCHAR(50) NOT NULL, 
    [strDescription] NVARCHAR(100) NULL, 
    [intTypeTaxStateId] INT NULL, 
    [intAccountId] INT NULL, 
    [dblRate] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [strCalculationType] NVARCHAR(20) NULL DEFAULT ('Amount'), 
    [intConcurrencyId] INT NULL DEFAULT ((1))
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRWorkersCompensation',
    @level2type = N'COLUMN',
    @level2name = N'intWorkersCompensationId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'WC Code',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRWorkersCompensation',
    @level2type = N'COLUMN',
    @level2name = N'strWCCode'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'State Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRWorkersCompensation',
    @level2type = N'COLUMN',
    @level2name = N'intTypeTaxStateId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Description',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRWorkersCompensation',
    @level2type = N'COLUMN',
    @level2name = N'strDescription'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Account Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRWorkersCompensation',
    @level2type = N'COLUMN',
    @level2name = N'intAccountId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Rate',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRWorkersCompensation',
    @level2type = N'COLUMN',
    @level2name = N'dblRate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'strCalculationType',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRWorkersCompensation',
    @level2type = N'COLUMN',
    @level2name = 'strCalculationType'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRWorkersCompensation',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'