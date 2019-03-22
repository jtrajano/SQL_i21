CREATE TABLE [dbo].[tblPRTemplateEarningDistribution]
(
	[intTemplateEarningDistributionId] INT NOT NULL IDENTITY,
    [intTemplateEarningId]    INT NOT NULL,
	[intAccountId]			  INT NULL,
    [dblPercentage]           NUMERIC(18,6) NULL,
    [intConcurrencyId]        INT NULL,
    CONSTRAINT [PK_tblPRTemplateEarningDistribution] PRIMARY KEY CLUSTERED ([intTemplateEarningDistributionId] ASC),
    CONSTRAINT [FK_tblPRTemplateEarningDistribution_tblPRTemplateEarning] FOREIGN KEY ([intTemplateEarningId]) REFERENCES [dbo].[tblPRTemplateEarning] ([intTemplateEarningId]) ON DELETE CASCADE, 
    CONSTRAINT [FK_tblPRTemplateEarningDistribution_ToTable] FOREIGN KEY ([intAccountId]) REFERENCES [tblGLAccount]([intAccountId])
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateEarningDistribution',
    @level2type = N'COLUMN',
    @level2name = N'intTemplateEarningDistributionId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Earning Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateEarningDistribution',
    @level2type = N'COLUMN',
    @level2name = N'intTemplateEarningId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Expense Account',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateEarningDistribution',
    @level2type = N'COLUMN',
    @level2name = N'intAccountId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Percentage',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateEarningDistribution',
    @level2type = N'COLUMN',
    @level2name = N'dblPercentage'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTemplateEarningDistribution',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'