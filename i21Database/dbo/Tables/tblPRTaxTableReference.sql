CREATE TABLE [dbo].[tblPRTaxTableReference]
(
	[intTaxTableReferenceId] INT NOT NULL IDENTITY, 
    [intYear] INT NOT NULL, 
    [dblSSLimit] NUMERIC(18, 6) NOT NULL DEFAULT ((0)), 
    [dblSSEmployeeRate] NUMERIC(18, 6) NOT NULL DEFAULT ((0)), 
    [dblSSEmployerRate] NUMERIC(18, 6) NOT NULL DEFAULT ((0)), 
    [dblMedEmployeeRate] NUMERIC(18, 6) NOT NULL DEFAULT ((0)), 
    [dblMedEmployerRate] NUMERIC(18, 6) NOT NULL DEFAULT ((0)), 
    [dblMedThresholdSingle] NUMERIC(18, 6) NOT NULL DEFAULT ((0)), 
    [dblMedThresholdMarried] NUMERIC(18, 6) NOT NULL DEFAULT ((0)), 
    [intConcurrencyId] INT NOT NULL DEFAULT ((1)),
	CONSTRAINT [PK_tblPRTaxTableReference] PRIMARY KEY ([intTaxTableReferenceId]), 
	CONSTRAINT [AK_tblPRTaxTableReference_intYear] UNIQUE ([intYear])
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Tax Year',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTaxTableReference',
    @level2type = N'COLUMN',
    @level2name = N'intYear'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTaxTableReference',
    @level2type = N'COLUMN',
    @level2name = N'intTaxTableReferenceId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Social Security Taxable Limit',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTaxTableReference',
    @level2type = N'COLUMN',
    @level2name = N'dblSSLimit'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Social Security Employee Rate',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTaxTableReference',
    @level2type = N'COLUMN',
    @level2name = 'dblSSEmployeeRate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Social Security Employer Rate',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTaxTableReference',
    @level2type = N'COLUMN',
    @level2name = N'dblSSEmployerRate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Medicare Employee Rate',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTaxTableReference',
    @level2type = N'COLUMN',
    @level2name = N'dblMedEmployeeRate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Medicare Employer Rate',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTaxTableReference',
    @level2type = N'COLUMN',
    @level2name = N'dblMedEmployerRate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Medicare Threshold Amount Single',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTaxTableReference',
    @level2type = N'COLUMN',
    @level2name = N'dblMedThresholdSingle'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Medicare Threshold Amount Married',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTaxTableReference',
    @level2type = N'COLUMN',
    @level2name = N'dblMedThresholdMarried'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTaxTableReference',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'